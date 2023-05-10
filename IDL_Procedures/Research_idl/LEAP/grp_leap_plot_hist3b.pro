Pro Grp_leap_Plot_hist3b, Pol, UnPol,  title=title, Bin = Bin
  ;----------------------
  ; Format this properly.
  ; This is for flat
  ; Clean Coding.
  ;----------------------
  ;
  ;-Input files are generated from Flt_Plot_Hist_Mac
  ;- The Polarized and UnPolarized
  ;

  ; -- Initiation Steps --
  ; Define and read the files
  Text_title = title

  IF Keyword_Set(title) Eq 0 Then Title='Test' Else title= title
  IF Keyword_Set(Bin) Eq 0 Then Bin = 20 Else Bin = Bin
  Half_Bin = Bin/2

  ; Read the files and put into arrays
  cd, cur=cur
  REadCol, Pol, X, Pol_Cnt, Pol_Err
  ReadCol, UnPol, X1, UnPol_Cnt, UnPol_Err
  Print, X

  ;-- Scale the background
  Tot_Pol = Double( Total(Pol_Cnt) )
  Tot_UnPol = Double( Total(UnPol_Cnt) )
  Scl_Factor = Tot_Pol/Tot_UnPol

  Print, Tot_pol, Tot_UnPol
  Print, Scl_Factor

  ;Subtract the scaled
  Scl_UnPol = UnPOl_Cnt*Scl_Factor
  Scl_UnPolErr = UnPol_Err*Scl_Factor



  Main_Hist = Pol_Cnt/Scl_UnPol
  Main_Hist_Err = Main_Hist*(sqrt((Pol_Err/Pol_Cnt )^2 + ( Scl_UnPolErr/Scl_UnPol)^2   ))
  ;  window,2
  ;  CgPlot, X,Pol_Cnt, PSYM=10, XRANGE=[0,360], xstyle=1, color='blue'
  ;  CGOPlot, X, Scl_UNpol, Psym=10, color='red'
  ;  CGoPLot, X, Main_hist, psym=10

  ;ReScale the main Hist

  Scl_factor2 = Tot_Pol/total(Main_Hist)
  Main_Hist1 = Main_Hist*Scl_factor2
  Main_Hist = Main_Hist1

  Main_hist1_Err = Main_Hist_Err*Scl_Factor2
  Main_Hist_Err = Main_Hist1_Err
  Final_Histogram = Main_hist
  Final_Histogram_err=Main_hist_err
  ;  window,0
  ;  CGPLot, X, Main_hist, psym=10,XRANGE=[0,360], xstyle=1
  ; So now the X-Axis is the Angle
 
  Xfit1  = X
  P0 = Avg(final_histogram)
  P1 = 0.0

  Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 2)

  Par[0].limited(0) = 1
  Par[0].limits(0)  = 0.9*MIn(Final_Histogram)
  Par[0].limited(1) = 1
  Par[0].limits(1)  = 1.1*Max(Final_Histogram)
  Par[*].Value = [P0,P1]

  Expr = 'P[0]+P[1]*X'

  Fit = mpfitexpr(expr, Xfit1, Final_Histogram, Final_Histogram_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/(Final_Histogram_Err*Final_Histogram_Err))
  Print, Er

  DOF     = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
  PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
  Chisqr = (BESTNORM / DOF)
  Print, 'Red Chi =', Chisqr
  Print, 'Fit PCERROR'
  Print, Fit
  Print, PCERROR

  Fitted = Fit[0]+ Fit[1]*Xfit1
  OPlot, Xfit1, Fitted, Color=CgColor('red')

  Fit_Text1= String(Format= '("Slope   =" ,(F6.1,X)," +/- ",(F4.1) )',Fit[1], PCERROR[1])
  Fit_Text2= STring(Format= '("Constant=" ,(F6.1,X)," +/- ",(F4.1) )',Fit[0], PCERROR[0])
  Fit_Text3= ''
  Fit_Text4 = String(Format= '("Reduced Chi-Sq= " ,(F7.3,X) )',Chisqr)
  Fit_Text5 = 'DOF ='+STRN(DOF)
  Fit_Text11 = String(Format= '("Slope   =" ,(F6.1,X)," +/- ",(F4.1) )',Fit[1], PCERROR[1])
  Fit_Text21 =''
  Fit_Text12 =''
  Fit_Text22 =''
 ;;Oplot, XFit1, fitted, Color=CgColor('Red')

  Print, Fit
  Print, PCERROR

  Modulation_Factor = Float(Fit[1]/float(Fit[1]+2*Fit[0]))

  Temp_Err_1 = 2 * PCError[0]
  Temp_Err_2 = SQRT( PCError[1]*PCError[1] + Temp_Err_1 * Temp_Err_1 )
  Temp_Err_3 = SQRT( ((PCError[1]/Fit[1])^2) + ((TEmp_Err_1/(Fit[1]+2*Fit[0]))^2)  )

  Modulation_Factor_Er = Modulation_Factor*Temp_Err_3
  Chisqr = (BESTNORM / DOF)
  CgPlot, Xfit1, Main_Hist, PSYM=10
  CGoplot, Xfit1, Fitted, COlor='red'

  Fit_Text11a = String(Format= '((F5.2,X))',Modulation_Factor)
  Fit_Text11b = String(Format= '((F5.2,X))',Modulation_Factor_Er)
  Fit_Text1 = Fit_text11a+'+/-'+Fit_Text11b
  Fit_Text11= String( '= '+Fit_Text11a +' ' +CgSymbol('+-')+' '+ Fit_Text11b )
  print, 'wut', xfit1
  ;
  ;
  Fit_Text11 = String(Format= '((F5.2,X))',Modulation_Factor)
  Fit_Text12 = String(Format= '((F5.2,X))',Modulation_Factor_Er)
  Fit_Text1 = Fit_text11+'+/-'+Fit_Text12

  Fit_Text2 = String(Format= '((F5.2,X))',Chisqr)
  ;
  ;;  Fit_Text21 = String(Format= '("Pol Angle =" ,(F6.1,X)," +/- ",(F5.1) )',(180*Fit[2]/(!PI))+90, 180*PCERROR[2]/!PI)
  ;
  ;Fit_Text21 = String(Format= '((F6.1),X)',(180*Fit[2]/(!PI))+90)
  ;Fit_Text22 = String(Format= '((F5.1),X )', (180*PCERROR[2]/!PI))
  ;Fit_Text2 = Fit_Text21+'+/-'+Fit_Text22
  ;
  ;
  ;Fit_Text3 = String(Format= '("Fit:",(F8.2),"(",(F6.2),") +", (F7.2),"(",(F6.2),")*Cos[",(F5.2),"(",(F4.2) ,")-X]^2" )',Fit[0],PCError[0],Fit[1],PCError[1],Fit[2],PCERROR[2])
  ;Fit_Text4 = String(Format= '("Reduced Chi-Sq= " ,(F7.3,X) )',Chisqr)
  ;Fit_Text5 = 'DOF ='+STRN(DOF)
  ;Print, Fit_text4

  ;
  ;So we get the shift in Cosine Squared Function, then we add 90 deg for the shift.
  ;The Error is Constant*Error. For the Addition error we add in quadrature and since the constant has no error, its the same error
  ;
  ;
  ;File_Text1= Strn(j) +' '+ Strn(Modulation_Factor)+' '+ Strn(Modulation_Factor_er)

 ; Print, 'MOdulation factor = '+Fit_Text1
  ;
  ;
  ;Print, Fit
  ;PRint, PCError
  ;Print, Fit_Text21
  ;PRint, 180*PCERROR[2]/!PI
  ;Cursor, X_Waste, Y_Waste, /DOWN, /DEVICE
  ;color = cgPickColorName() & Print, color

  YMax = Max([Main_Hist,Pol_Cnt])*1.4
  Print, YMax
  Ymin=0
  ; Main_Err = Sqrt(Src_Err*SRc_ERr + Scl_Berr*Scl_Berr)
  ;  If Ener eq 1 then title= title+'_Ener'
  CgPs_Open, title+'_hist3b.ps', Font =1, /LandScape
  cgLoadCT, 13
  CgPlot, X, Pol_Cnt, PSYM=10, XRANGE=[0,360], XTICKINTERVAL=40, Title=' Polarized  '+ title,Ytitle=' Counts', XTitle='Angle',$
    Xstyle=1, ERr_Ylow=Pol_Err, Err_yHigh=POl_Err, /ERR_Clip, Yrange=[YMin, Ymax], Ystyle=1, Color='Blue'

  CGErase
  CgPlot, X,Scl_unPol, PSYM=10, XRANGE=[0,360], XTICKINTERVAL=40, Title='Normalized UnPolarized :'+title,Ytitle=' Counts', XTitle='Angle',$
    Xstyle=1,  ERr_Ylow=Scl_UnPolErr, Err_yHigh=Scl_UnPolErr, /ERR_Clip, Yrange=[YMin, Ymax], Ystyle=1, Color='Dark Green'

  CGErase
  CgPlot, X, Main_Hist, PSYM=10, XRANGE=[0,360], XTICKINTERVAL=40, Title='Corrected Polarized :'+ Title,Ytitle=' Counts', XTitle='Angle',$
    Xstyle=1,  ERr_Ylow=Main_Hist_Err, Err_yHigh=Main_Hist_Err, /ERR_Clip, Yrange=[YMin, Ymax], Ystyle=1

  CGoplot, Xfit1, Fitted, COlor='red'
 ; CgText,  !D.X_Size*0.6,!D.Y_Size*0.85, 'Modulation ('+CgGreek('mu')+')='+ Fit_Text1  , Color=CgColor('Black'),/DEVICE, CharSize =1.7
  CgText,  !D.X_Size*0.6,!D.Y_Size*0.85, 'Reduced Chisqr='+ Fit_Text2  , Color=CgColor('Black'),/DEVICE, CharSize =1.7

  CGErase

  CGPlot, X1, UnPol_Cnt, PSYM=10, XRANGE=[0,360], XTICKINTERVAL=40, Title='UnScaled UnPol :'+Title ,Ytitle=' Counts', XTitle='Angle',$
    Xstyle=1,  ERr_Ylow=UnPol_Err, Err_yHigh=UnPol_Err, /ERR_Clip, Ystyle=1

  CgErase
  CgPlot, X, Pol_Cnt, PSYM=10, XRANGE=[0,360], XTICKINTERVAL=40, Title='All Plots :: '+ title,Ytitle=' Counts', XTitle='Angle',$
    Xstyle=1, ERr_Ylow=Pol_Err, Err_yHigh=POl_Err, /ERR_Clip, Yrange=[YMin, Ymax], Ystyle=1, Color='Cornflower Blue'
  CgOPlot, X,Scl_unPol, PSYM=10, XRANGE=[0,360], ERr_Ylow=Scl_UnPolErr, Err_yHigh=Scl_UnPolErr, /ERR_Clip, Color='Light Sea Green'
  CgOPlot, X, Main_Hist, PSYM=10, XRANGE=[0,360],   ERr_Ylow=Main_Hist_Err, Err_yHigh=Main_Hist_Err, /ERR_Clip
  CGoplot, Xfit1, Fitted, COlor='red'

  CgLegend, Location=[0.76,1.05], Titles=['Pol','UnPol','Corrected Pol'], Length =0, $
    SymColors = ['Cornflower Blue','Light Sea Green','Black'], TColors=['red', 'blue','Black'],Psyms=[1,1,1],/box, Charsize=1.2


 ; CgText,  !D.X_Size*0.65,!D.Y_Size*0.85, 'Modulation ('+CgGreek('mu')+')='+ Fit_Text1  , Color=CgColor('Black'),/DEVICE, CharSize =1.7
  CgText,  !D.X_Size*0.65,!D.Y_Size*0.82, 'Reduced Chisqr='+ Fit_Text2  , Color=CgColor('Black'),/DEVICE, CharSize =1.7


  CgPs_Close
  Temp_Str = Cur+'/'+title+'_Hist3b.ps'
  CGPS2PDF, Temp_Str,delete_ps=1


  ; If Ener eq 1 then Text_title = Text_title+'Ener.txt' Else Text_title=Text_title+'_leap_plot_Hist2.txt'

End