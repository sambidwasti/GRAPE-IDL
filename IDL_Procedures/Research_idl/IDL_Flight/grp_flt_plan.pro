Pro grp_flt_plan, input_file


; Input file is the inves6 file. 
;	Inves 6: Col file 
;		 EvtTime   Trun_Julian_Date  Latitude Longitute Atm_Altitude  Source PntZen  PntAzi

ReadCol, Input_file, EvtTime, Trn_JD, Lat, Lon, Atm_Alt, Src, Zen, PntAzi

;    eq2hor, ra, dec, jd, alt, az, [ha, LAT= , LON= , /WS, OBSNAME= , $
;                       /B1950 , PRECESS_= 0, NUTATE_= 0, REFRACT_= 0, $
;                       ABERRATION_= 0, ALTITUDE= , /VERBOSE, _EXTRA= ]

; EXAMPLE
;
;  Find the position of the open cluster NGC 2264 at the Effelsburg Radio
;  Telescope in Germany, on June 11, 2023, at local time 22:00 (METDST).
;  The inputs will then be:
;
;       Julian Date = 2460107.250
;       Latitude = 50d 31m 36s
;       Longitude = 06h 51m 18s
;       Altitude = 369 meters
;       RA (J2000) = 06h 40m 58.2s
;       Dec(J2000) = 09d 53m 44.0s
;
;  IDL> eq2hor, ten(6,40,58.2)*15., ten(9,53,44), 2460107.250d, alt, az, $
;               lat=ten(50,31,36), lon=ten(6,51,18), altitude=369.0, /verb, $
;                pres=980.0, temp=283.0
;
; The program produces this output (because the VERBOSE keyword was set)
;
; Latitude = +50 31 36.0   Longitude = +06 51 18.0
; ************************** 
;Julian Date =  2460107.250000
;LMST = +11 46 42.0
;LAST = +11 46 41.4
; 
;Ra, Dec:  06 40 58.2  +09 53 44   (J2000)
;Ra, Dec:  06 42 15.7  +09 52 19   (J2023.4422)
;Ra, Dec:  06 42 13.8  +09 52 27   (fully corrected)
;Hour Angle = +05 04 27.6  (hh:mm:ss)
;Az, El =  17 42 25.6  +16 25 10   (Apparent Coords)
;Az, El =  17 42 25.6  +16 28 23   (Observer Coords)
;
; Compare this with the result from XEPHEM:
; Az, El =  17h 42m 25.6s +16d 28m 21s
;
; This 1.8 arcsecond discrepancy in elevation arises primarily from slight
; differences in the way I calculate the refraction correction from XEPHEM, and
; is pretty typical.
;

eq2hor, ten(6,40,58.2)*15., ten(9,53,44), 2460107.250d, alt, az, $
              lat=ten(50,31,36), lon=ten(6,51,18), altitude=369.0;, /verb, $
              
              Print, alt
              print, az
              
              
;                pres=980.0, temp=283.0
End