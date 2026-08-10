"""Audit a moments-era class pack before it ships.

Checks the things this project has learned the hard way:
  - every trigger key the addon defines is covered (a gap silently leaks
    generic RPVox_LINES into the voice)
  - no key the addon does not define (a typo would just never fire)
  - %t never sits at the end of a line, where a rhyme would land on a name
  - every set has at least two lines that work with no target selected
  - no near-duplicate lines (same text once the target's name is removed)
  - outcome tags are ones the addon knows
"""
import io
import re
import sys

ADDON, PACK = sys.argv[1], sys.argv[2]
KNOWN_TAGS = {'hit', 'crit', 'miss', 'dodge', 'parry', 'block',
              'resist', 'immune', 'absorb', 'reflect'}

core = io.open(ADDON, encoding='utf-8', newline='').read()
b = core[core.index('local BUILTIN = {'):core.index('local PROFESSIONS = {')]
keys = re.findall(r'\{ key = "([^"]+)"', b)
p = core[core.index('local PROFESSIONS = {'):core.index('for _, p in ipairs(PROFESSIONS)')]
keys += ['IDLE:CRAFT:' + x for x in re.findall(r'\{\s*"([^"]+)"', p)]
required = set(keys)

sets, key, cur = {}, None, None
for line in io.open(PACK, encoding='utf-8', newline='').read().split('\n'):
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

bad = 0


def fail(msg):
    global bad
    bad += 1
    print('FAIL ' + msg)


for k in sorted(required - set(sets)):
    fail('missing trigger set: %s' % k)
for k in sorted(set(sets) - required):
    fail('set for a trigger that does not exist: %s' % k)


def body(line):
    t = re.sub(r'^<(\w+)>\s*', '', line)
    return re.sub(r'^\[[^\]]*\]\s*', '', t)


def fingerprint(line):
    t = body(line)
    t = re.sub(r'\{[^}]*\}', '', t)
    t = re.sub(r'[*_~#^]', '', t)
    t = t.replace('%t', '').replace('%s', '')
    t = re.sub(r'[^\w\s]', '', t)
    return re.sub(r'\s+', ' ', t).strip().lower()


for k in sorted(sets):
    lines = sets[k]
    if not lines:
        fail('%s is empty' % k)
        continue

    targetless = 0
    seen = {}
    for w in lines:
        m = re.match(r'^<(\w+)>', w)
        if m and m.group(1).lower() not in KNOWN_TAGS:
            fail('%s: unknown outcome tag <%s>' % (k, m.group(1)))

        t = body(w)
        if '%t' not in t:
            targetless += 1
        else:
            # a name must never land where a rhyme is expected
            stripped = re.sub(r'[\s"\'.,!?]+$', '', t)
            if stripped.endswith('%t'):
                fail('%s: %%t at the end of a line (a name cannot rhyme)\n     %s'
                     % (k, w[:78]))

        f = fingerprint(w)
        seen.setdefault(f, []).append(w)

    if targetless < 2:
        fail('%s: only %d line(s) work with no target selected'
             % (k, targetless))
    for f, group in seen.items():
        if len(group) > 1:
            fail('%s: %d lines say the same thing\n     %s'
                 % (k, len(group), '\n     '.join(x[:70] for x in group)))

print('sets: %d   required: %d   problems: %d' % (len(sets), len(required), bad))
sys.exit(1 if bad else 0)
