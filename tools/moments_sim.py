"""Check the new moment sets: routing, target-free fallbacks, known tags."""
import re
import sys

ACCEPTS = {
    'hit': ['hit'], 'crit': ['crit', 'hit'], 'miss': ['miss'],
    'dodge': ['dodge', 'miss'], 'parry': ['parry', 'miss'],
    'block': ['block', 'hit'], 'resist': ['resist', 'miss'],
    'immune': ['immune', 'resist', 'miss'],
    'absorb': ['absorb', 'resist', 'miss'], 'reflect': ['reflect', 'miss'],
}


def strip(line):
    mood = out = None
    rest = line
    m = re.match(r'^\[([A-Za-z][\w ]*)\]\s*(.*)$', rest)
    if m:
        mood, rest = m.group(1).lower(), m.group(2)
    m = re.match(r'^<([A-Za-z]+)>\s*(.*)$', rest)
    if m:
        out, rest = m.group(1).lower(), m.group(2)
    return mood, out, rest


def pick(words, outcome, target=True):
    plain, tagged = [], {}
    for w in words:
        _, tag, body = strip(w)
        if not target and '%t' in body:
            continue
        (tagged.setdefault(tag, []) if tag else plain).append(w)
    for tag in ACCEPTS.get(outcome, []):
        if tagged.get(tag):
            return tag, tagged[tag]
    return None, plain


sets, key, cur = {}, None, None
for line in open(sys.argv[1], encoding='utf-8').read().split('\n'):
    m = re.match(r'\s*\["([^"]+)"\]\s*=\s*\{\s*$', line)
    if m:
        key, cur = m.group(1), []
        continue
    if cur is not None:
        if re.match(r'\s*\},\s*$', line):
            sets[key] = cur
            key = cur = None
        else:
            m = re.match(r'\s*"(.*)",\s*$', line)
            if m:
                cur.append(m.group(1))

fails = 0
print('%-16s %6s %6s %6s %6s' % ('trigger', 'lines', 'crit', 'miss', 'other'))
for k in ('MELEE', 'COMBAT:SPELL', 'COMBAT:HEAL', 'COMBAT:BUFF', 'COMBAT:CC'):
    if k not in sets:
        print('FAIL missing', k)
        fails += 1
        continue
    w = sets[k]
    tags = {}
    for x in w:
        t = strip(x)[1]
        if t:
            tags[t] = tags.get(t, 0) + 1
        if t and t not in ACCEPTS:
            print('FAIL unknown tag <%s> in %s' % (t, k))
            fails += 1
    other = sum(v for t, v in tags.items() if t not in ('crit', 'miss'))
    print('%-16s %6d %6d %6d %6d'
          % (k, len(w), tags.get('crit', 0), tags.get('miss', 0), other))

    # every outcome must have something to say, with and without a target
    for outcome in ('hit', 'crit', 'miss', 'resist', 'immune', 'dodge', None):
        for target in (True, False):
            tag, cands = pick(w, outcome, target)
            if not cands:
                print('FAIL %s / %s / target=%s -> nothing eligible'
                      % (k, outcome, target))
                fails += 1

if 'SPELL:Fireball' in sets:
    print('FAIL a per-spell override survived')
    fails += 1

print('\nspell overrides remaining:',
      len([k for k in sets if k.startswith('SPELL:')]))
print('FAILURES:', fails)
sys.exit(1 if fails else 0)
