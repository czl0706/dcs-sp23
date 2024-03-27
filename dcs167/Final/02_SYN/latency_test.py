import os
import re
import math

min_prod = math.inf
min_CYC = 0

flog = open('./letency_test.log', 'w')

for i in range(35, 45 + 1):
    violated = False
    prod = 0
    logstr = 'CYCLE TIME: ' + str(f'{i/10:.1f}')
    
    fin  = open('./syn.tcl_t', 'r')
    fout = open('./syn.tcl', 'w')
    for line in fin:
        fout.write(line.replace('set CYCLE {CYC}', f'set CYCLE {i/10:.1f}'))
    fin.close()
    fout.close()

    os.system('./01_run_dc > /dev/null 2>&1')

    with open('./syn.log', 'r') as f:
        for line in f:
            if 'Total cell area: ' in line:
                prod = float(line.split()[-1]) * i / 10
                logstr += ' ' + str(prod)
            if 'VIOLATED' in line:
                violated = True
                logstr += ' ' + 'VIOLATED!'

    if prod < min_prod and not violated:
        min_prod = prod
        min_CYC = i / 10

    flog.write(logstr)
    flog.write('\n')
    print(logstr)

logstr = f'min: {min_CYC}, {min_prod}'
flog.write(logstr)
print(logstr)

flog.close()