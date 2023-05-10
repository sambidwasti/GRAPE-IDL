Pro Cal_Tool_Read_Sim_Data, Input_File, BIN=BIN, comp=comp, title=title
; *************************************************************************
; *           Tool to Read the Histogram Data Points from Sims            *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read the Histogram points generated from the simulation for *
; *           various manipulation or for fitting.                        * 
; *                                                                       *
; * Usage:                                                                *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *     Inputs::                                                          *
; *           Input_File: The file of just 1 value on each line which is  *
; *                       the histogram value                             *
; *                       Camden Ba133 data shows two keV bins            *
; *                                                                       *
; *           Bin : No. of values per Bin. If Not Defined Bin=1           *
; *                                                                       *
; *                                                                       *
; *           Comp: Computer no. 1 for Laptop (Default), 2 for Astro8     *
; *                                                                       *
; *     Outputs::                                                         *
; *           Fitted Plot. Can be modified for anything.                  *
; *                                                                       *
; * Author: 11/19/13  Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; *                                                                       *
; *                                                                       *
; * NOTE:    This Can do Fitting like Cal_Plots.pro but right now just a  *
; *          gaussian fit                                                 *
; *                                                                       *
; * 03/19/20   Sambid Wasti                                               *
; *           The fitting screen is adjusted to older screen.             *
; *           So creating a keyword that chooses computer (laptop or Desk-*
; *           top which fixes the pixels and window for calibration.      *
; *           - Also fixed some mac ps2pdf to pstopdf for the ghostscript *
; *             Error.                                                    *
; *                                                                       *
; *************************************************************************
; *************************************************************************
True=1
False=0

      If Keyword_Set(bin) EQ 0 Then bin = 1
      If Keyword_Set(comp) EQ 0 Then comp = 1; Comp1 = Laptop
      If Keyword_Set(title) EQ 0 Then title='Ba133'

      If comp eq 2 then begin
      Print, ' THE WINDOW GUI CUSTOMIZED FOR ASTRO 8'
      PIX0    = 60
      PIXMax  = 942
      PIY0    = 40
      PIYMax  = 510
      EndIf Else begin
      Print, ' THE WINDOW GUI CUSTOMIZED FOR SAM-MBP'
      PIX0    = 60
      PIXMax  = 702
      PIY0    = 40
      PIYMax  = 420
      EndElse
        
        

      Cd, Cur=Cur
      ; Read the file and get the values in an array.
      Openr, Lun, Input_File, /Get_Lun
      Data = ''
      
      Counter=0L
      Rows_File = File_Lines(Input_File)
      YVal=LONArr(Rows_File)
      
      While Not EOF(Lun) DO Begin
            ReadF, Lun, Data
            If Data NE '' Then BEgin
                  Temp_Value= FIX(Data)
                  YVal[Counter] = Temp_Value
                  Counter++
            EndIF
      EndWhile
      Free_Lun, Lun

      XVal=INDGEN(Rows_File)*BIN
      Plot, XVal, YVal, PSYM=10
      Cursor, X_Value4, Y_Value4, /Down, /Device
      
      ; == Now I want to do a Fit to this Plot ==
      ; Most Probably Double Gaussian..
      F=3
      Fit_Name=''
      Flag_Fitted = False
      While Flag_Fitted EQ False Do BEgin
              Print, ' Choose a Fitting Function to Fit or click on DONE'
            
              ; This is a change of X Cursor point to Channel value conversion.
              C_Slope = Float( (XVal[Rows_File-1]+BIN)/Float(PIXMax-PIX0))  ; Since binning starts at 0, we have 498 instead of 500 for 250th bin
              C_Range = Float( C_Slope*PIX0)
              YMax = max(YVal)
             
              ; Gives the effect of Buttons present in the Plot Window. 
              Polyfill, [PiXMax-62,PiXMax-62,PiXMax-14, PiXMax-14], [PiYMax-70,PiYMax-12,PiYMax-12,PiYMax-70], Color=CgColor('Purple'),/DEVICE
              XYOUTS, PiXMax-52, PiYMax-45, 'DONE', /Device
              
            ;  Polyfill, [822,822,870, 870], [440,498,498,440], Color=CgColor('ORANGE'),/DEVICE
            Polyfill, [PiXMax-120,PiXMax-120,PiXMax-72, PiXMax-72], [PiYMax-70,PiYMax-12,PiYMax-12,PiYMax-70], Color=CgColor('ORANGE'),/DEVICE
                              XYOUTS, PiXMax-110, PiYMax-45, '-0-', COLOR=CgColor('Black'),/Device
         
                              Polyfill, [PiXMax-178,PiXMax-178,PiXMax-130, PiXMax-130], [PiYMax-37,PiYMax-12,PiYMax-12,PiYMax-37], Color=CgColor('ORANGE'),/DEVICE
                              XYOUTS, PiXMax-170, PiYMax-25, '-1-', COLOR=CgColor('Black'),/Device
                              
                              Polyfill, [PiXMax-236,PiXMax-236,PiXMax-188, PiXMax-188], [PiYMax-37,PiYMax-12,PiYMax-12,PiYMax-37], Color=CgColor('ORANGE'),/DEVICE
                              XYOUTS, PiXMax-227, PiYMax-25, '-2-', COLOR=CgColor('Black'),/Device
                              
                              Polyfill, [PiXMax-178,PiXMax-178,PiXMax-130, PiXMax-130], [PiYMax-70,PiYMax-45,PiYMax-45,PiYMax-70], Color=CgColor('ORANGE'),/DEVICE
                              XYOUTS, PiXMax-172, PiYMax-60, '2 Gauss', COLOR=CgColor('Black'),/Device
                              
                              Polyfill, [PiXMax-236,PiXMax-236,PiXMax-188, PiXMax-188], [PiYMax-70,PiYMax-45,PiYMax-45,PiYMax-70], Color=CgColor('ORANGE'),/DEVICE
                              XYOUTS, PiXMax-227,PiYMax-60, 'GAUSS', COLOR=CgColor('Black'),/Device
                              
                              ; If Clicked Done
                              Cursor, X_Value, Y_Value, /DOWN, /DEVICE
                              IF( X_Value GE (PiXMax-62)) AND ( Y_VALUE GE (PiYMax-70)) Then BEgin
                                      Flag_Fitted = True
                                      Print, '-----------------Fitted ( Moving On )---------------------'
                                      GOTO, JUMP_Fitted
                              ENDIF
                              
                              ; Let that Variable Be F, If not selected a function, It defaults to Exponential.
                              If( (X_Value GE PiXMax-120) And (X_Value LE PiXMax-14) AND (Y_Value GE PiYMax-70) And (Y_Value LE PiYMax-12) ) Then F=0 $
                              Else If( (X_Value GE PiXMax-178) And (X_Value LE PiXMax-130) AND (Y_Value GE PiYMax-37) And (Y_Value LE PiYMax-12) ) Then F=1 $
                              Else If ( (X_Value GE PiXMax-236) And (X_Value LE PiXMax-188) AND (Y_Value GE PiYMax-37) And (Y_Value LE PiYMax-12) ) Then F=2 $ 
                              Else If ( (X_Value GE PiXMax-178) And (X_Value LE PiXMax-130) AND (Y_Value GE PiYMax-70) And (Y_Value LE PiYMax-45) ) Then F=3 $
                              Else If ( (X_Value GE PiXMax-236) And (X_Value LE PiXMax-188) AND (Y_Value GE PiYMax-70) And (Y_Value LE PiYMax-45) ) Then F=4 
                              
                     ;         Plot, XVal, YVal, PSYM=10, YRANGE=[0,YMax], YSTYLE=1

                              If F EQ 0 Then Fit_Name = '-1-' Else $
                                   If F EQ 1 Then Fit_Name = '-2-'Else $
                                        If F EQ 2 Then Fit_Name = '-3-' Else $
                                             If F EQ 3 Then Fit_Name = 'Double Gaussian' Else $
                                                    If F EQ 4 Then Fit_Name = 'Gaussian'
                                                  
                              Plot, XVal, YVal, PSYM=10
                             
                              XYOUTS, PiXMax-210, PiYMax-60, Fit_Name, CharSize= 2.5, /DEVICE  ; Outputing what function we clicked to keep track of it.
                              
                              ; Using Cursor to Find the Minimum channel of Data selected
                              Cursor, X_Value0, Y_Value0, /DOWN, /DEVICE
                              Print,X_Value0, Y_Value0
                              min_Chan_Val = Float(X_Value0*C_Slope-c_Range)
                              min_Chan= FIX(min_Chan_Val/BIN)
                              PolyFill, [X_Value0,X_Value0,X_Value0+1, X_Value0+1],[Y_Value-1000,Y_Value+1000,Y_Value+1000, Y_Value-1000], Color=CgColor('Yellow'),/Device
                              Print, ' Min Channel = ' + Strn(min_Chan_Val)
                           
                              ; Using Cursor to Find the Maximum channel of Data selected
                              Print, ' Click For Maximum '
                              Cursor, X_Value1, Y_Value1,  /DOWN, /DEVICE
                              Print,X_Value1, Y_Value1
                              max_Chan_Val= Float(X_Value1*C_Slope-c_Range)
                              Max_Chan=     Fix(max_Chan_Val/BIN)
                              PolyFill, [X_Value1,X_Value1,X_Value1+1, X_Value1+1],[Y_Value1-1000,Y_Value1+1000,Y_Value1+1000, Y_Value1-1000], Color=CgColor('Yellow'),/Device
                              Print, ' Max Channel =' + Strn(max_Chan_Val)
            
                              ; Using Cursor to Get the Initial starting position for the Peak position.
                              Print, ' Click For Starting PEAK position '
                              Cursor, X_Value2, Y_Value2, /Down, /DEVICE
                              Peak_Chan_Val = Float(X_Value2*C_Slope-c_Range)
                              Peak_Chan = FIX(Peak_Chan_Val/BIN) 
                              PolyFill, [X_Value2-2,X_Value2-1,X_Value2+1, X_Value2+1],[Y_Value2-5,Y_Value2+5,Y_Value2+5, Y_Value2-5], Color=CgColor('Orange'),/Device
                              Print, ' Peak Channel =' + STrn(PEak_Chan_Val)
                           
                              ; Just a check to have the option of selecting max Chan first( Swapping Min and Max Channel )
                              If Min_Chan GT Max_Chan Then BEgin
                                      Temp_A= Min_Chan
                                      Min_Chan = Max_Chan
                                      Max_Chan = Temp_A
                              EndIf
                              Hist_Err = Sqrt(YVal)
                              Hist1     = Yval(min_Chan:Max_Chan)
                              Xfit1     = XVal(min_Chan:Max_Chan)
                              Hist1_Err = Hist_Err(min_Chan:Max_Chan)                              
                              ;================== FITTING Function Now after Selection==============
                              Case F OF
                                    0: BEGIN ; This is for the Exponential.
                                            F=3
                                            Goto,Jump_Gaussian
                                       END
                                    1: BEGIN ; This is for QUADRATIC
                                            F=3
                                            Goto,Jump_Gaussian
                                       END
                                    2: Begin ; Polyfit  Polymeric Continium
                                           F=3
                                            Goto,Jump_Gaussian
                                       End 
                                    3: Begin ; Double Gaussian.
                                      Hist = YVal
                                      ; Using Cursor to Get the Initial starting position for the Peak position.
                                      Print, ' Click For 2nd Starting PEAK position '
                                      Cursor, X_Value3, Y_Value3, /Down, /DEVICE
                                      Peak_Chan_Val2 = Float(X_Value3*C_Slope-c_Range)
                                      Peak_Chan2 = FIX(Peak_Chan_Val2/BIN)
                                      PolyFill, [X_Value3-2,X_Value3-1,X_Value3+1, X_Value3+1],[Y_Value3-5,Y_Value3+5,Y_Value3+5, Y_Value3-5], Color=CgColor('Orange'),/Device
                                      Print, ' Peak Channel 2 =' + STrn(PEak_Chan_Val2)
                                      P0 = 0L
                                      P1 = Peak_Chan_Val
                                      P2 = 15
                                      P3 = Hist[peak_Chan]*5
                                      P4 = Peak_Chan_Val2
                                      P5 = 15
                                      P6 = Hist[peak_Chan2]*5


                                      Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 7)
                                    ;  print, Total_Counts
                                      Par[0].limited(1) = 1
                                      Par[0].limits(1)  = Hist(Peak_Chan)
                                      Par[0].limited(0) = 1
                                      Par[0].limits(0)  = -Max(Hist1)
                                      Par[0].fixed=1

                                      Par[1].limited(0) = 1
                                      Par[1].limits(0)  = Peak_Chan_Val-20
                                      Par[1].limited(1) = 1
                                      Par[1].limits(1)  = Peak_Chan_Val+20

                                      Par[2].limited(0) = 1
                                      Par[2].limits(0)  = 1.0

                                      Par[3].limited(0) = 1
                                      Par[3].limits(0)  = 1.0
                                      ;                                                Par[3].limited(1) = 1
                                      ;                                                Par[3].limits(1)  = 2*Total_Counts
                                      ;

                                      Par[4].limited(1) = 1
                                      Par[4].limits(1)  = Peak_Chan_Val2+40

                                      Par[5].Limited(0) = 1
                                      Par[5].limits(0)  = 1.0

                                      Par[6].limited(0) = 1
                                      Par[6].limits(0)  = 1.0
                                      ;                                                Par[6].limited(1) = 1
                                      ;                                                Par[6].limits(1)  = 2*Total_Counts

                                      Par[*].Value = [P0,P1,P2,P3,P4,P5,P6]

                                      Expr = 'P[0] + Gauss1(X, P[4:6]) + Gauss1(X,P[1:3] )'

                                      Print, Hist1_err
                                      Fit = mpfitexpr(expr, Xfit1, Hist1, Hist1_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=(1/(Hist1_Err*Hist1_Err)))

                                      G_Fit = Gauss1(Xfit1, Fit[1:3])
                                      G_Fit1= Gauss1(Xval, Fit[1:3])

                                      G_Fit2 = Gauss1(Xfit1, Fit[4:6])
                                      Continium_Fit = Fit[0]+ G_Fit2

                                      Fitted = Continium_Fit+ G_Fit

                                      oplot, Xfit1, G_Fit, Color=CgColor('green'), Thick= 1
                                      oplot, Xfit1, fitted, Color=CgColor('RED'), Thick = 3
                                      oplot, Xfit1, Continium_Fit, Color=CgColor('Pink'), Thick =1

                                      DOF      = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
                                      PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
                                      FWHM = 2 * Sqrt(2*Alog(2))* Fit[2]
                                      Chisqr = (BESTNORM / DOF)

                                      XYOUTS,300,470, 'FWHM ='+Strn(FWHM), /DEVICE
                                      XYOUTS,300,480, 'Centroid =' +Strn(Fit[1]), /DEvice
                                      XYOUTS,300,460, 'Red Chisq ='+Strn(Chisqr), /Device
                                      ;
                                      ;==== Creating a String of Fitted Parameters and Errors ===
                                      ;

                                      Temp_Str =Strn(F) + '  '
                                      For i = 0,3 Do begin
                                        Temp_FitOut= String(Format='(D10.3,X)', Fit[i])
                                        Temp_PCERror= String(Format='(D11.4,X)', PCERROR[i])
                                        Temp_Str = TEmp_Str+ '   '+Temp_FitOut+ '   '+Temp_PCERROR
                                      Endfor

                                      Temp_FitOut= String(Format='(D15.3,X)', Fit[4])
                                      Temp_PCERror= String(Format='(D16.4,X)', PCERROR[4])
                                      Temp_Str = TEmp_Str+ '   '+Temp_FitOut+ '   '+Temp_PCERROR

                                      For i = 5,N_Elements(Fit)-1 Do Begin
                                        Temp_FitOut= String(Format='(D10.3,X)', Fit[i])
                                        Temp_PCERror= String(Format='(D11.4,X)', PCERROR[i])
                                        Temp_Str = TEmp_Str+ '   '+Temp_FitOut+ '   '+Temp_PCERROR
                                      EndFor

                                      Print, Temp_Str

                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                       End
                                    4: Begin ; Gaussian Fit 
                                    Jump_Gaussian:
                                                P0 = 0
                                                P1 = Peak_Chan_Val
                                                P2 = 15
                                                P3 = YVal[peak_Chan]*5
                                                
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
                                                
                                                Fit = mpfitexpr(expr, Xfit1, Hist1, Hist1_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=(1/Hist1_Err))
                                                
                                                G_Fit = Gauss1(xfit1, Fit[1:3])
                                                G_Fit1= Gauss1(Xval, Fit[1:3])
                                                                                            
                                                Fitted =G_Fit
                                                Continium_Fit = 0*XVal
                                                
                                                FWHM = 2 * Sqrt(2*Alog(2))* Fit[2]
                                                XYOUTS,300,470, 'FWHM ='+Strn(FWHM), /DEVICE
                                                XYOUTS,300,480, 'Centroid =' +Strn(Fit[1]), /DEvice
                                                
                                                oplot, Xfit1, fitted, Color=CgColor('RED'), Thick = 2
                                                
                                                DOF      = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
                                                PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
                                                
                                                Temp_Str =Strn(F) + '  '
                                                For i = 0,N_Elements(Fit)-1 Do begin
                                                    Temp_FitOut= String(Format='(D10.3,X)', Fit[i])  
                                                    Temp_PCERror= String(Format='(D11.4,X)', PCERROR[i])  
                                                    Temp_Str = TEmp_Str+ '   '+Temp_FitOut+ '   '+Temp_PCERROR
                                                Endfor
                                                Print, Temp_Str
                                                
                                        End
                                 ELSE: Print, ' Invalid Case '
                              
                              EndCase
                              Jump_Fitted:
                       EndWhile   
                        
          Channel_wanted = 1.1775*Fit[2]+Fit[1]
          Error_Chan = Sqrt(PCerror[1]*PCerror[1]+PCerror[2]*PCerror[2])
          
      
          CgPS_Open,Cur+'/'+title+'cal_tool_sim_data.ps', Font =1, /LandScape
          cgLoadCT, 13
                       ; load color
                  Temp_Str0= ' ';'Ba133'
                  Temp_Str4= String(Format= '("Centroid =" ,(F7.3,X)," +/- ",(F6.3) )',Fit[1], PCERROR[1])
                  Temp_Str1= String(Format='("FWHM    ="(F7.3))',FWHM)
                  Temp_Str2= String(Format='("Half-Height=",(F7.3,X)," +/- ",(F6.3) )',Channel_Wanted, Error_Chan)
                  Temp_Str3= String(Format= '("Sigma =" ,(F7.3,X)," +/- ",(F6.3) )',Fit[2], PCERROR[2])
                  CgPlot, XVal,YVal, PSYM=10, Title= 'Sim-Data Ba-133 ', XTitle='Energy', YTitle = 'Counts', CharSize= 2,YRANGE=[0,YMax], YSTYLE=1
                  
                                
                             ;   if F eq 4 then begin
                                  CgOplot, Xval, g_Fit1, Color=CgColor('green'), Thick=1.5

                              ;  endif Else CgOplot, Xfit1, g_Fit, Color=CgColor('green'), Thick=1.5
                               
                                Cgoplot, Xfit1, fitted, Color=CgColor('RED'), Thick=2
                                if f eq 3 then Cgoplot, Xfit1, g_Fit2, Color=CgColor('Blue'), Thick=1.5
                               
                               CgText,!D.X_Size*0.2,!D.Y_Size*0.97, Temp_Str0, CharSize=2.5,/Device
                                
                                CgText,!D.X_Size*0.66,!D.Y_Size*0.86, Temp_Str4, CharSize=1.5,/DEvice
                                CgText,!D.X_Size*0.66,!D.Y_Size*0.83, Temp_Str3, CharSize=1.5,/DEvice
                                CgText,!D.X_Size*0.66,!D.Y_Size*0.80, Temp_Str2, CharSize=1.5,/DEvice
                                CgText,!D.X_Size*0.66,!D.Y_Size*0.77, Temp_Str1, CharSize=1.5,/DEvice
                                
;                                CgErase 
;                                CgPlot, XVal,YVal, PSYM=10, Title= 'Sim-Data Ba-133', XTitle='Energy', YTitle = 'Counts', CharSize= 2,YRANGE=[0,YMax], YSTYLE=1
               
          CgPS_Close
          Temp_Str = Cur+'/'+title+'cal_tool_sim_data.ps'
          If Comp eq 2 then CGPS2PDF, Temp_Str,delete_ps=1, unix_convert_cmd='pstopdf' Else CGPS2PDF, Temp_Str,delete_ps=1

                      
End