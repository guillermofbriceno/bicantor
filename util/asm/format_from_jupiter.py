import sys

with open (sys.argv[1], 'r') as f:
    next(f)
    next(f)
    for line in f:
        print(line[2:], end="")
        

