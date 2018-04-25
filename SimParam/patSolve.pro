/*====================
  Functional Spaces
====================*/

FunctionSpace {	
		
	//DOT Function Space
	{ Name phiFuncSpace; Type Form0;
		BasisFunction{
			{Name wn; NameOfCoef vn; Function BF_Node;
			Support AllOmega; Entity NodesOf[All]; }
		}
		
		//Constraint for the Source
		Constraint {
			{ NameOfCoef vn; EntityType NodesOf; NameOfConstraint Source_Set; }
		}

	}

	//WaveEqn Function Space (and Constraint of DOT for Init Condition)
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
							{Name phi; Type Local; NameOfSpace phiFuncSpace;}	
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
	//Fluence Equations
	{ Name dotFormulation; Type FemEquation;
		Quantity { { Name phi; Type Local; NameOfSpace phiFuncSpace;} }
		Equation {
			Integral{[ -mua[] * Dof{phi}, {phi}];
				In AllOmega; Jacobian JVol; Integration I1;}
	
			Integral{ [ kappa[] * Dof{d phi}, {d phi} ];
				In AllOmega; Jacobian JVol; Integration I1;}
		}
	}

	//Copy "phi" in "phi_aux"
  {Name CopyPhi; Type FemEquation;
    Quantity{
      {Name phi; Type Local; NameOfSpace phiFuncSpace; }
      {Name phi_aux; Type Local; NameOfSpace pressureFuncSpace;}
    }
    Equation{
      Galerkin{ [Dof{phi_aux}, {phi_aux}];
        In AllOmega; Jacobian JVol; Integration I1;}

      Galerkin{ [-mua[]*{phi}, {phi_aux}];
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

	{Name dotSolve;
    System{
    //System associated to "phi" will be transfered to the weak formulation of "v"
      {Name PbPhi; NameOfFormulation dotFormulation;}
      {Name PbPhiaux; NameOfFormulation CopyPhi; DestinationSystem wave_sys;}
    }
    Operation{
      Generate[PbPhi]; Solve[PbPhi]; SaveSolution[PbPhi];
      Generate[PbPhiaux]; Solve[PbPhiaux]; TransferSolution[PbPhiaux];
    }
  }

}

/*==============
Post Processing
==============*/

PostProcessing {
		
	{Name CoupledProblem; NameOfFormulation waveFormulation; 
    Quantity{
      {Name Fluence; Value {Local{[{phi}];In AllOmega; Jacobian JVol;}}}
			{Name initPressure; Value {Local{[mua[] * {phi}]; In AllOmega; Jacobian JVol;}}}
      {Name Pressure; Value {Local{[{p}];In AllOmega; Jacobian JVol;}}}
			{ Name measPressure; Value {Local{[{p}]; In Bndry; Jacobian JVol;}}}
		}
  }
}
