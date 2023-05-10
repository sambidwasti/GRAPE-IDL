pro Grp_XSpec_BackSub_plot, Src, Bgd

  ; This is to check the Src Sub Bgd
  ; This is designed to read in Each Sweep Src and BGd xspec data files
  ; and generate a bgd-subtracted file

  Title= 'Swp92'
  CD, Cur=Cur
  
  ReadCol, Src, Chan, Src_Cnt, Src_Err, format='D,D,D'
  ReadCol, Bgd, Chan1, Bgd_Cnt, Bgd_Err, format='D,D,D'
 
  ;Subtraction
  Tot = Src_Cnt-Bgd_Cnt
  Err = Sqrt(Src_Err*Src_err + Bgd_Err*Bgd_Err)
  
  Ebin_lo = [65,70,90 ,120,160,200]
  Ebin_hi = [70,90,120,160,200,300]
 
  Xerror = (Ebin_hi-Ebin_lo)/2
  Xerr= Xerror[1:4]
  Xarr = Ebin_lo[1:4]+Xerr
  Y = Src_Cnt[1:4]
  Yerr= Src_Err[1:4]
  
  B   = Bgd_cnt[1:4]
  BErr= Bgd_Err[1:4]


  Z = Tot[1:4]
  Zerr = Err[1:4]
    
  CgPs_Open, Title+'.ps', Font =1, /LandScape
  cgLoadCT, 13
  !P.Font=1
  
  CgPlot, Xarr,Y ,/Xlog, /Ylog, Xrange=[50,300], Xstyle=1, Yrange=[1,10], Ystyle=1, PSYM=3,$
  xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1,Err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0,$
  err_Yhigh=YErr, err_Ylow = YErr, /Err_Clip,Err_Color='black', $
  ytitle = 'c/s', xtitle ='Energy (keV)', title= title

  CgText, !D.X_Size*0.83,!D.Y_Size*0.92,'PC Events',/DEVICE, CHarSize=1.7,Color=CgColor('Black')

  CgOplot, Xarr, B, Color='Red' ,Err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0, Psym=3,$
  err_Yhigh=BErr, err_Ylow = BErr, /Err_Clip,Err_Color='Red'

  cgLegend, Colors=['Black', 'Red'], PSyms=[0,0], Location=[0.70, 0.09], $
    Titles=['Measured Total ', 'Estimated Bgd'], Length=0.03


  CgErase
  
  
  CgPlot, Xarr,Y ,/Xlog, /Ylog, Xrange=[50,300], Xstyle=1, Yrange=[0.01,10], Ystyle=1, PSYM=3,$
    xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1,Err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0,$
    err_Yhigh=YErr, err_Ylow = YErr, /Err_Clip,Err_Color='black', $
    ytitle = 'c/s', xtitle ='Energy (keV)', title= title
  CgText, !D.X_Size*0.83,!D.Y_Size*0.92,'PC Events',/DEVICE, CHarSize=1.7,Color=CgColor('Black')

  CgOplot, Xarr, B, Color='Red' ,Err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0, Psym=3,$
    err_Yhigh=BErr, err_Ylow = BErr, /Err_Clip,Err_Color='Red'
  
  cgLegend, Colors=['Black', 'Red'], PSyms=[0,0], Location=[0.70, 0.09], $
    Titles=['Measured Total ', 'Estimated Bgd'], Length=0.03

  CgErase  
  CgPlot, Xarr,Y ,/Xlog, /Ylog, Xrange=[50,300], Xstyle=1, Yrange=[1,10], Ystyle=1, PSYM=3,$
    xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1,Err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0,$
    err_Yhigh=YErr, err_Ylow = YErr, /Err_Clip,Err_Color='black', $
    ytitle = 'c/s', xtitle ='Energy (keV)', title= 'Eloss Spectra for'+ title

  CgText, !D.X_Size*0.83,!D.Y_Size*0.92,'PC Events',/DEVICE, CHarSize=1.7,Color=CgColor('Black')
  cgLegend, Colors=['Black'], PSyms=[0], Location=[0.70, 0.09], $
    Titles=['Measured Total '], Length=0.03

  CgErase
  CgPlot, Xarr,Z ,/Xlog, /Ylog, Xrange=[50,300], Xstyle=1, Yrange=[0.01,10], Ystyle=1, PSYM=3,$
    xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1,Err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0,$
    err_Yhigh=Err, err_Ylow = Err, /Err_Clip,Err_Color='black', $
    ytitle = 'c/s', xtitle ='Energy (keV)', title= 'Crab counts (Bgd Subtracted)   '+title 
    CgText, !D.X_Size*0.83,!D.Y_Size*0.92,'PC Events',/DEVICE, CHarSize=1.7,Color=CgColor('Black')
  
 
 CgPs_Close;, /Delete_PS,/PDF,UNIX_CONVERT_CMD='pstopdf'

 ;-- Create the PDF File
 Temp_Str = Cur+'/'+Title+'.ps'
 CGPS2PDF, Temp_Str,delete_ps=1,UNIX_CONVERT_CMD='pstopdf'
 
End