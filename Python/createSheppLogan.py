

LastPoint = 67
LastEllipse = 56
LastSurface = 14

print("Point(" + str(LastPoint+1) + ") = {cx + CosTh*MajA,cy + SinTh*MajA,0,lc};")
print("Point(" + str(LastPoint+2) + ") = {cx - CosTh*MajA,cy - SinTh*MajA,0,lc};")
print("Point(" + str(LastPoint+3) + ") = {cx + SinTh*MajA,cy - CosTh*MinA,0,lc};")
print("Point(" + str(LastPoint+4) + ") = {cx - SinTh*MajA,cy + CosTh*MinA,0,lc};")
print("Point(" + str(LastPoint+5) + ") = {cx,cy,0,lc};")
print("")

print("Ellipse(" + str(LastEllipse+1) + ") = {" + str(LastPoint+2) + "," +
    str(LastPoint+5) + "," + str(LastPoint+1) + "," + str(LastPoint+3) + "};")
print("Ellipse(" + str(LastEllipse+2) + ") = {" + str(LastPoint+1) + "," +
    str(LastPoint+5) + "," + str(LastPoint+2) + "," + str(LastPoint+3) + "};")
print("Ellipse(" + str(LastEllipse+3) + ") = {" + str(LastPoint+1) + "," +
    str(LastPoint+5) + "," + str(LastPoint+2) + "," + str(LastPoint+4) + "};")
print("Ellipse(" + str(LastEllipse+4) + ") = {" + str(LastPoint+2) + "," +
    str(LastPoint+5) + "," + str(LastPoint+1) + "," + str(LastPoint+4) + "};")

print("Line Loop(" + str(LastSurface+1) + ") = {" + str(LastEllipse+2) + ",-"
    + str(LastEllipse+1) + "," + str(LastEllipse+4) + ",-" + str(LastEllipse+3) + "};")
print("Surface(" + str(LastSurface+1) + ") = {" + str(LastSurface+1) + "};")
