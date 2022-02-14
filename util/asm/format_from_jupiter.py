import sys
import textwrap

new_lines = []
with open (sys.argv[1], 'r') as f:
    next(f)
    next(f)
    for line in f:
        instruction = line[2:].rstrip()
        instruction_endian = list(textwrap.wrap(instruction, 2))
        #instruction_endian.reverse()
        new_lines += instruction_endian

for i in range(1024):
    if i < len(new_lines):
        print(new_lines[i])
    else:
        print("00")




