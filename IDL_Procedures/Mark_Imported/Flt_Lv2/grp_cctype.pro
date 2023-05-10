function GRP_CCtype, anode1, anode2


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
;  Element ids for calorimeters.
;
celements=[0,1,2,3,4,5,6,7,8,15,16,23,24,31,32,39,40,47,48,55,56,57,58,59,60,61,62,63]

;
; Are anode1 and anode2 valid anode values (0-63)?
;
if (anode1 lt 0) or (anode1 gt 63) or (anode2 lt 0) or (anode2 gt 63) then begin
	evtype = -1
	return, evtype
endif


;
; Are anode1 and anode2 both calorimeter anodes?
;
if (where(anode1 eq celements) eq -1) or (where(anode2 eq celements) eq -1) then begin
	evtype = -1
	return, evtype
endif

;
; First, we assume that the event is of type 1 (non-adjacent anodes)
; 
evtype=1  

case 1 of
;
;	"Top" or "Bottom" row of anodes (excluding corner anodes)
;	
	((anode1 ge 1) and (anode1 le 6)) or ((anode1 ge 57) and (anode1 le 62)): 	begin
;
;  						Check to see if the two anodes are side-adjacent
;
     					if ((anode1+1 eq anode2) or (anode1-1 eq anode2)) then evtype=3 
;
;  						Check to see if the two anodes are corner-adjacent
;
     					if ((anode1-7 eq anode2) or (anode1+7 eq anode2)) then evtype=2
     				end
;
;	Corner anode
;	
	anode1 eq 0 : begin
;
;  						Check to see if the two anodes are side-adjacent.
;						There are no corner-adjacent calorimeters for this anode.
;
     					if ((anode1+8 eq anode2) or (anode1+1 eq anode2)) then evtype=3 
     				end
;
;	Corner anode
;		
	anode1 eq 7 : begin
;
;  						Check to see if the two anodes are side-adjacent
;						There are no corner-adjacent calorimeters for this anode.
;
     					if ((anode1+8 eq anode2) or (anode1-1 eq anode2)) then evtype=3 
     				end
	
;
;	Corner anode
;	
	anode1 eq 56 : begin
;
;  						Check to see if the two anodes are side-adjacent
;						There are no corner-adjacent calorimeters for this anode.
;
     					if ((anode1-8 eq anode2) or (anode1+1 eq anode2)) then evtype=3 
;
     				end
	
;
;	Corner anode
;	
	anode1 eq 63 : begin
;
;  						Check to see if the two anodes are side-adjacent
;						There are no corner-adjacent calorimeters for this anode.
;
     					if ((anode1-8 eq anode2) or (anode1-1 eq anode2)) then evtype=3 
     				end
;	
;	"Side" row of anodes (excluding corner anodes)
;
	(float(anode1+1.0)/8.0 eq fix(anode1+1.0)/8.0) and (anode1 ge 15) and (anode1 le 55) : begin
;
;  						Check to see if the two anodes are side-adjacent
;
     					if ((anode1+8 eq anode2) or (anode1-8 eq anode2)) then evtype=3 
;
;  						Check to see if the two anodes are corner-adjacent
;
     					if ((anode1-9 eq anode2) or (anode1+7 eq anode2)) then evtype=2
     				end
	
	
;	
;	"Side" row of anodes (excluding corner anodes)
;
	(float(anode1/8.0) eq fix(anode1/8.0)) and (anode1 ge 8) and (anode1 le 48) : begin
;
;  						Check to see if the two anodes are side-adjacent
;
     					if ((anode1+8 eq anode2) or (anode1-8 eq anode2)) then evtype=3 
;
;  						Check to see if the two anodes are corner-adjacent
;
     					if ((anode1+9 eq anode2) or (anode1-7 eq anode2)) then evtype=2
     				end
	

	else:   evtype = -1 
endcase

return, evtype

end
 