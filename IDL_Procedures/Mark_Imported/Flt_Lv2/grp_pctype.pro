function GRP_PCtype, anode1, anode2


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
;		evtype = 1  -  non-adjacent
;		evtype = 2  -  corner-adjacent
;		evtype = 3  -  side-adjacent
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


; THIS ALGORITHM DOES NOT WORK FOR CC Events


; if the number of variables is not correct it will send a message and stop the routine
if ( n_params() NE 2 ) then begin                 
  print, 'USAGE: Program_Name, Anodes ID Numbers'
  print, 'Returns the Event Type'
  stop
endif

;
; Are anode1 and anode2 valid anode values (1-64)?
;
if (anode1 lt 1) or (anode1 gt 64) or (anode2 lt 0) or (anode2 gt 64) then begin
	evtype = -1
	return, evtype
endif

;
; First, we assume that the event is of type 1 (non-adjacent anodes)
; 
evtype=1  

;
;  Check to see if the two anodes are side-adjacent
;
     if ((anode1-8 eq anode2) or (anode1+8 eq anode2) or $
     (anode1-1 eq anode2) or (anode1+1 eq anode2)) then evtype=3 

;
;  Check to see if the two anodes are corner-adjacent
;
     if ((anode1-9 eq anode2) or (anode1+9 eq anode2) or $
     (anode1-7 eq anode2) or (anode1+7 eq anode2)) then evtype=2


return, evtype

end
 