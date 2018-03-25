import numpy as np
from scipy.interpolate import griddata
import matplotlib.pyplot as plt
import h5py


dx = 0.2
dy = 0.2

Gx = 10
Gy = 10

gx = np.arange(0,Gx+1,dx)
gy = np.arange(0,Gy+1,dy)

fout = './build/Estatic.h5'
f5 = h5py.File(fout,"a")

nodes = np.asarray(f5['/nodes'])
Vout = np.asarray(f5['/Vout'])

#print(np.min(nodes[:,0]))
#print(np.max(nodes[:,0]))
#print(np.min(nodes[:,1]))
#print(np.max(nodes[:,1]))

grid_x, grid_y = np.meshgrid(gx,gy)
interpData = griddata((nodes[:,0],nodes[:,1]), Vout, (grid_x, grid_y), method='cubic')

plt.imshow(interpData,origin='lower')
plt.colorbar()
plt.show()
