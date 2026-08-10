"""Mirror of PickLine's bucketing, run against the real pack content.

Verifies the rules that matter: an outcome draws from its own lines, falls
through the near-miss chain, and lands on the untagged set when nothing was
written for it. Also proves every tag in the content is one the addon knows.
"""
import re
import sys

OUTCOME_ACCEPTS = {
    'hit': ['hit'],
    'crit': ['crit', 'hit'],
    'miss': ['miss'],
    'dodge': ['dodge', 'miss'],
    'parry': ['parry', 'miss'],
    'block': ['block', 'hit'],
    'resist': ['resist', 'miss'],
    'immune': ['immune', 'resist', 'miss'],
    'absorb': ['absorb', 'resist', 'miss'],
    'reflect': ['reflect', 'miss'],
}


def strip_tags(line):
    """mood, outcome, body -- either order, same as StripTags."""
    mood = None
    rest = line
    m = re.match(r'^\[([A-Za-z][A-Za-z0-9_ ]*)\]\s*(.*)$', rest)
    if m:
        mood, rest = m.group(1).lower(), m.group(2)
    outcome = None
    m = re.match(r'^<([A-Za-z]+)>\s*(.*)$', rest)
    if m:
        outcome, rest = m.group(1).lower(), m.group(2)
    if mood is None:
        m = re.match(r'^\[([A-Za-z][A-Za-z0-9_ ]*)\]\s*(.*)$', rest)
        if m:
            mood, rest = m.group(1).lower(), m.group(2)
    return mood, outcome, rest


def pick(words, outcome, has_target=True):
    """Returns (used_tag, candidate_lines) -- used_tag None means untagged."""
    plain, tagged = [], {}
    for w in words:
        _, tag, body = strip_tags(w)
        if not has_target and '%t' in body:
            continue
        (tagged.setdefault(tag, []) if tag else plain).append(w)
    for tag in OUTCOME_ACCEPTS.get(outcome, []):
        if tagged.get(tag):
            return tag, tagged[tag]
    return None, plain


def load(path):
    """key -> list of lines, straight out of the pack's `lines` table."""
    src = open(path, encoding='utf-8').read()
    sets, key, cur = {}, None, None
    for line in src.split('\n'):
        m = re.match(r'\s*\["([^"]+)"\]\s*=\s*\{\s*$', line)
        if m:
            key, cur = m.group(1), []
            continue
        if cur is not None:
            if re.match(r'\s*\},\s*$', line):
                sets[key] = cur
                key, cur = None, None
            else:
                m = re.match(r'\s*"(.*)",\s*$', line)
                if m:
                    cur.append(m.group(1))
    return sets


sets = load(sys.argv[1])
fails = 0


def show(key, outcome, expect_tag):
    global fails
    words = sets[key]
    tag, cands = pick(words, outcome)
    ok = tag == expect_tag
    if not ok:
        fails += 1
    print('%-4s %-22s %-8s -> %-10s %s' % (
        'ok' if ok else 'FAIL', key, outcome or '(none)',
        '<%s>' % tag if tag else 'untagged',
        cands[0][:58] if cands else '!! nothing eligible'))


print('--- outcome routing')
show('SPELL:Fireball', 'crit', 'crit')
show('SPELL:Fireball', 'miss', 'miss')
show('SPELL:Fireball', 'resist', 'resist')
show('SPELL:Fireball', 'hit', None)          # no <hit> lines -> untagged
show('SPELL:Fireball', None, None)           # timeout path -> untagged only
show('SPELL:Ice Lance', 'resist', 'miss')    # no <resist> -> falls to <miss>
show('SPELL:Frost Nova', 'immune', 'immune')
show('SPELL:Frost Nova', 'absorb', 'miss')   # absorb -> resist -> miss
show('MELEE', 'dodge', 'miss')               # dodge -> miss
show('MELEE', 'parry', 'miss')
show('MELEE', 'crit', 'crit')
show('MELEE', 'block', None)                 # block -> hit -> none -> untagged
show('SPELL:Polymorph', 'hit', 'hit')
show('SPELL:Polymorph', 'miss', 'miss')
show('SPELL:Blink', 'crit', None)            # untagged spell, unchanged

print()
print('--- no target: every bucket must still have something to say')
for key in sorted(k for k in sets if any(strip_tags(w)[1] for w in sets[k])):
    for outcome in ('crit', 'miss', 'hit', 'immune'):
        tag, cands = pick(sets[key], outcome, has_target=False)
        if not cands:
            print('FAIL %s / %s: nothing eligible without a target' % (key, outcome))
            fails += 1

print()
print('--- tags used in content')
known = set(OUTCOME_ACCEPTS)
seen = {}
for key, words in sets.items():
    for w in words:
        _, tag, _ = strip_tags(w)
        if tag:
            seen[tag] = seen.get(tag, 0) + 1
        elif w.startswith('<'):
            print('FAIL unparsed tag-looking line in %s: %s' % (key, w[:50]))
            fails += 1
for tag, count in sorted(seen.items()):
    bad = '' if tag in known else '   <-- UNKNOWN TAG'
    if bad:
        fails += 1
    print('  <%s> x%d%s' % (tag, count, bad))

print()
print('FAILURES:', fails)
sys.exit(1 if fails else 0)
