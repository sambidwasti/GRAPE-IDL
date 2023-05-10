Function Check_PPC, Anode1, Anode2, ANode3

; Just a random function to check PPC event type. 
P =0
C = 0

Anode = [Anode1, Anode2, Anode3]

For i = 0, 2 Do BEgin
    IF AnodeType(Anode[i]) EQ 0 Then C++ Else If AnodeType(Anode[i]) EQ 1 Then P++ Else stop
Endfor

If (P EQ 2) and (C EQ 1) Then  Return, 1 Else Return, 0
End