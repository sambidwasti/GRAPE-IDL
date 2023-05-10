
function Temp_Equation1,x
  ;This should return a temporary function/equation to be integrated.
  ; Can be changed depending on the need.
  A     = 1     ; in counts /s /m^2 / MeVs (
  alpha  = 1

  func = A*x^(alpha)
  return, func

end
