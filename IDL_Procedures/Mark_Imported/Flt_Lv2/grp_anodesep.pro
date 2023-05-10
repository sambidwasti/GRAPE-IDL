function GRP_AnodeSep, anode1, anode2


;****************************************************************************************
; Name:
;		NAME
;
; Purpose:
;	Provides the separation (in cm) between two anodes whose anode numbers (0-63)
;   are provided.
;	Side adjacent anodes have a separation of 0.608 cm.
;	Corner adjacent anodes have a separation of 0.859842 cm.	
;
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
if ( n_params() NE 2 ) then begin                 
  print, '************************************************'
  print, 'GRP_AnodeSep:  Incorrect Arguments  
  print, 'USAGE: grp_anodexy, anode1 (0-63), anode2 (0-63)'
  print, '************************************************'
  stop
endif

;
; 
if (anode1 lt 0) or (anode1 gt 63) then begin
    print, '**************************************************'
	print, 'GRP_AnodeSep:  Anode1 number out of range (0-63)'
	print, 'GRP_AnodeSep:  Anode1 number input = ',anode1
    print, '**************************************************'
	return, [-999,-999]
endif
;
if (anode2 lt 0) or (anode2 gt 63) then begin
    print, '**************************************************'
	print, 'GRP_AnodeSep:  Anode2 number out of range (0-63)'
	print, 'GRP_AnodeSep:  Anode2 number input = ',anode2
    print, '**************************************************'
	return, [-999,-999]
endif

pos1 = grp_anodexy(anode1)
pos2 = grp_anodexy(anode2)

sep = sqrt((pos2[0]-pos1[0])^2 + (pos2[1]-pos1[1])^2)

return, sep

end