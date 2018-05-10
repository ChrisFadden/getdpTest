import h5py
import numpy as np
import sys

#fn = sys.argv[1] #'../build/output.h5'
fn = "toy.h5"

##Load Data
f5 = h5py.File(fn,"a")

gpParam = f5.require_group("Parameters")

#0  FreeSpace
#1  Skull
#2  WhiteMatter
#3  GreyMatter
#4  CSF
#5  Scatterer
#6  FreeSpaceTR
#7  Sources
#8  Detectors 
#9  PML

mwave = -4 * np.ones([10,3])
mwave[0,:] = [40,1,0]
mwave[1,:] = [40,1,0]
mwave[2,:] = [40,1,0]
mwave[3,:] = [40,1,0]
mwave[4,:] = [40,1,0]

mwave[5,:] = [80,1,20]

mwave[6:,:] = [40,1,0]

gpParam.create_dataset("Microwave",data=mwave) # (epsr,mur,sigma)",data=)

dot = -4 * np.ones([10,2])
dot[0,:] = [0.01,0.1]
dot[1,:] = [0.01,0.1]
dot[2,:] = [0.01,0.1]
dot[3,:] = [0.01,0.1]
dot[4,:] = [0.01,0.1]

dot[5,:] = [1,0.1]

dot[6:,:] = [0.01,0.1]

gpParam.create_dataset("DOT",data=dot) #(mua,mus')

acous = -4 * np.ones([10,1])
acous[0,:] = [1]
acous[1,:] = [1]
acous[2,:] = [1]
acous[3,:] = [1]
acous[4,:] = [1]
acous[5,:] = [1]

acous[6:,:] = [1]
gpParam.create_dataset("Acoustics",data=acous) #(c0/n) Only speed of light for now...

f5.close()




