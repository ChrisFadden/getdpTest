/* ---------------------------------------
   Definition of the physical regions
   --------------------------------------- */
Group {

	backgnd = Region[1];
	scatter = Region[2];
	Sources = Region[333];
	Sinks = Region[555];
	Bndry = Region[786];

	Scatterer = Region[{scatter}];
	Background = Region[{backgnd,Sources,Sinks,Bndry}];

	AllOmega = Region[{backgnd,scatter,Sources,Sinks,Bndry}];
}

/* ---------------------------------------
   User defined functions/values
   --------------------------------------- */
Function {
	
	//Pressure Variables
	src[] = 0.;
	t0 = 0.;
	dt = 1e-4;
	T = 50 * dt;
	
	//Speed of sound
	cc = 1.5e6; //mm/s

	//Time Step parameters (Newmark)
	beta = 0.25;
	gamma = 0.5;
}

/* ---------------------------------------
   Dirichlet constraints
   --------------------------------------- */
Constraint { 
		
	//Initial Pressure 
	{ Name InitialData; 
		Case{ 
			{ Region AllOmega; Type InitFromResolution; NameOfResolution initResolution; }		
		}
	}
	
}

/* ---------------------------------------
   Includes
   --------------------------------------- */
Include "InitJacobian.pro"       
Include "tatSolve.pro"

/*=============
Post Operation
=============*/

PostOperation {
	
	{Name PrintData; NameOfPostProcessing CoupledProblem;
		Operation{
			Print[Pressure, OnElementsOf AllOmega, File "pressure.pos"];
			Print[measPressure, OnElementsOf Bndry, 
				Format NodeTable, File "BndMeas.tdat"];
		}
	}
	
}


