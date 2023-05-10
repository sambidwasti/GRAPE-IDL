Pro Flt_l1_Col, fsearch_String, nfiles=nfiles, title = title
; For collimator runs in FTS or default settings of the table parameters.
; We need PC/CC count spectrum for each increment in angles/ per rotation angle
;  
; also energy files at each of these angles.
; We round off the elevation angle so dont use it for the flight data. Use it as a template. 

True = 1
False= 0
    
    ;
    ;=== Energy Cuts ==
    ;
          ;
          ;-- Plastics --
          ;
          Pla_min = 4.0
          Pla_max = 200.0
          
          ;
          ;-- Calorimeters --
          ;
          Cal_min = 20.0
          Cal_max = 500.00
          
          ;
          ;-- Energy
          ;
          EMAX =500.0
          EMIN =0.0
    ;
    ; ==              ==
    ;
    
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
    
    
    ;
    ;==== Flagged Anodes and the respective anodes ===== In the calibration process not in from the GSE.
    ;
    Flag_Mod =   [3, 11, 13, 14]        ; Pos No.
    
    ;
    ;These Mod = 104 106 107 108   ; Respective Ser. No.
    ;
    Flag_Anodes =[34, 38, 49, 45]; Anodes in these modules. 
    
    ;
    ;-- The 2014 configuration of position that is occupied by the modules.
    ; 
    c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration
    
    ;
    ;-- Get the Current folder and define output folder --
    ;
    Cd, Cur=Cur
    Output_Folder = Cur+'/'
    
    ;
    ;== Define the Structure. 
    ;
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
     
     ;
     ;-- Define the Arrays --
     ;
     Total_Count_Array = LonArr(16)
     PC_Count_Array    = LonArr(16)
      C_Count_Array    = LonArr(16)
     
     PC_Ener_Array     = DblArr(16, EMAX )
      C_Ener_Array     = DblArr(16, Cal_Max )
      
      temp=0
     ;
     ;-- For Each File --
     ;
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
             
             For i = 0, TotPkt-1 Do Begin
                   
                  ;
                  ;-- Module Extraction and selection
                  ;
                  Mod_pos = Event_data[i].Mod_Position      ; Module Position
                  If (Where(Mod_pos EQ c2014) Ne -1) Eq 0 Then Goto, Jump_Packet      ; Skipping modules which are not in the configuration.
                  
                  ;
                  ;-- Table Status has to be waiting --
                  ;
                  If Event_data[i].Rotation_Status NE 5 Then Goto, Jump_Packet
                  
                  ;
                  ;-- Inter Module Flag --
                  ;
                  If Event_data[i].Int_Mod_Flag EQ 1 Then Goto, Jump_Packet
                  
                  ;
                  ;-- Grab the Zenith Angle
                  ;
                  Temp_Zen_Angle = Event_data[i].Point_Zenith
                  
                  ;
                  ;-- Fix the Zenith Angle if over 360 --
                  ;
                  If Temp_Zen_Angle GT 300 Then Temp_Zen_Angle = Temp_Zen_Angle-360.00
                  
                  ;
                  ;-- Not Sure We need to round it yet as we build histogram with binsize = 2
                  ;Zen_Angle = Round(Temp_Zen_Angle)
                  
                  ;
                  ;-- make sure max zenith angle is 30
                  ;
                  If Temp_Zen_Angle GT 30 then goto, Jump_Packet
                  
                  Z_Angle = (Round(Temp_Zen_Angle)/2)  
                  
                  ;
                  ;-- Concat the Total Count array --
                  ;
                  Total_Count_Array[Z_Angle]++
             
                  ;
                  ;-- PC or C Selection ( Get the Total Counts Here )
                  ;
                  If (Event_data[i].Event_Class EQ 3) and (Event_data[i].No_Anodes EQ 2) Then Begin
                           PC_Count_Array[Z_Angle]++
                  EndIf Else If (Event_data[i].Event_Class EQ 1) and (Event_data[i].No_Anodes EQ 1) Then Begin
                           C_Count_Array[Z_Angle]++
                  EndIf
                  
                  ;
                  ; ------- Flagged Anode Rejection -------
                  ; Note: We want this for Energy Calibration but not for counts.
                  ;
                  For z = 0, n_elements(Flag_Mod)-1 Do begin
                        IF Flag_Mod[z] Eq Mod_Pos Then Begin
                              If Event_Data[i].Anode_ID_1 EQ Flag_Anodes[z] Then Goto, Jump_Packet
                              If Event_Data[i].Anode_ID_2 EQ Flag_Anodes[z] Then Goto, Jump_Packet
                        EndIF
                  EndFor
                  
                  ;
                  ;-- PC or CC Energy Things now
                  ;
                  If (Event_data[i].Event_Class EQ 3) and (Event_data[i].No_Anodes EQ 2) Then Begin
                        
                        ;                           ;           
                        ;---- Choose primary and secondary anodes. ----
                        ;
                        If Event_data[i].Anode_Type_1 EQ 1 Then Begin
                            Pri_Anode = Event_Data[i].Anode_ID_1
                            Pri_Energy= Event_data[i].Anode_Energy_1 
                            Sec_Anode = Event_Data[i].Anode_ID_2
                            Sec_Energy= Event_data[i].Anode_Energy_2
                        EndIF Else Begin
                            Pri_Anode = Event_Data[i].Anode_ID_2
                            Pri_Energy= Event_data[i].Anode_Energy_2 
                            Sec_Anode = Event_Data[i].Anode_ID_1
                            Sec_Energy= Event_data[i].Anode_Energy_1 
                        ENDELSE
                        
                        ;
                        ;---- Energy Cuts for the Plastic and the Calorimeters.----
                        ;
                        If (Pri_Energy LT Pla_Min) OR (Pri_Energy GT Pla_Max) Then Goto, Jump_Packet
                        If (Sec_Energy LT Cal_Min) OR (Sec_Energy GT Cal_Max) Then Goto, Jump_Packet
                        Tot_Energy = Double(Pri_Energy + Sec_Energy)
                        
                        ;
                        ;-- Check the Total Energy
                        ;
                        If Tot_Energy GE EMAX Then goto, Jump_Packet
                        
                        PC_Ener_Array[Z_Angle,Tot_Energy]++
                        
                  EndIf Else If (Event_data[i].Event_Class EQ 1) and (Event_data[i].No_Anodes EQ 1) Then Begin
                        
                        ;
                        ;-- Get the anode Energy --  
                        ;
                        Tot_Energy = Event_data[i].Anode_Energy_1 
                        
                        ;
                        ;-- Check the Total Energy
                        ;
                        If Tot_Energy GE Cal_Max Then goto, Jump_Packet
                        C_Ener_Array[Z_Angle,Tot_Energy]++
                        
                  EndIf
                  ;
                  ;-- Pointer to jump in case of bad event. 
                  ;
                  Jump_Packet:    
                  
                  ;
                  ;-- Print Statement to give hope that its running the program.
                  ;
                  If i mod 100000 EQ 0 Then print, i 
                  
             EndFor; /i
             
             ;
             ;-- Simple output to keep track of things --
             ;
             
;             Window,0
;             Plot, INDGEN(15)*2.0, Total_Count_Array, PSYM=10, /NODATA, XTITLE= 'Zenith Angle', Title ='Colimator Run', YTitle='Counts',CharSize=2, XTickInterval=2, XRANGE=[0,30]
;               Oplot, INDGEN(15)*2.0, Total_Count_Array, PSYM=10
;                  OPlot, INDGEN(15)*2.0, PC_Count_Array, PSYM=10, Color=CgColor('Red')
;                       OPlot, INDGEN(15)*2.0, C_Count_Array, PSYM=10, Color=CgColor('Green')
;             
;             A = PC_Ener_Array[temp,*]
;             B = C_Ener_Array[temp,*]
;                          temp = temp +1
;                          
;             Window,2
;             Plot, Indgen(Cal_Max), B, PSYM=10, XRANGE=[0,150], XSTYLE=1 ,/NODATA
;                  Oplot, Indgen(Cal_Max), B, PSYM=10,Color = CgColor('green') 
;                  Oplot, Indgen(EMAX), A, PSYM=10, Color = CgColor('red')
     EndFor ; p
     
     ;
     ;-- Generate Histogram Text Files --
     ;
     
     ;
     ;-- Count Histograms --
     ;
           ;
           ;-- Total Counts --
           ;
           Openw, Lun_Tot, Output_Folder+'Total_Hist' ,/Get_Lun
                Printf, Lun_Tot, ' Total Counts Histogram for Colimator Run '
                For i = 0, N_Elements(Total_Count_Array)-1 Do Begin
                      Printf, Lun_Tot, STRN(Total_Count_Array[i])
                EndFor
           Free_Lun, Lun_Tot

           ;
           ;-- PC Counts --
           ;
           Openw, Lun_PC, Output_Folder+'PC_Hist' ,/Get_Lun
                Printf, Lun_PC, ' PC Counts Histogram for Colimator Run '
                For i = 0, N_Elements(PC_Count_Array)-1 Do Begin
                      Printf, Lun_PC, STRN(PC_Count_Array[i])
                EndFor
           Free_Lun, Lun_PC

           ;
           ;-- Total Counts --
           ;
           Openw, Lun_C, Output_Folder+'C_Hist' ,/Get_Lun
                Printf, Lun_C, ' C Counts Histogram for Colimator Run '
                For i = 0, N_Elements(C_Count_Array)-1 Do Begin
                      Printf, Lun_C, STRN(C_Count_Array[i])
                EndFor
           Free_Lun, Lun_C

     ;
     ;-- Energy Histograms --
     ;
     
     For  p = 0,15 Do Begin
           
           ;
           ;-- PC --
           ;
           Main_Pc_Array = PC_Ener_Array[p,*]
           
           If Total(Main_PC_ARray) GT 0.0 Then Begin
           
                     Openw, Lun_a, Output_Folder+Title+'_PC_'+Strn(p*2)+'Deg_EHist' ,/Get_Lun
                          Printf, Lun_a, ' PC Energy Histogram for the Colimator Runs '
                          For i = 0, N_Elements(Main_PC_Array)-1 Do Begin
                                Printf, Lun_a, STRN(Main_PC_Array[i])
                          EndFor
                     Free_Lun, Lun_a
           EndiF
           
           
           ;
           ;-- C --
           ;
           Main_C_Array = C_Ener_Array[p,*]
           
           If Total(Main_C_Array) GT 0.0 Then Begin
                     
                     Openw, Lun_b, Output_Folder+Title+'_C_'+Strn(p*2)+'Deg_EHist' ,/Get_Lun
                          Printf, Lun_a, ' C Energy Histogram for the Colimator Runs '
                          For i = 0, N_Elements(Main_C_Array)-1 Do Begin
                                Printf, Lun_b, STRN(Main_C_Array[i])
                          EndFor
                     Free_Lun, Lun_b
           EndIf
               
     EndFor
     
     
Stop
End