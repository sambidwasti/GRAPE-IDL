Pro Flt_l1_Ener_Anode, fsearch_String, Anode=Anode, Title= Title, nfiles=nfiles
;
;       Reading Level1 version 6 
;      Create a Energy Histogram for each an anode or all the anodes.
;      Only C Types

;  Need to include the flagged anodes. 
    Anode =31
 
    TYpe =1      ; Define C Types
    Number_of_Anode=1 ; Define 1 anodes
 
 
    EMAX= 1000.0 ; Max value of energy for energy histogram.
    Cd, Cur=Cur

    IF Keyword_Set(title) Eq 0 Then Title='Test'
    c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration

    ;===========
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
     ;==== Struc Defined =======
     
     Tot_Live_Time  = FltArr(32)
     Live_Time_Cnt  = LonArr(32)
     Total_Time_Ran = 0.0D
     
     Temp_Time = 0.0D
     
     ; The first value is going to be 0 so we have to be careful of getting rid of it. 
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
      
     Inst_Arr= DblArr(1)
     
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
              
              ;==== Read and build histogram for each packet read == 
              
              Temp_Time = Event_Data[i].Swept_Time ; For total time ran.
              
 ;Dif         ;---- Select 1 anodes  and Type = 1 which is c events
              If (Event_data[i].Event_Class NE Type) Or (Event_Data[i].No_Anodes NE Number_of_Anode) Or (Event_Data[i].Int_Mod_Flag EQ 1) Then goto, Jump_Packet
              
              Mod_pos = Event_data[i].Mod_Position      ; Module Position
              If (Where(Mod_pos EQ c2014) Ne -1) Eq 0 Then Goto, Jump_Packet      ; Skipping modules which are not in the configuration.
                         
              ;---- Choose primary and secondary anodes.
             
              Pri_Anode = Event_Data[i].Anode_ID_1
              If Pri_Anode NE Anode Then goto, Jump_Packet ; Selecting anode 1.
              
              Pri_Energy= Event_data[i].Anode_Energy_1 
              Tot_Energy = Pri_Energy
     
             
              ;---- Live Time Stuffs ---
              Tot_Live_Time[Mod_Pos] = Tot_Live_time[Mod_Pos]+Event_data[i].Cor_Live_Time
              Live_Time_Cnt[Mod_pos]++
              
              ;Energy Histogram
              If( (Tot_Energy GE EMAX) OR (Tot_Energy LT 0.0) )Then goto, Jump_Packet
              ; Concat for each modules. 
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

               
              Jump_Packet:    
          If i mod 100000 EQ 0 Then print, i 
          EndFor; /i
          Total_Time_Ran = Total_Time_Ran + Temp_Time
          Files_Left = nfiles-p
          Print, 'No. of Files LEft : '+STRN(Files_Left-1)
    EndFor; /p
    
    ; Create the Histograms
    H0_ARR =P0_EArr[1:N_Elements(P0_EArr)-1]
    H2_Arr =P2_EArr[1:N_Elements(P2_EArr)-1] 
    H3_Arr =P3_EArr[1:N_Elements(P3_EArr)-1]
    H4_Arr =P4_EArr[1:N_Elements(P4_EArr)-1]
    H6_Arr =P6_EArr[1:N_Elements(P6_EArr)-1]
    H7_Arr =P7_EArr[1:N_Elements(P7_EArr)-1]
    H9_Arr =P9_EArr[1:N_Elements(P9_EArr)-1]
    H10_Arr =P10_EArr[1:N_Elements(P10_EArr)-1]
  
    H11_Arr=P11_EArr[1:N_Elements(P11_EArr)-1]
    H12_Arr=P12_EArr[1:N_Elements(P12_EArr)-1]
    H13_Arr=P13_EArr[1:N_Elements(P13_EArr)-1]
    H14_Arr=P14_EArr[1:N_Elements(P14_EArr)-1]
    H17_Arr=P17_EArr[1:N_Elements(P17_EArr)-1]
    H18_Arr=P18_EArr[1:N_Elements(P18_EArr)-1]
    H19_Arr=P19_EArr[1:N_Elements(P19_EArr)-1]
    H20_Arr=P20_EArr[1:N_Elements(P20_EArr)-1]
    
    H21_Arr=P21_EArr[1:N_Elements(P21_EArr)-1]
    H22_Arr=P22_EArr[1:N_Elements(P22_EArr)-1]
    H24_Arr=P24_EArr[1:N_Elements(P24_EArr)-1]
    H25_Arr=P25_EArr[1:N_Elements(P25_EArr)-1]
    H27_Arr=P27_EArr[1:N_Elements(P27_EArr)-1]
    H28_Arr=P28_EArr[1:N_Elements(P28_EArr)-1]
    H29_Arr=P29_EArr[1:N_Elements(P29_EArr)-1]
    H31_Arr=P31_EArr[1:N_Elements(P31_EArr)-1]
    
    ; === For sanity Checks     
    Main_Src_Arr = [H0_Arr,H2_Arr,H3_Arr,H4_Arr,H6_Arr,H7_Arr,H9_Arr,H10_Arr,H11_Arr,H12_ARr,H13_Arr,H14_Arr,$
                    H17_Arr,H18_Arr,H19_Arr,H20_Arr,H21_Arr,H22_Arr,H24_Arr,H25_Arr,H27_Arr,H28_ARr,H29_Arr,H31_Arr]
    
   ; CgPlot,INDGEN(72)*5, Histogram(Main_Src_Arr,NBINS=72), XRange=[0,360], XStyle=1, PSYM=10
    CgHistoplot,Main_Src_Arr, Binsize=5.0, /OUTLINE, XRANGE=[0,500], XSTYLE=1
    Print, Total_Time_Ran
    ;====
    
    ;=== Getting the histogram array of length 360 ===
    
    M0Arr = Histogram(H0_Arr, NBIns=500)
    M2Arr = Histogram(H2_Arr, NBIns=500)
    M3Arr = Histogram(H3_Arr, NBIns=500)
    M4Arr = Histogram(H4_Arr, NBIns=500)
    M6Arr = Histogram(H6_Arr, NBIns=500)
    M7Arr = Histogram(H7_Arr, NBIns=500)
    M9Arr = Histogram(H9_Arr, NBIns=500)
    M10Arr = Histogram(H10_Arr, NBIns=500)
  
    M11Arr = Histogram(H11_Arr, NBIns=500)
    M12Arr = Histogram(H12_Arr, NBIns=500)
    M13Arr = Histogram(H13_Arr, NBIns=500)
    M14Arr = Histogram(H14_Arr, NBIns=500)
    M17Arr = Histogram(H17_Arr, NBIns=500)
    M18Arr = Histogram(H18_Arr, NBIns=500)
    M19Arr = Histogram(H19_Arr, NBIns=500)
    M20Arr = Histogram(H20_Arr, NBIns=500)
    
    M21Arr = Histogram(H21_Arr, NBIns=500)
    M22Arr = Histogram(H22_Arr, NBIns=500)
    M24Arr = Histogram(H24_Arr, NBIns=500)
    M25Arr = Histogram(H25_Arr, NBIns=500)
    M27Arr = Histogram(H27_Arr, NBIns=500)
    M28Arr = Histogram(H28_Arr, NBIns=500)
    M29Arr = Histogram(H29_Arr, NBIns=500)
    M31Arr = Histogram(H31_Arr, NBIns=500)
    
    Scat_Array= FltArr(32,500)
    
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
    
    
      ; ===== Now Need a Text-File of these Histogram of Energy Spectrum ====
        Openw, Lunger1, Cur+'/Anode'+Strn(Anode)+'_'+Title+'_n'+strn(nfiles)+'_EnerHist.txt', /Get_Lun
   
          ;=== Comment 10 lines ===
          Printf, Lunger1, ' Energy Histogram of Each of the Modules. '
          Printf, Lunger1, ' Total Time Ran      ='+ Strn(Total_Time_Ran)
          Printf, Lunger1, ' SIZE ='+Strn(EMAX) 
          Printf, Lunger1, '/Empty Line'
          
          For i =0,31 Do Begin
                      If Live_Time_Cnt[i] Eq 0 then AvgLT=0 Else AvgLT=(Double(Tot_Live_Time[i])/Double(Live_Time_Cnt[i]))
                      Printf, Lunger1, 'Mod_Pos='+Strn(i)
                      Printf, Lunger1, 'AVG_LT ='+Strn(AvgLT)  
                      Txt = ''
                      For j = 0,499 do begin
                           Txt= Txt+Strn(Scat_Array[i,j])+' '
                      EndFor
                      Printf, Lunger1, Txt
          EndFor

    Free_Lun, Lunger1



End