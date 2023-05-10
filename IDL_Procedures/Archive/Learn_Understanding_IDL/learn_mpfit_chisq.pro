Pro learn_MPfit_ChiSq
; *************************************************************************
; *                 Learn and Understand MPFit's Chi-Square               *
; *************************************************************************
; * Purpose:  Understand the MPFit's Chi-Square Calculation               *
; *           Part of Learn/Undersand IDL Documents                       *
; *                                                                       *
; *    Usage: Learn_String                                                *
; *           Learn_String, ID=#                                          *
; *                                                                       *
; *                                                                       *
; * Author: 9/17/14  Sambid Wasti                                         *
; *                  Email: Sambid.Wasti@wildcats.unh.edu                 *
; *                                                                       *
; * Revision History:                                                     *
; *                                                                       *
; *************************************************************************
; ************************************************************************* 
  ; -- Example from the document of MPFITEXPR
  
  ;---- First, generate some synthetic data -----
  x  = dindgen(200) * 0.1 - 10.                   ; Independent variable 
  yi = gauss1(x, [2.2D, 1.4, 3000.]) + 1000       ; "Ideal" Y variable
  y  = yi + randomn(seed, 200) * sqrt(yi)         ; Measured, w/ noise
  sy = sqrt(y)                                    ; Poisson errors

  ; Now fit a Gaussian to see how well we can recover
  expr = 'P[0] + GAUSS1(X, P[1:3])'               ; fitting function
  p0 = [800.D, 1.D, 1., 500.]                     ; Initial guess
  p = mpfitexpr(expr, x, y, sy, p0, nprint=0, Weights = 1/(y), bestnorm=bestnorm)               ; Fit the expression
  
  ; --- Get the fitted function in Y-Function -- 
  YFunction =  mpevalexpr(expr, x, p)
  
  ;-- Degrees of Freedom --
  DOF = N_ELEMENTS(x) - N_ELEMENTS(p0)
  
  ;
  ; -- Actual Way of calculating the Chi-Squred and finally reduced chi-squared
  ;
  CHISQ = TOTAL( (y-Yfunction)^2 * ABS(1/y) )
  red_Chisq = CHISQ/DOF
  
  ;
  ;--- The function created Chisquared value is in BESTNORM so get reduce chi-squared by
  ;
  rchisq = BESTNORM/(DOF)
    
  ;--- Now use the IDL default gaussian fit. --- 
  ;
  ; The estimates are after fitted.. the Chisquare here is a reduced chisqr.
  ;
  a = gaussfit(X,y, coeff,chisq = Chisqrr, Measure_Errors =sy, NTERMS=4, YERROR=Derr, ESTIMATES =[843,2,-1,1000])
  
   plot, x, y                                      ; Plot data
   Oplot, x, a, Color=CgColor('Blue')
   oplot,x,mpevalexpr(expr, x, p), Color=cgcolor('red')
   
   print, ' Default Gaussian=',STRN(chisqrr)
   print, ' From BESTNORM   =',STRN(rChisq)
   print, ' Calculation     =',STRN(red_Chisq)
   
   
End