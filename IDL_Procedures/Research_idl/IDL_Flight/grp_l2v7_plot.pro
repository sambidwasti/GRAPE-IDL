Pro Grp_L2v7_Plot, fsearch_String, Title= Title, nfiles=nfiles, Scl_Time=Scl_Time


  ;
  ;      Create Energy plots (lower and upper) to see what the lower/upper limits are
  ;      From L1 version 7 files.
  ;

  True = 1
  False= 0

  IF Keyword_Set(Scl_Time) Eq 0 Then Scl_Time =1


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
  Avg_Cnt = [0.0D]    ; Average Count Array.
  Avg_Alt = [0.0D]    ; Average Altitude Array.
  Avg_Zen = [0.0D]    ; Average Zenith Array.

  Avg_Sun_Alt = [0.0D]
  Avg_Crb_Alt = [0.0D]
  Avg_Blk2_Alt= [0.0D]
  Avg_Blk4_Alt= [0.0D]
  Avg_Cyg_Alt = [0.0D]

  Avg_Sun_Zen = [0.0D]
  Avg_Crb_Zen = [0.0D]
  Avg_Blk2_Zen= [0.0D]
  Avg_Blk4_Zen= [0.0D]
  Avg_Cyg_Zen = [0.0D]

  Avg_Sun_Cnt = [0.0D]
  Avg_Crb_Cnt = [0.0D]
  Avg_Blk2_Cnt= [0.0D]
  Avg_Blk4_Cnt= [0.0D]
  Avg_Cyg_Cnt = [0.0D]

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

    For i = 0, TotPkt-1 Do Begin

      Time = Event_Data[i].EvTime

      ;If Event_Data[i].QFlag NE 10 Then Goto, Jump_Packet
      IF Event_Data[i].ACFlag EQ 0 Then Goto, Jump_Packet
      
      LiveTime = Event_Data[i].CorrectLT

      If (Event_Data[i].RtStat LT 5) Then Goto, Jump_Packet
      If (Event_Data[i].RtStat EQ 7) and (End_Swp_Flag EQ True) Then Goto, Jump_Packet


      ;
      ;-- Counters to Add so that we can average in a block.
      ;

      ; Altitude
      Total_Altitude = Total_Altitude + Event_Data[i].Alt

      ; Zenith
      Zenith = Event_Data[i].PntZen
      If Zenith GT 60 THen Zenith= Zenith - 360.0D
      Total_Zenith = total_Zenith+Zenith

      ; Live-Time
      Total_LT = Total_LT+LiveTime

      ; Event Counter
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
        Goto, Jump_Avg
      EndIf

      ;
      ;-- Run this/ Average at a specific Intervals.
      ;
      If Time_Diff GE Scl_Time Then begin

        Jump_Avg:
        Temp_AvgLT = Double(Total_LT)/Double(No_Events) ; Average LT over the period

        Temp_Cnt = Double(Double(No_Events)*Scl_Time/Double(Time_Diff*Temp_AvgLT))  ; Scaled Count.

        Avg_Cnt = [Avg_Cnt,Temp_Cnt]    ; Average Count Array

        Temp_Alt = DOuble(Total_Altitude/(No_Events*1000))  ; Average Altitude Kft
        Avg_Alt = [Avg_Alt,Temp_Alt]

        Temp_Zen = Double(Total_Zenith)/Double(No_Events)   ; Average Zenith
        Avg_Zen = [ Avg_Zen,Temp_Zen ]

        If Event_Data[i].Source EQ 1 Then Begin ; this is crab
          Avg_Crb_Alt = [Avg_Crb_Alt, Temp_Alt]
          Avg_Crb_Zen = [Avg_Crb_Zen, Temp_Zen]
          Avg_Crb_Cnt = [Avg_Crb_Cnt, Temp_Cnt]
        Endif

        If Event_Data[i].Source EQ 2 Then Begin ; this is crab
          Avg_Sun_Alt = [Avg_Sun_Alt, Temp_Alt]
          Avg_Sun_Zen = [Avg_Sun_Zen, Temp_Zen]
          Avg_Sun_Cnt = [Avg_Sun_Cnt, Temp_Cnt]
        Endif

        If Event_Data[i].Source EQ 6 Then Begin ; this is crab
          Avg_Blk2_Alt = [Avg_Blk2_Alt, Temp_Alt]
          Avg_Blk2_Zen = [Avg_Blk2_Zen, Temp_Zen]
          Avg_Blk2_Cnt = [Avg_Blk2_Cnt, Temp_Cnt]
        Endif

        If Event_Data[i].Source EQ 7 Then Begin ; this is crab
          Avg_Blk4_Alt = [Avg_Blk4_Alt, Temp_Alt]
          Avg_Blk4_Zen = [Avg_Blk4_Zen, Temp_Zen]
          Avg_Blk4_Cnt = [Avg_Blk4_Cnt, Temp_Cnt]
        Endif

        If Event_Data[i].Source EQ 4 Then Begin ; this is crab
          Avg_Cyg_Alt = [Avg_Cyg_Alt, Temp_Alt]
          Avg_Cyg_Zen = [Avg_Cyg_Zen, Temp_Zen]
          Avg_Cyg_Cnt = [Avg_Cyg_Cnt, Temp_Cnt]
        Endif

        Total_LT        =0.0D
        Total_Zenith    =0L
        Total_Altitude  =0L
        No_Events=0L

        Old_Time = Time

      Endif

      ;;      If ( ((Double(Event_Data[i].Altitude)/1000.0D) GT  Altitude-0.1) and  ((Double(Event_Data[i].Altitude)/1000.0D) LT  Altitude+0.1) ) Then Begin
      ;        Spec_No_Events++
      ;        Spec_Tot_Cnt++
      ;        Spec_Tot_Zen = Spec_Tot_Zen+Zenith
      ;        Spec_Tot_Lt  = Spec_Tot_Lt+LiveTime
      ;      Endif
      ;
      ;      If (Spec_Time_Diff GE Scl_Time) and (Spec_No_Events GE 1)  Then begin
      ;        Print, '1'
      ;        Temp_LT = Double(Spec_Tot_LT)/Double(Spec_No_Events)
      ;
      ;        Temp_Cnt = Double(Double(Spec_Tot_Cnt)*Scl_Time/Double(Spec_Time_Diff*Temp_LT))
      ;        Spec_Cnt = [Spec_Cnt,Temp_Cnt]
      ;
      ;        Temp_Zen = Double(Spec_Tot_Zen)/Double(Spec_No_Events)
      ;        Spec_Zen = [ Spec_Zen,Temp_Zen ]
      ;
      ;        Spec_Tot_Cnt = 0L
      ;        Spec_Old_Time = Time
      ;        Spec_No_Events=0L
      ;        Spec_Tot_Zen =0L
      ;        Spec_Tot_LT = 0.0D
      ;      Endif



      Jump_Packet:
      If i mod 100000 EQ 0 Then print, i
    EndFor; /i

  EndFor; /p
  Avg_Cnt = Avg_Cnt[1:N_Elements(Avg_Cnt)-1]
  Avg_Alt = Avg_Alt[1:N_Elements(Avg_Alt)-1]
  Avg_Zen = Avg_Zen[1:N_Elements(Avg_Zen)-1]

  Avg_Crb_Alt = Avg_Crb_Alt[1:N_Elements(Avg_Crb_Alt)-1]
  Avg_Crb_Zen = Avg_Crb_Zen[1:N_Elements(Avg_Crb_Zen)-1]
  Avg_Crb_Cnt = Avg_Crb_Cnt[1:N_Elements(Avg_Crb_Cnt)-1]

  Avg_Sun_Alt = Avg_Sun_Alt[1:N_Elements(Avg_Sun_Alt)-1]
  Avg_Sun_Zen = Avg_Sun_Zen[1:N_Elements(Avg_Sun_Zen)-1]
  Avg_Sun_Cnt = Avg_Sun_Cnt[1:N_Elements(Avg_Sun_Cnt)-1]

  Avg_Blk2_Alt = Avg_Blk2_Alt[1:N_Elements(Avg_Blk2_Alt)-1]
  Avg_Blk2_Zen = Avg_Blk2_Zen[1:N_Elements(Avg_Blk2_Zen)-1]
  Avg_Blk2_Cnt = Avg_Blk2_Cnt[1:N_Elements(Avg_Blk2_Cnt)-1]

  Avg_Blk4_Alt = Avg_Blk4_Alt[1:N_Elements(Avg_Blk4_Alt)-1]
  Avg_Blk4_Zen = Avg_Blk4_Zen[1:N_Elements(Avg_Blk4_Zen)-1]
  Avg_Blk4_Cnt = Avg_Blk4_Cnt[1:N_Elements(Avg_Blk4_Cnt)-1]

  Avg_Cyg_Alt = Avg_Cyg_Alt[1:N_Elements(Avg_Cyg_Alt)-1]
  Avg_Cyg_Zen = Avg_Cyg_Zen[1:N_Elements(Avg_Cyg_Zen)-1]
  Avg_Cyg_Cnt = Avg_Cyg_Cnt[1:N_Elements(Avg_Cyg_Cnt)-1]

  ;  help, spec_Cnt
  ;  Spec_Cnt= Spec_Cnt[1:N_Elements(Spec_Cnt)-1]
  ;  Spec_Zen = Spec_Zen[1:N_Elements(Spec_Zen)-1]

  ;dist1 = Scatterplot3d(Avg_Alt, Avg_Zen, Avg_Cnt, Sym_Object=ORB(), /SYM_Filled, $
  ;       XTITLE='Altitude', $
  ;       YTITLE='Zen', $
  ;       ZTITLE='Total', $
  ;       TITLE='dafsdfasdfas', $
  ;       RGB_TABLE=7, AXIS_STYLE=2, SYM_SIZE=1, MAGNITUDE=Avg_Cnt)



  cgPS_Open, Title+'_Plots.ps', Font=1
  cgDisplay, 800, 800
  cgLoadCT, 13

  Str_Title = Title+'_Counts Vs Zenith Angle'

  Ymax = Max(Avg_Cnt)*1.2

  ; Counts vs Zenith
  CgScatter2D, Avg_Crb_Zen, Avg_Crb_Cnt, Fit=0, Xtitle ='Zenith Angle (Deg)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',SymSize=0.5,Xrange=[-5,60],Xstyle=1,$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), PSYM=45,Color='red',/noerase

  CgScatter2D, Avg_Sun_Zen, Avg_Sun_Cnt, Fit=0, Xtitle ='Zenith Angle (Deg)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',SymSize=0.5,Xrange=[-5,60],Xstyle=1,$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), PSYM=45,Color='Blue',/noerase,/Overplot

  CgScatter2D, Avg_Blk2_Zen, Avg_Blk2_Cnt, Fit=0, Xtitle ='Zenith Angle (Deg)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',SymSize=0.5,Xrange=[-5,60],Xstyle=1,$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), PSYM=45,Color='Dark Green',/noerase,/Overplot

  CgScatter2D, Avg_Blk4_Zen, Avg_Blk4_Cnt, Fit=0, Xtitle ='Zenith Angle (Deg)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',SymSize=0.5,Xrange=[-5,60],Xstyle=1,$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), PSYM=45,Color='Green',/noerase,/Overplot

  CgScatter2D, Avg_Cyg_Zen, Avg_Cyg_Cnt, Fit=0, Xtitle ='Zenith Angle (Deg)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',SymSize=0.5,Xrange=[-5,60],Xstyle=1,$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), PSYM=45,Color='Orange',/noerase,/Overplot

  CgPlot, Avg_Cyg_Zen, Avg_Cyg_Cnt, Fit=0, Xtitle ='Zenith Angle (Deg)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',Xrange=[-5,60],Xstyle=1,$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), Color='brown',/noerase,/Overplot

  CgText, !D.X_Size*0.78,!D.Y_Size*0.00, 'Data Collected Per '+STRN(Scl_Time)+'s',/DEVICE, CHarSize=2.0

  ;Counts vs Altitude
  Str_Title = Title+'_Counts Vs Altitude'


  legendObj = Obj_New('cgLegendItem', Colors=['red', 'dark green','orange','green','blue'], $
    PSym=[45,45,45,45,45], Symsize=1.5, Location=[1.005, 0.4], Titles=['Crab', 'Blank2', 'Cyg X1', 'Blank4','Sun'], $
    Length=0.0,  VSpace=2.75,  /Draw)
  Obj_Destroy, legendObj


  CgScatter2D, Avg_Crb_Alt, Avg_Crb_Cnt, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',SymSize=0.5,Color='RED',Xrange=[115,135],Xstyle=1,$
    Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]),PSYM=45, /noerase

  CgScatter2D, Avg_Sun_Alt, Avg_Sun_Cnt, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',SymSize=0.5,Color='Blue',Xrange=[115,135],Xstyle=1,$
    Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]),PSYM=45, /noerase, /OverPlot

  CgScatter2D, Avg_Blk2_Alt, Avg_Blk2_Cnt, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',SymSize=0.5,Color='Dark Green',Xrange=[115,135],Xstyle=1,$
    Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]),PSYM=45, /noerase, /OverPlot

  CgScatter2D, Avg_Blk4_Alt, Avg_Blk4_Cnt, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',SymSize=0.5,Color='Green',Xrange=[115,135],Xstyle=1,$
    Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]),PSYM=45, /noerase, /OverPlot

  CgScatter2D, Avg_Cyg_Alt, Avg_Cyg_Cnt, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',SymSize=0.5,Color='Orange',Xrange=[115,135],Xstyle=1,$
    Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]),PSYM=45, /noerase, /OverPlot

  CgPlot, Avg_Cyg_Alt, Avg_Cyg_Cnt, Fit=0, Xtitle ='Zenith Angle (Deg)',Title=Str_Title,Ytitle='Counts',$
    YRange=[3000,5000],YStyle=1,AxisColor='Black',Xrange=[-5,60],Xstyle=1,$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), Color='brown',/noerase,/Overplot

  CgErase
  ;Zenith vs altitude
  Str_Title = Title+'_Zenith Vs Altitude'


  CgScatter2D, Avg_Crb_Alt, Avg_Crb_Zen, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Zenith (Deg)',$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), AxisColor='Black',SymSize=0.5,Xrange=[115,135],Xstyle=1,$
    YRange=[-5,60],YSTYLE=1,Color='Red',PSYM=45,/noerase
  CgScatter2D, Avg_Sun_Alt, Avg_Sun_Zen, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Zenith (Deg)',$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), AxisColor='Black',SymSize=0.5,Xrange=[115,135],Xstyle=1,$
    YRange=[-5,60],YSTYLE=1,Color='Blue',PSYM=45,/noerase,/OverPlot
  CgScatter2D, Avg_Blk2_Alt, Avg_Blk2_Zen, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Zenith (Deg)',$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), AxisColor='Black',SymSize=0.5,Xrange=[115,135],Xstyle=1,$
    YRange=[-5,60],YSTYLE=1,Color='Dark Green',PSYM=45,/noerase,/OverPlot
  CgScatter2D, Avg_Blk4_Alt, Avg_Blk4_Zen, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Zenith (Deg)',$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), AxisColor='Black',SymSize=0.5,Xrange=[115,135],Xstyle=1,$
    YRange=[-5,60],YSTYLE=1,Color='Green',PSYM=45,/noerase,/OverPlot
  CgScatter2D, Avg_Cyg_Alt, Avg_Cyg_Zen, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Zenith (Deg)',$
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), AxisColor='Black',SymSize=0.5,Xrange=[115,135],Xstyle=1,$
    YRange=[-5,60],YSTYLE=1,Color='Orange',PSYM=45,/noerase,/OverPlot

  CgText, !D.X_Size*0.78,!D.Y_Size*0.00, 'Data Collected Per '+STRN(Scl_Time)+'s',/DEVICE, CHarSize=2.0

  ;YMax  = Max(Spec_Cnt)*1.1
  ;Str_Title = Title+'_Counts vs Zenith'

  ;  CgScatter2D, Spec_Zen, Spec_Cnt, Fit=0, Xtitle ='Zenith Angle (Deg)',Title=Str_Title,Ytitle='Counts',$
  ;    Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), AxisColor='Black',SymSize=0.5,$
  ;    Color='Blue',PSYM=7,/noerase, XRange=[36,42],YRange=[0,YMAX],XStyle=1,YStyle=1
  ;  CgText, !D.X_Size*0.78,!D.Y_Size*0.45, 'Altitude =('+STRN(Float(Altitude))+'+/- 0.1)kFt',/DEVICE, CHarSize=2.0
  cgPS_Close

  Temp_Str = Title+'_Plots.ps'
  CGPS2PDF, Temp_Str,delete_ps=1


  ; Create a text file with the values to be imported in an excel sheet.
  Openw, LUn, Cur+'/'+Title+'_'+Strn(Scl_Time)+'.txt',/Get_Lun
  TempText = 'Source Count Zenith Altitude'
  Printf, Lun, tempText

  ;Sun
  For i =0, N_Elements(Avg_Sun_Alt)-1 Do Begin
    Temp_Text = 'Sun '+ Strn(Avg_Sun_Cnt[i])+ '   '+ Strn(Avg_Sun_Zen[i]) + '   '+ Strn(Avg_Sun_Alt[i])
    Printf, Lun, Temp_Text
  Endfor

  ;Blank2
  For i =0, N_Elements(Avg_blk2_Alt)-1 Do Begin
    Temp_Text = 'Blank2 '+ Strn(Avg_blk2_Cnt[i])+ '   '+ Strn(Avg_blk2_Zen[i]) + '   '+ Strn(Avg_blk2_Alt[i])
    Printf, Lun, Temp_Text
  Endfor

  ;Cyg X1
  For i =0, N_Elements(Avg_Cyg_Alt)-1 Do Begin
    Temp_Text = 'Cyg '+ Strn(Avg_Cyg_Cnt[i])+ '   '+ Strn(Avg_Cyg_Zen[i]) + '   '+ Strn(Avg_Cyg_Alt[i])
    Printf, Lun, Temp_Text
  Endfor

  ;Blank4
  For i =0, N_Elements(Avg_blk4_Alt)-1 Do Begin
    Temp_Text = 'Blank4 '+ Strn(Avg_blk4_Cnt[i])+ '   '+ Strn(Avg_blk4_Zen[i]) + '   '+ Strn(Avg_blk4_Alt[i])
    Printf, Lun, Temp_Text
  Endfor

  For i =0, N_Elements(Avg_Crb_Alt)-1 Do Begin
    Temp_Text = 'Crab '+ Strn(Avg_Crb_Cnt[i])+ '   '+ Strn(Avg_Crb_Zen[i]) + '   '+ Strn(Avg_Crb_Alt[i])
    Printf, Lun, Temp_Text
  Endfor

  Free_Lun, Lun

  ;
  ;-- Now create the 3-D plot --
  ;
  Stop
End