function GRP_ModuleXY, ModPos


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


; This function provides the x,y coordinates for the center of the detector module
; specified by the value of modpos.
; The function returns a two-element array with the x,y coordinates.

;
; If the number of variables is not correct.  Abort the routine.
;
if ( n_params() NE 1 ) then begin                 
  print, '*****************************************'
  print, 'GRP_ModuleXY:  Incorrect Input  
  print, 'USAGE: grp_modulexy, Mod Position (0-31)'
  print, '*****************************************'
  stop
endif

;
; 
if (modpos lt 0) or (modpos gt 31) then begin
    print, '**************************************************'
	print, 'GRP_ModuleXY:  Module position out of range (0-31)'
	print, 'GRP_ModuleXY:  Module position input = ',modpos
    print, '**************************************************'
	return, [-999,-999]
endif

c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration    

if (where(modpos eq c2014) eq -1) then begin
    print, '**************************************************'
	print, 'GRP_ModuleXY:  Invalid module position for 2014   '
	print, 'GRP_ModuleXY:  Module position input = ',modpos
    print, '**************************************************'
	return, [-999,-999]
endif



;          0        1       2        3        4      5       6        7       8
xmodule = [-12.954, -4.318, -21.59, -12.954, -4.318, -21.59, -12.954, -4.318, 4.318,  $
;          9        10      11       12     13      14       15       16     17
         12.954,  4.318, 12.954,   21.59, 4.318,  12.954,   21.59, -21.59,  -12.954,  $
;          18        19     20        21      22      23      24      25     26
        -4.318, -21.59, -12.954,  -4.318, -12.954, -4.318,  4.318,  12.954,  21.59,  $
;          27       28     29        30       31
         4.318,   12.954,  21.59,  4.318, 12.954]         

;          0        1       2        3        4      5       6        7       8
ymodule = [ 21.59,  21.59,   12.954, 12.954, 12.954,   4.318, 4.318, 4.318, 21.59, $
;          9        10      11       12     13      14       15       16     17
         21.59,  12.954, 12.954,  12.954,  4.318,  4.318,  4.318,  -4.318,  -4.318, $
;          18        19     20        21      22      23      24      25     26
        -4.318, -12.954,   -12.954, -12.954, -21.59, -21.59, -4.318, -4.318, -4.318, $
;          27       28     29        30       31
       -12.954,   -12.954, -12.954, -21.59, -21.59]
       

return, [xmodule[modpos], ymodule[modpos]]

end