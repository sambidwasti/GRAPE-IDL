pro GRP_PosAng, sctang, rtang, elevation, azimuth, latitude, pvang, ppvang, hrangle, parang, posang


;****************************************************************************************
; Name:
;		NAME
;
; Purpose:
;		Returns the Position Angle of the Event Scatter Vector
;
; Calling Sequence:
;
;
; Inputs:
;		arg1 - Description of argument 1 
;
;		arg2 - Description of argument 2 
;
;		data1 - Description of datafile 1 
;
;
; Outputs:
;
;
; Uses:
;
;
;		
;
; Author and History:
;		M. McConnell - Initial Version - July, 2013
;
;
;****************************************************************************************



; if the number of variables is not correct it will send a message and stop the routine
if ( n_params() NE 10 ) then begin                 
  print, 'USAGE: GRP_PosAng, scatang, rtang, elevation, azimuth, latitude, pvang, ppvang, hrangle,parang, posang'
  print, 'Returns the Position Angle of the Event Scatter Vector'
  stop
endif
;

pvang = sctang - rtang + 151.6
cirrange, pvang

ppvang = 270.0 - pvang

altaz2hadec, elevation, azimuth, latitude, hrangle, dec

parang = parangle(hrangle, dec, latitude, /degree)

posang = ppvang + parang

cirrange, posang

;print, format = '("sctang = ",F6.2,"   rtang = ",F6.2,"   elev = ",F6.2, "   azim = ",F6.2,"   lat = ",F6.2,"   pvang = ",F6.2, "   ppvang = ",F6.2,"   hrangle = ",F6.2,"   Dec = ",F6.2,"   parang = ",F6.2,"   posang = ", F6.2)', $
;        sctang, rtang, elevation, azimuth, latitude, pvang, ppvang, hrangle, dec, parang, posang


return

end
