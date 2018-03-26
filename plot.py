import numpy as np
from scipy.interpolate import griddata
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import h5py



fout = './build/Estatic.h5'
f5 = h5py.File(fout,"a")

print("******\n\n")

nodes = np.asarray(f5['/nodes'])
Vout = np.asarray(f5['/Vout'])

GxMax = np.max(nodes[:,0])
GxMin = np.min(nodes[:,0])
GyMax = np.max(nodes[:,1])
GyMin = np.min(nodes[:,1])

gx = np.linspace(GxMin,GxMax,256)
gy = np.linspace(GyMin,GyMax,256)

fig = plt.figure()
ax = fig.gca(projection='3d')

ax.plot(nodes[:,0],nodes[:,1],Vout)
plt.show()
