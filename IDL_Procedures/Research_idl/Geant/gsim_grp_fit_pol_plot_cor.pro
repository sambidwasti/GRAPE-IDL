Pro Gsim_Grp_Fit_Pol_Plot_Cor, file, title=title

ptitle = 'Scat-block Co57'
;Activity of Co57 : 12358000 cnts/s
; Flux = Act/4 piR1^2
; Fluence = Flux *area = Flux * pi R2^2
; N_real = Fluence
N_r  = 12358000.0D*(59.0D*59.0D)/(4*200.0D*200.0D)
N_s   = 1000000.0D
Scale_Factor = N_r/N_s
Print, Scale_Factor
Cd, Cur=Cur
ReadCol, file, Ang, Cnt, Err
scl_Cnt = Cnt*scale_Factor
Scl_Err = Err*scale_Factor
;Window,0
;CgPlot, Ang, Cnt, psym=10

Print, Min(Cnt), Max(Cnt)

Print
Print, Min(Scl_Cnt), Max(Scl_Cnt)


; Now Fit
Xfit1 =  2*!Pi*Ang/360 ;Change to radians
Main_Hist = Scl_Cnt
Main_Hist_err = Scl_Err
A0 = Avg(Main_Hist)
A1 = Max(Main_Hist)-Avg(Main_Hist)
A2 = 1

;=== Some constraints
Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)

;Par[1].limited(0) = 1
;Par[1].limits(0)  = Avg(Main_Hist)-Min(Main_Hist)
Par[1].limited(0) = 1
Par[1].limits(0)  = 1
;Par[1].limited(1) = 1
;Par[1].limits(1) = Max(Main_Hist)-Min(Main_HIst)+200

Par[*].Value = [A0,A1,A2]

;=== Fitting Function ===
;expr = 'P[0] + P[1]*(cos(P[2]-X))^2'
expr = 'p[0]+P[1]* cos(2*(X-P[2]))'

PRint, Main_Hist_Err
Fit = mpfitexpr(expr, Xfit1, Main_Hist, Main_Hist_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/(Main_Hist_Err*Main_Hist_Err))
print, fit, '**'
Print, Er


DOF     = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
Print, BEstNorm , ' Chi2'
XFit2 =2*!Pi*FINDGEN(360)/360
fitted = Fit[0] + Fit[1]*cos(2*(Xfit2-Fit[2]))

;Xfit1 = XFit1*360/(2*!PI)
XFit2 = XFit2*360/(2*!PI)

CgPS_Open, 'Pol_Plot_Cor.ps', Font =1, /LandScape
cgLoadCT, 13

CgPlot, Ang, Main_Hist, Psym=10,  Err_Ylow=Main_Hist_err, Err_YHigh=Main_Hist_err, XStyle=1, Xrange=[0,360], Yrange=[0,Max(Main_Hist)*1.1], title=ptitle
CgOplot, XFit2, fitted, Color=CgColor('Red')

Modulation_Factor = Float(Fit[1]/float(Fit[0]))
print, modulation_Factor

Temp_Err_3 =  Modulation_Factor*Sqrt( (PCError[0]/Fit[0])^2 + (PCError[1]/Fit[1])^2 )
;Temp_Err_2 = SQRT( PCError[1]*PCError[1] + Temp_Err_1 * Temp_Err_1 )
;;Temp_Err_3 = SQRT( ((PCError[1]/Fit[1])^2) + ((TEmp_Err_1/(Fit[1]+2*Fit[0]))^2)  )

Modulation_Factor_Er = Temp_Err_3
Print, Modulation_Factor_Er

Temp1 = String(Format='(F4.2,X)', Modulation_Factor)
Temp2 = String(Format='(F4.2,X)', Modulation_Factor_er)
Chisq = String(Format='(F6.2,X)',BestNorm)
Text1 = 'Chi='+STRN(Chisq) + '( DOF='+STRN(DOF)+')'
Rchi =  String(Format='(F6.2,X)',BestNorm/DOF)
CgText, !D.X_Size*0.7,!D.Y_Size*(0.91),'Mod='+STRN(Temp1)+' +/- ' +STRN(Temp2),/DEVICE,Color=CgColor('Black');, CHarSize=1.7
CgText, !D.X_Size*0.7,!D.Y_Size*(0),text1 ,/DEVICE,Color=CgColor('Black');, CHarSize=1.7
CgText, !D.X_Size*0.7,!D.Y_Size*(0.95),'Red Chi ='+STRN(Rchi),/DEVICE,Color=CgColor('Black');, CHarSize=1.7

CgPS_Close
Temp_Str = Cur+'/'+'Pol_Plot_Cor.ps'
CGPS2PDF, Temp_Str,delete_ps=1,UNIX_CONVERT_CMD='pstopdf'

;Chisqr = (BESTNORM / DOF)
;Fit_Text11 = String(Format= '((F5.2,X))',Modulation_Factor)
;Fit_Text12 = String(Format= '((F5.2,X))',Modulation_Factor_Er)
;Fit_Text1 = Fit_text11+'+/-'+Fit_Text12
;Fit_Text5 = Strn(Fit[0])+'+'+Strn(Fit[1])+' Cos (2(X -'+Strn(Fit[2])+') )'
;Fit_Text2 = String(Format= '((F5.2,X))',Chisqr)


End