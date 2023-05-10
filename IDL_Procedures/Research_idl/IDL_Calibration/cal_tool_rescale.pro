Pro Cal_Tool_Rescale, Input_File, Scale=Scale

; *         11/15/13  Sambid Wasti                                        *
; *                   Modifying/Adding a scale factor that can filter out *
; *                   portion of the data ran, Usually for lower Time     *
;

      True  = 1         ; Define True     ( Easier to identify the Flags and Number this way )        
      False = 0         ; Define False
      
              If Keyword_Set(Scale) EQ 0 Then Scale_Flag=False Else Begin
                        Scale_Flag=True
                        Scale_Time= FIX(Scale)
              EndElse
              
              ; Since we are only interested where there are 1 anodes fired in an event. 
              Event = 1

              ; Input File or Files Existence and Validity
              Anode_Histogram = LONArr(64,1024)
              Fname = Input_File

              T_num = 0 ; Temporary Number Variable
              For k = 0, StrLen(Fname)-5 Do Begin ; For Multiple FM included with different folders.
                    T_num = StrPos(Fname, 'FM',k)
                    If T_num NE -1 Then Pos = T_num
              EndFor              
              
              Input_Folder = StrMid(Fname,0,Pos)
              
              F_Name = StrMid(Fname, Pos, StrLen(Fname)-Pos)
              Pos1 = StrPos(Fname,'_',Pos+14)
              Pos2 = StrPos(Fname,'_',Pos1+11)+1
              Pos5 = StrPos(Fname,'_',Pos1+3)+1
              Pos4 = StrPos(Fname,'_',Pos2+2)+1
              Pos3 = StrPos(Fname,'_',Pos4+2)
                    
              Pos6 = StrPos(Fname,'Event.txt',Pos1)
              
              Out_File= Strmid(Fname,Pos,Pos4-Pos)

              Module  = StrMid(Fname, Pos, 5)
              Angle   = StrMid(Fname, Pos+6, 3)
              Src     = StrMid(Fname, Pos+13,Pos1-Pos-13)
              Str_Mins= StrMid(Fname, Pos4, Pos3-Pos4)
                    
              T_Mins   =         Long(STRN(Str_Mins))
              Temp_CValue =      STRN(StrMId(Fname, Pos2+1, 3))
              Temp_PValue =      STRN(StrMid(Fname, Pos5+1, 3))
Print, T_Mins
              ; ===========**Open File**=============
              OPENR, logicUnit, fname, /GET_LUN                          ; Open the file. 
              data =''                                                       
              Rows_File = File_Lines(fname)
              
              if Scale_Flag EQ True Then BEgin ; Few extra lines than needed to clear any issues
                 
                        Temp_time = Float(T_Mins)
                        Scl_Time= Float(Scale_Time)
                        Scale_Factor= Float(Scl_Time/Temp_Time)
                        New_Rows_of_File = Float(Rows_File*Scale_Factor)
                        Scaled_Line = Long(New_Rows_of_File)
              Endif Else Begin
                              Scaled_Line= Rows_File
                              Scale_Time = T_Mins
              EndElse
              
              ;========== Work With The Data =============    
              Pulse = lonarr(64,1024)                                   ; At first we create an array of file length to store the Pulse Heights
              SLen = 0L                                                 ; Each String Length ( Each Line )
              Errorcount = 0L                                           ; Total No. Of Error lines encountered.
              
              Tot_Live_Time = 0L                                        ; We need total live time to get the average.
              Cnt_Live_Time = 0L                                        ; Which gives total Number of Valid Events
              Temp_Count = 0L
              ; Live Time and Time and Count Rate..                    
              Live_Time_Array  = FltArr(Rows_File/2)
              Count_Rate_Array = FltArr(Rows_File/2)
              Main_Time_Array  = LonArr(Rows_File/2)
              New_Time         = 0L
              Avg_L_Time       = 0L
              Count_Rate       = 0L
              Average_Counter  = 0L
              mSecond_Counter   = 0L
                    
              ; Operating on Each line of the File         
              While not EOF(logicunit) DO Begin
                        Temp_Count++
                        READF, logicUnit, data                             ; Read File Line by Line
                        SLen = strlen(data)                                ; Length of the Line    
                        Flag = False                                       ; Error Flag ( Checking Errors..) [ True for Error ]
                        N_Counter = 0                                      ; Counter for No. Of Events
                        
                        ;==** Standard: # 12 123 123456 123456 123456.. : 123 LT, 12 T, # good
                        
                        If strmid(data,0,1) NE '#' Then Flag = True        ; Check for good data.
                        
                        Time = StrMid(data,2,2)                            ; Extract the Time
                        
                        jstart= strpos(data, " ", 3) +1                    ; The Live time is of only 3 Digit. 
                        L_Time = Strn(Strmid(data, jstart,3))              ; Get the Live_Time
                        
                        ;============== **ERROR CHECKING** =================
                        jstart= strpos(data, " ",6) +1                     ; Next Space + 1 location is the starting of the values. 
                        For j = jstart,SLen-5 Do Begin                                    ; SLen-4 just operate it quicker
                                If ( strmid(data,j-1,1) NE " ") OR ( strmid(data,j+6,1) NE " ")  Then  Flag = True     ;####  If the format is invalid 
                                N_Counter++
                                j = j+6                                                  ; We are only doing j = j+5 instead of j + 6 because for loop increments 1 for us.     
                        EndFor  ;j 
                        
                        If strmid(data,jstart,1)EQ " " Then  Flag =True                     ; ####Error For Two Spaces.. 
                        If jstart GT 9 Then Flag = True                                    ; ####IF there is no space in the start. The position goes around to next which might be valid so this check needs to be done.
                        If N_Counter NE Event Then Flag = True                             ; Selects only 1 Anode Event
                        ;===================================================
                        
                        ;=========Data Collection===========================
                        ; The Actual data
                        If Flag EQ False Then Begin ; If No Errors.
                                  ;Live Time Variables.
                                  Live_Time = FIX(L_Time)
                                  Tot_Live_Time= Tot_Live_Time + Live_Time
                                  Cnt_Live_Time++
                                  
                                  For j = jstart,SLen-4 Do Begin     
                                          
                                          panode= FIX(strmid(data,j,2))                 ; Grab the Anode No.
                                          p=panode-1
                                          Temp_Pulse = FIX(strmid(data,j+2,4))
                                          Pulse[p,Temp_pulse]++
                                          j = j+6
                                 EndFor
                         EndIf  Else Begin
                                          Errorcount++
                                          IF (StrTrim(Data,2) NE '') And (N_Counter LE 1) then Print, Data
                         EndElse
                                 ;====================================================
                   
                    If (Scale_Flag Eq True) and (Temp_COunt GE Scaled_Line) Then Goto, Jump_Scale
                    If (Temp_Count mod 1000000) EQ 0 Then Print, Temp_Count
                    EndWHile
                    Jump_Scale:
                    FREE_LUN, logicUnit                                       ; Closing the file 
             
                    Avg_Live_Time = Float(Tot_Live_Time)/Float(Cnt_Live_Time)                    ; Live Time for Each Source.
                    
                    Anode_Histogram = Pulse
                    ; ===========**Close File**=============
                    
                    M_Module = Module
                   
                   ;================    OUTPUT Begins ==============
                   OutputFolder = Input_Folder
                   
                   ; Create a text file for each of the sources. 
                   O_File = OutputFolder+Out_File+Strn(Scale_Time)+'_Spect.txt'
                   file = O_File
                   
                   If Scale_Flag Eq True then T_Mins = Scale_Time
                        Openw, Lun, file, /Get_Lun 
                              Printf, Lun, 'File            :'+ F_Name
                              Printf, Lun, 'Source          :'+ Src
                              Printf, Lun, 'Module          :'+ Module
                              Printf, Lun, 'Line 4 : Empty for now'
                              Printf, Lun, 'LiveTime        :'+ Strn(Avg_Live_Time)
                              Printf, Lun, 'Time_Ran        :'+ Strn(T_mins)     
                              Printf, Lun, 'Line 7'
                              Printf, Lun, 'Line 8'
                              Printf, Lun, 'Line 9'
                              Printf, Lun, 'Line 10'
                              For p = 0,63 Do begin
                                        Temp_String = ''
                                        For j= 0,1023 Do begin
                                                Temp_String = Temp_String+' '+ Strn(Anode_Histogram[p,j])
                                        EndFor
                                                                         Printf, Lun, Strn(p)+ Temp_String
                              EndFor
                       Free_Lun, Lun
              
             
End

