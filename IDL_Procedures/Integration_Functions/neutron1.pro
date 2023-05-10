
function Neutron1,x

  A     = 7.96E4*1000*10000      ; in counts /s /m^2 / MeVs (
 alpha  = 1

  func = A*((1000*x)^(alpha))
  return, func

end
