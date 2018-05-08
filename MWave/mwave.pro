
//TRY MODELS: WAVEGUIDE

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

DefineConstant[
	FREQ = 1000,
	mu0 = (4e-10)*Pi, // H/mm
	cc = 299792458000., // mm/s
	eps0 = 1. / (cc*cc*mu0), //F/mm
	sigma0 = 1e-3, //1000, // S / mm 
	MHz = 1e6
];


Function {
	//EVERYTHING MUST BE IN mm (MILLIMETERS) NOT METERS
		
	omega = FREQ * 2*Pi*MHz;  //1 GHz
	I[] = Complex[0.,1.];	
	
	mu[Background] = 1*mu0;			//Water
	eps[Background] = 80*eps0;
	sigma[Background] = sigma0;	

	mu[scatter] = 4*mu0;		
	eps[scatter] = 120*eps0; 
	sigma[scatter] = 100*sigma0;
}

/* ---------------------------------------
   Dirichlet constraints
   --------------------------------------- */
Constraint {
	{ Name Source_Set; Type Assign;
		Case {
			{ Region Sources; Value 1; }
			//{ Region Bndry; Value 0; }
		}
	}
}

/* ---------------------------------------
   Includes
   --------------------------------------- */
Include "InitJacobian.pro"       
Include "mwaveSolve.pro"

/*=============
Post Operation
=============*/

PostOperation {
	{Name PrintData; NameOfPostProcessing mwavePost;
		Operation{
			Print[Efield, OnElementsOf AllOmega, File "efield.pos"];
			Print[Enorm, OnElementsOf AllOmega, File "enorm.pos"];
			Print[DielLoss, OnElementsOf AllOmega, File "Pdiel.pos"];
			Print[CondLoss, OnElementsOf AllOmega, File "Pcond.pos"];
			Print[MagLoss, OnElementsOf AllOmega, File "Pmag.pos"];
		}
	}	
}

