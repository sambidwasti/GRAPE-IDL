pro gsim_grp_l1_combine_pol,fsearch_str, bsize=bsize

; This is designed to commbine the output from gsim_grp_l1_pol_rot. 
; This combines the polarized histogram file from mainly gsim_grp_l1_pol_rot. 
; Any other version of this pol should also work
; 
; bin = bin => the input is 1 bin size, this will rebin the file in desired rebin values. 
;
If keyword_set(bsize) NE 1 Then bsize=20
gSimFile = FILE_SEARCH(fsearch_str)          ; get list of EVT input files
nfiles =n_elements(gsimFile)                      ; no. of files
CD, Cur = Cur

Main_Count = dblarr(360)
Main_err_2   = Dblarr(360)
for p = 0, nfiles-1 do begin
  infile = gsimfile[p]
  ReadCol, infile, ang,count, err
  
  Main_Count = Main_Count+count
  Main_Err_2 = Main_Err_2 + (err*err)
  
endfor
Main_err = Sqrt(Main_Err_2)
window,0
CgPlot, ang,Main_Count, xrange=[0,360], psym=10

; -- Rebinning --
Nbins = 360/bsize
Temp_Hist = FltArr(NBins)
Temp_Err_Hist = FltArr(NBins)
Angle =Indgen(Nbins) * bsize
Temp_Count =0L

For i = 0,NBins-1 Do Begin
  Temp_Val =0.0
  Temp_Err_Val =0.0
  
  For j=0, Bsize-1 Do Begin
    
    Temp_Val = Main_Count[Temp_Count]+Temp_Val
    Temp_Err_Val = (Main_err_2[Temp_Count]) + Temp_Err_Val
    Temp_Count++
    
  EndFor;j
  
  Temp_Hist[i]=Temp_Val
  Temp_Err_Hist[i]= Sqrt(Temp_Err_Val)
EndFor ; i
Main_Hist = Temp_Hist
Main_Hist_Err  = Temp_Err_Hist

print, min(Main_HIst), Max(Main_Hist)
ymin = bsize*65
ymax = bsize*90
window,2
CgPlot, Angle, Main_Hist, xrange=[0,360], psym=10, Yrange=[ymin,ymax],ystyle=1


end