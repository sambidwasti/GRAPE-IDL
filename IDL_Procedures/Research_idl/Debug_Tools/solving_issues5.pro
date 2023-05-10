pro solving_issues5
;
;This is printing an energy spectrum function. 
;
;
  E = 10+1.00*IndGen(4000)
  print, max(E)
  E2 = Indgen(100)*1000.0D + 4000.0D
  print, E2

  A1 = 0.17       ; Constants
  A2 = 0.236
  
  Mc2 = 0.511   ; Mass of proton in Mev/c^2
  
  alpha1 = -1.0D
  alpha2 = -2.83D  ; Alpha
  
  Ek = E - Mc2
  Ek2 = E2 - Mc2
  
  RCut = 4211  ; RCut
  
  func1 = A1 * (Ek/100)^(alpha1)
  func2 = A2 * (Ek2/1000)^(alpha2)
  
 print, max(func2)
  cgplot, Ek, func1, /Xlog, /ylog, XRANGE=[10,100000], xstyle=1, Yrange=[1E-5,3], ystyle=1, Title= 'Reproducing Mizuno et. al Fig 2 ', Xtitle='Kinetic Energy (MeV)', Ytitle='Flux (c s^-1 m^-2 sr^-1 MeV-1)'
  $,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1

 
  cgoplot, Ek2, func2, /Xlog, /ylog, color='red'
end