Pro Plot_Hist2, File,File1, Hist=Hist, Log=Log, title=title
  ;
  ;-- Generate a plot from a one column or two column file.
  ;-- Typically for a one column file we need to build a histogram and make it two column.
  ;-- Set that by keyword hist
  ;

  Cd, Cur=Cur
  Bin =2
  nbin = 100
  N = 100000
  If Keyword_Set(Log) NE 0 Then LogFlag=1
  If Keyword_Set(Title) EQ 0 Then Title='Try'

  If Keyword_Set(Hist) NE 0 Then HistFlag=1 Else HistFlag = 0
  
     ReadCol, File, Y1, Format='F' 
     print, n_elements(y1), total(y1)
    Y = CgHistogram(Y1,BINSIZE=BIN, LOCATIONS=XVAL1, /NAN);)
     XVal = [0.0]
    YVal = [0L]
    For i = 0, N_elements(y)-1 do begin
        If Y[i] GT 1.0 Then begin
              XVal = [XVAl,Xval1[i]]
              Yval = [YVal,Y[i]]
       Endif
    Endfor
    help, Xval
    Xval = Xval[1:N_Elements(Xval)-1]
    Yval = Yval[1:N_Elements(Yval)-1]

    
    Y1 = YVal/Bin ; per kev
    Y1_Err = Sqrt(Abs(Y1))
    
;    Y1 = Y1/N
  ;  Y1_Err = Y1_Err/N
    
    ;Y1 = Y1 *!PI* 1.2* 1.2



    A0= 0
    A1= -2.0; (alpha)
    A2=1;0000

    Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
    
    Par[0].fixed =1
    
    Par[*].Value = [A0,A1,A2]

    expr = 'P[0] + P[2]*X^(P[1])'

    Fit = mpfitexpr(expr, XVal, y1,y1_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/(y1_Err*y1_Err))

    fitted = Fit[0]+Fit[2]*Xval^(Fit[1])
   print, ER
;    window,0
;    cgplot, Xval, y1,/Xlog, /YLog, PSYM=2
;    cgoplot, XVal, fitted, Color='red', Thick= 2
 
   
    ReadCol, File1, B1,C1, Format='F,F'
    Xval2 = B1*1000 ; MEV to KEV
    C1 = C1/1000  ; change the /MEV to /KEV
    c2 = C1; /10000

    C1 = C1*!PI*1.20*1.20 ; multiplying m^2 
    C1 = C1*3.627
    C1_Err = Sqrt(C1)

    A0= 0
    A1= -2.0; (alpha)
    A2=500

    Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
    Par[0].fixed =1
    ; Par[2].limited(0) = 1
    ; Par[2].limits(0)  = 0
      ;                            Par[0].limited(0) = 1
      ;                            Par[0].limits(0)  = -Max(Hist1)
                                  
   
    Par[*].Value = [A0,A1,A2]

    expr = 'P[0] + P[2]*X^(P[1])'
;Weights=1/(C1_Err*C1_Err)
    Fit1 = mpfitexpr(expr, XVal2, C1,C1_Err, ParInfo=Par, NPRINT=0, PError=Er1, BestNorm= BEstNorm)

    fitted1 = Fit1[0]+Fit1[2]*Xval2^(Fit1[1])
    print, ER1
    
    
    scale = 15200.0d/N
    print, scale
    C1 = C1*Scale
    
    
    window,0
    cgplot, Xval2, C1,/Xlog, /YLog,  YRange=[10E-6,10E6], XRANGE=[10,1000],$
              Xtitle='MeV',Color='blue',psym=10
    cgoplot, XVal2, fitted1, Color='blue', Thick= 2
    cgoplot, Xval, y1, PSYM=10
    Cgoplot,XVal, fitted, Color='Green', Thick= 2

;  cgplot, Xval, y1, PSYM=10, /Xlog, /Ylog
;  Cgoplot,XVal, fitted, Color='Green', Thick= 2
 
 
  

;  CgPs_Open, Title+'_Final.ps', Font =1, /LandScape
;  cgLoadCT, 13
;  
;      cgplot, Xval, Y1,PSYM=2,/Xlog, /YLog, $
;            Err_YHigh = Y1_err, Err_YLow = Y1_Err,/Err_Clip
;      cgoplot, XVal, fitted, Color='green', Thick= 2
;       
;      Temp_text = Strn(Fit[0]) +'  '+  Strn(Fit[1]) +'  '+ Strn(Fit[2])
;      Temp_Text1= Strn(Er[0]) +'  '+  Strn(Er[1]) +'  '+ Strn(Er[2])
;      CgText,  !D.X_Size*0.60,!D.Y_Size*(-.010), temp_text, Color=CgColor('Black'),/DEVICE, CharSize =1.7
;       CgText,  !D.X_Size*0.60,!D.Y_Size*(-.05), temp_text1, Color=CgColor('Black'),/DEVICE, CharSize =1.7
;                  
;  CGPS_Close
;  Temp_Str = Cur+'/'+Title+'_Final.ps'
;  CGPS2PDF, Temp_Str,delete_ps=1

  DOF      = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
  Chisqr = (BESTNORM / DOF)
  help, XVal1, Y1
;print, Y1[80:99], Y1_Err[80:99]
End