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
	
	//DOT Variables
	backKappa = 0.3030;
	scatKappa = 0.3300;

	backMua = 0.0100;
	scatMua = 0.1;
	
	kappa[Background] = backKappa;
	kappa[Scatterer] = scatKappa;

	mua[Background] = backMua;
	mua[Scatterer] = scatMua;
	
	//Dummy variable 
	C = 5;

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
	
	//Optical Sources
	{ Name Source_Set; Type Assign;
		Case {
			{ Region Sources; Value 10; }	
		}
	}
	
	//Initial Pressure (From DOT)	
	{ Name InitialData; 
		Case{ 
			{ Region AllOmega; Type InitFromResolution; NameOfResolution dotSolve; }
			//{ Region Scatterer; Type Init; Value 10; }	
		}
	}
	
}

/* ---------------------------------------
   Includes
   --------------------------------------- */
Include "InitJacobian.pro"       
Include "patSolve.pro"

/*=============
Post Operation
=============*/

PostOperation {
	
	{Name PrintData; NameOfPostProcessing CoupledProblem;
		Operation{
			Print[Fluence, OnElementsOf AllOmega, LastTimeStepOnly, File "fluence.pos"];
			Print[initPressure, OnElementsOf AllOmega, LastTimeStepOnly, File "initPressure.pos"];
			Print[Pressure, OnElementsOf AllOmega, File "pressure.pos"];
			Print[measPressure, OnElementsOf Bndry, 
				Format NodeTable, File "BndMeas.tdat"];
		}
	}
	
	/*
	{Name PrintFluence; NameOfPostProcessing SaveFluence;
		Operation{
			Print[Fluence, OnElementsOf AllOmega, File "fluence.pos"];	
		}
	}
	*/
}


