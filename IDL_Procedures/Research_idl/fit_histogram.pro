Pro Fit_Histogram, Src_File, Back_File, Bin=Bin, Scale=Scale
; Grab in One/Two text files of Histogram and Do a subtraction and finally the Fitting to IT. 
; Option to Rebin
; The files to grab are text files.  
; Scale: Scale multiple plots individually for a time without subtraction.
; The length of the histogram, whether its anything should be included in the Text file's First 10 Lines if not 
; Array created for the length of the file. 


; The Comment section, THe last line should write Comments_End

True = 1
False= 0

    ;=== Various Flags ==
    Back_Flag = False 
    If Keyword_Set(Scale) EQ 0 Then Scale_Flag = False Else Scale_Flag = True ;Scale_Flag
    If Keyword_Set(BIN) EQ 0 Then Bin_Flag = False Else Bin_Flag = True ;Scale_Flag
                
    ;== Parameters and File Arrangements ==
    If n_params()EQ 1 Then BEgin
        
        N_Files = 1 
        Files = StrArr(N_Files)
        Time_Ran = LonArr(N_Files)
        Avg_Lt   = FLTARR(N_Files)
        Files[0] = Src_File

        EndIF Else IF N_Params() EQ 2 THen Begin
        
        N_Files =2
        Back_Flag = True
        Files = StrArr(N_Files)
        Time_Ran = LonArr(N_Files)
        Avg_Lt   = FLTARR(N_Files)
        
        Files[0] = Src_File
        Files[1] = Back_File
    EndIf Else Return
    
    ; === Files Stored in array
   
        For p = 0, N_Files-1 Do Begin
              Lines_Counter = 0L 
              Rows_File = File_LInes(Files[p])
              Print, ROws_File
              Openr, Lun, Files[p], /Get_Lun
                  Data =''
                  
                  Skip_Flag = True
                  ; We need to skip various lines if the Back_Flag or Scale_Flag is False
                  While Not EOF(Lun) DO Begin
                      
                      Readf, Lun, Data 
                      Lines_Counter++
                      
                      If (Back_Flag EQ True) or (Scale_Flag EQ True) Then Begin
                            
                            Pos = StrPos(Data,' ',2)
                            Temp_Str = StrMid(Data,0,Pos)
                            Pos1 = StrPos(Data,'=',0)
                            
                            If Temp_Str EQ 'Time_Ran' Then Begin
                                     Temp_Str1= StrMid(Data,Pos1+1,StrLen(Data)-Pos1-1)
                                     Time_Ran[p]= Long(Temp_Str1)   
                            EndIf
                            
                            If Temp_Str EQ 'Avg_Live_Time' Then Begin
                                     Temp_Str1= StrMid(Data,Pos1+1,StrLen(Data)-Pos1-1)
                                     Avg_Lt[p]= Float(Temp_Str1)   
                            EndIf
                     EndIF  
                     
                     If Data EQ 'Comments_End' Then Begin 
                             Skip_Flag = False
                             Readf, Lun, Data
                             Lines_Counter++
                     EndIf 
                     If Skip_Flag EQ True THen Goto, Skip_Line
                     
                     If p EQ 0 then Begin
                           Src_Hist = FltArr(Rows_File[p]-Lines_Counter)
                           For i =0,N_Elements(Src_Hist)-1 Do BEgin
                                    Readf, Lun, Data
                                    Src_Hist[i]= Float(Data)
                           EndFor
                     EndIF else If p Eq 1 Then Begin
                           Back_Hist = FltArr(Rows_File[p]-Lines_Counter)
                           For i = 0, N_Elements(Back_Hist)-1 Do Begin
                                    Readf, Lun, Data
                                    Back_Hist[i] = Float(Data)
                           EndFor 
                    EndIf
                     Skip_Line:
                  EnDWhile
              Free_Lun, LUn
        EndFor
        ;===== Currently have the Background and the Source Data.
        
        If (Back_Flag Eq TRUE) and ( N_Elements(Src_Hist) NE N_Elements(Back_Hist) ) Then Begin
                  PRINT, ' '
                  Print, 'INVALID: ERROR 101: THE SOURCE ARRAY NOT EQUAL TO BACKGROUND ARRAY'
        EndIf
        
        ;== REBINNING ==  Label 1
        If Bin_Flag EQ True Then Begin
              Array_Size = N_Elements(Src_Hist)
              NBins = Array_Size/Bin
              Src_Hist1 = DBLARR(NBins)
              Back_Hist1 = DBLARR(NBins)
              
              S_Counter=0L
              B_Counter=0L
              
              For i = 0, NBins-1 Do Begin
                    Temp_Val1 = 0.0
                    Temp_Val2 = 0.0
                    
                    For j = 0, Bin-1 Do Begin
                              Temp_Val1 = Temp_Val1 + Src_Hist[S_Counter]
                              S_Counter++
                              If Back_Flag EQ True Then Begin
                                      Temp_Val2 = Temp_Val2 + Back_Hist[B_Counter]
                                      B_Counter++
                              EndIf
                    EndFor
                    Src_Hist1[i] = Temp_Val1
                    Back_Hist1[i]= Temp_Val2
                    
              EndFor
        EndIf Else Begin
              Src_Hist1 = Src_Hist
              If Back_Flag EQ TRue Then Back_Hist1= Back_Hist
        EndElse
        
        ;=== SCALING/ Background Subtraction. ==  Label 2
        If Scale_Flag Eq True Then Begin
                Scale_Factor = Scale * 255.0 /(Avg_Lt[0] * Time_Ran[0])
                Src_Hist2 = Src_Hist1 * Scale_Factor
        EndIf Else Begin
                ; Subtract the Background if Back_Flag Present.
                If Back_Flag EQ True Then Begin
                     Src_Scl = Avg_Lt[0]*Time_Ran[0]/255.0
                     Back_Scl= Avg_Lt[1]*Time_Ran[1]/255.0
                
                     Back_Hist2 = Back_Hist1 * (Src_Scl/Back_Scl)
                     Src_Hist2 = Src_Hist1 - Back_Hist2   
                
                EndIf Else Src_Hist2 = Src_Hist1
        EndElse

        ; ===== Now the Fitting Functions. ==== 
        Help, Back_Hist 
                Help, Src_Hist
                Help, Src_Hist1
   ;     Print, Back_Hist1
        Print, AVg_LT, Time_Ran
        
End