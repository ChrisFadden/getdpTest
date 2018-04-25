// Group
//======
Group{ Omega = Region[{1}]; Gama = Region[{2}];
}

// Function
//=========
Function{
C = 5; //constant C in the problem solved by u
//testRead[] = Field[XYZ[]];

}

//Jacobian
//========
Jacobian {
  { Name JVol ;
    Case {
      { Region All ; Jacobian Vol ; }
    }
  }
  { Name JSur ;
    Case {
      { Region All ; Jacobian Sur ; }
    }
  }
  { Name JLin ;
    Case {
      { Region All ; Jacobian Lin ; }
    }
  }
}

//Integration (parameters)
//=======================
Integration {
  { Name I1 ;
    Case {
      { Type Gauss ;
        Case {
          { GeoElement Point ; NumberOfPoints  1 ; }
          { GeoElement Line ; NumberOfPoints  4 ; }
          { GeoElement Triangle ; NumberOfPoints  6 ; }
          { GeoElement Quadrangle ; NumberOfPoints 7 ; }
          { GeoElement Tetrahedron ; NumberOfPoints 15 ; }
          { GeoElement Hexahedron ; NumberOfPoints 34 ; }
        }
      }
    }
  }
}

// Dirichlet Constraint
Constraint{
    {Name DirichletV;
    Case{
        {Region Gama; Type AssignFromResolution; NameOfResolution AuxiliaryResolution; }
    }
    }
}
/*
The constraint will be obtained through the resolution of "AuxiliaryResolution".
This means that GetDP will automatically solve "AuxiliaryResolution" when it will
need the contraint !
*/

//FunctionSpace
//=============
FunctionSpace{
//Space for u AND v !!
	{ Name Hgrad; Type Form0;
    BasisFunction{
      {Name wn; NameOfCoef vn; Function BF_Node;
    Support Region[{Omega, Gama}]; Entity NodesOf[All];}
    }
    //the dirichlet constraint "v = u" on Gamma
    Constraint{
    {NameOfCoef vn; EntityType NodesOf;
     NameOfConstraint DirichletV;}
     }
    }
}
/*
ONLY one function space that will contain "u" and at the end, "v".
*/


//(Weak) Formulations
//==================

Formulation{
// Problem solved by u :
// Delta u + u = C (Omega)
// dn u = 0 (Gamma)
  {Name ProblemU; Type FemEquation;
    Quantity{
      {Name u; Type Local; NameOfSpace Hgrad;}
    }
		
		Equation{
			Galerkin{ [Dof{u},{u} ];
				In Omega; Jacobian JVol; Integration I1;}
		
			Galerkin{ [ -Field[XYZ[]], {u} ];
				In Omega; Jacobian JVol; Integration I1;}	
		}
  }

// Coupled problem : "first kind" : 
// DIRICHLET condition on Gamma 
// Delta v + v =0 Omega
// v = u on Gamma
  {Name ProblemV; Type FemEquation;
    Quantity{
    // v is the unknown
      {Name v; Type Local; NameOfSpace Hgrad;}
    }
    Equation{
      Galerkin{ [Dof{Grad v}, {Grad v}];
        In Omega; Jacobian JVol; Integration I1;}

      Galerkin{ [Dof{v}, {v}];
        In Omega; Jacobian JVol; Integration I1;}
    }
  }
  
  
}

// Resolution
//===========

Resolution{
//Main Resolution : the one that will be called when launching getdp
  {Name MainResolution;
    System{
      {Name PbV; NameOfFormulation ProblemV;}
    }
    Operation{
      Generate[PbV]; Solve[PbV]; SaveSolution[PbV];
    }
  }
/*Short explanations : GetDP will :
generate and solve the problem associated to "v" and save "v" in the space H1
However, to compute "v", GetDP need to compute the Dirichlet Contraint, thus
is needs to solve AuxiliaryResolution (bellow) !
*/

// Auxiliary resolution that computes "u"
  {Name AuxiliaryResolution;
    System{
    //System associated to "u" will be transfered to the weak formulation of "v"
      {Name PbU; NameOfFormulation ProblemU; DestinationSystem PbV;}
      {Name PbV; NameOfFormulation ProblemV;}
    }
    Operation{
      GmshRead["sol_u.pos"]; Generate[PbU]; Solve[PbU]; TransferSolution[PbU];
    }
  }
/*Short explanations : GetDP will :
1) generate and solve the problem associated to "u"
2) Transfert solution u (to problem associated to "v")
*/
}


//Post Processing
//===============

PostProcessing{
  {Name CoupledProblem; NameOfFormulation ProblemV;
    Quantity{
      {Name v; Value {Local{[{v}];In Omega; Jacobian JVol;}}}
    }
  }
}

//Post Operation
//==============

PostOperation{
  {Name Map_v; NameOfPostProcessing CoupledProblem;
    Operation{
      Print[v, OnElementsOf Omega, File "sol_v.pos"];
    }
  }
}
