"""Flag FILE-SCOPE locals used before the line that defines them.

Lua resolves a name that is not yet a visible local to a GLOBAL, which is nil.
The call parses fine, a syntax checker passes, and it throws "attempt to call a
nil value" only when that line actually runs -- possibly only on a branch a
user reaches days later.

This addon has been bitten by it four times: WeightedChance reading P and
OutcomeWeight, StockLines calling TrimNearDuplicates, WorldCVars calling
CVarGet. Every one looked right and every one was a nil global.

Scope of the check, deliberately narrow so the output is worth reading:
  - only locals declared at column 0 (`local function F` / `local X = ...`),
    which is where this file keeps the things everything else calls
  - field accesses (`obj.name`, `obj:name`) are not name lookups, so skipped
  - a bare `local X` with no assignment is a forward declaration and is fine

A hit inside a function body is only a bug if that body can run before the
definition line -- which is not decidable here -- but in practice, in this
codebase, every such hit has been real.
"""
import re
import sys

WORD = re.compile(r'(?<![.:%w_])([A-Za-z_][A-Za-z0-9_]*)')
DEF_FUNC = re.compile(r'^local\s+function\s+([A-Za-z_][A-Za-z0-9_]*)')
DEF_VAR = re.compile(r'^local\s+([A-Za-z_][A-Za-z0-9_]*)\s*(=?)')
KEYWORDS = {
    'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function',
    'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then',
    'true', 'until', 'while', 'self',
}


def strip(src):
    """Blank out strings and comments, preserving line structure."""
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


def check(path):
    lines = strip(open(path, encoding='utf-8').read()).split('\n')

    defined, declared, deflines = {}, set(), set()
    for idx, line in enumerate(lines, 1):
        m = DEF_FUNC.match(line)
        if m:
            defined.setdefault(m.group(1), idx)
            deflines.add(idx)
            continue
        m = DEF_VAR.match(line)
        if m and m.group(1) not in KEYWORDS:
            name = m.group(1)
            defined.setdefault(name, idx)
            deflines.add(idx)
            if not m.group(2):
                declared.add(name)

    hits = []
    for idx, line in enumerate(lines, 1):
        if idx in deflines:
            continue
        for name in set(WORD.findall(line)):
            if name in KEYWORDS or name in declared or name not in defined:
                continue
            if idx < defined[name]:
                hits.append((idx, name, defined[name], line.strip()[:66]))
    return hits


bad = 0
for path in sys.argv[1:]:
    for idx, name, defline, text in check(path):
        bad += 1
        print('%s:%d uses %s before its definition at line %d\n    %s'
              % (path, idx, name, defline, text))

print('forward references:', bad)
sys.exit(1 if bad else 0)
