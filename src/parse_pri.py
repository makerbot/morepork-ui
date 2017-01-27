#!/usr/bin/env python

import argparse
import re

def comment_strip(lines):
    """
    Very stupid comment stripper

    Does not handle any attempt to use # for anything other than a
    comment.  Only works because we explicitly disallow any attepmts
    to escape special characters.
    """
    for line in lines:
        yield line.partition('#')[0]

def continuation_merge(lines):
    """
    Handle line continuations

    God this is ugly
    """
    lines = iter(lines)
    for line in lines:
        line = line.rstrip('\n')
        line_parts = []
        while line.endswith('\\'):
            line_parts.append(line[:-1].strip())
            try:
                line = next(lines).rstrip('\n')
            except StopIteration:
                line = ''
        if line: line_parts.append(line.strip())
        yield ' '.join(line_parts)

def check_id(s, pattern=re.compile('[\w./]*$')):
    if not pattern.match(s):
        raise Exception('Invalid syntax: %r' % s)

def parse_file(file, vars=None):
    """
    Parse an open file object

    This just looks for variable assignments and returns a dict mapping
    variable names to values.  A value is a list regardless of how many
    space separated items are present on the RHS.
    """
    if not vars: vars = {}
    for line in continuation_merge(comment_strip(f)):
        if not line: continue
        if any(c in line for c in '"\'\\'):
            raise Exception('No quotes or escapes -- use sane file names!')
        elems = line.split()
        if len(elems) < 2:
            raise Exception('Unknown syntax: %r' % line)
        elif elems[1] in ('=', '+='):
            check_id(elems[0])
            [check_id(id) for id in elems[2:]]
            if elems[1] == '=': vars[elems[0]] = []
            vars.setdefault(elems[0], []).extend(elems[2:])
        else:
            raise Exception('Unknown syntax: %s' % ' '.join(elems[:2]+['...']))
    return vars

def parse_args():
    parser = argparse.ArgumentParser('Parse simple Qt pro/pri files')
    parser.add_argument('input', help='File to parse')
    parser.add_argument('--var', '-v',
                        help='Variable to output (CMake formatted)')
    parser.add_argument('--dir', '-d', help='Leading directory to strip')
    return parser.parse_args()

def output_val(val, args):
    if args.dir:
        dir_prefix = args.dir + '/'
        for v in val:
            if not v.startswith(dir_prefix):
                raise Exception('Path %s must start with %s' % (v, dir_prefix))
        val = [v[len(dir_prefix):] for v in val]
    print(';'.join(val))

if __name__ == '__main__':
    args = parse_args()
    with open(args.input) as f:
        vars = parse_file(f)
    if args.var:
        val = vars.get(args.var, [])
        output_val(val, args)
    else:
        print('Parsed %s successfully' % args.input)
