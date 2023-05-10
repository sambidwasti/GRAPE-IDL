function Neutron3,x

  A     = 3.023E2*1000*10000      ; in counts /s /m^2 / MeVs (
  alpha  = -1.94

  func = A*((1000*x)^(alpha))
  return, func

end