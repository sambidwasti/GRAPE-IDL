Pro Grp_leap_Plot_hist1, Pol, UnPol, Scl=Scl, title=title

; temporarily  combining to scale according to counts
 ptitle = 'Pol UnPol 96'
  title= 'Pol_Unpol'
  cd, cur=cur
  REadCol, Pol, Angle, pol_Cnt, Pol_Err
  ReadCol, UnPol, Ang1, UnPol_Cnt, UnPol_Err

  Scl_factor = Total(Pol_Cnt)/ total(UnPol_Cnt)
  Scaled_Unpol = Unpol_Cnt*Scl_Factor
  
  Scl_UnpolErr = UNPol_Err*Scl_Factor
  Help, scaled_Unpol
  
  
  
  Print, Pol_Cnt
  Print
  Print, UNPol_Cnt
  Print
  Print,Scaled_UnPol
  Help,UnPol_Cnt
  
  Temp_Tot_Count= Pol_cnt/Scaled_UnPol
  Temp_tot_count_err = Temp_Tot_Count*Sqrt((Pol_Err/Pol_Cnt)^2 + (Scl_UNPolErr/Scaled_UnPol)^2)
  
 ; Scl_Factor=1
  Scl_Factor1 = TOtal(Pol_Cnt)/Total(Temp_Tot_Count)
;  Print, Scl_Factor1
  Tot_Count = Temp_Tot_Count * Scl_Factor1
  Tot_err = Temp_Tot_Count_Err * Scl_Factor1
  
;  tot_Count = DblArr(N_Elements(pol_Cnt))
;  
;  
;  For i = 0, N_elements(Pol_Cnt)-1 do begin
;      
;      If UnPol_Cnt[i] GT 0 Then Tot_Count[i] = Pol_Cnt[i]/ Scaled_UnPol[i] Else UnPol_Cnt[i] = [0.0]
;    
;  Endfor
  
 ; Tot_Err = Sqrt(Src_Err*Src_ERr+ Bgd_Err*BGd_Err)

  CgPs_Open, title+'.ps', Font =1, /LandScape
  cgLoadCT, 13

  CGPlot, Angle, Pol_Cnt, PSYm=10, Color='Blue', XTICKINTERVAL=40, title=ptitle
  CgOplot, Angle, Scaled_UNpol, PSYM=10, COlor='RED'
  CGOplot, Angle, Tot_Count, PSYM=10, COlor='black'
  CGErase

  CgPlot, Angle, Tot_Count, PSYM=10, Xrange=[0,360], XTICKINTERVAL=40, title=ptitle, Err_ylow= Tot_err, Err_YHigh=Tot_Err
  CgPs_Close
  Temp_Str = Cur+'/'+title+'.ps'
  CGPS2PDF, Temp_Str,delete_ps=1


End