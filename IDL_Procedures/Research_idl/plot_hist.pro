Pro Plot_Hist, File1, Title=Title, Log=Log, Fit=Fit
  ;
  ;--- Purpose is to quicklook plot a histogram from a one column  file.
  ;-- Log = Log function. Not Set yet.
  ;-- Title for the output. 
  ;-- Need a fitting function too
  ;-- Bin system.
  ;
True = 1
False = 0
  LogFlag = 0
  IF Keyword_Set(Log) NE 0 Then LogFlag=1
    IF Keyword_Set(Title) eq 0 Then Title= 'Try'
  CD, Cur = Cur


  
  ReadCol, File1,Y1, format='F'
  Y2    = cghistogram(Y1, NBIns=200, locations=X2, MAX = 2E7)
  Y2Err = Sqrt(ABS(Y2))
  X2    = X2
  
  
  Y     = (Y2[40:N_Elements(Y2)-97])
  Y_Err = (Y2Err[40:N_Elements(Y2)-97])
  X     = (X2[40:N_Elements(Y2)-97])
  
  help, X
  openw, lun99, 'hist_text.txt',/Get_lun
  for i = 0,n_elements(Y)-1 do begin
    printf,lun99, Strn(X[i]) + '  '+ Strn(Y[i])
  endfor
  free_lun, lun99
  
; N =92
; Y     = (Y2[2:N])
;  Y_Err = (Y2Err[2:N])
;  X     = (X2[2:N])

help, X, Y
  ;--- Using a Flag to get out of the while loop when done. ---
  Flag_Fitted = False
  ;
  ;==== GUI SETUP for FITTING FUNCTION ====
  ;
  window, 0
  CgPlot, X,Y, PSYM=10,  /Xlog, /Ylog;, Ystyle=1,  YRange=[10E-5, 10]
;Err_YLow=Y-Y_Err, Err_Yhigh=Y+Y_Err,Err_Color='Yellow'
  

  P0 = 50;0; Min(Y)
  P1 = 5
  P2 = -2.7
  
  Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
  Par[*].Value = [P0,P1,P2]

 ; Par[2].limited(0) = 1
  ;Par[2].limits(0)  = -2.5
 ; Par[2].limited(1) = 1
;  Par[2].limits(1)  = -1.3

  ;Par[0].fixed = 1
  
  
  
  Expr = 'P[0] + P[1] * X^(P[2])'
  ;,

  Fit = mpfitexpr(expr, X, Y, Y_Err, NPrint=20,ParInfo=Par, PError=Er, BestNorm= BEstNorm,DOF=DOF, Weights=(1/(Y_Err*Y_Err)))
 print, Fit
 Print, Er

  
  Fitted = Fit[0] + Fit[1] * X^(Fit[2])

  Cgoplot, X, fitted, Color='Red', Thick = 2

;    ; ---- Fitting Flag ----
;    While Flag_Fitted EQ False Do BEgin
;    
;
;        
;          ;--- GUI things for the Cursors----
;          Polyfill, [880,880,928, 928], [440,498,498,440], Color=CgColor('Purple'),/DEVICE
;          XYOUTS, 890, 465, 'DONE', /Device
;        
;          Polyfill, [822,822,870, 870], [440,498,498,440], Color=CgColor('ORANGE'),/DEVICE
;          XYOUTS, 832, 465, '--', COLOR=CgColor('Black'),/Device
;        
;          Polyfill, [764,764,812, 812], [473,498,498,473], Color=CgColor('ORANGE'),/DEVICE
;          XYOUTS, 772, 485, 'up', COLOR=CgColor('Black'),/Device
;        
;          Polyfill, [706,706,754, 754], [473,498,498,473], Color=CgColor('ORANGE'),/DEVICE
;          XYOUTS, 715, 485, 'P2 up', COLOR=CgColor('Black'),/Device
;        
;          Polyfill, [764,764,812, 812], [440,465,465,440], Color=CgColor('ORANGE'),/DEVICE
;          XYOUTS, 770, 450, 'down', COLOR=CgColor('Black'),/Device
;        
;          Polyfill, [706,706,754, 754], [440,465,465,440], Color=CgColor('ORANGE'),/DEVICE
;          XYOUTS, 715, 450, 'P2 down', COLOR=CgColor('Black'),/Device
;        
;        
;         
;          ; If Clicked Done
;          Cursor, X_Value, Y_Value, /DOWN, /DEVICE
;          IF( X_Value GE 880) AND ( Y_VALUE GE 440 ) Then BEgin
;            Flag_Fitted = True
;            Print, '-----------------Fitting DONE ---------------------'
;            GOTO, Jump_Fitted
;          ENDIF
;          F =0
;          ;
;          ; Grabbing a Fitting function value depending on where the user clicked.
;          ;
;          If( (X_Value GE 822) And (X_Value LE 870) AND (Y_Value GE 440) And (Y_Value LE 498) ) Then F=0 $
;          Else If( (X_Value GE 764) And (X_Value LE 812) AND (Y_Value GE 473) And (Y_Value LE 498) ) Then F=1 $
;          Else If ( (X_Value GE 706) And (X_Value LE 754) AND (Y_Value GE 473) And (Y_Value LE 498) ) Then F=2 $
;          Else If ( (X_Value GE 764) And (X_Value LE 812) AND (Y_Value GE 440) And (Y_Value LE 465) ) Then F=3 $
;          Else If ( (X_Value GE 706) And (X_Value LE 754) AND (Y_Value GE 440) And (Y_Value LE 465) ) Then F=4
;        
;          ;
;          ;-- Plotting things---
;          ;
;          Plot, X,Y, PSYM=10, /Xlog, /Ylog;, Ystyle=1,  YRange=[10E-5, 10]
;          cgErrPlot, X,Y-Y_Err, Y+Y_Err,Color='YELLOW'
;        
;          ;--
;          ;---- Defining the Fit name with the F Variable
;          ;--
;                   
;          If F EQ 0 Then Fit_Name = 'Power' Else $        ;Working
;            If F EQ 1 Then Fit_Name = '3 GAUSSIAN'Else $
;            If F EQ 2 Then Fit_Name = 'SINOSUDIAL' Else $
;            If F EQ 3 Then Fit_Name = '2 GAUSSIAN' Else $      ;Working
;            If F EQ 4 Then Fit_Name = 'SINOSUDIAL SQ'          ;Working
;
;          XYOUTS, 700, 450, Fit_Name, CharSize= 3, /DEVICE  ; Outputing what function we clicked to keep track of it.
;        
;
;
;        
;
;        
;          ;
;          ; -- Using Cases to go between the fitting function --
;          ;
;          Case F OF
;            1: Begin      ; This is the GAUSSIAN.
;                P_1 = P_1+4
;            end
;            2: Begin      ; This is the GAUSSIAN.
;              P_2 = P_2-0.01
;            end
;            3: BEgin
;                P_1 = P_1-4
;            End
;            4: Begin      ; This is the GAUSSIAN.
;              P_2 = P_2+0.01
;            end
;            Else: Print, 'INVALID CASE'
;          EndCase  
;          P0 = P_0;0; Min(Y)
;          P1 = P_1
;          Print, P1
;          P2 = P_2
;          Print, P2
;
;
;
;
;              
;              Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
;              Par[*].Value = [P0,P1,P2]
;              
;              Par[2].limited(0) = 1
;              Par[2].limits(0)  = -2.5
;              Par[2].limited(1) = 1
;              Par[2].limits(1)  = -1.3
;              
;              Expr = 'P[0] + P[1]*X^(P[2])'
;              ;,
;
;              Fit = mpfitexpr(expr, X, Y, Y_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm,DOF=DOF, Weights=(1/(Y_Err*Y_Err)))
;              print, fit
;              
;
;              Fitted = Fit[0] + Fit[1] * X^(Fit[2])
;              
;              oplot, X, fitted, Color=CgColor('RED'), Thick = 2
;        
;
;      jump_Fitted:
;      Endwhile
        
 

;Print, Fitted
;CgPs_Open, Title+'_plthist.ps', Font =1
;cgLoadCT, 13
;  CgPlot, X, Y, PSYM=10,  Thick=2,$
;      Err_YHigh=(Y_err), Err_YLow=(Y_Err), Title= Title, XTitle='Energy (keV)', YTitle='Normalized Counts (c/s)',/Ylog, /Xlog $
;      , YRange=[0,Max(Y)*1.2], YStyle=1, XRANGE= [0, Max(X)*1.1], Xstyle=1
;  CgOplot, X, Fitted, Color='Blue'
;
;  
; ; Y3= 0.0025+ 4.3*X^(-2) + Gauss1(X,[45,40,1.5])
;  ;CGOPlot, X, Y3, Color='Green'
;
;
;  Str_Main = String(Format= '("Alpha =",(F8.5,X),"(",(F8.5,X),")" )',Fit[2], Er[2])
;  
;  ;  Str_Main1 = String(Format = '( (F7.4,X), "(", (F6.4,X),") +",(F6.2,X), "(", (F5.2,X),") ^",(F5.2,X) ,"(", (F5.2,X) ,")"  )', Fit[0], Er[0],Fit[1], Er[1], Fit[2], Er[2] )
;  Str_Main1 = String(Format = '( (F6.3,X), "(", (F6.3,X),") ^",(F6.3,X) ,"(", (F6.3,X) ,")"  )', Fit[1], Er[1], Fit[2], Er[2] )
;
;  CgText, !D.X_Size*0.1,-!D.Y_Size*0.001, Str_main1 , Color=CgColor('Black'),/DEVICE, CharSize =1.2
;  CgText, !D.X_Size*0.70,!D.Y_Size*0.85, Str_main , Color=CgColor('Black'),/DEVICE, CharSize =1.5
;  CgText, !D.X_Size*0.70,-!D.Y_Size*0.001, 'Chisqr ='+STRN(BESTNORM/DOF)+'(DOF ='+STRN(DOF)+')' , Color=CgColor('Black'),/DEVICE, CharSize =1.5
; 
;  CgPs_Close
;
;  ;-- Create the PDF File
; Temp_Str = Cur+'/'+Title+'_plthist.ps'
; CGPS2PDF, Temp_Str,delete_ps=1

  Stop
End