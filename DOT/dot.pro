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
	lambda = 800.; //nm	
	
	backMua = 0.01; //mm^-1
	backMus = 1; //mm^-1
	
	scatMua = 1; //mm^-1
	scatMus = 0.1; //mm^-1

	backKappa = 1. / (3*(backMua + backMus));
	scatKappa = 1. / (3*(scatMua + scatMus));
	
	backCC = 3e11; // mm per sec
	scatCC = 3e11; // mm per sec	

	kappa[Background] = backKappa;
	kappa[Scatterer] = scatKappa;

	mua[Background] = backMua;
	mua[Scatterer] = scatMua;
	
	cc[Background] = backCC;
	cc[Scatterer] = scatCC;

	imagWaveNum[AllOmega] = 0;//Complex[0.,2e6 * Pi / lambda];
}

/* ---------------------------------------
   Dirichlet constraints
   --------------------------------------- */
Constraint {
	{ Name Source_Set; Type Assign;
		Case {
			{ Region Sources; Value 50; }
			{ Region Bndry; Value 0; }
		}
	}
}

/* ---------------------------------------
   Includes
   --------------------------------------- */
Include "InitJacobian.pro"       
Include "dotSolve.pro"

/*=============
Post Operation
=============*/

PostOperation {
	{Name PrintData; NameOfPostProcessing dotPost;
		Operation{
			Print[muaCoeff, OnElementsOf AllOmega, File "mua.pos"];
			Print[kappaCoeff, OnElementsOf AllOmega, File "kappa.pos"];
			Print[Fluence, OnElementsOf AllOmega, File "fluence.pos"];
			Print[initPressure,OnElementsOf AllOmega, File "initPressure.pos"];	
		}
	}	
}

