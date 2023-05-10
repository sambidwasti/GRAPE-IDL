Pro Grp_leap_Plot_hist, Source, Bgd, Scl=Scl, title=title

Text_title = 'UnPol_Co57'
title= 'R121_R120'
cd, cur=cur
REadCol, Source, Angle, Src_Cnt, Src_Err
ReadCol, Bgd, Ang1, Bgd_Cnt, Bgd_Err

Tot_Counts = Src_Cnt- Bgd_Cnt
Tot_Err = Sqrt(Src_Err*Src_ERr+ Bgd_Err*BGd_Err)

CgPs_Open, title+'.ps', Font =1, /LandScape
cgLoadCT, 13

CGPlot, Angle, Src_Cnt, PSYm=10, Color='Blue'
CgOplot, Angle, Bgd_Cnt, PSYM=10, COlor='RED'
CGOplot, Angle, Tot_Counts, PSYM=10, COlor='black'
CGErase

CgPlot, Angle, Tot_Counts, PSYM=10, Xrange=[0,360]
CgPs_Close
Temp_Str = Cur+'/'+title+'.ps'
CGPS2PDF, Temp_Str,delete_ps=1

Openw, lun, Text_Title+'leap_plot_Hist.txt', /Get_lun
  for i = 0, N_elements(Angle)-1 do begin
    
    printf, lun, angle[i], Tot_Counts[i], Tot_err[i]
  endfor
Free_lun, lun
End