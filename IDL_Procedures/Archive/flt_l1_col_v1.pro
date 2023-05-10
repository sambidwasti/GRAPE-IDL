Pro Flt_l1_Col_V1, fsearch_String, nfiles=nfiles, title = title
; For collimator runs done in UNH with step size =89 and 4 steps..
; We need PC/CC count spectrum for each increment in angles/ per rotation angle
;  
; also energy files at each of these angles.
; We round off the elevation angle so dont use it for the flight data. Use it as a template. 
    If Keyword_Set(Title) EQ 0 Then Title=''
    Cd, Cur=Cur
    ;
    ;----------- Standard Flight Level 1 Reading ----------
    ;
    evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
    if keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)
  
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
     
     ;----- Define the Arrays ------
     
     ;--- For 4 steps we get 5 rotational angles--
     Angle_1_Array = FltArr(1)
     Angle_2_Array = FltArr(1)
     Angle_3_Array = FltArr(1)
     Angle_4_Array = FltArr(1)
     Angle_5_Array = FltArr(1)
     
    
     For p = 0, nfiles-1 Do Begin ; open each file

         fname = evtfiles[p]
         print, fname
         ;   ** Open the binary file and dump it in Data and Close the file.
         Openr, lun, fname, /GET_Lun     
                  Data = read_binary(lun)         ; Putting the file in an array
         Free_Lun, lun
         
         TotPkt = n_elements(Data)/Packet_Len   
         Event_data = replicate(Struc, TotPkt)  
         
         For i = 0, TotPkt-1 Do Begin
         ;**=== Break into smaller Packet.** ===
         
              ifirst = (i)*Packet_Len               ; first byte for this packet
              ilast  = (ifirst+ Packet_Len)-1       ; last byte for this packet
              pkt = data[ifirst:ilast]              ; this packet of 100Bytes length.            
                   
              ;==** Now For Each Packet we know the position of each Value.        ** Start  Size.(Byte)                                                                              
              
              Event_data[i].Version_Number       = pkt[0]         ;1    1
              Event_data[i].Sweep_Number         = Fix(pkt,1)     ;2    3
              Event_data[i].Sweep_Start_Time     = Double(pkt,3)  ;8    11
              Event_data[i].Swept_Time           = Double(pkt,11) ;8    19
              Event_data[i].Event_Time           = Double(pkt,19) ;8    27
              
              Event_data[i].Mod_Position         = pkt[27]        ;1    28
              Event_data[i].Mod_Serial           = pkt[28]        ;1    29
              
              Event_data[i].Event_Class          = pkt[29]        ;1    30
              Event_data[i].Int_Mod_Flag         = pkt[30]        ;1    31
              Event_data[i].Anti_Co_Flag         = pkt[31]        ;1    32
              Event_data[i].No_Anodes            = pkt[32]        ;1    33
              Event_data[i].No_Pla               = pkt[33]        ;1    34
              Event_data[i].No_Cal               = pkt[34]        ;1    35
              
              Event_data[i].Anode_id_1           = pkt[35]        ;1    36
              Event_data[i].Anode_id_2           = pkt[36]        ;1    37
              Event_data[i].Anode_id_3           = pkt[37]        ;1    38
              Event_data[i].Anode_id_4           = pkt[38]        ;1    39
              Event_data[i].Anode_id_5           = pkt[39]        ;1    40
              Event_data[i].Anode_id_6           = pkt[40]        ;1    41
              Event_data[i].Anode_id_7           = pkt[41]        ;1    42
              Event_data[i].Anode_id_8           = pkt[42]        ;1    43
              
              Event_data[i].Anode_Type_1         = pkt[43]        ;1    44
              Event_data[i].Anode_Type_2         = pkt[44]        ;1    45
              Event_data[i].Anode_Type_3         = pkt[45]        ;1    46
              Event_data[i].Anode_Type_4         = pkt[46]        ;1    47
              Event_data[i].Anode_Type_5         = pkt[47]        ;1    48
              Event_data[i].Anode_Type_6         = pkt[48]        ;1    49
              Event_data[i].Anode_Type_7         = pkt[49]        ;1    50
              Event_data[i].Anode_Type_8         = pkt[50]        ;1    51
              
              Event_data[i].Anode_Pha_1          = Fix(pkt,51)    ;2    53
              Event_data[i].Anode_Pha_2          = Fix(pkt,53)    ;2    55
              Event_data[i].Anode_Pha_3          = Fix(pkt,55)    ;2    57
              Event_data[i].Anode_Pha_4          = Fix(pkt,57)    ;2    59
              Event_data[i].Anode_Pha_5          = Fix(pkt,59)    ;2    61
              Event_data[i].Anode_Pha_6          = Fix(pkt,61)    ;2    63
              Event_data[i].Anode_Pha_7          = Fix(pkt,63)    ;2    65
              Event_data[i].Anode_Pha_8          = Fix(pkt,65)    ;2    67
              
              Event_data[i].Anode_Energy_1       = Float(pkt,67)  ;4    71
              Event_data[i].Anode_Energy_2       = Float(pkt,71)  ;4    75
              Event_data[i].Anode_Energy_3       = Float(pkt,75)  ;4    79
              Event_data[i].Anode_Energy_4       = Float(pkt,79)  ;4    83
              Event_data[i].Anode_Energy_5       = Float(pkt,83)  ;4    87
              Event_data[i].Anode_Energy_6       = Float(pkt,87)  ;4    91
              Event_data[i].Anode_Energy_7       = Float(pkt,91)  ;4    95
              Event_data[i].Anode_Energy_8       = Float(pkt,95)  ;4    99
              
              Event_data[i].Anode_Energy_Err_1   = Float(pkt,99)  ;4    103
              Event_data[i].Anode_Energy_Err_2   = Float(pkt,103) ;4    107
              Event_data[i].Anode_Energy_Err_3   = Float(pkt,107) ;4    111
              Event_data[i].Anode_Energy_Err_4   = Float(pkt,111) ;4    115
              Event_data[i].Anode_Energy_Err_5   = Float(pkt,115) ;4    119
              Event_data[i].Anode_Energy_Err_6   = Float(pkt,119) ;4    123
              Event_data[i].Anode_Energy_Err_7   = Float(pkt,123) ;4    127
              Event_data[i].Anode_Energy_Err_8   = Float(pkt,127) ;4    131
              
              Event_data[i].Total_Energy         = Float(pkt,131) ;4    135
              Event_data[i].Total_Energy_Err     = Float(pkt,135) ;4    139
              
              Event_data[i].Latitude             = Float(pkt,139) ;4    143
              Event_data[i].Longitude            = Float(pkt,143) ;4    147
              Event_data[i].Altitude             = Float(pkt,147) ;4    151
              Event_data[i].Depth                = Float(pkt,151) ;4    155
              Event_data[i].Point_Azimuth        = Float(pkt,155) ;4    159
              Event_data[i].Point_Zenith         = Float(pkt,159) ;4    163
    
              Event_data[i].Rotation_Angle       = Float(pkt,163) ;4    167
              Event_data[i].Rotation_Status      = Fix(pkt,167)   ;2    169
              Event_data[i].Live_Time            = Float(pkt,169) ;4    173
              Event_data[i].Cor_Live_Time        = Float(pkt,173) ;4    177
          
              ;------------------------
              
              ;
              ; ;;;=== EVENT SELECTION ==
              ;
              
              ;-- Table Status has to be waiting --
              If Event_data[i].Rotation_Status NE 5 Then Goto, Jump_Packet
              
              ;-- Inter Module Flag --
              If Event_data[i].Int_Mod_Flag EQ 1 Then Goto, Jump_Packet
              
              Rot_Angle = Event_data[i].Rotation_Angle
              
              Temp_Zen_Angle = Event_data[i].Point_Zenith
  ;            print, Temp_Zen_Angle
;              If Temp_Zen_Angle GT 300 Then Temp_Zen_Angle = Temp_Zen_Angle-360.00
              Zen_Angle = Round(TemP_Zen_Angle)
        ;      Print, Zen_Angle
              ; We know 4 steps so 

              If Rot_Angle EQ 0 then Angle_1_Array = [Angle_1_Array, Zen_Angle] 
              If Rot_Angle EQ 89 Then Angle_2_Array = [Angle_2_Array, Zen_Angle]
              If Rot_Angle EQ 178 Then Angle_3_Array = [Angle_3_Array, Zen_Angle]
              If Rot_Angle EQ 267 Then Angle_4_Array = [Angle_4_Array, Zen_Angle]
              If Rot_Angle EQ 356 Then Angle_5_Array = [Angle_5_Array, Zen_Angle]
              
              ;The X Axis is always Zen_Angle
              ; For the Counts, we will just build a histogram 
              ; 
              ; For Energy We do the same thing. 
              ;
              ;-- PC or CC --

;              If (Event_data[i].Event_Class EQ 3) and (Event_data[i].No_Anodes EQ 2) Then Begin
;              ; PC Event
;              
;              EndIF Else If (Event_data[i].Event_Class EQ 1) and (Event_data[i].No_Anodes EQ 1) Then Begin
;              ; C Event
;              
;              EndIF Else Goto, Jump_Packet
              
              
              Jump_Packet:
              
                        If i mod 100000 EQ 0 Then print, i
          EndFor; /i
          
          
    EndFor; /p
    
    
    
    Set_Plot, 'PS'
    loadct, 13                           ; load color
    Device, File = Cur+'/'+title+'Rot_0_TotHist.ps', /COLOR,/Portrait
    Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                    CgHistoplot, Angle_1_Array, BinSize=2.0,/OUTLINE, Xtitle='Zenith Angle'     
    Device,/Close
    Set_Plot, 'X'
    
    Set_Plot, 'PS'
    loadct, 13                           ; load color
    Device, File = Cur+'/'+title+'Rot_89_TotHist.ps', /COLOR,/Portrait
    Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                    CgHistoplot, Angle_2_Array, BinSize=1.0,/OUTLINE, Xtitle='Zenith Angle'     
    Device,/Close
    Set_Plot, 'X'
    
    Set_Plot, 'PS'
    loadct, 13                           ; load color
    Device, File = Cur+'/'+title+'Rot_178_TotHist.ps', /COLOR,/Portrait
    Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                    CgHistoplot, Angle_2_Array, BinSize=1.0,/OUTLINE, Xtitle='Zenith Angle'     
    Device,/Close
    Set_Plot, 'X'
    
    Set_Plot, 'PS'
    loadct, 13                           ; load color
    Device, File = Cur+'/'+title+'Rot_267_TotHist.ps', /COLOR,/Portrait
    Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                    CgHistoplot, Angle_3_Array, BinSize=1.0,/OUTLINE, Xtitle='Zenith Angle'     
    Device,/Close
    Set_Plot, 'X'
    
    Set_Plot, 'PS'    
    loadct, 13                           ; load color
    Device, File = Cur+'/'+title+'Rot_356_TotHist.ps', /COLOR,/Portrait
    Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                    CgHistoplot, Angle_4_Array, BinSize=1.0,/OUTLINE, Xtitle='Zenith Angle'     
    Device,/Close
    Set_Plot, 'X'

    
    ;CGPS2PDF
    Stop
End