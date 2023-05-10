function GRP_anode_uplim, ModPos, anode


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
if ( n_params() NE 2 ) then begin                 
  print, '*********************************************************'
  print, 'GRP_anode_uplim:  Incorrect Input  
  print, 'USAGE: grp_anode_uplim, Mod Position (0-31), anode (0-63)'
  print, '*********************************************************'
  stop
endif

;
; 
if (modpos lt 0) or (modpos gt 31) then begin
    print, '*****************************************************'
	print, 'GRP_anode_uplim:  Module position out of range (0-31)'
	print, 'GRP_anode_uplim:  Module position input = ',modpos
    print, '*****************************************************'
	return, [-999,-999]
endif


if (anode lt 0) or (anode gt 63) then begin
    print, '*****************************************************'
	print, 'GRP_anode_uplim:  Anode number out of range (0-63)'
	print, 'GRP_anode_uplim:  Module position input = ',anode
    print, '*****************************************************'
	return, [-999,-999]
endif

hdwul = fltarr(32,64)
rowdat = intarr(32)
header = ' '


openr, inunit, 'hdw_upper_limits.dat', /GET_LUN
				
readf, inunit, header
readf, inunit, hdwul

;for i = 0,63 do begin
;	readu, iunit, (for j = 0, 31 do hdwul[i,j], j = 1,31)
;endfor

return, hdwul[modpos, anode]


end