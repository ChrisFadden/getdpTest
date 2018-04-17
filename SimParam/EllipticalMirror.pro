/* ---------------------------------------
   Definition of the physical regions
   --------------------------------------- */
Group {
	//Boundaries
	Gama1 = Region[ 2 ];
	Gama0 = Region[{333,555} ];
	
	Recv = Region[ 786 ];
	//The Entire Domain
	Omega = Region[{1,Gama0}]; //Treat srcs/sinks like background

	//Closure of Domain
	AllOmega = Region[{Omega,Gama1,Recv}];
}

/* ---------------------------------------
   User defined functions/values
   --------------------------------------- */
Function {
	
	//Initial Position
	InitialState[AllOmega] = 0.;

	u[] = 0.;
	t0 = 0.;
	dt = 0.1;
	T = 50 * dt;

	//Time Step parameters (Newmark)
	beta = 0.25;
	gamma = 0.5;
}

/* ---------------------------------------
   Dirichlet constraints
   --------------------------------------- */
Constraint {
	//Initial State
	{	Name InitialData; Type Init;
		Case {
			{ Region Omega; Value InitialState[]; }
		}
	}

	//Apply Source
	{	Name Source; Type Assign;
		Case {
			{ Region Gama1; Value 1.;}// TimeFunction u[]; }
		}
	}

	//PEC boundaries
}

/* ---------------------------------------
   Includes
   --------------------------------------- */
Include "InitJacobian.pro"       
Include "WaveSolve.pro"

/*=============
Post Operation
=============*/

PostOperation {
   {Name Map_Omega; NameOfPostProcessing WaveSolver;
      Operation{
				Print[Fixed, OnElementsOf Recv, Format NodeTable, File "BndMeas.tdat"];
      }
   }
}


