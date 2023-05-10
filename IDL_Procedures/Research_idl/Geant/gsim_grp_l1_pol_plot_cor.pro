Pro Gsim_Grp_l1_pol_plot_cor, Pol_File, UnPol_File, Bsize=Bsize, title=title
  ;
  ;This is to combine, Scale and plot the polarization simulation .
  ;Those output are from gsim_grp_l1_pol
  ;They are in 360 bins of 1 angle each.
  ;They  are not scaled yet
  ;
  
  If keyword_set(bsize) NE 1 Then bsize=30
  If keyword_set(title) NE 1 Then title = 'Cor Pol' else title = ' Cor Pol '+Title
  ReadCol, Pol_File, Pol_ang,Pol_Count, Pol_err
 
  ReadCol, UnPol_File, UnPol_Ang, UnPol_Count, UnPol_Err
 
 
 
 
;window,0
;CgPlot, Pol_Ang, Pol_Count, psym=10
;;Print, Total(Pol_Count)
;window,2
;CgPlot, UnPol_Ang, UnPol_Count, color='red', psym=10
;Print, Total(UnPol_Count)

Cor = DblArr(N_elements(Pol_Count))
For i = 0, n_elements(UnPol_Count)-1 do if UnPol_Count[i] eq 0 then Cor[i]=0 Else Cor[i]=Pol_Count[i]/UnPol_Count[i]
;window,0
;CgPlot, Pol_Ang, cor, color='blue', psym=10


  ; -- Rebinning --
Nbins = 360/bsize
Temp_Hist = FltArr(NBins)
Temp_Hist1= FltArr(NBins)
Temp_Err_Hist = FltArr(NBins)
Temp_Err_Hist1 = FltArr(NBins)

Angle =Indgen(Nbins) * bsize
Temp_Count =0L

For i = 0,NBins-1 Do Begin
  Temp_Val =0.0
  Temp_Err_Val =0.0
  
  Temp_Val1 = 0.0
  Temp_Err_Val1 =0.0

  For j=0, Bsize-1 Do Begin

    Temp_Val = Pol_Count[Temp_Count]+Temp_Val
    Temp_Val1 = UnPol_Count[Temp_Count]+Temp_Val1
  
    Temp_Err_Val = (Pol_Err[Temp_Count]*Pol_Err[Temp_Count]) + Temp_Err_Val
    Temp_Err_Val1 = (UnPol_Err[Temp_Count]*UnPol_Err[Temp_Count]) + Temp_Err_Val1

    
    Temp_Count++

  EndFor;j

  Temp_Hist[i]=Temp_Val
  Temp_Hist1[i]=Temp_Val1
  
  Temp_Err_Hist[i]= Sqrt(Temp_Err_Val)
  Temp_Err_Hist1[i]= Sqrt(Temp_Err_Val1)
EndFor ; i
Pol_Hist = Temp_Hist
UnPol_Hist = Temp_Hist1

Pol_Hist_err = Temp_Err_Hist
UnPol_Hist_err = Temp_Err_Hist1

;Window,0
;CgPlot, Angle, Pol_Hist, Psym=10
print, Pol_Hist_Err
;-- Scaling/Normalization based on total counts in the histogram. 
Norm_Factor = Total(Pol_Hist)/Total(UnPOl_Hist)
UnPOl_Hist_Norm = UnPol_Hist*Norm_Factor

UnPol_Hist_err_Norm = UnPol_Hist_err*Norm_Factor

Cor_Pol_Hist = DblArr(N_elements(Pol_Hist))
Cor_Pol_Hist_Err = DblArr(N_elements(Pol_Hist_err))

For i = 0, n_elements(UnPOl_Hist_Norm)-1 do if UnPOl_Hist_Norm[i] eq 0 then Cor_Pol_Hist[i]=0 Else begin
  Cor_Pol_Hist[i]=Pol_Hist[i]/UnPOl_Hist_Norm[i]
  
  ; Error Propagation
   Cor_Pol_Hist_err[i] =Cor_Pol_Hist[i] * Sqrt(  (Pol_Hist_err[i]/Pol_Hist[i])^2 +  (UnPOl_Hist_Err_Norm[i]/UnPOl_Hist_Norm[i])^2  ) 
  
EndElse



Scl_Factor = Total(Pol_Hist)/Total(Cor_Pol_Hist)
Main_Pol_Hist = Scl_Factor * Cor_Pol_Hist
Main_POl_Hist_err = Scl_factor * Cor_Pol_Hist_Err
;
;-- This conversion makes so that the total count = no. bins
;The total coutns is used to balance this. 



window,1
CgPlot, Angle, Main_Pol_Hist, Psym=10, title=title, Err_Ylow=Main_Pol_Hist_err, Err_YHigh=Main_Pol_Hist_err, XStyle=1, Xrange=[0,360]

Openw, Lun, 'Pol_Plot_Cor.txt', /Get_lun
for i = 0, n_elements(Main_Pol_Hist)-1 do begin
  
  printf, lun, Angle[i], Main_Pol_Hist[i], Main_POl_Hist_err[i] ; This is error which needs to be translated accordingly
  
endfor

Free_lun, lun

End