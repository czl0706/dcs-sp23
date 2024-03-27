# A Python program to print all
# permutations using library function
from itertools import permutations
from os import system
import re
 
# Get all permutations of [1, 2, 3]
perm = permutations(range(16))

min_perm = list()
min_area = 100000000

flog = open("./test.log", "w")

for i in list(perm):
    li = list(i)
    logstr = str(list(i))
    # flog.write(logstr)
    # print(logstr)

    fin  = open("../01_RTL/MIPS_p.sv", "r")
    fout = open("../01_RTL/MIPS.sv", "w")
    print(*li[0:6])
    for line in fin:
        fout.write(line.replace('{PARAMS}', 'IDLE = {}, R = {}, R_GCD = {}, I = {}, INST_FAIL = {}, OUTPUT = {}'.format(*li[0:6])))
    fin.close()
    fout.close()
    system('./01_run_dc')

    fin = open('./syn.log', 'r')
    for line in fin:
        if 'Total cell area: ' in line:
            area = float(line.split()[-1])
            logstr += ' ' + str(area)
            # print(logstr)
            if (area < min_area):
                min_perm = li
                min_area = area
            break
    fin.close()

    flog.write(logstr)
    flog.write('\n')
    print(logstr)

logstr = f'min: {min_perm}, {min_area}'
flog.write(logstr)
print(logstr)

flog.close()