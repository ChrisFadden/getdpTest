import h5py
import numpy as np
import gmsh
import sys

fout = sys.argv[1] #'../build/output.h5'
fn = sys.argv[2] #'../build/Vnode.dat'


#fout = '../build/output.h5'

##Save Output to HDF5
f5 = h5py.File(fout,"a")
#Create group if it does not exist
gpout = f5.require_group("Output")

#Save Data to HDF5
vout = np.loadtxt(fn,skiprows=1,usecols=1)
gpout.create_dataset("Vout",data=vout)

f5.close()
