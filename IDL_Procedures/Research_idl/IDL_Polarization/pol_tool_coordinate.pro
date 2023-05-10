Function Pol_Tool_Coordinate, Anode
; Takes in Angle and Returns Coordinate
; Define Origin at intersection of 27,28,35,36 so 0,0 there
; It is a Square Boxes so equal width and length of each boxes.

    U = 1 ; Unit for each distance.
    Cord = FltArr(2) ; X,Y Coordinate
    
    Temp_X = Anode mod 8
    Temp_X = Temp_X-3.5
    X = -1*(Temp_X * U)   
    Cord[0] = X
    
    Temp_Y = Anode/8
    Temp_Y = (Temp_Y-3.5)
    Y = Temp_Y * U
    Cord[1] = Y
    
    Return, Cord

End 