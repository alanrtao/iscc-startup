#!/usr/bin/env python3


# This script will generate HPL .dat files, so that runs can be automated.

import os

# DATA BLOCK
# ******* Only fill out this block *******
NODES = 1   # Number of nodes
TASKS_PER_NODE = 96 # Cores per node
MEMORY_PER_CPU_GB = 1.87 # Memory per core --> make sure this is in GB due to conversion.
BLOCK_SIZE_NB_lst = []  # block size that the system works on. Common sizes are 100-256, but do not limit runs to range. Should be multiple of value P*Q that more or less fits in stated range.
for i in range(100, 256):  # Change range to try different values!
    if i % (NODES*TASKS_PER_NODE) == 0:
        BLOCK_SIZE_NB_lst.append(i)
#print(BLOCK_SIZE_NB_lst)
P_Q_lst = [(4,24), (8,12), (2,48), (1,96)]  # Base combinations off NODES*TASKS_PER_NODE. You want P and Q to be close to each other with P being the smaller of the two.
TOTAL_MEM_TO_USE = 0.9  # Give floating num 0 to 1. Starting range should be 0.7-0.8.
# END OF DATA BLOCK

Ns_VALUE = (((NODES*TASKS_PER_NODE)*(MEMORY_PER_CPU_GB)*(1073741824)*(TOTAL_MEM_TO_USE))/8)**0.5  # Make sure to convert GB to bytes. Do not use SI units.
Ns_INT = int(Ns_VALUE)
#print(Ns_INT)

for pq in P_Q_lst:
    #print(pq)
    for NB in BLOCK_SIZE_NB_lst:
        #print(block_size)
        Ns_DIVISIBLE_BY_NB = Ns_INT - Ns_INT % NB
        HPL_DAT_FILE = f'''HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any) 
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
{Ns_DIVISIBLE_BY_NB}         Ns
1            # of NBs
{NB}           NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
{pq[0]}            Ps
{pq[1]}            Qs
16.0         threshold
1            # of panel fact
2            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
1            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
1            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
2            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)'''
        output_dir = f"hpl_runs/p{pq[0]}q{pq[1]}_nodes{NODES}cpus{TASKS_PER_NODE}/NB{NB}"  # This will be created in working dir.
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        with open(os.path.join(output_dir, f"HPL_NB{NB}_p{pq[0]}q{pq[1]}_nodes{NODES}cpus{TASKS_PER_NODE}.dat"), "a") as outfile:
            outfile.write(HPL_DAT_FILE)
