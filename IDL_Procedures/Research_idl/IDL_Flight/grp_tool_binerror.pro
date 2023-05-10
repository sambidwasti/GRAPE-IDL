Pro Grp_tool_BinERror
  ;
  ;  Calorimeter element anode ids (0..63)
  ;
  Cal_anodes = [0,1,2,3,4,5,6,7,8,15,16,23,24,31,32,39,40,47,48,55,56,57,58,59,60,61,62,63]


  Bin_Energy = 5
   ;
  ;=========================================================================================
  ;
  ;  Plastic element anode Ids (0..63)
  ;
  Pls_anodes = [9,10,11,12,13,14,17,18,19,20,21,22,25,26,27,28,29,30,33,34,35,36,37,38,41, $
    42,43,44,45,46,49,50,51,52,53,54]

  ;
  ;
  ;=========================================================================================
  ;
  ;
  ;  Module position numbers for the 24 flight detectors (0..31)    Edited from 16 to 24: SW
  ;  These position numbers correspond to one of the 32 positions on the MIB.
  ;
  Module_Pos = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]

  ;
  ;
  ;=========================================================================================
  ;
  ;  Module serial number for each of the 24 flight detectors ;     Edited from 16 to 24: SW
  ;  The serial number identifiers the specific piece of hardware
  ;
  module_serno = [20,0,22,4,2,0,3,18,0,21,5,6,23,7,8,0,0,9,10,1,11,12,26,0,13,15,0,16,19,25,0,27]

  ;
  ;===========================================================================================
  ;   INTRODUCTION OF THE FLAGGED ANODES  ---(SW)---
  ;   Flagged Anode and Respective Module Pos No.
  Flagged_Anode = [ 34,8, 49, 45, 25,   33,   41,   7]
  Respect_Module= [ 3 , 11, 13, 14, 7,    7,    7,    9]
  ;Serial No.       4   6   7   8   18    18    18    21


  
  ;
  ;=========================================================================================
  ;
  ;  Read in energy calibration data.
  ;
  Ecal_m     = fltarr(32,64)
  Ecal_b     = fltarr(32,64)
  Ecal_m_err = fltarr(32,64)
  Ecal_b_err = fltarr(32,64)

  Slopes    = fltarr(64)
  Offsets   = fltarr(64)
  SlopeErr  = fltarr(64)
  OffsetErr = fltarr(64)

  nmodules   = n_elements(module_pos)


  cd, cur=cur
  cur1 = cur+'/'

  ;                                           Swapped this section from Grp_l1process to fix for new naming. SW
  ;  Read in energy calibration data.
  ;  In this case, there is one file for each module.
  ;  Each file contains energy calibration parameters for each of 64 anodes.
  ;  The numbers in each file / variable name are the module serial numbers.
  ;
  For i = 0,31 do begin
    If (module_serno[i] Eq 0) Then Continue
    filename = strjoin([ 'FM1', strn(module_serno[i], format='(I02)', padch='0'), '_Energy_Calibration.txt'])
       readcol, filename, Anodes, Slopes, SlopeErr, Offsets, OffsetErr, skipline=10, /silent
    Ecal_m[i,*]     = Slopes
    Ecal_b[i,*]     = Offsets
    Ecal_m_err[i,*] = SlopeErr
    Ecal_b_err[i,*] = OffsetErr
  Endfor

;
;Ecal stores all the energy calibration info.
;


Filename ='Avg_Cal.txt'
    Openw, lun, Filename, /Get_lun
    PRintf, Lun, 'Cal   FM  Slope Slope_err Const Const_Err 5KevChan 5kevError'
    Filename ='Avg_pla.txt'
    Openw, lun1, Filename, /Get_lun
    PRintf, lun1, 'Pla   FM  Slope Slope_err Const Const_Err 5KevChan 5kevError'

 For i = 0,31 do begin
   If (module_serno[i] Eq 0) Then Continue
   
     Temp_cal_slope = 0.0
     Temp_cal_slope_error =0.0
     
     temp_cal_cons = 0.0
     Temp_Cal_cons_error = 0.0 
     
     temp_pla_cons = 0.0
     temp_pla_cons_error = 0.0
     
     Temp_pla_Slope = 0.0
     Temp_pla_Slope_error = 0.0
     
    For j = 0,63 do begin
      
      C = where(Cal_anodes eq j, count)
      D = where(pls_anodes eq j, count1)
      If count gt 0 then begin
         Temp_cal_slope = Temp_Cal_Slope + Ecal_m[i,j] 
         Temp_cal_Cons  = Temp_Cal_Cons  + Ecal_b[i,j]
         
         Temp_Cal_slope_Error = Temp_Cal_Slope_Error + Ecal_m_err[i,j]*Ecal_m_err[i,j]
         Temp_Cal_Cons_error  = Temp_Cal_Cons_Error  + Ecal_b_err[i,j]*Ecal_b_err[i,j]
      Endif Else if count1 gt 0 then BEgin
        Temp_pla_slope = Temp_pla_Slope + Ecal_m[i,j]
        Temp_pla_Cons  = Temp_pla_Cons  + Ecal_b[i,j]

        Temp_pla_slope_Error = Temp_pla_Slope_Error + Ecal_m_err[i,j]*Ecal_m_err[i,j]
        Temp_pla_Cons_error  = Temp_pla_Cons_Error  + Ecal_b_err[i,j]*Ecal_b_err[i,j]        
      EndIf

    Endfor
    
    Avg_Cal_Slope =  Temp_Cal_Slope/28
    Avg_Pla_Slope = Temp_Pla_Slope/36
  ;  Print, Avg_Cal_Slope, Avg_Pla_Slope
    
    Avg_Cal_Cons = Temp_Cal_Cons/28
    Avg_Pla_Cons = Temp_Pla_Cons/36
  ; Print, Avg_Cal_Cons, Avg_Pla_Cons

    Avg_Cal_Slope_Error = Sqrt(Temp_Cal_Slope_Error)/28
    Avg_Pla_Slope_Error = Sqrt(Temp_Pla_Slope_Error)/36
   ; Print, Avg_Cal_Slope_Error, Avg_Pla_Slope_Error
   
   Avg_Cal_Cons_Error = Sqrt(Temp_Cal_Cons_Error)/28
   Avg_Pla_Cons_Error = Sqrt(Temp_Pla_Cons_Error)/36
   
   Kev5_Chan_cal = (5-Avg_Cal_Cons)/Avg_Cal_Slope
   kev5_cal_Error = Sqrt(  (Kev5_Chan_cal*Avg_Cal_Slope_Error)^2 + Avg_Cal_Cons_Error^2  )
;Print, Avg_Cal_Cons_Error, Avg_Pla_Cons_Error
 ;Temp_Str = Strn(i)+'  '+Strn(Avg_Cal_Slope)+'  '+Strn(Avg_Cal_Slope_Error)+'   '+Strn(Avg_Cal_Cons)+'  '+strn(Avg_Cal_Cons_Error)+'  '+Strn(kev5_Chan_Cal)
 PRintf, Lun, i, Avg_Cal_Slope, Avg_Cal_Slope_Error, Avg_Cal_Cons, Avg_cal_Cons_Error,kev5_Chan_cal, kev5_Cal_Error, format='(I,1X,F8.4,1X, F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'
; Temp_Str = Strn(i)+'  '+Strn(Avg_pla_Slope)+'  '+Strn(Avg_pla_Slope_Error)+'   '+Strn(Avg_pla_Cons)+'  '+strn(Avg_pla_Cons_Error)


 Kev5_Chan_pla = (5-Avg_Pla_Cons)/Avg_Pla_Slope
 kev5_Pla_Error = Sqrt(  (Kev5_Chan_pla*Avg_Pla_Slope_Error)^2 + Avg_Pla_Cons_Error^2  )
 PRintf, Lun1, i, Avg_Pla_Slope, Avg_Pla_Slope_Error, Avg_Pla_Cons, Avg_Pla_Cons_Error,kev5_Chan_pla, kev5_Pla_Error, format='(I,1X,F8.4,1X, F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'
  
 Endfor


 Free_lun, lun
 Free_lun, lun1
End