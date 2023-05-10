function GRP_AnodeType, anode


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

;  Returns 1 if it is a plastic element and 2 if it is a calorimeter element.

;
; If the number of variables is not correct.  Abort the routine.
;
if ( n_params() NE 1 ) then begin                 
  print, '*****************************************'
  print, 'GRP_AnodeType:  Incorrect Arguments  
  print, 'USAGE: grp_anodetype, Anode Number (0-63)'
  print, '*****************************************'
  stop
endif


;
; 
if (n_elements(anode[where(anode lt 0B, /null)]) gt 0) or (n_elements(anode[where(anode gt 63B, /null)]) gt 0) then begin
    print, '**************************************************'
	print, 'GRP_AnodeType:  Anode number out of range (0-63)'
	print, 'GRP_AnodeType:  Anode number input = ',anode
    print, '**************************************************'
	return, -1
endif

na   = n_elements(anode)
type = intarr(na)
;  
;  Element ids for plastic elements.
;
plastic = [9,10,11,12,13,14,17,18,19,20,21,22,25,26,27,28,29,30,33,34,35,36,37,38,$
             41,42,43,44,45,46,49,50,51,52,53,54]

;  
;  Element ids for calorimeters.
;
calorimeter = [0,1,2,3,4,5,6,7,8,15,16,23,24,31,32,39,40,47,48,55,56,57,58,59,60,61,62,63]

for i = 0, na-1 do begin

;
;  	If this is a plastic element, return a value of 1.
; 
	if (where(anode[i] eq plastic) ne -1) then type[i] = 1
	
;
;  	If this is a calorimeter element, return a value of 2.
; 
	if (where(anode[i] eq calorimeter) ne -1) then type[i] = 2

endfor 


return, type

end