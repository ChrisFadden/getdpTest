/*====================
  Functional Spaces
====================*/

FunctionSpace { 
	
	//Fluence Function Space
	{ Name EfieldFuncSpace; Type Form1P; //E-field perp to 2D-plane
		BasisFunction {
			{ Name sn; NameOfCoef vn; Function BF_PerpendicularEdge;
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
	{ Name mwaveFormulation; Type FemEquation;
		Quantity { 
			{ Name E; Type Local; NameOfSpace EfieldFuncSpace; }	
		}
		Equation {
				
			Galerkin{[Dof{d E}, {d E}];
				In AllOmega; Jacobian JVol; Integration I1;}
			
			Galerkin{[(-I[]*omega*sigma[]*mu[])*Dof{E},{E} ];
				In AllOmega; Jacobian JVol; Integration I1;}

			Galerkin{ [ (omega*omega * eps[]*mu[])*Dof{E}, {E} ];
				In AllOmega; Jacobian JVol; Integration I1;}
			
		}
	}
}

/*======================
  Resolution
======================*/

Resolution {
	{	Name mwaveSolve;
		System { 
			{ Name mwave_sys; NameOfFormulation mwaveFormulation; 
					Type ComplexValue;}
		}
		Operation {
			Generate[mwave_sys]; Solve[mwave_sys]; SaveSolution[mwave_sys];
		}
	}
}

/*==============
Post Processing
==============*/

PostProcessing {
   { Name mwavePost; NameOfFormulation mwaveFormulation; //NameOfSystem mwave_sys;
      Quantity{
				{ Name Enorm; Value {Local {
					[Norm[{E}]]; In AllOmega; Jacobian JVol; }}}
				{ Name Efield; Value {Local { 
					[CompZ[{E}]]; In AllOmega; Jacobian JVol; }}}	
				{ Name DielLoss; Value {Local {
					[0.5*eps[]*Norm[{E}]*Norm[{E}]]; In AllOmega; Jacobian JVol; }}}
				{ Name CondLoss; Value {Local {
					[0.5*sigma[]*Norm[{E}]*Norm[{E}]]; In AllOmega; Jacobian JVol; }}}					
				{ Name MagLoss; Value {Local {
					[0.5*Norm[{E}]*Norm[{E}]*mu[] / Sqrt[omega^2*mu[]^2 / (sigma[]^2 + omega^2*eps[]^2)]   ]; In AllOmega; Jacobian JVol; }}}
			}
   }
}
