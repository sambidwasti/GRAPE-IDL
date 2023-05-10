;Plotting

pro Untitled_1
va = 2
c = 1
X = 2.0* !pi *Findgen(1000)/1000

F = Sqrt( Va*cos(x)*Va*Cos(x) + Va*Va*sin(x)*Sin(X))

g0= Sqrt(5/2 + 1/2*( Sqrt( 25-16*cos(x)*cos(x) ) ) )
g1= 4*sin(x)*cos(x)/( g0* Sqrt(25- 16*cos(x)*cos(x) ) )

h0=Sqrt(5/2 - 1/2*( Sqrt( 25-16*cos(x)*cos(x) ) ) )
h1= -1*4*sin(x)*cos(x)/( h0* Sqrt(25- 16*cos(x)*cos(x) ) )
                      Set_Plot, 'PS'
                      loadct, 13                           ; load color
                      
                      Device, File = '/Users/sam/Desktop/Psplot.ps', /COLOR,/Portrait
                      Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                                Plot, F, X, /Polar,/ISOTROPIC
                                OPlot, Sqrt(g1*g1+g0*g0), X, /Polar, Color=CgColor('green')
                                Oplot, Sqrt(h1*h1+h0*h0), X, /Polar, Color=CgColor('red')
                      Device,/Close
                      Set_Plot, 'X'
;                      
;                      

end