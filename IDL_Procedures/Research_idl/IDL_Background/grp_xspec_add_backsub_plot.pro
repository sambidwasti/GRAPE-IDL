Pro Grp_xspec_add_backsub_plot, file
  ; This is to add the background subtracted sweep files
  ;
  
  Cd, Cur=Cur
  Title='BgdSub_Tot_Crab'
  ;
  ;The objective is to plot the background subtracted summed histogram.
  ;
  ReadCol, File, Chan, Src_Cnt, Src_Err, format='D,D,D'

  Ebin_lo = [65,70,90 ,120,160,200]
  Ebin_hi = [70,90,120,160,200,300]

  Xerror = (Ebin_hi-Ebin_lo)/2
  Xerr= Xerror[1:4]
  Xarr = Ebin_lo[1:4]+Xerr
  Y = Src_Cnt[1:4]
  Yerr= Src_Err[1:4]
;  Y = Y/9
;  Yerr = Yerr/9

CgPs_Open, Title+'.ps', Font =1, /LandScape
cgLoadCT, 13
!P.Font=1


  CgPlot, Xarr,Y ,/Xlog, /Ylog, Xrange=[50,300], Xstyle=1, Yrange=[0.1,10], Ystyle=1, PSYM=3,$
    xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1,Err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0,$
    err_Yhigh=YErr, err_Ylow = YErr, /Err_Clip,Err_Color='black', $
    ytitle = 'c/s', xtitle ='Energy (keV)', title= 'Bgd Sub Eloss Spec for the Crab observation'
    
    ;-- Create the PDF File
 CgPs_Close, /Delete_PS,/PDF,UNIX_CONVERT_CMD='pstopdf'

End