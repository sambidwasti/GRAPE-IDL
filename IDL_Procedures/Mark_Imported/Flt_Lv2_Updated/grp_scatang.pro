function GRP_ScatAng, module1, anode1, module2, anode2


;****************************************************************************************
; Name:
;		NAME
;
; Purpose:
;		Brief Description
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
;		GRP_AUXDATA    	- Reads in auxiliary data files.
;		GRP_ECALDATA   	- Reads in anode energy calibration files.
;		GRP_RTDATA		- Reads in Rotation Table data
;		GRP_GETAUX     	- Handles lookup of auxiliary data value for a given time.
;
;		
;
; Author and History:
;		M. McConnell - Initial Version - July, 2013
;		
;		S. Wasti     - Jan 22, 2015
;		             - Changed the c2011 to c2014 adding 8 new module positions. The
;		               Old code configuration is commented not deleted.
;
;
;****************************************************************************************



; if the number of variables is not correct it will send a message and stop the routine
if ( n_params() NE 4 ) then begin                 
  print, 'USAGE: Program_Name, Mod Positions, Anode IDs'
  print, 'Returns the Scatter Vector';Azimuthal Scattering Angle'
  stop
endif
;
; If the number of variables is not correct.  Abort the routine.
;
if ( n_params() ne 4 ) then begin                 
  print, '****************************************************'
  print, 'GRP_AnodeXY:  Incorrect Arguments  
  print, 'USAGE: grp_sctang, Module1, Anode1, Module2, Anode2
  print, '****************************************************'
  stop
endif

;
; 
if (module1 lt 0) or (module1 gt 31) or (module2 lt 0) or (module2 gt 31) then begin
    print, '***********************************************************'
	print, 'GRP_ScatAng:  Module position(s) out of range (0-31)'
	print, 'GRP_ScatAng:  Module positions input = ', module1, module2
    print, '***********************************************************'
	return, [-999,-999]
endif

;c2011 = [3,4,6,7,10,11,13,14,17,18,20,21,24,25,27,28]    ; 2011 configuration
c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]  ; 2014 Configuration.

;if (where(module1 eq c2011) eq -1) or (where(module2 eq c2011) eq -1) then begin
if (where(module1 eq c2014) eq -1) or (where(module2 eq c2014) eq -1) then begin
    print, '**********************************************************'
	print, 'GRP_ScatAng:  Invalid module position(s) for 2014   '
	print, 'GRP_ScatAng:  Module position input = ', module1, module2
    print, '***********************************************************'
	return, [-999,-999]
endif


;
; 
if (anode1 lt 0) or (anode1 gt 63) or (anode2 lt 0) or (anode2 gt 63) then begin
    print, '*******************************************************'
	print, 'GRP_ScatAng:  Anode number(s) out of range (0-63)'
	print, 'GRP_ScatAng:  Anode number(s) input = ', anode1, anode2
    print, '*******************************************************'
	return, [-999,-999]
endif


site1 = grp_modulexy(module1) + grp_anodexy(anode1)

site2 = grp_modulexy(module2) + grp_anodexy(anode2)

sctvec = site2 - site1

sctang = atan(sctvec(1),sctvec(0)) * !radeg

if (sctang lt 0.0) then  sctang = sctang + 360.0

return, sctang

end
