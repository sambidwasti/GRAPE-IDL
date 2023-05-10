function Hem_Equation_Neb,x
  ;This should return a temporary function/equation to be integrated.
  ; Can be changed depending on the need.
  A = 2.02D*10.0D^(-2)
  Alpha = -2.09D
  func = A * (X/20.0)^(Alpha)

   return, func

end