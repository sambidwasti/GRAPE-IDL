Pro SOlving_ISsues204

;a = 0.0021321421543523452345
;print, a, format='(D5.2)'
;print, a, format='(E13.7)'
;5.8065601E-02
;2.1321422E-03

;Deal with Matrix. 
; Rebinning for non -square matrices
; normalizing and printing.

A = INDGEN(4,6)

B = fltArr(2,3)
help, a
print, a

n_ele_x = 2
n_ele_y =3

; n_ele_X = n_elements(Elo_E) Input energy which is each row or each detected.
i=0
print, 'a[i,*]'
help, a[i,*]
Print, a[i,*]
print
print, 'a[*,i]
help, a[*,i]
print, a[*,i]


help, n_ele_X
help, n_ele_y

Elo_D = [0,2]
EHi_D = [2,4]

Elo_E = [0,2,4]
EHi_E = [2,4,6]


A_x = FltArr(2,6)
For i = 0, N_ele_x-1 do begin

  lowj = Fix(Elo_D[i])        ; arr loc
  hij  = Fix(Ehi_D[i])      ; arr loc

  tempval = fltarr(1,6)
  for j = lowj, hij-1 do begin

    tempval = tempval + A[j,*]

  endfor

  A_x[i,*] = tempval

Endfor
Print, A
Print, A_x

; Now rebinning in Y
For i = 0, N_ele_y-1 do begin

  lowj = Fix(Elo_E[i])        ; arr loc
  hij  = Fix(Ehi_E[i])      ; arr loc

  tempval1 = fltarr(3)
  for j = lowj, hij-1 do begin

    tempval1 = tempval1 + A_x[*,j]

  endfor

  B[*,i] = tempval1

Endfor
print

Print, B
End