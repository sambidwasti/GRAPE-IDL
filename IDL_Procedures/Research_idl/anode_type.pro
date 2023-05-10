Function Anode_Type, Anode
  ; *************************************************************************
  ; *           Identifying the Anode Type of 8X8 Anodes Module             *
  ; *************************************************************************
  ; * Version: 1.02 
  ; * NOTE: THis is an upgrade to AnodeType so that the output is changed   *
  ; *                                                                       *
  ; * Purpose:  Read the Anode Number and Return the Anode Type             *
  ; *           Subroutine/Function For other Procedures.                   *
  ; *           Specially For Calibration Procedures                        *
  ; *                                                                       *
  ; * Usage:  Result = AnodeType(AnodeNumber)                               *
  ; *                                                                       *
  ; * Inputs:   Anode Number= Anode Number of the Anode                     *
  ; *                                                                       *
  ; * Returns:       1 for C-Anode                                          *
  ; *                2 for P-Anode                                          *
  ; *               -1 for Invalid( If Any )                                *
  ; *                                                                       *
  ; * Error Handling: For Invalid Anode Number Return Invalid Type          *
  ; *                                                                       *
  ; * Author: 5/10/13   Sambid Wasti                                        *
  ; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
  ;           
  ; *                                                                       *
  ; * Note: Here its 0~63 anode numbers so +1 while calling this procedure  *
  ; *                                                                       *
  ; * Revision History:                                                     *
  ; *                                                                       *
  ;           4/24/16 Sambid Wasti
  ;           Updated teh name from anodetype to anode_Type, works for 0~63
  ;           Outputs now 0-C, 1-P and -1 for invalid.
  ; *************************************************************************
  ; *************************************************************************


  If (anode LT 0 )  or  (anode GT 63) Then Type =-1 Else $
    If (anode GE 0)   and (anode LE 7)  Then Type =1 Else $               ;C
    If (anode GE 55)  and (anode LE 63) Then Type =1 Else $               ;C
    If ((anode mod 8) EQ 7) OR ((anode mod 8) EQ 0) Then Type =1 Else $   ;C
    If (anode GE 9)   and (anode LE 14) Then Type =2 Else $               ;P
    If (anode GE 17)  and (anode LE 22) Then Type =2 Else $               ;P
    If (anode GE 25)  and (anode LE 30) Then Type =2 Else $               ;P
    If (anode GE 33)  and (anode LE 38) Then Type =2 Else $               ;P
    If (anode GE 41)  and (anode LE 46) Then Type =2 Else $               ;P
    If (anode GE 49)  and (anode LE 54) Then Type =2 Else $               ;P
    Type=-1
  Return, Type
End
