#!/usr/bin/python3

import sys
import json

out = []
for fn in sys.argv[1:]:
    with open(fn) as fp:
        out += json.load(fp)
json.dump(out, sys.stdout, indent=2)
print()
