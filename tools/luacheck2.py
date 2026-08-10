"""Single-pass Lua lexer, enough to verify block balance and string termination.

Handles strings and comments in one pass so a '--' inside a string is not
mistaken for a comment, which is what broke the naive regex version.
"""
import re
import sys

WORD = re.compile(r'[A-Za-z_][A-Za-z0-9_]*')
OPEN = {'function', 'if', 'for', 'while', 'do', 'repeat'}


def lex(src):
    i, n, line = 0, len(src), 1
    out = []
    while i < n:
        c = src[i]
        if c == '\n':
            line += 1
            i += 1
        elif src.startswith('--', i):
            i += 2
            m = re.match(r'\[(=*)\[', src[i:])
            if m:                                   # long comment
                close = ']' + m.group(1) + ']'
                j = src.find(close, i)
                if j < 0:
                    return out, f'unterminated long comment at line {line}'
                line += src.count('\n', i, j)
                i = j + len(close)
            else:
                j = src.find('\n', i)
                i = n if j < 0 else j
        elif c in '"\'':
            j = i + 1
            while j < n:
                if src[j] == '\\':
                    j += 2
                    continue
                if src[j] == '\n':
                    return out, f'unterminated string at line {line}'
                if src[j] == c:
                    break
                j += 1
            if j >= n:
                return out, f'unterminated string at line {line}'
            i = j + 1
        elif c == '[' and re.match(r'\[(=*)\[', src[i:]):
            m = re.match(r'\[(=*)\[', src[i:])
            close = ']' + m.group(1) + ']'
            j = src.find(close, i)
            if j < 0:
                return out, f'unterminated long string at line {line}'
            line += src.count('\n', i, j)
            i = j + len(close)
        else:
            m = WORD.match(src, i)
            if m:
                out.append((line, m.group(0)))
                i = m.end()
            else:
                i += 1
    return out, None


def check(path):
    src = open(path, encoding='utf-8').read()
    toks, err = lex(src)
    if err:
        return f'{path}: {err}'

    stack = []
    prev = None
    for line, t in toks:
        if t in ('function', 'if', 'while', 'for', 'repeat'):
            stack.append((t, line))
        elif t == 'do':
            if not (stack and stack[-1][0] in ('for', 'while')
                    and prev != 'end'):
                stack.append(('do', line))
        elif t == 'until':
            if stack and stack[-1][0] == 'repeat':
                stack.pop()
            else:
                return f'{path}: stray until at line {line}'
        elif t == 'end':
            if not stack:
                return f'{path}: extra end at line {line}'
            stack.pop()
        prev = t

    if stack:
        return f'{path}: unclosed {stack[-3:]}'
    return f'{path}: OK'


for p in sys.argv[1:]:
    print(check(p))
