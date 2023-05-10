Pro Grp_Leap_L2v7_Pol_E, fsearch_String, title=title
  Close, /all
  
  ; Child of Grp_leap_l2v7_Pol
  ; This is just for energy but per sweep. Get LT. Time Ran. Get effective time. Change to T/s and get it back to effective time?
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

  ;
  ;-- Energy Selection
  ; We might want a smaller pla and cal for statistics but lets see.
  ;
  Pla_EMin = 12.0
  Pla_EMax = 200.00

  Cal_EMin = 30.0
  Cal_EMax = 400.00

  ;Angle and Tot Pol Ener

  Rt_Ang_Min = 96
  Rt_Ang_Max = 96

  Tot_EMin = 50.00
  Tot_EMax = 500.00

  Altitude = 131.5D

  PMax= 1500 ; Max value of energy for energy histogram.
  Cd, Cur=Cur

  IF Keyword_Set(title) Eq 0 Then Title='Test'

  Title1 =Title+'_grp_leap_pol'

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

  Old_Time = 0L
  Spec_Old_Time = 0L


  Rot_angle = FltArr(1);
  Sel_Scat_Angle = FltArr(1)
  Pv_Angle = FltArr(1)
  TotNrg_all = FltARr(1)

  ; The first value is going to be 0 so we have to be careful of getting rid of it.
  P0_Arr  = DBLArr(1)
  P2_Arr  = DBLArr(1)
  P3_Arr  = DBLArr(1)
  P4_Arr  = DBLArr(1)
  P6_Arr  = DBLArr(1)
  P7_Arr  = DBLArr(1)
  P9_Arr  = DBLArr(1)
  P10_Arr = DBLArr(1)
  P11_Arr = DBLArr(1)
  P12_Arr = DBLArr(1)
  P13_Arr = DBLArr(1)
  P14_Arr = DBLArr(1)
  P17_Arr = DBLArr(1)
  P18_Arr = DBLArr(1)
  P19_Arr = DBLArr(1)
  P20_Arr = DBLArr(1)
  P21_Arr = DBLArr(1)
  P22_Arr = DBLArr(1)
  P24_Arr = DBlArr(1)
  P25_Arr = DBlArr(1)
  P27_Arr = dblArr(1)
  P28_Arr = dBLArr(1)
  P29_Arr = DBLArr(1)
  P31_Arr = DBLArr(1)

  ;=== ENERGY ===
  P0_EArr  = FltArr(1)
  P2_EArr  = FltArr(1)
  P3_EArr  = FltArr(1)
  P4_EArr  = FltArr(1)
  P6_EArr  = FltArr(1)
  P7_EArr  = FltArr(1)
  P9_EArr  = FltArr(1)
  P10_EArr = FltArr(1)
  P11_EArr = FltArr(1)
  P12_EArr = FltArr(1)
  P13_EArr = FltArr(1)
  P14_EArr = FltArr(1)
  P17_EArr = FltArr(1)
  P18_EArr = FltArr(1)
  P19_EArr = FltArr(1)
  P20_EArr = FltArr(1)
  P21_EArr = FltArr(1)
  P22_EArr = FltArr(1)
  P24_EArr = FltArr(1)
  P25_EArr = FltArr(1)
  P27_EArr = FltArr(1)
  P28_EArr = FltArr(1)
  P29_EArr = FltArr(1)
  P31_EArr = FltArr(1)

  Tot_Time = 0.0D
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

    LT_Array = DblArr(32)
    LT_Count = DblArr(32)

    a = 0
    ;-- Per Event

    For i = 0, TotPkt-1 Do Begin
      data = Event_data[i]

      If data.qflag LT 0 Then goto, Jump_Packet
      If (data.rtstat LT 5) Or (data.rtstat GT 7) then begin
        Print,data.rtstat,'@@@@', data.rtang,':::',data.swtime, '****', data.evtime
        goto, jump_packet
      endif
      a++
      If a eq 1 then StartTime = data.evtime
      EndTime = data.evtime
         
      ; Selection
      If data.EvClass NE 3 Then goto, Jump_Packet
      If data.Nanodes NE 2 Then goto, Jump_Packet
      If data.qflag NE 10 Then goto, Jump_Packet
      If data.evtype NE 1 Then goto, Jump_Packet

      m = data.Pa_Mod
      Mod_Pos = m
      LiveTime = Data.CorrectLT

      LT_Array[m] = LT_Array[m]+LiveTime
      LT_Count[m]++

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
      If (data.totnrg LT tot_EMIN) or (data.totnrg GT tot_EMAX) then goto, Jump_PAcket Else Begin
        If Mod_Pos EQ 0 Then P0_EArr  = [P0_EArr,Tot_Energy]
        If Mod_Pos EQ 2 Then P2_EArr  = [P2_EArr,Tot_Energy]
        If Mod_Pos EQ 3 Then P3_EArr  = [P3_EArr,Tot_Energy]
        If Mod_Pos EQ 4 Then P4_EArr  = [P4_EArr,Tot_Energy]
        If Mod_Pos EQ 6 Then P6_EArr  = [P6_EArr,Tot_Energy]
        If Mod_Pos EQ 7 Then P7_EArr  = [P7_EArr,Tot_Energy]
        If Mod_Pos EQ 9 Then P9_EArr  = [P9_EArr,Tot_Energy]
        If Mod_Pos EQ 10 Then P10_EArr = [P10_EArr,Tot_Energy]

        If Mod_Pos EQ 11 Then P11_EArr = [P11_EArr,Tot_Energy]
        If Mod_Pos EQ 12 Then P12_EArr = [P12_EArr,Tot_Energy]
        If Mod_Pos EQ 13 Then P13_EArr = [P13_EArr,Tot_Energy]
        If Mod_Pos EQ 14 Then P14_EArr = [P14_EArr,Tot_Energy]
        If Mod_Pos EQ 17 Then P17_EArr = [P17_EArr,Tot_Energy]
        If Mod_Pos EQ 18 Then P18_EArr = [P18_EArr,Tot_Energy]
        If Mod_Pos EQ 19 Then P19_EArr = [P19_EArr,Tot_Energy]
        If Mod_Pos EQ 20 Then P20_EArr = [P20_EArr,Tot_Energy]

        If Mod_Pos EQ 21 Then P21_EArr = [P21_EArr,Tot_Energy]
        If Mod_Pos EQ 22 Then P22_EArr = [P22_EArr,Tot_Energy]
        If Mod_Pos EQ 24 Then P24_EArr = [P24_EArr,Tot_Energy]
        If Mod_Pos EQ 25 Then P25_EArr = [P25_EArr,Tot_Energy]
        If Mod_Pos EQ 27 Then P27_EArr = [P27_EArr,Tot_Energy]
        If Mod_Pos EQ 28 Then P28_EArr = [P28_EArr,Tot_Energy]
        If Mod_Pos EQ 29 Then P29_EArr = [P29_EArr,Tot_Energy]
        If Mod_Pos EQ 31 Then P31_EArr = [P31_EArr,Tot_Energy]

      EndElse

;      ;PV Angle for sanity checks.
;      Pv_Angle = [Pv_Angle,data.pvang]
;
;      ; Rotation angle selection
;      If ( data.rtang LT Rt_Ang_min ) Or (data.rtang GT RT_Ang_max) Then Goto, Jump_Packet

;
;
;      scat = data.sctang
;      If Mod_Pos EQ 0 Then P0_Arr  = [P0_Arr,scat]
;      If Mod_Pos EQ 2 Then P2_Arr  = [P2_Arr,scat]
;      If Mod_Pos EQ 3 Then P3_Arr  = [P3_Arr,scat]
;      If Mod_Pos EQ 4 Then P4_Arr  = [P4_Arr,scat]
;      If Mod_Pos EQ 6 Then P6_Arr  = [P6_Arr,scat]
;      If Mod_Pos EQ 7 Then P7_Arr  = [P7_Arr,scat]
;      If Mod_Pos EQ 9 Then P9_Arr  = [P9_Arr,scat]
;      If Mod_Pos EQ 10 Then P10_Arr = [P10_Arr,scat]
;
;      If Mod_Pos EQ 11 Then P11_Arr = [P11_Arr,scat]
;      If Mod_Pos EQ 12 Then P12_Arr = [P12_Arr,scat]
;      If Mod_Pos EQ 13 Then P13_Arr = [P13_Arr,scat]
;      If Mod_Pos EQ 14 Then P14_Arr = [P14_Arr,scat]
;
;      If Mod_Pos EQ 17 Then P17_Arr = [P17_Arr,scat]
;      If Mod_Pos EQ 18 Then P18_Arr = [P18_Arr,scat]
;      If Mod_Pos EQ 19 Then P19_Arr = [P19_Arr,scat]
;      If Mod_Pos EQ 20 Then P20_Arr = [P20_Arr,scat]
;
;      If Mod_Pos EQ 21 Then P21_Arr = [P21_Arr,scat]
;      If Mod_Pos EQ 22 Then P22_Arr = [P22_Arr,scat]
;      If Mod_Pos EQ 24 Then P24_Arr = [P24_Arr,scat]
;      If Mod_Pos EQ 25 Then P25_Arr = [P25_Arr,scat]
;      If Mod_Pos EQ 27 Then P27_Arr = [P27_Arr,scat]
;      If Mod_Pos EQ 28 Then P28_Arr = [P28_Arr,scat]
;      If Mod_Pos EQ 29 Then P29_Arr = [P29_Arr,scat]
;      If Mod_Pos EQ 31 Then P31_Arr = [P31_Arr,scat]


      ; Print, Event_data[i].RtAng
      Jump_Packet:
      If i mod 10000 EQ 0 Then print, i
    EndFor; /i

;    ;-- Concat the Array --
    If N_elements(P0_EArr) NE 1 then P0_EArr =P0_EArr[1:N_Elements(P0_EArr)-1] Else P0_EArr=[-1.0]
    If N_elements(P2_EArr) NE 1 then P2_EARR =P2_EArr[1:N_Elements(P2_EArr)-1] Else P2_EArr=[-1.0]
    If N_elements(P3_EArr) NE 1 then P3_EARR =P3_EArr[1:N_Elements(P3_EArr)-1] Else P3_EArr=[-1.0]
    If N_elements(P4_EArr) NE 1 then P4_EARR =P4_EArr[1:N_Elements(P4_EArr)-1] Else P4_EArr=[-1.0]
    If N_elements(P6_EArr) NE 1 then P6_EARR =P6_EArr[1:N_Elements(P6_EArr)-1] Else P6_EArr=[-1.0]
    If N_elements(P7_EArr) NE 1 then P7_EARR =P7_EArr[1:N_Elements(P7_EArr)-1] Else P7_EArr=[-1.0]
    If N_elements(P9_EArr) NE 1 then P9_EARR =P9_EArr[1:N_Elements(P9_EArr)-1] Else P9_EArr=[-1.0]

    If N_elements(P10_EArr) NE 1 then P10_EARR =P10_EArr[1:N_Elements(P10_EArr)-1] Else P10_EArr=[-1.0]
    If N_elements(P11_EArr) NE 1 then P11_EARR =P11_EArr[1:N_Elements(P11_EArr)-1] Else P11_EArr=[-1.0]
    If N_elements(P12_EArr) NE 1 then P12_EARR =P12_EArr[1:N_Elements(P12_EArr)-1] Else P12_EArr=[-1.0]
    If N_elements(P13_EArr) NE 1 then P13_EARR =P13_EArr[1:N_Elements(P13_EArr)-1] Else P13_EArr=[-1.0]
    If N_elements(P14_EArr) NE 1 then P14_EARR =P14_EArr[1:N_Elements(P14_EArr)-1] Else P14_EArr=[-1.0]
    If N_elements(P17_EArr) NE 1 then P17_EARR =P17_EArr[1:N_Elements(P17_EArr)-1] Else P17_EArr=[-1.0]
    If N_elements(P18_EArr) NE 1 then P18_EARR =P18_EArr[1:N_Elements(P18_EArr)-1] Else P18_EArr=[-1.0]
    If N_elements(P19_EArr) NE 1 then P19_EARR =P19_EArr[1:N_Elements(P19_EArr)-1] Else P19_EArr=[-1.0]

    If N_elements(P20_EArr) NE 1 then P20_EARR =P20_EArr[1:N_Elements(P20_EArr)-1] Else P20_EArr=[-1.0]
    If N_elements(P21_EArr) NE 1 then P21_EARR =P21_EArr[1:N_Elements(P21_EArr)-1] Else P21_EArr=[-1.0]
    If N_elements(P22_EArr) NE 1 then P22_EARR =P22_EArr[1:N_Elements(P22_EArr)-1] Else P22_EArr=[-1.0]
    If N_elements(P24_EArr) NE 1 then P24_EARR =P24_EArr[1:N_Elements(P24_EArr)-1] Else P24_EArr=[-1.0]
    If N_elements(P25_EArr) NE 1 then P25_EARR =P25_EArr[1:N_Elements(P25_EArr)-1] Else P25_EArr=[-1.0]
    If N_elements(P27_EArr) NE 1 then P27_EARR =P27_EArr[1:N_Elements(P27_EArr)-1] Else P27_EArr=[-1.0]
    If N_elements(P28_EArr) NE 1 then P28_EARR =P28_EArr[1:N_Elements(P28_EArr)-1] Else P28_EArr=[-1.0]
    If N_elements(P29_EArr) NE 1 then P29_EARR =P29_EArr[1:N_Elements(P29_EArr)-1] Else P29_EArr=[-1.0]
    If N_elements(P31_EArr) NE 1 then P31_EARR =P31_EArr[1:N_Elements(P31_EArr)-1] Else P31_EArr=[-1.0]


;    ;-- Histogram it
    Pol_0 = CgHistogram(P0_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_2 = CgHistogram(P2_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_3 = CgHistogram(P3_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_4 = CgHistogram(P4_EArr, Min=0, Max=500, BinSize=5,Locations=X1)
    Pol_6 = CgHistogram(P6_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_7 = CgHistogram(P7_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_9 = CgHistogram(P9_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_10 = CgHistogram(P10_EArr,Min=0, Max=500, BinSize=5, Locations=X1)

    Pol_11 = CgHistogram(P11_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_12 = CgHistogram(P12_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_13 = CgHistogram(P13_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_14 = CgHistogram(P14_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_17 = CgHistogram(P17_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_18 = CgHistogram(P18_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_19 = CgHistogram(P19_EArr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_20 = CgHistogram(P20_EArr, Min=0, Max=500, BinSize=5, Locations=X1)

    Pol_21 = CgHistogram(P21_Arr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_22 = CgHistogram(P22_Arr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_24 = CgHistogram(P24_Arr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_25 = CgHistogram(P25_Arr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_27 = CgHistogram(P27_Arr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_28 = CgHistogram(P28_Arr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_29 = CgHistogram(P29_Arr, Min=0, Max=500, BinSize=5, Locations=X1)
    Pol_31 = CgHistogram(P31_Arr, Min=0, Max=500, BinSize=5, Locations=X1)

    ; Now we scale and add.
    Temp_time = ENdTime-StartTime
    if temp_time lt 0 then begin
      CGPLot, event_Data.evtime
      stop
    endif
    Tot_Time = tot_time+Temp_Time
    Print, Temp_Time,'Temp_Time'

    Tot_Count = FltArr(N_Elements(Pol_31))
    Tot_ERr   = Tot_Count
    Empty_Count = Tot_Count
    AvgLT_Arr = dblArr(32)
    for j = 0,31 do if lt_count[j] ne 0 then  AvgLT_arr[j] = lt_array[j]/lt_count[j]

    ;Mod0
    If AvgLt_arr[0] NE 0 Then begin
      tempCnt = Pol_0/(AvgLt_arr[0]*Temp_Time)
      Temp_Err = TempCnt
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod2
    If AvgLt_arr[2] NE 0 Then begin
      tempCnt = Pol_2/(AvgLt_arr[2]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod3
    If AvgLt_arr[3] NE 0 Then begin
      tempCnt = Pol_3/(AvgLt_arr[3]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod4
    If AvgLt_arr[4] NE 0 Then begin
      tempCnt = Pol_4/(AvgLt_arr[4]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod6
    If AvgLt_arr[6] NE 0 Then begin
      tempCnt = Pol_6/(AvgLt_arr[6]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod7
    If AvgLt_arr[7] NE 0 Then begin
      tempCnt = Pol_7/(AvgLt_arr[7]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err


    ;Mod9
    If AvgLt_arr[9] NE 0 Then begin
      tempCnt = Pol_9/(AvgLt_arr[9]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err


    ;Mod10
    If AvgLt_arr[10] NE 0 Then begin
      tempCnt = Pol_10/(AvgLt_arr[10]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod11
    If AvgLt_arr[11] NE 0 Then begin
      tempCnt = Pol_11/(AvgLt_arr[11]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod12
    If AvgLt_arr[12] NE 0 Then begin
      tempCnt = Pol_12/(AvgLt_arr[12]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod13
    If AvgLt_arr[13] NE 0 Then begin
      tempCnt = Pol_13/(AvgLt_arr[13]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err


    ;Mod14
    If AvgLt_arr[14] NE 0 Then begin
      tempCnt = Pol_14/(AvgLt_arr[14]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod17
    If AvgLt_arr[17] NE 0 Then begin
      tempCnt = Pol_17/(AvgLt_arr[17]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err


    ;Mod18
    If AvgLt_arr[18] NE 0 Then begin
      tempCnt = Pol_18/(AvgLt_arr[18]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err


    ;Mod19
    If AvgLt_arr[19] NE 0 Then begin
      tempCnt = Pol_19/(AvgLt_arr[19]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err


    ;Mod20
    If AvgLt_arr[20] NE 0 Then begin
      tempCnt = Pol_20/(AvgLt_arr[20]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod21
    If AvgLt_arr[21] NE 0 Then begin
      tempCnt = Pol_21/(AvgLt_arr[21]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod22
    If AvgLt_arr[22] NE 0 Then begin
      tempCnt = Pol_22/(AvgLt_arr[22]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod24
    If AvgLt_arr[24] NE 0 Then begin
      tempCnt = Pol_24/(AvgLt_arr[24]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod25
    If AvgLt_arr[25] NE 0 Then begin
      tempCnt = Pol_25/(AvgLt_arr[25]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod27
    If AvgLt_arr[27] NE 0 Then begin
      tempCnt = Pol_27/(AvgLt_arr[27]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod28
    If AvgLt_arr[28] NE 0 Then begin
      tempCnt = Pol_28/(AvgLt_arr[28]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod29
    If AvgLt_arr[29] NE 0 Then begin
      tempCnt = Pol_29/(AvgLt_arr[29]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err

    ;Mod31
    If AvgLt_arr[31] NE 0 Then begin
      tempCnt = Pol_31/(AvgLt_arr[31]*Temp_Time)
      Temp_Err = TempCnt  ; THis is due to the sqrt(count) = error and this is error^2
    Endif Else BEgin
      TempCnt = Empty_Count
      Temp_Err = Empty_Count
    Endelse
    tot_Count = Tot_Count+TempCnt
    Tot_Err = Tot_Err+ Temp_Err
    If P Eq 0 Then Total_Hist = Tot_Count Else Total_Hist=Total_Hist+Tot_Count
    If P Eq 0 Then Total_Hist_Err = Tot_ERr Else Total_Hist_Err=Total_Hist_err+Tot_ERr

  EndFor; /p
  help, nfiles
  Total_Hist = Total_Hist/nfiles
  Total_Hist_Err = Sqrt(Total_Hist_Err) /nfiles

  CgPlot, X1, Total_hist, PSYM=10
  ;-- TExt Files --
  Openw, Lun, Title1+'_TotNrg_polE.txt', /Get_lun
  For i = 0, N_Elements(Total_Hist)-1 Do begin
    Printf,lun, X1[i], Total_Hist[i], Total_hist_Err[i]
  EndFor
  Free_lun, lun
  ;

End