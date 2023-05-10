
function Sec_Pro_Down1,x
A = 0.17
  B = 1.0
  C = 0.9 ; depth/3.8 3.8 is the mizunu numbers
  func = C* A * ( x/100 )^(-B)
  return, func


end