/*====================
  Functional Spaces
====================*/

FunctionSpace { 
	
	//Fluence Function Space
	{ Name phiFuncSpace; Type Form0; 
		BasisFunction {
			{ Name sn; NameOfCoef vn; Function BF_Node;
				Support AllOmega; Entity NodesOf[ All ]; }
		}

		//Constraint for the Source
		Constraint {
			{ NameOfCoef vn; EntityType NodesOf; NameOfConstraint Source_Set; }
		}	
	}
}


/*======================
  Weak formulations
======================*/

Formulation {
	{ Name dotFormulation; Type FemEquation;
		Quantity { 
			{ Name phi; Type Local; NameOfSpace phiFuncSpace; }	
		}
		Equation {

			Integral{[ (mua[] + imagWaveNum[])*Dof{phi}, {phi}];
				In AllOmega; Jacobian JVol; Integration I1;}
	
			Integral{ [ (kappa[])*Dof{d phi}, {d phi} ];
				In AllOmega; Jacobian JVol; Integration I1;}
		}
	}
}

/*======================
  Resolution
======================*/

Resolution {
	{	Name dotSolve;
		System { 
			//{ Name dot_sys; NameOfFormulation dotFormulation; Type Complex;}
			{ Name dot_sys; NameOfFormulation dotFormulation;}
		}
		Operation {
			Generate[dot_sys]; Solve[dot_sys]; 
		}
	}
}

/*==============
Post Processing
==============*/

PostProcessing {
   { Name dotPost; NameOfFormulation dotFormulation; NameOfSystem dot_sys;
      Quantity{
				{ Name Fluence; Value {Local { 
					[{phi}]; In AllOmega; Jacobian JVol; }}}
				
				{ Name initPressure; Value {Local { 
					[mua[] * {phi}]; In AllOmega; Jacobian JVol; }}}
				
				{	Name kappaCoeff; Value {Local {
					[kappa[]]; In AllOmega; Jacobian JVol; }}}
				{ Name muaCoeff; Value {Local {
					[mua[]]; In AllOmega; Jacobian JVol; }}}
			}
   }
}
