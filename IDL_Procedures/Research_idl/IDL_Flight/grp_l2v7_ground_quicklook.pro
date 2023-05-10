Pro Grp_l2v7_Ground_quicklook, fsearch_String, nfiles=nfiles, title= title
  ;
  ; Reading in Level 2 version 7 data.
  ; Do some energy selection and some calculation to do per sweep stuff.
  ; Creating hardware upper and lower limit files.?
  ;
  ;
  ;

  True = 1
  False= 0

  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 12.0
  Pla_EMax = 200.00

  Cal_EMin = 40.0
  Cal_EMax = 400.00

  Tot_EMin = 70.00
  Tot_EMax = 300.00

  ;
  ;-- Get the array of event files.
  ;
  Evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files


  c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration

  ;
  ;-- Total no. of files --
  ;
  If keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)
  nsweep = nfiles

  Hdw_Upper = INTARR(32,64)
  Hdw_Lower = IntArr(32,64)

  ;
  ;-- Start time
  ;
  ;Start_Time = 477264


  ;
  ;-- Title --
  ;
  IF Keyword_Set(title) Eq 0 Then Title='Test'


  ;
  ;-- Current Directory --
  ;
  CD, Cur = Cur

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

    EVCLASS:0,          $   ; Event Class (1=C, 2=CC, 3=PC, 4= intermdule)
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

  ;
  ;--- Each Sweep Data
  ;
  Swp_Alt_Ar    = DblArr(nsweep)
  Swp_Time_Ar   = [0.0]
  Swp_Anodes_Ar = [0L]
  Swp_Depth_Ar  = [0.0]
  Swp_CorLT_Ar  = [0.0]
  Swp_LT_Ar     = [0.0]
  Swp_SweepNo_Ar= [0L]
  Swp_Evt_Ar  = DblArr(nsweep)
  Swp_PC_Ar   = [0L]

  ;
  ;-- Calculated stuffs --
  ;
  Scaled_No_Events = DblArr(nsweep)
  PC_T1_Events     = DblArr(nsweep)
  PC_T2_Events     = DblArr(nsweep)
  PC_T3_Events     = DblArr(nsweep)
  Sweep_Ar         = Indgen(nsweep)



  For p = 0, nfiles-1 Do Begin

    LT_Arr = DBLArr(32)
    LT_Cnt = DBLArr(32)

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

    Temp_Counter    = 0.0
    Avg_LT          = 0.0
    Avg_LT_Counter  = 0L

    PC_Counter      = LONARR(32)
    PC_T1_Counter   = LONARR(32)
    PC_T2_Counter   = 0L
    PC_T3_Counter   = 0L

    Compt_Err_Count = 0L

    For i = 0, TotPkt-1 Do Begin
      anode = Event_Data[i].pa_mod

      LT_Arr[anode] = LT_Arr[anode]+ Event_Data[i].CorrectLT
      LT_Cnt[anode]++

      If Event_Data[i].QFlag EQ 10 Then Begin
        If (Event_Data[i].EVClass EQ 3) and (Event_Data[i].NAnodes EQ 2) Then Begin

          ; Do Energy Checks.

          If Event_Data[i].AnodeTyp1 EQ 1 Then Begin    ; Its a Plastic so check these
            If (Event_Data[i].AnodeNRG1 LT Pla_EMIN) or (Event_Data[i].AnodeNRG1 GT Pla_EMAX) Then Goto, Jump_Packet
          EndIf Else If  Event_Data[i].AnodeTyp1 EQ 2 Then Begin    ; Its a Plastic so check these
            If (Event_Data[i].AnodeNRG1 LT Cal_EMIN) or (Event_Data[i].AnodeNRG1 GT Cal_EMAX) Then Goto, Jump_Packet
          EndIf

          If Event_Data[i].AnodeTyp2 EQ 1 Then Begin    ; Its a Cal so check these
            If (Event_Data[i].AnodeNRG2 LT Pla_EMIN) or (Event_Data[i].AnodeNRG2 GT Pla_EMAX) Then Goto, Jump_Packet
          EndIf Else If  Event_Data[i].AnodeTyp2 EQ 2 Then Begin    ; Its a Plastic so check these
            If (Event_Data[i].AnodeNRG2 LT Cal_EMIN) or (Event_Data[i].AnodeNRG2 GT Cal_EMAX) Then Goto, Jump_Packet
          EndIf

          ; Total Energy
          Total_Energy = Event_Data[i].AnodeNRG1 + EVent_Data[i].AnodeNRG2
          If (Total_Energy LT Tot_EMIN) OR (Total_Energy GT Tot_EMAx) Then Goto, Jump_Packet

          PC_Counter[anode]++
          ;      print, '*'
          IF Event_Data[i].EVType EQ 1 Then PC_T1_Counter[anode]++
          IF Event_Data[i].EVType EQ 2 Then PC_T2_Counter++
          IF Event_Data[i].EVType EQ 3 Then PC_T3_Counter++
        Endif

      Endif
      Jump_Packet:
    EndFor
    Temp_PC_Cnt= 0.0D
    Temp_PC1_Cnt= 0.0D
    ;   print, PC_Counter
    For j = 0,31 Do Begin
      If (where (j EQ c2014) GE 0) Then Begin
        Temp_AvgLT = Double(LT_Arr[j])/Double(LT_Cnt[j]) ; Average LT over the period
        Temp_PC_Cnt= Temp_PC_Cnt+PC_Counter[j]/Temp_AvgLT
        Temp_PC1_Cnt= Temp_PC1_Cnt+PC_T1_Counter[j]/Temp_AvgLT
      EndIf
    EndFor

    Sweep_No = p
    
    Average_LT = Avg_LT/Avg_LT_Counter

    Scaled_No_Events[Sweep_no] = Temp_PC_Cnt/(Max(Event_Data.Swtime)) ; we have (Avg_LT_Counter)* Avg_LT/Avg_LT_Counter * 720/ (Total Time * 720) for the sweep
    PC_T1_Events[Sweep_no]     = Temp_PC1_Cnt/(Max(Event_Data.Swtime))

    ;PC_T1_Counter/(Average_LT*(Max(Event_Data.Swtime))) ; we have (Avg_LT_Counter)* Avg_LT/Avg_LT_Counter * 720/ (Total Time * 720) for the sweep
    PC_T2_Events[Sweep_no] = PC_T2_Counter/(Average_LT*(Max(Event_Data.Swtime))) ; we have (Avg_LT_Counter)* Avg_LT/Avg_LT_Counter * 720/ (Total Time * 720) for the sweep
    PC_T3_Events[Sweep_no] = PC_T3_Counter/(Average_LT*(Max(Event_Data.Swtime))) ; we have (Avg_LT_Counter)* Avg_LT/Avg_LT_Counter * 720/ (Total Time * 720) for the sweep


    ;--- Per Sweep Data Generated directly ---
    Swp_Alt_Ar[Sweep_no]=Avg(Event_Data.Alt)
    Swp_Evt_Ar[Sweep_no]= TotPkt
    ;Swp_Time_Ar=[Swp_Time_Ar, Avg(Event_Data.SwTime)+Event_Data[i-1].SwStart]

    Swp_SweepNo_Ar= [Swp_SweepNo_Ar,Sweep_no]


    jump_file:

  EndFor ; p
  Print, Scaled_No_Events
  ;  Scaled_No_Events = Scaled_No_Events[where(Scaled_No_Events NE 0)]
  ;  PC_T1_Events     =  PC_T1_Events[where( PC_T1_Events  NE 0)];  ;  CgPS_Close
  ;  PC_T1_Events     =  PC_T2_Events[where( PC_T2_Events  NE 0)];  ;  CgPS_Close
  ;  PC_T1_Events     =  PC_T3_Events[where( PC_T3_Events  NE 0)];  ;  CgPS_Close


  ;Swp_Alt  = Swp_Alt_Ar[1:N_Elements(Swp_Alt_Ar)-1]

  ;Swp_Evt   = Swp_Evt_Ar[1:N_Elements(Swp_Evt_Ar)-1]
  ;Swp_SweepNo= Swp_SweepNo_Ar[1:N_Elements(Swp_SweepNo_Ar)-1]
  Swp_Alt  = Swp_Alt_Ar
  Swp_Evt   = Swp_Evt_Ar
  Swp_SweepNo=Sweep_Ar

  Xrange =[0,10]

  cgPS_Open, Title+'_Level2_Ground_quicklook.ps', Font=1
  cgDisplay, 800, 800
  cgLoadCT, 13

  CgPlot, Swp_SweepNo, (Swp_Alt/(1000.0)), Xtitle ='Sweep Number',Title='Altitude',Ytitle='Altitude (kft)',$; XRange=xrange,XStyle=1,PSYM=45$;,YRange = [ 110,135], $
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

  CgPlot, Swp_SweepNo, (Swp_Evt_Ar/(10000)), Xtitle ='Sweep Number',Title=' Total no. of Events',YTitle= ' Counts (10^4)/ Sec',$;  XRange=xrange,PSYM=45,XStyle=1$;,YRange= [28,37], YStyle=1, $
    Position= cgLayout([1,2,2],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

  CgText, !D.X_Size*0.78,!D.Y_Size*0.97, 'Pla = 6~200 kev',/Device,Charsize=1.0
  CgText, !D.X_Size*0.78,!D.Y_Size*0.95, 'Cal = 20~400 kev',/Device,Charsize=1.0
  CgText, !D.X_Size*0.78,!D.Y_Size*0.93, 'Tot = 80~200 kev',/Device,Charsize=1.0

  CgErase; Next Page

  CgPlot,Swp_SweepNo,Scaled_No_Events, Xtitle ='Sweep Number',Title=' PC Counts',YTitle=' Counts/ Sec',$;XRange=[20,102],XStyle=1, PSYM=45,YRange= [10,20], YStyle=1, $
    Position= cgLayout([1,2,1],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase, PSYM=10
  CgText, !D.X_Size*0.78,!D.Y_Size*0.97, 'Pla = 6~200 kev',/Device,Charsize=1.0
  CgText, !D.X_Size*0.78,!D.Y_Size*0.95, 'Cal = 20~400 kev',/Device,Charsize=1.0
  CgText, !D.X_Size*0.78,!D.Y_Size*0.93, 'Tot = 80~200 kev',/Device,Charsize=1.0

  ;'Altitude =('+STRN(Float(Altitude))+'+/- 0.1)kFt',/DEVICE, CHarSize=2.0

  CgPlot, Swp_SweepNo*2, PC_T1_Events, Xtitle ='Sweep Number',Title=' Normalized PC Type 1',YTitle=' Counts/ Sec',$
    $;XRange=[20,102],PSYM=45,XStyle=1,$;YRange= [5,10], YStyle=1, $
    Position= cgLayout([1,2,2],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase, PSYM=10

  CgErase

  CgPlot,Swp_SweepNo, PC_T2_Events, Xtitle ='Sweep Number',Title=' Normalized PC Type 2',YTitle=' Counts/ Sec',$
    XRange=[20,102],XStyle=1, PSYM=45,$;YRange= [12,22], YStyle=1, $
    Position= cgLayout([1,2,1],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase


  CgPlot, Swp_SweepNo, PC_T3_Events, Xtitle ='Sweep Number',Title=' Normalized PC Type 3',YTitle=' Counts/ Sec',$
    XRange=[20,102],PSYM=45,XStyle=1,$;YRange= [5,10], YStyle=1, $
    Position= cgLayout([1,2,2],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

  cgPS_Close
  Temp_Str = Title+'_Level2_Ground_quicklook.ps'
  CGPS2PDF, Temp_Str,delete_ps=1

  Skip_Plot2:
  Stop
End