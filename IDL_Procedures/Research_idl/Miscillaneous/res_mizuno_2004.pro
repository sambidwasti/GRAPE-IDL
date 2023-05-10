pro res_mizuno_2004
;
; Looks like a proton flux?
;

  E = 939+10.00*IndGen(10000)


  A = 23.9D       ; Constants
  phi = 1100.0D   ; Solar Modulation
  Mc2 = 938.27D   ; Mass of proton in Mev/c^2
  alpha = -2.83D  ; Alpha
  Ek = E - Mc2
  RCut = 4211  ; RCut
  r = -12

  RE = Double(sqrt( (E+phi)^2 - Mc2^2 ))     ; Rigidity = pc/ze
  Rig = Double(Sqrt( E^2 - Mc2^2))

  unmod = A * ( (RE/1000.0D)^(alpha) )
  solmod_factor =  (E^2 - Mc2^2 ) / ( (E+ phi)^2 - Mc2^2 )
  geo_factor = 1/(1 + ((Rig/RCut)^r) )

  func = unmod*solmod_factor*geo_factor

  ;print, func
  ; cgplot, Ek, geo_factor,XRANGE=[10,100000],xstyle=1
  ;  stop
  cgplot, Ek, func, /Xlog, /ylog, XRANGE=[10,100000], xstyle=1, Yrange=[1E-5,3], ystyle=1, Title= 'Reproducing Mizuno et. al Fig 2 ', Xtitle='Kinetic Energy (MeV)', Ytitle='Flux (c s^-1 m^-2 sr^-1 MeV-1)',$
    xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1

  phi1 = 650.0D
  RE1 = Double(sqrt( (E+phi1)^2 - Mc2^2) )    ; Rigidity = pc/ze

  unmod1 = A * ( (RE1/1000.0D)^(alpha) )

  solmod_factor1 =  (E^2 - Mc2^2 ) / ( (E+ phi1)^2 - Mc2^2 )

  func1 = unmod1*solmod_factor1 * geo_factor
  cgoplot, Ek, func1, /Xlog, /ylog, color='red'
end