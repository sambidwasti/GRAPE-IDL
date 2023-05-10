Pro Cal_Histogram1, Input_File, Flag_anodes, Scale=Scale, Time=Time
      ; The data is in flight mode
      ; # for PC events and
      ; C for C, CC events
      ; PLottimg the energy histogram.
      True =1
      False=0
      
      
      Scale_Length = 60
      If Keyword_Set(Scale) EQ 0 Then Scale_Flag = False Else Begin
                    Scale_Flag = True 
                    If Keyword_Set(Time) EQ 0 Then BEgin
                          Print, 'INPUT : TIME'
                          Return
                    Endif
      EndElse
      
      ;--- Output Folder and file name selection ---
      T_num = 0 ; Temporary Number Variable
      For k = 0, StrLen(Input_File)-5 Do Begin ; For Multiple / included with different folders.
          T_num = StrPos(Input_File, '/',k)
          If T_num NE -1 Then Pos = T_num
      EndFor; k
      
      Output_Folder= StrMid(Input_File,0,Pos+1)
      File_Name = StrMid(Input_File,Pos+1,Strlen(Input_File)-Pos-1)   ; For creation of the Scat file.
      Print, File_Name
      Print, Output_Folder
      
      Module = StrMid(File_Name,2,3)

      ;====== Energy Information ======
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
      
      Max_Anode_Number = 2
      
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
              IF (AnodeType(Anode1+1) EQ 0) And Energy1 LE 25 THen GOTO, JUmp_Line
              IF (AnodeType(Anode1+1) EQ 1) And Energy1 LE 10 THen GOTO, JUmp_Line
              
              IF (AnodeType(Anode1+1) EQ 0) And Energy1 GE 400 THen GOTO, JUmp_Line
              IF (AnodeType(Anode1+1) EQ 1) And Energy1 GE 150 THen GOTO, JUmp_Line
              
              If N_Anodes GT 1 Then BEgin
                  Pos1 = StrPos(Data,' ', Pos2+1)
                  If (Pos1- Pos2) NE 6 then Goto, Jump_Line     ; Checking for incorrect data format
                  Temp_Str = StrMid(Data, Pos2, Pos1-Pos2)
                  Anode2 = Fix(Strmid(Data,Pos2+1, 2))-1
                  Pulse2 = Fix(Strmid(Data,Pos2+3, 3))
                  Energy2= Energy_Array[Anode2,0]*Pulse2 + Energy_Array[Anode2,1]
                  Tot_Energy=Tot_ENergy+Energy2
                  
                  IF (AnodeType(Anode2+1) EQ 0) And Energy2 LE 25 THen GOTO, JUmp_Line
                  IF (AnodeType(Anode2+1) EQ 1) And Energy2 LE 10 THen GOTO, JUmp_Line
                  
                  IF (AnodeType(Anode2+1) EQ 0) And Energy2 GE 400 THen GOTO, JUmp_Line
                  IF (AnodeType(Anode2+1) EQ 1) And Energy2 GE 150 THen GOTO, JUmp_Line
                  
                  If (EventType(Anode1+1,Anode2+1)) NE 1 Then Goto, Jump_Line
                  
              EndIF
             
             ;== Energy Cuts ==
             ;==
             
              For p =0,N_Elements(Flag_Anodes)-1 Do BEgin
                          If N_Anodes GT 1 Then If ANode1 Eq Flag_Anodes[p] and Anode2 Eq Flag_Anodes[p] THen Goto, Jump_Line Else $
                              If ANode1 Eq Flag_Anodes[p] Then Goto, Jump_Line
              EndFor
              
              If Tot_Energy GT 1999 Then Goto, Jump_Line
              
              If (S_Value EQ '# ') and N_Anodes EQ 2 Then Begin 
                   PC_Array(Tot_Energy)++ 
              EndIf else begin 
                          
                          If (S_Value EQ 'C ') Then BEgin
                                If N_Anodes EQ 2 Then CC_Array(Tot_Energy)++ Else C_Array(Tot_Energy)++
                          
                          EndIF
              EndElse

              
              Jump_Line:
              EndWhile
      Free_Lun, Lun
; Average Live Time.             
      AVGLiveTime = Tot_LiveTime/LiveTime_Cntr
      Scl_Factor = 60*AvGLiveTime/(255.0*Time)
 
            PCArray = PC_Array*SCL_Factor
            CCArray = CC_ARray*SCL_Factor
            CArray  = C_Array*SCl_Factor
            
      ;== REBINNING ==
      PC_Array1 = FLTARR(400)
      CC_Array1 = FLTARR(400)
      C_Array1  = FLTARR(400)
      
      Counter= 0L
      For i = 0,399 Do Begin
            Temp_Val = 0L
            Temp_Val1= 0L
            Temp_Val2= 0L
            
            For k = 0,4 Do Begin
                      Temp_Val = Temp_Val+PCArray[Counter]
                      Temp_Val1= Temp_Val1+CCArray[Counter]
                      Temp_Val2= Temp_Val2+CArray[Counter]
                      Counter++
            Endfor
            PC_Array1[i] = Temp_Val
            CC_Array1[i] = Temp_Val1
            C_Array1[i] =  Temp_Val2
       EndFor
       
      
       X_Min=0
       X_Max=800
      
       Bin_Scale=5
       XFit = Float(INDGEN(400)*BIN_Scale)
       
       ; Using Cursor to Find the Minimum channel of Data selected
       C_Slope = Float( (X_Max-X_Min)/Float(882))
       C_Range = Float((C_Slope*60)-X_Min)
       
        ;============ CC =========================

          Plot, INDGEN(400)*5,CC_Array1,Title='FM'+Module+'CC EVENTS', $
                                       XTitle='ENERGY (KEV)', YTitle='Counts',PSYM=10$
                                      ,Xrange=[X_Min,X_MAx],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0 $
                                      ,XTickInterval=50, XMinor=5
                                      

          Cursor, X_Value0, Y_Value0, /DOWN, /DEVICE
          min_Chan_Val = Float(X_Value0*C_Slope-c_Range)
          min_Chan= FIX(min_Chan_Val/(Bin_Scale))
          PolyFill, [X_Value0,X_Value0,X_Value0+1, X_Value0+1],[Y_Value0-1000,Y_Value0+1000,Y_Value0+1000, Y_Value0-1000], Color=CgColor('Yellow'),/Device
          Print, ' Min Channel = ' + Strn(min_Chan_Val)
          
          ; Using Cursor to Find the Maximum channel of Data selected
          Print, ' Click For Maximum '
          Cursor, X_Value1, Y_Value1,  /DOWN, /DEVICE
          max_Chan_Val= Float(X_Value1*C_Slope-c_Range)
          Max_Chan=     Fix(max_Chan_Val/BIN_Scale)
          PolyFill, [X_Value1,X_Value1,X_Value1+1, X_Value1+1],[Y_Value1-1000,Y_Value1+1000,Y_Value1+1000, Y_Value1-1000], Color=CgColor('Yellow'),/Device
          Print, ' Max Channel =' + Strn(max_Chan_Val)
            
          ; Using Cursor to Get the Initial starting position for the Peak position.
          Print, ' Click For Starting PEAK position '
          Cursor, X_Value2, Y_Value2, /Down, /DEVICE
          Peak_Chan_Val = Float(X_Value2*C_Slope-c_Range)
          Peak_Chan = FIX(Peak_Chan_Val/BIN_Scale) 
          PolyFill, [X_Value2-2,X_Value2-1,X_Value2+1, X_Value2+1],[Y_Value2-5,Y_Value2+5,Y_Value2+5, Y_Value2-5], Color=CgColor('Orange'),/Device
          Print, ' Peak Channel =' + STrn(PEak_Chan_Val)
      
          
          Hist1     = CC_Array1(min_Chan:Max_Chan)
          Xfit1     = Xfit(min_Chan:Max_Chan)
          Hist1_Err = SQRT(ABS(CC_ARRAY1))
                                                P0 = 0
                                                P1 = Peak_Chan_Val
                                                P2 = 15
                                                P3 = CC_Array1[peak_Chan]*5
                                                
                                                Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
                                                
                                                Par[1].limited(0) = 1
                                                Par[1].limits(0)  = Peak_Chan_Val-40
                                                Par[1].limited(1) = 1
                                                Par[1].limits(1)  = Peak_Chan_Val+40
                                                
                                                Par[2].limited(0) = 1
                                                Par[2].limits(0)  = 1.0
                                  
                                                Par[3].limited(0) = 1
                                                Par[3].limits(0)  = 1.0
                                                
                                                
                                                Par[*].Value = [P0,P1,P2,P3]
                                                
                                                Expr = 'Gauss1(X,P[1:3])'
                                                
                                                Fit = mpfitexpr(expr, Xfit1, Hist1, Hist1_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=(1/Hist1))
                                                
                                                G_Fit = Gauss1(Xfit1, Fit[1:3])
                                                                                                
                                                Fitted =G_Fit
                                                Continium_Fit = 0*Xfit1
                                                
                                                FWHM = 2 * Sqrt(2*Alog(2))* Fit[2]
                                                XYOUTS,300,470, 'FWHM ='+Strn(FWHM), /DEVICE
                                                XYOUTS,300,480, 'Centroid =' +Strn(Fit[1]), /DEvice
                                                
                                                oplot, Xfit1, fitted, Color=CgColor('RED'), Thick = 2
                                                
                                                DOF      = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
                                                PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
                                                 Cursor, X_Value9, Y_Value9, /Down, /DEVICE
                                                ;==== Creating a String of Fitted Parameters and Errors ===
                                                Temp_Str0= 'Centroid =' +Strn(Fit[1])
                                                Set_Plot, 'PS'
                                                loadct, 13                           ; load color
                                                Device, File = Output_Folder+'FM'+Module+'_CC.ps', /COLOR,/Portrait
                                                Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                                               
                                                                 Plot, XFit,CC_Array1,Title='FM'+Module+'CC EVENTS', $
                                                                           XTitle='ENERGY (KEV)', YTitle='Counts',PSYM=10$
                                                                          ,Xrange=[X_Min,X_MAx],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0 $
                                                                          ,XTickInterval=50, XMinor=5
                                                                          
                                                                 Oplot, Xfit1, Fitted, Color=CgColor('Red') 
                                                                 XYOUTS,!D.X_Size*0.75,!D.Y_Size*0.8, Temp_Str0, CharSize=1.5,/Device
                                                Device,/Close
                                                Set_Plot, 'X'
                                                
       ;============ CC ===============
       
       ;===========  PC ===============
          X_Max=400
          C_Slope = Float( (X_Max-X_Min)/Float(882))
          C_Range = Float((C_Slope*60)-X_Min)
          Plot, Xfit,PC_Array1,Title='FM'+Module+'PC EVENTS', $
                                       XTitle='ENERGY (KEV)', YTitle='Counts',PSYM=10$
                                      ,Xrange=[X_Min,X_MAx],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0 $
                                      ,XTickInterval=50, XMinor=5
                                      

          Cursor, X_Value0, Y_Value0, /DOWN, /DEVICE
          min_Chan_Val = Float(X_Value0*C_Slope-c_Range)
          min_Chan= FIX(min_Chan_Val/(Bin_Scale))
          PolyFill, [X_Value0,X_Value0,X_Value0+1, X_Value0+1],[Y_Value0-1000,Y_Value0+1000,Y_Value0+1000, Y_Value0-1000], Color=CgColor('Yellow'),/Device
          Print, ' Min Channel = ' + Strn(min_Chan_Val)
          
          ; Using Cursor to Find the Maximum channel of Data selected
          Print, ' Click For Maximum '
          Cursor, X_Value1, Y_Value1,  /DOWN, /DEVICE
          max_Chan_Val= Float(X_Value1*C_Slope-c_Range)
          Max_Chan=     Fix(max_Chan_Val/BIN_Scale)
          PolyFill, [X_Value1,X_Value1,X_Value1+1, X_Value1+1],[Y_Value1-1000,Y_Value1+1000,Y_Value1+1000, Y_Value1-1000], Color=CgColor('Yellow'),/Device
          Print, ' Max Channel =' + Strn(max_Chan_Val)
            
          ; Using Cursor to Get the Initial starting position for the Peak position.
          Print, ' Click For Starting PEAK position '
          Cursor, X_Value2, Y_Value2, /Down, /DEVICE
          Peak_Chan_Val = Float(X_Value2*C_Slope-c_Range)
          Peak_Chan = FIX(Peak_Chan_Val/BIN_Scale) 
          PolyFill, [X_Value2-2,X_Value2-1,X_Value2+1, X_Value2+1],[Y_Value2-5,Y_Value2+5,Y_Value2+5, Y_Value2-5], Color=CgColor('Orange'),/Device
          Print, ' Peak Channel =' + STrn(PEak_Chan_Val)
      
          
          Hist1     = PC_Array1(min_Chan:Max_Chan)
          Xfit1     = Xfit(min_Chan:Max_Chan)
          Hist1_Err = SQRT(ABS(PC_ARRAY1))
                                                P0 = 0
                                                P1 = Peak_Chan_Val
                                                P2 = 15
                                                P3 = PC_Array1[peak_Chan]*5
                                                
                                                Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
                                                
                                                Par[1].limited(0) = 1
                                                Par[1].limits(0)  = Peak_Chan_Val-40
                                                Par[1].limited(1) = 1
                                                Par[1].limits(1)  = Peak_Chan_Val+40
                                                
                                                Par[2].limited(0) = 1
                                                Par[2].limits(0)  = 1.0
                                  
                                                Par[3].limited(0) = 1
                                                Par[3].limits(0)  = 1.0
                                                
                                                
                                                Par[*].Value = [P0,P1,P2,P3]
                                                
                                                Expr = 'Gauss1(X,P[1:3])'
                                                
                                                Fit = mpfitexpr(expr, Xfit1, Hist1, Hist1_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=(1/Hist1))
                                                
                                                G_Fit = Gauss1(Xfit1, Fit[1:3])
                                                                                                
                                                Fitted =G_Fit
                                                Continium_Fit = 0*Xfit1
                                                
                                                FWHM = 2 * Sqrt(2*Alog(2))* Fit[2]
                                                XYOUTS,300,470, 'FWHM ='+Strn(FWHM), /DEVICE
                                                XYOUTS,300,480, 'Centroid =' +Strn(Fit[1]), /DEvice
                                                
                                                oplot, Xfit1, fitted, Color=CgColor('RED'), Thick = 2
                                                
                                                DOF      = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
                                                PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
                                                Cursor, X_Value9, Y_Value9, /Down, /DEVICE
                                                ;==== Creating a String of Fitted Parameters and Errors ===
                                                Temp_Str0= 'Centroid =' +Strn(Fit[1])
                                                Set_Plot, 'PS'
                                                loadct, 13                           ; load color
                                                Device, File = Output_Folder+'FM'+Module+'_PC.ps', /COLOR,/Portrait
                                                Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                                               
                                                                 Plot, XFit,PC_Array1,Title='FM'+Module+'PC EVENTS', $
                                                                           XTitle='ENERGY (KEV)', YTitle='Counts',PSYM=10$
                                                                          ,Xrange=[X_Min,X_MAx],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0 $
                                                                          ,XTickInterval=50, XMinor=5
                                                                          
                                                                 Oplot, Xfit1, Fitted, Color=CgColor('Red') 
                                                                 XYOUTS,!D.X_Size*0.75,!D.Y_Size*0.85, Temp_Str0, CharSize=1.5,/Device
                                                Device,/Close
                                                Set_Plot, 'X'
   ;=====
   
   
   ;===========  C ===============
          X_Max=450
          C_Slope = Float( (X_Max-X_Min)/Float(882))
          C_Range = Float((C_Slope*60)-X_Min)
          Plot, Xfit,C_Array1,Title='FM'+Module+'C EVENTS', $
                                       XTitle='ENERGY (KEV)', YTitle='Counts',PSYM=10$
                                      ,Xrange=[X_Min,X_MAx],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0 $
                                      ,XTickInterval=50, XMinor=5
                                      

          Cursor, X_Value0, Y_Value0, /DOWN, /DEVICE
          min_Chan_Val = Float(X_Value0*C_Slope-c_Range)
          min_Chan= FIX(min_Chan_Val/(Bin_Scale))
          PolyFill, [X_Value0,X_Value0,X_Value0+1, X_Value0+1],[Y_Value0-1000,Y_Value0+1000,Y_Value0+1000, Y_Value0-1000], Color=CgColor('Yellow'),/Device
          Print, ' Min Channel = ' + Strn(min_Chan_Val)
          
          ; Using Cursor to Find the Maximum channel of Data selected
          Print, ' Click For Maximum '
          Cursor, X_Value1, Y_Value1,  /DOWN, /DEVICE
          max_Chan_Val= Float(X_Value1*C_Slope-c_Range)
          Max_Chan=     Fix(max_Chan_Val/BIN_Scale)
          PolyFill, [X_Value1,X_Value1,X_Value1+1, X_Value1+1],[Y_Value1-1000,Y_Value1+1000,Y_Value1+1000, Y_Value1-1000], Color=CgColor('Yellow'),/Device
          Print, ' Max Channel =' + Strn(max_Chan_Val)
            
          ; Using Cursor to Get the Initial starting position for the Peak position.
          Print, ' Click For Starting PEAK position '
          Cursor, X_Value2, Y_Value2, /Down, /DEVICE
          Peak_Chan_Val = Float(X_Value2*C_Slope-c_Range)
          Peak_Chan = FIX(Peak_Chan_Val/BIN_Scale) 
          PolyFill, [X_Value2-2,X_Value2-1,X_Value2+1, X_Value2+1],[Y_Value2-5,Y_Value2+5,Y_Value2+5, Y_Value2-5], Color=CgColor('Orange'),/Device
          Print, ' Peak Channel =' + STrn(PEak_Chan_Val)
      
          
          Hist1     = C_Array1(min_Chan:Max_Chan)
          Xfit1     = Xfit(min_Chan:Max_Chan)
          Hist1_Err = SQRT(ABS(C_ARRAY1))
                                                P0 = 0
                                                P1 = Peak_Chan_Val
                                                P2 = 15
                                                P3 = C_Array1[peak_Chan]*5
                                                
                                                Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
                                                
                                                Par[1].limited(0) = 1
                                                Par[1].limits(0)  = Peak_Chan_Val-40
                                                Par[1].limited(1) = 1
                                                Par[1].limits(1)  = Peak_Chan_Val+40
                                                
                                                Par[2].limited(0) = 1
                                                Par[2].limits(0)  = 1.0
                                  
                                                Par[3].limited(0) = 1
                                                Par[3].limits(0)  = 1.0
                                                
                                                
                                                Par[*].Value = [P0,P1,P2,P3]
                                                
                                                Expr = 'Gauss1(X,P[1:3])'
                                                
                                                Fit = mpfitexpr(expr, Xfit1, Hist1, Hist1_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=(1/Hist1))
                                                
                                                G_Fit = Gauss1(Xfit1, Fit[1:3])
                                                                                                
                                                Fitted =G_Fit
                                                Continium_Fit = 0*Xfit1
                                                
                                                FWHM = 2 * Sqrt(2*Alog(2))* Fit[2]
                                                XYOUTS,300,470, 'FWHM ='+Strn(FWHM), /DEVICE
                                                XYOUTS,300,480, 'Centroid =' +Strn(Fit[1]), /DEvice
                                                
                                                oplot, Xfit1, fitted, Color=CgColor('RED'), Thick = 2
                                                
                                                DOF      = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
                                                PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
                                                ;==== Creating a String of Fitted Parameters and Errors ===
                                                Temp_Str0= 'Centroid =' +Strn(Fit[1])
                                                Set_Plot, 'PS'
                                                loadct, 13                           ; load color
                                                Device, File = Output_Folder+'FM'+Module+'_C.ps', /COLOR,/Portrait
                                                Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                                               
                                                                 Plot, XFit,C_Array1,Title='FM'+Module+'C EVENTS', $
                                                                           XTitle='ENERGY (KEV)', YTitle='Counts',PSYM=10$
                                                                          ,Xrange=[X_Min,X_MAx],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0 $
                                                                          ,XTickInterval=50, XMinor=5
                                                                          
                                                                 Oplot, Xfit1, Fitted, Color=CgColor('Red') 
                                                                 XYOUTS,!D.X_Size*0.75,!D.Y_Size*0.85, Temp_Str0, CharSize=1.5,/Device
                                                Device,/Close
                                                Set_Plot, 'X'
   ;==========
       
   
      
      
End