Pro gsim_grp_compare_gamma2, file1, file2, title=title, bin=bin, PSD=PSD, sel=sel

  ; This is built on gsim_gp_compare_gamma1 
  ;     which was only for Gammas. 
  ;     this adds in the analysis of secondary electrons aswell
  ;     
  ;     
  ;== Read in the flight file 1
  ;   read in the FOLDER or files (right now its a folder)
  ;   Since theya are gamma files so they end with
  ;   l1_gamma_com.txt
  ;
  ;   April 27, 2017
  ;   entering an option for filename and color.
  ;
  ;   May 3, 2017
  ;   Modifying to be able to work for 2~5 files.
  ;   Added a PSD Flag for the psd print out.
  ;
  ;   May 8, 2017
  ;   Adding a Variance/ Chi-squared value to the data.

  True =1
  False = 0
  If Keyword_Set(PSD) EQ 0 Then PSD_Flag = False Else PSD_Flag= True
  If keyword_set(title) ne 1 then title='Try'
  ;
  ;==== PLOT Variables
  ;
  PTitle = ' PC Flight vs Simulation '+Title
  Xtitle = ' Energy (keV) '
  Ytitle = ' C/s/keV '

  ;Range
  Xmin  = 80
  Xmax  = 300
  ;       ymin = 1E-7
  Ymin  = 0.01
  Ymax  = 0.1
  ;--- Current Directory
  CD, Cur = Cur

  if keyword_set(bin) ne 1 then bin = 10

  if keyword_set(sel) eq 1 then Sel_Flag =1 else Sel_Flag=False
  If Sel_Flag EQ True THen Title=Title+'_Sel'
  Sel_energy_min = 100
  sel_energy_max = 220
  sel_energy_text = 'Fit Energy Range = '+strn(Sel_energy_min)+'keV ~'+Strn(sel_energy_max)+'keV'
  Sel_min = fix(sel_energy_min/bin)
  Sel_max = fix(sel_energy_max/bin)


  ; Read in the flight --
  ReadCol, file1, Flight1, Flight1_err, format='F,F'


  ;
  ;-- Read in the sims --
  ;
  simfile = file_search(file2+'/*.txt')
  nfiles  = n_elements(simfile)
  Print, nfiles,'&&'
  Legend_Array = ['Flight']
  Color_Array = ['Black','Red','Blue','Green','Purple','Orange']
  Color_Array11= ['Black','Blue','Red','Green','Purple','Orange','Grey']

  Legend_Array1=['Red-Chisqr']
  Legend_Array2=['Chisqr']
  Legend_Array11=['Flight','Tot Gamma']
  ;,'Green','Blue','Red','Orange']

  ;  temp_Str_Array =['0Per', '5per', '10Per', '15Per']
  Legend_Array =[LEgend_ARray,'sm1','sm3','sm5','sm7','sm9']
  ndata = 5
  ndata1 = nfiles+1
  For p =0,nfiles-1 do begin
    print, p, simfile[p]

    Temp=''
    Temp_Col=''
    Read, temp, PROMPT=' Enter Legend for this File : '
 ;    Read, temp_col, PROMPT=' Enter Color for this Data : '
 ;    Color_Array11 = [Color_Array,temp_col]
    Legend_ARray11 = [LEgend_ARray11,temp]

; right now only selecting two components.
; the general idea is to plot individual component as well as the sum. 

    ReadCol, simfile[p], Temp1, Temp1_err, format='F,F'
    If p eq 0 Then Begin
      Gamma1 = Temp1
      Gamma1_Err = Temp1_Err
    Endif Else If  p eq 1 Then Begin
      Gamma2 = Temp1
      Gamma2_Err = Temp1_Err
    Endif Else If  p eq 2 Then Begin
      Gamma3 = Temp1
      Gamma3_Err = Temp1_Err
    Endif Else If  p eq 3 Then Begin
      Gamma4 = Temp1
      Gamma4_Err = Temp1_Err
    EndIF Else If  p eq 4 Then Begin
      Gamma5 = Temp1
      Gamma5_Err = Temp1_Err
    EndIF

  Endfor

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

  ;
  ;-- Gammas
  ;
  Gamma12 = DblArr(nbins)
  Gamma12_Err = DblArr(nbins)

  Gamma22 = DblArr(nbins)
  Gamma22_Err = DblArr(nbins)

  Gamma32 = DblArr(nbins)
  Gamma32_Err = DblArr(nbins)

  Gamma42 = DblArr(nbins)
  Gamma42_Err = DblArr(nbins)

  Gamma52 = DblArr(nbins)
  Gamma52_Err = DblArr(nbins)

  TotGamma = DblArr(nbins)
  TotErr = DblArr(nbins)

  Cntr=0L

  for i = 0, nbins-1 do begin
      tempFli   = 0.0
    tempGam1   = 0.0
    tempGam2   = 0.0
    tempGam3   = 0.0
    tempGam4   = 0.0
    tempGam5   = 0.0


    tempFli_err   = 0.0
    tempGam1_err   = 0.0
    tempGam2_err   = 0.0
    tempGam3_err   = 0.0
    tempGam4_err   = 0.0
    tempGam5_err   = 0.0

    for j = 0, bin-1 do begin

      tempFli   = tempfli   + Flight1[cntr]

      tempGam1   = tempGam1   + Gamma1[cntr]
      if nfiles ge 2 then tempGam2   = tempGam2   + Gamma2[cntr]
      if nfiles ge 3 then tempGam3   = tempGam3   + Gamma3[cntr]
      if nfiles ge 4 then tempGam4   = tempGam4   + Gamma4[cntr]
      if nfiles ge 5 then tempGam5   = tempGam5   + Gamma5[cntr]

      ;
      ;-- Errors --
      ;

      tempFli_err   = tempFli_err   + Flight1_Err[cntr]*Flight1_Err[cntr]

      tempGam1_err   = tempGam1_err   + Gamma1_Err[cntr]*Gamma1_Err[cntr]
      if nfiles ge 2 then tempGam2_err   = tempGam2_err   + Gamma2_Err[cntr]*Gamma2_Err[cntr]
      if nfiles ge 3 then tempGam3_err   = tempGam3_err   + Gamma3_Err[cntr]*Gamma3_Err[cntr]
      if nfiles ge 4 then tempGam4_err   = tempGam4_err   + Gamma4_Err[cntr]*Gamma4_Err[cntr]
      if nfiles ge 5 then tempGam5_err   = tempGam5_err   + Gamma5_Err[cntr]*Gamma5_Err[cntr]

      cntr++
    endfor

    Flight2[i] = tempFli

    Gamma12[i]  = tempGam1
    if nfiles ge 2 then Gamma22[i]  = tempGam2
    if nfiles ge 3 then Gamma32[i]  = tempGam3
    if nfiles ge 4 then Gamma42[i]  = tempGam4
    if nfiles ge 5 then Gamma52[i]  = tempGam5

    Flight2_Err[i] = Sqrt(tempFli_Err)

    Gamma12_Err[i]  = Sqrt(tempGam1_Err)

    if nfiles ge 2 then Gamma22_Err[i]  = Sqrt(tempGam2_Err)
    if nfiles ge 3 then Gamma32_Err[i]  = Sqrt(tempGam3_Err)
    if nfiles ge 4 then Gamma42_Err[i]  = Sqrt(tempGam4_Err)
    if nfiles ge 5 then Gamma52_Err[i]  = Sqrt(tempGam5_Err)


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
  Openw, Lun555, '10_40_Type3_l2v7_inv3_rebin.txt',/Get_Lun
      for i = 0, n_elements(Flight2)-1 do begin
            printf, lun555, Strn(Flight2[i]), ' ', Strn(Flight2_Err[i])
      endfor
  free_lun,lun555
  stop

  Gamma12_Err  = Gamma12_err/bin
  Gamma12  = Gamma12/bin
 
  Gamma22_Err = Gamma22_err/bin
  Gamma22 = Gamma22/bin
  
  Gamma32_Err = Gamma32_err/bin
  Gamma32 = Gamma32/bin
  
  Gamma42_Err = Gamma42_err/bin
  Gamma42 = Gamma42/bin  
  
  Gamma52_Err = Gamma52_err/bin
  Gamma52 = Gamma52/bin
  ; Now we need to add the errors and the components in the simulation. 
 ; Need to make it automated for numerous combinations after this.
  

  TotGamma = Gamma12+Gamma22+Gamma32+Gamma42+Gamma52
  TotErr = Sqrt(Gamma22_Err*Gamma22_err+ Gamma12_Err*Gamma12_Err+ Gamma32_Err*Gamma32_Err+Gamma42_Err*Gamma42_Err + Gamma52_Err*Gamma52_Err)

  If Sel_Flag eq true then begin
    St_Estimated = TotGamma[sel_min:sel_max]
    St_measured_1 =  Flight2[sel_min:sel_max]
    St_Chiarr1_ele = N_Elements(Flight2_Err[where(Flight2_Err[sel_min:sel_max] ne 0.0)])
    St_Var1 = (Flight2_Err[sel_min:sel_max])^2
    xval2 = Indgen(N_Elements(St_Estimated))*Bin+Sel_energy_min


  Endif else begin
    St_estimated  =  totGamma
    St_measured_1 = Flight2
    St_Chiarr1_ele = N_Elements(Flight2_Err[where(Flight2_Err ne 0.0)])
    St_Var1 = (Flight2_Err)^2
  Endelse


  ; Smoothing. 0
  St_Diff_0 = (St_estimated - St_measured_1)^2
  St_Chiarr_0 = DblArr(n_elements(St_Diff_0))
  For i = 0,n_elements(St_Diff_0)-1 do if (St_Var1[i] ne 0.0) then  St_Chiarr_0[i] = St_Diff_0[i]/(St_Var1[i]) else St_Chiarr_0[i] =0.0

  Chi0 = Total(st_chiarr_0)
  Red_Chi0 = Chi0/(St_Chiarr1_Ele)
  Legend_ARray1 =[ Legend_ARray1,STRN(Red_Chi0)]
  Legend_ARray2 =[ Legend_ARray2,STRN(Chi0)]

  DOF = ST_Chiarr1_Ele -2


  ; Smoothing 1
  St_Estimated1 = Smooth(St_Estimated,1,/Edge_truncate)

  St_Diff_1 = (St_estimated1 - St_measured_1)^2
  St_Chiarr_1 = DblArr(n_elements(St_Diff_1))
  For i = 0,n_elements(St_Diff_1)-1 do if (St_Var1[i] ne 0.0) then  St_Chiarr_1[i] = St_Diff_1[i]/(St_Var1[i]) else St_Chiarr_1[i] =0.0
  Chi1 = Total(st_chiarr_1)
  Red_Chi1 = Chi1/DOF


  ; Smoothing 3
  St_Estimated3 = Smooth(St_Estimated,3,/Edge_truncate)

  St_Diff_3 = (St_estimated3 - St_measured_1)^2
  St_Chiarr_3 = DblArr(n_elements(St_Diff_3))
  For i = 0,n_elements(St_Diff_3)-1 do if (St_Var1[i] ne 0.0) then  St_Chiarr_3[i] = St_Diff_3[i]/(St_Var1[i]) else St_Chiarr_3[i] =0.0
  Chi3 = Total(st_chiarr_3)
  Red_Chi3 = Chi3/DOF


  ; Smoothing 5
  St_Estimated5 = Smooth(St_Estimated,5,/Edge_truncate)

  St_Diff_5 = (St_estimated5 - St_measured_1)^2
  St_Chiarr_5 = DblArr(n_elements(St_Diff_5))
  For i = 0,n_elements(St_Diff_5)-1 do if (St_Var1[i] ne 0.0) then  St_Chiarr_5[i] = St_Diff_5[i]/(St_Var1[i]) else St_Chiarr_5[i] =0.0
  Chi5 = Total(st_chiarr_5)
  Red_Chi5 = Chi5/DOF

  ; Smoothing 7
  St_Estimated7 = Smooth(St_Estimated,7,/Edge_truncate)

  St_Diff_7 = (St_estimated7 - St_measured_1)^2
  St_Chiarr_7 = DblArr(n_elements(St_Diff_7))
  For i = 0,n_elements(St_Diff_7)-1 do if (St_Var1[i] ne 0.0) then  St_Chiarr_7[i] = St_Diff_7[i]/(St_Var1[i]) else St_Chiarr_7[i] =0.0
  Chi7 = Total(st_chiarr_7)
  Red_Chi7 = Chi7/DOF

  ; Smoothing 9
  St_Estimated9 = Smooth(St_Estimated,9,/Edge_truncate)

  St_Diff_9 = (St_estimated9 - St_measured_1)^2
  St_Chiarr_9 = DblArr(n_elements(St_Diff_9))
  For i = 0,n_elements(St_Diff_9)-1 do if (St_Var1[i] ne 0.0) then  St_Chiarr_9[i] = St_Diff_9[i]/(St_Var1[i]) else St_Chiarr_9[i] =0.0
  Chi9 = Total(st_chiarr_9)
  Red_Chi9 = Chi9/DOF

  Legend_ARray2 =[ Legend_ARray2,STRN(Chi1),STRN(Chi3),STRN(Chi5),STRN(Chi7)]

  ; More Plot Param
  Xerr = intarr(n_elements(xval1))
  Xerr[*] = bin/2
  er_wid = 0.001


  ;===
  ;---- Opening the Device for further plots and various things -----
  If PSD_Flag eq true then begin
    CgPs_Open, Title+'_Psd_'+STrn(PSD)+'_Com_Gamma_a.ps', Font =1, /LandScape
  Endif Else BEgin
    CgPs_Open, Title+'_Com_Gamma_a.ps', Font =1, /LandScape

  Endelse
  cgLoadCT, 13
  !P.Font=1

  xticks = loglevels([xmin,xmax])
  nticks = n_elements(xticks)

  ;
  ; Page 1: Flight vs gamma
  ;
  PSYM_Arr = IntArr(ndata+2)
  PSYM_Arr[*]=1


  Cgplot, Xval2,St_Measured_1, PSYM=3, XRANGE=[Xmin,Xmax],Xstyle=1, /Xlog,/Ylog,  YRAnge=[Ymin,Ymax], YStyle=1,$
    title=ptitle, xtitle=xtitle, ytitle=ytitle,linestyle=1,$
    err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color='black',Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1
  ;  Cgoplot, Xval2,Flight2,Color='black'


  If PSD_Flag Eq true then CgText, !D.X_Size*0.75,!D.Y_Size*(0.050), 'PSD efficiency ='+Strn(PSD),/DEVICE, CHarSize=1.5

  CgLegend, SymColors=Color_Array[0:ndata],PSyms=PSYM_Arr[0:ndata], Location=[0.93,0.9],$
    Titles=Legend_Array,length=0, Tcolors=Color_Array[0:ndata], /box, charsize=1

  ;CgLegend, SymColors=Color_Array[0:ndata],PSyms=PSYM_Arr[0:ndata], Location=[0.93,0.6],$
  ;  Titles=Legend_Array1,length=0, Tcolors=Color_Array[0:ndata], /box, charsize=1

  CgLegend, SymColors=Color_Array[0:ndata],PSyms=PSYM_Arr[0:ndata], Location=[0.93,0.3],$
    Titles=Legend_Array2,length=0, Tcolors=Color_Array[0:ndata], /box, charsize=1

  CGText, !D.X_Size*0.93,!D.Y_Size*(0.93), 'DOF='+STRN(DOF),/DEVICE, CHarSize=1.5

  If Sel_Flag eq True Then CGText, !D.X_Size*0.12,!D.Y_Size*(0.001), Sel_energy_Text,/DEVICE, CHarSize=1.1

  CGoplot, Xval2,St_Estimated1, Color=Color_array[1]
  ;   err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
  ;   err_Yhigh = Gamma12_Err, err_Ylow = Gamma12_Err , /Err_Clip, PSYM=3

  CGoplot, Xval2,St_Estimated3, Color=Color_array[2]

  CGoplot, Xval2,St_Estimated5, Color=Color_array[3]
  CGoplot, Xval2,St_Estimated7, Color=Color_array[4]
  CGoplot, Xval2,St_Estimated9, Color=Color_array[5]
  ;err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
  ;   err_Yhigh = Gamma22_Err ,err_Ylow = Gamma22_Err , /Err_Clip, Err_Color=Color_array[2]
  CgErase

  Smooth_Arr = [1,3,5,7,9]
  Smooth_Chi = [Chi1,Chi3,Chi5,Chi7,Chi9]
  CgPlot, Smooth_arr, Smooth_Chi, Xtitle='Smooth Degree', PSYM=4, Ytitle='Chi-Squared', Yrange=[0,300]
  CgErase

  residual1 = St_Estimated1- St_Measured_1
  residual3 = St_Estimated3- St_Measured_1
  residual5 = St_Estimated5- St_Measured_1
  residual7 = St_Estimated7- St_Measured_1
  residual9 = St_Estimated9- St_Measured_1

  CgPlot, Xval2,Residual1, Ytitle ='Diff',Xtitle='Energy', Color=Color_array[1]
  CgoPlot, Xval2,Residual3, Ytitle ='Diff',Xtitle='Energy', Color=Color_array[2]
  CgoPlot, Xval2,Residual5, Ytitle ='Diff',Xtitle='Energy', Color=Color_array[3]
  CgoPlot, Xval2,Residual7, Ytitle ='Diff',Xtitle='Energy', Color=Color_array[4]
  CgoPlot, Xval2,Residual9, Ytitle ='Diff',Xtitle='Energy', Color=Color_array[5]
  CgLegend, SymColors=Color_Array[0:ndata],PSyms=PSYM_Arr[0:ndata], Location=[0.93,0.3],$
    Titles=Legend_Array2,length=0, Tcolors=Color_Array[0:ndata], /box, charsize=1
  
  
  CgErase

  Smooth_Red = [Red_chi1,REd_Chi3,Red_Chi5,Red_Chi7,Red_Chi9]
  CgPlot, Smooth_arr, Smooth_Red, Xtitle='Smooth Degree', PSYM=4, Ytitle='Red-Chi-Squared', Yrange=[0,15]
  
  CgErase
  Ymin = 0.000001
  Ymax = 0.1
  
  print, n_elements(xval1), n_elements(flight2)
  CgPlot, xval1, Flight2,PSYM=10, XRANGE=[Xmin,Xmax],Xstyle=1, /Xlog,/Ylog,  YRAnge=[Ymin,Ymax], YStyle=1,$
    title=ptitle, xtitle=xtitle, ytitle=ytitle,linestyle=1,$
    err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color=Color_array11[0],Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1
  
  

  CgoPlot, xval1, TotGamma,PSYM=10,Color=Color_Array11[1],$
    err_Yhigh =totGamma_Err, err_Ylow = TotGamma_Err, /Err_Clip,Err_Color=Color_array11[1],Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1

  CgoPlot, xval1, gamma12,PSYM=10,Color=Color_Array11[2],$
    err_Yhigh =Gamma12_Err, err_Ylow = Gamma12_Err, /Err_Clip,Err_Color=Color_array11[2],Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1
  
  CgoPlot, xval1, gamma22,PSYM=10,Color=Color_Array11[3],$
    err_Yhigh =Gamma22_Err, err_Ylow = Gamma22_Err, /Err_Clip,Err_Color=Color_array11[3],Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1
   
  CgoPlot, xval1, gamma32,PSYM=10,Color=Color_Array11[4],$
    err_Yhigh =Gamma32_Err, err_Ylow = Gamma32_Err, /Err_Clip,Err_Color=Color_array11[4],Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1
    
    CgoPlot, xval1, gamma42,PSYM=10,Color=Color_Array11[5],$
    err_Yhigh =Gamma42_Err, err_Ylow = Gamma42_Err, /Err_Clip,Err_Color=Color_array11[5],Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1
    
      CgoPlot, xval1, gamma52,PSYM=10,Color=Color_Array11[6],$
      err_Yhigh =Gamma52_Err, err_Ylow = Gamma52_Err, /Err_Clip,Err_Color=Color_array11[6],Err_Width=er_wid,$
      err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1
    
    print, n_elements(legend_array11), n_elements(psym_arr[0:ndata1])
    print, legend_array11
    print, (psym_arr[0:ndata1])
        CgLegend, SymColors=Color_Array11[0:ndata1],PSyms=PSYM_Arr[0:ndata1], Location=[0.93,0.9],$
        Titles=Legend_Array11,length=0, Tcolors=Color_Array11[0:ndata1], /box, charsize=1
  
      
  CgPs_Close

  ;print, gamma12, gamma12_err


  ;-- Create the PDF File
  If PSD_Flag Eq true then Temp_Str = Cur+'/'+Title+'_Psd_'+STrn(PSD)+'_Com_Gamma_a.ps' Else Temp_Str = Cur+'/'+Title+'_Com_Gamma_a.ps'
  CGPS2PDF, Temp_Str,delete_ps=1


  print,'end'

End