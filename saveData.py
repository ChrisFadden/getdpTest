import h5py
import numpy as np
import random
import re

fout = './build/Estatic.h5'
f5 = h5py.File(fout,"w")

#Node File
fn = './build/microstrip.msh'
fp = open(fn,"r")

nflag = False
eflag = False
ii = 0
for line in fp:
    if("$EndNodes" in line):
        break 
    if(eflag): 
        linerg = re.findall('[\d.]+',line)
        nodes[ii,0] = linerg[1]
        nodes[ii,1] = linerg[2]
        #nodes[ii,2] = linerg[3]
        ii = ii+1
    if(nflag):
        nflag = False
        numNodes = int(line)
        #nodes = np.zeros((numNodes,3))
        nodes = np.zeros((numNodes,2))
	eflag = True
    if("$Nodes" in line):
        nflag = True
fp.close()

f5.create_dataset("nodes", data=nodes)
#f5.create_dataset("nodes", data=nodes,compression='gszip',compression_opts=9)

#First File
fn = './build/Vnode.dat'
vout = np.loadtxt(fn,skiprows=1,usecols=1)

f5.create_dataset("Vout",data=vout)


