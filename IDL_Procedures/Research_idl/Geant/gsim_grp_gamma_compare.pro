Pro gsim_grp_gamma_compare, file1, file2, title=title, bin=bin

  ;
  ;== Read in the files and plot together. Compare teh combined gamma with the flight
  ;

  ;
  ;==== PLOT Variables
  ;
  PTitle = ' Sims 0% CT (black) vs Flight (red) '
  Xtitle = 'Energy (keV)'
  Ytitle = ' C/s/keV'

  ;Range
  Xmin  = 30
  Xmax  = 600
  Ymin  = 1E-5
  Ymax  = 1
  ;--- Current Directory
  CD, Cur = Cur

  if keyword_set(bin) ne 1 then bin = 10
  if keyword_set(title) ne 1 then title='Try'

  ReadCol, file1, Y1, Y1_err, format='F,F'
  ReadCol, File2, Z1, Z1_err, format='F,F'

  nbins = (1000/bin) + 1
  xval2 = indgen(nbins)*bin

  Y2 = DblArr(nbins)
  Z2 = DblArr(nbins)
  Y2_Err = DblArr(nbins)
  Z2_Err = DblArr(nbins)

  Cntr=0L
  for i = 0, nbins-2 do begin
    tempY = 0.0
    tempZ = 0.0

    tempYerr = 0.0
    tempZerr = 0.0
    for j = 0, bin-1 do begin

      tempY = tempY + Y1[cntr]
      tempZ = tempZ + Z1[cntr]

      tempYerr =  tempYerr + Y1_err[cntr]*Y1_err[cntr]
      tempZerr =  tempZerr + Z1_err[cntr]*Z1_err[cntr]
      cntr++
    endfor

    Y2[i] = tempY
    Z2[i] = tempZ

    Y2_Err[i] = Sqrt(tempYerr)
    Z2_Err[i] = Sqrt(tempZerr)
  endfor

  Y2 = Y2/bin
  Z2 = Z2/bin

  Y2_Err = Y2_Err/bin
  Z2_Err = Z2_Err/bin
  ;---- Opening the Device for further plots and various things -----
  CgPs_Open, Title+'_Final.ps', Font =1, /LandScape
  cgLoadCT, 13
  !P.Font=1

  xticks = loglevels([xmin,xmax])
  nticks = n_elements(xticks)

  ;--- Define the template ---
  Cgplot, Xval2,Y2, PSYM=10, XRANGE=[Xmin,Xmax],Xstyle=1, /Xlog, /Ylog, YRAnge=[Ymin,Ymax], YStyle=1,$
    title=ptitle, xtitle=xtitle, ytitle=ytitle,$
    err_Yhigh=Y2_Err, err_Ylow = Y2_Err, /Err_Clip;, xticks=nticks-1, xtickv=(xticks), Xminor=5

  CGoplot, Xval2,Z2, PSYM=10, Color='red',$
    err_Yhigh = Z2_Err, err_Ylow = Z2_Err , /Err_Clip;, Err_Color='green'

  print, total(Y2), Total(Z2)
  ;CgPlot,XVAL2, Final_Histogram, PSYM=10,CharSize=2,$
  ;  XRange=[0,max_x], XStyle=1,XTickInterval=50, $
  ;  YRange=[0,Y_Max2],/NODATA,$
  ;  XTitle=Title_X  , YTitle='Counts'
  ;
  ;;
  ;;--- Plot the Data ---
  ;;
  ;Err_YHigh = Final_Histogram_Err
  ;Err_YLow  = Final_Histogram_Err
  ;CgOPlot, XVAL2, Final_Histogram, PSYM =10, Color=CGColor('black'), $
  ;  Err_YHigh= Err_YHigh  ,Err_YLow= Err_YLow , Err_Color= CGColor('Dark gray'),/ERR_CLIP
  ;
  ;;
  ;;--- Respective Error ---
  ;;
  ;;cgErrPlot, XVal2,Final_Histogram-Final_Histogram_Err, Final_Histogram+Final_Histogram_Err, color='red'
  ;
  ;;--- The fitted function ---
  ;;
  ;Cgoplot, Xfit2, fitted, Color=CgColor('RED'), Thick = 2
  ;
  ;
  ;
  ;;
  ;; -- Bin Size
  ;;
  ;;                  CgText, !D.X_Size*0.78,!D.Y_Size*0.00, 'BINSIZE ='+STRN(BSIZE),/DEVICE, CHarSize=2.0
  ;
  ;;
  ;; --- DOF
  ;;
  ;;                  cgText, !D.X_Size*0.13,!D.Y_Size*0.00, Fit_Text5,/Device, CharSize=2.0
  ;
  ;;
  ;;Title
  ;;
  ;cgText, !D.X_Size*0.18,!D.Y_Size*0.93, Temp_Title,/Device, CharSize=3.0
  ;
  ;
  ;
  ;  ;
  ;  ;--- Fit Text1 : Centroid or modulation data
  ;  ;
  ;  ;                        XYOUTS, !D.X_Size*0.58,!D.Y_Size*0.85, Fit_Text1, Color=CgColor('RED'),/DEVICE, CharSize =2.0
  ;
  ;
  ;  CgText,  !D.X_Size*0.76,!D.Y_Size*0.97, CgGreek('mu') + '     =  '+Fit_Text11 +' ' +CgSymbol('+-')+' '+ Fit_Text12 , Color=CgColor('Black'),/DEVICE, CharSize =1.7
  ;  ;
  ;  ; --- Fitted Total Counts
  ;  ;
  ;  ;                        XYOUTS, !D.X_Size*0.58,!D.Y_Size*0.81, Fit_Text4, Color=CgColor('RED'),/Device, CharSize=2.0
  ;
  ;  ;
  ;  ; --- Fitted Total Counts
  ;  ;
  ;  ;                       XYOUTS, !D.X_Size*0.58,!D.Y_Size*0.77, 'Total Counts   ='+STRN(TOTAL(Final_Histogram)),/Device, CharSize=2
  ;
  ;  ;
  ;  ;--- More Fit Text Stuffs.
  ;  ;
  ;  ;                        XYOUTS, !D.X_Size*0.5,!D.Y_Size*(-0.05), Fit_Text3,/DEVICE, CHarSize=1.2,Color=CgColor('Blue')
  ;  ;                        XYOUTS, !D.X_Size*0.5,!D.Y_Size*(-0.08), Fit_Text2,/DEVICE, CHarSize=1.2,Color=CgColor('Red')
  ;  CgText, !D.X_Size*0.70,!D.Y_Size*0.93,'Pol Angle  ='+ Fit_Text21+' ' +CgSymbol('+-')+''+Fit_Text22, Color=CgColor('Black'),/Device, CharSize=1.7
  ;
  ;;-- Close the Device
  CgPs_Close

  ;-- Create the PDF File
  Temp_Str = Cur+'/'+Title+'_Final.ps'
  CGPS2PDF, Temp_Str,delete_ps=1



End