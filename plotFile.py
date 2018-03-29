import h5py
import numpy as np
import gmsh

fn = './build/output.h5'
fplot = './build/output.pos'

##Load Data
f5 = h5py.File(fn,"r")
nodes = np.asarray(f5['/Mesh/nodes'])

#Output File for Plotting
fp = open(fplot,"w")
fp.write("$MeshFormat$\n")
fp.write("2.2 0 8\n")

#Write out the Nodes
fp.write("$Nodes\n")
fp.write(str(nodes.shape[0]) + "\n")
for ii in np.arange(nodes.shape[0]):
    fp.write(str(ii+1) + " ")
    fp.write(str(nodes[ii,0]+1) + " ")
    fp.write(str(nodes[ii,1]+1) + " ")
    fp.write(str(nodes[ii,2]+1) + "\n")
fp.write("$EndNodes\n")

#Write out the Elements
fp.write("$Elements\n")
f5elemType = f5['/Mesh/Elements']
fp.write(str(np.asarray(f5elemType['NumElements']))+"\n")
ii = 1
for kk in f5elemType.keys():
    if("NumElements" not in kk):
        f5elem = f5elemType[kk] 
        typeElem = kk[8:]
        tags = np.asarray(f5elem['Tag'])
        nodes = np.asarray(f5elem['Nodes'])
        for jj in np.arange(tags.shape[0]):
            fp.write(str(ii) + " ")
            fp.write(str(typeElem) + " ")
            fp.write("2" + " ") #Number of tags (assumed 2)
        
            #Tags are not important for plotting
            fp.write("1" + " ")
            fp.write("1" + " ")
        
            #write out nodes for element
            for ll in np.arange(nodes.shape[1]-1):
                fp.write(str(nodes[jj,ll]+1) + " ")
            fp.write(str(nodes[jj,nodes.shape[1]-1]+1) + "\n")
            ii = ii+1

fp.write("$EndElements")
fp.close()
f5.close()
