pro Grp_Flight_Plan 
;
; Trying to generate a flight plan. 
; We need RA - DEC and the time. 
; We have UTC time and we need julian date. 
; 
; Few Notes:
; Julian day starts at 12:00 UTC.
; On Sept 26, 2014 at 12:00 UTC, julian day was : 2456927
; So on 13:00 UTC it became 2456927 + 1/24 = 2346927.0416667
; 
; Since we launched at 1445 UTC and terminated at next day's 0937 UTC
; Its the same julian day. 
; 
;


; We need to create an array of time interval for plot.
; lets say 5 min interval. 
;testing with 1 hour
; Well need a time to convert the UTC to Julian in a logical way. 
; Assuming Mod_UTC as 12:00 utc as base
; So Mod_hr = UTC - 12:00 UTC
;
;
; Flight Line : 1400
; End the next day around 900
; So do from 1200 to next day 1200
; Lets say every half hour at first.
; Float at :
;

cd, cur= cur


;=== FT Sumner Constants ===
Ft_Lat =    34.4717332
Ft_Lon =    -104.2455304

StdJulDay = 2456927.0D
Temp_1daymin = 24.0D*60.0D

UTC_5min    = 05.0D/Temp_1daymin   ; *3 = 390
UTC_10min   = 10.0D/Temp_1daymin   ;195
UTC_15min   = 15.0D/Temp_1daymin  ;130
UTC_30min   = 30.0D/Temp_1daymin ; 65

UsedUTC = UTC_10min
ntime = 195
; Need 60 Array. 
TempTime= Indgen(ntime)*UsedUTC
TimeArr = StdJulDay+TempTime




TempArrH = lonarr(ntime)
TempArrM = lonarr(ntime)
for i = 0, ntime-1 do begin
jul2greg, TimeArr[i], M, D, Y, H, M, S
TempArrH[i] = H
TempARrM[i] = M
EndFor

;BGd2
Ra = 265.95
Dec= 47.00

AltArr =DblArr(ntime)
for i = 0, ntime-1 do begin
EQ2Hor, Ra, Dec, TimeArr[i], Alt, Azi, altitude=39000, Lat=Ft_lat, Lon=Ft_lon
altarr[i]=Alt
endfor
Bgd2_AltArr = altarr

;Cyg1
Ra = 299.59
Dec= 35.20

AltArr =DblArr(ntime)
for i = 0, ntime-1 do begin
  EQ2Hor, Ra, Dec, TimeArr[i], Alt, Azi, altitude=39000, Lat=Ft_lat, Lon=Ft_lon
  altarr[i]=Alt
endfor
Cyg_AltArr= altarr

;BGd4
Ra = 0.0
Dec= 22.15

AltArr =DblArr(ntime)
for i = 0, ntime-1 do begin
  EQ2Hor, Ra, Dec, TimeArr[i], Alt, Azi, altitude=39000, Lat=Ft_lat, Lon=Ft_lon
  altarr[i]=Alt
endfor
Bgd4_AltArr= altarr

;Crab
Ra = 83.63
Dec= 22.01

AltArr =DblArr(ntime)
for i = 0, ntime-1 do begin
  EQ2Hor, Ra, Dec, TimeArr[i], Alt, Azi, altitude=39000, Lat=Ft_lat, Lon=Ft_lon
  altarr[i]=Alt
endfor
Crab_AltArr= altarr

;SUn
AltArr =DblArr(ntime)
for i = 0, ntime-1 do begin
  SunPos, TimeArr[i], Ra, Dec
  EQ2Hor, Ra, Dec, TimeArr[i], Alt, Azi, altitude=39000, Lat=Ft_lat, Lon=Ft_lon
  altarr[i]=Alt
endfor
SUn_Altarr = altArr


help, timeArr
dummy = LABEL_DATE(DATE_FORMAT='%H:%I')


; flight=1400
;float = 1700
; termination 9:37 next day = 1200 +937
; 21hrs +37min = 1297
FltLine_time = (120.0D/Temp_1daymin)+StdJulDay
Float_Time = (240.0D/Temp_1daymin)+StdJulDay
Termination_time = (1297.0D/Temp_1daymin)+StdJulDay
MaxTime = TimeArr[ntime-1]
Interval =UTC_30min * 8

Colorarr = ['Red','Orange','Gray','Dark Green','Cornflower Blue','Black']
CgPS_Open,'Flight_Plan.ps', Font =1, /LandScape
cgLoadCT, 13
;window,0
CgPlot, TimeArr, Bgd2_AltArr, yrange = [40, 90], ystyle=1, xtickformat='LABEL_DATE', $
    xstyle=1, Xrange=[Float_time,Maxtime], Xtickinterval=Interval,color=colorarr[1],thick=3,$
    xtitle = 'UTC Time for 26th to 27th September', Ytitle ='Elevation angle (deg)', Title='Flight Plan for GRAPE 2014 flight',$
    charsize=2.5
CgOplot, TimeArr, Cyg_AltArr, color=colorarr[2], thick=3
CgOplot, TimeArr, Bgd4_AltArr, color=colorarr[3], thick=3
CgOplot, TimeArr, Crab_AltArr, color=colorarr[4], thick=3
CgOplot, TimeArr, Sun_AltArr, Color =colorarr[0], thick=3


;
; Now we create a Main Bold flight plan array.
;
;Flight_pnt = dblarr(ntime)

;Follow Sun till 2100 
SunPnt_Start = 0
TempTimeJ = ((9*60.0D + 0)/Temp_1daymin)+StdJulDay  ; went to 2000 hours
TempArr1  = where(TimeArr GE TempTimeJ)
SunPnt_end   = TempArr1[0]

;Follow Bgd2 till 2300
Bgd2Pnt_Start = SunPnt_End
TempTimeJ = ((11*60.0D + 0)/Temp_1daymin)+StdJulDay  ; went to 2000 hours
TempArr1  = where(TimeArr GE TempTimeJ)
Bgd2Pnt_end   = TempArr1[0]

;Follow Cygnus X1  till 6 which is 12+6
CygPnt_Start = Bgd2Pnt_End
TempTimeJ = ((18*60.0D + 0)/Temp_1daymin)+StdJulDay  ; went to 2000 hours
TempArr1  = where(TimeArr GE TempTimeJ)
CygPnt_end   = TempArr1[0]

;Follow Bgd4 till 9:30 which is 12 + 9.5
Bgd4Pnt_Start = CygPnt_End
TempTimeJ = ((21*60.0D + 30.0D)/Temp_1daymin)+StdJulDay  ; went to 2000 hours
TempArr1  = where(TimeArr GE TempTimeJ)
Bgd4Pnt_end   = TempArr1[0]

;Follow Crab till 15+ which is 12 + 16 = 28
CrabPnt_Start = Bgd4Pnt_End
TempTimeJ = ((28*60.0D + 10.0D)/Temp_1daymin)+StdJulDay  ; went to 2000 hours
TempArr1  = where(TimeArr GE TempTimeJ)
CrabPnt_end   = TempArr1[0]


;Follow the Sun again till end
Sun2Pnt_Start = CrabPnt_End
Sun2Pnt_end   = n_elements(TimeArr)-1


;Arr_end = CygPnt_end

TimeArr1 = [TimeArr[0:SunPnt_End], TimeArr[Bgd2Pnt_Start:Bgd2Pnt_end], TimeArr[CygPnt_Start:CygPnt_end], TimeArr[Bgd4Pnt_Start:Bgd4Pnt_end] , TimeArr[CrabPnt_Start:CrabPnt_end] ,TimeArr[Sun2Pnt_Start:Sun2Pnt_end]]
Flight_pnt = [Sun_AltArr[0:SunPnt_End], Bgd2_AltArr[Bgd2Pnt_Start:Bgd2Pnt_end], Cyg_AltArr[CygPnt_Start:CygPnt_end], Bgd4_AltArr[Bgd4Pnt_Start:Bgd4Pnt_end],  Crab_AltArr[CrabPnt_Start:CrabPnt_end], Sun_AltArr[Sun2Pnt_Start:Sun2Pnt_end] ]


CgOplot, TimeArr1,Flight_pnt , Color ='Black', thick=6, linestyle=4

; CgLegend, Location=[0.76,0.885], Titles=['Sun','Bgd2','CygnusX1','Bgd4','Crab','FlightPlan'], Length =0.03, color=colorarr,$
 ;   SymColors = colorarr, TColors=colorarr,Psyms=[3,3,3,3,3,3],/box, Charsize=1.2, linestyles=[0,0,0,0,0,4]
 CgLegend, Location=[0.76,0.885], Titles=['FlightPlan'], Length =0.03, color=Black,$
     SymColors = 'Black', TColors='Black',Psyms=[3],/box, Charsize=1.2, linestyles=[4]


  CgText,  !D.X_Size*0.17,!D.Y_Size*0.40, 'Sun'  , Color=ColorArr[0],/DEVICE, CharSize =2
  CgText,  !D.X_Size*0.24,!D.Y_Size*0.6, 'Bgd2'  , Color='Dark Goldenrod',/DEVICE, CharSize =2
  CgText,  !D.X_Size*0.45,!D.Y_Size*0.85, 'Cygnus X1', Color='Dark Gray',/DEVICE, CharSize =2
  CgText,  !D.X_Size*0.56,!D.Y_Size*0.7, 'Bgd4'  , Color=ColorArr[3],/DEVICE, CharSize =2
  CgText,  !D.X_Size*0.66,!D.Y_Size*0.48, 'Crab'  , Color='Navy',/DEVICE, CharSize =2.5
  CgText,  !D.X_Size*0.85,!D.Y_Size*0.40, 'Sun'  , Color=ColorArr[0],/DEVICE, CharSize =2



CgPS_Close
Temp_Str = Cur+'/'+'Flight_plan.ps'
CGPS2PDF, Temp_Str,delete_ps=1

End