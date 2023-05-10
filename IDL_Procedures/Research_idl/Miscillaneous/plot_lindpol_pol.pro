Pro Plot_LinDPol_Pol


  Ener = 100.0D ;kev
  ; Need array of radians from 0-Pi
  No_points = 100
  TArr = FIndGen(No_points)/No_Points*360.0D
  Xfit1 = Tarr*2*!PI/(360.0D)
  mc2 = 511.0D ;kEV


  E0 = Ener
  denom = 1.0D + (E0/mc2)*(1-cos(Xfit1))
  Epsilon = 1/denom
  
  denom1 = Epsilon + Epsilon^(-1) - 2*sin(Xfit1)*cos(double(!PI/2.0D))
  numer1 = 1- sin(xfit1)^2*cos(!PI/2.0D)^2
  Lin_100 = 2*numer1 / denom1

  cd, cur=cur
  CgPS_Open,'KN_LinearDeg_Pol.ps', Font =1, /LandScape
  cgLoadCT, 13

  CgPlot, Tarr, Lin_100, Xrange=[0,180], xstyle =1, $
    ytitle= 'Degree of Linear Polarization', Xtitle= 'Compton Scatter Angle (Deg)', XtickInterval=30

  ;
  ;500kev
  Ener=500.0
  E0 = Ener
  denom = 1.0D + (E0/mc2)*(1-cos(Xfit1))
  Epsilon = 1/denom
  denom1 = Epsilon + Epsilon^(-1) - 2*sin(Xfit1)*cos(double(!PI/2.0D))
  numer1 = 1- sin(xfit1)^2*cos(!PI/2.0D)^2
  Lin_500 = 2*numer1 / denom1

  CgOPlot, Tarr, Lin_500, linestyle=5

  ;
  ;100kev
  Ener=1000.0
  E0 = Ener
  denom = 1.0D + (E0/mc2)*(1-cos(Xfit1))
  Epsilon = 1/denom
  denom1 = Epsilon + Epsilon^(-1) - 2*sin(Xfit1)*cos(double(!PI/2.0D))
  numer1 = 1- sin(xfit1)^2*cos(!PI/2.0D)^2
  Lin_1000 = 2*numer1 / denom1

  CgOPlot, Tarr, Lin_1000, linestyle=4


  ;
  ;100kev
  Ener=2000.0
  E0 = Ener
  denom = 1.0D + (E0/mc2)*(1-cos(Xfit1))
  Epsilon = 1/denom
  denom1 = Epsilon + Epsilon^(-1) - 2*sin(Xfit1)*cos(double(!PI/2.0D))
  numer1 = 1- sin(xfit1)^2*cos(!PI/2.0D)^2
  Lin_2000 = 2*numer1 / denom1

  CgOPlot, Tarr, Lin_2000, linestyle=2


  ;
  ;100kev
  Ener=5000.0
  E0 = Ener
  denom = 1.0D + (E0/mc2)*(1-cos(Xfit1))
  Epsilon = 1/denom
  denom1 = Epsilon + Epsilon^(-1) - 2*sin(Xfit1)*cos(double(!PI/2.0D))
  numer1 = 1- sin(xfit1)^2*cos(!PI/2.0D)^2
  Lin_5000 = 2*numer1 / denom1

  CgOPlot, Tarr, Lin_5000, linestyle=1


  Leg_Text = [ '100 keV', '500 keV', '1 MeV', '2 MeV', '5 MeV' ]
  Leg_linestyle = [ 0, 5,4,2,1]

  CgLegend, Location=[0.70,0.885], Titles=Leg_Text, length =0.075,color=['black','black','black','black','black'],$
    psym=[0,0,0,0,0],/box, linestyles=Leg_linestyle

  CgPS_Close
  Temp_Str = Cur+'/'+'KN_LinearDeg_Pol.ps'
  CGPS2PDF, Temp_Str,delete_ps=1,UNIX_CONVERT_CMD='pstopdf'


End