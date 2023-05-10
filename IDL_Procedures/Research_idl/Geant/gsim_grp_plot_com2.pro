Pro Gsim_Grp_Plot_Com2, fsearch_Str, title


;
; This is plot couple of the combined plots to see the differences.
;

  Files = FILE_SEARCH(fsearch_str)
  print, n_elements(Files)

  nfiles = n_elements(Files)
  Xarray = INDGen(1000)
  MainHist1 = DblARr(1000)
  MainHist1_Err = DblArr(1000)

  TempHistArr = DblArr(nfiles,1000)
  TempHistErrArr = DblArr(nfiles,1000)
  
  Xmin2 =60
  Xmax2 =500 
     CGPlot,Xarray,MainHist1,/NODATA,$
        /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[Xmin2,Xmax2], YRange=[1E-8,2],Title='Comparing files',$
        Xtitle= 'Energy (keV)', YTitle=' Counts / s / keV '

    colorarr =['blue','red']
    for p = 0, nfiles-1 do begin
      fname = Files[p]
      
      print, fname
      ReadCol,fname, Temp_Hist, Temp_Hist_Err, format='D,D'

      tempHistArr[p,*] = Temp_Hist[*]
      TempHistErrArr[p,*] = Temp_Hist_Err[*]

      
      CGOplot, Xarray , Temp_HIst, color=colorarr[p]
    endfor

End