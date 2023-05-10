function Pri_Proton,x
; Primary Proton Function
A     = 21.75D       ; Constants
phi   = 1199.0D   ; Solar Modulation
alpha = -2.83D  ; Alpha
Mc2   = 938.27D   ; Mass of proton in Mev/c^2
RCut  = 4211.0D  ; RCut
r     = -12.0D    ; r

E     = x

Rig   = Double(Sqrt( E^2 - Mc2^2))
RE    = Double(sqrt( (E+phi)^2 - Mc2^2))     ; Rigidity = pc/ze

unmod = A * ( (RE/1000.0D)^(alpha) )

solmod_factor =  (E^2 - Mc2^2 ) / ( (E+ phi)^2 - Mc2^2 )

geo_factor = 1/(1 + ((Rig/RCut)^r) )

func = unmod*solmod_factor*geo_factor

return, func

end
