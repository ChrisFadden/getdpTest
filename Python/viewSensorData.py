import h5py
import numpy as np
import sys
import matplotlib.pyplot as plt

fn = sys.argv[1] #'../build/output.h5'

##Load Data
f5 = h5py.File(fn,"r")
pout = np.asarray(f5['/Output/Pressure'])

plt.plot(pout[50,1:])
plt.show()
f5.close()
