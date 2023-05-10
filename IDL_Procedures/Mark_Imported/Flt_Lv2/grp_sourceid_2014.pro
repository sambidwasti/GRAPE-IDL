function GRP_SourceID_2014, time


;****************************************************************************************
; Name:
;		NAME
;
; Purpose:
;		To get the Source ID for the 2014 Flight for a certain time. 
;
; Calling Sequence:
;
;
; Inputs:
;		Time: Event time (in seconds)
;
; Outputs:
;   Outputs a number for the respective soruces.
;         1 - Crab
;         2 - Sun
;         3 - Sun
;         4 - Cyg X-1
;         5 - not used
;         6 - Blank 2
;         7 - Blank 3
;         8 - transition (no specific pointing)
;
;
; Uses:
;
; Author and History:
;		M. McConnell - Initial Version - July, 2013
;		
;		S.Wasti      - Renamed and modified - Jan, 2015
;		             - Added 2014 in the function name to differentiate from 2011 Flight
;		             - Corrected the time to identify sources for the 2014 Flight.
;		             Note: We are using the pause command when moving between sources.
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
  print, 'Returns Source Code: Crab=1, Sun1=2, Sun2=3, Cyg=4, Blank1=5, Blank2=6, Blank4=7, Nothing=8"
  stop
endif
  
  If time LT  493944 Then source = 8                        ; Nothing (Flight-Line and Ascent)
  if time GE  493944 And time LT  505179 then source = 2    ; Sun
  if time GE  505179 And time LT  505571 then source = 8    ; Nothing (Rehoming Elevation Motor)
  if time GE  505571 And time LT  510056 then source = 2    ; Sun (Again)
  if time ge  510056 and time lt  514710 then source = 6    ; Blank 2
  if time ge  514710 and time lt  528800 then source = 4    ; Cyg X 1
  if time ge  528800 and time lt  529767 then source = 8    ; Nothing (Rehoming the Elevation Motor)
  if time ge  529767 and time lt  540383 then source = 4    ; Cyg X 1
  if time ge  540383 and time lt  545811 then source = 7    ; Blank4
  if time ge  545811 and time lt  552552 then source = 1    ; Crab
  if time ge  552552 then source = 8    ; Flight over

return, source

end
 