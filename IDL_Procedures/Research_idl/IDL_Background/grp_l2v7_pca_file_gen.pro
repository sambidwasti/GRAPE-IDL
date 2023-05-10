Pro Grp_l2v7_PCA_file_Gen, fsearch_String, Title= Title, nfiles=nfiles

  ; This just creates a text file with swpno. rate and error.
  ; For 1 energy range.
  ;

  True = 1
  False= 0

  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 10.0
  Pla_EMax = 200.00

  Cal_EMin = 40.0
  Cal_EMax = 400.00

  Tot_EMin = 50.00
  Tot_EMax = 300.00


  Print,'-----------'
  Print,'Energy Range'
  Print, Tot_EMin
  Print, Tot_EMax
  Print,'-----------'

  ; ************* STANDARD INITIATIONS ******************
  Cd, Cur=Cur
  IF Keyword_Set(title) Eq 0 Then Title='Test'


  ;
  ;******************STANDARD FILTERING AND PROCESSING*********************
  ;
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
 Sum_Sweep = [0]
  ;**************************** STANDARD INITIATION **************************

  ;******* Procedure Specific *************

  LT_Array = DblArr(32)
  LT_Count = DblArr(32)

  Sum_Count = [0.0D]
  Sum_Count_Err = [0.0D]


  ; ******* Standard Each File ************
  For p = 0, nfiles-1 Do Begin ; open each file

    ;-- No. of Events Counter --
    No_Events = 0L

    ;
    ;-- Few Values --
    ;
    ;    Total_Altitude = 0.0D
    ;    Total_Zenith   = 0.0D
    ;    Total_Depth    = 0.0D
    ;    Total_LT       = 0.0D
    ;    Total_Azimuth  = 0.0D

    End_Swp_Flag = False    ; Need this to make sure we are not wasting time in the end of file.

    ;
    ;---- Each file
    ;
    fname = evtfiles[p]

    ;
    ;--- Grab some file info
    ;
    f = file_info(fname)

    ;
    ;--- Open the binary file and dump it in Data and Close the file.
    ;
    Openr, lun, fname, /GET_Lun

    ;
    ;--- Grab total no. of packets
    ;
    TotPkt = long(f.size/Packet_Len)

    ;
    ;--- Replicate the structure for each packets.
    ;
    Event_data = replicate(Struc, TotPkt)
    ;
    ;---- Grab all the event data all at once.----
    ;
    For i = 0, TotPkt-1 Do Begin
      readu, lun, Struc        ; read one event
      Event_data[i] =Struc        ; add it to input array
    EndFor

    ;
    ;--- Free Lun ----
    ;
    Free_Lun, lun

    ;
    ;--- For Each Packet ---
    ;
    For i = 0, TotPkt-1 Do Begin

      ;
      ; Event Description
      ;
      Time = Event_Data[i].EvTime             ; Time
      m = Event_Data[i].Pa_Mod
      ; Live Time
      LiveTime = Event_Data[i].CorrectLT


      Swpno = Event_Data[i].SweepNo

      ;
      ;-- Applying Various Filters. ---
      ;

      ; Quality Flag for fully processed PC events
      If Event_Data[i].QFlag NE 10 Then Goto, Jump_Packet


      ; Filtering the rate period via Rotation Status.
      If (Event_Data[i].RtStat LT 5) Then Goto, Jump_Packet
      If (Event_Data[i].RtStat EQ 7) and (End_Swp_Flag EQ True) Then Goto, Jump_Packet


      ;
      ; -- Software Threshold applied --
      ;
      If Event_Data[i].AnodeTyp1 EQ 1 Then Begin    ; Its a Plastic so check these
        If (Event_Data[i].AnodeNRG1 LT Pla_EMIN) or (Event_Data[i].AnodeNRG1 GT Pla_EMAX) Then Goto, Jump_Packet
      EndIf Else If  Event_Data[i].AnodeTyp1 EQ 2 Then Begin    ; Its a Plastic so check these
        If (Event_Data[i].AnodeNRG1 LT Cal_EMIN) or (Event_Data[i].AnodeNRG1 GT Cal_EMAX) Then Goto, Jump_Packet
      EndIf

      If Event_Data[i].AnodeTyp2 EQ 1 Then Begin    ; Its a Plastic so check these
        If (Event_Data[i].AnodeNRG2 LT Pla_EMIN) or (Event_Data[i].AnodeNRG2 GT Pla_EMAX) Then Goto, Jump_Packet
      EndIf Else If  Event_Data[i].AnodeTyp2 EQ 2 Then Begin    ; Its a Plastic so check these
        If (Event_Data[i].AnodeNRG2 LT Cal_EMIN) or (Event_Data[i].AnodeNRG2 GT Cal_EMAX) Then Goto, Jump_Packet
      EndIf

      ; Total Energy
      Total_Energy = Event_Data[i].AnodeNRG1 + EVent_Data[i].AnodeNRG2
      If (Total_Energy LT Tot_EMIN) OR (Total_Energy GT Tot_EMAx) Then Goto, Jump_Packet

      LT_Array[m] = LT_Array[m]+LiveTime
      LT_Count[m]++

      Jump_Packet:
      If i mod 100000 EQ 0 Then print, i
    EndFor; /i End Packet.



    Tot_Count = 0.0D
    Tot_Count_Er = 0.0D
    Temp_Err_Val = 0.0D
    ;
    ;-- We do this for each of the module position --
    ;
    Time_diff = 720.00
    
    ;
    ; Module 0
    ;
    If LT_Count[0] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[0])/Double(LT_Count[0]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[0])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt

    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))



    ;
    ; Module2
    ;
    If LT_Count[2] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[2])/Double(LT_Count[2]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[2])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.

    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))

    ;
    ; Module3
    ;
    If LT_Count[3] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[3])/Double(LT_Count[3]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[3])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.

    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))



    ;
    ; Module4
    ;
    If LT_Count[4] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[4])/Double(LT_Count[4]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[4])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module6
    ;
    If LT_Count[6] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[6])/Double(LT_Count[6]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[6])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module7
    ;
    If LT_Count[7] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[7])/Double(LT_Count[7]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[7])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))

    ;
    ; Module9
    ;
    If LT_Count[9] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[9])/Double(LT_Count[9]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[9])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))



    ;
    ; Module10
    ;
    If LT_Count[10] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[10])/Double(LT_Count[10]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[10])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module11
    ;
    If LT_Count[11] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[11])/Double(LT_Count[11]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[11])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))



    ;
    ; Module12
    ;
    If LT_Count[12] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[12])/Double(LT_Count[12]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[12])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module13
    ;
    If LT_Count[13] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[13])/Double(LT_Count[13]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[13])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module14
    ;
    If LT_Count[14] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[14])/Double(LT_Count[14]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[14])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))

    ;
    ; Module17
    ;
    If LT_Count[17] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[17])/Double(LT_Count[17]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[17])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))

    ;
    ; Module18
    ;
    If LT_Count[18] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[18])/Double(LT_Count[18]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[18])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module19
    ;
    If LT_Count[19] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[19])/Double(LT_Count[19]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[19])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))

    ;
    ; Module20
    ;
    If LT_Count[20] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[20])/Double(LT_Count[20]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[20])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module21
    ;
    If LT_Count[21] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[21])/Double(LT_Count[21]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[21])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module22
    ;
    If LT_Count[22] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[22])/Double(LT_Count[22]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[22])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module24
    ;
    If LT_Count[24] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[24])/Double(LT_Count[24]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[24])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))

    ;
    ; Module25
    ;
    If LT_Count[25] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[25])/Double(LT_Count[25]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[25])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module27
    ;
    If LT_Count[27] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[27])/Double(LT_Count[27]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[27])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module28
    ;
    If LT_Count[28] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[28])/Double(LT_Count[28]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[28])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ;
    ; Module29
    ;
    If LT_Count[29] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[29])/Double(LT_Count[29]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[29])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))


    ; Module31
    ;
    If LT_Count[31] EQ 0.0 Then begin
      Temp_AvgLT  = 0.0 ; Average LT over the period
      Temp_Cnt    = 0.0
    Endif Else Temp_AvgLT  = Double(LT_Array[31])/Double(LT_Count[31]) ; Average LT over the period

    IF Temp_AvgLT Gt 0.0 Then Temp_Cnt    = Double(Double(LT_Count[31])/Double(Time_Diff*Temp_AvgLT))  Else Temp_Cnt=0.0; Scaled Count.
    Tot_Count = Tot_Count+Temp_Cnt
    IF Temp_AvgLT Gt 0.0 Then Temp_Err_Val = (Temp_Err_Val + Temp_Cnt/Double(Time_Diff*Temp_AvgLT))

    ; Error propagation.. one multiplication and then adding in quadrature.
    Tot_Count_Err = Sqrt(Temp_Err_Val)
    ;;

    Sum_Count = [SUm_Count,Tot_Count]
    Sum_Count_Err=[Sum_Count_Err, Tot_Count_Err]
  Swpno = Event_Data[1].Sweepno
    Sum_Sweep = [Sum_Sweep, Swpno]


    ;
    ;=== Statistic Stuffs ====
    ;

    For j =0, 31 Do Begin
      LT_Array[j]=0.0D
      LT_COunt[j]=0.0D
    EndFor

    Tot_Count = 0.0D

    Print, Event_Data[i-1].SweepNo
  EndFor; /p For file


  ;
  ;-- Trim these arrays for removal for the 1st value--
  ;


  Openw, Lun1, Cur+'/'+Title+'_flt_rate.txt',/Get_Lun
  Printf,lun1, 'Erange = '+Strn(Tot_Emin)+'  '+Strn(Tot_EMax)
  Printf,lun1, 'Sweep     Count    CountErr'
  For i=1,  N_Elements(Sum_Count)-1 Do Begin
    Printf, Lun1, Sum_Sweep[i],Sum_Count[i], Sum_Count_Err[i],$
      format = '(I4,1X,  1X,F8.2, 1X, F8.4 )'
  Endfor
  Free_Lun, Lun1



  Stop
End