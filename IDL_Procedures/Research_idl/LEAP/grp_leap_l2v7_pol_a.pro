Pro Grp_Leap_L2v7_Pol_a, fsearch_String, title=title, nfiles = nfiles, Bsize=Bsize
  Close, /all
  ; This is similar to grp leap l2v7 pol but making it generalized to see few incostistencies.
  ;  
  ;  This way, the rebinning conserves the possion statistics so rebinning needs to be done in further.
  ;
  ; The purpose of this is to get a polarization spectra for the GRAPE with ability to select certain rotation angle.
  ; LEAP is not moving and Grape is so it is not an issue.
  ;
  ; The selection bin size has to be smaller than the angles.
  ; We can have a 5 deg bins for start and to 20 deg bin if this process takes longer.
  ; the angles are 4 deg increments.
  ;
  ; We will have Source/ background data.
  ; Background will be scaled to Source with time ran and live time.
  ;
  ;First focused on getting out the plot and seeing what is being done. Then focused on getting the output file.
  ; Note the software threshold are higher than before

  True = 1
  False= 0
  
; ptitle= 'UnPol BgdCo57 r120'
 ;ptitle= 'UnPol Co57 r121'
  ptitle = 'UnPol BackCo57 r120'
  ;
  ;-- Energy Selection
  ; We might want a smaller pla and cal for statistics but lets see.
  ;
  Pla_EMin = 12.0
  Pla_EMax = 200.00

  Cal_EMin = 30.0
  Cal_EMax = 400.00

  ;Angle and Tot Pol Ener

  Rt_Ang_Min =96
  Rt_Ang_Max =96
  rtText = '_'+Strn(rt_ang_Min)+'_'+Strn(Rt_Ang_Max)
  Print, RTText
  Tot_EMin = 70.00
  Tot_EMax = 160.00

  Altitude = 131.5D

  PMax= 1500 ; Max value of energy for energy histogram.
  Cd, Cur=Cur

  IF Keyword_Set(title) Eq 0 Then Title='Test'
  IF Keyword_Set(BSize) Eq 0 Then Bsize=20


  c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration

  ;
  ;  Calorimeter element anode ids (0..63)
  ;
  Cal_anodes = [0,1,2,3,4,5,6,7,8,15,16,23,24,31,32,39,40,47,48,55,56,57,58,59,60,61,62,63]

  ;
  ;=========================================================================================
  ;
  ;  Plastic element anode Ids (0..63)
  ;
  Pls_anodes = [9,10,11,12,13,14,17,18,19,20,21,22,25,26,27,28,29,30,33,34,35,36,37,38,41, $
    42,43,44,45,46,49,50,51,52,53,54]


  ;===========
  evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
  if keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)
  Title1 =Title+'_b'+strn(Bsize)+'_N'+strn(nfiles)+rtText+'_grp_leap_pol_a'

  Mod_Lt_arr = DblArr(32)
  Mod_Lt_Cnt = LonArr(32)
  
  MOd_Sel_Cnt = LonArr(32)
  ;
  ;
  ;  Here we define the structure to hold the output L2 event data.
  ;
  Struc = {                $
    VERNO:0B,            $   ; Data format version number
    QFLAG:0,             $   ; Event quality flag
    SWEEPNO:0,           $   ; Sweep Number
    SWSTART:0.0D,        $   ; Start time of sweep
    SWTIME:0.0D,         $   ; Time since start of sweep (secs)
    EVTIME:0.0D,         $   ; Event Time (secs in gps time - from 0h UT Sunday)
    TJD:0.0D,            $   ; Truncated Julian Date

    EVCLASS:0,           $   ; Event Class (1=C, 2=CC, 3=PC, 4= intermdule)
    IMFLAG:0B,           $   ; = 1 for intermodule (2 module) event
    ACFLAG:0B,           $   ; = 1 for anticoincidence

    NANODES:0B,          $   ; Number of triggered anodes (1-8)
    NPLS:0B,             $   ; Number of triggered plastic anodes
    NCAL:0B,             $   ; Number of triggered calorimeter anodes
    EVTYPE:0,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)

    ANODEID1:0B,         $   ; Anode id 1
    ANODEID2:0B,         $   ; Anode id 2
    ANODEID3:0B,         $   ; Anode id 3
    ANODEID4:0B,         $   ; Anode id 4
    ANODEID5:0B,         $   ; Anode id 5
    ANODEID6:0B,         $   ; Anode id 6
    ANODEID7:0B,         $   ; Anode id 7
    ANODEID8:0B,         $   ; Anode id 8

    AnodeTyp1:0B,        $   ; Anode Type 1
    AnodeTyp2:0B,        $   ; Anode Type 2
    AnodeTyp3:0B,        $   ; Anode Type 3
    AnodeTyp4:0B,        $   ; Anode Type 4
    AnodeTyp5:0B,        $   ; Anode Type 5
    AnodeTyp6:0B,        $   ; Anode Type 6
    AnodeTyp7:0B,        $   ; Anode Type 7
    AnodeTyp8:0B,        $   ; Anode Type 8

    ANODENRG1:0.0,       $   ; Anode 1 Energy
    ANODENRG2:0.0,       $   ; Anode 2 Energy
    ANODENRG3:0.0,       $   ; Anode 3 Energy
    ANODENRG4:0.0,       $   ; Anode 4 Energy
    ANODENRG5:0.0,       $   ; Anode 5 Energy
    ANODENRG6:0.0,       $   ; Anode 6 Energy
    ANODENRG7:0.0,       $   ; Anode 7 Energy
    ANODENRG8:0.0,       $   ; Anode 8 Energy

    AnodeSig1:0.0,       $   ; Anode 1 Energy Error
    AnodeSig2:0.0,       $   ; Anode 1 Energy Error
    AnodeSig3:0.0,       $   ; Anode 1 Energy Error
    AnodeSig4:0.0,       $   ; Anode 1 Energy Error
    AnodeSig5:0.0,       $   ; Anode 1 Energy Error
    AnodeSig6:0.0,       $   ; Anode 1 Energy Error
    AnodeSig7:0.0,       $   ; Anode 1 Energy Error
    AnodeSig8:0.0,       $   ; Anode 1 Energy Error

    PA_MOD:0,            $   ; Primary Anode Module Position No.
    PA_SER:0,            $   ; Primary Anode Module Serial No.
    PA_ID:0,             $   ; Primary Anode No.
    PA_NRG:0.0,          $   ; Primary Anode Energy (keV)
    PA_SIG:0.0,          $   ; Primary Anode Energy Uncertainty (keV)

    SA_MOD:0,            $   ; Secondary Anode Module Position No.
    SA_SER:0,            $   ; Secondary Anode Module Serial No.
    SA_ID:0,             $   ; Secondary Anode No.
    SA_NRG:0.0,          $   ; Secondary Anode Energy (keV)
    SA_SIG:0.0,          $   ; Secondary Anode Energy Uncertainty (keV)

    TOTNRG:0.0,          $   ; Total Event Energy (keV)
    TOTSIG:0.0,          $   ; Total Event Energy Uncertainty (keV)

    COMPANG:0.0,         $   ; Caluculated Compton Scatter Angle (deg)
    COMPSIG:0.0,         $   ; Compton Scatter Angle Uncertainty (deg)

    LAT:0.0,             $   ; Latitude (degs)
    LON:0.0,             $   ; Longitude (degs)
    ALT:0.0,             $   ; Altitude (feet)
    DEPTH:0.0,           $   ; Atm Depth (g cm^-2)
    SOURCE:0B,           $
    AIRMASS:0.0,         $
    PNTAZI:0.0,          $   ; Pointing Azimuth (degs)
    PNTZEN:0.0,          $   ; Pointing Zenith (degs)
    SRCAZI:0.0,          $
    SRCZEN:0.0,          $
    SRCOFF:0.0,          $

    RTANG:0.0,           $   ; Rotation Table Angle (degs)
    RTSTAT:0B,           $   ; Rotation Table Status
    SCTANG:0.0,          $   ; Scatter Angle in instrument coords (degs)
    PVANG:0.0,           $   ; Scatter Angle in pressure vessel coords (degs)
    PPVANG:0.0,          $   ; Scatter Angle in projected PV coords (degs)
    HRANG:0.0,           $   ; Hour Angle (degs)
    PARANG:0.0,          $   ; Paralactic Angle (degs)
    POSANG:0.0,          $   ; Position angle of the scatter vector (deg)

    LIVETIME:0.0,        $
    CORRECTLT:0.0        $
  }
  ;Total 248 Bytes

  Packet_Len = 248 ; In Bytes
  ;
  ;------
  ;

  Rot_ang = FltArr(1);
  Sel_Scat_Angle = FltArr(1)
  Pv_Angle = FltArr(1)
  sel_pvAng = FltArr(1)
  Tot_Nrg = FltARr(1)
  Tot_Nrg_Full = FltArr(1)
  ; The first value is going to be 0 so we have to be careful of getting rid of it.
  P0_Arr  = DBLArr(1)


  ;=== ENERGY ===
  P0_EArr  = FltArr(1)

  Lt_Count = 0L

  Tot_LiveTime = 0.0D
  Tot_Time = 0.0D
  
    LT_Count_Ener=0L
    Tot_LiveTime_Ener = 0.0D
    Tot_Time_Ener = 0.0D
  For p = 0, nfiles-1 Do Begin ; open each file
    fname = evtfiles[p]
    print, fname

    ; Open file, read file into structuures and close the file
    f = file_info(fname)
    Openr, lun, fname, /GET_Lun
    TotPkt = long(f.size/Packet_Len)
    Event_data = replicate(Struc, TotPkt)
    For i = 0, TotPkt-1 Do Begin
      readu, lun, Struc        ; read one event
      Event_data[i] =Struc        ; add it to input array
    EndFor
    Free_Lun, lun
    Print, TotPkt

    a = 0L
    b = 0L
    ;-- Per Event

    For i = 0, TotPkt-1 Do Begin
      data = Event_data[i]
      m = data.pa_mod
      
      b++
      If b eq 1 then StartTime_Ener = data.evtime
      EndTime_Ener = data.evtime

      
      LT_Count_Ener++
      Mod_Lt_Arr[m] = Mod_Lt_Arr[m]+data.CorrectLT
      Mod_LT_Cnt[m]++
      Tot_LiveTime_Ener =   Tot_LiveTime_Ener+data.CorrectLT

      ; Selection
      ; This is for the live time and start and end time. This is property of the module so it has to be for all
      ;
      If ( data.rtang GE Rt_Ang_min ) and (data.rtang LE RT_Ang_max) Then begin
      ; print, data.rtang
        a++
        If a eq 1 then StartTime = data.evtime

        Tot_Livetime = Tot_liveTime+ data.CorrectLT
        LT_Count++
        EndTime = data.evtime
      EndIf
      
      If data.EvClass NE 3 Then goto, Jump_Packet
      If data.Nanodes NE 2 Then goto, Jump_Packet
      If data.qflag NE 10 Then goto, Jump_Packet
      If data.evtype NE 1 Then goto, Jump_Packet


    
    
      ;ENERGY SELECITON
      ;-- NOTE: WE are not refiguring out the events and reclassifying .
      ;We are ignoring the events that violate energy thresholds
      ;We are reducing the statistics this way.
      ;----
      PA = Event_Data[i].pa_id
      If AnodeType(PA) EQ 0 Then Begin
        If (Event_Data[i].pa_nrg LT Cal_EMin) OR (Event_Data[i].pa_nrg GT Cal_EMax) Then Goto, Jump_Packet
      Endif Else If AnodeType(PA) EQ 1 Then Begin
        If (Event_Data[i].pa_nrg LT Pla_EMin) OR (Event_Data[i].pa_nrg GT Pla_EMax) Then Goto, Jump_Packet
      Endif

      SA = Event_Data[i].sa_id
      If AnodeType(SA) EQ 0 Then Begin
        If (Event_Data[i].sa_nrg LT Cal_EMin) OR (Event_Data[i].sa_nrg GT Cal_EMax) Then Goto, Jump_Packet
      Endif Else If AnodeType(SA) EQ 1 Then Begin
        If (Event_Data[i].sa_nrg LT Pla_EMin) OR (Event_Data[i].sa_nrg GT Pla_EMax) Then Goto, Jump_Packet
      Endif
      ;----
      ; TotNRg_all = [TotNrg_all, data.totnrg]

      ;--- Tot Energy Selection
      Tot_Energy = data.totnrg
      Tot_NRg_Full = [Tot_Nrg_Full,Tot_Energy]
      If (data.totnrg LT tot_EMIN) or (data.totnrg GT tot_EMAX) then goto, Jump_PAcket

      ;PV Angle for sanity checks.
      Pv_Angle = [Pv_Angle,data.pvang]
      Tot_Nrg = [Tot_nrg, Tot_Energy]
      ; Rotation angle selection
      If ( data.rtang LT Rt_Ang_min ) Or (data.rtang GT RT_Ang_max) Then Goto, Jump_Packet

  ;    print, data.rtstat, data.rtang
      Rot_ang = [Rot_Ang,data.rtang]
   ;   Print, data.rtang, '**'
  ;    print, n_elements(rot_ang)
      Sel_PVAng =[ Sel_PvAng, data.pvang]
      Sel_scat_angle = [Sel_Scat_Angle,data.sctang]
      MOd_Sel_Cnt[m]++
      ; Print, Event_data[i].RtAng
      Jump_Packet:
   ;   If i mod 10000 EQ 0 Then print, i
    EndFor; /i
;    window,0
;    CgPlot, Event_data[where( (Event_Data.evClass eq 3) and (Event_Data.qflag eq 10))].sctang, psym=1
;    window,1
;    CgPlot,Event_data[where( (Event_Data.evClass eq 3) and (Event_Data.qflag eq 10))].EvTime, Event_data[where( (Event_Data.evClass eq 3) and (Event_Data.qflag eq 10))].rtang, psym=1, title='Rt Ang'
;    window,2
;    CgPlot, Event_Data.swtime,Event_data.rtstat, psym=1
;
;Print,data.swstart, '****'


    Sel_Scat_Angle = Sel_Scat_Angle[1:N_Elements(Sel_Scat_Angle)-1]
    Tot_nrg = Tot_nrg[1:N_Elements(Tot_Nrg)-1]
    Tot_NRg_Full = Tot_Nrg_Full[1:N_elements(Tot_Nrg_Full)-1]
    Rot_Ang = Rot_Ang[1:N_Elements(Rot_Ang)-1]
    Pv_Angle =Pv_Angle[1:N_Elements(Pv_Ang)-1]
    Sel_PVANg = Sel_PvAng[1:N_Elements(Sel_PvAng)-1]
    
    T_Rot_Ang = CgHistogram(Rot_Ang, Min=0, max=360, Binsize=1,locations=X0)
    T_Scat_hist = CgHistogram(Sel_Scat_Angle,Min=0,Max=360,BinSize=BSize,Locations=X1)
 ;   T_Scat_hist1= CgHistogram(Sel_Scat_Angle, Min=0, Max=360, Binsize=20,Locations=X11)
    T_Tot_Nrg = CgHistogram(Tot_nrg,Min=0,Max=500,BinSize=5,Locations=X2)    
    T_tot_nrg_Full = CgHistogram(Tot_Nrg_Full,Min=0,Max=500,Binsize=5,Locations=X2)
    T_Pv_Ang = CgHistogram(Pv_Angle, Min=0, max=360, Binsize=BSize,locations=X3)
    T_SPV_Ang = CgHistogram(Sel_PVang, Min=0, Max=360, Binsize=BSize, Locations =X4)
    
    If p eq 0 Then Scat_Hist = T_Scat_Hist Else Scat_Hist= Scat_Hist + T_Scat_Hist
  ;  If p eq 0 Then Scat_Hist1 = T_Scat_Hist1 Else Scat_Hist1= Scat_Hist1 + T_Scat_Hist1

    If p eq 0 Then Ener_Hist = T_Tot_Nrg Else Ener_Hist= Ener_Hist + T_Tot_Nrg
    If p eq 0 Then TotEner_Hist = T_Tot_Nrg_Full Else TotEner_Hist= TotEner_Hist + T_Tot_Nrg_Full
    If p eq 0 Then Rot_Hist = T_Rot_Ang Else Rot_Hist= Rot_hist+ T_Rot_Ang

    If p eq 0 Then PV_Hist = T_PV_Ang Else PV_Hist= PV_hist+ T_PV_Ang
    If p eq 0 Then SPV_Hist = T_sPV_Ang Else sPV_Hist= sPV_hist+ T_sPV_Ang

    ; Now we scale and add.
    Temp_time = ENdTime-StartTime
    Temp_Time_Ener = EndTIme_Ener- StartTime_Ener
    if temp_time lt 0 then begin
      CGPLot, event_Data.evtime
      stop
    endif
 ;   CGPLot, event_Data.evtime
    Tot_Time = tot_time+Temp_Time
    
    Tot_Time_Ener =Tot_time_Ener + Temp_Time_Ener
    Print, Temp_Time,'Temp_Time', Temp_Time_Ener

    Print, Tot_liveTime, LT_Count
    
    Print, 'No of Files Left :' + strn(Nfiles-p-1)
;    CgPlot, Event_data.CorrectLT, Yrange=[0.9,1], title=ptitle
 ;   Stop
  EndFor; /p
 
  ;Tot_Time = tot_time+Temp_Time
;  Print, Tot_liveTime, LT_Count, Tot_Time

  AvgLT = Tot_livetime/ LT_Count 
  AvgLT_Ener = Tot_livetime_Ener/LT_Count_Ener++
  Print, 'Avglt:', AvgLT
  True_Time = Double(Tot_Time* AvgLT)
  True_Time_Ener = Double(Tot_Time_Ener* AvgLT_Ener)
; print, title1
; help, title1
    CgPs_Open, title1+'.ps', Font =1, /LandScape
    cgLoadCT, 13
;  
;    CgPlot, Indgen(N_Elements(Rot_Angle), /LONG), Rot_Angle, Title=' Table Angle Variation',Ytitle=' Table Angle ', XTitle='Event No'
;    CgErase
;  
;    CgPlot, Indgen(N_Elements(Sel_Scat_Angle), /LONG), Sel_Scat_Angle, Title=' Scat Angle',Ytitle=' Angle ', XTitle='Event No'
;    CgErase
    
    halfXVal = X1[1]/2
    halfXarr = fltarr(N_Elements(x1))*0+halfXval
    halfX1 = X1+ halfXVal

;    CgPlot, halfX11, Scat_HIst1,Title=' Sel Scat Angle (BSize =20)',Ytitle=' Counts', XTitle='Angle', XTICKINTERVAL=20, PSYM=10, XRANGE=[0,360];, Err_Xhigh=halfXarr, Err_Xlow = halfXarr
;    PRint, Scat_Hist1
;    PRint, halfX11
;    CgErase
    CgPlot, halfX1, Scat_HIst,Title=ptitle+' Sel Scat Angle (Bsize='+STRN(FIX(BSiZE))+')',Ytitle=' Counts', XTitle='Angle', PSYm=10,$
                XRANGE=[0,360], Err_Xhigh=halfXarr, Err_Xlow = halfXarr, Err_WIDTH=0, XTICKINTERVAL=40
    Cgerase
    
    Cgplot,halfX1, SPV_Hist, title =' Rotated Sel PvAngle', ytitle='COunts', xtitle='Angle', PSYM=10, XRANGE=[0,360],XTICKINTERVAL=40,Err_Xhigh=halfXarr, Err_Xlow = halfXarr
    Cgerase
Print, Scat_Hist
Print
Print, total(Scat_Hist)
Print
Print, SPV_HIST
print
Print, Total(SPV_HIST)
    CgPlot, X3, PV_Hist, title =' Rotated PV Angle', ytitle='Counts', Xtitle='Angle',PSYM=10
    Cgerase
    
    CgPlot, X2, TotEner_Hist, title='All Energy', ytitle='Counts', Xtitle='Energy', PSYM=10
  
    CgOPlot, X2, Ener_Hist, PSYM= 10, Color='Red'
    CgErase
    
    CGplot, X0, Rot_Hist, title='Rot Angle valid', Xtitle='Angle', Ytitle='Counts', PSYM=10
    CgPs_Close
  
    ;  -- Create the PDF File
    Temp_Str = Cur+'/'+Title1+'.ps'
    CGPS2PDF, Temp_Str,delete_ps=1
  PRint
  Print, Mod_Lt_Arr
  Print
  Print, Mod_Lt_Cnt
  Print
  Print, MOd_Sel_Cnt
  print
  for i = 0, 31 do if Mod_lt_Cnt[i] NE 0 Then Print, i, Double(mod_lt_Arr[i])/double(Mod_lt_Cnt[i])
  
  Scat_hist_Err = Sqrt(Scat_hist)
  Openw, Lun, Title1+'_SelScat.txt', /Get_lun
  Printf,lun, 'Time ='+Strn(True_Time)
  Printf,lun, 'Angle Selection:'+strn(Rt_Ang_Min)+ ' , ' + Strn(Rt_Ang_Max)

  For i = 0, N_Elements(Scat_Hist)-2 Do begin
    Printf,lun, halfX1[i], Scat_Hist[i], Scat_hist_Err[i]
  EndFor
  Free_lun, lun
  
  TotEner_Hist_Err = Sqrt(TotENer_Hist)
  Openw, Lun1, Title1+'_TotEner.txt', /Get_lun
  Printf,lun1, 'Time ='+Strn(True_Time_ENer)
  For i = 0, N_Elements(TotEner_Hist)-1 Do begin
    Printf,lun1, X2[i], TotEner_Hist[i], TotEner_Hist_Err[i]
  EndFor
  Free_lun, lun1
  ;

End