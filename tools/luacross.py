"""Flag a function that is a file-local in one addon file and called bare in another.

Lua has no imports. A `local function Debug` in RPVox.lua is invisible to
RPVoxBubble.lua, so a bare `Debug(...)` there resolves to a global, which is
nil, and throws only when that line runs. It parses cleanly and `luaorder.py`
cannot see it either -- that check compares a use against a definition in the
*same* file, and here there is no definition to compare against.

That is exactly how 4.6 shipped with a nil Debug call on the world-mode path.

The rule here is narrow on purpose, so its output is worth reading: report a
called name only when some *other* file in the addon declares it as a
file-scope local and this one does not. Genuine WoW API calls are never
file-locals anywhere, so they are silently ignored, and no whitelist has to be
maintained.
"""
import re
import sys

DEF_FUNC = re.compile(r'^local\s+function\s+([A-Za-z_][A-Za-z0-9_]*)')
DEF_VAR = re.compile(r'^local\s+([A-Za-z_][A-Za-z0-9_]*)\s*=')
CALL = re.compile(r'(?<![.:%\w])([A-Za-z_][A-Za-z0-9_]*)\s*\(')
KEYWORDS = {'if', 'while', 'for', 'return', 'and', 'or', 'not', 'function',
            'elseif', 'until', 'do', 'then', 'end', 'local', 'in'}


def strip(src):
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if src.startswith('--', i):
            m = re.match(r'--\[(=*)\[', src[i:])
            if m:
                close = ']' + m.group(1) + ']'
                j = src.find(close, i)
                j = n if j < 0 else j + len(close)
            else:
                j = src.find('\n', i)
                j = n if j < 0 else j
        elif c in '"\'':
            j = i + 1
            while j < n and src[j] != c and src[j] != '\n':
                j += 2 if src[j] == '\\' else 1
            j = min(j + 1, n)
        elif c == '[' and re.match(r'\[(=*)\[', src[i:]):
            m = re.match(r'\[(=*)\[', src[i:])
            close = ']' + m.group(1) + ']'
            j = src.find(close, i)
            j = n if j < 0 else j + len(close)
        else:
            out.append(c)
            i += 1
            continue
        out.append(re.sub(r'[^\n]', ' ', src[i:j]))
        i = j
    return ''.join(out)


files = {}
for path in sys.argv[1:]:
    files[path] = strip(open(path, encoding='utf-8').read()).split('\n')

# every file-scope local, and which files declare it
locals_by_file = {}
for path, lines in files.items():
    names = set()
    for line in lines:
        m = DEF_FUNC.match(line) or DEF_VAR.match(line)
        if m and m.group(1) not in KEYWORDS:
            names.add(m.group(1))
    locals_by_file[path] = names

bad = 0
for path, lines in files.items():
    mine = locals_by_file[path]
    elsewhere = {}
    for other, names in locals_by_file.items():
        if other == path:
            continue
        for n in names:
            elsewhere.setdefault(n, []).append(other)

    for idx, line in enumerate(lines, 1):
        for name in set(CALL.findall(line)):
            if name in KEYWORDS or name in mine or name not in elsewhere:
                continue
            bad += 1
            print('%s:%d calls %s(), which is a file-local of %s and not of this file\n    %s'
                  % (path, idx, name,
                     ', '.join(x.split('/')[-1].split('\\')[-1] for x in elsewhere[name]),
                     line.strip()[:66]))

print('cross-file nil calls:', bad)
sys.exit(1 if bad else 0)
