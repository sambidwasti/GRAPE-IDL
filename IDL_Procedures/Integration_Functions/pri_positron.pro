
function Pri_Positron,x
  ; Primary Electron Function


  A     = 0.0501     ; Attenuated A
  phi   = 1199.0D   ; Solar Modulation ZePhi in MeV
  alpha = -3.3D  ; Alpha
  Mc2   = 0.511   ; Mass of positron in Mev/c^2
  RCut  = 4211.0D  ; RCut
  r     = -6.0D    ; r

  E     = x


  Rig   = Double(Sqrt( E^2 - Mc2^2))
  RE    = Double(sqrt( (E+phi)^2 - Mc2^2))     ; Rigidity = pc/ze

  unmod = A * ( (RE/1000.0D)^(alpha) )
  solmod_factor =  (E^2 - Mc2^2 ) / ( (E+ phi)^2 - Mc2^2 )
  geo_factor = 1/(1 + ((Rig/RCut)^r) )

  func = unmod*solmod_factor*geo_factor

   return, func

end