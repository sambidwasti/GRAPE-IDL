function b2d_flt2dec, array
  ; simple binary 2 decimal procedure
  ; takes in an array of 4 size where each size is a byte.

  if n_elements(array) NE 4 then begin
    Print, ' Array has to be length 4 and integer '
    STOP
  endif

  val = array

  b = StrArr(4)

  for i = 0, n_elements(val)-1 Do begin
    b[i]= val[i].ToBinary(  WIDTH=8)
  endfor

  c = b[0]+b[1]+b[2]+b[3]

  flt_s = strmid(c,0,1)
  flt_exp = Strmid(c,1,8)
  ; Exponent

  e_0 = fix(Strn(strmid(flt_exp,0,1) )* 2^7)
  e_1 = fix(Strn(strmid(flt_exp,1,1) )* 2^6)
  e_2 = fix(Strn(strmid(flt_exp,2,1) )* 2^5)
  e_3 = fix(Strn(strmid(flt_exp,3,1) )* 2^4)
  e_4 = fix(Strn(strmid(flt_exp,4,1) )* 2^3)
  e_5 = fix(Strn(strmid(flt_exp,5,1) )* 2^2)
  e_6 = fix(Strn(strmid(flt_exp,6,1) )* 2^1)
  e_7 = fix(Strn(strmid(flt_exp,7,1) )* 2^0)

  Tot_Exp = e_0+e_1+e_2+e_3+e_4+e_5+e_6+e_7
  Act_exp = Tot_Exp-127

  flt_man = StrMid(C,9,23)

  ; Mantissa
  temp =0.0D
  for i = 0,22 do begin
    byt_int = float(Strn(strmid(flt_man,i,1) ))
    byt_val = byt_int* 2.0D^(-1*(i+1))
    ;   print, i, byt_int, byt_val
    temp = temp + byt_val
  endfor
  act_mantissa = 1.0D +temp

  ; Print, 'Man:', act_mantissa
  ; print, 'Exp:', Act_Exp

  Number = (-1)^FLoat(flt_s) * float(act_mantissa) * 2.0^(float(act_Exp))
  return, Number


End