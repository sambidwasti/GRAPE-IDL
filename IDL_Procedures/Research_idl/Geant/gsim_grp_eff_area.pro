Pro Gsim_Grp_Eff_Area, fsearch_String, title=title
  ;
  ; This generates a text file with the necessary binning defined for the
  ; effective area along with a plot and few files for creating a fits file
  ; using the fcreate ftools command. 
  ; 
  ; The input energy bins has to be same as the response matrix's bins
  ;
  ; Input files:
  ; These are lvl1 processed geant simulated file.
  ;
  ;
  ; Required Procedures/Functions:
  ;           gsim_grp_main_response
  ;                 this function returns an array of 1000 for each file which is
  ;                 one specific mono-energetic enerygy.
  ;  
  ;   3/14/2020      Sambid Wasti 
  ;            gsim_grp_main_response_a For the extra parameter class
  ;            We are still creating only 1 file for xspec but we want PC and C for classes.
  ;  
  ; Current notes:
  ;   Work on one issue at a time.
  ;
  ; 
  ;=== Get single or multiple files ====
  ;
  title = 'Eff'
  close, /all
  ;    Elo = [65,70,90, 120,160,200]
  ;    Ehi = [70,90,120,160,200,300]
  cd, cur=cur
  
  Elo_E = INdgen(193)*5+35
  Ehi_E = Elo_E+5
 

  l1respfiles = file_search(fsearch_String)
  n_l1respfiles = n_elements(l1respfiles)
  ;n_l1respfiles = 10


  ;
  ; Effective area
  ;
  N = 1000000
  Area = 65 * !pi * 65    ; Simulated input area ; mainly for effective area


  ;
  ; == We would want to get the input energy from the file name ==
  ;

  MainResp = LonArr(1001,1001)        ; 1001 because we are including 0 and 1000
  ; Need to filter and select energy and send one at a time
  for p = 0, n_l1respfiles-1 do begin
    Temploc = StrPos(l1respfiles[p],'ResponseRun',0)
    TempLoc1 = StrPos(l1respfiles[p], '_', TempLoc+13)
    TempLoc = TempLoc +12
    ;    Print, TempLoc, tempLoc1
    Ener = Float(StrMID(l1respfiles[p],Temploc, TempLoc1-TempLoc))

   ; B = Gsim_Grp_Main_Response(l1respfiles[p],title=title, Input_ener = Ener)
    B = Gsim_Grp_Main_Response_a(l1respfiles[p],title=title, Input_ener = Ener, class=3)
    MainResp[Ener,*] = B

;    Print, 'InputEner:', Ener
  endfor

  ;
  ; Effective Area. Without rebinning.
  ;
  Ener_Counts = LonArr(1001)
  For i = 0,1000 do Ener_Counts[i]= Total(MainResp[i,*])
  ArfNorm = Area* Ener_Counts/N ; Effective Area
  

  


  ;
  ;-- Now Rebinning --
  ;
  ;Simply, adding the counts consist of binsize and the N is divided by the difference.
  ;
  
  N_ele = n_elements(ELO_E)
  Counts_rebin = LonArr(N_Ele)
  Counts_rebinCC = LonArr(N_Ele)
  Arf_rebin = FltArr(N_ele)
  

  StrVal = '#Elo  Ehi  cm^2'

  Openw, Lun1, 'PC_Eff_Area.txt', /Get_lun
  Printf,LUn1, StrVal
  For i = 0, N_ele-1 do begin
    ; Format is Elo, Ehi, det (1), fchan (0), nchan(N_ele), Ener
    StrVal1 = Strn(Float(ELo_E[i])) + '  '+ Strn(Float(Ehi_E[i])) + '  '+Strn(Arf_Rebin[i])
    Printf, Lun1, strval1
  Endfor

  Free_lun, Lun1

  Print, Ehi_E-Elo_E
  For i = 0, N_ele-1 do begin

    Print, i
    Print, '***************'

    lowj = Fix(Elo_E[i])      ; arr loc
    hij  = Fix(Ehi_E[i])      ; arr loc
    
    tempval = 0.0
    for j = lowj, hij-1 do begin

      tempval = tempval + Ener_Counts[j]
;        Print, Ener_counts[j], TempVal, '***'
;        
;        Print, ArfNorm[j] ,' ArfNorm'
    endfor
    Counts_Rebin[i] = TempVal
  ;  Print, Elo_E[i],Counts_rebin[i],'%%'
    
    Diff = Ehi_E[i] - Elo_E[i]
;    Print,Diff, 'Diff'
;    Print, Area, 'Arrea'
;    Print, N
;    Print, N * Diff, 'Diff_N)'
;    
;    
;    
    Arf_rebin[i] = (Counts_Rebin[i] * Area )/ (Diff *N)

  Endfor

  StrVal = '#Elo  Ehi  cm^2'

  Openw, Lun1, 'PC_Eff_Area.txt', /Get_lun
  Printf,LUn1, StrVal
  For i = 0, N_ele-1 do begin
    ; Format is Elo, Ehi, det (1), fchan (0), nchan(N_ele), Ener
    StrVal1 = Strn(Float(ELo_E[i])) + '  '+ Strn(Float(Ehi_E[i])) + '  '+Strn(Arf_Rebin[i])
    Printf, Lun1, strval1
  Endfor

  Free_lun, Lun1

  Print, Ehi_E-Elo_E
  
  
  ; Now for CC
  MainRespCC = LonArr(1001,1001)        ; 1001 because we are including 0 and 1000
  ; Need to filter and select energy and send one at a time
  for p = 0, n_l1respfiles-1 do begin
    Temploc = StrPos(l1respfiles[p],'ResponseRun',0)
    TempLoc1 = StrPos(l1respfiles[p], '_', TempLoc+13)
    TempLoc = TempLoc +12
    Ener = Float(StrMID(l1respfiles[p],Temploc, TempLoc1-TempLoc))

    ; B = Gsim_Grp_Main_Response(l1respfiles[p],title=title, Input_ener = Ener)
    CC = Gsim_Grp_Main_Response_a(l1respfiles[p],title=title, Input_ener = Ener, class=2)
    MainRespCC[Ener,*] = CC

  endfor  ;
  ; Effective Area. Without rebinning.
  ;
  Ener_Counts_CC = LonArr(1001)
  For i = 0,1000 do Ener_Counts_CC[i]= Total(MainRespCC[i,*])
  ArfNormCC = Area* Ener_Counts_CC/N ; Effective Area

  
  ; Now for C
  MainRespC = LonArr(1001,1001)        ; 1001 because we are including 0 and 1000
  ; Need to filter and select energy and send one at a time
  for p = 0, n_l1respfiles-1 do begin
    Temploc = StrPos(l1respfiles[p],'ResponseRun',0)
    TempLoc1 = StrPos(l1respfiles[p], '_', TempLoc+13)
    TempLoc = TempLoc +12
    Ener = Float(StrMID(l1respfiles[p],Temploc, TempLoc1-TempLoc))

    ; B = Gsim_Grp_Main_Response(l1respfiles[p],title=title, Input_ener = Ener)
    C = Gsim_Grp_Main_Response_a(l1respfiles[p],title=title, Input_ener = Ener, class=1)
    MainRespC[Ener,*] = C

  endfor

  ; Effective Area. Without rebinning.
  ;
  Ener_Counts_C = LonArr(1001)
  For i = 0,1000 do Ener_Counts_C[i]= Total(MainRespC[i,*])
  ArfNormC = Area* Ener_Counts_C/N ; Effective Area
  
  
  ; Now for PC T1
  MainRespPCT1 = LonArr(1001,1001)        ; 1001 because we are including 0 and 1000
  ; Need to filter and select energy and send one at a time
  for p = 0, n_l1respfiles-1 do begin
    Temploc = StrPos(l1respfiles[p],'ResponseRun',0)
    TempLoc1 = StrPos(l1respfiles[p], '_', TempLoc+13)
    TempLoc = TempLoc +12
    Ener = Float(StrMID(l1respfiles[p],Temploc, TempLoc1-TempLoc))

    ; B = Gsim_Grp_Main_Response(l1respfiles[p],title=title, Input_ener = Ener)
    PCT1= Gsim_Grp_Main_Response_a(l1respfiles[p],title=title, Input_ener = Ener, class=3, type=1)
    MainRespPCT1[Ener,*] = PCT1

  endfor

  ; Effective Area. Without rebinning.
  ;
  Ener_Counts_PCT1 = LonArr(1001)
  For i = 0,1000 do Ener_Counts_PCT1[i]= Total(MainRespPCT1[i,*])
  ArfNormPCT1 = Area* Ener_Counts_PCT1/N ; Effective Area

  
  ; Now for PC T2
  MainRespPCT2 = LonArr(1001,1001)        ; 1001 because we are including 0 and 1000
  ; Need to filter and select energy and send one at a time
  for p = 0, n_l1respfiles-1 do begin
    Temploc = StrPos(l1respfiles[p],'ResponseRun',0)
    TempLoc1 = StrPos(l1respfiles[p], '_', TempLoc+13)
    TempLoc = TempLoc +12
    Ener = Float(StrMID(l1respfiles[p],Temploc, TempLoc1-TempLoc))

    ; B = Gsim_Grp_Main_Response(l1respfiles[p],title=title, Input_ener = Ener)
    PCT2= Gsim_Grp_Main_Response_a(l1respfiles[p],title=title, Input_ener = Ener, class=3, type=2)
    MainRespPCT2[Ener,*] = PCT2

  endfor

  ; Effective Area. Without rebinning.
  ;
  Ener_Counts_PCT2 = LonArr(1001)
  For i = 0,1000 do Ener_Counts_PCT2[i]= Total(MainRespPCT2[i,*])
  ArfNormPCT2 = Area* Ener_Counts_PCT2/N ; Effective Area
  
  
  
  ; Now for PC T3
  MainRespPCT3 = LonArr(1001,1001)        ; 1001 because we are including 0 and 1000
  ; Need to filter and select energy and send one at a time
  for p = 0, n_l1respfiles-1 do begin
    Temploc = StrPos(l1respfiles[p],'ResponseRun',0)
    TempLoc1 = StrPos(l1respfiles[p], '_', TempLoc+13)
    TempLoc = TempLoc +12
    Ener = Float(StrMID(l1respfiles[p],Temploc, TempLoc1-TempLoc))

    ; B = Gsim_Grp_Main_Response(l1respfiles[p],title=title, Input_ener = Ener)
    PCT3= Gsim_Grp_Main_Response_a(l1respfiles[p],title=title, Input_ener = Ener, class=3, type=3)
    MainRespPCT3[Ener,*] = PCT3

  endfor

  ; Effective Area. Without rebinning.
  ;
  Ener_Counts_PCT3 = LonArr(1001)
  For i = 0,1000 do Ener_Counts_PCT3[i]= Total(MainRespPCT3[i,*])
  ArfNormPCT3 = Area* Ener_Counts_PCT3/N ; Effective Area


  print,"EFFECTIVE_AREA:", Cur
  
  ; --- Legend infos ---
  Leg_Text = [ 'C', 'CC','PC Total', 'PC Type1', 'PC Type2', 'PC Type3' ]
  color_array=['Blue','Brown','Black','Dark Green','Orange','Green']
  
  CGPS_open, title+'_Effective_area.ps',/LandScape
  CGPlot, Indgen(1001),ARfNorm, /XLog, /ylog, xstyle=1, ystyle=1, xrange=[20,1000], yrange=[0.1,500], Title='Effective Area', Xtitle='Energy (keV)', Ytitle='Area (cm^2)'
  CGOPlot, Indgen(1001),ARfNormCC, color='Brown'
  CGOPlot, Indgen(1001),ARfNormC, color='Blue'
  CgOPlot, Indgen(1001),   ArfNormPCT1, color='Dark Green'
  CgOPlot, Indgen(1001),   ArfNormPCT2, color='ORange'
  CgOPlot, Indgen(1001),   ArfNormPCT3, color='Green'
  
  ;Location=[0.93,0.9][0.01,0.89]
  CgLegend, Location=[0.93,0.9], Titles=Leg_Text, Length =0, $
    SymColors = color_array, TColors=color_array,Psyms=[1,1,1,1,1,1],/box, Charsize=0.8

  
  CgErase
  CGPlot, Indgen(1001),ARfNorm, /XLog, /ylog, xstyle=1, ystyle=1, xrange=[20,1000], yrange=[0.1,500], Title='Effective Area (PC)', Xtitle='Energy (keV)', Ytitle='Area (cm^2)'
  
  CgErase
  
  CGPlot, Indgen(1001),ARfNorm, /XLog, /ylog, xstyle=1, ystyle=1, xrange=[20,1000], yrange=[0.1,500], Title='Effective Area (PC)', Xtitle='Energy (keV)', Ytitle='Area (cm^2)'
  CgOPlot, Indgen(1001),   ArfNormPCT1, color='Dark Green'

  CgErase
  CGPlot, Indgen(1001),ARfNorm, /XLog, /ylog, xstyle=1, ystyle=1, xrange=[20,1000], yrange=[0.1,500], Title='Effective Area (PC)', Xtitle='Energy (keV)', Ytitle='Area (cm^2)'
  CgOPlot, Indgen(1001),   ArfNormPCT1, color='Dark Green'
  CgOPlot, Indgen(1001),   ArfNormPCT2, color='Orange'
  CgOPlot, Indgen(1001),   ArfNormPCT3, color='Green'

  Temp_Str = Cur+'/'+title+'_Effective_area.ps'
  CGPS_Close
  CGPS2PDF, Temp_Str,delete_ps=1




End
