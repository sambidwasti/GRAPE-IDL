Pro Grp_l1v7_Flt_quicklook_1, fsearch_String
  ;
  ; Reading in Level 1 version 7 data. for angles
  ; Do some energy selection and some calculation to do per sweep stuff.
  ; Creating hardware upper and lower limit files.
  ;
  ; Feb 21, Wastisk: Statistics file.
  ; some output format needs updated.
  ;

  True = 1
  False= 0

  Xmin = 90
  Xmax = 101
  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 10.0
  Pla_EMax = 200.00

  Cal_EMin = 40.0
  Cal_EMax = 400.00

  Tot_EMin = 80.00
  Tot_EMax = 200.00

  ;
  ;-- Get the array of event files.
  ;
  Evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  ;
  ;-- Total no. of files --
  ;
  If keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)

  Plot_Flag = True
  If Keyword_set(noplot) ne 0 Then Plot_Flag = False

  Dump_Flag = False
  If Keyword_set(Dump) NE 0 Then Dump_Flag = True


  Hdw_Upper = INTARR(32,64)
  Hdw_Lower = IntArr(32,64)

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

    Quality           : 0   ,$    ; 2 141

    Latitude          : 0.0 ,$    ; 4 145
    Longitude         : 0.0 ,$    ; 4 149
    Altitude          : 0.0 ,$    ; 4 153
    Depth             : 0.0 ,$    ; 4 157
    Point_Azimuth     : 0.0 ,$    ; 4 161
    Point_Zenith      : 0.0 ,$    ; 4 165

    Rotation_Angle    : 0.0 ,$    ; 4 169
    Rotation_Status   : 0   ,$    ; 2 171
    Live_Time         : 0.0 ,$    ; 4 175
    Cor_Live_Time     : 0.0 }     ; 4 179

  Packet_Len = 179L ; In Bytes
  ;
  ;------
  ;


  ;
  ;--- Each Sweep Statistics ---
  ;

  Stt_Total   = 0.0D
  Stt_PC      = 0.0D
  Stt_PC_Fil  = 0.0D
  Stt_CC      = 0.0D
  Stt_C      = 0.0D
  Stt_ev0     =0.0D

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
  ;-- Calculated stuffs --
  ;
  Scaled_No_Events = DblArr(102)
  PC_T1_Events     = DblArr(102)

  ;
  ;--- Average out every minute.
  ;


  Sun_Arr = [0.0D]
  Crab_Arr = [0.0D]
  ;
  ;-- For Each File --
  ;
  ;  cgPS_Open, Title+'.ps', Font=1
  ;  cgDisplay, 800, 800
  ;  cgLoadCT, 13
  If Dump_Flag Eq True Then Openw, Temp_Lun, Cur+'/Dumped_Data.txt', /Get_lun

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



	cgplot, event_data.rotation_angle


    jump_file:
stop
  EndFor ; p
 

  



End