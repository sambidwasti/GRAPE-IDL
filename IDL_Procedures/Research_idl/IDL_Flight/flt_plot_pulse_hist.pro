Pro Flt_Plot_Pulse_Hist, Src_File, Back_File, BSIZE=BSIZE, Title=Title, Ener=Ener, XMAX = XMAX
; *************************************************************************
; *        Plotting Program for Flight Pulse Height Spectrum              *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read in the text files of pulse height spectrum and do a    *
; *           background subtraction, rebin, fit and generate a PS plot   *
; *           ( For only Calorimeters  )                                  *
; *                                                                       *
; * Usage:                                                                *
; *                                                                       *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *     BSize = Bin Size                                                  *
; *                                                                       *
; *     Ener = Energy trying to Fit                                       *
; *                                                                       *
; *     Xmax = maximum value of X axis we want                            *
; *                                                                       *
; *     Title = added title to the created pulse histogram files.         *
; *                                                                       *
; *     Inputs::                                                          *
; *           Src_File = Source File                                      *
; *                                                                       *
; *           Back_File = Background File                                 *
; *                                                                       *
; *     Outputs::                                                         *
; *          A pdf file with all the calorimeter plots.                   *
; *                                                                       *
; * Libraries Imported:                                                   *  
; *           -Coyote Full Library                                        *
; *           -Astronomy Full Library                                     *
; *           -MPFit Full Library. For fitting functions.                 *
; *                                                                       *
; * Files Used and thier Formats:                                         *
; *        *Phist.txt created via Flt_l1_Pulse_hist.pro                   *
; *                                                                       *
; * Author: 9/23/14  Sambid Wasti                                         *
; *                  Email: Sambid.Wasti@wildcats.unh.edu                 *
; *                                                                       *
; * Revision History:                                                     *
; *                                                                       *
; *************************************************************************
; *************************************************************************
True =1
False=0    
     
    ;
    ;==  INITIAlIZATION ==
    ;
    
    ;
    ;-- Input Parameters and KeyWords --
    ;
    
    ;
    ;-- No. of Parameters.
    ;
    If (n_params() GT 2) or (n_params() LT 1) Then Begin
          Print, 'ERROR: INVALID NO. of Parameters'
          Return
    EndIf Else Begin
          If n_params() EQ 2 Then Back_Flag= True Else Back_Flag = False
    EndElse
    
    ;
    ; -- Bin Size --
    ;
    If Keyword_Set(BSize) EQ 0 Then BSize=1
    
    ;
    ; -- Set the Max X Axis --
    ;
    If Keyword_Set(XMAX) EQ 0 Then MAX_X =200 Else MAX_X = XMAX
    
    ;
    ; -- Set the Energy Value that we are Fitting --
    ;
    If Keyword_Set(Ener) EQ 0 Then Ener=1
    
    ; 
    ;-- Title keyword + Title Manipulation --
    ;
    If Keyword_Set(Title) EQ 0 Then Title='Pulse'
    
          Title_pos_head = StrPos(Title,'*',0)
          
          If Title_pos_Head GE 2 Then Begin
                Title_Flag = True
                Title_Head1 = StrMid(title,0,Title_Pos_Head)
                Title_Head2 = StrMid(title, Title_Pos_Head+1,StrLen(Title)-title_Pos_Head)
                Title=Title_head1+'_'+Title_head2
          EndIF Else Begin
                Title_flag = False
          EndElse

          If Title_Flag EQ False Then begin
                IF StrLen(Title) GT 20 Then Begin
                      Title_Flag = True
                      Title_Head1 = StrMid(title,0,20)
                      Title_Head2 = StrMid(title,21,StrLen(Title)-21)
                EndIf Else Title_Head1 = Title
          EndiF 
    
    ;
    ;--- Current Directory
    ;
    CD, Cur = Cur    
     
    ;
    ;-- Variables / Arrays and Structures --
    ;
    
    ;
    ;-- Calorimeter element anode ids (0..63)
    ;
    cal_anodes = [0,1,2,3,4,5,6,7,8,15,16,23,24,31,32,39,40,47,48,55,56,57,58,59,60,61,62,63]
    
    ;
    ;-- Plastic element anode Ids (0..63)
    ;
    pls_anodes = [9,10,11,12,13,14,17,18,19,20,21,22,25,26,27,28,29,30,33,34,35,36,37,38,41, $
        42,43,44,45,46,49,50,51,52,53,54]
    
    ;
    ;-- module Serial no. w.r.t Module position defined by array location.
    ;
    module_serno = [20,0,22,4,2,0,3,18,0,21,5,6,23,7,8,0,0,9,10,1,11,12,26,0,13,15,0,16,19,25,0,27]       
    
    ;
    ;-- Few Arrays --
    ;
    
    ;-- File Titles
    File_title = STRARR(2)
    
    ;-- Module Position
    ModPos = StrARR(2)
    
    ;-- Number of Files for each file--
    No_Files = IntArr(2)
    
    ;
    ;================ END INITIALIZATION ====================
    ;
    
    
    ;
    ;================ DATA ACCUMULATION =======================
    ;

          
    ;
    ;--- GRAB DATA FROM EACH FILE ---
    ;
    For p=0,1 Do Begin
          
          ;
          ; -- Defining the Source or Background File
          ;
          If p eq 0 Then Fname=Src_File Else Begin
                If Back_Flag Eq False THen Goto, Jump_File
                Fname=Back_File
          EndElse
          
          ;
          ;-- Read the File Name --
          ;
          Openr, Lun, Fname, /Get_Lun
          Data =''
          Readf, lun, Data  ; Title
          Pos0 = StrPos(Data, ' ', 2)
          File_Title[p] = StrMid(Data, 0, Pos0)
          
          ;
          ;-- Grab the Module Position Number      
          ;
          Readf, lun, Data  
          Pos0 = StrPos(Data,'=',0)
          ModPos[p] = Strmid(Data,Pos0+1,StrLen(Data)-Pos0)
          
          ;
          ;-- Number of Files(EVT) involved
          ;
          ReadF, Lun, Data    
          Pos0 = StrPos(Data,'=',0)
          No_Files[p] = Strmid(Data,Pos0+1,StrLen(Data)-Pos0)
          
          ;
          ; -- Total Time Ran--
          ;
          ReadF, Lun, Data    
          Pos0 = StrPos(Data,'=',0)
          Time_Ran = Double(Strmid(Data,Pos0+1,StrLen(Data)-Pos0))
          If p eq 0 Then Src_time = Time_Ran Else Back_Time = Time_Ran
          
          ;
          ; -- Average Live Time --      
          ;
          ReadF, Lun, Data  
          Pos0 = StrPos(Data,'=',0)
          Avg_LT = Double(Strmid(Data,Pos0+1,StrLen(Data)-Pos0))
          If p eq 0 Then Src_LT = Avg_LT Else Back_LT = Avg_LT
          
          ;
          ;-- Define the Temp Array for data to get stored. Also assuming that the max pulse height value that can be read is 1024.
          ;
          Temp_Arr = LonArr(64,1024)
          
          ;
          ;-- Read the whole ASCII Text file.
          ;
          While Not EOF(LUN) Do BEgin
                
                ;
                ;-- read in the line--
                ;
                ReadF, Lun, Data
                
                ;
                ;-- Skip few lines if not the header 'Anode='
                ;
                IF STRMID(Data,0,5) EQ 'Anode' Then BEgin
                    ;
                    ;-- Extract the anode no.
                    ;
                    Pos0 = StrPos(Data,'=',0)
                    anode = FIX(Strmid(Data,Pos0+1,StrLen(Data)-Pos0))
                    
                    ;
                    ;-- Extract and grab the pulse height spectrum information.
                    ;
                    Readf, LUn, Data
                    
                    ;
                    ;-- For each pulse height value
                    ;
                    Pos0 = 0
                    For i = 0, 1023 Do Begin
                          ;
                          ;-- Since each value for the 1024 channels are separated by a ' '
                          ;
                          Pos1 = StrPos(Data,' ',Pos0)
                          Temp_Val = LOnG(Strmid(Data,Pos0,Pos1-Pos0))
                          
                          ;
                          ;-- This is not necessary but just in case.
                          ; 
                          If Temp_Val NE 0 Then Temp_arr[Anode,i] = Temp_Val
                          
                          Pos0=Pos1+1
                    EndFor ;i
                    
                EndIf ; Anode

          EndWhile; Ending While.. So end of file.
          
          ;
          ;-- Store the Temp Array to Source or Background Array.
          ;
          If P Eq 0 then Src_Hist = Temp_Arr Else Back_Hist = Temp_Arr
          
          ;
          Free_Lun, Lun 
          ;
          Jump_File:
    EndFor ;p
    
    ;
    ; === Data Accumulated ===
    ; 
    
    
    ;
    ; === Data Processing ( Rebinning and Scaling ) ===
    ;
    
    ;
    ; -- Double Checking if Source and Back-Ground are of the same module.
    ;
    IF Back_Flag EQ True Then Begin
          If ModPos[0] NE ModPos[1] then Begin
              Print, 'ERROR :: Two Different Modules for Background and Source.. '
              Return
          EndIF
    ENDIF
    
    ;
    ;-- Rebinning --
    ;
          
          ;
          ;-- Defining No. of Bins
          ;
          N_Bins = 1024/BSize 
          
          ;
          ;--- More Array Defined ---
          ;
          Re_Src_Hist     = LonArr(64,N_Bins)
          Scaled_Hist   = DblArr(64,N_Bins)
          Scaled_Back   = DblArr(64,N_Bins)
          
          Scaled_HistErr= DblArr(64,N_Bins)
          Scaled_BackErr= DblArr(64,N_Bins)
          
          ;
          ;--- Rebinning the Source Histogram--
          ;
          
          ; 
          ;-- For Each Anode
          ;
          For M =0,63 Do Begin    
              
              ;-- Counter--
              Temp_Count =0L        
              
              ;
              ;-- Standard rebining --
              ;
              For i = 0,N_Bins-1 Do Begin
                  
                  Temp_Val =0.0
                  
                  For j=0, BSize-1 Do Begin
                           Temp_Val = Src_Hist[M,Temp_Count]+Temp_Val
                           Temp_Count++
                  EndFor;j
                  
                  Re_Src_Hist[M,i]=Temp_Val
                  
              EndFor ; i
          
          EndFor; M
          
          ;
          ;-- The Error Histogram --
          ;
          Temp_Err_Hist= Sqrt(ABS(Double(Re_Src_Hist)))
          
          ;
          ;--- Rebinning and scaling the second/background file to the Source File
          ;
          If Back_Flag Eq True Then Begin
              
              ;
              ;--- Rebin For Background ---
              ;
              
              ;
              ;-- Additional Array --
              ;
              Temp_Hist1 = LonArr(64,N_Bins)
              
              ;
              ;-- For Each Anode
              ;
              For M =0,63 Do Begin     
                    
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
              
              ;
              ;-- Error Histogram
              ;
              Temp_Err_Hist1= Sqrt(Abs(Double(Temp_Hist1)))
              
              ;
              ;--- Background Rebinning Done ---
              ;
              
              ;
              ; -- Scaling and Normalizing the background to the source --
              ; 
              For M=0,63 Do Begin
                      
                      ;
                      ;-- Skipping the Modules not in the 2014 Configuration --
                      ;
                      If (Where(M EQ cal_anodes) NE -1) Then Begin
                            
                            ;
                            ;--- Grab a Scale Factor ---
                            ;
                            Scl_Factor = Src_Time* Src_LT/(Back_LT*Back_Time)
                            
                            ;
                            ;-- Get a Scaled Background Array ---
                            ;
                            Scaled_Back[M,*]= Scl_Factor* Temp_Hist1[M,*]
                            
                            ;
                            ;-- Subtract the scaled Background From the Source to ge a Scaled Hist --
                            ;
                            Scaled_Hist[M,*]= Re_Src_Hist[M,*]-Scaled_Back[M,*]
                            
                            ;
                            ;-- Scaled Background Error-- via proper propagation.
                            ;
                            Scaled_BackErr[M,*]= Scl_Factor* Temp_Err_Hist1[M,*]
                            
                            ;
                            ;-- Adding the errors in quadrature so squaring each errors.
                            ;
                            TempArrErr1 = Scaled_BackErr[M,*] * Scaled_BackErr[M,*]
                            TempArrERr2 = Temp_Err_Hist[M,*] * Temp_Err_Hist[M,*]
                            
                            ;
                            ;-- Finishing the final Error.
                            ;
                            Scaled_HistErr[M,*]= SQRT( TempArrErr2 + TempArrErr1 )
                      
                      EndIF
              
              EndFor; /M
          
          EndIf Else Begin  ; BackFlag Stuff.
                    Scaled_Hist = Re_Src_Hist
                    Scaled_HistErr = Temp_Err_Hist
          EndElse
    
    ;
    ; === Data Processed ( Rebinned and Rescaled ) ===
    ;  
    
    
    ;
    ; === OutPut / Resuts.. Fits and TextFiles ==
    ; 
    
          
          ;
          ;-- Few Variables Defined for proper plots
          ;
          
          ;-- X Values --
          XVAL = INDGEN(N_Bins)*BSIZE 
          
          ;-- Correcting the bins for the plots --
          XVAL2 = XVAL+(BSize/2.0)
          
          ;-- Min and Max X values.
          XMAX = MAX(XVAL)
          XMIN = MIN(XVAL)
          
          ;
          ; Now do the fits
          ;
       
          ;
          ;-- For the Text file with Fitting Parameters
          ;
          Openw, Text_Lun, Cur+'/'+Title+'_FitPar.txt', /Get_Lun
              
              ;
              ;-- Few Print Statements at the begining of the file --
              ;
              Printf, Text_Lun, 'Fitting for Energy ='+Strn(Ener)
              Printf, Text_Lun, 'Module Position No ='+Strn(ModPos)
              Printf, Text_Lun, 'Module Serial No   ='+Strn(Module_serno[Fix(ModPos[0])])
              Printf, Text_Lun, 'FitParams= A0 + Gauss1(A1(Centroid),A2(Sigma),A3(Area))
              Printf, Text_Lun, 'Anode Energy A0 A0Err A1 A1Err A2 A2Err A3 A3Err' 
          
          ;
          ;---- Set Up the Device for PS file.-----
          ;
          Set_Plot, 'PS'
              loadct, 13                           ; load color
              Device, File = Cur+'/'+Title+'_Flt_PHist.ps', /COLOR,/Portrait
              Device, /inches, xsize = 8.0, ysize = 7.0, xoffset = 0.01, yoffset = 2.0, font_size = 9, scale_factor = 1.0

          ;
          ;-- Few Counters and Values Defined Here.
          ;
          
          Plot_Counter =0
          YCounter=0
          Xtext =0
          
          ;
          ;-- For Each of the Anodes.
          ;
          For a = 0, 63 Do Begin
                
                ;
                ; Since we are moving between Set_plots 'PS' and 'X' and the usage of cursors. This might look confusing
                ; but it works fine as it is now. Any changes should be verified for the plots and set plot options.
                ;
                !P.MULTI=0
                Set_Plot, 'X'
                
                ;
                ;-- Only work for Calorimeters. 
                ;
                If (Where(a EQ cal_anodes) NE -1) Then Begin
                      
                      ;
                      ;-- Grab the histogram file to be fitted for this calorimeter.
                      ;
                      Final_Histogram = Scaled_Hist[a,*]
                      
                      ;
                      ;-- Grab the respective Error Histogram
                      ;
                      Final_Histogram_Err = Scaled_HistErr[a,*]
                      
                      ;
                      ;--- DEFINE YMAX
                      ;
                      YMAX= Max(Final_Histogram)*1.3
                      
                      ;
                      ;-- Plot the data get the GUI for fitting.
                      ;
                      Plot, XVAL,Final_Histogram, PSYM=10, YRange=[0,YMAX],XRANGE=[0,MAx_X], XStyle=1
                      cgErrPlot, XVal,Final_Histogram-Final_Histogram_Err, Final_Histogram+Final_Histogram_Err,Color='Steel Blue'
                      
                      ;
                      ;-- Print the Module working on. --
                      ;
                      XYOUTS, 100 , 460, 'Mod='+(MODPOS[0]), CHarSize = 3, /DEVICE
                      
                      ;
                      ;-- Print the Anode that we are currently working on.
                      ;
                      XYOUTS, 300 , 460, 'Anode='+Strn(a), CHarSize = 3, /DEVICE
                      
                      ;
                      ;-- Define a flag to define the Fitting being done. ---
                      ;
                      Flag_Fitted = False
                      
                      ;
                      ;-- Define the Fitting Variable
                      ;
                      F=0
                      
                      ;
                      ;-- Define the Fit_Text2 variable
                      ;
                      File_text2='0'
                      
                      ;
                      ;========== SET UP THE GUI ============
                      ;
                      
                      ;
                      ;-- Loop until fitted --
                      ;
                      While Flag_Fitted EQ False Do BEgin
                            
                            ;
                            ;--- Starting to get the Rectangular boxes and the Words there.----
                            ;
                            
                            ;
                            ;-- Done --
                            ;
                            Polyfill, [880,880,928, 928], [440,498,498,440], Color=CgColor('Purple'),/DEVICE
                            XYOUTS, 890, 465, 'DONE', /Device
                            
                            ;
                            ;-- Gauss --
                            ;
                            Polyfill, [822,822,870, 870], [440,498,498,440], Color=CgColor('ORANGE'),/DEVICE
                            XYOUTS, 832, 465, 'GAUSS', COLOR=CgColor('Black'),/Device
                            
                            ;
                            ;-- 3Gauss --
                            ;
                            Polyfill, [764,764,812, 812], [473,498,498,473], Color=CgColor('ORANGE'),/DEVICE
                            XYOUTS, 772, 485, '3GAUSS', COLOR=CgColor('Black'),/Device
                            
                            ;
                            ;-- Sino --
                            ;
                            Polyfill, [706,706,754, 754], [473,498,498,473], Color=CgColor('ORANGE'),/DEVICE
                            XYOUTS, 715, 485, 'SINO', COLOR=CgColor('Black'),/Device
                            
                            ;
                            ;-- 2Gauss --
                            ;
                            Polyfill, [764,764,812, 812], [440,465,465,440], Color=CgColor('ORANGE'),/DEVICE
                            XYOUTS, 770, 450, '2GAUSS', COLOR=CgColor('Black'),/Device
                            
                            ;
                            ;-- No-Fit --
                            ;
                            Polyfill, [706,706,754, 754], [440,465,465,440], Color=CgColor('ORANGE'),/DEVICE
                            XYOUTS, 715, 450, 'No-Fit', COLOR=CgColor('Black'),/Device
                            
                            ;
                            ;-- File Text : Text to be written on the fit parameter text file.
                            ;
                            File_text1=   Strn(a)+' '+File_Text2
                            
                            ;
                            ;-- If Clicked No-Fit then no need to click Done.--
                            ;
                            If F NE 4 Then Cursor, X_Value, Y_Value, /DOWN, /DEVICE Else Begin
                                X_Value = 881 
                                Y_Value = 441
                            ENDELSE
                            
                            ;
                            ;-- Click Done if fitted --
                            ;
                            If( X_Value GE 880) and ( Y_VALUE GE 440 ) Then Begin
                                
                                ;
                                ;-- Change the flag to get out of the loop.
                                ;
                                Flag_Fitted = True
                                
                                Print, '-----------------Fitting DONE ---------------------'
                                
                                ;
                                ;-- Reset the Fit value --
                                ;
                                F = 0
                                
                                ;
                                ;-- Jump Fitted --
                                ;
                                Goto, Jump_Fitted
                                
                            EndIf
                            
                            ;
                            ;-- Grabbing a Fitting function value depending on where the user clicked--
                            ;
                            If( (X_Value GE 822) And (X_Value LE 870) AND (Y_Value GE 440) And (Y_Value LE 498) ) Then F=0 $
                            Else If( (X_Value GE 764) And (X_Value LE 812) AND (Y_Value GE 473) And (Y_Value LE 498) ) Then F=1 $
                            Else If ( (X_Value GE 706) And (X_Value LE 754) AND (Y_Value GE 473) And (Y_Value LE 498) ) Then F=2 $ 
                            Else If ( (X_Value GE 764) And (X_Value LE 812) AND (Y_Value GE 440) And (Y_Value LE 465) ) Then F=3 $
                            Else If ( (X_Value GE 706) And (X_Value LE 754) AND (Y_Value GE 440) And (Y_Value LE 465) ) Then F=4 
                            
                            ;
                            ;-- No Fits for Sino-Plot, 3 gaussian so defaults back to gaussian.
                            ;
                            If (F EQ 2) OR (F EQ 1) Then F = 0
                            
                            ;
                            ;-- Special case for no-fit
                            ;
                            If F Eq 4 Then Goto, Skip_Select_Data
                            
                            ;
                            ;-- Plotting things again for an actual fit this time.---
                            ;
                            Plot, XVAL,Final_Histogram, PSYM=10, YRange=[0,Max(Final_Histogram)*1.3],XRANGE=[0,MAx_X], XStyle=1
                            cgErrPlot, XVal,Final_Histogram-Final_Histogram_Err, Final_Histogram+Final_Histogram_Err,Color='Steel Blue'
                            
                            ;
                            ;-- Defining the Fit name 
                            ;
                            If F EQ 0 Then Fit_Name = 'GAUSSIAN' Else $        ;Working
                            If F EQ 1 Then Fit_Name = '3 GAUSSIAN'Else $ 
                            If F EQ 2 Then Fit_Name = 'SINOSUDIAL' Else $
                            If F EQ 3 Then Fit_Name = '2 GAUSSIAN' Else $      ;Working
                            If F EQ 4 Then Fit_Name = 'No-Fitting'             ;Working
                            
                            ;
                            ;--- Print the Fitting Function for sanity check.
                            ;
                            XYOUTS, 750, 400, Fit_Name, CharSize= 3, /DEVICE  ; Outputing what function we clicked to keep track of it.
                            
                            ;
                            ;-- Get the Module Position and print it out.
                            ;
                            XYOUTS, 100 , 460, 'Mod='+(MODPOS[0]), CHarSize = 3, /DEVICE
                            
                            ;
                            ;-- Get the Anode Position and print it out.
                            ;
                            XYOUTS, 300 , 460, 'Anode='+Strn(a), CHarSize = 3, /DEVICE
                            
                            ;
                            ; === Selecting the Data using the screen coordinates == (Different for different MAcs)
                            ;
                            
                            ;
                            ;-- The plotting area has the X range of 60~882, getting the intercept and slope for the conversion. 
                            ;
                            C_Slope = Float( (Max_X-XMIN)/Float(882)) 
                            C_Range = Float( (C_Slope*60)-XMIN)
                            
                            ;
                            ;--- Here Comes the Cursor Stuffs
                            ;
                            
                            ;
                            ;--- Min Channel ---
                            ;
                            Cursor, X_Value0, Y_Value0, /DOWN, /DEVICE
                            min_Chan_Val = Float(X_Value0*C_Slope-c_Range)
                            min_Chan= FIX(min_Chan_Val/BSIZE)
                            PolyFill, [X_Value0,X_Value0,X_Value0+1, X_Value0+1],[Y_Value0-1000,Y_Value0+1000,Y_Value0+1000, Y_Value0-1000], Color=CgColor('Yellow'),/Device
                            Print, ' Min Channel = ' + Strn(min_Chan_Val)
                            
                            ;
                            ;--- Max Channel ---            
                            ;
                            Cursor, X_Value1, Y_Value1, /DOWN, /DEVICE
                            max_Chan_Val = Float(X_Value1*C_Slope-c_Range)
                            max_Chan= FIX(max_Chan_Val/BSIZE)
                            PolyFill, [X_Value1,X_Value1,X_Value1+1, X_Value1+1],[Y_Value1-1000,Y_Value1+1000,Y_Value1+1000, Y_Value1-1000], Color=CgColor('Yellow'),/Device
                            Print, ' Max Channel = ' + Strn(max_Chan_Val)
                            
                            ;
                            ; -- Peak Position
                            ;
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
                            
                            ;
                            ; -- Using Cases to go between the fitting function --
                            ;
                            Skip_Select_Data:
                            Case F OF
                            0: Begin      ; This is the GAUSSIAN fit.
                                    
                                    ; Initial Parameter Values
                                    P0 = 0.0
                                    P1 = Peak_Chan_Val
                                    P2 = 15
                                    P3 = Final_Histogram[peak_Chan]*5
                                    
                                    Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
                                    
                                    ; Setting Parameter Boundaries.
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
                                    
                                    ; Fitting
                                    Fit = mpfitexpr(expr, Xfit1, Hist1, Hist1_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=(1/(Hist1_Err*Hist1_Err)))
                                    
                                    ;Gaussian Fit
                                    G_Fit = Gauss1(Xfit1, Fit[1:3])
                                    
                                    Fitted =G_Fit
                                    Continium_Fit = 0*Xfit1
                                    
                                    Print, FIT
                                    FWHM = 2 * Sqrt(2*Alog(2))* Fit[2]
                                    XYOUTS,500,460, 'FWHM ='+Strn(FWHM), /DEVICE , CharSize = 1.5
                                    XYOUTS,500,480, 'Centroid =' +Strn(Fit[1]), /DEvice, CharSize = 1.5
                                    
                                    oplot, Xfit1, fitted, Color=CgColor('RED'), Thick = 2
                                    OPlot, Xfit1, Continium_fit, Color = CgColor('Blue'), Thick =2
                                    DOF      = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
                                    PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
                                    Chisqr = (BESTNORM / DOF)
                                    
                                    
                                    Print, PCERROR
                                    Fit_Text1= String(Format= '("Centroid =" ,(F7.3,X)," +/- ",(F6.3) )',Fit[1], PCERROR[1])
                                    Fit_Text2= STring(Format= '("FWHM =",(F7.3,X))',FWHM)
                                    Fit_Text3= String(Format= '("Gaussian : {",(F7.3,X),"(",(F6.3,X),"), ",(F7.3,X),"(",(F6.3,X),"), ",(F12.3,X),"(",(F10.3,X),") }" )' ,Fit[1],PCERROR[1],Fit[2],PCError[2],Fit[3],PCError[3])
                                    Fit_Text4 = String(Format= '("Red Chi-Sq= " ,(F5.3,X)," (DOF:",(I3),")" )',Chisqr,DOF)
                                 
                                    
                                    Print, Fit_text4
                                    File_text2=STRN(ENER)+' '+ Strn(Fit[0])+' '+Strn(PCError[0] ) +' '+ Strn(Fit[1])+' '+Strn(PCError[1] )+ $
                                                                       ' '+ Strn(Fit[2])+' '+Strn(PCError[2] ) +' '+ Strn(Fit[3])+' '+Strn(PCError[3] )
                                                  
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
                                    XYOUTS,500,470, 'FWHM ='+Strn(FWHM), /DEVICE
                                    XYOUTS,500,480, 'Centroid =' +Strn(Fit[1]), /DEvice
                                    
                                    oplot, Xfit1, G_Fit, Color=CgColor('green'), Thick= 1
                                    oplot, Xfit1, fitted, Color=CgColor('RED'), Thick = 3
                                    oplot, Xfit1, Continium_Fit, Color=CgColor('Pink'), Thick =1
                                    
                                    DOF      = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
                                    PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
                                    Chisqr = (BESTNORM / DOF)
                                    
                                    
                                    Print, Fit
                                    Print, PCERROR
                                    
                                    
                                    Fit_Text1= String(Format= '("Centroid =" ,(F7.3,X)," +/- ",(F6.3) )',Fit[1], PCERROR[1])
                                    Fit_Text2= STring(Format= '("FWHM =",(F7.3,X))',FWHM)
                                    Fit_Text3= String(Format= '("Gaussian1: ",(F7.3,X),"(",(F6.3,X),"),",(F7.3,X),"(",(F6.3,X),"),",(F12.3,X),"(",(F10.3,X),")}")' ,Fit[1],PCERROR[1],Fit[2],PCError[2],Fit[3],PCError[3])
                                    Fit_Text4 = String(Format= '("Red Chi-Sq= " ,(F5.3,X)," (DOF:",(I3),")" )',Chisqr,DOF)
                                    
                                    Print, Fit_text4
                                    
                                    File_text2= +STRN(ENER)+' '+ Strn(Fit[0])+' '+Strn(PCError[0] ) +' '+ Strn(Fit[1])+' '+Strn(PCError[1] )+ $
                                                                       ' '+ Strn(Fit[2])+' '+Strn(PCError[2] ) +' '+ Strn(Fit[3])+' '+Strn(PCError[3] )

                            End
                            4: Begin ; No-Fits.
                                    Fitted = 0 * Xfit1
                                    Continium_Fit = 0*Xfit1
                                    Fit_Text1 = 'No-Fit'
                                    Fit_Text2 = ''      
                                    Fit_Text4 = ''
                                    
                                    File_text2 = '0'                                    
                            End 
                            Else: Print, 'INVALID CASE'
                            EndCase
                            ;
                            ;-- Ending The Case --
                            ;
                            
                  Jump_Fitted:
                  EndWhile    
                  ;
                  ;-- Function Fitted -- 
                  ;
                  
                  
                  
                  ;
                  ;==== The OutPut File ====
                  ;
                  
                  ;- Set Plot to Post Script --
                  Set_Plot, 'PS'
                  
                  ;
                  ;--- The Plot is set for 6 plots in a page. We need different positions to plot
                  ;
                  Plot_Pos =  (Plot_Counter mod 6)
                  IF Plot_Pos NE 0 Then Plot_Pos=6-Plot_Pos
                  
                  ;
                  ;--- We also need different positon to enter the texts.
                  ;
                  If Xtext EQ 1 then YCounter++
                  XText = (Plot_Counter mod 2)
                  Ytext = 2 - (YCounter mod 3)
                  YPos= Ytext * 1.2  +1
                  XPos= XText * 1.88+1
                  
                  ;
                  ;-- Title for each plots
                  ;
                  Title1 = 'Anode '+Strn(a)
                  
                  ;
                  ;-- Set up the 2 X 3 Plots --
                  ;
                  !P.Multi=[Plot_Pos,2,3]
                  
                  ;
                  ;-- Correcting one of the binning issue --
                  ;
                  Xfit2= Xfit1+(BSize/2.0)
                  
                  ;
                  ;-- Set the Plotting Template --
                  ;
                  Plot, XVAL2,Final_Histogram, PSYM=10, YRange=[0,Max(Final_Histogram)*1.2],XRANGE=[0,MAx_X], XStyle=1, Title=Title1 $
                                            ,/NODATA, YSTYLE=1, XTitle='Pulse', YTitle='Counts', CharSize=2
                  
                  ;
                  ;-- Plotting the histogram --
                  ;
                  CgOplot, XVAL2,Final_Histogram, PSYM=10
                  
                  ;
                  ;-- Plot the Error --
                  ;
                  cgErrPlot, XVal2,Final_Histogram-Final_Histogram_Err, Final_Histogram+Final_Histogram_Err,Color='Steel Blue'
                  
                  ;
                  ;-- Plot the Fitting function
                  ;
                  CGOplot, Xfit2, Fitted, Color=CgColor('red')
                  
                  ;
                  ;--- For the double gaussian we need the continium and the G_Fit
                  ;
                  If F EQ 3 Then Begin
                                Cgoplot, Xfit2, G_Fit, Color=CgColor('green'), Thick= 1
                                Cgoplot, Xfit2, Continium_Fit, Color=CgColor('Orange'), Thick =1
                  EndIF
                  
                  ;
                  ;--- Some Each Plot Text Outputs ----
                  ;
                      ;
                      ; -- Centroid --
                      ;
                      XYOUTS, !D.X_Size*0.26*XPos,!D.Y_Size*0.28*YPos, Fit_Text1,/DEVICE, CharSize=0.9
                      
                      ;
                      ; -- Reduced Chi-Sqr and DOF --
                      ; 
                      XYOUTS, !D.X_Size*(0.26*XPos),!D.Y_Size*((0.28*YPos)-0.015), Fit_Text4,/DEVICE, CharSize=0.9
                      
                      ;
                      ; -- FWHM --
                      ;
                      XYOUTS, !D.X_Size*(0.265*XPos+0.12),!D.Y_Size*((0.28*YPos)-0.265), Fit_Text2,/DEVICE, CharSize=0.9
                      
                      ;
                      ; -- Total Counts of the Final Histogram --
                      ;
                      XYOUTS, !D.X_Size*(0.265*XPos-0.18),!D.Y_Size*((0.28*YPos)-0.265), 'Counts  = '+Strn(Round(Total(Final_Histogram))), CharSize =0.9, /DEVICE
                      
                  ;
                  ;--- Some Per Page Titles, headers and footers.
                  ;
                  
                      ;
                      ; -- Module Position --
                      ;
                      XYOUTS, !D.X_Size*0.4,!D.Y_Size*1.12, 'Module '+ModPos[0], Color=CgColor('Black'),/DEVICE, CharSize =5.0
                      
                      ;
                      ; -- Module Serial No. --      
                      ;
                      XYOUTS, !D.X_Size*0.45,!D.Y_Size*1.07, '(FM 1'+STRN(Module_Serno[Fix(ModPos[0])]) +')', Color=CgColor('Black'),/DEVICE, CharSize =3.5
                      
                      ;
                      ;-- Bin-Size --
                      ;
                      XYOUTS, !D.X_Size*0.75,!D.Y_Size*1.07, 'Bin Size = '+Strn(Bsize), Color=CgColor('Black'),/DEVICE, CharSize =2.5
                      
                      ;
                      ;-- Title we want present somewhere in the plot.
                      ;
                      XYOUTS, !D.X_Size*0.1,!D.Y_Size*1.07,Title_Head1 , Color=CgColor('Black'),/DEVICE, CharSize =2.5
                            If Title_Flag Eq True Then XYOUTS, !D.X_Size*0.1,!D.Y_Size*1.02,Title_Head2 , Color=CgColor('Black'),/DEVICE, CharSize =2.5
                      
                      ;
                      ;-- Energy Currently Fitting --
                      ;
                      If Ener NE 1 Then XYOUTS, !D.X_Size*0.75,!D.Y_Size*1.02,'Ener = '+STRN(ENER)+'kev' , Color=CgColor('Black'),/DEVICE, CharSize =2.5
                      
                      ;
                      ;-- Name of the Source File and No. of files present.
                      ;
                            XYOUTS, !D.X_Size*0.1,-!D.Y_Size*0.03, 'SrcFile = '+Strn(File_title[0]), Color=CgColor('Black'),/DEVICE, CharSize =1.7
                            XYOUTS, !D.X_Size*0.8,-!D.Y_Size*0.03, 'No.Files = '+Strn(No_Files[0]), Color=CgColor('Black'),/DEVICE, CharSize =1.7
                      
                      ;
                      ;-- Background File name and no. of files.     
                      ;
                      If Back_Flag Eq true Then Begin
                            XYOUTS, !D.X_Size*0.1,-!D.Y_Size*0.06, 'BackFile = '+Strn(File_title[1]), Color=CgColor('Black'),/DEVICE, CharSize =1.7
                            XYOUTS, !D.X_Size*0.8,-!D.Y_Size*0.06, 'No.Files = '+Strn(No_Files[1]), Color=CgColor('Black'),/DEVICE, CharSize =1.7
                      EndIf
                      
                      ;
                      ;-- Write in the Text file the Fitting Parameters.
                      ;
                      Printf, Text_Lun, File_Text1 
                      
                      Plot_Counter++
            EndIf ; If its a cal...  
                       
       EndFor ;a 
       
       ;
       ;-- Close the Device
       ;
       Device,/Close
        
       ;
       ; -- Free the Text Lunger   
       ;
       Free_Lun, Text_Lun
       
       ;
       ;-- Create the PDF File from the Post Script File
       ;
       Temp_Str = Cur+'/'+Title+'_Flt_PHist.ps'
       CGPS2PDF, Temp_Str,delete_ps=1
       Set_Plot, 'X'  
       
End