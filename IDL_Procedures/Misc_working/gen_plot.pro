pro Gen_Plot, Title = Title
; General Plot Procedure
Title = 'sss'
b= [0.01, 0.1, 0.2, 0.5, 1, 5]

CgPs_Open, Title+'_Gen_Plot.ps', Font =1, /LandScape
cgLoadCT, 13

a = b[0]/.511
e = 1/(1+a)
x = indgen(180)*!PI/180
y = sin(x)^2/( (1/e) + e - (sin(x)^2) )

CgPlot, !radeg*x, y, Xtitle='$\theta$', Ytitle ='frac. deg. of linear polarization', $
      Xrange=[0,180], Xstyle =1, XTicks=9, Yrange=[0,1.1], Color = 'Black', Title='$\mu$ vs $\theta$ for different energies',$
      charsize=2.5 

a = b[1]/.511
e = 1/(1+a)
x = indgen(180)*!PI/180
y = sin(x)^2/( (1/e) + e - (sin(x)^2) )

CgPlot, !radeg*x, y, Xtitle='$\theta$', Ytitle ='frac. deg. of linear polarization', Xrange=[0,180], Xstyle =1, XTicks=9, Yrange=[0,1.1],/Overplot,  Color = 'Red'$
      , Title='$\mu$ vs $\theta$ for different energies',$
  charsize=2.5

a = b[2]/.511
e = 1/(1+a)
x = indgen(180)*!PI/180
y = sin(x)^2/( (1/e) + e - (sin(x)^2) )

CgPlot, !radeg*x, y, Xtitle='$\theta$', Ytitle ='frac. deg. of linear polarization', Xrange=[0,180], Xstyle =1, XTicks=9, Yrange=[0,1.1],/Overplot,  Color = 'Blue'$
      , Title='$\mu$ vs $\theta$ for different energies',$
  charsize=2.5

a = b[3]/.511
e = 1/(1+a)
x = indgen(180)*!PI/180
y = sin(x)^2/( (1/e) + e - (sin(x)^2) )

CgPlot, !radeg*x, y, Xtitle='$\theta$', Ytitle ='frac. deg. of linear polarization', Xrange=[0,180], Xstyle =1, XTicks=9, Yrange=[0,1.1],/Overplot,  Color = ' Forest Green'$
      , Title='$\mu$ vs $\theta$ for different energies',$
  charsize=2.5

a = b[4]/.511
e = 1/(1+a)
x = indgen(180)*!PI/180
y = sin(x)^2/( (1/e) + e - (sin(x)^2) )

CgPlot, !radeg*x, y, Xtitle='$\theta$', Ytitle ='frac. deg. of linear polarization', Xrange=[0,180], Xstyle =1, XTicks=9, Yrange=[0,1.1],/Overplot,  Color = 'Purple'$
      , Title='$\mu$ vs $\theta$ for different energies',$
  charsize=2.5

a = b[5]/.511
e = 1/(1+a)
x = indgen(180)*!PI/180
y = sin(x)^2/( (1/e) + e - (sin(x)^2) )

CgPlot, !radeg*x, y, Xtitle='$\theta$', Ytitle ='frac. deg. of linear polarization', Xrange=[0,180], Xstyle =1, XTicks=9, Yrange=[0,1.1],/Overplot,  Color = 'Dark Gray'$
      , Title='Modulation Factor($\mu$) vs $\theta$ for different energies',$
  charsize=2.5


CgLegend, Colors=['black','red','blue','forest green', 'purple', 'Dark Gray'], Location=[0.720, 0.85], Titles = ['10 keV', '100keV', '200keV', '500keV', '1MeV', '2Mev'],$
        Length=0.075, /Box
      ;-- Close the Device
      CgPs_Close

    ;-- Create the PDF File
    Temp_Str = Title+'_Gen_Plot.ps'
    CGPS2PDF, Temp_Str,delete_ps=1
End