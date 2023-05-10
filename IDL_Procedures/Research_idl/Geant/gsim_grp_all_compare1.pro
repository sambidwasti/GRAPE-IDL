Pro gsim_grp_all_compare1, file1, file2, title=title, bin=bin

  ;
  ;== Read in the flight file 1
  ;   read in the sim FOLDER
  ;

  ;
  ;==== PLOT Variables
  ;
    CTVal = 10
  PTitle = ' PC Flight vs Simulation  (CT='+STRN(CTVAL)+'%)'
  Xtitle = ' Energy (keV) '
  Ytitle = ' C/s/keV '

  ;Range
  Xmin  = 40
  Xmax  = 500
  Ymin  = 1E-8
  Ymax  = 2
  ;--- Current Directory
  CD, Cur = Cur


  if keyword_set(bin) ne 1 then bin = 10
  if keyword_set(title) ne 1 then title='Try'

  ; Read in the flight --
  ReadCol, file1, Flight1, Flight1_err, format='F,F'

  ;
  ;-- Read in the sims --
  ;
  simfile = file_search(file2+'/*')
  nfiles  = n_elements(simfile)

  For p =0,nfiles-1 do begin

    if StrPos(simfile[p],'gamma_com',0) GT 1 then begin
  ;    print, simfile[p]
      ReadCol, simfile[p], Gamma1, Gamma1_err, format='F,F'
    endif
    
    ; Primaries
    if StrPos(simfile[p],'prielec',0) GT 1 then   ReadCol, simfile[p], PElec1, PElec1_err, format='F,F'
      if StrPos(simfile[p],'priposi',0) GT 1 then   ReadCol, simfile[p], PPosi1, PPosi1_err, format='F,F'
        if StrPos(simfile[p],'priprot',0) GT 1 then   ReadCol, simfile[p], PProt1, PProt1_err, format='F,F'
 
    ;-- Secondaries--
    if StrPos(simfile[p],'sec_positron_down',0) GT 1 then   ReadCol, simfile[p], SPosiD1, SPosiD1_err, format='F,F'
      if StrPos(simfile[p],'sec_positron_up',0) GT 1 then   ReadCol, simfile[p], SPosiU1, SPosiU1_err, format='F,F'

    if StrPos(simfile[p],'sec_electron_down',0) GT 1 then   ReadCol, simfile[p], SElecD1, SElecD1_err, format='F,F'
      if StrPos(simfile[p],'sec_electron_up',0) GT 1 then   ReadCol, simfile[p], SElecU1, SElecU1_err, format='F,F'

    if StrPos(simfile[p],'sec_proton_down',0) GT 1 then   ReadCol, simfile[p], SProtD1, SProtD1_err, format='F,F'
      if StrPos(simfile[p],'sec_proton_up',0) GT 1 then   ReadCol, simfile[p], SProtU1, SProtU1_err, format='F,F'
      
    if StrPos(simfile[p],'neutron',0) GT 1 then   ReadCol, simfile[p], Neut1, Neut1_err, format='F,F'

  Endfor

  ;
  ; Rebinning here:
  nbins = (1000/bin) + 1
  xval2 = indgen(nbins)*bin

  ;
  ;-- FLight
  ;
  Flight2 = DblArr(nbins)
  Flight2_Err = DblArr(nbins)

  ;
  ;-- Gammas
  ;
  Gamma2 = DblArr(nbins)
  Gamma2_Err = DblArr(nbins)

  ;
  ;-- Primaries ---
  ;
  PElec2 = DblArr(nbins)
  PElec2_Err = DblArr(nbins)
  
    PPosi2 = DblArr(nbins)
    PPosi2_Err = DblArr(nbins)
    
      PProt2 = DblArr(nbins)
      PProt2_Err = DblArr(nbins)

  ;
  ;-- Secondaries ---
  ;
  SPosiD2 = DblArr(nbins)
  SPosiD2_err = DblArr(nbins)

    SPosiU2 = DblArr(nbins)
    SPosiU2_err = DblArr(nbins)
  
      SElecD2 = DblArr(nbins)
      SElecD2_err = DblArr(nbins)
    
        SElecU2 = DblArr(nbins)
        SElecU2_err = DblArr(nbins)
      
          SProtD2 = DblArr(nbins)
          SProtD2_err = DblArr(nbins)
        
            SProtU2 = DblArr(nbins)
            SProtU2_err = DblArr(nbins)

    Neut2 = DblArr(nbins)
    Neut2_err = DblArr(nbins)

  ;
  ; Total
  ;
  TotalGamma = DblArr(nbins)
  TotalGamma_Err = DblArr(nbins)
  
    TotalGamma_a = DblArr(nbins)
    TotalGamma_a_Err = DblArr(nbins)

    TotalGamma_b = DblArr(nbins)
    TotalGamma_b_Err = DblArr(nbins)
    
  TotalGamma_c = DblArr(nbins)
    TotalGamma_c_Err = DblArr(nbins) 

  Cntr=0L
  
  for i = 0, nbins-2 do begin
    tempFli   = 0.0
    tempGam   = 0.0
    tempPEle  = 0.0
    tempPPos  = 0.0
    tempPPro  = 0.0
    tempSposD = 0.0
    tempSposU = 0.0
    tempSeleD = 0.0
    tempSeleU = 0.0
    tempSproD = 0.0
    tempSproU = 0.0
    tempNeut = 0.0


    tempFli_err   = 0.0
    tempGam_err   = 0.0
    tempPEle_err  = 0.0
    tempPPos_err  = 0.0
    tempPPro_err  = 0.0
    tempSposD_err = 0.0
    tempSposU_err = 0.0
    tempSeleD_err = 0.0
    tempSeleU_err = 0.0
    tempSproD_err = 0.0
    tempSproU_err = 0.0
    tempNeut_err =0.0

    for j = 0, bin-1 do begin

      tempFli   = tempfli   + Flight1[cntr]

      tempGam   = tempGam   + Gamma1[cntr]

      tempPEle  = tempPEle  + PElec1[cntr]
      tempPPos  = tempPPos  + PPosi1[cntr]
      tempPPro  = tempPPro  + PProt1[cntr]

      tempSposD = tempSposD + SPosiD1[cntr]
      tempSposU = tempSposU + SPosiU1[cntr]
      tempSeleD = tempSeleD + SElecD1[cntr]
      tempSeleU = tempSeleU + SElecU1[cntr]
      tempSproD = tempSproD + SProtD1[cntr]
      tempSproU = tempSproU + SProtU1[cntr]

      tempNeut = tempNeut + Neut1[cntr]
      ;
      ;-- Errors --
      ;

      tempFli_err   = tempFli_err   + Flight1_Err[cntr]*Flight1_Err[cntr]

      tempGam_err   = tempGam_err   + Gamma1_Err[cntr]*Gamma1_Err[cntr]

      tempPEle_err  = tempPEle_err  + PElec1_Err[cntr]*PElec1_Err[cntr]
      tempPPos_err  = tempPPos_err  + PPosi1_Err[cntr]*PPosi1_Err[cntr]
      tempPPro_err  = tempPPro_err  + PProt1_Err[cntr]*PProt1_Err[cntr]

      tempSposD_err = tempSposD_err + SPosiD1_Err[cntr]*SPosiD1_Err[cntr]
      tempSposU_err = tempSposU_err + SPosiU1_Err[cntr]*SPosiU1_Err[cntr]

      tempSeleD_err = tempSeleD_err + SElecD1_Err[cntr]*SElecD1_Err[cntr]
      tempSeleU_err = tempSeleU_err + SElecU1_Err[cntr]*SElecU1_Err[cntr]

      tempSproD_err = tempSproD_err + SProtD1_Err[cntr]*SProtD1_Err[cntr]
      tempSproU_err = tempSproU_err + SProtU1_Err[cntr]*SProtU1_Err[cntr]

      tempNeut_err = tempNeut_err + Neut1_Err[cntr]*Neut1_Err[cntr]
      
      cntr++
    endfor

    Flight2[i] = tempFli

    Gamma2[i]  = tempGam

    PElec2[i]  = tempPele
    PPosi2[i]  = tempPpos
    PProt2[i]  = tempPpro

    SPosiD2[i] = tempSposD
    SPosiU2[i] = tempSposU

    SElecD2[i] = tempSeleD
    SElecU2[i] = tempSeleU

    SProtD2[i] = tempSproD
    SProtU2[i] = tempSproU
    
    Neut2[i] = tempNeut
    

    TotalGamma[i] = tempGam+tempPele+TempPpos+TempPPro+TempSposD+TempSPosU+TempSEleU+TempSEleD+TempSProD+TempSProU+tempNeut
    TotalGamma_a[i] = tempGam+tempPele+TempPpos+TempPPro
    TotalGamma_b[i] = tempGam+TempSposD+TempSPosU+TempSEleU+TempSEleD+TempSProD+TempSProU
    TotalGamma_c[i] = tempGam+tempPele+TempPpos+TempPPro+TempSposD+TempSPosU+TempSEleU+TempSEleD+TempSProD+TempSProU

    TotalGamma_Err[i] = sqrt(tempGam_Err+ tempPEle_Err+ tempPPos_Err+ tempPPro_Err $
      + TempSPosD_Err + TempSPosU_Err + TempSEleD_Err + TempSEleU_Err + TempSProD_Err + TempSProU_Err+ TempNeut_Err)
    TotalGamma_a_Err[i] = sqrt(tempGam_Err+ tempPEle_Err+ tempPPos_Err+ tempPPro_Err)  
    TotalGamma_b_Err[i] = sqrt(tempGam_Err+ TempSPosD_Err + TempSPosU_Err + TempSEleD_Err + TempSEleU_Err + TempSProD_Err + TempSProU_Err)
    TotalGamma_c_Err[i] = sqrt(tempGam_Err+ tempPEle_Err+ tempPPos_Err+ tempPPro_Err $
      + TempSPosD_Err + TempSPosU_Err + TempSEleD_Err + TempSEleU_Err + TempSProD_Err + TempSProU_Err)


    Flight2_Err[i] = Sqrt(tempFli_Err)

    Gamma2_Err[i]  = Sqrt(tempGam_Err)

    PElec2_Err[i]  = Sqrt(tempPEle_Err)
    PPosi2_Err[i]  = Sqrt(tempPPos_Err)
    PProt2_Err[i]  = Sqrt(tempPPro_Err)

    SPosiD2_err[i] = Sqrt(tempSPosD_Err)
    SPosiU2_err[i] = Sqrt(tempSPosU_Err)

    SElecD2_err[i] = Sqrt(tempSEleD_Err)
    SElecU2_err[i] = Sqrt(tempSEleU_Err)

    SProtD2_err[i] = Sqrt(tempSProD_Err)
    SProtU2_err[i] = Sqrt(tempSProU_Err)
    
    Neut2_Err[i] = Sqrt(TempNeut_Err)
  endfor

  ;
  ;=== Per bin scaling ===
  ;
  Flight2 = Flight2/bin

  Gamma2  = Gamma2/bin

  PElec2  = PElec2/bin
  PPosi2  = PPosi2/bin
  PProt2  = PProt2/bin

  SPosiD2 = SPosiD2/bin
  SPosiU2 = SPosiU2/bin

  SElecD2 = SElecD2/bin
  SElecU2 = SElecU2/bin

  SProtD2 = SprotD2/bin
  SProtU2 = SprotU2/bin
  
  NEut2 = Neut2/bin
  
  TotalGamma = totalGamma/bin
    TotalGamma_a = totalGamma_a/bin
      TotalGamma_b = totalGamma_b/bin
        TotalGamma_c = totalGamma_c/bin
  
  Flight2_Err = Flight2_err/bin
  Gamma2_Err  = Gamma2_err/bin

  PElec2_Err  = PElec2_err/bin
  PPosi2_Err  = PPosi2_err/bin
  PProt2_Err  = PProt2_err/bin

  SPosiD2_err = SPosiD2_err/bin
  SPosiU2_err = SPosiU2_err/bin

  SElecD2_err = SElecD2_err/bin
  SElecU2_err = SElecU2_err/bin

  SProtD2_err = SProtD2_err/bin
  SProtU2_err = SProtU2_err/bin

  TotalGamma_Err = totalGamma_err/bin
    TotalGamma_a_Err = totalGamma_a_err/bin
      TotalGamma_b_Err = totalGamma_b_err/bin
          TotalGamma_c_Err = totalGamma_c_err/bin
      
  Neut2_Err = NEut2_err/bin
  ;
  ;=== Combining secondaries  ===
  ;

  SPosi = SPosiD2 + SPosiU2
  SElec = SElecD2 + SElecU2
  SProt = SprotD2 + SprotU2

  ; Adding errors in quadrature
  SPosi_Err = Sqrt(SposiD2_err*SposiD2_err + SposiU2_err*SposiU2_err)
  SElec_Err = Sqrt(SElecD2_err*SElecD2_err + SElecU2_err*SElecU2_err)
  SProt_Err = Sqrt(SProtD2_err*SProtD2_err + SProtU2_err*SProtU2_err)
  ; -----
  


  ; More Plot Param
  Xerr = intarr(n_elements(xval2))
  Xerr[*] = bin/2
  er_wid = 0.001
  ; a = cgPickColorName()
  ;---- Opening the Device for further plots and various things -----
  CgPs_Open, Title+'_Final.ps', Font =1, /LandScape
  cgLoadCT, 13
  !P.Font=1

  xticks = loglevels([xmin,xmax])
  nticks = n_elements(xticks)

 ;
 ; Page 1: Flight vs gamma
 ;
  Cgplot, Xval2,Flight2, PSYM=3, XRANGE=[Xmin,Xmax],Xstyle=1, /Xlog,/Ylog,  YRAnge=[Ymin,Ymax], YStyle=1,$
    title=ptitle, xtitle=xtitle, ytitle=ytitle,$
    err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color='black',Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1
    
  CgLegend, SymColors=['black','red'],PSyms=[1,1], Location=[0.93,0.9],$
    Titles=['Flight','Gamma'],length=0, Tcolors=['black','red'], /box, charsize=1
    
  CGoplot, Xval2,Gamma2, PSYM=3, Color='red',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Yhigh = Gamma2_Err, err_Ylow = Gamma2_Err , /Err_Clip, Err_Color='red'
    
  Cgerase

;
;--- PAGE 2
;

  Cgplot, Xval2,Flight2, PSYM=3, XRANGE=[Xmin,Xmax],Xstyle=1, /Xlog,/Ylog,  YRAnge=[Ymin,Ymax], YStyle=1,$
  title=ptitle, xtitle=xtitle, ytitle=ytitle,$
  err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color='black',Err_Width=er_wid,$
  err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1
  
  CgLegend, SymColors=['black','red','blue','ORG4','Gold','GRN4'],PSyms=[1,1,1,1,1,1], Location=[0.93,0.9],$
    Titles=['Flight','Gamma','Total gamma','Pri Elec','Pri Pos', 'Pri Prot'],length=0, Tcolors=['black','red','blue','ORG4','Gold','GRN4'], /box, charsize=1
    
  CGoplot, Xval2,Gamma2, PSYM=3, Color='red',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Yhigh = Gamma2_Err, err_Ylow = Gamma2_Err , /Err_Clip, Err_Color='red'
    
  CGoplot, Xval2,TotalGamma_a, PSYM=0, Color='blue';,$
  ; err_Yhigh = TotalGamma_a_Err, err_Ylow = TotalGamma_Err , /Err_Clip, Err_Color='blue'
  ;     
 
 ;Primaries
    CGoplot, Xval2,PElec2, PSYM=3, Color='ORG4',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
      err_Yhigh = PElec2_Err, err_Ylow = PElec2_Err , /Err_Clip, Err_Color='ORG4'
    CGoplot, Xval2,PPosi2, PSYM=3, Color='Gold',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
      err_Yhigh = PPosi2_Err, err_Ylow = PPosi2_Err , /Err_Clip, Err_Color='Gold'
    CGoplot, Xval2,PProt2, PSYM=3, Color='GRN4',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
      err_Ylow = PProt2_Err,ERR_YHigh = PProt2_Err , /Err_Clip, Err_Color='GRN4
  
  Cgerase
;
;-- PAGE 3
;
Cgplot, Xval2,Flight2, PSYM=3, XRANGE=[Xmin,Xmax],Xstyle=1, /Xlog,/Ylog,  YRAnge=[Ymin,Ymax], YStyle=1,$
  title=ptitle, xtitle=xtitle, ytitle=ytitle,$
  err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color='black',Err_Width=er_wid,$
  err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1

CgLegend, SymColors=['black','red','blue','medium orchid', 'sky blue','gray'],PSyms=[1,1,1,1,1,1], Location=[0.93,0.9],$
  Titles=['Flight','Gamma','Total', 'Sec Prot', 'Sec Elec', 'Sec Posi'],length=0, Tcolors=['black','red','blue','medium orchid','sky blue','gray'], /box, charsize=1

CGoplot, Xval2,TotalGamma_b, PSYM=0, Color='blue';$
; err_Yhigh = TotalGamma_a_Err, err_Ylow = TotalGamma_Err , /Err_Clip, Err_Color='blue'

CGoplot, Xval2,Gamma2, PSYM=3, Color='red',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
  err_Yhigh = Gamma2_Err, err_Ylow = Gamma2_Err , /Err_Clip, Err_Color='red'


;
;      ; Secondaries
CGoplot, XVal2, Sprot, PSYM=3, color='medium orchid',err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
  err_Ylow = SProt_Err,ERR_YHigh = SProt_Err , /Err_Clip, Err_Color='medium orchid'
CGoplot, XVal2, SPosi, PSYM=3, color='Gray',err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
  err_Ylow = SPosi_Err,ERR_YHigh = SPosi_Err , /Err_Clip, Err_Color='Gray'
CGoplot, XVal2, SElec, PSYM=3, color='sky blue',err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
  err_Ylow = SElec_Err,ERR_YHigh = SElec_Err , /Err_Clip, Err_Color='sky blue'

  Cgerase
  ;PAGE 4
  
  Cgplot, Xval2,Flight2, PSYM=3, XRANGE=[Xmin,Xmax],Xstyle=1, /Xlog,/Ylog,  YRAnge=[Ymin,Ymax], YStyle=1,$
    title=ptitle, xtitle=xtitle, ytitle=ytitle,$
    err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color='black',Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1

  CgLegend, SymColors=['black','red','blue','ORG4','Gold','GRN4','medium orchid', 'sky blue','gray'],PSyms=[1,1,1,1,1,1,1,1,1], Location=[0.93,0.9],$
    Titles=['Flight','Gamma','Total','Pri Elec','Pri Pos', 'Pri Prot', 'Sec Prot', 'Sec Elec', 'Sec Posi'],length=0, Tcolors=['black','red','blue','ORG4','Gold','GRN4','medium orchid','sky blue','gray'], /box, charsize=1

  CGoplot, Xval2,TotalGamma_c, PSYM=0, Color='blue';$
  ; err_Yhigh = TotalGamma_a_Err, err_Ylow = TotalGamma_Err , /Err_Clip, Err_Color='blue'

  CGoplot, Xval2,Gamma2, PSYM=3, Color='red',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Yhigh = Gamma2_Err, err_Ylow = Gamma2_Err , /Err_Clip, Err_Color='red'

  ; Primaries
  CGoplot, Xval2,PElec2, PSYM=3, Color='ORG4',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Yhigh = PElec2_Err, err_Ylow = PElec2_Err , /Err_Clip, Err_Color='ORG4'
  CGoplot, Xval2,PPosi2, PSYM=3, Color='Gold',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Yhigh = PPosi2_Err, err_Ylow = PPosi2_Err , /Err_Clip, Err_Color='Gold'
  CGoplot, Xval2,PProt2, PSYM=3, Color='GRN4',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Ylow = PProt2_Err,ERR_YHigh = PProt2_Err , /Err_Clip, Err_Color='GRN4'
  ;
  ;      ; Secondaries
  CGoplot, XVal2, Sprot, PSYM=3, color='medium orchid',err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Ylow = SProt_Err,ERR_YHigh = SProt_Err , /Err_Clip, Err_Color='medium orchid'
  CGoplot, XVal2, SPosi, PSYM=3, color='Gray',err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Ylow = SPosi_Err,ERR_YHigh = SPosi_Err , /Err_Clip, Err_Color='Gray'
  CGoplot, XVal2, SElec, PSYM=3, color='sky blue',err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Ylow = SElec_Err,ERR_YHigh = SElec_Err , /Err_Clip, Err_Color='sky blue'


  Cgerase
;
;--- PAGE 5
;
ymax = 10000
Cgplot, Xval2,Flight2, PSYM=3, XRANGE=[Xmin,Xmax],Xstyle=1, /Xlog,/Ylog,  YRAnge=[Ymin,Ymax], YStyle=1,$
  title=ptitle, xtitle=xtitle, ytitle=ytitle,$
  err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color='black',Err_Width=er_wid,$
  err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1

 CgLegend, SymColors=['black','red','blue','slate blue','ORG4','Gold','GRN4','medium orchid', 'sky blue','gray'],PSyms=[1,1,1,1,1,1,1,1,1,1], Location=[0.93,0.9],$
  Titles=['Flight','Gamma','Total','neutron','Pri Elec','Pri Pos', 'Pri Prot', 'Sec Prot', 'Sec Elec', 'Sec Posi'],length=0, Tcolors=['black','red','blue','slate blue','ORG4','Gold','GRN4','medium orchid','sky blue','gray'], /box, charsize=1

 CGoplot, Xval2,TotalGamma, PSYM=0, Color='blue';$
; err_Yhigh = TotalGamma_a_Err, err_Ylow = TotalGamma_Err , /Err_Clip, Err_Color='blue'

CGoplot, Xval2,Gamma2, PSYM=3, Color='red',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
  err_Yhigh = Gamma2_Err, err_Ylow = Gamma2_Err , /Err_Clip, Err_Color='red'

; Primaries
    CGoplot, Xval2,PElec2, PSYM=3, Color='ORG4',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
      err_Yhigh = PElec2_Err, err_Ylow = PElec2_Err , /Err_Clip, Err_Color='ORG4'
    CGoplot, Xval2,PPosi2, PSYM=3, Color='Gold',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
      err_Yhigh = PPosi2_Err, err_Ylow = PPosi2_Err , /Err_Clip, Err_Color='Gold'
    CGoplot, Xval2,PProt2, PSYM=3, Color='GRN4',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
      err_Ylow = PProt2_Err,ERR_YHigh = PProt2_Err , /Err_Clip, Err_Color='GRN4'
;
;      ; Secondaries
      CGoplot, XVal2, Sprot, PSYM=3, color='medium orchid',err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
      err_Ylow = SProt_Err,ERR_YHigh = SProt_Err , /Err_Clip, Err_Color='medium orchid'
      CGoplot, XVal2, SPosi, PSYM=3, color='Gray',err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
      err_Ylow = SPosi_Err,ERR_YHigh = SPosi_Err , /Err_Clip, Err_Color='Gray'
      CGoplot, XVal2, SElec, PSYM=3, color='sky blue',err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
      err_Ylow = SElec_Err,ERR_YHigh = SElec_Err , /Err_Clip, Err_Color='sky blue'

      CGoplot, Xval2,neut2, PSYM=3, Color='slate blue',    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
      err_Yhigh = neut2_Err, err_Ylow = neut2_Err , /Err_Clip, Err_Color='slate blue'


  CgPs_Close

  ;-- Create the PDF File
  Temp_Str = Cur+'/'+Title+'_Final.ps'
  CGPS2PDF, Temp_Str,delete_ps=1



End