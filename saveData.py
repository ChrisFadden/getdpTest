import h5py
import numpy as np
import gmsh

fout = './build/Estatic.h5'
fn = './build/microstrip.msh'

mesh = gmsh.Mesh()
mesh.read_msh(fn)


##Save Mesh to HDF5
f5 = h5py.File(fout,"w")
gpmesh = f5.create_group("Mesh")

#Nodes
gpmesh.create_dataset("nodes", data=mesh.Verts)

#Elements
types = list(mesh.Elmts.keys())

#Create for each element type
for ii in types:
    gpmesh.create_dataset("ElemType" + str(ii) + "_Tag",data = mesh.Elmts[ii][0])
    gpmesh.create_dataset("ElemType" + str(ii) + "_Nodes",data = mesh.Elmts[ii][1])

#PhysTypes
typeList = []
for key, value in mesh.Phys.items(): 
    typeList.append(str(key) + "_" + value)
typeList = [n.encode("ascii","ignore") for n in typeList]
gpmesh.create_dataset("Physical Types", (len(typeList),1),'S20',typeList)

#Save Data to HDF5
#fn = './build/Vnode.dat'
#vout = np.loadtxt(fn,skiprows=1,usecols=1)
#f5.create_dataset("Vout",data=vout)

f5.close()
