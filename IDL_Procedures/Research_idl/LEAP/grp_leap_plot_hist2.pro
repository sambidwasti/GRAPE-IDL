Pro Grp_leap_Plot_hist2, Src, Back,  title=title, Ener=Ener

  ; temporarily  combining to scale according to counts
  Text_title = title
  IF Keyword_Set(title) Eq 0 Then Title='Test' Else title= title
  IF Keyword_Set(Ener) Eq 0 Then Ener=0 Else Ener=1
  Bin = 'BinSize = 20'
  TableAngle = '96'
  cd, cur=cur
  REadCol, Src, X, Src_Cnt, Src_Err
  ReadCol, back, X1, Back_Cnt, Back_Err
  
  ;-- SCale Factor --
  ; The time ran recorder are time * avg lt
  data =''
  openr, lun, Src, /Get_lun
  Readf, lun, data
  print,data
        a = StrPos(data, '=', 0)
        b = StrmID(data, a+1, StrLEn(data)-a-1)
        Src_Time = double(b)
  Free_lun,lun
  Print, Src_time
  
  data =''
  openr, lun, Back, /Get_lun
  Readf, lun, data
  print,data
  a = StrPos(data, '=', 0)
  b = StrmID(data, a+1, StrLEn(data)-a-1)
  Back_Time = double(b)
  Free_lun,lun
  Print, Back_time
  
  
  Scl_Factor = Src_Time/Back_time
Print, Scl_Factor
  ;Subtract
  Scl_BAck = Back_Cnt*Scl_Factor
  Scl_BErr = Back_Err*Scl_Factor
  
  Main_Hist = Src_Cnt - Scl_Back 
  
  Main_Err = Sqrt(Src_Err*SRc_ERr + Scl_Berr*Scl_Berr)
  If Ener eq 1 then title= title+'_Ener'
  CgPs_Open, title+'.ps', Font =1, /LandScape
  cgLoadCT, 13

  CGPlot, X, Src_Cnt, PSYm=10, Color='Blue', Title=Title+TableAngle,Ytitle=' Counts', XTitle='Angle',$
    XRANGE=[0,360], XTICKINTERVAL=40
  CgOplot, X, Scl_Back, PSYM=10, COlor='RED'
  CGOplot, X, Main_Hist, PSYM=10, COlor='black', Err_Ylow=Main_Err, Err_yHigh=Main_Err
  CgLegend, Location=[0.93,0.9], Titles=['Back','Src+Bgd','Src'], Length =0, $
    SymColors = ['Red','Blue','Black'], TColors=['red', 'blue','Black'],Psyms=[1,1,1],/box, Charsize=1.2



  CGErase

  CgPlot, X, Main_Hist, PSYM=10, Xrange=[0,360], Title=Title+TableAngle,Ytitle=' Counts', XTitle='Angle',$
     XTICKINTERVAL=40, ERr_Ylow=Main_Err, Err_yHigh=Main_Err
  CgPs_Close
  Temp_Str = Cur+'/'+title+'.ps'
  CGPS2PDF, Temp_Str,delete_ps=1
  
  
  If Ener eq 1 then Text_title = Text_title+'Ener.txt' Else Text_title=Text_title+'_leap_plot_Hist2.txt'
  
  Openw, lun, Text_Title, /Get_lun
  for i = 0, N_elements(X)-1 do begin

    printf, lun, X[i], Main_Hist[i], Main_Err[i]
    
  endfor
  Free_lun, lun
  
  Print, Total(Main_Hist)
End