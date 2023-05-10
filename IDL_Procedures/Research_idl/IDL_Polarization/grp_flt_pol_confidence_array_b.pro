Pro Grp_Flt_Pol_Confidence_array_b, infile

  ; mu 100 from crab is 0.41 =/- 0.01
  ;NOTE : HERE C1 is fixed. for mu to be fixed go to version.
  Readcol, infile, Xval1, Main_Hist, Main_Hist_err, format='F,F,F'

  Pol_array = Double(Indgen(101))/(100.00) ; 0-100 Current 1 points
  pol_angle_arr =Double( indgen(361)); 0-360; 36 deg bin
  ChiSqArray = DblArr(n_elements(Pol_Angle_Arr),n_elements(Pol_Array))
  ;
  CgPlot, Xval1, Main_Hist


  Xfit1 = 2*!Pi*Xval1/360


  A0 = Avg(Main_Hist)
  A1 = Max(Main_Hist)-Avg(Main_Hist)
  A2 = 1
  ;=== Some constraints
  Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
  Par[*].Value = [A0,A1,A2]
  Par[1].limited(0) = 1
  Par[1].limits(0)  = 1
  expr = 'p[0]+P[1]* cos(2*(X-P[2]))'
  Fit = mpfitexpr(expr, Xfit1, Main_Hist, Main_Hist_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/(Main_Hist_Err*Main_Hist_Err), Yfit=yfit)
  XFit2 =2*!Pi*FINDGEN(360)/360
  fitted = Fit[0] + Fit[1]*cos(2*(Xfit2-Fit[2]))
  fitted1 = Fit[0] + XFit2*0.0

  XFit2 = XFit2*360/(2*!PI)
  DOF     = N_ELEMENTS(XFit1) - N_ELEMENTS(Par)
  Chisqr = BestNorm
  angle = fit[2]*180/!Pi
  Print, 'angle =',angle
  Print, 'Pol angle -', angle+90
  Print, 'mod=',Fit[1]/Fit[0]
  Print, 'pol=',Fit[1]/(Fit[0]*0.41)

  Cgplot, Xval1, Main_Hist, PSYM=10, xrange=[0,360], Err_YHigh=Main_Hist_Err, Err_YLow=Main_Hist_Err
  CGoplot, Xfit2, Fitted, COlor='red'
  CGoplot, Xfit2, Fitted1, COlor='green'

  ;print, fit
  ;Print, '-----------'
  ;Print, Yfit
  ;Print, '----'
  ;=== Confidence plot ==
  ; The modulation factor is Fit[1]/Fit[0] so fixing Fit[0]
  ; C1 = 409.41553
  ; All we need angle from 0-2pi, chisqr and the mu.
  ; u 100 is 0.41 +/- 0.01
  ; C3 +pi/2 = pol angle in radians
  ; So C3 = (pol-90)*pi/180 (for pol in angle)

  C2 = Fit[1]
  mu100 = 0.41

  ;Print, Pol_Array
  ;Print, C1, Fit[1], Fit[1]/C1
  ;Print, Pol_array
  C1_array = C2 /( mu100 * Pol_Array)
  C3_angle_arr = (pol_angle_arr-90)*!pi/180

  For i =0, n_elements(C3_angle_arr)-1 do begin
    For j =0, n_elements(Pol_Array)-1 do begin
      C3 = C3_angle_arr[i];Fit[2];
      C1 = C1_array[j];Fit[1];
      ; Print, '7777'
      ;Print, C3
      ;Print, C3_angle_arr

      ; Print, C2
      ;; PRint, C2_Array
      ; the contour values should be for nparam 1 and 2

      Model_array = C1 + C2 * cos(2*(Xfit1-C3))

      ;  Print, '---'
      ;  Print, Model_Array
      ; Print, '---'

      ; Now Calculate the chi Square
      Chi_Sq_Val  =0.0
      For k = 0, n_elements(Main_Hist)-1 Do begin

        T_Val = (Main_HIst[k]-Model_array[k])^2/(Main_Hist_err[k]*Main_Hist_err[k])
        Chi_Sq_Val =  Chi_Sq_Val+T_Val

      Endfor

      ; Print, CHi_SQ_Val, BestNorm
      ChiSqArray[i,j] = Chi_Sq_Val
    EndFor
  endfor

  ;Print, ChiSqArray, Pol_Array, Pol

  ;Change Angle to Deg
  Deg_Arr = Pol_Angle_Arr;*360.0D/(2*!pi)
  ;print, pol_angle_arr
  ;== Plot Contour==
  ;chi = BestNorm
  ; For 2 DOF, the del Ch values are
  delX_array = [2.28, 5.99, 9.21]

  LevelsArray =delX_array + chisqr;+chi
  window,2
  CgContour, ChiSqArray , Deg_Arr, Pol_Array, xrange=[0,360],xstyle=1,Levels=LevelsArray, Xtitle= 'Polarization Angle', Ytitle ='Polarization Fraction',Title ='Confidence Plot of del Chi-Sq (Constant C1)',$
    C_annotation=['  68%  ','  95%  ','  99%  ']
  CgOplot,angle+90, Fit[1]/(Fit[0]*0.41),PSYM=1, SymSize=5.0, Color='Red'


end