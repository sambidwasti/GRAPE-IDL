function Hem_Equation_Pul,x
  ;This should return a temporary function/equation to be integrated.
  ; Can be changed depending on the need.
  A    = 2.96D * 10.0D^(-3)
  alpha = -2.00
  func = A * (X/20)^(alpha)
  return, func

end