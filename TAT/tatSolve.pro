/*====================
  Functional Spaces
====================*/

FunctionSpace {	
			
	//Pressure Function Space 
	{ Name pressureFuncSpace; Type Form0;
		BasisFunction{
			{ Name wn; NameOfCoef vn; Function BF_Node;
				Support AllOmega; Entity NodesOf[All];}
		}
		Constraint {			
			//Give Initial Data
			{ NameOfCoef vn; EntityType NodesOf;
					NameOfConstraint InitialData; }
		}
	}
}


/*======================
  Weak formulations
======================*/

Formulation {
		
	//Pressure Equations
	{ Name waveFormulation; Type FemEquation;
		Quantity{ {Name p; Type Local; NameOfSpace pressureFuncSpace;} 
							//{Name p0; Type Local; NameOfSpace phiFuncSpace;}	
		}	
					

		Equation{
			//Inital Time Step
			Galerkin{ DtDof [ ($TimeStep < 2 ? 1 : 0) * Dof{p}, {p} ];
			In AllOmega; Jacobian JVol; Integration I1;}
 
			// Weak formulation after the initialisation of the two first steps
			Galerkin{ DtDtDof [ (1. / cc) * ($TimeStep < 2 ? 0 : 1) * Dof{p}, {p} ];
			In AllOmega; Jacobian JVol; Integration I1;}
 
			Galerkin{ [ ($TimeStep < 2 ? 0 : 1) * Dof{d p}, {d p} ];
			In AllOmega; Jacobian JVol; Integration I1;}        
		}
	}
		
	//Copy Pressure
	{Name CopyPressure; Type FemEquation;
    Quantity{
      {Name p0; Type Local; NameOfSpace pressureFuncSpace;}
    }
		
		Equation{
			Galerkin{ [Dof{p0},{p0} ];
				In AllOmega; Jacobian JVol; Integration I1;}
		
			Galerkin{ [ -Field[XYZ[]], {p0} ];
				In AllOmega; Jacobian JVol; Integration I1;}	
		}
	}	
}

/*======================
  Resolution
======================*/

Resolution {
	//Pressure Resolution
	{ Name waveSolve;
		System{ { Name wave_sys; NameOfFormulation waveFormulation;} }

		Operation{
			// Initialisation
			InitSolution[wave_sys];
			
			//First time step
			TimeLoopTheta[t0,t0 + dt,dt,0.5] {
				Generate[wave_sys]; Solve[wave_sys]; SaveSolution[wave_sys];
			}
				
			TimeLoopNewmark[t0+dt, T, dt, beta, gamma ] {
				Generate[wave_sys]; Solve[wave_sys]; SaveSolution[wave_sys];
			}
			
		}
	}
	
 {Name initResolution;
    System{
    //System associated to "u" will be transfered to the weak formulation of "v"
      {Name PbP0; NameOfFormulation CopyPressure; DestinationSystem wave_sys;}
    }
    Operation{
      GmshRead["initPressure.pos"]; Generate[PbP0]; Solve[PbP0]; TransferSolution[PbP0];
    }
  }

}

/*==============
Post Processing
==============*/

PostProcessing {
		
	{Name CoupledProblem; NameOfFormulation waveFormulation; 
    Quantity{ 
      {Name Pressure; Value {Local{[{p}];In AllOmega; Jacobian JVol;}}}
			{ Name measPressure; Value {Local{[{p}]; In Bndry; Jacobian JVol;}}}
		}
  }
}
