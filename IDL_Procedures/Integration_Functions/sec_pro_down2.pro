
function Sec_Pro_Down2,x
  A = 0.236
  B = 2.83
  C = 0.9 ; depth/3.8 3.8 is the mizunu numbers
  func = C* A * ( x/100 )^(-B)
  return, func

end