import h5py
import numpy as np
import random
import re
import gmsh

fout = './build/Estatic.h5'
fn = './build/microstrip.msh'
fn = './build/mStrip_e.pos'

#Load Mesh
mesh = gmsh.Mesh()
mesh.read_msh(fn)

#Save Mesh to HDF5
f5 = h5py.File(fout,"w")

f5.create_dataset("nodes", data=mesh.Verts)
#f5.create_dataset("nodes", data=nodes,compression='gszip',compression_opts=9)

#Save Data to HDF5
fn = './build/Vnode.dat'
vout = np.loadtxt(fn,skiprows=1,usecols=1)
f5.create_dataset("Vout",data=vout)

f5.close()
