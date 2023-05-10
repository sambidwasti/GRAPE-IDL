Pro Grp_l1_Flt_quicklook_v1, fsearch_String, nfiles=nfiles, title= title
  ;
  ; Reading in Level 1 version 6 data.
  ;
  ; Sole purpose is to generate few of the quicklook plots
  ; These plots are
  ;     - For Each Sweep:
  ;           - Avg Atm Depth
  ;           - Count-Rate
  ;           - Alt
  ;           - LT

  True = 1
  False= 0
  ;
  ;-- Get the array of event files.
  ;
  Evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  ;
  ;-- Total no. of files --
  ;
  If keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)

  ;
  ;-- Start time
  ;
  Start_Time = 477264


  ;
  ;-- Title --
  ;
  IF Keyword_Set(title) Eq 0 Then Title='Test'


  ;
  ;-- Current Directory --
  ;
  CD, Cur = Cur


  ;== Define the Structure.
  Struc = { Version_Number    : 0B  ,$    ; 1 1
    Sweep_Number      : 0   ,$    ; 2 3
    Sweep_Start_Time  : 0.0D,$    ; 8 11
    Swept_Time        : 0.0D,$    ; 8 19
    Event_Time        : 0.0D,$    ; 8 27

    Mod_Position      : 0B  ,$    ; 1 28
    Mod_Serial        : 0B  ,$    ; 1 29

    Event_Class       : 0B  ,$    ; 1 30
    Int_Mod_Flag      : 0B  ,$    ; 1 31
    Anti_Co_Flag      : 0B  ,$    ; 1 32
    No_Anodes         : 0B  ,$    ; 1 33
    No_Pla            : 0B  ,$    ; 1 34
    No_Cal            : 0B  ,$    ; 1 35

    Anode_Id_1        : 0B  ,$    ; 1 36
    Anode_Id_2        : 0B  ,$    ; 1 37
    Anode_Id_3        : 0B  ,$    ; 1 38
    Anode_Id_4        : 0B  ,$    ; 1 39
    Anode_Id_5        : 0B  ,$    ; 1 40
    Anode_Id_6        : 0B  ,$    ; 1 41
    Anode_Id_7        : 0B  ,$    ; 1 42
    Anode_Id_8        : 0B  ,$    ; 1 43

    Anode_Type_1      : 0B  ,$    ; 1 44
    Anode_Type_2      : 0B  ,$    ; 1 45
    Anode_Type_3      : 0B  ,$    ; 1 46
    Anode_Type_4      : 0B  ,$    ; 1 47
    Anode_Type_5      : 0B  ,$    ; 1 48
    Anode_Type_6      : 0B  ,$    ; 1 49
    Anode_Type_7      : 0B  ,$    ; 1 50
    Anode_Type_8      : 0B  ,$    ; 1 51

    Anode_Pha_1       : 0   ,$    ; 2 53
    Anode_Pha_2       : 0   ,$    ; 2 55
    Anode_Pha_3       : 0   ,$    ; 2 57
    Anode_Pha_4       : 0   ,$    ; 2 59
    Anode_Pha_5       : 0   ,$    ; 2 61
    Anode_Pha_6       : 0   ,$    ; 2 63
    Anode_Pha_7       : 0   ,$    ; 2 65
    Anode_Pha_8       : 0   ,$    ; 2 67

    Anode_Energy_1    : 0.0 ,$    ; 4 71
    Anode_Energy_2    : 0.0 ,$    ; 4 75
    Anode_Energy_3    : 0.0 ,$    ; 4 79
    Anode_Energy_4    : 0.0 ,$    ; 4 83
    Anode_Energy_5    : 0.0 ,$    ; 4 87
    Anode_Energy_6    : 0.0 ,$    ; 4 91
    Anode_Energy_7    : 0.0 ,$    ; 4 95
    Anode_Energy_8    : 0.0 ,$    ; 4 99

    Anode_Energy_Err_1: 0.0 ,$    ; 4 103
    Anode_Energy_Err_2: 0.0 ,$    ; 4 107
    Anode_Energy_Err_3: 0.0 ,$    ; 4 111
    Anode_Energy_Err_4: 0.0 ,$    ; 4 115
    Anode_Energy_Err_5: 0.0 ,$    ; 4 119
    Anode_Energy_Err_6: 0.0 ,$    ; 4 123
    Anode_Energy_Err_7: 0.0 ,$    ; 4 127
    Anode_Energy_Err_8: 0.0 ,$    ; 4 131

    Total_Energy      : 0.0 ,$    ; 4 135
    Total_Energy_Err  : 0.0 ,$    ; 4 139

    Latitude          : 0.0 ,$    ; 4 143
    Longitude         : 0.0 ,$    ; 4 147
    Altitude          : 0.0 ,$    ; 4 151
    Depth             : 0.0 ,$    ; 4 155
    Point_Azimuth     : 0.0 ,$    ; 4 159
    Point_Zenith      : 0.0 ,$    ; 4 163

    Rotation_Angle    : 0.0 ,$    ; 4 167
    Rotation_Status   : 0   ,$    ; 2 169
    Live_Time         : 0.0 ,$    ; 4 173
    Cor_Live_Time     : 0.0 }     ; 4 177

  Packet_Len = 177L ; In Bytes
  ;
  ;------
  ;

  ;
  ;--- Each Sweep Data
  ;
  Swp_Alt_Ar    = [0.0]
  Swp_Time_Ar   = [0.0]
  Swp_Anodes_Ar = [0L]
  Swp_Depth_Ar  = [0.0]
  Swp_CorLT_Ar  = [0.0]
  Swp_LT_Ar     = [0.0]
  Swp_SweepNo_Ar= [0L]

  Swp_Evt_Ar  = [0L]


  ;
  ;--- Average out every minute.
  ;
  Temp_EvtAr = [0.0D]
  Temp_Alt   = [0.0]
  Temp_Time = Double(Start_Time)

  Temp_Counter = 0.0
  Avg_LT = 0.0
  Avg_Time = 0.0
  Avg_Altitude = 0.0D
  ;
  ;-- For Each File --
  ;
  cgPS_Open, Title+'.ps', Font=1
  cgDisplay, 800, 800
  cgLoadCT, 13

  For p = 0, nfiles-1 Do Begin
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

    ;



    CgPlot,Event_Data.Event_Time, Event_Data.Cor_Live_Time, Xtitle ='Sweep Time',Title='Cor Live Time '+STRN(Event_Data[1].Sweep_Number),$
      YRange = [0.7,1.1],Position= cgLayout([1,2,1],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

    CgPlot,Event_Data.Event_Time, Event_Data.Live_Time, Xtitle ='Sweep Time',Title='Live Time '+STRN(Event_Data[1].Sweep_Number),$
      YRange = [0.7,1.1],Position= cgLayout([1,2,2],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
    CGERASE

    print, Event_Data[1].Sweep_number

    Swp_Alt_Ar=[Swp_Alt_Ar,Avg(Event_Data.Altitude)]
    Swp_Time_Ar=[Swp_Time_Ar, Avg(Event_Data.Swept_Time)+Event_Data[i-1].Sweep_Start_Time]
    Swp_Anodes_Ar = [Swp_Anodes_Ar,Avg(Event_Data.No_Anodes)]
    Swp_Depth_Ar  = [Swp_Depth_Ar, Avg(Event_Data.Depth)]
    Swp_CorLT_Ar  = [Swp_CorLT_Ar, Avg(Event_Data.Cor_Live_Time)]
    Swp_LT_Ar     = [Swp_LT_Ar, Avg(Event_Data.Live_Time)]
    Swp_SweepNo_Ar= [Swp_SweepNo_Ar, Event_Data[5].Sweep_Number]
    Swp_Evt_Ar    = [Swp_Evt_Ar, TotPkt]
  EndFor ; p

  CgPS_Close
  Temp_Str = Title+'.ps'
  CGPS2PDF, Temp_Str,delete_ps=1
  ;
  ;--- NOTE : REbin is better to rebin to smaller and Congrid better for binning to bigger
  ;

  Swp_Time = Swp_Time_Ar[1:N_Elements(Swp_Time_Ar)-1]
  Swp_Alt  = Swp_Alt_Ar[1:N_Elements(Swp_Alt_Ar)-1]
  Swp_Anodes= Swp_Anodes_Ar[1:N_Elements(Swp_Anodes_Ar)-1]
  Swp_Depth = Swp_Depth_Ar[1:N_Elements(Swp_Depth_Ar)-1]
  Swp_CorLT    = Swp_CorLT_Ar[1:N_Elements(Swp_CorLT_Ar)-1]
  Swp_LT    = Swp_LT_Ar[1:N_Elements(Swp_LT_Ar)-1]
  Swp_Evt   = Swp_Evt_Ar[1:N_Elements(Swp_Evt_Ar)-1]
  Swp_SweepNo= Swp_SweepNo_Ar[1:N_Elements(Swp_SweepNo_Ar)-1]


  cgPS_Open, Title+'_Level1_quicklook.ps', Font=1
  cgDisplay, 800, 800
  cgLoadCT, 13


  ;XMINOR = 6, YMARGIN = [5,5], $
  CgPlot, Swp_SweepNo, Swp_Alt, Xtitle ='Sweep Number',Title='Altitude',$
    YRange = [ 115000,135000],XRange=[0,102],XStyle=1, $
    Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

  CgPlot, Swp_SweepNo, Swp_Anodes, Xtitle ='Sweep Number',Title='No.of Anodes triggered',$
    Yrange =[ 0, 10],XRange=[0,102],XStyle=1, $
    Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

  CgErase ; Next page::

  CgPlot, Swp_SweepNo, Swp_Depth, Xtitle ='Sweep Number',Title='Atmospheric Depth',$
    YRange = [0,8.0],XRange=[0,102],XStyle=1, $
    Position= cgLayout([1,2,1],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

  CgPlot, Swp_SweepNo, Swp_CorLT , Xtitle ='Sweep Number',Title='Corrected Live Time',$
    YRange = [0,1.5] ,XRange=[0,102],XStyle=1,$
    Position= cgLayout([1,2,2],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
  CgErase ; Next Page

  CgPlot, Swp_SweepNo, Swp_LT, Xtitle ='Sweep Number',Title='Live Time',$
    YRange = [0,1.5] ,XRange=[0,102],XStyle=1,$
    Position= cgLayout([1,2,1],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

  CgPlot, Swp_SweepNo, Swp_Evt_Ar, Xtitle ='Sweep Number',Title=' Total no. of Events',$
    XRange=[0,102],XStyle=1,$
    Position= cgLayout([1,2,2],xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

  cgPS_Close
  Temp_Str = Title+'_Level1_quicklook.ps'
  CGPS2PDF, Temp_Str,delete_ps=1



  Stop
End