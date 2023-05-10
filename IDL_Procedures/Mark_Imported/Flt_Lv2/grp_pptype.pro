function GRP_PPtype, anode1, anode2


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
;		anode1 - First of two anode ids (0-63)
;
;		anode2 - Second of two anode ids (0-63) 
;
;
; Outputs:
;
;		evtype = 1  -  non-adjacent
;		evtype = 2  -  corner-adjacent
;		evtype = 3  -  side-adjacent
;
; Uses:
;
;		
;
; Author and History:
;		M. McConnell - Initial Version - July, 2013
;
;
;****************************************************************************************


; THIS ALGORITHM DOES NOT WORK FOR PC Events


; if the number of variables is not correct it will send a message and stop the routine
if ( n_params() NE 2 ) then begin                 
  print, 'USAGE: Program_Name, Anodes ID Numbers'
  print, 'Returns the Event Type'
  stop
endif


;  
;  Element ids for plastic elements.
;
plastic = [9,10,11,12,13,14,17,18,19,20,21,22,25,26,27,28,29,30,33,34,35,36,37,38,$
             41,42,43,44,45,46,49,50,51,52,53,54]

;
; Are anode1 and anode2 valid anode values (0-63)?
;
if (anode1 lt 0) or (anode1 gt 63) or (anode2 lt 0) or (anode2 gt 63) then begin
	evtype = -1
	return, evtype
endif


;
; Are anode1 and anode2 both plastic anodes?
;
if (where(anode1 eq plastic) eq -1) or (where(anode2 eq plastic) eq -1) then begin
	evtype = -1
	return, evtype
endif

;
; First, we assume that the event is of type 1 (non-adjacent anodes)
; 
evtype=1  

; Check to see if the two anodes are side-adjacent
;
if ((anode1+1 eq anode2) or (anode1-1 eq anode2) or  $
    (anode1+8 eq anode2) or (anode1-8 eq anode2)) then evtype=3 
;
;  Check to see if the two anodes are corner-adjacent
;
if ((anode1-7 eq anode2) or (anode1+7 eq anode2) or  $
    (anode1-9 eq anode2) or (anode1+9 eq anode2)) then evtype=2

return, evtype

end
 