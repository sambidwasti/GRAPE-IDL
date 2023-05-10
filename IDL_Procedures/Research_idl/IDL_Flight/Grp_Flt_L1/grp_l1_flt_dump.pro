Pro Grp_L1_Flt_Dump, fsearch_String, nfiles=nfiles, title= title
  ;
  ; Read in the file and dump the data in a text file.
  ;
  ;-- Last Updated : Sambid Wasti
  ;                  Sept 21, 2014 : Updated the comments and way to read in the structure.

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
  ;-- Title --
  ;
  IF Keyword_Set(title) Eq 0 Then Title='Test'



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
  ;-- For Each File --
  ;
  For p = 0, nfiles-1 Do Begin
    
   

    print,p
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
    Text_Data = ''
    
    Openw, TextLun, title+'_'+strn(Event_data[1].sweep_number)+'_Data.txt',/Get_Lun
    Printf, TextLun, 'Swp_No Evt_Time Swp_St_Time Rt_Time Rt_Angle LT CorLT No_Anodes Alt Depth
    For i =0, TotPkt-1 Do Begin

      ;
      ;-- Work for each of the files from here--
      ;
      
              Text_Data = STRN(Event_Data[i].Sweep_Number) + ' '+ STRN(Event_Data[i].Event_Time) + ' '+ $
                          STRN(Event_Data[i].Sweep_Start_Time) + ' '+ STRN(Event_Data[i].Swept_Time) + ' '+ $
                          STRN(Event_Data[i].Rotation_Angle)+ ' '+  STRN(Event_Data[i].Rotation_Status)+ ' '+$
                          STRN(Event_Data[i].Live_Time) + ' '+ STRN(Event_Data[i].Cor_Live_Time) + ' '+ $
                          STRN(Event_Data[i].No_Anodes)+ ' '+ $
                          STRN(Event_Data[i].Altitude) + ' '+ STRN(Event_Data[i].Depth)
                          
              Printf, TextLun, Text_Data

      ;
      ;-- Pointer to jump in case of bad event.
      ;
      Jump_Packet:
        

      ;
      ;-- Print Statement to give hope that its running the program.
      ;
      If i mod 100000 EQ 0 Then print, i

    EndFor; /i

  Free_Lun, TextLun
  EndFor ; p


End