function grp_compang, E1, E2


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
;
;****************************************************************************************


; Taylor Subroutine 
; read in a file and output desired variable.
; Higher and lower limit


; Start of subroutine
; function name, input variable
;evtype=2 then cc ;;evtype=3 then pc


; if the number of variables is not correct it will send a message and stop the routine
if ( n_params() NE 2 ) then begin                 
  print, 'USAGE: Program_Name, Energy of the two anodes'
  print, 'Returns the Compton Scatter angle (degrees)'
  stop
endif

cosang = (1.0+ (511./ (E1+E2))-(511./(E2)))

if cosang lt -1.0 or cosang gt 1.0 then return, -999.0
	
compang = acos(cosang) * !radeg

return, compang


end
 