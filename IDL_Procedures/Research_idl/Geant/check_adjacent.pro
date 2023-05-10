pro Check_Adjacent
  for p = 0,63 do begin
    print, p
    temp_ar = Grp_Find_Adjacent_1(p)
    Len = N_Elements(temp_ar)/2
    Adj_anodes = temp_ar[0:Len-1]
    Adj_types  = temp_ar[len:N_elements(Temp_ar)-1]
    b = Adj_Anodes

    loadct, 13
    Z = IntARR(8,8)
    ; z[*,*] = INDGEN(8,8)*255/63



    ctr =0
    for i=0,7 do begin
      for j =0,7 do begin

        for k = 0,len-1 do if ctr Eq B[k] Then Z[j,i]=Adj_Types[k]

        if ctr eq P then Z[j,i] = 1
        ctr++
      endfor
    endfor
    Z_Scl = Z*255/8
    Z_New = CONGRID(Z_Scl, 1024,1024)



    Cgimage, Z_new

    Xs = !D.X_Size/8
    Ys = !D.Y_Size/8
    zcount = 1L

    For i = 0, 7 Do Begin ; Printing the Anode Number on the plot to identify the anode
      For j = 0, 7 Do Begin
        ;If Zcount EQ Panode Then
        CgText, (Xs/3)+Xs*(j), (Ys/2)+ Ys*(i), charsize = 2, Strn(zcount), /DEVICE , Charthick = 2, Color='White'
        zcount++;
      Endfor
    EndFor
    Cursor, X_Value, Y_Value, /DOWN, /DEVICE

  EndFor ;P
end