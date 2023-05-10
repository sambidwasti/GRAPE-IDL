pro solving_issues4

;
; 
EnerArr = Fix(RandomU(1,30)*30)
; A random array
E_bin_lo = [6,9,12,16,20]
E_bin_hi  = [9,12,16,20,30]

Print, EnerArr[6:9]



nbins = n_elements(E_bin_lo)

;xval2 = indgen(nbins)*bin
;xval3 = indgen(nbins)*bin+bin

Cntr = 0L
Flight2 = DblArr(nbins)
Flight2_Err = DblArr(nbins)

for i = 0, nbins-1 do begin
  tempFli   = 0.0
  
  Elo = E_bin_lo[i]
  Ehi = E_bin_hi[i]
  
  For j = Elo, Ehi-1 do begin
     Print, j, '**', ENERARR[J]
     TempFli = TempFli + EnerArr[j]
     
  Endfor
  Print
  Print, TempFli, '**'
  Flight2[i] = TempFli
  
 Endfor
 Print, Flight2
 
;  tempFli_err   = 0.0
;  for j = 0, bin-1 do begin

;    tempFli   = tempfli   + EnerArr[cntr]
;    tempFli_err   = tempFli_err   + EnerErr[cntr]*EnerErr[cntr]
;    cntr++
;  endfor
;
;  Flight2[i] = tempFli
;  Flight2_Err[i] = Sqrt(tempFli_Err)



end