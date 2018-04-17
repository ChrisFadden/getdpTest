/*====================
  Functional Spaces
====================*/

FunctionSpace { 
   { Name VhDir; Type Form0;
      BasisFunction{
      { Name wn; NameOfCoef vn; Function BF_Node;
         Support AllOmega; Entity NodesOf[All];}
      }
      Constraint {
      { NameOfCoef vn; EntityType NodesOf;
         NameOfConstraint Source; }
      { NameOfCoef vn; EntityType NodesOf;
         NameOfConstraint Fixed; }
      { NameOfCoef vn; EntityType NodesOf;
         NameOfConstraint InitialData; }
      }
   }
}


/*======================
  Weak formulations
======================*/

Formulation {
   { Name Wave; Type FemEquation;
      Quantity{
         { Name v; Type Local; NameOfSpace VhDir;}
      }

   Equation{
	// Membrane fixed, i.e. Dirichlet boundary condition on Gama0
      Galerkin{ DtDof [ ($TimeStep < 2 ? 1 : 0) * Dof{v}, {v} ];
         In Omega; Jacobian JVol; Integration I1;}
       
      // Weak formulation after the initialisation of the two first steps
      Galerkin{ DtDtDof [ ($TimeStep < 2 ? 0 : 1) * Dof{v}, {v} ];
         In Omega; Jacobian JVol; Integration I1;}
       
      Galerkin{ [ ($TimeStep < 2 ? 0 : 1) * Dof{Grad v}, {Grad v} ];
         In Omega; Jacobian JVol; Integration I1;}        
    }
  }
}

/*======================
  Resolution
======================*/

Resolution {
	{ Name WaveSolver;
		System{
			{ Name SysWave; NameOfFormulation Wave;}
		}

		Operation{
			// Initialisation
			InitSolution[SysWave];
			
			//First time step
			TimeLoopTheta[t0,t0 + dt,dt,0.5] {
				Generate[SysWave]; Solve[SysWave];
			}

			TimeLoopNewmark[t0+dt, T, dt, beta, gamma ] {
				Generate[SysWave]; Solve[SysWave];
			}
		}
	}
}

/*==============
Post Processing
==============*/

PostProcessing {
   { Name WaveSolver; NameOfFormulation Wave; NameOfSystem SysWave;
      Quantity{
				{ Name Fixed; Value {Local{[{v}]; In AllOmega; Jacobian JVol;}}}
      }
   }
}
