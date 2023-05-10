Pro Grp_l2v7_com_fltHist1, fsearch_Str, Title=Title
; Combine FltHist1 files together which are per sweep file.

InFile = FILE_SEARCH(fsearch_str)          ; get list of EVT input files
if keyword_set(nfiles) ne 1 then nfiles = n_elements(infile)

if Keyword_Set(title) Eq 0 Then Title='Test'

ReadCol, Infile[0], LoEnergy, HiEnergy, Counts, Error
Counts = FltArr(N_Elements(Counts))
Error = FltArr(N_Elements(Error))

;= = = = Combining = = = =
For p=0, nfiles-1 do begin
    file = infile[p]
    print, file
    ReadCol, file, LoEner, HiEner, Cnts, Errs
    
    Counts = Counts + Cnts
    Error  = Error  + Errs*Errs
  
Endfor
Counts = Counts/nfiles
Error= Sqrt(Error)/nfiles
;= = = =  * * * *  = = = =

Cd, Cur = Cur
Outfile = Cur+'/'+Title+'.txt'
print, outfile

Openw, lun101, Outfile, /Get_lun
  for i =0, n_elements(LoENergy)-1 Do Begin
      Printf, lun101, LoEnergy[i], HiEnergy[i], Counts[i], Error[i]
  EndFor
Free_lun, lun101

End