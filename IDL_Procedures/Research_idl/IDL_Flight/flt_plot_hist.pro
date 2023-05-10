Pro Flt_Plot_Hist, Src_File, Back_File , BSize=BSize ,Indiv = Indiv, Title=Title, Type=Type, NFIT=NFIT, Max_X = Max_X , OPT=OPT

; Needs the energy range associated with it. 
; *************************************************************************
; *                 Plot the histograms for Flights                       *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read in the flight histogram files, Scale them and plot     *
; *           them and do a fitting to them. It could be all combined     *
; *           or each individual modules.                                 *
; *                                                                       *
; * Usage: Flt_Plot_Hist,'First File','Second File'                       *
; *        Flt_Plot_Hist,'One File'                                       *
; *    Note: second file is scaled to the first file.                     *
; *                                                                       *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *     BSize = Bin Size                                                  *
; *                                                                       *
; *     Title = added title to the created histogram files.               *
; *                                                                       *
; *     Nfit  = No. of fits to be done on each plot. Usually very helpful *
; *             for sources with multiple fits. Default is 1              *
; *                                                                       *
; *     Type  = A flag to label the X-Axis and give its range             * 
; *             1 = Energy                                                *
; *             2 = Angle and this is 0-360                               *
; *                                                                       *     
; *     Indiv = A flag to print each module separately or not.            * 
; *                                                                       *
; *     Max_X = Maximum X value. For Polarization, its always 360, for the*
; *             Energy we can vary it. Default is 500.                    *    
; *                                                                       *
; *     Inputs::                                                          *
; *           Src_File : Source Histogram File                            *
; *           Back_File: Background Histogram File                        *
; *                                                                       *
; *     Outputs::                                                         *
; *          A fitting parameter text file along with                     *
; *          Fitted plot(s) with source and scaled background with errors *
; *                                                                       *
; * Involved Non-Library Procedures:                                      *
; *           -Dir_Exist.pro                                              *
; *           -Grp_Anode_XY                                               *
; *           -Grp_Module_XY                                              *
; *                                                                       *
; * Libraries Imported:                                                   *  
; *           -Coyote Full Library                                        *
; *           -Astronomy Full Library                                     *
; *           -MPFit Full Library. For fitting functions.                 *
; *                                                                       *
; * Files Used and thier Formats:                                         *
; *        Histogram Files are generated via Flt_L1_Pol or Flt_L1_Ener    *
; *        right now.                                                     *
; *                                                                       *
; * Author: 9/05/14  Sambid Wasti                                         *
; *                  Email: Sambid.Wasti@wildcats.unh.edu                 *
; *                                                                       *
; * Revision History:                                                     *
; *         9/07/14  Sambid Wasti                                         *
; *                  Added the polarization angle to the sin-squared plots*
; *         9/14/14  Sambid Wasti                                         *
; *                  Fixed the binning problem of plotting it in begining *
; *                  to plotting it in the middle.                        *
; *                                                                       *
; *                                                                       *
; * NOTE:  Currently 2 fitting functions are empty                        *
; *                                                                       *
; *************************************************************************
; *************************************************************************

;-- Standard Flag System for easiness --
True =1
False=0
    
    
    ;=====  INITIALIZATION of input parameters and keywords =======
    
    
    ;--- See whether we have only source or a background too --
    If (n_params() GT 2) or (n_params() LT 1) Then Begin
          Print, 'ERROR: INVALID NO. of Parameters'
          Return
    EndIf Else Begin
          If n_params() EQ 2 Then Back_Flag= True Else Back_Flag = False
    EndElse
    
    
    ;--- No. of fits --
    If Keyword_Set(Nfit) EQ 0 Then N_fit =1 Else N_Fit=NFIT    
    
    
    ;--- Optimization --
    If Keyword_Set(OPT) NE 0 Then Opt_Flag = True Else Opt_Flag = False
    
    ;--- Plot type --
    If Keyword_Set(Type) EQ 0 Then Type =1      
    
    ;--- Max X in the plot and X title ---
    If Type eq 1 Then begin
       If Keyword_Set(MAx_X) Eq 0 Then Max_X = 600
        Title_X = 'Energy'
    EndIF Else Begin
        Max_X= 360
        Title_X = 'Scatter Angle'
    EndELse 
    
    ; -- Bin Size --
    If Keyword_Set(BSize) EQ 0 Then BSize=1
    
    ;-- Title added --
    If Keyword_Set(Title) EQ 0 Then Title=''
    
    ;--- Individual plot for Modules.. Flag --
    If Keyword_Set(INDIV) NE 0 Then Indiv_Flag = True Else Indiv_Flag =False
    
    ;--- Some Variables --
    Src_Avg_LT  = FltArr(32)
    Back_Avg_LT  = FltArr(32)
    
    ; 2014 Grape Configuration Positions
    c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration
  
    ;
    ; Grab the Data and Put them in the individual Arrays
    ;
    For p=0,1 Do Begin
         
         ;--- Src and Back---
         If p eq 0 Then Fname=Src_File Else Begin
                  IF Back_Flag Eq False THen Goto, Jump_File
                  Fname=Back_File
         EndElse
         
         
         ;
         ;--- Open the file and proceeed --
         ;
         Openr, Lun, Fname, /Get_Lun
                
                Data =''
                Readf, lun, Data
                
                ;
                ;Total Time Ran
                ;
                Readf, lun, Data  
                Pos0 = StrPos(Data,'=',0) +1
                Time_Ran= Float( StrMid(Data,Pos0, StrLen(Data)-Pos0 ) )
                If p eq 0 Then Src_time = Time_Ran Else Back_Time = Time_Ran
                print, time_ran
                ;
                ;-- Array Length --
                ;
                Readf, lun, Data
                Pos0 = StrPos(Data,'=',0) +1
                Arr_Len= Long( StrMid(Data,Pos0, StrLen(Data)-Pos0 ) )
                print, arr_len
                ;
                ;-- Define the Histogram Arrays --
                ;
                If p EQ 0 Then Src_Hist  = LonArr(32, Arr_Len) Else Back_Hist = LonArr(32, Arr_Len)
                
                ;
                ;-- Grab the data
                ;
                While Not EOF(Lun) Do Begin
                      
                      ;- Read -
                      Readf, lun, Data
                 
                      ;-- Skip the Module Position not in Configuration--
                      If StrPos(Data,'Mod_Pos',0) NE -1 Then BEgin
                            ; Grab Mod Position for the array
                            Pos0 = StrPos(Data,'=',0)+1
                            ModPos = Long(StrMid(Data, Pos0, StrLEn(Data)-Pos0))
             
                            ; Grab the Avg Livetime
                            Readf, lun, Data
                            Pos0 = StrPos(Data,'=',0)+1
                            Temp_LT = Float(StrMid(Data, Pos0, StrLEn(Data)-Pos0))
                            If p eq 0 Then Src_Avg_LT[ModPos] = Temp_LT Else Back_Avg_LT[ModPos] = Temp_LT
                            
                            ; Read the Data
                            Readf, lun, Data
                            Pos0 = 0
                            For i = 0,Arr_Len-1 Do BEgin
                                  
                                  Pos1 = StrPos(Data,' ',Pos0)
                                  Temp_Var = StrMid(Data,Pos0,Pos1-Pos0)
                                  
                                  ;
                                  ;-- Grab the data for the source or background.
                                  ;
                                  If P Eq 0 Then Src_Hist[ModPos,i] = Strn(Temp_Var) Else Back_Hist[Modpos,i]=Strn(Temp_Var)
                                  
                                  Pos0 = Pos1+1
                            EndFor
                      EndIF 
                 EndWhile
         Free_Lun, Lun 
         ; ==== We have the The background and Src Data =====
    Jump_File:
    EndFor ;p
    
    ;--- Source/Background Error Definitions. 
    Src_Err = SQRT(Src_Hist)
    If Back_Flag Eq True Then Back_ERr = SQRT(Back_Hist)
 Print, Max(Src_Hist)
    ;
    ;===== REBINNING =======
    ;
        N_Bins = Arr_Len/BSize
        
        ;--- More definitions ---
        Temp_Hist     = LonArr(32,N_Bins)
        Scaled_Hist   = DblArr(32,N_Bins)
        Scaled_Back   = DblArr(32,N_Bins)
        
        Scaled_HistErr= DblArr(32,N_Bins)
        Scaled_BackErr= DblArr(32,N_Bins)

        ;
        ;--- Rebinning the Source Histogram--
        ;
        For M =0,31 Do Begin     
              
              Temp_Count =0L        
              For i = 0,N_Bins-1 Do Begin
                  Temp_Val =0.0
                  
                  For j=0, BSize-1 Do Begin
                           Temp_Val = Src_Hist[M,Temp_Count]+Temp_Val
                           Temp_Count++
                  EndFor;j
                  Temp_Hist[M,i]=Temp_Val
                  
              EndFor ; i
         EndFor; M
         Temp_Err_Hist= Sqrt(ABS(Double(Temp_Hist)))
        
         ;
         ;--- Rebinning and scaling the second/background file to the Source File
         ;
         If Back_Flag Eq True Then Begin
    
              ;--- Rebin For Background ---
              Temp_Hist1 = LonArr(32,N_Bins)
             
              For M =0,31 Do Begin     
              Temp_Count =0L        
                    For i = 0,N_Bins-1 Do Begin
                    Temp_Val =0.0
                    
                        For j=0, BSize-1 Do Begin
                            
                            Temp_Val = Back_Hist[M,Temp_Count]+Temp_Val
                            Temp_Count++
                        EndFor;j
                        Temp_Hist1[M,i]=Temp_Val
                    EndFor ; i
              EndFor ; M
              Temp_Err_Hist1= Sqrt(Abs(Double(Temp_Hist1)))
              
              ;
              ; ==== Now Scaling or Normalizing ===
              ; 
              For M=0,31 Do Begin
                      ;
                      ;-- Skipping the Modules not in the 2014 Configuration --
                      ;
                      If (Where(M EQ c2014) NE -1) Then Begin
                            
                            ;--- Grab a Scale Factor ---
                            Scl_Factor = Src_Time* Src_Avg_LT[M]/(Back_Avg_LT[M]*Back_Time)
                           print, M, ' ',Scl_Factor
                            ;-- Get a Scaled Background Array ---
                            Scaled_Back[M,*]= Scl_Factor* Temp_Hist1[M,*]
                            
                            ;-- Subtract the scaled Background From the Source to ge a Scaled Hist --
                            Scaled_Hist[M,*]= Temp_Hist[M,*]-Scaled_Back[M,*]
                            
                            ;-- Scaled Background Error-- via proper propagation.
                            Scaled_BackErr[M,*]= Scl_Factor* Temp_Err_Hist1[M,*]
                            
                            ;-- Adding the errors in quadrature so squaring each errors.
                            TempArrErr1 = Scaled_BackErr[M,*] * Scaled_BackErr[M,*]; Scaled Background Error
                            TempArrERr2 = Temp_Err_Hist[M,*] * Temp_Err_Hist[M,*];Src Error
                            
                            ;-- Finishing the final Error.
                            Scaled_HistErr[M,*]= SQRT( TempArrErr2 + TempArrErr1 )
         
                      EndIF
              EndFor; /M
          
          EndIf Else Begin  ; BackFlag Stuff.
                    Scaled_Hist = Temp_Hist
                    Scaled_HistErr = Temp_Err_Hist
          EndElse
    ;      
    ;======= Rebinning Finished ======
    ;
               

    ;
    ; --- Now Work All together
    ;
    Total_Histogram = DblArr(N_Bins)
    Total_SclBack   = DblArr(N_Bins)
    Total_Src       = DblArr(N_Bins)
    
    Total_Histogram_Err = DblArr(N_Bins)
    Total_SclBack_Err   = DblArr(N_Bins)
    Total_Src_Err       = DblArr(N_Bins) 
    
    If Indiv_flag Eq False Then Begin
          For M = 0,31 Do Begin
                If (Where(M EQ c2014) NE -1) Then Begin
                        Total_Histogram = Total_Histogram+ Scaled_Hist[M,*]
                        Total_SclBack   = Total_SclBack  + Scaled_Back[M,*]
                        Total_Src       = Total_Src      + Temp_Hist[M,*]
                        
                        ;== Square the Errors and add
                        Total_Histogram_Err = Total_Histogram_Err + ( Scaled_HistErr[M,*] *  Scaled_HistErr[M,*])
                        Total_SclBack_Err   = Total_SclBack_Err   + ( Scaled_BackErr[M,*] *  Scaled_BackErr[M,*])
                        Total_Src_Err       = Total_Src_Err       + ( Temp_Err_Hist[M,*] * Temp_Err_Hist[M,*])
                EndIf
          EndFor
          ;=== Square root the errors to get the quadrature.
          Total_Histogram_Err = SQRT(Total_Histogram_Err)
          Total_SclBack_Err   = SQRT(Total_SclBack_Err)
          Total_Src_Err       = SQRT(Total_Src_Err)
    EndIF
    ;---------

    ;--- Few X Variables --
    XVAL = INDGEN(N_Bins)*BSIZE 
    XVAL2 = XVAL+(BSize/2.0)
    
    XMAX = MAX(XVAL)
    XMIN = MIN(XVAL)

   ; Total_Histogram = Total_Histogram - Total_Histogram*0.00039390863
    ;
    ; ====== Plot and Fit the Data =====
    ;
    
        ;--- Defining the title for all-
        IF Indiv_Flag EQ False THen Title=Title
        
        ;--- Current Directory
        CD, Cur = Cur    
        
        ;----- text File naming and path
        If Indiv_Flag Eq True Then Openw, Txt_Lun,Cur+'/'+Title+'_Fit.txt',/Get_LUn 
        
        ;---- Opening the Device for further plots and various things -----
        Set_Plot, 'PS'
        loadct, 13                           ; load color
        Device, File = Cur+'/'+Title+'_Hist.ps', /COLOR,/Portrait
        Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
        
        F=0   ; Default Fitting value = Gaussian. 
        
        For i=0,N_Fit-1 Do BEgin
            
            ;-- For All Modules --
            Final_Histogram = Total_Histogram  
            Final_SclBack = Total_SclBack
            Final_Src     = total_Src
            
            Final_Histogram_Err = Total_Histogram_Err
            Final_SclBack_Err   = Total_SclBack_Err
            Final_Src_Err       = Total_Src_Err
            
            ;---  Flag to skip for Indiv Modules --
            If INDIV_Flag EQ False Then GOTO, SKIP_INDIV
            
            ;---  The heading in the text file ---
            If Indiv_Flag Eq True then begin
                    If Type EQ 1 then Printf, Txt_Lun, 'Mod Centroid  Error    Sigma    Error    Area    Error' Else Printf, Txt_Lun,  ' Module  Modulation Error'
            EndIF

            ;--- For Each Module ----
            For j = 0,31 Do Begin
                  
                  ;
                  ;--- Selecting/Working on only the Modules in the 2014 configuration.
                  If (Where(j EQ c2014) NE -1) Then Begin
                        
                        ;---- If Individual Module then we want the each indvidual module histogram.
                        Final_Histogram = Scaled_Hist[j,*]
                        Final_SclBack = Scaled_Back[j,*]
                        Final_Src     = Temp_Hist[j,*]
                        
                        Final_Histogram_Err = Scaled_HistErr[j,*]
                        Final_SclBack_Err   = Scaled_BackErr[j,*]
                        Final_Src_Err       = Temp_Err_Hist[j,*]
                        
                   EndIF Else Goto, Skip_Indiv2 ; Skip all this if the Module is not in 2014 config.

                   Skip_Indiv:   ; A goto pointer. 
                   
                   ;-- Set Plot changed back to 'X' so that we can use cursors.
                   Set_plot, 'X'
                   
                   ;--- Plotting the working data ---
                   Plot, XVAL,Final_Histogram, PSYM=10, YRange=[0,Max(Final_Histogram)*1.2],XRANGE=[0,MAx_X], XStyle=1
                   cgErrPlot, XVal,Final_Histogram-Final_Histogram_Err, Final_Histogram+Final_Histogram_Err, Color='YELLOW'
                   
                   ;--- Using a Flag to get out of the while loop when done. ---
                   Flag_Fitted = False
                   ;
                   ;==== GUI SETUP for FITTING FUNCTION ====
                   ;
                   
                   ; ---- Fitting Flag ----
                   While Flag_Fitted EQ False Do BEgin
                          
                            Print, 'N_Fit=', i
                            
                            ;--- GUI things for the Cursors----
                            Polyfill, [880,880,928, 928], [440,498,498,440], Color=CgColor('Purple'),/DEVICE
                            XYOUTS, 890, 465, 'DONE', /Device
                            
                            Polyfill, [822,822,870, 870], [440,498,498,440], Color=CgColor('ORANGE'),/DEVICE
                            XYOUTS, 832, 465, 'GAUSS', COLOR=CgColor('Black'),/Device
                            
                            Polyfill, [764,764,812, 812], [473,498,498,473], Color=CgColor('ORANGE'),/DEVICE
                            XYOUTS, 772, 485, '3GAUSS', COLOR=CgColor('Black'),/Device
                            
                            Polyfill, [706,706,754, 754], [473,498,498,473], Color=CgColor('ORANGE'),/DEVICE
                            XYOUTS, 715, 485, 'SINO', COLOR=CgColor('Black'),/Device
                            
                            Polyfill, [764,764,812, 812], [440,465,465,440], Color=CgColor('ORANGE'),/DEVICE
                            XYOUTS, 770, 450, '2GAUSS', COLOR=CgColor('Black'),/Device
                            
                            Polyfill, [706,706,754, 754], [440,465,465,440], Color=CgColor('ORANGE'),/DEVICE
                            XYOUTS, 715, 450, 'SINO^2', COLOR=CgColor('Black'),/Device
                            
                          
                            
                            ; If Clicked Done
                            Cursor, X_Value, Y_Value, /DOWN, /DEVICE
                            IF( X_Value GE 880) AND ( Y_VALUE GE 440 ) Then BEgin
                                  Flag_Fitted = True
                                  Print, '-----------------Fitting DONE ---------------------'
                            GOTO, Jump_Fitted
                            ENDIF
                     
                            ;
                            ; Grabbing a Fitting function value depending on where the user clicked.
                            ;
                            If( (X_Value GE 822) And (X_Value LE 870) AND (Y_Value GE 440) And (Y_Value LE 498) ) Then F=0 $
                            Else If( (X_Value GE 764) And (X_Value LE 812) AND (Y_Value GE 473) And (Y_Value LE 498) ) Then F=1 $
                            Else If ( (X_Value GE 706) And (X_Value LE 754) AND (Y_Value GE 473) And (Y_Value LE 498) ) Then F=2 $ 
                            Else If ( (X_Value GE 764) And (X_Value LE 812) AND (Y_Value GE 440) And (Y_Value LE 465) ) Then F=3 $
                            Else If ( (X_Value GE 706) And (X_Value LE 754) AND (Y_Value GE 440) And (Y_Value LE 465) ) Then F=4 
                            
                            ;
                            ;-- Plotting things---
                            ;
                            Plot, XVAL,Final_Histogram, PSYM=10, YRange=[0,Max(Final_Histogram)*1.2],XRANGE=[0,MAx_X], XStyle=1
                            cgErrPlot, XVal,Final_Histogram-Final_Histogram_Err, Final_Histogram+Final_Histogram_Err,Color='YELLOW'
                            
                            ;--
                            ;---- Defining the Fit name with the F Variable
                            ;--
                            If F EQ 0 Then Fit_Name = 'GAUSSIAN' Else $        ;Working
                            If F EQ 1 Then Fit_Name = '3 GAUSSIAN'Else $ 
                            If F EQ 2 Then Fit_Name = 'SINOSUDIAL' Else $
                            If F EQ 3 Then Fit_Name = '2 GAUSSIAN' Else $      ;Working
                            If F EQ 4 Then Fit_Name = 'SINOSUDIAL SQ'          ;Working
                            
                            ;
                            ;--- Printing the Fitting function stuffs.
                            ;
                            XYOUTS, 700, 450, Fit_Name, CharSize= 3, /DEVICE  ; Outputing what function we clicked to keep track of it.
                            
                            ;
                            ;--- Module No. for Individual Module Plots--
                            ;
                            IF Indiv_Flag eq True Then XYOUTS, !D.X_Size*0.5,!D.Y_Size*0.85, 'MODULE '+strn(j), CharSize=3,/Device
                            
                            ;
                            ;-- No Fits for these fits yet so jump to Sino-Plot
                            If (F EQ 2) OR (F EQ 4) Then Goto, Sino_Plot
                            
                            ;
                            ; === Selecting the Data using the coordinates ==
                            ;
                            
                            ;
                            ;-- The plotting area has the X range of 60~882, getting the intercept and slope for the conversion. 
                            ;
                            C_Slope = Float( (Max_X-XMIN)/Float(882)) 
                            C_Range = Float( (C_Slope*60)-XMIN)
                            
                            ;
                            ;--- Here Comes the Cursor Stuffs
                            ;
                            
                            If Opt_Flag EQ True Then BEgin
                              Cursor, X_Value9, Y_Value9, /DOWN, /DEVICE
                              Temp_Chan_val = Float(X_Value9*C_Slope-c_Range)
                              Temp_Chan = FIX(Temp_Chan_Val/BSIZE)
                              PolyFill, [X_Value9,X_Value9,X_Value9+1, X_Value9+1],[Y_Value9-1000,Y_Value9+1000,Y_Value9+1000, Y_Value9-1000], Color=CgColor('Purple'),/Device

                              Cursor, X_Value10, Y_Value10, /DOWN, /DEVICE
                              Temp_Chan_val2 = Float(X_Value10*C_Slope-c_Range)
                              Temp_Chan2=FIX(Temp_Chan_Val2/BSIZE)
                              PolyFill, [X_Value10,X_Value10,X_Value10+1, X_Value10+1],[Y_Value10-1000,Y_Value10+1000,Y_Value10+1000, Y_Value10-1000], Color=CgColor('Purple'),/Device
                              
                             OPt_Scale = Double(Total(Final_Histogram[Temp_Chan:Temp_Chan2])/ N_Elements(Final_Histogram[Temp_Chan:Temp_Chan2]))
                             Final_Histogram = Final_Histogram - OPt_Scale
                             Opt_Flag = False
                             ;
                             ;-- Plotting things---
                             ;
                             Plot, XVAL,Final_Histogram, PSYM=10, YRange=[0,Max(Final_Histogram)*1.2],XRANGE=[0,MAx_X], XStyle=1
                             cgErrPlot, XVal,Final_Histogram-Final_Histogram_Err, Final_Histogram+Final_Histogram_Err,Color='YELLOW'
                            EndIF
                            
                            ;--- Min Channel ---
                            Cursor, X_Value0, Y_Value0, /DOWN, /DEVICE
                            min_Chan_Val = Float(X_Value0*C_Slope-c_Range)
                            min_Chan= FIX(min_Chan_Val/BSIZE)
                            Print, XVAL(min_Chan)
                            PolyFill, [X_Value0,X_Value0,X_Value0+1, X_Value0+1],[Y_Value0-1000,Y_Value0+1000,Y_Value0+1000, Y_Value0-1000], Color=CgColor('Yellow'),/Device
                            Print, ' Min Channel = ' + Strn(min_Chan_Val)
                            
                            ;--- Max Channel ---            
                            Cursor, X_Value1, Y_Value1, /DOWN, /DEVICE
                            max_Chan_Val = Float(X_Value1*C_Slope-c_Range)
                            max_Chan= FIX(max_Chan_Val/BSIZE)
                            PolyFill, [X_Value1,X_Value1,X_Value1+1, X_Value1+1],[Y_Value1-1000,Y_Value1+1000,Y_Value1+1000, Y_Value1-1000], Color=CgColor('Yellow'),/Device
                            Print, ' Max Channel = ' + Strn(max_Chan_Val)
                            
                            Cursor, X_Value2, Y_Value2, /DOWN, /DEVICE
                            peak_Chan_Val = Float(X_Value2*C_Slope-c_Range)
                            peak_Chan= FIX(peak_Chan_Val/BSIZE)
                            PolyFill, [X_Value2-2,X_Value2-1,X_Value2+1, X_Value2+1],[Y_Value2-5,Y_Value2+5,Y_Value2+5, Y_Value2-5], Color=CgColor('Yellow'),/Device
                            Print, ' Peak Channel = ' + Strn(peak_Chan_Val)
                            
                            ;
                            ; Just a check to have the option of selecting max Chan first( Swapping Min and Max Channel )
                            ;
                            If Min_Chan GT Max_Chan Then BEgin
                                    Temp_A= Min_Chan
                                    Min_Chan = Max_Chan
                                    Max_Chan = Temp_A
                            EndIf
                            
                            ;
                            ;-- Data Selection
                            ;
                            Hist1     =     Final_Histogram[min_Chan:max_Chan]
                            Hist1_Err = Final_Histogram_Err[min_Chan:max_Chan]
                            Xfit1     =                XVAL[min_chan:max_Chan]
                            
                            Fit_Text2 = ''
                            
                            ; No Selection for the Sino plot. sino=sinosudoil squared.
                            Sino_Plot:
                            
                            ;
                            ; -- Using Cases to go between the fitting function --
                            ;
                            Case F OF
                            0: Begin      ; This is the GAUSSIAN.
                                    P0 = 0.0
                                    P1 = Peak_Chan_Val
                                    P2 = 15
                                    P3 = Final_Histogram[peak_Chan]*5
                                    
                                    Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
                                    
                                    Par[1].limited(0) = 1
                                    Par[1].limits(0)  = Peak_Chan_Val-40
                                    Par[1].limited(1) = 1
                                    Par[1].limits(1)  = Peak_Chan_Val+40
                                    
                                    Par[2].limited(0) = 1
                                    Par[2].limits(0)  = 1.0
                                    
                                    Par[3].limited(0) = 1
                                    Par[3].limits(0)  = 0.0
                                    
                                    
                                    Par[*].Value = [P0,P1,P2,P3]
                                    
                                    Expr = 'Gauss1(X,P[1:3])'
                                    
                                    Fit = mpfitexpr(expr, Xfit1, Hist1, Hist1_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=(1/(Hist1_Err*Hist1_Err)))
                                    
                                    G_Fit = Gauss1(Xfit1, Fit[1:3])
                                    
                                    Fitted =G_Fit
                                    Continium_Fit = 0*Xfit1
                                    
                                    
                                    Print, FIT
                                    FWHM = 2 * Sqrt(2*Alog(2))* Fit[2]
                                    XYOUTS,300,470, 'FWHM ='+Strn(FWHM), /DEVICE
                                    XYOUTS,300,480, 'Centroid =' +Strn(Fit[1]), /DEvice
                                    
                                    oplot, Xfit1, fitted, Color=CgColor('RED'), Thick = 2
                                    OPlot, Xfit1, Continium_fit, Color = CgColor('Blue'), Thick =2
                                    DOF      = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
                                    PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
                                    Chisqr = (BESTNORM / DOF)
                                    

                                    Print, PCError
                                    
                                 ;   Fit_Text1= String(Format= '("Centroid =" ,(F4.1,X)," +/- ",(F4.1) )',Fit[1], PCERROR[1])
                                    Fit_Text11 = String(Format= '((F5.1,X))',Fit[1])
                                    Fit_Text12 =String(Format= '((F4.1,X))',PCERROR[1])
                                    Fit_Text1 = Fit_Text11 + '+/-'+Fit_Text12
                                    
                                    Fit_Text2= STring(Format= '("FWHM    =",(F4.1,X))',FWHM)
                                    Fit_Text3= String(Format= '("Gaussian : {",(F7.3,X),"(",(F6.3,X),"), ",(F7.3,X),"(",(F6.3,X),"), ",(F12.3,X),"(",(F10.3,X),") }" )' ,Fit[1],PCERROR[1],Fit[2],PCError[2],Fit[3],PCError[3])
                                    Fit_Text4 = String(Format= '("Reduced Chi-Sq= " ,(F7.3,X) )',Chisqr)
                                    Fit_Text5 = 'DOF ='+STRN(DOF)
                                    
                                    
                                    Print, Fit_text4
                                    
                                    File_text1= Strn(j) + '   '+ Strn( Fit[1]) + '   '+ Strn(PCError[1] ) + '   ' + Strn( Fit[2]) + '   '+ Strn(PCError[2] ) +  '  '+Strn( Fit[3]) + '  '+ Strn(PCError[3] )
                                                  
                            End  
                            3: Begin  ; Double Gaussian. 
                                    
                                    ;
                                    ;--- For this fit, we need 2 peak positions so getting it
                                    ;
                                    Print, ' Click For 2nd Starting PEAK position '
                                    Cursor, X_Value3, Y_Value3, /Down, /DEVICE
                                    Peak_Chan_Val2 = Float(X_Value3*C_Slope-c_Range)
                                    Peak_Chan2 = FIX(Peak_Chan_Val2/BSize) 
                                    PolyFill, [X_Value3-2,X_Value3-1,X_Value3+1, X_Value3+1],[Y_Value3-5,Y_Value3+5,Y_Value3+5, Y_Value3-5], Color=CgColor('Orange'),/Device
                                    Print, ' Peak Channel 2 =' + STrn(PEak_Chan_Val2)
                                    
                                    
                                    P0 = 0L
                                    P1 = Peak_Chan_Val
                                    P2 = 15
                                    P3 = Final_Histogram[peak_Chan]*5
                                    P4 = Peak_Chan_Val2
                                    P5 = 15
                                    P6 = Final_Histogram[peak_Chan2]*5
                                    
                                    
                                    Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 7)
                                    
                                    Par[0].fixed=1
                                    
                                    Par[1].limited(0) = 1
                                    Par[1].limits(0)  = Peak_Chan_Val-40
                                    Par[1].limited(1) = 1
                                    Par[1].limits(1)  = Peak_Chan_Val+40
                                    
                                    Par[2].limited(0) = 1
                                    Par[2].limits(0)  = 1.0
                                    
                                    Par[3].limited(0) = 1
                                    Par[3].limits(0)  = 0.0
                                    
                                    Par[5].Limited(0) = 1
                                    Par[5].limits(0)  = 1.0
                                    
                                    Par[6].limited(0) = 1
                                    Par[6].limits(0)  = 1.0
                                    
                                    Par[*].Value = [P0,P1,P2,P3,P4,P5,P6]
                                    
                                    Expr = 'P[0] + Gauss1(X,P[1:3]) + Gauss1(X, P[4:6])'
                                    
                                    Fit = mpfitexpr(expr, Xfit1, Hist1, Hist1_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=(1/(Hist1_Err*Hist1_Err)))
                                    
                                    G_Fit = Gauss1(Xfit1, Fit[1:3])
                                    G_Fit2 = Gauss1(Xfit1, Fit[4:6])
                                    Continium_Fit = Fit[0]+ G_Fit2
                                    
                                    Fitted = Continium_Fit+ G_Fit
                                    
                                    FWHM = 2 * Sqrt(2*Alog(2))* Fit[2]
                                    XYOUTS,300,470, 'FWHM ='+Strn(FWHM), /DEVICE
                                    XYOUTS,300,480, 'Centroid =' +Strn(Fit[1]), /DEvice
                                    
                                    oplot, Xfit1, G_Fit, Color=CgColor('green'), Thick= 1
                                    oplot, Xfit1, fitted, Color=CgColor('RED'), Thick = 3
                                    oplot, Xfit1, Continium_Fit, Color=CgColor('Pink'), Thick =1
                                    
                                    DOF      = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
                                    PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
                                    Chisqr = (BESTNORM / DOF)
                                    
                                    
                                    Print, Fit
                                    Print, PCERROR
                                    
                                        Fit_Text11 = String(Format= '((F5.1,X))',Fit[1])
                                        Fit_Text12 =String(Format= '((F4.1,X))',PCERROR[1])
                                        Fit_Text1 = Fit_Text11 + '+/-'+Fit_Text12
                                   ; Fit_Text1= String(Format= '("Centroid =" ,(F7.3,X)," +/- ",(F6.3) )',Fit[1], PCERROR[1])
                                    Fit_Text2= STring(Format= '("FWHM =",(F7.3,X))',FWHM)
                                    Fit_Text3= String(Format= '("Gaussian1: ",(F7.3,X),"(",(F6.3,X),"),",(F7.3,X),"(",(F6.3,X),"),",(F12.3,X),"(",(F10.3,X),")}")' ,Fit[1],PCERROR[1],Fit[2],PCError[2],Fit[3],PCError[3])
                                    Fit_Text4 = String(Format= '("Reduced Chi-Sq= " ,(F7.3,X) )',Chisqr)
                                    Fit_Text5 = 'DOF ='+STRN(DOF)
                                    
                                    Print, Fit_text4
                                    
                                    File_text1= Strn(j) + ' '+ Strn( Fit[1]) + ' '+ Strn(PCError[1] ) + ' ' + Strn( Fit[2]) + ' '+ Strn(PCError[2] ) +  ' '+Strn( Fit[3]) + ' '+ Strn(PCError[3] )
                                    
                            End
                            4: Begin ; Sinosudial squared.
                                          
                                    ; So now the X-Axis is the Angle
                                    Xfit1 = 2*!Pi*XVal/360
                                    
                                    A0 = MIN(Final_Histogram)
                                    A1 = Max(Final_Histogram)-MIn(Final_Histogram)
                                    A2 = 1
                                    
                                    ;=== Some constraints
                                    Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
                                    
                                    Par[1].limited(0) = 1
                                    Par[1].limits(0)  = Avg(Final_Histogram)-Min(Final_Histogram)
                                    
                                    Par[1].limited(1) = 1
                                    Par[1].limits(1) = Max(Final_Histogram)-Min(Final_Histogram)+200
                                    
                                    Par[*].Value = [A0,A1,A2]
                                    
                                    Print, MIN(Final_Histogram)
                                    Print, Avg(Final_Histogram)-Min(Final_Histogram), Max(Final_Histogram)-Min(Final_Histogram)+200
                                    
                                    ;=== Fitting Function ===
                                    expr = 'P[0] + P[1]*(cos(P[2]-X))^2'
                                    Fit = mpfitexpr(expr, Xfit1, Final_Histogram, Final_Histogram_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/(Final_Histogram_Err*Final_Histogram_Err))
                                    
                                    Print, Er
                                    
                                    DOF     = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
                                    PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
                                    
                                    XFit1 =2*!Pi*FINDGEN(360)/360
                                    fitted = Fit[0] + Fit[1]*cos(Fit[2]-Xfit1)^2
                                    
                                    Xfit1 = XFit1*360/(2*!PI)
                                    Oplot, XFit1, fitted, Color=CgColor('Red')   
                                    
                                    Print, Fit
                                    Print, PCERROR
                                    
                                    Modulation_Factor = Float(Fit[1]/float(Fit[1]+2*Fit[0]))
                                    
                                    Temp_Err_1 = 2 * PCError[0]
                                    Temp_Err_2 = SQRT( PCError[1]*PCError[1] + Temp_Err_1 * Temp_Err_1 )
                                    Temp_Err_3 = SQRT( ((PCError[1]/Fit[1])^2) + ((TEmp_Err_1/(Fit[1]+2*Fit[0]))^2)  )
                                    
                                    Modulation_Factor_Er = Modulation_Factor*Temp_Err_3
                                    Chisqr = (BESTNORM / DOF)
                                    
                        
                                    
                                    Fit_Text11 = String(Format= '((F5.2,X))',Modulation_Factor)
                                    Fit_Text12 = String(Format= '((F5.2,X))',Modulation_Factor_Er)
                                    Fit_Text1 = Fit_text11+'+/-'+Fit_Text12
                                    
                                  ;  Fit_Text21 = String(Format= '("Pol Angle =" ,(F6.1,X)," +/- ",(F5.1) )',(180*Fit[2]/(!PI))+90, 180*PCERROR[2]/!PI)

                                    Fit_Text21 = String(Format= '((F6.1),X)',(180*Fit[2]/(!PI))+90) 
                                    Fit_Text22 = String(Format= '((F5.1),X )', (180*PCERROR[2]/!PI))
                                    Fit_Text2 = Fit_Text21+'+/-'+Fit_Text22
                                    
                                    
                                    Fit_Text3 = String(Format= '("Fit:",(F8.2),"(",(F6.2),") +", (F7.2),"(",(F6.2),")*Cos[",(F5.2),"(",(F4.2) ,")-X]^2" )',Fit[0],PCError[0],Fit[1],PCError[1],Fit[2],PCERROR[2]) 
                                    Fit_Text4 = String(Format= '("Reduced Chi-Sq= " ,(F7.3,X) )',Chisqr)
                                    Fit_Text5 = 'DOF ='+STRN(DOF)
                                    Print, Fit_text4

                                    ;
                                    ;So we get the shift in Cosine Squared Function, then we add 90 deg for the shift. 
                                    ;The Error is Constant*Error. For the Addition error we add in quadrature and since the constant has no error, its the same error
                                    ;
                                    
                                    File_Text1= Strn(j) +' '+ Strn(Modulation_Factor)+' '+ Strn(Modulation_Factor_er)
                                    
                                    Print, 'MOdulation factor = '+Fit_Text1
                                    
                                    
                                    Print, Fit
                                    PRint, PCError
                                    Print, Fit_Text21
                                    PRint, 180*PCERROR[2]/!PI
                                    Cursor, X_Waste, Y_Waste, /DOWN, /DEVICE
                            End 
                            Else: Print, 'INVALID CASE'
                            EndCase
                            
                  Jump_Fitted:
                  EndWhile    ; Fitted 
                  
                  ;
                  ;--- We have the fitted plots --- So we now need to get the plots.
                  ;
                  
                  ; Adding a title to the plots.
                  IF Indiv_Flag Eq True then Title2 = Title+'_MOD_'+strn(j) else Title2= Title 
                  
                  ;-- Y Max for the the plots --
                  YMAX = MAX([Final_Src, Final_Histogram])*1.3
                  
                  ;
                  ; --- Fixing Binning Problem for plotting in the middle of the bin rather than beginning.
                  ;
                  Xfit2= Xfit1+(BSize/2.0)
                  
                  ;
                  ;--- Set Plots for Ps file.
                  ;
                  Set_Plot, 'PS'
                  
                  ;--- Define the template ---
                  CgPlot,XVAL2, Final_Histogram, PSYM=10,Title=Title2,CharSize=2,$
                                XRange=[0,max_x], XStyle=1,XTickInterval=50, $
                                YRange=[0,YMAX],/NODATA,$
                                XTitle=Title_X  , YTitle='Counts'
                                    
                  ;
                  ;--- For Background or the second file ---
                  ;
                  If Back_Flag eq True Then BEgin
                        
                        ;
                        ;--- Final Scaled Background---
                        ;
                        CgOPlot, XVAL2, Final_SclBack, PSYM =10, Color=CGCOLOR('Dark Green'), $
                               Err_YHigh= Final_SclBack_ERr  ,Err_YLow= Final_SclBack_ERr , Err_Color= CGColor('Dark Green'),/ERR_CLIP
                        
                        ;
                        ;---- The Source Histogram ---
                        ;
                        CgOPlot, XVAL2, Final_Src , PSYM =10, Color=CGCOLOR('Blue'), $
                             Err_YHigh= Final_Src_Err  ,Err_YLow= Final_Src_Err , Err_Color= CGColor('Blue'),/ERR_CLIP
                        
                       
                        
                        ;
                        ;----Source/Background Total Counts 
                        ;
                        XYOUTS,!D.X_Size*0.5,!D.Y_Size*0.79, 'Src Counts    = '+STRN(TOTAL(Final_Src)),/Device, CharSize=1.5, Color=Cgcolor('Blue')
                        XYOUTS, !D.X_Size*0.5,!D.Y_Size*0.77,'SclBack Counts= '+STRN(Total(Final_SclBack)),/Device, CharSize=1.5, Color=CgColor('Dark Green')
                  EndIF
                  
                  ;
                  ;--- Plot the Data ---
                  ;
                  CgOPlot, XVAL2, Final_Histogram, PSYM =10, Color=CGColor('black'), $
                          Err_YHigh= Final_Histogram_Err  ,Err_YLow= Final_Histogram_Err , Err_Color= CGColor('Dark Gray'),/ERR_CLIP
                 
                  
                  ;
                  ;--- The fitted function ---
                  ;
                  Cgoplot, Xfit2, fitted, Color=CgColor('RED'), Thick = 2
                  
                  ;
                  ;--- For the double gaussian we need the continium and the G_Fit
                  ;
                  If F EQ 3 Then Begin
                      Cgoplot, Xfit2, G_Fit, Color=CgColor('green'), Thick= 1
                      Cgoplot, Xfit2, Continium_Fit, Color=CgColor('Pink'), Thick =1
                  EndIF
              
                  ;
                  ;--- Fit Text1 : Centroid or modulation data
                  ;
                  XYOUTS, !D.X_Size*0.5,!D.Y_Size*0.85, Fit_Text1, Color=CgColor('RED'),/DEVICE, CharSize =1.5
                  
                  ;
                  ;--- Chi Squared
                  ;
                  XYOUTS,!D.X_Size*0.5,!D.Y_Size*0.83, Fit_Text4, CharSize=1.5, Color=CgColor('red'),/DEVICE
                  
                  ;
                  ; --- Fitted Total Counts
                  ;
                  XYOUTS, !D.X_Size*0.5,!D.Y_Size*0.81, 'Total Counts   = '+STRN(TOTAL(Final_Histogram)),/Device, CharSize=1.5
                  
                                     
                  ;
                  ; -- Bin Size
                  ;
                  XYOUTS, !D.X_Size*0.7,!D.Y_Size*0.06, 'BINSIZE ='+STRN(BSIZE),/DEVICE, CHarSize=2
                  
                  ;
                  ; -- Bin Size
                  ;
                  XYOUTS, !D.X_Size*0.1,!D.Y_Size*0.06, Fit_Text5,/DEVICE, CHarSize=2
                 
                  ;
                  ;--- More Fit Text Stuffs.
                  ;
                  XYOUTS, !D.X_Size*0.2,!D.Y_Size*0.04, Fit_Text3,/DEVICE, CHarSize=1.2,Color=CgColor('Blue')
               ;   XYOUTS, !D.X_Size*0.2,!D.Y_Size*0.02, Fit_Text2,/DEVICE, CHarSize=1.2,Color=CgColor('Red')
                  
                  ;
                  ;-- Getting the data in the Text File --
                  ;
                  If Indiv_Flag EQ True Then Printf, Txt_Lun, File_text1
                  
                  ;-- Skip for individual flag --
                  If INDIV_Flag EQ False Then GOTO, SKIP_INDIV1
                  
                  Skip_INDIV2:
                  
        EndFor    ;j
        Skip_INDIV1:
        
    EndFor;i
    
    ;-- Close the Device
    Device,/Close
    
    ;-- Create the PDF File
    Temp_Str = Cur+'/'+Title+'_Hist.ps'
    CGPS2PDF, Temp_Str,delete_ps=1,Unix_Convert_cmd='pstopdf'
    Set_Plot, 'X'   
    
    ;-- Close the Text File  
    If Indiv_Flag EQ True Then Free_Lun, Txt_Lun
    
    ;
    ; ---  Getting another plot for the polarization that would zoom in and show the Polarization data--
    ;
    If (Indiv_Flag EQ False) Then Begin
    ;
    ;--- Y_MAX2
    Y_Max2 = Max(Final_Histogram)*1.25
    Temp_Title = Title
        ;---- Opening the Device for further plots and various things -----
        CgPs_Open, Title+'_Final.ps', Font =1, /LandScape
        cgLoadCT, 13
                     !P.Font=1
                  ;--- Define the template ---
                  CgPlot,XVAL2, Final_Histogram, PSYM=10,CharSize=2,$
                                XRange=[0,max_x], XStyle=1,XTickInterval=50, $
                                YRange=[0,Y_Max2],/NODATA,$
                                XTitle=Title_X  , YTitle='Counts'
                  
                  ;
                  ;--- Plot the Data ---
                  ;
                  Err_YHigh = Final_Histogram_Err
                  Err_YLow  = Final_Histogram_Err
                  CgOPlot, XVAL2, Final_Histogram, PSYM =10, Color=CGColor('black'), $
                     Err_YHigh= Err_YHigh  ,Err_YLow= Err_YLow , Err_Color= CGColor('Dark gray'),/ERR_CLIP
                  
                  ;
                  ;--- Respective Error ---
                  ;
                  ;cgErrPlot, XVal2,Final_Histogram-Final_Histogram_Err, Final_Histogram+Final_Histogram_Err, color='red'

                  ;--- The fitted function ---
                  ;
                  Cgoplot, Xfit2, fitted, Color=CgColor('RED'), Thick = 2
                  
                  
                  
                  ;
                  ; -- Bin Size
                  ;
;                  CgText, !D.X_Size*0.78,!D.Y_Size*0.00, 'BINSIZE ='+STRN(BSIZE),/DEVICE, CHarSize=2.0
                  
                  ;
                  ; --- DOF
                  ;                   
;                  cgText, !D.X_Size*0.13,!D.Y_Size*0.00, Fit_Text5,/Device, CharSize=2.0
                 
                  ;
                  ;Title
                  ;
                  cgText, !D.X_Size*0.18,!D.Y_Size*0.93, Temp_Title,/Device, CharSize=3.0
                  
                  If Type EQ 2 Then Begin
                  
                        ;
                        ;--- Fit Text1 : Centroid or modulation data
                        ;
;                        XYOUTS, !D.X_Size*0.58,!D.Y_Size*0.85, Fit_Text1, Color=CgColor('RED'),/DEVICE, CharSize =2.0

                     
                         CgText,  !D.X_Size*0.76,!D.Y_Size*0.97, CgGreek('mu') + '     =  '+Fit_Text11 +' ' +CgSymbol('+-')+' '+ Fit_Text12 , Color=CgColor('Black'),/DEVICE, CharSize =1.7
                        ;
                        ; --- Fitted Total Counts
                        ;
;                        XYOUTS, !D.X_Size*0.58,!D.Y_Size*0.81, Fit_Text4, Color=CgColor('RED'),/Device, CharSize=2.0
                        
                        ;
                        ; --- Fitted Total Counts
                        ;
 ;                       XYOUTS, !D.X_Size*0.58,!D.Y_Size*0.77, 'Total Counts   ='+STRN(TOTAL(Final_Histogram)),/Device, CharSize=2
                        
                        ;
                        ;--- More Fit Text Stuffs.
                        ;
;                        XYOUTS, !D.X_Size*0.5,!D.Y_Size*(-0.05), Fit_Text3,/DEVICE, CHarSize=1.2,Color=CgColor('Blue')
;                        XYOUTS, !D.X_Size*0.5,!D.Y_Size*(-0.08), Fit_Text2,/DEVICE, CHarSize=1.2,Color=CgColor('Red')
                          CgText, !D.X_Size*0.70,!D.Y_Size*0.93,'Pol Angle  ='+ Fit_Text21+' ' +CgSymbol('+-')+''+Fit_Text22, Color=CgColor('Black'),/Device, CharSize=1.7
                  EndIf Else BEgin
                        ;
                        ;--- Fit Text1 : Centroid or modulation data
                        ;
                        CgText,  !D.X_Size*0.70,!D.Y_Size*0.97, 'Centroid ='+Fit_Text11+CgSymbol('+-')+Fit_Text12 , Color=CgColor('Black'),/DEVICE, CharSize =1.7
                        
                        ;
                        ; --- Fitted Total Counts
                        ;
                        ;XYOUTS, !D.X_Size*0.5,!D.Y_Size*0.81, Fit_Text4, Color=CgColor('RED'),/Device, CharSize=2.0
                        
                        ;
                        ; --- Fitted Total Counts
                        ;
                        ;XYOUTS, !D.X_Size*0.5,!D.Y_Size*0.77, 'Total Counts   ='+STRN(TOTAL(Final_Histogram)),/Device, CharSize=2
                        
                        ;
                        ;--- More Fit Text Stuffs.
                        ;
                        ;XYOUTS, !D.X_Size*0.4,!D.Y_Size*(-0.05), Fit_Text3,/DEVICE, CHarSize=1.2,Color=CgColor('Blue')
                        ;XYOUTS, !D.X_Size*0.4,!D.Y_Size*(-0.08), Fit_Text2,/DEVICE, CHarSize=1.2,Color=CgColor('Red')
                        CgText, !D.X_Size*0.70,!D.Y_Size*0.93,Fit_Text2,/DEVICE, CHarSize=1.7,Color=CgColor('Black')
                  EndElse
          ;-- Close the Device
          CgPs_Close
          
          ;-- Create the PDF File
          Temp_Str = Cur+'/'+Title+'_Final.ps'
          CGPS2PDF, Temp_Str,delete_ps=1,Unix_Convert_cmd="pstopdf"
       
    EndIF
    Print, Total(Scl_Factor)/N_elements(SCl_Factor)
   ; Print, OPt_Scale, Opt_Scale/Total(Final_SclBack)
    PRint, Total(Final_Histogram), Total(Final_SclBack), Total(Final_Src)
    Stop
    
End