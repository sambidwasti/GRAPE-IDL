Pro Grp_Flt_l2v7_Pol, fsearch_String, nfiles=nfiles, title=title, Type = Type
;****************************************************************
; This is a child of Flt_l2v7_Pol. 
; That was generating per module data.and was background subtracting per module.
; HEre we are doing total source and total background
; 
;
  True = 1
  False= 0

  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 12.0
  Pla_EMax = 200.00

  Cal_EMin = 30.0
  Cal_Emax = 400.00

  Tot_Emin = 80.00
  Tot_EMax = 120.00

  ;  Tot_Emin = 150.00
  ;  Tot_EMax = 250.00
  ;  Cal_EMin = 20.0
  ;  Cal_EMax = 600.00
  ;
  ;  Tot_Emin = 80.0
  ;  Tot_Emax = 800.00
  ;== Few Useful Energy Cuts Used at times for these sources and energies ==
  ; For Cs-Pol, used Peak energy 290 and width 50
  ;                              175 and width 40
  ; For Co-57 used               100 and width 25
  ; For Ba-133 used              70   and witdth 15 ..  for 80
  ;                              210  and width 30
  ; For Room Peak_Energy         150 and width 100, since we are usually interested in Energy.
  ; =======================================================================


  EMAX= 1000.00 ; Max value of energy for energy histogram.
  ; === Energy Cuts Ended ==


  ;
  Cd, Cur=Cur
  ;

  ; The 2014 configuration of position that is occupied by the modules.
  ;
  c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration


  ;
  ;========= Input Parameters. =========
  Ener_Flag =0
  IF Keyword_Set(title) Eq 0 Then Title='Test'

  IF Keyword_Set(Ener) NE 0 THen Ener_Flag = 1

  evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  if keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)

  If Keyword_Set(Type) EQ 0 Then Type_Flag = false Else type_Flag = True
  ;=====================================
  ;

  ;
  ;-- Just a print statement for keeping track of things
  ;
  ; If Ener_Flag EQ 0 Then Print, Peak_Energy , Peak_Energy_Width


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
  ;==== Struc Defined =======
  ;

  ;
  ; == Define Arrays and Variables.
  Tot_Live_Time  = FltArr(32)
  Live_Time_Cnt  = LonArr(32)
  Total_Time_Ran = 0.0D

  Temp_Time = 0.0D

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

  Inst_Arr= DblArr(1)

  Temp_Scat_Arr = DblArr(1)

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
  ; =================
  ;

  ;
  ; === Work on each Files Now ======
  ;
  For p = 0, nfiles-1 Do Begin ; open each file
    ;
    ;---- Each file
    ;
    fname = evtfiles[p]
    print, fname

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
      readu, lun, Struc           ; read one event
      Event_data[i] =Struc        ; add it to input array
    EndFor

    ;
    ;--- Free Lun ----
    ;
    Free_Lun, lun

    ;
    ;-- For Each of the Packets--
    ;
    For i = 0, TotPkt-1 Do Begin



      ;
      ; -- Quality Selection--
      ;
      If Event_Data[i].QFlag NE 10 then goto, Jump_Packet   ; This selection is only true for PC, (Filetered after Hdw Threshold & flag anodes)

      ;
      ;-- Fail-Safe check to make sure PC events
      ;
      If Event_Data[i].EvClass NE 3 Then goto, Jump_Packet

      ;
      ; -- Select 2 Events for PC events (This should have already been selected)--
      ;
      If Event_Data[i].nanodes NE 2 Then goto, Jump_Packet

      ;
      ; -- Inter-Module Flag --
      ;
      If Event_Data[i].pa_mod NE Event_Data[i].sa_mod Then Goto, Jump_Packet

      Mod_pos = Event_data[i].pa_mod     ; Module Position
      If (Where(Mod_pos EQ c2014) Ne -1) Eq 0 Then Goto, Jump_Packet      ; Skipping modules which are not in the configuration.

      ;
      ;-- Total Time compounded in the end.
      ;
      Temp_Time = Event_Data[i].Swtime ; For total time ran. ( This is the time since begining of the sweep.)

      ;
      ; Already have primary and secondary anodes.
      ; However, we do not know which one is plastic or not.
      ;

      ;
      ;-- Check for PA
      ;
      PA = Event_Data[i].pa_id

      If AnodeType(PA) EQ 0 Then Begin
        If (Event_Data[i].pa_nrg LT Cal_EMin) OR (Event_Data[i].pa_nrg GT Cal_EMax) Then Goto, Jump_Packet
      Endif Else If AnodeType(PA) EQ 1 Then Begin
        If (Event_Data[i].pa_nrg LT Pla_EMin) OR (Event_Data[i].pa_nrg GT Pla_EMax) Then Goto, Jump_Packet
      Endif

      ;
      ;-- Check for SA
      ;
      SA = Event_Data[i].sa_id
      If AnodeType(SA) EQ 0 Then Begin
        If (Event_Data[i].sa_nrg LT Cal_EMin) OR (Event_Data[i].sa_nrg GT Cal_EMax) Then Goto, Jump_Packet
      Endif Else If AnodeType(SA) EQ 1 Then Begin
        If (Event_Data[i].sa_nrg LT Pla_EMin) OR (Event_Data[i].sa_nrg GT Pla_EMax) Then Goto, Jump_Packet
      Endif

      ;
      ;-- Check for Event Type Flag (Type 1, 2  or 3)
      ;

      If Type_Flag Eq True Then Begin
        If(EventType(PA,SA) NE Type) Then Goto, Jump_Packet
      EndIF

      Tot_Energy = Double(Event_Data[i].pa_nrg + Event_Data[i].sa_nrg)


      ;      print, Event_Data[i].pvang, event_Data[i].sctang, Event_Data[i].RTang , Event_Data[i].posang, Event_Data[i].ppvang
      ;      Print, Event_Data[i].PA_id, Event_Data[i].SA_id
      ;      stop

      ;
      ;---- Live Time Values and Counters. ---
      ;
      Tot_Live_Time[Mod_Pos] = Tot_Live_time[Mod_Pos]+Event_data[i].CorrectLT
      Live_Time_Cnt[Mod_pos]++



      ;
      ;--- Energy Histogram Creation ----
      ;
      If Tot_Energy LT EMAX Then Begin
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
      ENdIF

      ;
      ; ------------ Total Energy Selection for the Polarized Run -------
      ;
      If (Tot_Energy LT Tot_EMIN) or (Tot_Energy GT Tot_EMAX) THen goto, Jump_Packet


      ;
      ;---- Grab Co-ordinates ---
      ;




      ;---- Debugging Tool ---------
      ;; Instrument Coordinate Things:
      ;
      ;             Y_Diff = Sec_Cord[1]-Pri_Cord[1]
      ;             X_Diff = Sec_Cord[0]-Pri_Cord[0]
      ;             Ins_Scat_Angle = !Radeg*Atan(Y_Diff,X_Diff)             ; Just so we want to see. (NRIC)
      ;             If Ins_Scat_Angle LT 0.0 then Ins_Scat_Angle=Ins_Scat_Angle+360.00
      ;             Inst_Arr = [Inst_Arr,Ins_Scat_Angle]
      ;------------------------


      ;=================== ANGLE THINGS ====================
      ;---- Transform Co-Ordinates with the Rotation Angle ---
      ;====================================================

      ;----------------- Few more Notes on the transformation-----------------;
      ; We are doing a Clockwise rotation.
      ; So, we are transforming the angle to the PVCS                         ;
      ; Angle in Non-Rotated ICS = measured angle (Rotated ICS) - table angle ;
      ; PV angle = Non-Rotated ICS + offset Angle                             ;

      ; Table angle goes from 0~360 and offset angle measured is 152.4 deg.   ;
      ; Camden used 151.6 so we are using this a teh 152.4 is within error    ;
      ; So we want the rotation angle in the same form that is 0~360          ;
      ;-----------------------------------------------------------------------;

      ;      ;
      ;      ;--- The Effective rotation angle 0~360
      ;      ;
      ;      Rot_Angle_Measured = Offset_Angle - Event_Data[i].Rotang
      ;      If Rot_Angle_Measured LT 0.0 Then Rot_Angle_Measured = Rot_Angle_Measured + 360.00
      ;
      ;      ;
      ;      ; --- Change the angle to radians --
      ;      ;
      ;      Rotation_Angle = Rot_Angle_Measured * !PI/180
      ;
      ;
      ;      ;----- Now Transform the coordinates before getting the angle ----;
      ;      ;      For  CW rotation angle                                     ;
      ;      ;            ( X' ) =  X0*Cos(Ang) - Y0*Sin(Ang)                  ;
      ;      ;            ( Y' ) =  X0*Sin(Ang) + Y0*Cos(Ang)                  ;
      ;      ;-----------------------------------------------------------------;
      ;
      ;      ;=== (Optimus Prime and Optimus Secondary ) TRANSFORM ==
      ;      Pri_X = Pri_Cord[0]*Cos(Rotation_Angle) - Pri_Cord[1]*Sin(ROtation_Angle)
      ;      Pri_Y = Pri_Cord[0]*Sin(Rotation_Angle) + Pri_Cord[1]*Cos(ROtation_Angle)
      ;
      ;      Sec_X = Sec_Cord[0]*Cos(Rotation_Angle) - Sec_Cord[1]*Sin(ROtation_Angle)
      ;      Sec_Y = Sec_Cord[0]*Sin(Rotation_Angle) + Sec_Cord[1]*Cos(ROtation_Angle)
      ;
      ;
      ;      ; ----- Transformed getting the Ydiff and Xdiff
      ;      Y_Diff_1 = Sec_Y- Pri_Y
      ;      X_Diff_1 = Sec_X- Pri_X
      ;
      ;      ; ----- Grab Angles and transform them to Degrees in the range 0~360
      ;      Pres_Ves_Angle =!Radeg*Atan(Y_Diff_1,X_Diff_1)
      ;      If Pres_Ves_Angle LT 0.0 Then PRes_Ves_Angle = PRes_Ves_Angle + 360.0
      ;
      Pres_Ves_Angle = Double( Event_Data[i].PVAng)

      ;    TempAng = event_data[i].rtang
      ;   ; Cirrange, TempAng
      ;
      ;      Temp_Scat_Arr = [Temp_Scat_Arr,TempAng]

      ;--------- Debugging Tool : --------------
      ;      If i gt 200000 then stop
      ;      Print, PA, SA, Event_Data[i].RtAng, Event_Data[i].SctAng , Pres_Ves_Angle
      ;----------------------------------------

      ;
      ; The Each Module Arrays (Concat them)
      ;
      If Mod_Pos EQ 0 Then P0_Arr  = [P0_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 2 Then P2_Arr  = [P2_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 3 Then P3_Arr  = [P3_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 4 Then P4_Arr  = [P4_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 6 Then P6_Arr  = [P6_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 7 Then P7_Arr  = [P7_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 9 Then P9_Arr  = [P9_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 10 Then P10_Arr = [P10_Arr,Pres_Ves_Angle]

      If Mod_Pos EQ 11 Then P11_Arr = [P11_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 12 Then P12_Arr = [P12_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 13 Then P13_Arr = [P13_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 14 Then P14_Arr = [P14_Arr,Pres_Ves_Angle]

      If Mod_Pos EQ 17 Then P17_Arr = [P17_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 18 Then P18_Arr = [P18_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 19 Then P19_Arr = [P19_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 20 Then P20_Arr = [P20_Arr,Pres_Ves_Angle]

      If Mod_Pos EQ 21 Then P21_Arr = [P21_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 22 Then P22_Arr = [P22_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 24 Then P24_Arr = [P24_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 25 Then P25_Arr = [P25_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 27 Then P27_Arr = [P27_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 28 Then P28_Arr = [P28_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 29 Then P29_Arr = [P29_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 31 Then P31_Arr = [P31_Arr,Pres_Ves_Angle]


      Jump_Packet:


      ; -- Helps to track the part of the data its working.
      If i mod 100000 EQ 0 Then print, i

      ;----- End packet loop
    EndFor; /i


    ;
    ; --- Add the total time ran for each Event File.
    ;
    Total_Time_Ran = Total_Time_Ran + Temp_Time

    ;
    ; --- Prints out no. of files left to work on.
    ; --- Just to keep track of things.
    ;
    Files_Left = nfiles-p
    Print, 'No. of Files LEft : '+STRN(Files_Left-1)

    ; end of File Loop.
  EndFor; /p
  ;
  ; ==== Finished working on the files and the huge histograms are made.. ===
  ;


  ;
  ; Since we concat the array, first value is 0 so we fix it.
  ;

  ;
  ;---- Polarization Array first
  ;
  Help, P14_Arr
  H0_ARR =P0_Arr[1:N_Elements(P0_Arr)-1]
  H2_Arr =P2_Arr[1:N_Elements(P2_Arr)-1]
  H3_Arr =P3_Arr[1:N_Elements(P3_Arr)-1]
  H4_Arr =P4_Arr[1:N_Elements(P4_Arr)-1]
  H6_Arr =P6_Arr[1:N_Elements(P6_Arr)-1]
  H7_Arr =P7_Arr[1:N_Elements(P7_Arr)-1]
  H9_Arr =P9_Arr[1:N_Elements(P9_Arr)-1]
  H10_Arr =P10_Arr[1:N_Elements(P10_Arr)-1]

  H11_Arr=P11_Arr[1:N_Elements(P11_Arr)-1]
  H12_Arr=P12_Arr[1:N_Elements(P12_Arr)-1]
  H13_Arr=P13_Arr[1:N_Elements(P13_Arr)-1]

  If N_elements(P14_Arr) GT 1 Then H14_Arr=P14_Arr[1:N_Elements(P14_Arr)-1] Else H14_Arr = P14_Arr
  H17_Arr=P17_Arr[1:N_Elements(P17_Arr)-1]
  H18_Arr=P18_Arr[1:N_Elements(P18_Arr)-1]
  H19_Arr=P19_Arr[1:N_Elements(P19_Arr)-1]
  H20_Arr=P20_Arr[1:N_Elements(P20_Arr)-1]

  H21_Arr=P21_Arr[1:N_Elements(P21_Arr)-1]
  H22_Arr=P22_Arr[1:N_Elements(P22_Arr)-1]
  H24_Arr=P24_Arr[1:N_Elements(P24_Arr)-1]
  H25_Arr=P25_Arr[1:N_Elements(P25_Arr)-1]
  H27_Arr=P27_Arr[1:N_Elements(P27_Arr)-1]
  H28_Arr=P28_Arr[1:N_Elements(P28_Arr)-1]
  H29_Arr=P29_Arr[1:N_Elements(P29_Arr)-1]
  H31_Arr=P31_Arr[1:N_Elements(P31_Arr)-1]
  ;-----------

  ;
  ;------For sanity Checks, Plot them together.
  ;
  Window,0
  Main_Src_Arr = [H0_Arr,H2_Arr,H3_Arr,H4_Arr,H6_Arr,H7_Arr,H9_Arr,H10_Arr,H11_Arr,H12_ARr,H13_Arr,H14_Arr,$
    H17_Arr,H18_Arr,H19_Arr,H20_Arr,H21_Arr,H22_Arr,H24_Arr,H25_Arr,H27_Arr,H28_ARr,H29_Arr,H31_Arr]
  CgHistoplot,Main_Src_Arr, Binsize=1.0, /OUTLINE, XRANGE=[0,360], XSTYLE=1
  ;Window, 2
  ;  Cgplot, Temp_Scat_Arr[1:N_Elements(Temp_Scat_Arr)-1]
  ;Stop
  ;--- Print total time ----
  Print, Total_Time_Ran

  ;
  ; Getting the Scattering Histogram for each module
  ;
  M0Arr = Histogram(H0_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M2Arr = Histogram(H2_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M3Arr = Histogram(H3_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M4Arr = Histogram(H4_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M6Arr = Histogram(H6_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M7Arr = Histogram(H7_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M9Arr = Histogram(H9_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M10Arr = Histogram(H10_Arr, NBIns=360, Max = 360.0, Min=0.0)

  M11Arr = Histogram(H11_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M12Arr = Histogram(H12_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M13Arr = Histogram(H13_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M14Arr = Histogram(H14_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M17Arr = Histogram(H17_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M18Arr = Histogram(H18_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M19Arr = Histogram(H19_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M20Arr = Histogram(H20_Arr, NBIns=360, Max = 360.0, Min=0.0)

  M21Arr = Histogram(H21_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M22Arr = Histogram(H22_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M24Arr = Histogram(H24_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M25Arr = Histogram(H25_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M27Arr = Histogram(H27_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M28Arr = Histogram(H28_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M29Arr = Histogram(H29_Arr, NBIns=360, Max = 360.0, Min=0.0)
  M31Arr = Histogram(H31_Arr, NBIns=360, Max = 360.0, Min=0.0)


  ;
  ;--- Combine these to one array
  ;
  Scat_Array= DBLArr(32,360)

  Scat_Array[0,*] = M0Arr
  Scat_Array[2,*] = M2Arr
  Scat_Array[3,*] = M3Arr
  Scat_Array[4,*] = M4Arr
  Scat_Array[6,*] = M6Arr
  Scat_Array[7,*] = M7Arr
  Scat_Array[9,*] = M9Arr
  Scat_Array[10,*] = M10Arr

  Scat_Array[11,*] = M11Arr
  Scat_Array[12,*] = M12Arr
  Scat_Array[13,*] = M13Arr
  Scat_Array[14,*] = M14Arr
  Scat_Array[17,*] = M17Arr
  Scat_Array[18,*] = M18Arr
  Scat_Array[19,*] = M19Arr
  Scat_Array[20,*] = M20Arr

  Scat_Array[21,*] = M21Arr
  Scat_Array[22,*] = M22Arr
  Scat_Array[24,*] = M24Arr
  Scat_Array[25,*] = M25Arr
  Scat_Array[27,*] = M27Arr
  Scat_Array[28,*] = M28Arr
  Scat_Array[29,*] = M29Arr
  Scat_Array[31,*] = M31Arr
  ; --- One giant array created ---


  ;
  ; ---- Now Generate the Histogram Text File.
  ;
  If Type_Flag EQ True Then Title=Title+'_Type'+Strn(Type)

  Openw, Lunger, Cur+'/'+Title+'_n'+strn(nfiles)+'_PolHist.txt', /Get_Lun

  Printf, Lunger, ' Polarization Histogram of Each of the Modules. '
  Printf, Lunger, ' Total Time Ran      ='+ Strn(Total_Time_Ran)
  Printf, Lunger, 'SIZE ='+Strn(360)
  ;  Printf, Lunger, 'PEak_Energy='+Strn(Peak_Energy)
  ;  Printf, Lunger, 'Peak_Energy_Width='+Strn(Peak_Energy_Width)
  Printf, Lunger, '/Empty Line'

  For i =0,31 Do Begin

    ; --- The Average Live Time Stuffs -----
    If Live_Time_Cnt[i] Eq 0 then AvgLT=0 Else AvgLT=(Double(Tot_Live_Time[i])/Double(Live_Time_Cnt[i]))
    Printf, Lunger, 'Mod_Pos='+Strn(i)
    Printf, Lunger, 'AVG_LT ='+Strn(AvgLT)
    Txt = ''

    ; --- Generating a text to write in the file. ---
    For j = 0,359 do begin
      Txt= Txt+Strn(Scat_Array[i,j])+' '
    EndFor
    Printf, Lunger, Txt
  EndFor
  Free_Lun, Lunger
  ; --- Histogram Text file generated ---
  PRINT, 'TOTAL COUNTS POL='+STRN(TOTAL(Scat_Array))

  ; The pointer for goto*
  Jump_Pol:

  ;
  ;----- Now do the same thing for the Energy Array (Concat fixing)
  ;
  ;
  ;------For sanity Checks, Plot them together.
  ;


  H0_EARR =P0_EArr[1:N_Elements(P0_EArr)-1]
  H2_EArr =P2_EArr[1:N_Elements(P2_EArr)-1]
  H3_EArr =P3_EArr[1:N_Elements(P3_EArr)-1]
  H4_EArr =P4_EArr[1:N_Elements(P4_EArr)-1]
  H6_EArr =P6_EArr[1:N_Elements(P6_EArr)-1]
  H7_EArr =P7_EArr[1:N_Elements(P7_EArr)-1]
  H9_EArr =P9_EArr[1:N_Elements(P9_EArr)-1]
  H10_EArr =P10_EArr[1:N_Elements(P10_EArr)-1]

  H11_EArr=P11_EArr[1:N_Elements(P11_EArr)-1]
  H12_EArr=P12_EArr[1:N_Elements(P12_EArr)-1]
  H13_EArr=P13_EArr[1:N_Elements(P13_EArr)-1]
  If N_elements(P14_EArr) GT 1 Then H14_EArr=P14_EArr[1:N_Elements(P14_EArr)-1] Else H14_EArr = P14_EArr

  H17_EArr=P17_EArr[1:N_Elements(P17_EArr)-1]
  H18_EArr=P18_EArr[1:N_Elements(P18_EArr)-1]
  H19_EArr=P19_EArr[1:N_Elements(P19_EArr)-1]
  H20_EArr=P20_EArr[1:N_Elements(P20_EArr)-1]

  H21_EArr=P21_EArr[1:N_Elements(P21_EArr)-1]
  H22_EArr=P22_EArr[1:N_Elements(P22_EArr)-1]
  H24_EArr=P24_EArr[1:N_Elements(P24_EArr)-1]
  H25_EArr=P25_EArr[1:N_Elements(P25_EArr)-1]
  H27_EArr=P27_EArr[1:N_Elements(P27_EArr)-1]
  H28_EArr=P28_EArr[1:N_Elements(P28_EArr)-1]
  H29_EArr=P29_EArr[1:N_Elements(P29_EArr)-1]
  H31_EArr=P31_EArr[1:N_Elements(P31_EArr)-1]

  Window,1
  Main_Src_EArr = [H0_EArr,H2_EArr,H3_EArr,H4_EArr,H6_EArr,H7_EArr,H9_EArr,H10_EArr,H11_EArr,H12_EARr,H13_EArr,H14_EArr,$
    H17_EArr,H18_EArr,H19_EArr,H20_EArr,H21_EArr,H22_EArr,H24_EArr,H25_EArr,H27_EArr,H28_EARr,H29_EArr,H31_EArr]
  CgHistoplot,Main_Src_EArr, Binsize=5, /OUTLINE

  ;
  ; ----- Creating the individual Module Histogram Array
  ;
  M0EArr = Histogram(H0_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M2EArr = Histogram(H2_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M3EArr = Histogram(H3_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M4EArr = Histogram(H4_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M6EArr = Histogram(H6_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M7EArr = Histogram(H7_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M9EArr = Histogram(H9_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M10EArr = Histogram(H10_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)

  M11EArr = Histogram(H11_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M12EArr = Histogram(H12_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M13EArr = Histogram(H13_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M14EArr = Histogram(H14_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M17EArr = Histogram(H17_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M18EArr = Histogram(H18_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M19EArr = Histogram(H19_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M20EArr = Histogram(H20_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)

  M21EArr = Histogram(H21_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M22EArr = Histogram(H22_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M24EArr = Histogram(H24_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M25EArr = Histogram(H25_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M27EArr = Histogram(H27_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M28EArr = Histogram(H28_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M29EArr = Histogram(H29_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)
  M31EArr = Histogram(H31_EArr, NBIns=EMAX, MAX=EMAX, MIN=0.0)


  ;
  ; ---- Combine them to One giant array ---
  ;
  Scat_EArray= FltArr(32,EMAX)

  Scat_EArray[0,*] = M0EArr
  Scat_EArray[2,*] = M2EArr
  Scat_EArray[3,*] = M3EArr
  Scat_EArray[4,*] = M4EArr
  Scat_EArray[6,*] = M6EArr
  Scat_EArray[7,*] = M7EArr
  Scat_EArray[9,*] = M9EArr
  Scat_EArray[10,*] = M10EArr

  Scat_EArray[11,*] = M11EArr
  Scat_EArray[12,*] = M12EArr
  Scat_EArray[13,*] = M13EArr
  Scat_EArray[14,*] = M14EArr
  Scat_EArray[17,*] = M17EArr
  Scat_EArray[18,*] = M18EArr
  Scat_EArray[19,*] = M19EArr
  Scat_EArray[20,*] = M20EArr

  Scat_EArray[21,*] = M21EArr
  Scat_EArray[22,*] = M22EArr
  Scat_EArray[24,*] = M24EArr
  Scat_EArray[25,*] = M25EArr
  Scat_EArray[27,*] = M27EArr
  Scat_EArray[28,*] = M28EArr
  Scat_EArray[29,*] = M29EArr
  Scat_EArray[31,*] = M31EArr

  PRINT, 'TOTAL COUNTS ENER='+STRN(TOTAL(Scat_EArray))


  ;
  ; ---- Now generate the PC Energy Spectrum Histogram text file.
  ;
  Openw, Lunger1, Cur+'/'+Title+'_n'+strn(nfiles)+'_EnerHist.txt', /Get_Lun

  Printf, Lunger1, ' Energy Histogram of Each of the Modules. '
  Printf, Lunger1, ' Total Time Ran      ='+ Strn(Total_Time_Ran)
  Printf, Lunger1, ' SIZE ='+Strn(EMAX)
  Printf, Lunger1, '/Empty Line'

  For i =0,31 Do Begin
    ;
    ; - live time stuffs -
    ;
    If Live_Time_Cnt[i] Eq 0 then AvgLT=0 Else AvgLT=(Double(Tot_Live_Time[i])/Double(Live_Time_Cnt[i]))

    Printf, Lunger1, 'Mod_Pos='+Strn(i)
    Printf, Lunger1, 'AVG_LT ='+Strn(AvgLT)
    Txt = ''

    ;
    ; Energy values into a text.
    ;
    For j = 0,EMAX-1 do begin
      Txt= Txt+Strn(Scat_EArray[i,j])+' '
    EndFor
    Printf, Lunger1, Txt
  EndFor
  Free_Lun, Lunger1
End