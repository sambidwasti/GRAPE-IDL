Pro Plot_Mod_Factor


  Constant = 1000.0D ;Counts
  Amplitude= 300.0D
  Phase_shift_Deg = 30.0D
  Phase_shift = Phase_shift_Deg*2*!PI/(360.0D)
  ; Need array of radians from 0-Pi
  No_points = 100
  TArr = FIndGen(No_points)/No_Points*360.0D
  Xfit1 = Tarr*2*!PI/(360.0D)
  mc2 = 511.0D ;kEV


  E0 = Constant
  E1 = Amplitude
  X1 = phase_shift
  
  ; Equaiton form = E0 + E1*cos(X1-X)^2
  C = E0 + E1*cos(X1-Xfit1)^2
  C1=E0 - E1*cos(X1-Xfit1)^2
  cd, cur=cur
  CgPS_Open,'ModFactor_IDL.ps', Font =1, /LandScape
  cgLoadCT, 13

  CgPlot, Tarr, C, Xrange=[0,360], xstyle =1, $
     xtickinterval=30, charsize=2, $
    yrange=[600,1800], ystyle=1,ytickinterval=200, thick=5


  CgPS_Close
  Temp_Str = Cur+'/'+'ModFactor_IDL.ps'
  CGPS2PDF, Temp_Str,delete_ps=1


End