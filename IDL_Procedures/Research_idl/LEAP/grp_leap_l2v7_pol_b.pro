Pro Grp_Leap_L2v7_Pol_b, fsearch_String, title=title, nfiles = nfiles, Bsize=Bsize
  Close, /all
  ; This is similar to grp leap l2v7 pol _a but making it generalized to see few incostistencies.
  ; Just to track few issues with energy
  ;
  True = 1
  False= 0

  ptitle = Title+' Energy Plot'
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
  Title1 =Title+'_b'+strn(Bsize)+'_N'+strn(nfiles)+rtText+'_grp_leap_pol_b'

  
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


  Mod_Lt_arr = DblArr(32)
  Mod_Lt_Cnt = LonArr(32)

  MOd_Sel_Cnt = LonArr(32)

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
  ;  Print, TotPkt

   
    b = 0L
    ;-- Per Event

    For i = 0, TotPkt-1 Do Begin
      data = Event_data[i]
      m = data.pa_mod


      If data.qflag LT 0 Then goto, Jump_Packet
      If (data.rtstat LT 5) Or (data.rtstat GT 7) then begin
              Print,data.rtstat,'@@@@', data.rtang,':::',data.swtime, '****', data.evtime
        goto, jump_packet
      endif

      ;stop
      ;print, data.rtstat

      b++
      If b eq 1 then StartTime_Ener = double(data.evtime)
      EndTime_Ener = double(data.evtime)
      
      If data.EvClass NE 3 Then goto, Jump_Packet
      If data.Nanodes NE 2 Then goto, Jump_Packet
      If data.qflag NE 10 Then goto, Jump_Packet           
      If data.evtype NE 1 Then goto, Jump_Packet
    


      LT_Count_Ener++
      Mod_Lt_Arr[m] = Mod_Lt_Arr[m]+data.CorrectLT
      Mod_LT_Cnt[m]++
      Tot_LiveTime_Ener =   Tot_LiveTime_Ener+data.CorrectLT
        
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
      
      ;--- Tot Energy Selection
      Tot_Energy = data.totnrg
      Tot_NRg_Full = [Tot_Nrg_Full,Tot_Energy]

MOd_Sel_Cnt[m]++
      Jump_Packet:
    ;  If i mod 10000 EQ 0 Then print, i
    EndFor; /i

    Tot_NRg_Full = Tot_Nrg_Full[1:N_elements(Tot_Nrg_Full)-1]
    T_tot_nrg_Full = CgHistogram(Tot_Nrg_Full,Min=0,Max=500,Binsize=5,Locations=X2)
    If p eq 0 Then TotEner_Hist = T_Tot_Nrg_Full Else TotEner_Hist= TotEner_Hist + T_Tot_Nrg_Full

    Temp_Time_Ener = EndTIme_Ener- StartTime_Ener
    if temp_time_ener lt 0 then begin
     
      Print, StartTime_Ener ,EndTIme_Ener
      Print, MIn(Event_Data.evtime), MAx(Event_data.evtime)
      PRint, Min(event_Data.swtime), Max(event_Data.Swtime)
      CGPLot, event_Data.evtime, yrange=[min(Event_Data.evtime),Max(Event_Data.evtime)]
      window,2
      CGPLot, Event_Data.swtime
      Window,3 
      CgPlot, Event_Data.rtstat
      stop
    endif
 ;   CgPlot, event_data.evtime

    Tot_Time_Ener =Tot_time_Ener + Temp_Time_Ener
    Print,'Temp_Time', Temp_Time_Ener

    Print, 'No of Files Left :' + strn(Nfiles-p-1)
  EndFor; /p

  AvgLT_Ener = Tot_livetime_Ener/LT_Count_Ener
  True_Time_Ener = Double(Tot_Time_Ener* AvgLT_Ener)
  CgPs_Open, title1+'.ps', Font =1, /LandScape
  cgLoadCT, 13

  halfXVal = X2[1]/2
  halfXarr = fltarr(N_Elements(x2))*0+halfXval
  halfX1 = X2+ halfXVal

  CgPlot, X2, TotEner_Hist, title=ptitle, ytitle='Counts', Xtitle='Energy', PSYM=10
  CgPs_Close

  ;  -- Create the PDF File
  Temp_Str = Cur+'/'+Title1+'.ps'
  CGPS2PDF, Temp_Str,delete_ps=1
  PRint
  Print, Mod_Lt_Arr
  Print,'****'
  Print, Mod_Lt_Cnt
  Print,'***'
  print,  MOd_Sel_Cnt
  Print,'66666'
  for i = 0, 31 do if Mod_lt_Cnt[i] NE 0 Then Print, i, Double(mod_lt_Arr[i])/double(Mod_lt_Cnt[i])


  TotEner_Hist_Err = Sqrt(TotENer_Hist)
  Openw, Lun1, Title1+'_TotEner.txt', /Get_lun
  Printf,lun1, 'Time ='+Strn(True_Time_ENer)
  For i = 0, N_Elements(TotEner_Hist)-1 Do begin
    Printf,lun1, X2[i], TotEner_Hist[i], TotEner_Hist_Err[i]
  EndFor
  Free_lun, lun1
  ;

End