;+
; NAME:
; Cls
;
; PURPOSE:
; This procedure clears the active IDL display window.
;
; CATEGORY:
; Input/Output
;
; CALLING SEQUENCE:
; Cls
;
; PROCEDURE:
; This procedure uses the IDL ERASE and !p.multi to clear and
; reset the active display window.
;
; EXAMPLE:
; Plot something in a window.
;   plot, [0,1]
; Clear the window.
;   clear
;   
;
; MODIFICATION HISTORY:
;   Written by: Edward C. Wiebe, 2000-07-05.
; Modified: Daithi A. Stone, 2000-07-14 (Added
;     documentation).
;-

;***********************************************************************

PRO CLs

  ;***********************************************************************
  ;Clear the Screen and Reset !p.multi

  Erase
  !p.multi = 0
  
  
  spawn, 'clear'

  ;***********************************************************************
  ;The End

  return
END
