Group {
  Air = Region[1];
  Diel1 = Region[2];
	Sources = Region[333];
	Sinks = Region[555];
	Bndry = Region[786];
	Vol_Ele = Region[ {Air, Diel1, Sources,Sinks,Bndry} ];
}

Function {
  eps0 = 8.854187818e-12;
  epsilon[Air] = 1. * eps0;
  epsilon[Diel1] = 10 * eps0;
	epsilon[Sources] = 1. * eps0;
	epsilon[Sinks] = 1. * eps0;
	epsilon[Bndry] = 1. * eps0;
}

Constraint {
  { Name Dirichlet_Ele; Type Assign;
    Case {
      { Region Sources; Value 1; }
			//{ Region Bndry; Value 0; }
			//{ Region Diel1; Value 1; }
    }
  }
}

Group{
  Dom_Hgrad_v_Ele =  Region[ {Vol_Ele} ];
}

FunctionSpace {
  { Name Hgrad_v_Ele; Type Form0;
    BasisFunction {
      { Name sn; NameOfCoef vn; Function BF_Node;
        Support Dom_Hgrad_v_Ele; Entity NodesOf[ All ]; }
      // using "NodesOf[All]" instead of "NodesOf[Dom_Hgrad_v_Ele]" is an
      // optimization, which allows GetDP to not explicitly build the list of
      // all the nodes
    }
    Constraint {
      { NameOfCoef vn; EntityType NodesOf; NameOfConstraint Dirichlet_Ele; }
    }
  }
}

Jacobian {
  { Name Vol ;
    Case {
      { Region All ; Jacobian Vol ; }
    }
  } 
}

Integration {
  /* A Gauss quadrature rule with 4 points is used for all integrations below. */
  { Name Int ;
    Case { { Type Gauss ;
             Case { { GeoElement Line        ; NumberOfPoints  4 ; }
                    { GeoElement Triangle    ; NumberOfPoints  4 ; }
                    { GeoElement Quadrangle  ; NumberOfPoints  4 ; } }
      }
    }
  }
}

Formulation {
	{ Name Electrostatics_v; Type FemEquation;
    Quantity {
      { Name v; Type Local; NameOfSpace Hgrad_v_Ele; }
    }
    Equation {
      Integral { [ epsilon[] * Dof{d v} , {d v} ];
	    In Vol_Ele; Jacobian Vol; Integration Int; }
    }
  }
}


Resolution {
  { Name EleSta_v;
    System {
      { Name Sys_Ele; NameOfFormulation Electrostatics_v; }
    }
    Operation {
      Generate[Sys_Ele]; Solve[Sys_Ele]; SaveSolution[Sys_Ele];
    }
  }
}

PostProcessing {
  { Name EleSta_v; NameOfFormulation Electrostatics_v;
    Quantity {
      { Name v; Value {
          Term { [ {v} ]; In Dom_Hgrad_v_Ele; Jacobian Vol; }
        }
      }
      { Name e; Value {
          Term { [ -{d v} ]; In Dom_Hgrad_v_Ele; Jacobian Vol; }
        }
      }
      { Name d; Value {
          Term { [ -epsilon[] * {d v} ]; In Dom_Hgrad_v_Ele; Jacobian Vol; }
        }
      }
    }
  }
}

PostOperation {
  { Name Map; NameOfPostProcessing EleSta_v;
     Operation {
       Print [ v, OnElementsOf Vol_Ele, Format NodeTable, File "Vnode.dat"];
			 Print [ v, OnElementsOf Vol_Ele, File "Vcut.pos"];
     }
  } 
}
