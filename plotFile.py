import h5py
import numpy as np
import gmsh

fn = './build/output.h5'
fplot = './build/output.pos'

#Mesh object for nodes per element
tmp = gmsh.Mesh()
elm_type = tmp.elm_type

#Load Data
fd = './build/Vnode.dat'
vout = np.loadtxt(fd,skiprows=1,usecols=1)

##Load Mesh Nodes
f5 = h5py.File(fn,"r")
nodes = np.asarray(f5['/Mesh/nodes'])

#Output File for Plotting
fp = open(fplot,"w")
fp.write("$MeshFormat$\n")
fp.write("2.2 0 8\n")
fp.write("$EndMeshFormat$\n")

#Write out the Nodes
fp.write("$Nodes\n")
fp.write(str(nodes.shape[0]) + "\n")
for ii in np.arange(nodes.shape[0]):
    fp.write(str(ii+1) + " ")
    fp.write(str(nodes[ii,0]) + " ")
    fp.write(str(nodes[ii,1]) + " ")
    fp.write(str(nodes[ii,2]) + "\n")
fp.write("$EndNodes\n")

#Write out the Elements
fp.write("$Elements\n")
f5elemType = f5['/Mesh/Elements']
numElements = str(np.asarray(f5elemType['NumElements']))
fp.write(numElements+"\n")
ii = 1
for kk in f5elemType.keys():
    if("NumElements" not in kk):
        f5elem = f5elemType[kk] 
        typeElem = kk[8:]
        tags = np.asarray(f5elem['Tag'])
        elmNodes = np.asarray(f5elem['Nodes'])
        for jj in np.arange(tags.shape[0]):
            fp.write(str(ii) + " ")
            fp.write(str(typeElem) + " ")
            fp.write("2" + " ") #Number of tags (assumed 2)
        
            #Tags are not important for plotting
            fp.write("1" + " ")
            fp.write("1" + " ")
        
            #write out nodes for element
            for ll in np.arange(elmNodes.shape[1]-1):
                fp.write(str(elmNodes[jj,ll]) + " ")
            fp.write(str(elmNodes[jj,elmNodes.shape[1]-1]) + "\n")
            ii = ii+1

fp.write("$EndElements\n")

#Write out Elements Data
fp.write("$ElementNodeData\n")
fp.write("1\n") #number of view tags
fp.write("\"Voltage Output\"\n") #Name of view
fp.write("1\n") #The number of real tags (time values)
fp.write("0.0\n") #The time value
fp.write("3\n") #The number of integer tags
fp.write("0\n") #The time step (always starts at 0)
fp.write("1\n") #The components for each field (1 = scalar)
fp.write(numElements + "\n")

#write out data
ii = 1
for kk in f5elemType.keys():
    if("NumElements" not in kk):
        f5elem = f5elemType[kk] 
        typeElem = kk[8:]
        tags = np.asarray(f5elem['Tag'])
        elmNodes = np.asarray(f5elem['Nodes'])
        for jj in np.arange(tags.shape[0]):
            fp.write(str(ii) + " ")
            fp.write(str(elm_type[int(typeElem)]) + " ")              
          
            #write out nodes for element
            for ll in np.arange(elmNodes.shape[1]-1):
                nodeIdx = elmNodes[jj,ll]
                fp.write(str(vout[nodeIdx]) + " ")
            nodeIdx = elmNodes[jj,elmNodes.shape[1]-1]
            fp.write(str(vout[nodeIdx]) + "\n")
            ii = ii+1
fp.write("$EndElementNodeData\n")
fp.close()
f5.close()
