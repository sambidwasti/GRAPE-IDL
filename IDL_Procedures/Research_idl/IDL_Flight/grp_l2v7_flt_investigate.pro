Pro Grp_L2v7_Flt_Investigate, fsearch_String, Title= Title, nfiles=nfiles, Scl_Time=Scl_Time


  ;       Uses Level 2 files.
  ;      Create Energy plots (lower and upper) to see what the lower/upper limits are
  ;      From 
  ;

  True = 1
  False= 0

  IF Keyword_Set(Scl_Time) Eq 0 Then Scl_Time =720

  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 12.0
  Pla_EMax = 200.00

  Cal_EMin = 30.0
  Cal_EMax = 400.00

  Tot_EMin = 80.00
  Tot_EMax = 200.00


  Altitude = 131.5D

  PMax= 1500 ; Max value of energy for energy histogram.
  Cd, Cur=Cur

  IF Keyword_Set(title) Eq 0 Then Title='Test'


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

  ;
  ;-- Define Arrays for Each Time Cycle Block--
  ;
  Mod0_Cnt = [0.0D]
  Mod2_Cnt = [0.0D]
  Mod3_Cnt = [0.0D]
  Mod4_Cnt = [0.0D]
  Mod6_Cnt = [0.0D]
  Mod7_Cnt = [0.0D]
  Mod9_Cnt = [0.0D]
  
  Mod10_Cnt = [0.0D]
  Mod11_Cnt = [0.0D]
  Mod12_Cnt = [0.0D]
  Mod13_Cnt = [0.0D]
  Mod14_Cnt = [0.0D]
  Mod17_Cnt = [0.0D]
  Mod18_Cnt = [0.0D]
  Mod19_Cnt = [0.0D]
  
  Mod20_Cnt = [0.0D]
  Mod21_Cnt = [0.0D]
  Mod22_Cnt = [0.0D]
  Mod24_Cnt = [0.0D]
  Mod25_Cnt = [0.0D]
  Mod27_Cnt = [0.0D]
  Mod28_Cnt = [0.0D]
  Mod29_Cnt = [0.0D]
  Mod31_Cnt = [0.0D]

  ;
  ;--
  ;
  Mod0_Alt = [0.0D]
  Mod2_Alt = [0.0D]
  Mod3_Alt = [0.0D]
  Mod4_Alt = [0.0D]
  Mod6_Alt = [0.0D]
  Mod7_Alt = [0.0D]
  Mod9_Alt = [0.0D]

  Mod10_Alt = [0.0D]
  Mod11_Alt = [0.0D]
  Mod12_Alt = [0.0D]
  Mod13_Alt = [0.0D]
  Mod14_Alt = [0.0D]
  Mod17_Alt = [0.0D]
  Mod18_Alt = [0.0D]
  Mod19_Alt = [0.0D]

  Mod20_Alt = [0.0D]
  Mod21_Alt = [0.0D]
  Mod22_Alt = [0.0D]
  Mod24_Alt = [0.0D]
  Mod25_Alt = [0.0D]
  Mod27_Alt = [0.0D]
  Mod28_Alt = [0.0D]
  Mod29_Alt = [0.0D]
  Mod31_Alt = [0.0D]
  
  ;
  ;--
  ;
  Mod0_Time = [0.0D]
  Mod2_Time = [0.0D]
  Mod3_Time = [0.0D]
  Mod4_Time = [0.0D]
  Mod6_Time = [0.0D]
  Mod7_Time = [0.0D]
  Mod9_Time = [0.0D]

  Mod10_Time = [0.0D]
  Mod11_Time = [0.0D]
  Mod12_Time = [0.0D]
  Mod13_Time = [0.0D]
  Mod14_Time = [0.0D]
  Mod17_Time = [0.0D]
  Mod18_Time = [0.0D]
  Mod19_Time = [0.0D]

  Mod20_Time = [0.0D]
  Mod21_Time = [0.0D]
  Mod22_Time = [0.0D]
  Mod24_Time = [0.0D]
  Mod25_Time = [0.0D]
  Mod27_Time = [0.0D]
  Mod28_Time = [0.0D]
  Mod29_Time = [0.0D]
  Mod31_Time = [0.0D]
  
  Mod0_Dep = [0.0D]
  Mod0_ZEn = [0.0D]
  
  LT_Array = DblArr(32)
  LT_Count = DblArr(32)
  Alt_Array = DblArr(32)
  
  Sum_Count = [0.0D]
  Sum_Count_Err = [0.0D]
  Sum_Alt   = [0.0D]
  Sum_Azi   = [0.0D]
  Sum_Time  = [0.0D]
  Sum_Dep   = [0.0D]
  Sum_Dep_Err=[0.0D]
  
  Sum_Zen   = [0.0D]
  Sum_Zen_Err=[0.0D]
  
  Var_Dep   =[0.0D]
  Var_Count =[0.0D]
  Var_Azi   =[0.0D]
  
  Anode_Cnt = LONARR(32,64)
  ;
  For p = 0, nfiles-1 Do Begin ; open each file

    ; Counter for first and End Array
    A=0

    ;
    ;-- No. of Events Counter --
    ;
    No_Events = 0L

    ;
    ;-- Few Values --
    ;
    Total_Altitude = 0.0D
    Total_Zenith   = 0.0D
    Total_Depth    = 0.0D
    Total_LT       = 0.0D
    Total_Azimuth  = 0.0D

    End_Swp_Flag = False    ; Need this to make sure we are not wasting time in the end of

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
      readu, lun, Struc        ; read one event
      Event_data[i] =Struc        ; add it to input array
    EndFor

    ;
    ;--- Free Lun ----
    ;
    Free_Lun, lun
    EVtime = 0.0D
    EvtCntr = 0L
    EvtDep  = 0.0D
    EvtZen  = 0.0D
    EvtAzi  = 0.0D
    EvtDep2 = 0.0D
    EvtZEn2 = 0.0D
    For i = 0, TotPkt-1 Do Begin

      Time = Event_Data[i].EvTime
      Zenith = Event_Data[i].PntZen
      
      If Zenith GT 90.0 THen ZEnith = Zenith-360.0D
      
      Depth  = Event_Data[i].Depth
      Azimuth= Event_Data[i].PntAzi
      
      If Event_Data[i].QFlag NE 10 Then Goto, Jump_Packet
      


;      If (Event_Data[i].pa_mod EQ 7) and  (EVENT_DATA[i].ANODEID1 EQ 25) Then begin
;        Print, m,i,EVENT_DATA[i].ANODEID1, EVENT_DATA[i].ANODEID2,' ', Event_Data[i].Qflag
;        Stop
;
;      EndIF
      LiveTime = Event_Data[i].CorrectLT

      If (Event_Data[i].RtStat LT 5) Then Goto, Jump_Packet
      If (Event_Data[i].RtStat EQ 7) and (End_Swp_Flag EQ True) Then Goto, Jump_Packet

      ;
      ; Check for Software Threshold Energies
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

      m = Event_Data[i].Pa_Mod
 
     ;--- Anode Counts ---
      Anode_Cnt[m,Event_Data[i].ANODEID1]++
      Anode_Cnt[m,Event_Data[i].ANODEID2]++

      ; Altitude
      Alt_Array[m] = Alt_Array[m]+Event_Data[i].Alt

      ; Live-Time

      LT_Array[m] = LT_Array[m]+LiveTime
      LT_Count[m]++
      No_Events++
      
      

      ;
      ;-- Define the First Time Stamp --
      ;
      If A EQ 0 Then Begin
        Old_Time = Time
        ;       Spec_Old_Time = Time
      Endif
      A=1

      ; Time Difference
      Time_Diff = Time - Old_Time
      ;     Spec_Time_Diff = Time - Spec_Old_Time


      If (Event_Data[i].RtStat EQ 7) and (End_Swp_Flag EQ False) Then Begin
        End_Swp_Flag = True
        A = 0
        IF (EVTCntr GT 0) Then Goto, Jump_Avg
      EndIf
      EvTime = Time + EVTime
      EvTDep = EvtDep+ Depth
      EvtDep2= EvtDep2+ Depth*Depth
      EvTZen = EvtZen+ Zenith
      EvtZen2= EvtZen2+ Zenith*ZEnith

      EvTAzi = EvtAzi+ Azimuth
      
      
      EvtCntr++

      ;
      ;-- Run this/ Average at a specific Intervals.
      ;
      If (Time_Diff GE Scl_Time) Then begin
  Jump_Avg:  
   
        AvTime = EVTime/Double(EVTCntr)
        AvDep  = EvtDep/Double(EVTCntr)
        AvZen  = EvtZen/Double(EVTCntr)
        AvAzi  = EvtAzi/Double(EVTCntr)
          Tot_Count = 0.0D
        Tot_Count_Er = 0.0D
        
        ;
        ;-- We do this for each of the module position -- 
        ;

        ;
        ; Module 0
        ;
        Temp_AvgLT  = Double(LT_Array[0])/Double(LT_Count[0]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[0])*Scl_Time/Double(Time_Diff*Temp_AvgLT)) ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[0]/(LT_Count[0]*1000))  ; Average Altitude Kft

        Mod0_Alt = [Mod0_Alt,Temp_Alt]        ; Event Alt
        Mod0_Cnt = [Mod0_Cnt,Temp_Cnt]        ; Event Count
        Mod0_Time= [Mod0_Time,AvTime]         ; Event Time
        
        Mod0_Dep = [Mod0_Dep,AvDep]
        Mod0_Zen = [Mod0_Zen,AvZen]
        
        Tot_Count = Tot_Count+Temp_Cnt
      
        
        ;  
        ; Module2
        ;
        Temp_AvgLT  = Double(LT_Array[2])/Double(LT_Count[2]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[2])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[2]/(LT_Count[2]*1000))  ; Average Altitude Kft

        Mod2_Alt = [Mod2_Alt,Temp_Alt]        ; Event Alt
        Mod2_Cnt = [Mod2_Cnt,Temp_Cnt]        ; Event Count
        Mod2_Time= [Mod2_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
          
            
        ;
        ; Module3
        ;
        Temp_AvgLT  = Double(LT_Array[3])/Double(LT_Count[3]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[3])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[3]/(LT_Count[3]*1000))  ; Average Altitude Kft

        Mod3_Alt = [Mod3_Alt,Temp_Alt]        ; Event Alt
        Mod3_Cnt = [Mod3_Cnt,Temp_Cnt]        ; Event Count
        Mod3_Time= [Mod3_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
            
            
            
        ;
        ; Module4
        ;
        Temp_AvgLT  = Double(LT_Array[4])/Double(LT_Count[4]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[4])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[4]/(LT_Count[4]*1000))  ; Average Altitude Kft

        Mod4_Alt = [Mod4_Alt,Temp_Alt]        ; Event Alt
        Mod4_Cnt = [Mod4_Cnt,Temp_Cnt]        ; Event Count
        Mod4_Time= [Mod4_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
             
              
        ;
        ; Module6
        ;
        Temp_AvgLT  = Double(LT_Array[6])/Double(LT_Count[6]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[6])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[6]/(LT_Count[6]*1000))  ; Average Altitude Kft

        Mod6_Alt = [Mod6_Alt,Temp_Alt]        ; Event Alt
        Mod6_Cnt = [Mod6_Cnt,Temp_Cnt]        ; Event Count
        Mod6_Time= [Mod6_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
            Tot_Count_Er= Tot_Count_Er + Temp_Cnt
            
            
        
        ;
        ; Module7
        ;
        Temp_AvgLT  = Double(LT_Array[7])/Double(LT_Count[7]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[7])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[7]/(LT_Count[7]*1000))  ; Average Altitude Kft

        Mod7_Alt = [Mod7_Alt,Temp_Alt]        ; Event Alt
        Mod7_Cnt = [Mod7_Cnt,Temp_Cnt]        ; Event Count
        Mod7_Time= [Mod7_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
           
            
        ;
        ; Module9
        ;
        Temp_AvgLT  = Double(LT_Array[9])/Double(LT_Count[9]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[9])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[9]/(LT_Count[9]*1000))  ; Average Altitude Kft

        Mod9_Alt = [Mod9_Alt,Temp_Alt]        ; Event Alt
        Mod9_Cnt = [Mod9_Cnt,Temp_Cnt]        ; Event Count
        Mod9_Time= [Mod9_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
            
            
        
        ;
        ; Module10
        ;
        Temp_AvgLT  = Double(LT_Array[10])/Double(LT_Count[10]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[10])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[10]/(LT_Count[10]*1000))  ; Average Altitude Kft

        Mod10_Alt = [Mod10_Alt,Temp_Alt]        ; Event Alt
        Mod10_Cnt = [Mod10_Cnt,Temp_Cnt]        ; Event Count
        Mod10_Time= [Mod10_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
           
            
        
        ;
        ; Module11
        ;
        Temp_AvgLT  = Double(LT_Array[11])/Double(LT_Count[11]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[11])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[11]/(LT_Count[11]*1000))  ; Average Altitude Kft

        Mod11_Alt = [Mod11_Alt,Temp_Alt]        ; Event Alt
        Mod11_Cnt = [Mod11_Cnt,Temp_Cnt]        ; Event Count
        Mod11_Time= [Mod11_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
           
            
        
        ;
        ; Module12
        ;
        Temp_AvgLT  = Double(LT_Array[12])/Double(LT_Count[12]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[12])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[12]/(LT_Count[12]*1000))  ; Average Altitude Kft

        Mod12_Alt = [Mod12_Alt,Temp_Alt]        ; Event Alt
        Mod12_Cnt = [Mod12_Cnt,Temp_Cnt]        ; Event Count
        Mod12_Time= [Mod12_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
          
            
        
        ;
        ; Module13
        ;
        Temp_AvgLT  = Double(LT_Array[13])/Double(LT_Count[13]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[13])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[13]/(LT_Count[13]*1000))  ; Average Altitude Kft

        Mod13_Alt = [Mod13_Alt,Temp_Alt]        ; Event Alt
        Mod13_Cnt = [Mod13_Cnt,Temp_Cnt]        ; Event Count
        Mod13_Time= [Mod13_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
            
            
        
        ;
        ; Module14
        ;
        Temp_AvgLT  = Double(LT_Array[14])/Double(LT_Count[14]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[14])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[14]/(LT_Count[14]*1000))  ; Average Altitude Kft

        Mod14_Alt = [Mod14_Alt,Temp_Alt]        ; Event Alt
        Mod14_Cnt = [Mod14_Cnt,Temp_Cnt]        ; Event Count
        Mod14_Time= [Mod14_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
          
        
        ;
        ; Module17
        ;
        Temp_AvgLT  = Double(LT_Array[17])/Double(LT_Count[17]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[17])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[17]/(LT_Count[17]*1000))  ; Average Altitude Kft

        Mod17_Alt = [Mod17_Alt,Temp_Alt]        ; Event Alt
        Mod17_Cnt = [Mod17_Cnt,Temp_Cnt]        ; Event Count
        Mod17_Time= [Mod17_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
            
            
        ;
        ; Module18
        ;
        Temp_AvgLT  = Double(LT_Array[18])/Double(LT_Count[18]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[18])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[18]/(LT_Count[18]*1000))  ; Average Altitude Kft

        Mod18_Alt = [Mod18_Alt,Temp_Alt]        ; Event Alt
        Mod18_Cnt = [Mod18_Cnt,Temp_Cnt]        ; Event Count
        Mod18_Time= [Mod18_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
           
            
        ;
        ; Module19
        ;
        Temp_AvgLT  = Double(LT_Array[19])/Double(LT_Count[19]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[19])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[19]/(LT_Count[19]*1000))  ; Average Altitude Kft

        Mod19_Alt = [Mod19_Alt,Temp_Alt]        ; Event Alt
        Mod19_Cnt = [Mod19_Cnt,Temp_Cnt]        ; Event Count
        Mod19_Time= [Mod19_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
            
            
        ;
        ; Module20
        ;
        Temp_AvgLT  = Double(LT_Array[20])/Double(LT_Count[20]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[20])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[20]/(LT_Count[20]*1000))  ; Average Altitude Kft

        Mod20_Alt = [Mod20_Alt,Temp_Alt]        ; Event Alt
        Mod20_Cnt = [Mod20_Cnt,Temp_Cnt]        ; Event Count
        Mod20_Time= [Mod20_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
           
            
        ;
        ; Module21
        ;
        Temp_AvgLT  = Double(LT_Array[21])/Double(LT_Count[21]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[21])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[21]/(LT_Count[21]*1000))  ; Average Altitude Kft

        Mod21_Alt = [Mod21_Alt,Temp_Alt]        ; Event Alt
        Mod21_Cnt = [Mod21_Cnt,Temp_Cnt]        ; Event Count
        Mod21_Time= [Mod21_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
           
            
        ;
        ; Module22
        ;
        Temp_AvgLT  = Double(LT_Array[22])/Double(LT_Count[22]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[22])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[22]/(LT_Count[22]*1000))  ; Average Altitude Kft

        Mod22_Alt = [Mod22_Alt,Temp_Alt]        ; Event Alt
        Mod22_Cnt = [Mod22_Cnt,Temp_Cnt]        ; Event Count
        Mod22_Time= [Mod22_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
           
            
        ;
        ; Module24
        ;
        Temp_AvgLT  = Double(LT_Array[24])/Double(LT_Count[24]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[24])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[24]/(LT_Count[24]*1000))  ; Average Altitude Kft

        Mod24_Alt = [Mod24_Alt,Temp_Alt]        ; Event Alt
        Mod24_Cnt = [Mod24_Cnt,Temp_Cnt]        ; Event Count
        Mod24_Time= [Mod24_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
         
           
        ;
        ; Module25
        ;
        Temp_AvgLT  = Double(LT_Array[25])/Double(LT_Count[25]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[25])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[25]/(LT_Count[25]*1000))  ; Average Altitude Kft

        Mod25_Alt = [Mod25_Alt,Temp_Alt]        ; Event Alt
        Mod25_Cnt = [Mod25_Cnt,Temp_Cnt]        ; Event Count
        Mod25_Time= [Mod25_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt

            
        ;
        ; Module27
        ;
        Temp_AvgLT  = Double(LT_Array[27])/Double(LT_Count[27]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[27])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[27]/(LT_Count[27]*1000))  ; Average Altitude Kft

        Mod27_Alt = [Mod27_Alt,Temp_Alt]        ; Event Alt
        Mod27_Cnt = [Mod27_Cnt,Temp_Cnt]        ; Event Count
        Mod27_Time= [Mod27_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
         
            
        ;
        ; Module28
        ;
        Temp_AvgLT  = Double(LT_Array[28])/Double(LT_Count[28]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[28])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[28]/(LT_Count[28]*1000))  ; Average Altitude Kft

        Mod28_Alt = [Mod28_Alt,Temp_Alt]        ; Event Alt
        Mod28_Cnt = [Mod28_Cnt,Temp_Cnt]        ; Event Count
        Mod28_Time= [Mod28_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
         
            
        ;
        ; Module29
        ;
        Temp_AvgLT  = Double(LT_Array[29])/Double(LT_Count[29]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[29])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[29]/(LT_Count[29]*1000))  ; Average Altitude Kft

        Mod29_Alt = [Mod29_Alt,Temp_Alt]        ; Event Alt
        Mod29_Cnt = [Mod29_Cnt,Temp_Cnt]        ; Event Count
        Mod29_Time= [Mod29_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
          
        ;
        ; Module31
        ;
        Temp_AvgLT  = Double(LT_Array[31])/Double(LT_Count[31]) ; Average LT over the period
        Temp_Cnt    = Double(Double(LT_Count[31])*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.
        Temp_Alt    = Double(Alt_Array[31]/(LT_Count[31]*1000))  ; Average Altitude Kft

        Mod31_Alt = [Mod31_Alt,Temp_Alt]        ; Event Alt
        Mod31_Cnt = [Mod31_Cnt,Temp_Cnt]        ; Event Count
        Mod31_Time= [Mod31_Time,AvTime]         ; Event Time
        Tot_Count = Tot_Count+Temp_Cnt
         
        Tot_Count_Err = Sqrt(Tot_Count)                     
        Print, TIme_Diff, AvTime, Event_Data[i].SweepNo, Tot_Count


        Sum_Count = [SUm_Count,Tot_Count]
        Sum_Count_Err=[Sum_Count_Err, Tot_Count_Err]
        Sum_Alt   = [SUm_Alt, Temp_Alt  ]
        Sum_Time  = [SUm_Time,  AVTime  ]
        Sum_Zen   = [Sum_Zen, AvZen]
        Sum_Dep   = [Sum_Dep, AvDep]
        
        ;STDEV Calc
        Dep_Stdev = Sqrt( (EvtDep2/(EvtCntr-1)) - AvDep*AvDep)
        Zen_Stdev = Sqrt( (EvtZen2/(EvtCntr-1)) - AvZen*AvZen)
        Print, Zen_Stdev, EvtZen2, AvZen, EvtCntr,( (EvtZen2/(EvtCntr-1)) - AvZen*AvZen)
        
        Sum_Dep_Err = [Sum_Dep_err, Dep_Stdev]
        Sum_Zen_Err = [Sum_Zen_Err, Zen_Stdev]
        Sum_Azi   = [Sum_Azi, AvAzi]
        For j =0, 31 Do Begin
              LT_Array[j]=0.0D
              LT_COunt[j]=0.0D
              Alt_ARray[j]=0.0D
        EndFor
        No_Events=0L
        Evtime = 0.0D
        EvtDep = 0.0D
        EvtDep2=0.0D
        EvtZen = 0.0D
        EvtCntr=0L
        EvtAzi =0.0D
        Old_Time = Time
        Tot_Count = 0.0D
      Endif

      Jump_Packet:
      If i mod 100000 EQ 0 Then print, i
    EndFor; /i

  EndFor; /p

;
;-- Trim these arrays for removal for the 1st value--
;

Mod0_Cnt = Mod0_Cnt[1:N_Elements(Mod0_Cnt)-1]
Mod2_Cnt = Mod2_Cnt[1:N_Elements(Mod2_Cnt)-1]
Mod3_Cnt = Mod3_Cnt[1:N_Elements(Mod3_Cnt)-1]
Mod4_Cnt = Mod4_Cnt[1:N_Elements(Mod4_Cnt)-1]
Mod6_Cnt = Mod6_Cnt[1:N_Elements(Mod6_Cnt)-1]
Mod7_Cnt = Mod7_Cnt[1:N_Elements(Mod7_Cnt)-1]
Mod9_Cnt = Mod9_Cnt[1:N_Elements(Mod9_Cnt)-1]

Mod10_Cnt = Mod10_Cnt[1:N_Elements(Mod10_Cnt)-1]
Mod11_Cnt = Mod11_Cnt[1:N_Elements(Mod11_Cnt)-1]
Mod12_Cnt = Mod12_Cnt[1:N_Elements(Mod12_Cnt)-1]
Mod13_Cnt = Mod13_Cnt[1:N_Elements(Mod13_Cnt)-1]
Mod14_Cnt = Mod14_Cnt[1:N_Elements(Mod14_Cnt)-1]
Mod17_Cnt = Mod17_Cnt[1:N_Elements(Mod17_Cnt)-1]
Mod18_Cnt = Mod18_Cnt[1:N_Elements(Mod18_Cnt)-1]
Mod19_Cnt = Mod19_Cnt[1:N_Elements(Mod19_Cnt)-1]

Mod20_Cnt = Mod20_Cnt[1:N_Elements(Mod20_Cnt)-1]
Mod21_Cnt = Mod21_Cnt[1:N_Elements(Mod21_Cnt)-1]
Mod22_Cnt = Mod22_Cnt[1:N_Elements(Mod22_Cnt)-1]
Mod24_Cnt = Mod24_Cnt[1:N_Elements(Mod24_Cnt)-1]
Mod25_Cnt = Mod25_Cnt[1:N_Elements(Mod25_Cnt)-1]
Mod27_Cnt = Mod27_Cnt[1:N_Elements(Mod27_Cnt)-1]
Mod28_Cnt = Mod28_Cnt[1:N_Elements(Mod28_Cnt)-1]
Mod29_Cnt = Mod29_Cnt[1:N_Elements(Mod29_Cnt)-1]
Mod31_Cnt = Mod31_Cnt[1:N_Elements(Mod31_Cnt)-1]


;
;--
;
Mod0_Alt = Mod0_Alt[1:N_Elements(Mod0_Alt)-1]
Mod2_Alt = Mod2_Alt[1:N_Elements(Mod2_Alt)-1]
Mod3_Alt = Mod3_Alt[1:N_Elements(Mod3_Alt)-1]
Mod4_Alt = Mod4_Alt[1:N_Elements(Mod4_Alt)-1]
Mod6_Alt = Mod6_Alt[1:N_Elements(Mod6_Alt)-1]
Mod7_Alt = Mod7_Alt[1:N_Elements(Mod7_Alt)-1]
Mod9_Alt = Mod9_Alt[1:N_Elements(Mod9_Alt)-1]

Mod10_Alt = Mod10_Alt[1:N_Elements(Mod10_Alt)-1]
Mod11_Alt = Mod11_Alt[1:N_Elements(Mod11_Alt)-1]
Mod12_Alt = Mod12_Alt[1:N_Elements(Mod12_Alt)-1]
Mod13_Alt = Mod13_Alt[1:N_Elements(Mod13_Alt)-1]
Mod14_Alt = Mod14_Alt[1:N_Elements(Mod14_Alt)-1]
Mod17_Alt = Mod17_Alt[1:N_Elements(Mod17_Alt)-1]
Mod18_Alt = Mod18_Alt[1:N_Elements(Mod18_Alt)-1]
Mod19_Alt = Mod19_Alt[1:N_Elements(Mod19_Alt)-1]

Mod20_Alt = Mod20_Alt[1:N_Elements(Mod20_Alt)-1]
Mod21_Alt = Mod21_Alt[1:N_Elements(Mod21_Alt)-1]
Mod22_Alt = Mod22_Alt[1:N_Elements(Mod22_Alt)-1]
Mod24_Alt = Mod24_Alt[1:N_Elements(Mod24_Alt)-1]
Mod25_Alt = Mod25_Alt[1:N_Elements(Mod25_Alt)-1]
Mod27_Alt = Mod27_Alt[1:N_Elements(Mod27_Alt)-1]
Mod28_Alt = Mod28_Alt[1:N_Elements(Mod28_Alt)-1]
Mod29_Alt = Mod29_Alt[1:N_Elements(Mod29_Alt)-1]
Mod31_Alt = Mod31_Alt[1:N_Elements(Mod31_Alt)-1]

;
;--
;
Mod0_Time = Mod0_Time[1:N_Elements(Mod0_Time)-1]
Mod2_Time = Mod2_Time[1:N_Elements(Mod2_Time)-1]
Mod3_Time = Mod3_Time[1:N_Elements(Mod3_Time)-1]
Mod4_Time = Mod4_Time[1:N_Elements(Mod4_Time)-1]
Mod6_Time = Mod6_Time[1:N_Elements(Mod6_Time)-1]
Mod7_Time = Mod7_Time[1:N_Elements(Mod7_Time)-1]
Mod9_Time = Mod9_Time[1:N_Elements(Mod9_Time)-1]

Mod10_Time = Mod10_Time[1:N_Elements(Mod10_Time)-1]
Mod11_Time = Mod11_Time[1:N_Elements(Mod11_Time)-1]
Mod12_Time = Mod12_Time[1:N_Elements(Mod12_Time)-1]
Mod13_Time = Mod13_Time[1:N_Elements(Mod13_Time)-1]
Mod14_Time = Mod14_Time[1:N_Elements(Mod14_Time)-1]
Mod17_Time = Mod17_Time[1:N_Elements(Mod17_Time)-1]
Mod18_Time = Mod18_Time[1:N_Elements(Mod18_Time)-1]
Mod19_Time = Mod19_Time[1:N_Elements(Mod19_Time)-1]

Mod20_Time = Mod20_Time[1:N_Elements(Mod20_Time)-1]
Mod21_Time = Mod21_Time[1:N_Elements(Mod21_Time)-1]
Mod22_Time = Mod22_Time[1:N_Elements(Mod22_Time)-1]
Mod24_Time = Mod24_Time[1:N_Elements(Mod24_Time)-1]
Mod25_Time = Mod25_Time[1:N_Elements(Mod25_Time)-1]
Mod27_Time = Mod27_Time[1:N_Elements(Mod27_Time)-1]
Mod28_Time = Mod28_Time[1:N_Elements(Mod28_Time)-1]
Mod29_Time = Mod29_Time[1:N_Elements(Mod29_Time)-1]
Mod31_Time = Mod31_Time[1:N_Elements(Mod31_Time)-1]


  ; Create a text file with the values to be imported in an excel sheet.
  Openw, LUn, Cur+'/'+Title+'_'+Strn(Scl_Time)+'_Inves.txt',/Get_Lun
  TempText = ' Time Altitude Dep Zen Mod0 Mod2 Mod3 Mod4 Mod6 Mod7 Mod9 Mod10 Mod11 Mod12 Mod13 Mod14 Mod17 Mod18 Mod19 Mod20 Mod21 Mod22 Mod24 Mod25 Mod27 Mod28 Mod29 Mod31 '
  Printf, Lun, tempText

  ;Module 0
  For i =0, N_Elements(Mod0_Alt)-1 Do Begin
    Printf, Lun, Mod0_Time[i],  Mod0_Alt[i], Mod0_Dep[i], Mod0_Zen[i], Mod0_Cnt[i],  Mod2_Cnt[i],  Mod3_Cnt[i],  MOd4_Cnt[i],  Mod6_Cnt[i], $
                 Mod7_Cnt[i],   Mod9_Cnt[i], Mod10_Cnt[i], Mod11_Cnt[i], Mod12_Cnt[i], Mod13_Cnt[i], Mod14_Cnt[i], $
                 Mod17_Cnt[i], Mod18_Cnt[i], Mod19_Cnt[i], Mod20_Cnt[i], Mod21_Cnt[i], Mod22_Cnt[i], Mod24_Cnt[i], $
                 Mod25_Cnt[i], Mod27_Cnt[i], Mod28_Cnt[i], Mod29_Cnt[i], Mod31_Cnt[i], $
      format = '(F11.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2)'
      ;                     Alt       Dep      Zen     0         2       3       4         6         7       9         10      11        12      13      14      17        18       19       20        21      22        24      25        27      28      29        31
      
  Endfor
    Free_Lun, Lun
  


  Openw, Lun1, Cur+'/'+Title+'_'+Strn(Scl_Time)+'.txt',/Get_Lun
  Printf,lun1, ' For the time scale '+Strn(Scl_Time)
  Printf,lun1, ' Time  Alt   Dep  Dep_Err Zen Zen_Err Azi  Count CountErr'
      For i=1,  N_Elements(Sum_Count)-1 Do Begin
          Printf, Lun1, Sum_Time[i], Sum_Alt[i], Sum_Dep[i], Sum_Dep_Err[i], SUm_Zen[i], Sum_Zen_Err[i], Sum_Azi[i], Sum_Count[i]/Scl_Time, Sum_Count_Err[i]/Scl_Time,$
                format = '(F11.2,1X, F8.2,1X,  F8.2,1X, F8.2,1X, F8.2,1X,F8.2,1X, F8.2, 1X,F8.2, 1X, F8.4 )'
      Endfor
  Free_Lun, Lun1
  
  Openw, Lun2, Cur+'/'+Title+'_'+Strn(Scl_Time)+'Anode_Cnt.txt',/Get_Lun
      For i = 0,63 Do Begin
        Temp_Str = ''
            For j = 0, 31 Do Begin
                
                Temp_Str = Temp_Str+ String(Anode_Cnt[j, i], format = '(I11.2,1X)' )
            Endfor
            
            Printf, Lun2, Temp_Str
      Endfor
  
  Free_Lun, Lun2


  ;
  ;-- Now create the 3-D plot --
  ;
  Stop
End