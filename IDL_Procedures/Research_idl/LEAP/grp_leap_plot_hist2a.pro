Pro Grp_leap_Plot_hist2a, Src, Back,  title=title

  ; temporarily  combining to scale according to counts
  ; this will eventually be scaling from both.
 ; Text_title = 'r126_r128'
  Plot_title= 'Co57 Pol_UnPol'
  title = 'pol_unpol'
  
  ; Default bin size is 5 and increment of 5
  cd, cur=cur
  REadCol, Src, X, Src_Cnt, Src_Err
  ReadCol, back, X1, Back_Cnt, Back_Err

  Src_Cnt = Src_Cnt[0:N_Elements(Src_Cnt)-2]
  Back_Cnt= Back_Cnt[0:N_Elements(Back_Cnt)-2]
  Src_Err = Src_err[0:N_Elements(Src_Err)-2]
  Back_Err= Back_Err[0:N_elements(Back_Err)-2]
  X = X[0:N_Elements(X)-2]
  X1= X1[0:N_Elements(X1)-2]
  
  ; temporarily  combining to scale according to counts
  Text_title = 'Combined'
  title= 'Pol_Unpol'
  cd, cur=cur
  REadCol, Pol, Angle, pol_Cnt, Pol_Err
  ReadCol, UnPol, Ang1, UnPol_Cnt, UnPol_Err

  Scl_factor = Total(Pol_Cnt)/ total(UnPol_Cnt)
  Scaled_Unpol = Unpol_Cnt*Scl_Factor
  Help, scaled_Unpol

  Help,UnPol_Cnt

  Temp_Tot_Count= Pol_cnt/Scaled_UnPol

  ; Scl_Factor=1
  Scl_Factor1 = TOtal(Pol_Cnt)/Total(Temp_Tot_Count)
  ;  Print, Scl_Factor1
  Tot_Count = Temp_Tot_Count * Scl_Factor1

  ;  tot_Count = DblArr(N_Elements(pol_Cnt))
  ;
  ;
  ;  For i = 0, N_elements(Pol_Cnt)-1 do begin
  ;
  ;      If UnPol_Cnt[i] GT 0 Then Tot_Count[i] = Pol_Cnt[i]/ Scaled_UnPol[i] Else UnPol_Cnt[i] = [0.0]
  ;
  ;  Endfor

  ;Tot_Err = Sqrt(Src_Err*Src_ERr+ Bgd_Err*BGd_Err)

  CgPs_Open, title+'.ps', Font =1, /LandScape
  cgLoadCT, 13

  CGPlot, Angle, Pol_Cnt, PSYm=10, Color='Blue', XTICKINTERVAL=40
  CgOplot, Angle, Scaled_UNpol, PSYM=10, COlor='RED'
  CGOplot, Angle, Tot_Count, PSYM=10, COlor='black'
  CGErase

  CgPlot, Angle, Tot_Count, PSYM=10, Xrange=[0,360], XTICKINTERVAL=40
  CgPs_Close
  Temp_Str = Cur+'/'+title+'.ps'
  CGPS2PDF, Temp_Str,delete_ps=1


End