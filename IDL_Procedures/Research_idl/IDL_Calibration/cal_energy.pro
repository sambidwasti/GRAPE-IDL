Pro Cal_Energy, InputFileFolderPath, Module, TYPE=Type, Anode=Anode
; *************************************************************************
; *           Doing an energy Callibration for a specific Module          *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read in the text file of Parameters from various sources    *
; *           and select the Centroid and respective energy to do an      *
; *           Linear Energy Calibration of Energy to Channel.             * 
; *                                                                       *
; * Usage:                                                                *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *     Inputs::                                                          *
; *           InputFileFolderPath: This is the file itself along with its *
; *           folder path.                                                *
; *                                                                       *
; *           Module: This gives us the Module to be selected.            *
; *                                                                       *
; *     Outputs::                                                         *
; *           A text file of Callibrated Energy with anode number and     *
; *           the standard M, Merror, C, Cerror for Y=Mx+C                *
; *                                                                       *
; * File Formats:   ASCII TEXT FILES                                      *
; *           The text file created by Cal_Plots.pro which has few lines  *
; *           to skip and after that                                      *
; *                                                                       *
; *             Format:                                                   *
; *             Anode Ener Parameter[0], parameter[0]error ...            *
; *             Note that at location 1 is the gaussian peak which we take*
; *             also note that we have energy so we can do a linear fit   *
; *             with these values.                                        *
; *                                                                       *
; * Author: 10/16/13  Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; *                                                                       *
; *                                                                       *
; * NOTE:                                                                 *
; *                                                                       *
; *************************************************************************
; *************************************************************************
 True = 1
 False = 0 
        
        InputFileFolderPath = Rmv_Bk_Slash(InputFileFolderPath)     ; Removes the Back Slash if there are any.
       
        If Keyword_Set(Anode) EQ 0 Then Single_Anode = False Else Single_Anode = True 
        
        Type_Text= 'ALL'
        If Keyword_Set(Type)  EQ 0 Then Type_Flag = False Else Begin
                        Type_Flag = True
                        If (Type NE 2) and (Type NE 1) Then BEgin
                                  Print, ' TYPE ERROR: Enter 2 for Plastics and 1 for Calorimeters.
                                  Return
                        EndIf
                        If Type Eq 2 then Type_Text ='Plastics' Else Type_Text ='Calorimeters'
                        If Type Eq 2 then Type =0
        EndElse
        
        Search_cal     = 'FM*'+Strn(Module)+'*_cal_KEV.txt'
        Search_pla     = 'FM*'+Strn(Module)+'*_pla_KEV.txt'
        InputFileFolderPath = InputFileFolderPath+'/'
        
        ;== Files ==
        FileNames_cal = File_Search( InputFileFolderPath, Search_cal)
        FileNames_pla = File_Search( InputFileFolderPath, Search_pla)
 
        If( N_elements(FileNames_cal) Eq 0) and (N_elements(FileNames_pla) EQ 0) Then Begin
                       Print, 'ERROR: NO FILE EXISTS WITH FM'+Module+'*KEV.txt '
                       Return
        EndIf
        N_Files_cal = N_elements(FileNames_cal)
        N_Files_pla = N_elements(FileNames_pla)
      
        
        ; Gotta need a 2Darray with the rows for anode no. and every 3 columns for Centroid, Error and Energy.
        Main_Array_cal = FltArr(64,(3*N_Files_cal))
      
        Arr_Loc = LonArr(64)
        Arr_Loc[*]=-1
        F_Ener = 0D
        If Type_Flag EQ True and Type Eq 0 Then Goto, Jump_Cal
        Type_String = 'cal'
                  ;===READ IN THE Cal FILES==
                  For q = 0, N_Files_cal-1 Do Begin 
                            Fname= FileNames_cal[q]
                            Print, Fname, q
                            Openr, Lun, Fname, /Get_Lun
                            data=''
                            
                            ReadF, Lun, data   ; Reading Line   Headline
                            ReadF, Lun, data   ; Reading Line   Raw data File name
                            ReadF, Lun, data   ; Reading Line   Module
                            ReadF, Lun, data   ; Reading Line   Source
                            ReadF, Lun, data   ; Reading Line   Avg Live Time
                            ReadF, Lun, data   ; Reading Line   Time Ran
          
                            ReadF, Lun, data   ; Fitting function numbering
                            ReadF, Lun, data   ; Fitting Function 0
                            ReadF, Lun, data   ; Fitting Function 1
                            ReadF, Lun, data   ; Fitting Function 2
                            ReadF, Lun, data   ; Fitting Function 3
                            ReadF, Lun, data   ; Fitting Function 4
                            
                            Readf, Lun, data   ; Empty Line right now.
                            
                            ReadF, Lun, data   ; Reading Line Column Label
                            ReadF, Lun, Data   ; Reading Line Just a ==== Boundary
                       
                            ; Now the actual File Begins.
                            While Not EOF(Lun) DO Begin
                                    ReadF, Lun, Data
                                
                                    if Data EQ '' Then Goto, Jump_line
                                    Pos1=0
                                    Pos3=3
                                    p = Fix(strmid(Data,0,2)); Anode no.
                                    
                                    Pos1 = StrPos(Data,' ',1)
                                    Pos3 = StrPos(Data, ' ', 4)
                                    
                                    Temp_Value = Float(StrMid(data,Pos1, Pos3-Pos1+1))  ; For the Fit Function.
                        
                                    Pos1 = StrPos(Data,' ',Pos3)
                                    Pos3 = StrPos(Data,' ',Pos1+3)
                                    Temp_Value = Float(StrMid(data,Pos1, Pos3-Pos1+1))  ; For the Energy Function.
          
                                    Arr_Loc[p]++
                                    s = Arr_Loc[p]
                                                ;                        Print, p
                                    Main_Array_cal[p,s] = Temp_Value

                                    For i = 0 , 4 Do BEgin
                                            Pos = StrPos(Data, '.', Pos3)
                                            Pos1= StrPos(Data, ' ', Pos)
                                            Temp_Value = Float(StrMid(data,Pos3+2, Pos1-Pos3-2))
                                            
                                             Pos3 = Pos1
                                            If (i EQ 2) Or (i EQ 3) Then Begin
                                                    ; Print, Data, Pos3+2, Pos1-Pos3-2
                                                   
                                                    Arr_Loc[p]++
                                                    s = Arr_Loc[p]
                                                    Main_Array_cal[p,s] = Temp_Value
                                                   
                                           EndIf
                                    EndFor
                  
                           Jump_Line:
                           EndWhile
                           
                           Free_Lun, Lun
                 EndFor ;q
                        Jump_Cal:
        Main_Array_pla = FltArr(64,(3*N_Files_pla))
        Arr_Loc[*]=-1
        F_Ener = 0D
 
        If Type_Flag EQ True and Type Eq 1 Then Goto, Jump_Pla
         Type_String = 'pla'
                  ;===READ IN THE Cal FILES==
                  For q = 0, N_Files_pla-1 Do Begin 
                            Fname= FileNames_pla[q]
                            Print, Fname
                            Openr, Lun, Fname, /Get_Lun
                            data=''
                            
                            ReadF, Lun, data   ; Reading Line   Headline
                            ReadF, Lun, data   ; Reading Line   Raw data File name
                            ReadF, Lun, data   ; Reading Line   Module
                            ReadF, Lun, data   ; Reading Line   Source
                            ReadF, Lun, data   ; Reading Line   Avg Live Time
                            ReadF, Lun, data   ; Reading Line   Time Ran
          
                            ReadF, Lun, data   ; Fitting function numbering
                            ReadF, Lun, data   ; Fitting Function 0
                            ReadF, Lun, data   ; Fitting Function 1
                            ReadF, Lun, data   ; Fitting Function 2
                            ReadF, Lun, data   ; Fitting Function 3
                            ReadF, Lun, data   ; Fitting Function 4
                            
                            Readf, Lun, data   ; Empty Line right now.
                            
                            ReadF, Lun, data   ; Reading Line Column Label
                            ReadF, Lun, Data   ; Reading Line Just a ==== Boundary
                            
                            ; Now the actual File Begins.
                            While Not EOF(Lun) DO Begin
                                    ReadF, Lun, Data
                                   
                                    Pos1=0
                                    Pos3=3
                                    p = Fix(strmid(Data,0,2)); Anode no.
                                    Pos1 = StrPos(Data,' ',1)
                                    Pos3 = StrPos(Data, ' ', 4)
                                    
                                    Temp_Value = Float(StrMid(data,Pos1, Pos3-Pos1+1))  ; For the Fit Function.
                        
                                    Pos1 = StrPos(Data,' ',Pos3)
                                    Pos3 = StrPos(Data,' ',Pos1+3)
                                    Temp_Value = Float(StrMid(data,Pos1, Pos3-Pos1+1))  ; For the Energy Function.
          
                                    Arr_Loc[p]++
                                    s = Arr_Loc[p]
                                    
                                    Main_Array_pla[p,s] = Temp_Value
                                    
                                    For i = 0 , 4 Do BEgin
                                            Pos = StrPos(Data, '.', Pos3)
                                            Pos1= StrPos(Data, ' ', Pos)
                                            Temp_Value = Float(StrMid(data,Pos3+2, Pos1-Pos3-2))
                                           
                                            
                                             Pos3 = Pos1
                                            If (i EQ 2) Or (i EQ 3) Then Begin
                                                    ; Print, Data, Pos3+2, Pos1-Pos3-2
                                                  
                                                    Arr_Loc[p]++
                                                    s = Arr_Loc[p]
                                                    Main_Array_pla[p,s] = Temp_Value
                                                   
                                           EndIf
                                    EndFor
                                                             
                        
                           EndWhile
                           
                           Free_Lun, Lun
                 EndFor ;q
    Jump_Pla:            
                 O_File = InputFileFolderPath+'FM'+Module+'Energy_'+Type_String+'.txt'
                 Openw, Lunger, O_file, /Get_Lun  
                 Printf, Lunger, 'LINEAR FITTED ENERGY CALIBRATION FILE'
                 Printf, Lunger, 'Module          : '+ Module
                 Printf, Lunger, 'Fitted for      : '+ Type_Text
                 Printf, Lunger, 'Linear Fit      : Energy = slope* Channel + Intercept'
                 printf, Lunger, 'line 5'
                 printf, Lunger, 'line 6'
                 printf, Lunger, 'line 7'
                 printf, Lunger, 'line 8'
                 printf, Lunger, 'line 9'
                 Printf, Lunger, 'Anode Slope  SlopeErr  Intercept InterceptErr  Chisquare(Non-Scaled)'
                 
                 
                 Free_Lun,Lunger
                 ;=Extract each anode values and do a linear Fit.
                 If Single_Anode EQ True Then Begin
                        p = Anode
                        Goto, Jump_Anode_Loop
                 EndIf
                ; Print, Main_Array_Cal[p,*]
                 
                 For p = 0,63 do Begin
                       Jump_Anode_Loop:     
                            IF (Type_Flag Eq True) Then If (AnodeType(p+1) EQ Type) then Goto, Jump_Loop
                            
                            If (AnodeType(p+1) EQ 0) then Begin
                                    Temp_Main_Array = Main_Array_cal[p,*]  
                                   
                                    N_Files = N_Files_Cal
                                    
                            EndIf Else Begin
                                    Temp_Main_Array = Main_Array_pla[p,*] ; Grabs the whole row
                                    N_Files = N_Files_Pla
                           EndElse
                            
                            
                            Temp_Y = FltArr(N_Files)
                            Temp_X = FltArr(N_Files)
                            Temp_Y_Err = FltArr(N_Files)
                            Temp_Count=0
                            
                            For i =0, N_Files-1 Do Begin
                                    Temp_X[i]      = Temp_Main_Array[Temp_Count]
                                    Temp_Count++
                                    Temp_Y[i]  = Temp_Main_Array[Temp_Count]
                                    Temp_Count++
                                    Temp_Y_Err[i]      = Temp_Main_Array[Temp_Count]
                                    Temp_Count++
                            EndFor
                            
                           X = Temp_X
                           Y = Temp_Y
                           Y_Err = Temp_Y_Err
                           
                       ;     window,0     
                            Print, X
                            Print, Y    
               
                            Plot, X, Y, PSYM=4 , XRange=[0,400], YRange=[-10,800], YStyle=1, XStyle=1,YTITLE='Channel',XTITLE='Energy',Title='Anode='+Strn(p),XTickInterval=25, YtickInterval=25
                            OplotErr, X,Y, Y_Err
                
                
                            m_Slope = Float( (Y[N_Files-1]-Y[0]) / (X[N_Files-1]-X[0]) )
                            A=[1.0,m_Slope]
                           
                            Linear_Fit = LinFit(X,Y, MEASURE_ERROR=Y_Err, SIGMA=Sigma, CHISQR= Chi, Yfit=Yfit)
                            Full_X = INDGEN(1000)
                            Full_Y = Full_X*Linear_Fit[1]+Linear_Fit[0]
                            oplot, Full_X, Full_Y, Color= CgColor('Red')
                            Print, 'Chisqr=',Chi
                            Output_Folder = InputFileFolderPath+'FM'+Module+'Energy_Calibration_'+Type_String   
                            If Dir_Exist(Output_Folder) EQ False Then File_MKdir, Output_Folder
                            Output_File = Output_Folder+'/'+'FM'+Module+'_Ener_Calibration_Anode_'+Strn(p)
                                               
     
                            
                            ; Values                  
                            K = Linear_Fit[0]
                            M = Linear_Fit[1]
                            M1 = Float(1/M)
                            K1 = Float(K/M) 
                            
                            ; Errors
                            Er_K = Sigma[0]
                            Er_M = Sigma[1]
                            If K NE 0.0 Then Er_K1= Float(K1*( Sqrt(  ((Er_k/K)*(Er_k/k)) + ((Er_m/m)*(Er_m/M))  )  ) ) Else Er_K1=0      
                            Er_M1= Float(Er_m/(m*m))          
                    
                            ; Since we want to add the intercept, we multiply by -1
                    
                            K1= K1*(-1)
                            If Er_K1 LT 0 Then Er_K1=Er_K1*(-1)
                
                                       Set_Plot, 'PS'
                                       loadct, 13                           ; load color
                                       Device, File = Output_File, /COLOR,/Portrait
                                       Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                                                  Temp_Str0= String(Format= '("Chan = " ,(F6.3,X),"(",(F5.3),") Ener +",(F7.3),"(",( F6.3),")")',M,Er_M, K, Er_K)
                                                  Temp_Str1= String(Format= '("Ener = " ,(F6.3,X),"(",(F5.3),") Chan +",(F7.3),"(",( F6.3),")")',M1,Er_M1, K1, Er_K1)
                                                  Plot, X, Y, PSYM=4 , XRange=[0,400], YRange=[0,800], YStyle=1,XStyle=1, YTITLE='Channel',XTITLE='Energy',Title='Anode='+Strn(p)$
                                                    ,XTickInterval=50, YtickInterval=50 , Charsize=2.0;, YCharSize=2.0 , XCharsize=2.0
                                                  OplotErr, X,Y, Y_Err
                                                  oplot, Full_X, Full_Y, Color= CgColor('Red')
                                                  XYOUTS,!D.X_Size*0.3,!D.Y_Size*0.9, Temp_Str0, CharSize=1.5,/Device 
                                                  XYOUTS,!D.X_Size*0.3,!D.Y_Size*0.88, Temp_Str1, CharSize=1.5,/Device 
                                                  XYOUTS,!D.X_Size*0.2,!D.Y_Size*0.97, 'FM'+Module, CHarSize=2.5, /Device
                                                  XYOUTS,!D.X_Size*0.6,!D.Y_Size*0.86, 'Chisqr ='+Strn(Chi), CharSize=1.5,/Device 
                                       Device,/Close
                                       Set_Plot, 'X'
                                         CGPS2PDF, OutPut_File,delete_ps=1
                            Print, M, Er_M,K,Er_K, Chi 
                            Print, M1, Er_M1, K1, ER_K1
                
                            Cursor, X_t, Y_t,/Device,/Down
                            Openw, Lunger, O_file, /Get_Lun ,/Append
                                        Printf, Lunger, Strn(P)+'     '+ Strn(M1)+'   '+ Strn(Er_M1)+'  ' +Strn(K1)+'    '+Strn(Er_K1) + '   '+Strn(Chi)
                            Free_Lun, Lunger
                            
                       Jump_Loop:   
                       If Single_Anode EQ True Then Goto, Jump1 ; Just skip the end for here.
                       EndFor ;/p
                       Jump1:
End