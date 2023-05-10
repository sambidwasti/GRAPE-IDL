Pro Grp_Chk_Hrs_onboard_out, RotationTableData
; May 28/ 2019
; Creating this to check the outputs from hrs on board quicklook 
; Currenlty checking only RotationTableData output.
ReadCol, RotationTableData, rtTime, GpsTime, rtSwpTIme, Rt1,RtSTat, RtStep, rtAngle, Format=' LL, LL, LL, I,I, I, L'

CD,Cur=Cur
    CgPs_Open, 'HRS_RotTableData.ps', Font =1, /LandScape
    cgLoadCT, 13
    Cgplot, RtTIme, title='Rt TIme'
    CgERase
    CgPlot, GPSTime, title='GPS Time'
    CgErase

    Cgplot, rtTime, GPSTime, PSYM=1, Title='GPStime vs RtTime', Ytitle='GPS Time', Xtitle='Rt Time'
    CGErase
    CGPlot, GPSTime, RtSwpTime, Title='RtSwpTime vs GPSTime', Ytitle='RtSwpTime', Xtitle='GPSTime'
    CgErase
    CGPlot, GPSTime, RTStat, Title='RTStat vs GPSTime', Ytitle='RTStat', Xtitle='GPSTime'
    CgErase
    CgPlot, GPSTIme, RTStep, Title='RTStep vs GPSTime', Ytitle='RTStep', Xtitle='GPSTime'
    CgErase
    CgPlot, GPSTime, RtAngle, Title='RTAngle vs GPSTime', Ytitle='Rt Angle', Xtitle='GPSTime', psym=1
    
help, rtTime, GpsTime
  CGPS_Close
    Temp_Str = Cur+'/HRS_RotTableData.ps'
    CGPS2PDF, Temp_Str,delete_ps=1

End