pro solving_Issues6,infile
;  print,'infile:', infile
;  h=''
;  im = Readfits(infile,h,/noscale)
;  print
;  print, 'im = Readfits(infile,h,/noscale)'
;  print,'h(header): ', h
;  print
;  print
;  print, 'im:'
;  print, im
;  print
;  print
;  print, '=================='
;  htab = ''
;  tab = READFITS(infile,htab,/EXTEN)
;  print, 'tab = Readfits(infile,htab,/EXTEN)'
;  print
;  print,'htab:',htab
;  print
;  print,'tab:', tab
A = Indgen(10)
print, A

B = (where(A GT 10, count))
print, count
print, B

;This does not work
c = [5,7,8]
D = (where(A EQ C, count))
print, count
Print, D
print, 'not working'

Bgd = A

arrloc = [0]
for i = 0, n_elements(C)-1 do begin
    D = where(A EQ C[i], count)
    help, bgd_arr
    
    BGD_arr = [where(Bgd NE C[i])]
    Bgd = Bgd[bgd_arr]
    print, strn(d)+ 'd'+ strn(c[i])+ 'c'
    print
    arrloc = [arrloc,D]
    print, arrloc
endfor
print, C ,'C'
print, arrloc
arrloc=arrloc[1:n_elements(arrloc)-1]
print, arrloc, 'arrloc'
E =  A[arrloc]
print,E, 'E'
print, Bgd, 'bgd'

stop
; val = [253, 242 ]
;print,  b2d_int2dec(val)


 val = [63 ,128, 0 ,0 ]

b = StrArr(4)
 for i = 0, n_elements(val)-1 Do begin
  b[i]= val[i].ToBinary(  WIDTH=8)
 endfor
c = b[0]+b[1]+b[2]+b[3]

print, c
print,strlen(c)
flt_s = strmid(c,0,1)
print, flt_s
flt_exp = Strmid(c,1,8)
print, flt_exp
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
    Print, Act_Exp

flt_man = StrMid(C,9,23)
print, flt_man
; Mantissa
temp =0.0D
for i = 0,22 do begin
    byt_int = double(Strn(strmid(flt_man,i,1) ))
    byt_val = byt_int* 2.0D^(-1*(i+1))
 ;   print, i, byt_int, byt_val
    temp = temp + byt_val
endfor
act_mantissa = 1.0D +temp

Print, 'Man:', act_mantissa
print, 'Exp:', Act_Exp
;print, (-1)^0, (-1)^1

Number = (-1)^Double(flt_s) * Double(act_mantissa) * 2.0D^(Double(act_Exp))
print, Number
;flt_man = c[ 

print, b2d_float2dec(val)
End