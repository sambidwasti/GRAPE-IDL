Pro Gsim_Spec_Gen_Flux_fit, infile
  ;
  ; This is a modifi ation of Gsim_Spec_Gen_Flux
  ; THis only takes in 1 file of the energy column and bins it and plots it.
  ; It can further fit it. 

; Read the file
  ReadCol, infile,Ener2,format='D' ; this is the output energy file

; Histogram the input energies
  bsize = 5
  flux2 = CgHistogram(Ener2,locations=Xarr,binsize=bsize, /NAN)
  flux2 = flux2/bsize

; Fit it
  P0 = -12.83
  P1 = 1E7
  P2 = 2.2
  Expr = 'P[0] + P[1]*X^(-P[2])'
  
  Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
  
 ; par[0].fixed = 1
  
  
;  Par[2].limited(1) = 1
 ; Par[2].limits(1)  = -2.0

  Par[*].Value = [P0,P1,P2]
  flux2_Err = Sqrt(abs(flux2))
  Fit = mpfitexpr(expr, Xarr, flux2, flux2_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=(1/(flux2)))

 ;   Fit = mpfitexpr(expr, Xarr, flux2, flux2_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm)
    print, Er
  Fit2 = Fit[0]+Fit[1]*Xarr^(-Fit[2])


Fit3 = 1E8* Xarr^(-2.2)

; Plot it
  window, 2
  CgPlot, Xarr, Flux2, /Xlog, /ylog, Xtitle='Energy (MEV)',PSYM=10
  CGoPlot, Xarr, Fit2, /Xlog, /Ylog, Color='green'
 ; CGOplot, Xarr, Fit3, /Xlog, /Ylog, Color='red'
  
 ; Cgoplot,Xarr, flux2, /Xlog, /ylog , Color='red', PSYM=10

  ;Print, Ener, Flux1


End