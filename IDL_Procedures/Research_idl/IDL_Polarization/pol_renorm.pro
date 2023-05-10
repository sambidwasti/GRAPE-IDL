Pro Pol_ReNorm, Input_Folder
    
True = 1
False= 0

    
    
    List_of_Files = File_Search(Input_Folder+'/*ScaledScat*.txt')
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
    Pos0= Strpos(Plot_File_Name,'FM',0)
    Pos = Strpos(Plot_File_Name,'_',Pos0+2)
    Module = StrMid(Plot_File_Name,Pos0,Pos-Pos0)
    
    Pos1 = Strpos(Plot_File_Name,'_',Pos+1)
    Source = Strmid(Plot_File_Name,Pos+1, Pos1-Pos-1)

    ;============= Now Read in the Files ===============
    For p = 0, N_Files-1 Do Begin

            If StrPos(List_of_Files[p],'Unpol',0) GT 0 Then UnPol_Index=p
            
            ;----- Read In the Files----
            Openr, Lun,List_of_Files[p], /Get_Lun
                  Data =''
                 
                  Readf, Lun, Data      ; Headline
                  Readf, Lun, Data      ; File name
                  
                  Readf, Lun, Data ; Average LT.
                  Readf, Lun, Data ; Time Ran
                  Readf, Lun, Data ; Total Counts
                  Pos0 = StrPos(Data,'=',0)
                  Temp_Str = StrMid(Data,Pos0+1,Strlen(Data)-Pos0)
                  Temp_Total_Counts =Double(Temp_Str)
                 
                  Readf, Lun, Data ;Bin Size
                  Pos0 = StrPos(Data,'=',0)
                  Temp_Str = StrMid(Data,Pos0+1,Strlen(Data)-Pos0)
                  Temp_Bin_Size = Fix(Temp_Str)
                  Half_BinSize = Double(Temp_Bin_Size/2)
                  N_Bins = 360/Temp_Bin_Size

                  Readf, Lun, Data ;Empty Line
                  Readf, Lun, Data ;Empty Line
                  Readf, Lun, Data ;Empty Line
                  Readf, Lun, Data ;Empty Line
                  
                  Temp_Hist = DblArr(N_Bins)
                   
                  ; Now the Extraction of Angle information and data.
                  For i = 0, N_Bins-1 Do Begin
                          Readf, Lun, Data
;                          Pos0 = StrPos(Data,' ',0)
;                          Temp_Str = StrMid(Data,0,Pos0)
                          Value = Double(Data)
                          Temp_Hist[i] = Value
                  EndFor ;/i

                  If p eq UnPol_Index Then Begin
                          UnPol_Hist=Temp_Hist
                          UnPol_Total_Counts = Temp_Total_Counts
                          UnPol_NBins = N_Bins
                  EndIf Else Begin
                          Pol_Hist= Temp_Hist
                          Pol_Total_Counts = Temp_Total_Counts
                          Pol_NBins = N_Bins
                  EndElse
                  
            Free_Lun, Lun
     EndFor ;/p
     
     ;Few checks before everything
     If Pol_NBins NE UnPol_NBins Then Begin
            Print, 'INVALID: The Number of Bins or Binsizes dont MATCH'
            Return
     EndIf
     
     Cor_Pol_Hist = DblArr(N_Bins)
     For i =0,N_Bins-1 Do Begin
            Cor_Pol_Hist[i] = UnPol_Total_Counts*Pol_Hist[i]/(UnPol_Hist[i]*N_Bins)
     EndFor
     

;    ;============ FITTING FUNCTIOn =========
;           ;=== Initial Guess ===
;           A0 = MIN(Scat_Hist)
;           A1 = Max(Scat_HIst)-MIn(Scat_HIst)
;           A2 = 1
;           
;           ;=== Some constraints
;           Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
;           Par[1].limited(0) = 1
;           Par[1].limits(0)  = Avg(Scat_Hist)-Min(Scat_Hist)
;                                               
;           Par[*].Value = [A0,A1,A2]
;           
;           ;=== Errors ===
;           Scat_Error = Src_Scat_err_Hist
;           
;           ;=== Fitting Function ===
;           expr = 'P[0] + P[1]*(cos(P[2]-X))^2'
;           
;           ;Plotting the data
;           Plot, X_Val, Scat_Hist, PSYM=10,Title='Polarized Events',CharSize=2,$
;                               XRange=[0,360], XStyle=1,XTickInterval=45, $
;                               YRange=[YMin,YMax],/NODATA,$
;                               XTitle='Angle', YTitle='Counts'
;           
;           Oplot, X_Val, Scat_Hist, PSYM=10
;           OplotError, X_Val, Scat_Hist, Scat_Error, ErrStyle=4,ErrColor='green',/NOHAT  ; Error
;           
;           ;=== Changing the degree values to Radians for the fitting.
;           X_Val1 = 2*!Pi*X_Val/360
;           
;           ;=== Fitting
;           Fit = mpfitexpr(expr, X_Val1, Scat_Hist, Scat_Error, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/Scat_Error)
;           ;=== Fitted Function
;           
;           X_Val2 = 2*!Pi*FINDGEN(360)/360
;           Fitted_Funct = Fit[0] + Fit[1]*cos(Fit[2]-X_Val2)^2
;           Text_Funct = STRN(Fit[0])+' +'+Strn(Fit[1])+'(Cos( '+Strn(Fit[2])+'-X ))^2
;           ;=== Changing the x axis values to Degrees and plotting the fit
;           Oplot, X_Val2*360/(2*!PI), Fitted_Funct, Color=CgColor('Red')   
;;           Oplot, X_Val, Src_Scat_Hist1, PSYM=10, Color=CgColor('Green')
;;           Oplot, X_Val, Scaled_Back_Scat_Hist, PSYM=10, Color=CgColor('Blue')
;           ;-- Calculating the modulation factor -- (Max-Min)/(Max+Min)
;           ; Max- Min is the Fit[1] value. 
;           
;           Modulation = Double(Double(Fit[1])/Double(2*Fit[0]+Fit[1]))
;           Print, Modulation
;    ;=========== Plotting =================
X_VAL = INdGen(N_Bins)*Temp_Bin_Size+Half_BinSize
       Set_Plot, 'PS'
       loadct, 13                           ; load color
            Device, File = Input_Folder+'_Plot.ps', /COLOR,/Portrait
            Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                         Plot, X_VAl, Unpol_Hist, PSYM=10,Title='Renormalized Events',CharSize=2,$
                               XRange=[0,360], XStyle=1,XTickInterval=45, $
                               YRange=[-100,1500],/NODATA,$;YRange=[Ymin,YMax],$
                               XTitle='Angle', YTitle='Counts'
                         Oplot, X_Val, Pol_Hist, PSYM=10,Color=CgColor('Blue')
                          
                         Oplot, X_Val, UnPol_Hist, PSYM=10 , Color=CgColor('Green')
                         Oplot, X_Val, Cor_Pol_Hist, PSYM=10, Color=CgColor('Dark Green')

;                         XYOUTS,!D.X_Size*0.2,!D.Y_Size*0.966, Module, CharSize=2.5,/Device
;                         XYOUTS,!D.X_Size*0.8,!D.Y_Size*0.966, Source, CharSize=2.5,/Device
;                         XYOUTS,!D.X_Size*0.7,!D.Y_Size*(0.03), 'Deg Per Bin='+STRN(BIN), CharSize=1.8,/Device
;                         XYOUTS,!D.X_Size*0.7,!D.Y_Size*0.915, 'u ='+STRN(Modulation), CharSize=1.8,/Device
;                         XYOUTS,!D.X_Size*0.6,!D.Y_Size*0.01, Text_Funct, CharSize=1.0,/Device
           Device,/Close
       Set_Plot, 'X'


End