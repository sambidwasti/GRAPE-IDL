Pro Grp_L2v7_Flt_Investigate1, fsearch_String, Title= Title, nfiles=nfiles, Scl_Time=Scl_Time


  ;
  ;     look at the each anode of a selective module and get a text file with counts vs time and alt.
  ;     We want 1 point for each sweep so scl time ~~ 720
  ;

  True = 1
  False= 0
  

  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 12.0
  Pla_EMax = 200.00

  Cal_EMin = 30.0
  Cal_EMax = 400.00

  Tot_EMin = 80.00
  Tot_EMax = 200.00


  PMax= 1500 ; Max value of energy for energy histogram.
  Cd, Cur=Cur

  IF Keyword_Set(title) Eq 0 Then Title='Test'


  c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration
  
  For i = 0,N_Elements(C2014)-1 Do Begin
         k = c2014[i]
         Filename = Cur+'/Mod_'+STRN(k)+'.txt'
          Openw, Lun, Filename, /Get_Lun
          Printf, Lun, ' Time Alt 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63'
          Free_Lun, Lun
          
  Endfor
  
  
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

 
  LT_Array = DblArr(32)
  LT_Count = DblArr(32)
  Alt_Array = DblArr(32)

  Sum_Count = [0.0D]
  Sum_Alt   = [0.0D]
  Sum_Time  = [0.0D]

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
    Total_LT       = 0.0D


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
    print, TotPkt
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
    For i = 0, TotPkt-1 Do Begin

      Time = Event_Data[i].EvTime

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

            Anode_Cnt[m,Event_Data[i].ANODEID1]++
            Anode_Cnt[m,Event_Data[i].ANODEID2]++





      ; Live-Time
      LT_Array[m] = LT_Array[m]+LiveTime
      LT_Count[m]++
      No_Events++

      EvTime = Time + EVTime
      EvtCntr++

      Jump_Packet:
      If i mod 100000 EQ 0 Then print, i
   
    EndFor; /i
    
    ; === For each of the file ===
    AvTime = Avg(Event_data.Evtime)
    AvAlt  = Avg(Event_data.Alt)

    For j = 0,N_Elements(C2014)-1 Do Begin
        k = c2014[j]
        Filename = Cur+'/Mod_'+STRN(k)+'.txt'

        Openw, Lun, Filename, /Get_Lun, /Append
      
        Temp_Text = String(AvTime, AvAlt, format = '(F11.2,1X,F11.2,1X)' )
        
        Temp_AvgLT = Double(LT_Array[k])/Double(LT_Count[k]) ; Average LT over the period
        
        For i = 0,63 Do Begin
          Temp_Cnt = Double(Anode_Cnt[k,i])/Double(Temp_AvgLT)
          Temp_Text = Temp_Text + String(Temp_Cnt, format = '(F11.2,1X)' )
        EndFor ;i
        Printf, Lun, Temp_Text
        Free_LUn, Lun
    EndFor
    
    
    
    
    For j =0, 31 Do Begin
      LT_Array[j]=0.0D
      LT_COunt[j]=0.0D
            For i = 0, 63 Do Begin
                  Anode_Cnt[j,i]=0L
            EndFor  

    EndFor
    
   EndFor; /p




  ;
  ;-- Now create the 3-D plot --
  ;
  Stop
End