Pro Grp_flt_ACPlots, inputfile, Title=Title
; We use the grp_flt_hkdata which requires the AC Rates files along with other info files to
; interpolate the data for the AC Rates files.
; This programs reads the output file from there. 

; The Basic reading file has the following columns. 
; GPSTime, Altitude(ft)  AC1 AC2 AC3 AC4 AC5 AC6 AC(total) Depth Zen
; Note that the Total AC is not correctly added..
; AC is the AC Counts in 5s.
IF Keyword_Set(title) Eq 0 Then Title='Test'

;493944 is the time for the Sun's sweep start time.
;we want to skip the ascent data .
ReadCol, inputfile, GPSTime, Altitude, AC1, AC2, AC3, AC4, AC5, AC6, ACT, Depth, Zenith, $
                format='D,D,D,D,D,D,D,D,D,D,D'

Loc = Value_Locate( GPSTime, 493900 )
; this is the location we want to start looking at the values.

Time = GPSTIME[Loc:N_Elements(GPSTIme)-1]
Alt  = Altitude[Loc:N_Elements(Altitude)-1]
AC1_R= AC1[Loc:N_Elements(AC1)-1]/5.0
AC2_R= AC2[Loc:N_Elements(AC2)-1]/5.0
AC3_R= AC3[Loc:N_Elements(AC3)-1]/5.0
AC4_R= AC4[Loc:N_Elements(AC4)-1]/5.0
AC5_R= AC5[Loc:N_Elements(AC5)-1]/5.0
AC6_R= AC6[Loc:N_Elements(AC6)-1]/5.0
AC_TotR = AC1_R + AC2_R+ AC3_R+ AC4_R+ AC5_R+ AC6_R
Dep  = Depth[Loc:N_Elements(Depth)-1]
Zen  = Zenith[Loc:N_Elements(Zenith)-1] 




Col = FIX(255*Zen/Max(Zen))

;CGPlot, XVal, YVal, /Nodata, POSITION=[0.15, 0.15, 0.80, 0.90], XTitle ='Depth (g/cm^2) ', YTitle = 'AC Rates (C/s)', Title='zz', Charsize=2.0,$
;        Xrange = [2.5, 6.0], YRange =[1500,2000]
;CgLoadCt, 34
;CgColorbar,  Color='Black',NColors=254, POSITION=[0.90, 0.15, 0.95, 0.90] , /Vertical, Range=[0,Max(Zen)], Title='Zenith'

;For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
;sFor i=0,N_Elements(XVal)-1 DO CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1

;-- Start Plotting and Generating graphs like above --
cgPS_Open, Title+'_AC_Plots.ps', Font=1
cgDisplay, 800, 800
cgLoadCT, 34
        XVal = Dep
        YVal = AC_TotR
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='Depth (g/cm^2) ', YTitle = 'AC Rates (C/s)', Title='Total AC Rates Vs Depth', Charsize=2.0,$
        Xrange = [2.5, 6.0], YRange =[14000,17000]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[0,Max(Zen)], Title='Zenith'
        ;For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
              IF (YVal[i] GT 14000) And  (YVal[i] LT 17000) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        
        XVal = Dep
        YVal = AC1_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='Depth (g/cm^2) ', YTitle = 'AC Rates (C/s)', Title='AC1 Rates Vs Depth', Charsize=2.0,$
          Xrange = [2.5, 6.0], YRange =[1500,2000]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[0,Max(Zen)], Title='Zenith'
        ;For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
              IF (YVal[i] GT 1500) And  (YVal[i] LT 2000) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor

        XVal = Dep
        YVal = AC2_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='Depth (g/cm^2) ', YTitle = 'AC Rates (C/s)', Title='AC2 Rates Vs Depth', Charsize=2.0,$
          Xrange = [2.5, 6.0], YRange =[2600,3400]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[0,Max(Zen)], Title='Zenith'
        ;For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
              IF (YVal[i] GT 2600) And  (YVal[i] LT 3400) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        
        XVal = Dep
        YVal = AC3_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='Depth (g/cm^2) ', YTitle = 'AC Rates (C/s)', Title='AC3 Rates Vs Depth', Charsize=2.0,$
          Xrange = [2.5, 6.0], YRange =[2600,3400]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[0,Max(Zen)], Title='Zenith'
        ;For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
              IF (YVal[i] GT 2600) And  (YVal[i] LT 3400) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        
        XVal = Dep
        YVal = AC4_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='Depth (g/cm^2) ', YTitle = 'AC Rates (C/s)', Title='AC4 Rates Vs Depth', Charsize=2.0,$
          Xrange = [2.5, 6.0], YRange =[2600,3400]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[0,Max(Zen)], Title='Zenith'
        ;For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
              IF (YVal[i] GT 2600) And  (YVal[i] LT 3400) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        
        XVal = Dep
        YVal = AC5_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='Depth (g/cm^2) ', YTitle = 'AC Rates (C/s)', Title='AC5 Rates Vs Depth', Charsize=2.0,$
          Xrange = [2.5, 6.0], YRange =[1900,2400]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[0,Max(Zen)], Title='Zenith'
        ;For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
              IF (YVal[i] GT 1900) And  (YVal[i] LT 2400) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        
        XVal = Dep
        YVal = AC6_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='Depth (g/cm^2) ', YTitle = 'AC Rates (C/s)', Title='AC6 Rates Vs Depth', Charsize=2.0,$
          Xrange = [2.5, 6.0], YRange =[2600,3400]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[0,Max(Zen)], Title='Zenith'
        ;For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
              IF (YVal[i] GT 2600) And  (YVal[i] LT 3400) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        
        XVal1= Zen*!PI/180
        XVal = 1/(cos(XVal1))
        YVal = AC_TotR
        Col = FIX(255*(Dep-Min(Depth))/(Max(Dep)-Min(Depth)))
        
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='1/Cos(Theta)  ', YTitle = 'AC Rates (C/s)', Title='AC Total Rates Vs Depth', Charsize=2.0,$
         YRange =[14000,17000]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[Min(Dep),Max(Dep)], Title='Dep'
       ; For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
          IF (YVal[i] GT 14000) And  (YVal[i] LT 17000) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor       
        
               
        YVal = AC1_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='1/Cos(Theta)  ', YTitle = 'AC  Rates (C/s)', Title='AC 1 Rates Vs Depth',Charsize=2.0,$
          YRange =[1500,2000]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[Min(Dep),Max(Dep)], Title='Dep'
        ; For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
          IF (YVal[i] GT 1500) And  (YVal[i] LT 2000) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        
        PL = Dep*XVal
        Xval = PL
        YVal = AC1_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='Path Length (g/cm^2)  ', YTitle = 'AC  Rates (C/s)', Title='AC 1 Rates Vs Path Length',Charsize=2.0,$
          YRange =[1500,2000]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[Min(Dep),Max(Dep)], Title='Dep'
        ; For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
          IF (YVal[i] GT 1500) And  (YVal[i] LT 2000) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        
        
        XVal1= Zen*!PI/180
        XVal = 1/(cos(XVal1))
        
        YVal = AC2_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='1/Cos(Theta)  ', YTitle = 'AC Rates (C/s)', Title='AC 2 Rates Vs Depth',Charsize=2.0,$
          YRange =[2600,3400]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[Min(Dep),Max(Dep)], Title='Dep'
        ; For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
          IF (YVal[i] GT 2600) And  (YVal[i] LT 3400) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        
        XVal1= Zen*!PI/180
        XVal = 1/(cos(XVal1))
        YVal = AC5_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='1/Cos(Theta)  ', YTitle = 'AC Rates (C/s)', Title='AC 5 Rates Vs Depth',Charsize=2.0,$
          YRange =[1900,2400]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[Min(Dep),Max(Dep)], Title='Dep'
        ; For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
          IF (YVal[i] GT 1900) And  (YVal[i] LT 2400) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        

        PL = Dep*XVal
        Xval = PL
        YVal = AC5_R
        CGPlot, XVal, YVal, /Nodata, POSITION=[0.0, 0.20, 0.85, 0.85], XTitle ='Path Length (g/cm^2)  ', YTitle = 'AC Rates (C/s)', Title='AC 5 Rates Vs Path length',Charsize=2.0,$
          YRange =[1900,2400]
        CgColorbar,  Color='Black',NColors=254, POSITION=[0.95, 0.20, 1.0, 0.85] , /Vertical, Range=[Min(Dep),Max(Dep)], Title='Dep'
        ; For i=0,N_Elements(XVal)-2 DO CGPLots, [XVal[i],XVal[i+1]], [YVal[i],YVal[i+1]], Color=StrTrim(Col[i],2),Thick=2
        For i=0,N_Elements(XVal)-1 DO Begin
          IF (YVal[i] GT 1900) And  (YVal[i] LT 2400) Then CGPLots, XVal[i], YVal[i], Color=StrTrim(Col[i],2),PSYM=1
        Endfor
        
        
cgPS_Close
Temp_Str = Title+'_AC_Plots.ps'
CGPS2PDF, Temp_Str,delete_ps=1
Stop
End
