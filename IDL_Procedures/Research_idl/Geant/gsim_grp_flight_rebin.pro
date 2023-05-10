Pro Gsim_Grp_Flight_Rebin, infile, bin = bin
; Procedure to rebin flight file for comparing with Geant.
; Currenlty using the Investigate3 file from L2 Flight.. 
; This was done as a partial job of the compare_gamma2

;Currently looking for the Inv3 and replacign that in the filename
If keyword_set(bin) eq 0 then bin = 10 ; Binsize
Pos1 = StrPos(infile,'Inv3.txt',0)
title1 = StrMid(Infile,0,Pos1)+'inv3_rebin.txt'

; Read in the flight --
ReadCol, infile, Flight1, Flight1_err, format='F,F'

;
; Rebinning here:
nbins = (1000/bin)
xval2 = indgen(nbins)*bin
xval1 = xval2

;
;-- FLight
;
Flight2 = DblArr(nbins)
Flight2_Err = DblArr(nbins)

Cntr=0L

for i = 0, nbins-1 do begin
  tempFli   = 0.0

  tempFli_err   = 0.0
  for j = 0, bin-1 do begin

    tempFli   = tempfli   + Flight1[cntr]
    tempFli_err   = tempFli_err   + Flight1_Err[cntr]*Flight1_Err[cntr]
    cntr++
  endfor

  Flight2[i] = tempFli
  Flight2_Err[i] = Sqrt(tempFli_Err)

endfor ; i


;
;=== Per bin scaling ===
;
Flight2 = Flight2/bin
Flight2_Err = Flight2_err/bin

print, n_elements(Flight2)
;
;-- JUst print out hte rebinned Flight2.
;
Openw, Lun555, title1,/Get_Lun
for i = 0, n_elements(Flight2)-1 do begin
  printf, lun555, Strn(Flight2[i]), ' ', Strn(Flight2_Err[i])
endfor
free_lun,lun555
stop


End