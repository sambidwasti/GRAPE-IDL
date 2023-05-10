function GRP_SourceID, time


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



; Camden's Subroutine reimagined by Taylor, twice.
; read in a file and output desired variable.
; Higher and lower limit

; Start of subroutine
; function name, input variable
; 2F is for 0 on sunday


; if the number of variables is not correct it will send a message and stop the routine
if ( n_params() NE 1 ) then begin                 
  print, 'USAGE: Program_Name, time"
  print, 'Returns Source Code: Crab=1, Sun1=2, Sun2=3, Cyg=4, Blank1=5, Blank2=6, Blank3=7, Nothing=8"
  stop
endif
  
  if time lt  491884 then source = 8                           ;before pointing
  if time ge  491884 and time lt  510018 then source = 2    ; on the sun
  if time ge  510018 and time lt  510420 then source = 8    ;moving to blank2 and MIB reset
  if time ge  510420 and time lt  511080 then source = 2    ; on the sun 
  if time ge  511080 and time lt  511440 then source = 8    ; moving to blank2 
  if time ge  511440 and time lt  520603 then source = 6    ; On blank2 
  if time ge  520603 and time lt  520800 then source = 8    ; moving to Cyg X-1
  if time ge  520800 and time lt  542880 then source = 4    ; On Cyg X-1 
  if time ge  542880 and time lt  543660 then source = 8    ; moving to blank3
  if time ge  543660 and time lt  546654 then source = 7    ; On blank3
  if time ge  546654 and time lt  547080 then source = 8    ; Moving to Crab
  if time ge  547080 and time lt  573526 then source = 1    ; On Crab
  if time ge  573526 and time lt  573720 then source = 8    ; Moving to the sun
  if time ge  573720 and time lt  585420 then source = 3    ; on the sun
  if time ge  585420 then source = 8    ; Flight over

return, source

end
 