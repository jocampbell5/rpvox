"""Mirror of LineFingerprint / TrimNearDuplicates, run over a pack file.

Reports any set where two lines say the same thing once the target's name,
colour tags and emphasis markers are removed -- the pattern that made every
list look half repeated.
"""
import re
import sys


def fingerprint(line):
    body = re.sub(r'^\[[^\]]*\]\s*', '', line)
    body = re.sub(r'^<\w+>\s*', '', body)
    body = re.sub(r'\{[^}]*\}', '', body)
    body = re.sub(r'[*_~#^]', '', body)
    body = body.replace('%t', '').replace('%s', '')
    body = re.sub(r'[^\w\s]', '', body)
    return re.sub(r'\s+', ' ', body).strip().lower()


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

worst = 0
for k in sorted(sets):
    groups = {}
    for w in sets[k]:
        groups.setdefault(fingerprint(w), []).append(w)
    dups = {f: g for f, g in groups.items() if len(g) > 1}
    bare = sum(1 for w in sets[k] if '%t' not in w)
    flag = ''
    if dups:
        flag = '  <-- %d repeated' % sum(len(g) - 1 for g in dups.values())
        worst += 1
    if bare == 0:
        flag += '  <-- no target-free line, silent with no target'
        worst += 1
    print('%-22s %3d lines  %2d target-free%s' % (k, len(sets[k]), bare, flag))
    for g in dups.values():
        for w in g:
            print('      %s' % w[:70])

print('\nsets with problems:', worst)
sys.exit(1 if worst else 0)
