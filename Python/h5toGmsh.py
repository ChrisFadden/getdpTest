import h5py
import numpy as np
import gmsh
import sys

fn = sys.argv[1] #'../SimParam/output.h5'
fmesh = sys.argv[2] #'../SimParam/microstrip.msh'

###Load Mesh Nodes
f5 = h5py.File(fn,"r")
nodes = np.asarray(f5['/Mesh/nodes'])

##Output File for Mesh
fp = open(fmesh,"w")
fp.write("$MeshFormat\n")
fp.write("2.2 0 8\n")
fp.write("$EndMeshFormat\n")

##Write Out the Physical Names
physNames = np.asarray(f5['/Mesh/Physical Types'])
fp.write("$PhysicalNames\n")
fp.write(str(physNames.shape[0]) + "\n")
for ii in np.arange(physNames.shape[0]):
    #nameStr = physNames[ii][0].decode('UTF-8')
    nameStr = physNames[ii].decode('UTF-8') 
    parseStr = nameStr.split("_") #parse into ElmType Elm_ID Name
    fp.write(parseStr[0] + " ")
    fp.write(parseStr[1] + " ")
    fp.write("\"" + parseStr[2] + "\"\n")
fp.write("$EndPhysicalNames\n")

##Write out the Nodes
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
numElements = str(int(np.asarray(f5elemType['NumElements'])))
fp.write(numElements+"\n")
ii = 1
for kk in f5elemType.keys():
    if("NumElements" not in kk):
        f5elem = f5elemType[kk] 
        typeElem = kk[8:]
        tags = np.asarray(f5elem['Tag'])
        elmNodes = np.asarray(f5elem['Nodes'])
        for jj in np.arange(tags.shape[0]):
            fp.write(str(int(ii)) + " ")
            fp.write(str(int(typeElem)) + " ")
            fp.write("2" + " ") #Number of tags (assumed 2)
        
            #Tags
            fp.write(str(int(tags[jj])) + " ")
            fp.write("2" + " ") #second tag is a further ID i think, hopefully don't need...
             
            #write out nodes for element
            for ll in np.arange(elmNodes.shape[1]-1):
                fp.write(str(int(elmNodes[jj,ll])) + " ")
            fp.write(str(int(elmNodes[jj,elmNodes.shape[1]-1])) + "\n")
            ii = ii+1

fp.write("$EndElements\n")

fp.close()
f5.close()
