Pro Pol_Scat, Input_Folder, Bin=Bin, NoEner=NoEner, EBIN=EBIN, OPT=OPT
; Introduction of Optimization keyword which can rescale the non-proper scaled graphs.
; Need to transfer errors..
True = 1
False= 0
    Bin_Flag = False
    
    EBin_Flag= False
    If Keyword_Set(EBin) NE 0 Then EBin_Flag = True Else EBin=1
    If Keyword_Set(Bin) NE 0 Then Bin_Flag = True Else Bin=1
    If Keyword_Set(Opt) Then Opt_Flag = True Else Opt_Flag = False

    Half_BinSize = Double(BIN/2)
    
    If Keyword_Set(NoEner) NE 0 Then Energy_Flag = False Else Energy_Flag = True
    
    List_of_Files = File_Search(Input_Folder+'/*_Scat*.txt')
    N_Files = N_Elements(List_of_Files)
    
    ;---- Check the valid number of Scat files in the folder.
    If ((N_Files GT 2) or (N_Files LT 1)) Then Begin
            Print, 'INVALID: Number of *Scat are more than 2 or None at all'
            Return
    EndIF
    
    ;--- Output Folder and file name selection ---
    T_num = 0 ; Temporary Number Variable
    For k = 0, StrLen(Input_Folder)-5 Do Begin ; For Multiple / included with different folders.
            T_num = StrPos(Input_Folder, '/',k)
            If T_num NE -1 Then Pos = T_num
    EndFor; k  
    Plot_File_Name = StrMid(Input_Folder,Pos+1,Strlen(Input_Folder)-Pos-1)
    Pos = Strpos(Plot_File_Name,'_',0)
    Module = StrMid(Plot_File_Name,0,Pos)
    Pos1 = Strpos(Plot_File_Name,'_',Pos+1)
    Source = Strmid(Plot_File_Name,Pos+1, Pos1-Pos-1)
   
    Avg_LT = FltArr(2)
    Time_Ran = FltArr(2)
    
    Back_Index =-1
    ;============= Now Read in the Files ===============
    For p = 0, N_Files-1 Do Begin
            ;----- Grab the Back-Ground Index ------
            If StrPos(List_of_Files[p],'Back',0) GT 0 Then Back_Index=p
            
            Temp_Scat_Hist = FltArr(360)
            ;----- Read In the Files----
            Openr, Lun,List_of_Files[p], /Get_Lun
                  Data =''
                 
                  Readf, Lun, Data      ; Headline
                  Readf, Lun, Data      ; File name
                  
                  Readf, Lun, Data ; Average LT.
                  Pos0 = StrPos(Data,'=',0)
                  Temp_Str = StrMid(Data,Pos0+1,Strlen(Data)-Pos0)
                  Avg_LT[p] = Float(Temp_Str)
                  
                  Readf, Lun, Data ; Time Ran
                  Pos0 = StrPos(Data,'=',0)
                  Temp_Str = StrMid(Data,Pos0+1,Strlen(Data)-Pos0)
                  Time_Ran[p] = Double(Temp_Str)*360
                  
                  Readf, Lun, Data ; Flagged Anode
                  Pos0 = StrPos(Data,'=',0)
                  Temp_Str = StrMid(Data,Pos0+1,Strlen(Data)-Pos0)
                  Flag_Anode =Fix(Temp_Str)
                  
                  Readf, Lun, Data ;Energy
                  Pos0 = StrPos(Data,'=',0)
                  Temp_Str = StrMid(Data,Pos0+1,Strlen(Data)-Pos0)
                  Energy = LONG(Temp_Str)

                  Readf, Lun, Data ;Energy Range
                  Pos0 = StrPos(Data,'=',0)
                  Temp_Str = StrMid(Data,Pos0+1,Strlen(Data)-Pos0)
                  Energy_Range = LONG(Temp_Str)
                  
                  Readf, Lun, Data ;Empty Line
                  Readf, Lun, Data ;Empty Line
                  Readf, Lun, Data ;Empty Line
                  
                  ; Now the Extraction of Angle information and data.
                  For i = 0, 359 Do Begin
                          Readf, Lun, Data
                          Pos0 = StrPos(Data,' ',0)
                          Temp_Str = StrMid(Data,0,Pos0)
                          Ang = Float(Temp_Str)
                          
                          Pos1 = StrPos(Data,' ',Pos0+1)
                          Temp_Str = StrMid(Data,Pos0,StrLen(Data)-Pos0)
                          Temp_Value= Double(Temp_Str)
                                                   
                          Temp_Scat_Hist[Ang]= Temp_Value
                  EndFor
                  If Energy_Flag EQ True Then Begin
                  
                          Readf, Lun, Data ; Empty
                          Readf, Lun, Data ; Empty\
                          Readf, Lun, Data ; Empty

                          ;------- Energy Information --------
                          Pos0=StrPos(Data,':',0)
                          Temp_Str = StrMid(Data,Pos0+1,StrLen(Data)-Pos0-1)
                          Print,Long(Temp_Str)
                          Temp_Energy_Hist = LonArr(Long(Temp_Str))
                          For i = 0, Long(Temp_Str)-1 Do Begin
                                  Readf, Lun, Data
                                  Temp_Energy_Hist[i]=Long(Data)
                          EndFor
                  EndIF
                  ;---- Get the Background and Source Data Respectively ----
                  Print, p, ' ',Back_Index,' ',List_of_Files[p]
                  If p Eq Back_Index Then Begin
                          Print, p
                              Back_Scat_Hist = Temp_Scat_Hist
                          If Energy_Flag Eq True Then    Back_Ener_Hist = Temp_Energy_Hist
                  EndIf Else Begin
                              Src_Scat_Hist = Temp_Scat_Hist
                          If Energy_Flag Eq True Then     Src_Ener_Hist = Temp_Energy_Hist
                              Src_Index = p
                  EndElse
                  
            Free_Lun, Lun
            
    EndFor ; p
    ;====== Files Read and stored the Histogram ========
    
    ;====== INTRODUCING ERRORS ===========
    Back_Error= Sqrt(Abs(Back_Scat_Hist))
    Src_Error = Sqrt(Abs(Src_Scat_Hist))
    If Energy_Flag Eq True Then Begin
          Back_ener_err= Sqrt(Abs(Back_Ener_Hist))
          Src_Ener_Err = Sqrt(Abs(Src_Ener_Hist))
    EndIf
    ; (dz)^2 = dx^2 + dy^2  for z=x+y
     
    
    ;====== Rebin Before Scaling and Substractions =======
    ;--- For Scattering
                    N_Bins = 360/Bin
                    Temp_Hist = FltArr(N_Bins)
                    Temp_Err_Hist = FltArr(N_Bins)
                    
                    Temp_Count =0L
                    
                    For i = 0,N_Bins-1 Do Begin
                          Temp_Val =0.0
                          Temp_Err_Val =0.0
                          For j=0, Bin-1 Do Begin
                                  Temp_Val = Src_Scat_Hist[Temp_Count]+Temp_Val
                                  Temp_Err_Val = ((Src_error[Temp_Count])*(Src_error[Temp_Count])) + Temp_Err_Val 
                                  Temp_Count++
                          EndFor;j
                          Temp_Hist[i]=Temp_Val
                          Temp_Err_Hist[i]= Sqrt(Temp_Err_Val)
                    EndFor ; i
                    Src_Scat_Hist1 = Temp_Hist
                    Src_Err_Hist1  = Temp_Err_Hist
                    
                    
                    Temp_Count = 0L
                    For i = 0,N_Bins-1 Do Begin
                          Temp_Val =0.0
                          Temp_Err_Val =0.0
                          
                          For j=0, Bin-1 Do Begin
                                  Temp_Val = Back_Scat_Hist[Temp_Count]+Temp_Val
                                  Temp_Err_Val = ((Back_error[Temp_Count])*(Back_error[Temp_Count])) + Temp_Err_Val 
                                  Temp_Count++
                          EndFor;j
                          Temp_Hist[i]=Temp_Val
                          Temp_Err_Hist[i]= Sqrt(Temp_Err_Val)
                    EndFor ; i
                    Back_Scat_Hist1 = Temp_Hist
                    Back_Err_Hist1  = Temp_Err_Hist
                    X_Val = INdgen(N_Bins)*Bin+Half_BinSize 

              
       ;---- For Energy
            If Energy_Flag EQ True Then Begin
                    N_EBins = N_Elements(Src_Ener_Hist)/EBin
                    Temp_Hist = FltArr(N_EBins)
                    Temp_Ener_Err_Hist = Fltarr(N_EBins)
                    Temp_Count =0L
                    
                    For i = 0,N_EBins-1 Do Begin
                          Temp_Val =0L
                          Temp_Err =0.0
                          For j=0, EBin-1 Do Begin
                                  Temp_Val = Src_Ener_Hist[Temp_Count]+Temp_Val
                                  Temp_Err = (Src_Ener_Err[Temp_Count]*Src_Ener_Err[Temp_Count])+Temp_Err
                                  Temp_Count++
                          EndFor;j
                          Temp_Hist[i]=Temp_Val
                          Temp_Ener_Err_Hist[i] = Temp_Err
                    EndFor ; i
                    Src_Ener_Hist1 = Temp_Hist
                    Src_Ener_Err_Hist1 = Sqrt(Temp_Ener_Err_Hist)
                    
                    Temp_Count = 0L
                    For i = 0,N_EBins-1 Do Begin
                          Temp_Val =0L
                          Temp_Err =0.0
                          For j=0, EBin-1 Do Begin
                                  Temp_Val = Back_Ener_Hist[Temp_Count]+Temp_Val
                                  Temp_Err = (Back_Ener_Err[Temp_Count]*Back_Ener_Err[Temp_Count])+Temp_Err
                                  Temp_Count++
                          EndFor;j
                          Temp_Hist[i]=Temp_Val
                          Temp_Ener_Err_Hist[i] = Temp_Err
                    EndFor ; i
                    Back_Ener_Hist1 = Temp_Hist
                    Back_Ener_Err_Hist1 = Sqrt(Temp_Ener_Err_Hist)
                    
                    X_Ener_Val = INdgen(N_EBins)*EBin
            EndIF
       ;=======================     
  
  
    ;====== Now Normalize/Rescale and Rebin the Histograms =====
    
    If Opt_Flag Eq True Then Begin
                ; The range of data to be selected to rescale:
                Opt_X_Value = (ENergy+Energy_Range)/Ebin
                Opt_X1_Value= 400/Ebin
                ;Opt_X1_Value = N_Elements(Src_Ener_Hist1) -1
    EndIF
    ; Scale Background to Source
    IF Back_Index NE -1 Then Begin
            Back_Scale= Double( Time_Ran[Back_Index]*Avg_Lt[Back_Index]/Double(255) )
            Src_Scale= Double( Time_Ran[Src_Index]*Avg_Lt[Src_Index]/Double(255) )
            Normalizing_Scale=(Src_Scale/Back_Scale)

            If Energy_Flag Eq True Then  Begin 
                  
                  If Opt_Flag Eq True Then Begin
                  
                            Value =0.0D
                            Value_Counter =0L

                            For k= Opt_X_Value, Opt_X1_Value Do Begin
                                    If Back_Ener_Hist1[k] NE 0.0 Then Temp_Value= Double(Double(Src_Ener_Hist1[k])/Double(Back_Ener_Hist1[k])) Else Temp_Value = Double(Src_Ener_Hist1[k])
                                    
                                    If Temp_Value NE 0.0 Then BEgin
                                          Print, k, Temp_Value, Src_Ener_Hist1[k], Back_Ener_Hist1[k]
                                          Value=Value+Temp_Value
                                          Value_Counter++
                                    EndIF 
                            EndFor

                            New_Scale = Double(Value/Value_Counter)
                            Normalizing_Scale = New_Scale
                            Print, NEw_Scale,'****'
                  EndIF
                  
                  Scaled_Back_Ener_Hist1 = Double( Back_Ener_Hist1* Normalizing_Scale )
                  Ener_Hist = Src_Ener_Hist1-Scaled_Back_Ener_Hist1
                  
                  
                  Scaled_Back_Ener_Err = Normalizing_Scale*Back_Ener_Err_Hist1
                  Src_Ener_Err_Hist = Sqrt( (Src_Ener_Err_Hist1*Src_Ener_Err_Hist1)+(Back_Ener_Err_Hist1*Back_Ener_Err_Hist1) )
            EndIf
            
            Scaled_Back_Scat_Hist = Double( Back_Scat_Hist1* Normalizing_Scale )
            Scat_Hist = Src_Scat_Hist1-Scaled_Back_Scat_Hist
            
            Scaled_back_Hist_Err = Back_Err_Hist1 * Normalizing_Scale
            Src_Scat_err_Hist = Sqrt( (Src_Err_Hist1*Src_Err_Hist1) +  (Scaled_back_Hist_Err* Scaled_back_Hist_Err) )

           
    EndIf Else Begin
            Scat_Hist = Src_Scat_Hist1
            If Energy_Flag Eq True Then  Ener_Hist = Src_Ener_Hist1
    EndElse
    
    print, Normalizing_Scale
    ;YMax = Max(Src_Scat_Hist1)*1.2
    YMax = Max(Scat_Hist)*1.2
    YMin = 0;Min(Scat_Hist)*0.78
    OUtput_File_Scat = Input_Folder+'/'+ Plot_File_Name+'_Scat.ps'
    OutPut_File_Ener = Input_Folder+'/'+ Plot_File_Name+'_Energy.ps'
    OutPut_File_Text = Input_Folder+'/'+ Plot_File_Name+'_ScaledScat.txt'
    ;============ FITTING FUNCTIOn =========
           ;=== Initial Guess ===
           A0 = MIN(Scat_Hist)
           A1 = Max(Scat_HIst)-MIn(Scat_HIst)
           A2 = 1
           
           ;=== Some constraints
           Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
           Par[1].limited(0) = 1
           Par[1].limits(0)  = Avg(Scat_Hist)-Min(Scat_Hist)
                                               
           Par[*].Value = [A0,A1,A2]
           
           ;=== Errors ===
           Scat_Error = Src_Scat_err_Hist
           
           ;=== Fitting Function ===
           expr = 'P[0] + P[1]*(cos(P[2]-X))^2'
           
           ;Plotting the data
           Plot, X_Val, Scat_Hist, PSYM=10,Title='Polarized Events',CharSize=2,$
                               XRange=[0,360], XStyle=1,XTickInterval=45, $
                               YRange=[YMin,YMax],/NODATA,$
                               XTitle='Angle', YTitle='Counts'
           
           Oplot, X_Val, Scat_Hist, PSYM=10
           OplotError, X_Val, Scat_Hist, Scat_Error, ErrStyle=4,ErrColor='green',/NOHAT  ; Error
           
           ;=== Changing the degree values to Radians for the fitting.
           X_Val1 = 2*!Pi*X_Val/360
           
           ;=== Fitting
           Fit = mpfitexpr(expr, X_Val1, Scat_Hist, Scat_Error, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/Scat_Error)
           ;=== Fitted Function
           
           X_Val2 = 2*!Pi*FINDGEN(360)/360
           Fitted_Funct = Fit[0] + Fit[1]*cos(Fit[2]-X_Val2)^2
           Text_Funct = STRN(Fit[0])+' +'+Strn(Fit[1])+'(Cos( '+Strn(Fit[2])+'-X ))^2
           ;=== Changing the x axis values to Degrees and plotting the fit
           Oplot, X_Val2*360/(2*!PI), Fitted_Funct, Color=CgColor('Red')   
;           Oplot, X_Val, Src_Scat_Hist1, PSYM=10, Color=CgColor('Green')
;           Oplot, X_Val, Scaled_Back_Scat_Hist, PSYM=10, Color=CgColor('Blue')
           ;-- Calculating the modulation factor -- (Max-Min)/(Max+Min)
           ; Max- Min is the Fit[1] value. 
           
           Modulation = Double(Double(Fit[1])/Double(2*Fit[0]+Fit[1]))
           Print, Modulation
    ;=========== Plotting =================
       Set_Plot, 'PS'
       loadct, 13                           ; load color
            Device, File = Output_File_Scat, /COLOR,/Portrait
            Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                         Plot, X_Val, Src_Scat_Hist1, PSYM=10,Title='Polarized Events',CharSize=2,$
                               XRange=[0,360], XStyle=1,XTickInterval=45, $
                               YRange=[0,Max(Src_Scat_Hist1)*1.2],/NODATA,$;YRange=[Ymin,YMax],$
                               XTitle='Angle', YTitle='Counts'
                         Oplot, X_Val, Scat_Hist, PSYM=10, Color=CgColor('Dark_Green')
                         oplotError, X_Val, Scat_Hist, Src_Scat_err_Hist, ErrStyle=0,PSYM=10,/NOHAT  ; Error
                         
                         Oplot, X_Val2*360/(2*!PI), Fitted_Funct, Color=CgColor('Red')   
                         ;Oplot, X_Val, Back_Scat_Hist1, PSYM=10, Color=CgColor('red')
                         Oplot, X_Val, Src_Scat_Hist1, PSYM=10, Color=CgColor('Blue')
                         Oplot, X_Val, Scaled_Back_Scat_Hist, PSYM=10,Color=CgColor('Green')

                         XYOUTS,!D.X_Size*0.2,!D.Y_Size*0.966, Module, CharSize=2.5,/Device
                         XYOUTS,!D.X_Size*0.8,!D.Y_Size*0.966, Source, CharSize=2.5,/Device
                         XYOUTS,!D.X_Size*0.7,!D.Y_Size*(0.03), 'Deg Per Bin='+STRN(BIN), CharSize=1.8,/Device
                         XYOUTS,!D.X_Size*0.7,!D.Y_Size*0.915, 'u ='+STRN(Modulation), CharSize=1.8,/Device
                         XYOUTS,!D.X_Size*0.6,!D.Y_Size*0.01, Text_Funct, CharSize=1.0,/Device
           Device,/Close
       Set_Plot, 'X'
       
       YMax1= Max(Src_Ener_Hist1)*1.2
;       Plot, Indgen(N_Elements(Ener_Hist)), Ener_Hist, PSYM=10, Title= 'Energy Histogram',CharSize=2,$
;                                       XTitle='KeV', YTitle='Counts', YRange=[0,YMax1], YStyle=1$
;                                       ,Xrange=[0,450],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0$
;                                       ,XTickInterval=50, XMinor=5
;                                   OPlot, Indgen(N_Elements(Ener_Hist)),Scaled_Back_Ener_Hist, PSYM=10, Color=CgColor('Red') 
;                                   OPlot, Indgen(N_Elements(Ener_Hist)),Src_Ener_Hist, PSYM=10, Color=CgColor('Blue')
;                                   
       If Energy_Flag Eq True Then Begin
                 
                 Set_Plot, 'PS'
                 loadct, 13                           ; load color
                      Device, File = Output_File_Ener, /COLOR,/Portrait
                      Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                                   Plot, X_Ener_Val, Src_Ener_Hist1, PSYM=10, Title= 'Energy Histogram',CharSize=2,$
                                       XTitle='KeV', YTitle='Counts', YRange=[-50,YMax1], YStyle=1$
                                       ,Xrange=[0,600],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0$
                                       ,XTickInterval=50, XMinor=5
                                   OPlot,X_Ener_Val,Scaled_Back_Ener_Hist1, PSYM=10, Color=CgColor('Red') 
                                   OPlot,X_Ener_Val,Ener_Hist, PSYM=10, Color=CgColor('Blue')
                                   OplotError, X_ener_Val, Ener_Hist,Src_Ener_Err_Hist,ErrStyle=0,PSYM=10,/NOHAT
                                   
                                   XYOUTS,!D.X_Size*0.2,!D.Y_Size*0.966, Module, CharSize=2.5,/Device
                                   XYOUTS,!D.X_Size*0.8,!D.Y_Size*0.966, Source, CharSize=2.5,/Device
                                   XYOUTS,!D.X_Size*0.70,!D.Y_Size*(0.03), 'Energy Per Bin ='+STRN(EBIN), CharSize=1.8,/Device
                                   XYOUTS,!D.X_Size*0.8,!D.Y_Size*0.966, Source, CharSize=2.5,/Device
                         
                     Device,/Close
                 Set_Plot, 'X'
      EndIF
      
      Openw, Lun, Output_File_Text,/Get_LUn 
                  Printf, Lun, ' Scaled Back-subtracted Files for further normalization if required '
                  Printf, Lun, ' File Name          ='+Plot_File_Name
                  Printf, Lun, ' Average LT (Src)   ='+Strn(Avg_Lt[Src_Index])
                  Printf, Lun, ' Total Time Ran     ='+Strn(Time_Ran[Src_Index])
                  Printf, Lun, ' Total Counts       ='+Strn(Total(Scat_Hist))
                  
                  Printf, Lun, ' Bin_Size           ='+Strn(BIN)
                  Printf, Lun, ' Empty Line/'
                  Printf, Lun, ' Empty Line/'
                  Printf, Lun, ' Empty Line/'
                  Printf, Lun, ' Empty Line/'

                  For i = 0, N_Elements(Scat_Hist)-1 Do Begin
                          Printf, Lun, Strn(Scat_Hist[i])
                  EndFor
      Free_Lun, Lun
    
End