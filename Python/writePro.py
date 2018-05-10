import h5py
import numpy as np
import sys

#fn = sys.argv[1] #'../build/output.h5'
fn = "toy.h5"
fpro = "./output/toy_"

#Set Files
fps = ["dot","mwave","acous"]

#Set order
groups = ["freespace","skull","whitematter","greymatter","csf","scatterer"]
groups.extend(["FreeSpaceTR","Sources","Detectors","PML"])

##Load Data
f5 = h5py.File(fn,"r")

for name in fps:
     
    fp = open(fpro + name + ".pro","w")

    #Write Physical Regions 
    fp.write("/* --------------------------------\n")
    fp.write(" * Definition of Physical Regions\n")
    fp.write(" * --------------------------------*/\n")
    fp.write("Group {\n")
    fp.write("\n")
    fp.write("\t " + groups[0] + " = Region[100];\n")
    fp.write("\t " + groups[1] + " = Region[101];\n")
    fp.write("\t " + groups[2] + " = Region[102];\n")
    fp.write("\t " + groups[3] + " = Region[103];\n")
    fp.write("\t " + groups[4] + " = Region[104];\n")
    fp.write("\t " + groups[5] + " = Region[105];\n\n")

    fp.write("\t " + groups[6] + " = Region[106];\n")
    fp.write("\t " + groups[7] + " = Region[107];\n")
    fp.write("\t " + groups[8] + " = Region[108];\n")
    fp.write("\t " + groups[9] + " = Region[109];\n\n")

    fp.write("\t Bndry = Region[{PML}];\n")
    fp.write("\t AllOmega = Region[{skull,freespace,whitematter,")
    fp.write("greymatter,csf,scatter,Sources,Detectors,Bndry}];\n")
    fp.write("}\n\n")

    fp.write("/* ------------------------------\n")
    fp.write(" * User Defined functions/values \n")
    fp.write(" * ------------------------------ */\n")
    fp.write("Function {\n")

    #***********************
    #   Write DOT .pro file
    #***********************
    if(name == "dot"):
        params = np.asarray(f5['/Parameters/DOT'])

        #Set Wavelength
        fp.write("\t lambda = 800.; //nm\n\n")

        #Set Parameters
        for ii in range(len(groups)):
            fp.write("\t mua[" + groups[ii] + "] = " + str(params[ii,0]) + ";\n")
        fp.write("\n")

        for ii in range(len(groups)):
            fp.write("\t kappa[" + groups[ii] + "] = ")
            fp.write("1. / (" + str(3*(params[ii,0] + params[ii,1])) + ");\n")

        fp.write("}\n\n")
        fp.write("Include \"dot.pro\"\n")
        fp.close()

    #****************************
    #   Write Microwave .pro file
    #****************************
    if(name == "mwave"): 
        params = np.asarray(f5['/Parameters/Microwave'])

        #Set Constants
        fp.write("\t mu0 = (4e-10)*Pi;\n")
        fp.write("\t cc = 299792458000.;\n")
        fp.write("\t eps0 = 1. / (cc*cc*mu0);\n")
        fp.write("\t MHz = 1e6;\n")
        fp.write("\t I[] = Complex[0.,1.];\n")

        #Set Frequency
        fp.write("\t FREQ = 1000.; \n")
        fp.write("\t omega = FREQ * 2*Pi*MHz;\n\n")

        #Set Parameters
        for ii in range(len(groups)):
            fp.write("\t eps[" + groups[ii] + "] = " + str(params[ii,0]))
            fp.write("*eps0;\n")
        fp.write("\n")

        for ii in range(len(groups)):
            fp.write("\t mu[" + groups[ii] + "] = " + str(params[ii,1]))
            fp.write("*mu0;\n")
        fp.write("\n")

        for ii in range(len(groups)):
            fp.write("\t sigma[" + groups[ii] + "] = " + str(params[ii,2]))
            fp.write(";\n")

        fp.write("}\n\n")
        fp.write("Include \"mwave.pro\"\n")
        fp.close()

    #***************************
    #   Write Acoustic .pro file
    #***************************
    if(name == "acous"): 
        params = np.asarray(f5['/Parameters/Acoustics'])

        #Set Constants
        fp.write("\t t0 = 0.;\n")
        fp.write("\t dt = 1e-4;\n")
        fp.write("\t T = 50 * dt;\n\n")

        fp.write("\t //Time Step parameters (Newmark)\n")
        fp.write("\t beta = 0.25;\n")
        fp.write("\t gamma = 0.5;\n\n")

        fp.write("\t cc0 = 1.5e6; //mm/s\n\n")

        #Set Parameters
        for ii in range(len(groups)):
            fp.write("\t cc[" + groups[ii] + "] = " + str(1./params[ii,0]))
            fp.write("*cc0;\n")

        fp.write("}\n\n")
        fp.write("Include \"acous.pro\"\n")
        fp.close()



