function b2d_int2dec, array
  ; simple binary 2 decimal procedure
  ; takes in an array of 4 size where each size is a byte.

  if n_elements(array) NE 2 then begin
    Print, ' Array has to be length 2 and integer '
    STOP
  endif

  val = array

  b = StrArr(2)

  for i = 0, n_elements(val)-1 Do begin
    b[i]= val[i].ToBinary(  WIDTH=8)
  endfor

  c = b[0]+b[1]
  print, c, '**'
  val_s = fix(strmid(c,0,1))
  val_rest = Strmid(c,1,15)
;  print, strlen( val_rest)
  print, Val_Rest
  Int_S = (-1)^(fix(Val_S))
  
  If Int_S eq 1 Then BEgin
      dec_Val = 0
      for i = 1,15 do begin
         cur_byte =Fix(Strn(strmid(val_rest,i-1,1) ))
      ;   print, strn(i)+'^^'+ cur_byte +'^^^'+Strn(15-i)
         dec_Val = dec_Val + cur_byte*2^(15-i)
      endfor
  Endif Else If Int_S eq -1 then begin
      val_Rest_comp = bin_Compliment(val_rest)
      dec_val = 0
      for i = 1,15 do begin
        cur_byte =Fix(Strn(strmid(val_rest_Comp,i-1,1) ))
        ;   print, strn(i)+'^^'+ cur_byte +'^^^'+Strn(15-i)
        dec_Val = dec_Val + cur_byte*2^(15-i)
      endfor
      dec_val= dec_val+1
  Endif
  
  Number= dec_Val*Int_S
  return, Number


End