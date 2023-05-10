function GRP_AnodeXY, Anode


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



;
; If the number of variables is not correct.  Abort the routine.
;
if ( n_params() NE 1 ) then begin                 
  print, '*****************************************'
  print, 'GRP_AnodeXY:  Incorrect Arguments  
  print, 'USAGE: grp_anodexy, Anode Number (0-63)'
  print, '*****************************************'
  stop
endif

;
; 
if (anode lt 0) or (anode gt 63) then begin
    print, '**************************************************'
	print, 'GRP_AnodeXY:  Anode number out of range (0-63)'
	print, 'GRP_AnodeXY:  Anode number input = ',anode
    print, '**************************************************'
	return, [-999,-999]
endif

;
;
;
ia = anode mod 8
ja =  7 - fix(anode/8)

;
;
;
xa = (3.5 - float(ia)) * .608
ya = (3.5 - float(ja)) * .608

return, [xa, ya]

end