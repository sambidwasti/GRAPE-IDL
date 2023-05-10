Function AnodeType, AnodeNumber
; *************************************************************************
; *           Identifying the Anode Type of 8X8 Anodes Module             *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read the Anode Number and Return the Anode Type             *
; *           Subroutine/Function For other Procedures.                   *
; *           Specially For Calibration Procedures                        *
; *                                                                       *
; * Usage:  Result = AnodeType(AnodeNumber)                               *
; *                                                                       *
; * Inputs:   Anode Number= Anode Number of the Anode                     *
; *                                                                       *
; * Returns:       0 for C-Anode                                          *
; *                1 for P-Anode                                          *
; *                2 for Invalid( If Any )                                *
; *                                                                       *
; * Error Handling: For Invalid Anode Number Return Invalid Type          *
; *                                                                       *
; * Author: 5/10/13   Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Note: Here its 1-64 anode numbers so +1 while calling this procedure  *
; *                                                                       *
; * Revision History:                                                     *
; *                                                                       *
; *************************************************************************
; *************************************************************************
    Anode = AnodeNumber+1
    
    If (anode LT 1 )  or  (anode GT 64) Then Type1 =2 Else $
    If (anode LT 9)   and (anode GT 0)  Then Type1 =0 Else $               ;C
    If (anode GT 56)  and (anode LT 65) Then Type1 =0 Else $               ;C
    If ((anode mod 8) EQ 1) OR ((anode mod 8) EQ 0) Then Type1 =0 Else $   ;C
    If (anode GT 9)   and (anode LT 16) Then Type1 =1 Else $               ;P  
    If (anode GT 9)   and (anode LT 16) Then Type1 =1 Else $               ;P
    If (anode GT 17)  and (anode LT 24) Then Type1 =1 Else $               ;P
    If (anode GT 25)  and (anode LT 32) Then Type1 =1 Else $               ;P
    If (anode GT 33)  and (anode LT 40) Then Type1 =1 Else $               ;P
    If (anode GT 41)  and (anode LT 48) Then Type1 =1 Else $               ;P
    If (anode GT 49)  and (anode LT 56) Then Type1 =1 Else $               ;P
    Type1=2
    Return, Type1
End    
