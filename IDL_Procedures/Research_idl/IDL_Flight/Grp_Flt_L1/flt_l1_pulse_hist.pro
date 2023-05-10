Pro Flt_l1_Pulse_Hist, fsearch_String, Title= Title, nfiles=nfiles
; *************************************************************************
; *           Create a Pulse Spectrum for single Cal anode                *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read in the Level 1 Version 6 processed files and generate  *
; *           Pulse Height Spectrum for Calorimeters.                     *
; *                                                                       *
; * References: Flt_L1_Read.pro                                           *
; *            [ Reads in Flight level 1 version 6 files ]                *
; *                                                                       *
; * Usage: Flt_l1_Pulse_Hist, 'L1*.dat'                                   *
; *                                                                       *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *     nfiles = Number of files to be processed.                         *
; *                                                                       *
; *     title = added title to the created pulse histogram files.         *
; *                                                                       *
; *     Inputs::                                                          *
; *           fsearch_strings: We are already in the folder so this is    *
; *           the array with a wildcard or search string.                 *
; *                                                                       *
; *     Outputs::                                                         *
; *          A folder that contains:  pulse height spectrum for           *
; *                         Calorimeters.  24 files in totol              *
; *                                                                       *
; * Libraries Imported:                                                   *  
; *           -Coyote Full Library                                        *
; *           -Astronomy Full Library                                     *
; *           -MPFit Full Library. For fitting functions.                 *
; *                                                                       *
; * Files Used and thier Formats:                                         *
; *        L1_processed_file : Level 1 version 6 processed files          *
; *                 These files are generated via grp_l1process.pro       *
; *                                                                       *
; * Author: 9/21/14  Sambid Wasti                                         *
; *                  Email: Sambid.Wasti@wildcats.unh.edu                 *
; *                                                                       *
; * Revision History:                                                     *
; *                                                                       *
; *************************************************************************
; *************************************************************************
True =1
False=0
    
    ;-- Current Directory
    Cd, Cur=Cur
    
    ;
    ; ===== Initialization =====
    ;
    
        ;
        ;== KeyWords and Input Parameters==
        ;
        
        ;
        ;-- Title --
        ;
        IF Keyword_Set(title) Eq 0 Then Title='Test'
    
        ;
        ;-- Get the Files. (The L1*.dat files.)
        ;
        Evtfiles = FILE_SEARCH(fsearch_string)          

        ;
        ;-- No. of Files --
        ;
        If keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)
        
        ;
        ; == Some Variables/Structures and Arrays
        ;
        
        ;
        ;-- 2014 Configuration --
        ;
        c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration
        
        ;
        ;-- Define the structure to read in
        ;
        
        ;== Level 1 Structure. 
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
         ;--- Struc Defined ---
         
         ;
         ;-- Few Arrays and Variables used---
         ;
         
         ;-- Total Live Time array for each modules.
         Tot_Live_Time  = FltArr(32)
         
         ;-- Live time counter to get an average value
         Live_Time_Cnt  = LonArr(32)
         
         ;--- Total time ran, same for all the modules. 
         Total_Time_Ran = 0.0D
         
         ;--- Temporary Time variable ---
         Temp_Time = 0.0D
         
         ;
         ; Define an array for each module, despite not being in the configuration.. Will take care of it later.
         ; The first value is going to be 0 so we have to be careful of getting rid of it. 
         ;
               P0_PArr  = LonArr(64,1024)
               P1_PArr  = LonArr(64,1024)
               P2_PArr  = LonArr(64,1024)
               P3_PArr  = LonArr(64,1024)
               P4_PArr  = LonArr(64,1024)
               P5_PArr  = LonArr(64,1024)
               P6_PArr  = LonArr(64,1024)
               P7_PArr  = LonArr(64,1024)
               P8_PArr  = LonArr(64,1024)
               P9_PArr  = LonArr(64,1024)
               
               P10_PArr  = LonArr(64,1024)
               P11_PArr  = LonArr(64,1024)
               P12_PArr  = LonArr(64,1024)
               P13_PArr  = LonArr(64,1024)
               P14_PArr  = LonArr(64,1024)
               P15_PArr  = LonArr(64,1024)
               P16_PArr  = LonArr(64,1024)
               P17_PArr  = LonArr(64,1024)
               P18_PArr  = LonArr(64,1024)
               P19_PArr  = LonArr(64,1024)
               P20_PArr  = LonArr(64,1024)
               
               P21_PArr  = LonArr(64,1024)
               P22_PArr  = LonArr(64,1024)
               P23_PArr  = LonArr(64,1024)
               P24_PArr  = LonArr(64,1024)
               P25_PArr  = LonArr(64,1024)
               P26_PArr  = LonArr(64,1024)
               P27_PArr  = LonArr(64,1024)
               P28_PArr  = LonArr(64,1024)
               P29_PArr  = LonArr(64,1024)
               P30_PArr  = LonArr(64,1024)
               P31_PArr  = LonArr(64,1024)
         ;
         ;-------
         ;
     ;
     ; ===== Finished Initialization =====
     ;
     
     ;
     ;---- For Each of the file.
     ;
     For p = 0, nfiles-1 Do Begin ; open each file
             ;
             ;-- Grab One file at a time
             ;
             fname = evtfiles[p]
             
             ;
             ;-- Print file name for tracking purposes
             ;
             print, fname
             
             ;
             ;-- get the file information
             ;
             f = file_info(fname)
             
             ;
             ;-- Open the Binary File
             ;
             Openr, lun, fname, /GET_Lun     
             
             ;
             ;-- Total no. of Event Packets
             ;
             TotPkt = long(f.size/Packet_Len)   
             
             ;
             ;-- Define an array of structures
             ;
             Event_data = replicate(Struc, TotPkt)  
             
             ;
             ;-- Grab all the packets in one go using a structure.
             ;
             For i = 0, TotPkt-1 Do Begin
                    readu, lun, Struc        ; read one event
                    Event_data[i] =Struc        ; add it to input array
             EndFor
             
             ;
             ;-- Free the Lun ; Close the file.
             ;
             Free_Lun, lun
             
             ;
             ;-- Now work on one event packet at a time
             ;
             For i = 0, TotPkt-1 Do Begin
                  
                  ;
                  ;-- Grab a temp time to keep track of the total time ran.
                  ;
                  Temp_Time = Event_Data[i].Swept_Time ; For total time ran.
                  
                  ;
                  ;-- Event Selection : C events and 1 anode fired.
                  ;
                  If (Event_data[i].Event_Class NE 1) Or (Event_Data[i].No_Anodes NE 1) Then goto, Jump_Packet
                  
                  ;
                  ;-- Get the Module Position
                  ;
                  Mod_pos = Event_data[i].Mod_Position      ; Module Position
                  
                  ;
                  ;-- Module Filter: Skip for the modules that are not in 2014 configuration.
                  ;
                  If (Where(Mod_pos EQ c2014) Ne -1) Eq 0 Then Goto, Jump_Packet      ; Skipping modules which are not in the configuration.
                  
                  ;           
                  ;--- Grab the anode no.
                  ;
                  Anode = Event_Data[i].Anode_ID_1
                  
                  ;
                  ;--- Grab the anode Pulse Height
                  ;
                  Pulse= Event_data[i].Anode_Pha_1
                  
                  ;
                  ;---- Add the live time and live time counter ----
                  ;
                  Tot_Live_Time[Mod_Pos] = Tot_Live_time[Mod_Pos]+Event_data[i].Cor_Live_Time
                  Live_Time_Cnt[Mod_pos]++
                  
                  ;
                  ;-- Build the Pulse Height Histogram --
                  ;
                  IF Pulse LT 1024 Then Begin 
                        
                        If Mod_Pos EQ 0 Then P0_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 2 Then P2_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 3 Then P3_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 4 Then P4_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 6 Then P6_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 7 Then P7_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 9 Then P9_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 10 Then P10_PArr[Anode,Pulse]++
                        
                        If Mod_Pos EQ 11 Then P11_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 12 Then P12_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 13 Then P13_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 14 Then P14_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 17 Then P17_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 18 Then P18_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 19 Then P19_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 20 Then P20_PArr[Anode,Pulse]++
                        
                        If Mod_Pos EQ 21 Then P21_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 22 Then P22_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 24 Then P24_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 25 Then P25_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 27 Then P27_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 28 Then P28_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 29 Then P29_PArr[Anode,Pulse]++
                        If Mod_Pos EQ 31 Then P31_PArr[Anode,Pulse]++
                  EndIF
                  
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
              ;-- Total time ran, sum of each sweep time for each file.
              ;
              Total_Time_Ran = Total_Time_Ran + Temp_Time
              
              ;
              ;-- Another marker for knowing how many files are left.
              ;
              Files_Left = nfiles-p
              Print, 'No. of Files LEft : '+STRN(Files_Left-1)
              
    EndFor; /p
         
    ;
    ;========== Generating 24 Module Histogram Text files.. ============
    ;
    
    ;
    ;-- Define/Create the Directory to dump all the files.
    ;
    Cur = Cur+'/Flt_ECal'
    If Dir_Exist(Cur) EQ 0 Then File_MKdir, Cur ; making a directory
    
    ;
    ;------For Module 0-------
    ;
    Title2 = Title+'_Mod0_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun0, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[0])/Double(Live_Time_Cnt[0]))
        Printf, Lun0, Title+' Pulse Histogram '
        Printf, Lun0, 'Module Position   =0'
        Printf, Lun0, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun0, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun0, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun0, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                     Temp_String = Temp_String+ Strn(P0_PArr[p,j])+' '
              EndFor
        Printf, Lun0, Temp_String
        EndFor
    Free_Lun, Lun0
    
    ;
    ;------For Module 2-------
    ;
    Title2 = Title+'_Mod2_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun2, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[2])/Double(Live_Time_Cnt[2]))
        Printf, Lun2, Title+' Pulse Histogram '
        Printf, Lun2, 'Module Position   =2'
        Printf, Lun2, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun2, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun2, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun2, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P2_PArr[p,j])+' '
              EndFor
        Printf, Lun2, Temp_String
        EndFor
    Free_Lun, Lun2
    
    ;
    ;------For Module 3-------
    ;
    Title2 = Title+'_Mod3_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun3, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[3])/Double(Live_Time_Cnt[3]))
        Printf, Lun3, Title+' Pulse Histogram '
        Printf, Lun3, 'Module Position   =3'
        Printf, Lun3, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun3, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun3, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun3, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P3_PArr[p,j])+' '
              EndFor
        Printf, Lun3, Temp_String
        EndFor
    Free_Lun, Lun3
    
    ;
    ;------For Module 4-------
    ;
    Title2 = Title+'_Mod4_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun4, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[4])/Double(Live_Time_Cnt[4]))
        Printf, Lun4, Title+' Pulse Histogram '
        Printf, Lun4, 'Module Position   =4'
        Printf, Lun4, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun4, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun4, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun4, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P4_PArr[p,j])+' '
              EndFor
        Printf, Lun4, Temp_String
        EndFor
    Free_Lun, Lun4
    
    ;
    ;------For Module 6-------
    ;
    Title2 = Title+'_Mod6_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun6, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[6])/Double(Live_Time_Cnt[6]))
        Printf, Lun6, Title+' Pulse Histogram '
        Printf, Lun6, 'Module Position   =6'
        Printf, Lun6, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun6, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun6, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun6, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P6_PArr[p,j])+' '
              EndFor
        Printf, Lun6, Strn(p)+ Temp_String
        EndFor
    Free_Lun, Lun6
    
    ;
    ;------For Module 7-------
    ;
    Title2 = Title+'_Mod7_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun7, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[7])/Double(Live_Time_Cnt[7]))
        Printf, Lun7, Title+' Pulse Histogram '
        Printf, Lun7, 'Module Position   =7'
        Printf, Lun7, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun7, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun7, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun7, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P7_PArr[p,j])+' '
              EndFor
        Printf, Lun7, Temp_String
        EndFor
    Free_Lun, Lun7
    
    ;
    ;------For Module 9-------
    ;
    Title2 = Title+'_Mod9_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun9, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[9])/Double(Live_Time_Cnt[9]))
        Printf, Lun9, Title+' Pulse Histogram '
        Printf, Lun9, 'Module Position   =9'
        Printf, Lun9, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun9, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun9, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun9, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P9_PArr[p,j])+' '
              EndFor
        Printf, Lun9, Temp_String
        EndFor
    Free_Lun, Lun9
    
    ;
    ;------For Module 10-------
    ;
    Title2 = Title+'_Mod10_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun10, O_file, /Get_Lun 
       AvgLT=(Double(Tot_Live_Time[10])/Double(Live_Time_Cnt[10]))
        Printf, Lun10, Title+' Pulse Histogram '
        Printf, Lun10, 'Module Position   =10'
        Printf, Lun10, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun10, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun10, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun10, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P10_PArr[p,j])+' '
              EndFor
        Printf, Lun10, Temp_String
        EndFor
    Free_Lun, Lun10
    
    ;
    ;------For Module 10-------
    ;
    Title2 = Title+'_Mod11_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun11, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[11])/Double(Live_Time_Cnt[11]))
        Printf, Lun11, Title+' Pulse Histogram '
        Printf, Lun11, 'Module Position   =11'
        Printf, Lun11, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun11, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun11, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun11, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P11_PArr[p,j])+' '
              EndFor
        Printf, Lun11, Temp_String
        EndFor
    Free_Lun, Lun11
    
    ;
    ;------For Module 12-------
    ;
    Title2 = Title+'_Mod12_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun12, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[12])/Double(Live_Time_Cnt[12]))
        Printf, Lun12, Title+' Pulse Histogram '
        Printf, Lun12, 'Module Position   =12'
        Printf, Lun12, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun12, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun12, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun12, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P12_PArr[p,j])+' '
              EndFor
        Printf, Lun12, Temp_String
        EndFor
    Free_Lun, Lun12
    
    ;
    ;------For Module 13-------
    ;
    Title2 = Title+'_Mod10_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun13, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[13])/Double(Live_Time_Cnt[13]))
        Printf, Lun13, Title+' Pulse Histogram '
        Printf, Lun13, 'Module Position   =13'
        Printf, Lun13, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun13, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun13, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun13, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P13_PArr[p,j])+' '
              EndFor
        Printf, Lun13, Temp_String
        EndFor
    Free_Lun, Lun13
    
    ;
    ;------For Module 14-------
    ;
    Title2 = Title+'_Mod14_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun14, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[14])/Double(Live_Time_Cnt[14]))
        Printf, Lun14, Title+' Pulse Histogram '
        Printf, Lun14, 'Module Position   =14'
        Printf, Lun14, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun14, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun14, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun14, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P14_PArr[p,j])+' '
              EndFor
        Printf, Lun14,Temp_String
        EndFor
    Free_Lun, Lun14
    
    ;
    ;------For Module 17-------
    ;
    Title2 = Title+'_Mod17_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun17, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[17])/Double(Live_Time_Cnt[17]))
        Printf, Lun17, Title+' Pulse Histogram '
        Printf, Lun17, 'Module Position   =17'
        Printf, Lun17, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun17, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun17, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun17, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P17_PArr[p,j])+' '
              EndFor
        Printf, Lun17, Temp_String
        EndFor
    Free_Lun, Lun17
    
    ;
    ;------For Module 18-------
    ;
    Title2 = Title+'_Mod18_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun18, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[18])/Double(Live_Time_Cnt[18]))
        Printf, Lun18, Title+' Pulse Histogram '
        Printf, Lun18, 'Module Position   =18'
        Printf, Lun18, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun18, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun18, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun18, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P18_PArr[p,j])+' '
              EndFor
        Printf, Lun18, Temp_String
        EndFor
    Free_Lun, Lun18
    
    ;
    ;------For Module 19-------
    ;
    Title2 = Title+'_Mod19_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun19, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[19])/Double(Live_Time_Cnt[19]))
        Printf, Lun19, Title+' Pulse Histogram '
        Printf, Lun19, 'Module Position   =18'
        Printf, Lun19, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun19, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun19, 'Average Live Time ='+Strn(AvgLT)
        
        
        For p = 0,63 Do begin
              Printf, Lun19, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P19_PArr[p,j])+' '
              EndFor
        Printf, Lun19, Temp_String
        EndFor
    Free_Lun, Lun19
    
    ;
    ;------For Module 20-------
    ;
    Title2 = Title+'_Mod20_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun20, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[20])/Double(Live_Time_Cnt[20]))
        Printf, Lun20, Title+' Pulse Histogram '
        Printf, Lun20, 'Module Position   =20'
        Printf, Lun20, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun20, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun20, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun20, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P20_PArr[p,j])+' '
              EndFor
        Printf, Lun20, Temp_String
        EndFor
    Free_Lun, Lun20
    
    ;
    ;------For Module 20-------
    ;
    Title2 = Title+'_Mod20_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun20, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[20])/Double(Live_Time_Cnt[20]))
        Printf, Lun20, Title+' Pulse Histogram '
        Printf, Lun20, 'Module Position   =20'
        Printf, Lun20, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun20, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun20, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun20, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P20_PArr[p,j])+' '
              EndFor
        Printf, Lun20, Temp_String
        EndFor
    Free_Lun, Lun20
    
    ;
    ;------For Module 21-------
    ;
    Title2 = Title+'_Mod21_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun21, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[21])/Double(Live_Time_Cnt[21]))
        Printf, Lun21, Title+' Pulse Histogram '
        Printf, Lun21, 'Module Position   =21'
        Printf, Lun21, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun21, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun21, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun21, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P21_PArr[p,j])+' '
              EndFor
        Printf, Lun21,Temp_String
        EndFor
    Free_Lun, Lun21
    
    ;
    ;------For Module 22-------
    ;
    Title2 = Title+'_Mod22_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun22, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[22])/Double(Live_Time_Cnt[22]))
        Printf, Lun22, Title+' Pulse Histogram '
        Printf, Lun22, 'Module Position   =22'
        Printf, Lun22, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun22, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun22, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun22, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P22_PArr[p,j])+' '
              EndFor
        Printf, Lun22,Temp_String
        EndFor
    Free_Lun, Lun22
    
    ;
    ;------For Module 24-------
    ;
    Title2 = Title+'_Mod24_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun24, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[24])/Double(Live_Time_Cnt[24]))
        Printf, Lun24, Title+' Pulse Histogram '
        Printf, Lun24, 'Module Position   =24'
        Printf, Lun24, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun24, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun24, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun24, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P24_PArr[p,j])+' '
              EndFor
        Printf, Lun24, Temp_String
        EndFor
    Free_Lun, Lun24
    
    ;
    ;------For Module 25-------
    ;
    Title2 = Title+'_Mod25_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun25, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[25])/Double(Live_Time_Cnt[25]))
        Printf, Lun25, Title+' Pulse Histogram '
        Printf, Lun25, 'Module Position   =25'
        Printf, Lun25, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun25, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun25, 'Average Live Time ='+Strn(AvgLT)
        
        
        For p = 0,63 Do begin
              Printf, Lun25, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P25_PArr[p,j])+' '
              EndFor
        Printf, Lun25, Temp_String
        EndFor
    Free_Lun, Lun25
    
    ;
    ;------For Module 27-------
    ;
    Title2 = Title+'_Mod27_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun27, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[27])/Double(Live_Time_Cnt[27]))
        Printf, Lun27, Title+' Pulse Histogram '
        Printf, Lun27, 'Module Position   =27'
        Printf, Lun27, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun27, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun27, 'Average Live Time ='+Strn(AvgLT)
        
         For p = 0,63 Do begin
              Printf, Lun27, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P27_PArr[p,j])+' '
              EndFor
        Printf, Lun27, Temp_String
        EndFor
    Free_Lun, Lun27
    
    ;
    ;------For Module 28-------
    ;
    Title2 = Title+'_Mod28_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun28, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[28])/Double(Live_Time_Cnt[28]))
        Printf, Lun28, Title+' Pulse Histogram '
        Printf, Lun28, 'Module Position   =28'
        Printf, Lun28, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun28, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun28, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun28, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P28_PArr[p,j])+' '
              EndFor
        Printf, Lun28, Temp_String
        EndFor
    Free_Lun, Lun28
    
    ;
    ;------For Module 29-------
    ;
    Title2 = Title+'_Mod29_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun29, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[29])/Double(Live_Time_Cnt[29]))
        Printf, Lun29, Title+' Pulse Histogram '
        Printf, Lun29, 'Module Position   =29'
        Printf, Lun29, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun29, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun29, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun29, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P29_PArr[p,j])+' '
              EndFor
        Printf, Lun29, Temp_String
        EndFor
    Free_Lun, Lun29
    
    ;
    ;------For Module 31-------
    ;
    Title2 = Title+'_Mod31_PHist.txt'
    O_File = CUR+'/'+Title2
    Openw, Lun31, O_file, /Get_Lun 
        AvgLT=(Double(Tot_Live_Time[20])/Double(Live_Time_Cnt[20]))
        Printf, Lun31, Title+' Pulse Histogram '
        Printf, Lun31, 'Module Position   =31'
        Printf, Lun31, 'No. of files      ='+Strn(Nfiles)
        Printf, Lun31, 'Total Time Ran    ='+Strn(Total_Time_Ran)
        Printf, Lun31, 'Average Live Time ='+Strn(AvgLT)
        
        For p = 0,63 Do begin
              Printf, Lun31, 'Anode ='+Strn(p)
              Temp_String = ''
              For j= 0,1023 Do begin
                      Temp_String = Temp_String+ Strn(P31_PArr[p,j])+' '
              EndFor
        Printf, Lun31,Temp_String
        EndFor
    Free_Lun, Lun31
    
End