Function Rmv_Bk_Slash, Name
; *************************************************************************
; *          Removes BackSlash and return the String                      *
; *************************************************************************
; *                                                                       *
; * Purpose:  Removes the Backslash and returns the string. Very handy    *
; *           For the folder paths with spaces which gets in as backslash *
; *           as we drag the location. This simply helps to ease the      *
; *           ease the drag drop.                                         *
; *                                                                       *
; * Usage:  Result = Remove_Bk_Slash( Name  )                             *
; *                                                                       *
; *         Name = Variable to remove back slash from                     *
; *                                                                       *
; * Author: 7/10/13   Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; *************************************************************************
; *************************************************************************
A1 = ''                           ; String Variable to return
Len = StrLen(String(Name))        ; Lenght of string
For i = 0, Len Do Begin
    B=StrPos(Name,'\',i)
    If B EQ -1 Then B=Len
    A1 = A1+StrMid(Name,i,B-i)
    If B EQ -1 then i = Len Else i = B
EndFor
Return, A1                        ; return the string.
End