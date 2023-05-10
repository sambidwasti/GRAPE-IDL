Pro FIGUREPLOT,Xfit, HistoData, CFit, BArray, Textfile, PosScat
; *************************************************************************
; *  Plot the respective Figure and do the Fitting and write in TextFile  *
; *************************************************************************
; *  Purpose: To Support the Readlv2V07FlightDataFiles.pro                *
; *           And plot the respective plots with errorbars                *
; *           And do the Curve Fitting as well as write in TextFile       *
; *           For the Excel file for Chisquare or Kolmogorov Test         *
; *                                                                       * 
; *  Usage: As this is procedure or function it had a limit of            *
; *           Taking in only 8 parameters so Arrays used to decrease the  *
; *           No. of parameters called in.                                *
; *           X = The X Locations or the Value of X in Histogram          *
; *           Histodata:    Respective Histogram.                         *
; *           B=[ XPos, YPos, Angle_Interval, Type ]                      * 
; *                     XPos = X Position in Multiplot of the Plot        *
; *                     YPos = Y Position in Multiplot of the Plot        *
; *                     Angle_Interval = Intervals for XTick marks        *
; *                     Type = 0 If no Type, and Type for PC and CC       *
; *           Textfile: Name of the TextFile to dump the Chi Sq Value     *
; *           PosScat:  The Flag to Set Pos Angle or Scat Angle Instrument*
; *                                                                       *
; * Author: 5/31/13   Sambid Wasti                                        *
; *                                                                       *
; * Revision History:                                                     *
; *         6/21/13   Few Standard Changes to Clean the code              *
; *                   Use of Locations in histogram to get X values of    *
; *                   Histogram Used. Commented/Used an Array to Input B  *
; *                                                                       *
; *                                                                       *
; *************************************************************************
; *************************************************************************

     ; Define Flags
     True =  1      ; True Flag as 1
     False = 0      ; False Flag as 0
          
          If PosScat EQ True Then XLABEL= ' Position Angle ' Else XLABEL= ' Scattering Angle Instrument '   ;Selects Pos or Scat Depending on Values
          
          Xpos            = BArray[0]                 ; X position of The Plot
          Ypos            = BArray[1]                 ; Y Position of the Plot  
          Angle_Interval  = BArray[2]                 ; Angle Interval in the Plot. Used 90 so see interval at 0, 90,180, 270 360
          Type            = BArray[3]                 ; Type of the Data. 0 If All.
          SweepNo         = BArray[4]
          
          Ymax = Max(HistoData)*1.5   ; Set the MAX and MiN value for The Y.                 
          Ymin = Min(HistoData)*0.85
          
          ; As we can only enter 8 parameters. Depending on XPos or YPos we get The Title. 
                If (YPOS EQ 1) Or (YPOS EQ 2) THEN P_Title=' CC ' ELSE $
                P_Title=' PC '
                
                If Type GT 0 Then P_Title = P_Title+ ' Type ' + STRN(Type) Else $
                If Type EQ 0 And YPos EQ 1 Then P_Title = P_Title +' Inter ' Else $
                P_Title = P_Title              
          
          plot, Xfit,HistoData, PSYM =10,charsize = 1.5, Xcharsize = 1,$
                XTITLE= XLABEL, YTITLE = ' No. Of Counts ', TITLE= P_Title,$
                YRANGE=[Ymin,Ymax],YSTYLE=1, XRANGE=[0,360], XSTYLE =1, XTICKINTERVAL = Angle_Interval
                
          Error = SQRT(ABS(HistoData))
                oploterr,Xfit,HistoData, Error, 1
          
          ; Output Total No. Of Events at a Certain Location Depending on XPos and YPos      
          xyouts,((Xpos-1)*!D.X_Size/Xpos)+!D.X_Size*0.15,((Ypos-1)*!D.Y_Size/(YPos+1))+ ((YPos-1)*(YPos-2)*!D.Y_Size/(YPos+9))+!D.Y_Size*0.28, 'No. Of Events ='+StrTrim(String(Total(HistoData)),1), charsize = 0.9, /DEVICE

          ;------ Now Curve Fitting
                Weights = FltARR(n_elements(HistoData))
                If CFit EQ True Then Begin
                        for i = 0,n_elements(HistoData)-1 Do  Begin                                                      
                              If HistoData[i] NE 0.0 Then Weights[i]= 1.0/HistoData[i] Else Weights[i]= 0.00
                        Endfor

                        yfitP = Total(HistoData)/(n_elements(HistoData)-1)  ; Taking average to get a starting Guess                                                 
                        A = [ 0.0, yfitP]                                   ; Starting Parameters, 0.0 Means Fix that Parameter
                                                                                                                                                                           
                        yfit = CURVEFIT(Xfit, Float(HistoData), weights, A, SIGMA,  FUNCTION_NAME='gfunct',FITA=[0,1], /NODERIVATIVE, CHISQ= chi )    ; uses Gfunct defined.                         
            
                        Y = [ A[1], A[1]]
                        oplot, INDGEN(2)*360, Y, color=cgcolor('red')                                                                                                      
                        
                        ; Print Result
                        Yout = STRING(FORMAT='("Y =",/,(F8.2,X),/, "+/- ",/,(F4.2,X))',A[1], Sigma[1])
                        Yout1 = Yout[0]+Yout[1]+Yout[2]+Yout[3]
                        xyouts,((Xpos-1)*!D.X_Size/Xpos)+!D.X_Size*0.27,((Ypos-1)*!D.Y_Size/(YPos+1))+ ((YPos-1)*(YPos-2)*!D.Y_Size/(YPos+9))+!D.Y_Size*0.09, Yout1, charsize = 0.6, /DEVICE    
                        
                        ; Print Chi Squared
                        Chisquared = STRING( FORMAT ='("Chisq =",/,(F7.2))',chi)
                        chisq = Chisquared[0]+Chisquared[1]           
                        xyouts,((Xpos-1)*!D.X_Size/Xpos)+!D.X_Size*0.27,((Ypos-1)*!D.Y_Size/(YPos+1))+ ((YPos-1)*(YPos-2)*!D.Y_Size/(YPos+9))+!D.Y_Size*0.07, chisq, charsize = 0.6, /DEVICE
                        
                        ; Dump Chi Squared in the Text File.
                        If (Xpos Eq 1) And (Ypos Eq 2) Then Begin ; CC
                              Openw, lunger, Textfile, /GET_Lun, /Append  
                                    printf, lunger, String(SweepNo), ' ', chisq    
                              Free_lun, lunger 
                        EndIF
                EndIF
                
End