
Function EventClass, Anode1, Anode2
; *************************************************************************
; *           Identifying the Event Class Depending on 2 Anodes           *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read in the Anode Numbers and Output the Event Class        *
; *           Subroutine/Function For other Procedures.                   *
; *           Specially For Calibration Procedures                        *
; *                                                                       *
; * Usage:  Result = EventClass(AnodeNumber1, AnodeNumber2)               *
; *                                                                       *
; * Inputs:   Anode1= Anode Number of the 1st Anode                       *
; *           Anode2= Anode Number of the 2nd Anode                       *
; *                                                                       *
; * Returns:  -1 for Invalid                                               *
; *           3 for PC Event                                              *
; *           2 for CC Event                                              *
; *           4 for PP Event                                              *
; *           1 for C Event   
; *           7 for OThers.      
;                                                                         *
; * Involved Non-Library Procedures:                                      *
; *          - Anode_Type.pro   (0-63)                                    *
; *                                                                       *
; * Error Handling: For Invalid Anode Number Return Invalid Type =0       *
; *                                                                       *
; * Author: 5/10/13   Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; * April 10, 2018                       
; *         Changed the AnodeType to Anode_Type                           *
; *         Few output variables. Need to verify older code to check.
; *************************************************************************
; *************************************************************************
    Class = -1
    If((Anode_Type(Anode1)EQ 1) And (Anode_Type(Anode2)EQ 2)) Or ((Anode_Type(Anode2)EQ 1) And (Anode_Type(Anode1)EQ 2)) Then Class= 3 Else $
    If((AnodeType(Anode1)EQ 1) And (AnodeType(Anode2)EQ 1)) Then Class= 2 Else $
    If((AnodeType(Anode1)EQ 2) And (AnodeType(Anode2)EQ 2)) Then Class= 4 Else $  
    Class = 7
    Return, Class
End