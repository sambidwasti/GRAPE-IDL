Pro Cal_Tool_Flt_Hist, Input_File, Flag_anodes
; Read the ASCII Flight mode to generate a Histogram of Bin_Width =1, NON-Scaled
; We have C, PC, CC Arrays. 
; IMPORTANT: NEED the ENERGY FILE IN THE SAME FOLDER.
; The Length of the Array is UNKNOWN so we are making the Array until 2000 KEV
; FIle name should have FMXXX Module no. at the start.
; File name should end with TimeRan_Event.txt
; Defining the Bit Flags for convinience.
True =1
False=0
    
    ;==========
    Max_Anode_Number = 2        ;No. of Anodes Fired.
    
    Cal_Max= 400                ;Upper Energy Cut for a Calorimeter
    Cal_Min= 25                 ;Lower Energy Cut for a Calorimeter
    
    Pla_Max= 150                ;Upper Energy Cut for a Plastic
    Pla_Min= 10                 ;Lower Energy Cut for a Plastic
    
    ;==========
    
    
    ;===== Output Folder and file name selection ====
      T_num = 0 ; Temporary Number Variable
      For k = 0, StrLen(Input_File)-5 Do Begin ; For Multiple / included with different folders.
          T_num = StrPos(Input_File, '/',k)
          If T_num NE -1 Then Pos = T_num
      EndFor; k
      
    Output_Folder= StrMid(Input_File,0,Pos+1)
    File_Name = StrMid(Input_File,Pos+1,Strlen(Input_File)-Pos-1-4-6)   ; File Name, 4=.txt, 6=_Event
    Print, File_Name
    Print, Output_Folder
    ;==================
    
    Module = StrMid(File_Name,2,3)
    ;===== ENERGY INFORMATION EXTRACTION ====================
      E_File = File_Search(Output_Folder+'FM'+Module+'*Energy_Calibration*.txt')
      
      Openr, Lun1, E_File, /Get_Lun
          Energy_Array = FltArr(64,2)     ; Array[0,0]= slope and Array[0,1]= Intercept
          Data1 = ''
          Row_File1 = File_Lines(E_File)
          
          For j=0,Row_File1[0]-1 Do Begin

              Readf, Lun1, Data1

              If j Gt 9 Then Begin  ; For skipping comments. we start at 0 so GT 9 for 10 lines to skip.
              
                      Pos = StrPos(Data1,' ',1)
                      p = FIX(StrMid(Data1,0,Pos)) ; Anode
                      
                      Pos1 = StrPos(Data1,'.',Pos)
                      Pos2 = StrPos(Data1,' ',Pos1)
                      M = Float(StrMid(Data1,Pos+1,Pos2-Pos))
      
                      Pos = Pos2
                      Pos1 = StrPos(Data1,'.',Pos)
                      Pos2 = StrPos(Data1,' ',Pos1)
                      
                      Pos = Pos2
                      Pos1 = StrPos(Data1,'.',Pos)
                      Pos2 = StrPos(Data1,' ',Pos1)
                      C = Float(StrMid(Data1,Pos+1,Pos2-Pos))
                      
                      Energy_Array[p,0]= M
                      Energy_Array[p,1]= C
                      
              Endif
          EndFor
    
      Free_Lun, Lun1
      ;================ ENERGY stored in Energy_Array ============
      
      
      ;==== READ AND BUILD HISTOGRAM ====
      PC_Array = FLTARR(2000)
      CC_Array = FLTARR(2000)
      C_Array  = FLTARR(2000)
      
      LiveTime_Cntr = 0L
      Tot_LIveTime = 0.0D
      Openr, Lun, Input_File, /Get_Lun
              Data = ''
              
              While Not EOF(Lun) DO Begin
              Readf, Lun, Data
              
              S_Value = StrMid(Data,0,2)
              
              IF ((S_Value NE '# ') And (S_Value NE 'C ')) Then Goto, Jump_Line

              ;Selecting 2 Events at Most.
              Pos1 = StrPos(Data,' ',0)
              Pos2 = StrPos(Data,' ',Pos1+1)
              Temp_Str = StrMid(Data, Pos1, Pos2-Pos1)
              If Temp_Str EQ ' Valid' Then Goto, Jump_Line
              N_Anodes = FIx(Temp_Str)
              If N_Anodes GT Max_Anode_Number then Goto, Jump_Line
            
              ;---- Getting the Live Time ----
              Pos1 = StrPos(Data,' ', Pos2+1)
              Temp_Str = StrMid(Data, Pos2, Pos1-Pos2)
              Live_Time= Float(Temp_Str)
              Tot_LiveTime= Tot_LiveTime+Live_Time
              LiveTime_Cntr++
              
              
              ;---- Getting the Anodes and Pulse  Heights
              Pos2 = StrPos(Data,' ',Pos1+1)

              If (Pos2-Pos1) NE 6 Then Goto, Jump_Line      ; Checking for incorrect data format
              Temp_Str = StrMid(Data, Pos1, Pos2-Pos1)
              Anode1 = Fix(Strmid(Data,Pos1+1, 2))-1
              Pulse1 = Fix(Strmid(Data,Pos1+3, 3))
              Energy1= Energy_Array[Anode1,0]*Pulse1 + Energy_Array[Anode1,1]
              Tot_Energy = Energy1
              
              ;--- Energy Cuts ---
              IF (AnodeType(Anode1+1) EQ 0) And Energy1 LE Cal_Min THen GOTO, JUmp_Line
              IF (AnodeType(Anode1+1) EQ 1) And Energy1 LE Pla_Min THen GOTO, JUmp_Line
              
              IF (AnodeType(Anode1+1) EQ 0) And Energy1 GE Cal_Max THen GOTO, JUmp_Line
              IF (AnodeType(Anode1+1) EQ 1) And Energy1 GE Pla_Max THen GOTO, JUmp_Line
              
              If N_Anodes GT 1 Then BEgin
                  Pos1 = StrPos(Data,' ', Pos2+1)
                  If (Pos1- Pos2) NE 6 then Goto, Jump_Line     ; Checking for incorrect data format
                  Temp_Str = StrMid(Data, Pos2, Pos1-Pos2)
                  Anode2 = Fix(Strmid(Data,Pos2+1, 2))-1
                  
                  Pulse2 = Fix(Strmid(Data,Pos2+3, 3))
                  Energy2= Energy_Array[Anode2,0]*Pulse2 + Energy_Array[Anode2,1]
                  
                  Tot_Energy=Tot_ENergy+Energy2
                  
                  ; Energy Cuts
                  IF (AnodeType(Anode2+1) EQ 0) And Energy2 LE Cal_Min THen GOTO, JUmp_Line
                  IF (AnodeType(Anode2+1) EQ 1) And Energy2 LE Pla_Min THen GOTO, JUmp_Line
                  
                  IF (AnodeType(Anode2+1) EQ 0) And Energy2 GE Cal_Max THen GOTO, JUmp_Line
                  IF (AnodeType(Anode2+1) EQ 1) And Energy2 GE Pla_Min THen GOTO, JUmp_Line
                  
                  ;Event Type
                  If (EventType(Anode1+1,Anode2+1)) NE 1 Then Goto, Jump_Line
                  
              EndIF
             
              For p =0,N_Elements(Flag_Anodes)-1 Do BEgin
                          If N_Anodes GT 1 Then If ANode1 Eq Flag_Anodes[p] and Anode2 Eq Flag_Anodes[p] THen Goto, Jump_Line Else $
                              If ANode1 Eq Flag_Anodes[p] Then Goto, Jump_Line
              EndFor
              
              If Tot_Energy GT 1999 Then Goto, Jump_Line ; Max Energy
              
              If (S_Value EQ '# ') and N_Anodes EQ 2 Then Begin 
                   PC_Array(Tot_Energy)++       ; PC Array
              EndIf else begin 
                          If (S_Value EQ 'C ') Then BEgin ; CC Array or C Array
                                If N_Anodes EQ 2 Then CC_Array(Tot_Energy)++ Else C_Array(Tot_Energy)++
                          EndIF
              EndElse

              Jump_Line:
              EndWhile
      Free_Lun, Lun
      
      AVGLiveTime = Tot_LiveTime/LiveTime_Cntr

      T_num = 0 ; Temporary Number Variable
      For k = 0, StrLen(File_Name)-5 Do Begin ; For Multiple / included with different folders.
          T_num = StrPos(File_Name, '_',k)
          If T_num NE -1 Then Pos = T_num
      EndFor; k
      Time_Ran= StrMid(File_Name,Pos+1,StrLen(File_name)-Pos)
      
      ;======GET the text file now.. NEW FORMAT: Hist.txt for histogram files====
      Openw, Lun2, Output_Folder+File_Name+'_CC_Hist.txt', /Get_Lun
                
                ;The 10 Lines of Various Informations
                
                Printf, Lun2, 'Histogram File for plotting,binning,scaling,fitting,etc' ;Line1
                Printf, Lun2, 'File           ='+Input_File                                ;Line2
                Printf, Lun2, 'Time_Ran       ='+Time_Ran                                 ;Line3
                PRintf, LUn2, 'Avg_Live_Time  ='+Strn(AVGLiveTime)                        ;Line4
                Printf, Lun2, 'File_Name      ='+File_Name+'_CC'
                
                Printf, Lun2, 'Empty_Line'  ;Line6
                Printf, Lun2, 'Empty_Line'  ;Line7
                Printf, Lun2, 'Empty_Line'  ;Line8
                Printf, Lun2, 'Empty_Line'  ;Line9
                Printf, Lun2, 'Comments_End'  ;Line10
                Printf, Lun2, ''  ;Line11
                
                ; Now the Histogram 
                For i = 0, N_Elements(CC_Array)-1 Do Begin
                        Temp_Text = Strn(CC_Array[i])
                        Printf, Lun2, Temp_Text
                EndFor
      Free_Lun, Lun2
      
      Openw, Lun4, Output_Folder+File_Name+'_C_Hist.txt', /Get_Lun
                
                ;The 10 Lines of Various Informations
                
                Printf, Lun4, 'Histogram File for plotting,binning,scaling,fitting,etc' ;Line1
                Printf, Lun4, 'File           ='+Input_File                                ;Line2
                Printf, Lun4, 'Time_Ran       ='+Time_Ran                                 ;Line3
                PRintf, LUn4, 'Avg_Live_Time  ='+Strn(AVGLiveTime)                        ;Line4
                Printf, Lun4, 'File_Name      ='+File_Name+'_C'
                
                Printf, Lun4, 'Empty_Line'  ;Line6
                Printf, Lun4, 'Empty_Line'  ;Line7
                Printf, Lun4, 'Empty_Line'  ;Line8
                Printf, Lun4, 'Empty_Line'  ;Line9
                Printf, Lun4, 'Comments_End'  ;Line10
                Printf, Lun4, ''  ;Line11
                
                ; Now the Histogram 
                For i = 0, N_Elements(C_Array)-1 Do Begin
                        Temp_Text = Strn(C_Array[i])
                        Printf, Lun4, Temp_Text
                EndFor
      Free_Lun, Lun4
      
      Openw, Lun3, Output_Folder+File_Name+'_PC_Hist.txt', /Get_Lun
                
                ;The 10 Lines of Various Informations
                
                Printf, Lun3, 'Histogram File for plotting,binning,scaling,fitting,etc' ;Line1
                Printf, Lun3, 'File_Path_Name ='+Input_File                                ;Line2
                Printf, Lun3, 'Time_Ran       ='+Time_Ran                                 ;Line3
                PRintf, LUn3, 'Avg_LT         ='+Strn(AVGLiveTime)                        ;Line4
                Printf, Lun3, 'File_Name      ='+File_Name+'_PC'
                
                Printf, Lun3, 'Empty_Line'  ;Line6
                Printf, Lun3, 'Empty_Line'  ;Line7
                Printf, Lun3, 'Empty_Line'  ;Line8
                Printf, Lun3, 'Empty_Line'  ;Line9
                Printf, Lun3, 'Comments_End'  ;Line10
                Printf, Lun3, ''  ;Line11
                
                ; Now the Histogram 
                For i = 0, N_Elements(PC_Array)-1 Do Begin
                        Temp_Text = Strn(PC_Array[i])
                        Printf, Lun3, Temp_Text
                EndFor
      Free_Lun, Lun3
End