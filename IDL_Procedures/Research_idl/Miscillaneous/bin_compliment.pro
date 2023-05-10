function bin_compliment, BitArray
;
;Takes in a Its not exactly binary array but a string of binary values.
;Returns a compliment.. that is 1 to 0 and 0 to 1
;
Str_Length = StrLen(BitArray)

Comp_Array = StrArr(Str_length)

For i = 0,Str_Length-1 Do Begin
  CurStr = StrMid(BitArray,i,1) 
  
  If curStr eq '0' Then Comp_Array[i]='1' Else if CurStr eq '1' then Comp_array[i] = '0'
Endfor

Comp_BitArray = ''

For i = 0,Str_Length-1 Do Comp_BitArray = Comp_BitArray+Comp_array[i]
Return, Comp_BitArray
End