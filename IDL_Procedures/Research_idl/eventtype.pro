
Function EventType, Anode1, Anode2
; *************************************************************************
; *           To Get the Type of Event Between 2 Anodes                   *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read in the Anode Numbers and Output the Event Type         *
; *           Subroutine/Function For other Procedures.                   *
; *           Specially For Calibration Procedures                        *
; *                                                                       *
; * Usage:  Result = EventType(AnodeNumber1, AnodeNumber2)                *
; *                                                                       *
; * Inputs:   Anode1= Anode Number of the 1st Anode                       *
; *           Anode2= Anode Number of the 2nd Anode                       *
; *                                                                       *
; * Returns:  0 for Invalid                                               *
; *           1 for Type 1: Non Adjacent or Non-Corners                   *
; *           2 for Type 2: Adjacent to each other. Non-Corners           *
; *           3 for Type 3: Adjacent Corners.                             *
; *                                                                       *
; * Error Handling: For Invalid Anode Number Return Invalid Type =0       *
; *                                                                       *
; * Author: 5/10/13   Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; *         9/10/2013 Sambid Wasti                                        *
; *                   -Fixing So that it works for 0~63                   *
; *                                                                       *
; *                                                                       *
; 
; *************************************************************************
; *************************************************************************
      
      ;
      ;-- Some basic checks
      ;
      
      ;-- If both the same anode
      If Anode1 Eq Anode2 Then Return, 0
      
      ;-- If Anode 1 out of range
      If (Anode1 LT 0) or (Anode1 GT 63) Then Return, 0
      
      ;-- If Anode 2 out of range
      If (Anode1 LT 0) or (Anode1 GT 63) Then Return, 0
      
      ;
      ;-- Selection starts--
      ;
      Case 1 Of
      (Anode1 EQ 0): Begin
          If (Anode2 EQ 1) OR (Anode2 EQ 8) Then  Type=2 Else $
          If (Anode2 EQ 9) Then  Type= 3 Else $
          If (Anode2 GT 1) And (Anode2 LT 64) Then  Type=1 Else $
           Type = 0;
          End
      (Anode1 EQ 7): Begin
          If (Anode2 EQ 6) OR (Anode2 EQ 15) Then  Type=2 Else $
          If (Anode2 EQ 14) Then  Type= 3 Else $
          If (Anode2 GE 0) And (Anode2 LT 64) Then  Type=1 Else $
           Type = 0;
          End
      (Anode1 EQ 56): Begin  
          If (Anode2 EQ 57) OR (Anode2 EQ 48) Then  Type=2 Else $
          If (Anode2 EQ 49) Then  Type= 3 Else $
          If (Anode2 GE 0) And (Anode2 LT 64) Then  Type=1 Else $
           Type = 0;
          End       
      (Anode1 EQ 63): Begin
          If (Anode2 EQ 62) OR (Anode2 EQ 55) Then  Type=2 Else $
          If (Anode2 EQ 54) Then  Type= 3 Else $
          If (Anode2 GE 0) And (Anode2 LT 64) Then  Type=1 Else $
          Type = 0;
          End
      (Anode1 MOD 8) EQ 0: Begin
          If (Anode2 EQ Anode1+1) OR (Anode2 EQ ANode1 -8) OR (Anode2 EQ ANode1 +8) Then Type =2 Else $
          If (Anode2 EQ Anode1+9) OR (Anode2 EQ ANode1-7) Then Type =3 Else $
          If (Anode2 GE 0) And (Anode2 LT 64) Then  Type=1 Else $
           Type = 0
          End
      (Anode1 MOD 8) EQ 7: Begin
          If (Anode2 EQ Anode1-1) OR (Anode2 EQ ANode1 -8) OR (Anode2 EQ ANode1 +8) Then Type =2 Else $
          If (Anode2 EQ Anode1+7) OR (Anode2 EQ ANode1-9) Then Type =3 Else $
          If (Anode2 GE 0) And (Anode2 LT 64) Then  Type=1 Else $
           Type = 0
          End 
      (Anode1 GT 0) And (Anode1 LT 7): Begin
          If (Anode2 EQ Anode1+1) OR (Anode2 EQ ANode1 -1) OR (Anode2 EQ ANode1 +8) Then Type =2 Else $
          If (Anode2 EQ Anode1+7) OR (Anode2 EQ ANode1+9) Then Type =3 Else $
          If (Anode2 GE 0) And (Anode2 LT 64) Then  Type=1 Else $
           Type = 0
          End
      (Anode1 GT 56) And (Anode1 LT 63): Begin
          If (Anode2 EQ Anode1+1) OR (Anode2 EQ ANode1 -1) OR (Anode2 EQ ANode1 -8) Then Type =2 Else $
          If (Anode2 EQ Anode1-7) OR (Anode2 EQ ANode1-9) Then Type =3 Else $
          If (Anode2 GE 0) And (Anode2 LT 64) Then  Type=1 Else $
           Type = 0
          End    
      (Anode1 GT 8) And (Anode1 LT 56): Begin
          If (Anode2 EQ Anode1+1) OR (Anode2 EQ ANode1 -1) OR (Anode2 EQ ANode1 +8) OR (Anode2 EQ ANode1 -8) Then Type =2 Else $
          If (Anode2 EQ Anode1+7) OR (Anode2 EQ ANode1+9) OR (Anode2 EQ Anode1-7) OR (Anode2 EQ ANode1-9) Then Type =3 Else $
          If (Anode2 GE 0) And (Anode2 LT 64) Then  Type=1 Else $
           Type = 0
          End
          
      Else:  Type = 0
      EndCase
      
      Return, Type
End