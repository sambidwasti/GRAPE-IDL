function Neutron2,x

  A     = 2.4E-3*1000*10000      ; in counts /s /m^2 / MeVs (
  alpha  = -0.88

  func = A*((1000*x)^(alpha))
  return, func

end