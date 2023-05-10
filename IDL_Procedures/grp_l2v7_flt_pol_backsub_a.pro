Pro Grp_L2v7_Flt_Pol_BackSub_a, Crab_Pol_Files, PCA_bgdfile , title=title
; This is to deal with polarization_a which is used to take into account of the parralactic angle.
; The only diffrence is that the filename has 'a.txt' instead of '.txt'
  ; This is created to background subtract the scatter angle histograms.
  ; this uses 2 files.
  ; The crab files are processed through grp_l2v7_flt_polarization (txt file)
  ; The background pca file is generated via grp_l2v

  ;Notes: -Flow-
  ;Basic structure of the files
  ; Crab files are per sweep column files with two columns, angle and counts.
  ;         Error can be inferred as squareroot.
  ; PCA background file has Erange, counts, error in a line . so that needs to be extracted in that form.
  ;
  ;Flow of the program
  ;   Read the files.
  ;   Subtract and plot individual plots
  ;   Add them with proper error propagation.
  ;
  ;   2/3/2020
  ;   Adding a fitting funciton.
  ;
  ;   To-do-list
  ;   Need to change the specific no. of bins to file specific so it is versatile.
  ;   2/16/2020
  ;   Generating a text file with the fit values, errors, the data, etc. for F test.
  ;
  ;   3/9/20
  ;   Need to change the sinosoidal to cos2T from (cosT)^2
  ;
  ;   08/06/20
  ;   No need to change this is better form where C1 is the center line and
  ;   C2 is the amplitude that vanishes when there is no polarization.
  ;
  ;   Generating the final output as a text file so we can generate a confidence plot
  ;
  ;




  IF Keyword_Set(Title) Eq 0 Then title = 'Untitled' else title=title

  cd,cur=cur
  ;
  ;Read the PCA file and get the values in an array.
  ;
  openr, lun1, pca_bgdfile, /get_lun
  data = ''
  readf, lun1, data
  readf, lun1, data
  readf, lun1, data
  readf, lun1, data
  print, data
  Free_lun, lun1

  ; The last character is non space so that is messing with the last error file so.
  data= data+' '

  ; Elow
  pos0 = 0
  post = strpos(data,'.',pos0)
  pos1 = strpos(data,' ',post)

  ; Ehi
  pos0 = pos1
  post = strpos(data,'.',pos0)
  pos1 = strpos(data,' ',post)

  ;Chi
  pos0 = pos1
  post = strpos(data,'.',pos0)
  pos1 = strpos(data,' ',post)

  Bgd_cnt = dblarr(9)
  Bgd_err = dblarr(9)
  ;there are 9 sweeps.
  ; 92sweep is 1st(or 0th position in array)
  for i =0, 8 do begin
    pos0 = pos1
    post = strpos(data,'.',pos0)
    pos1 = strpos(data,' ',post)
    Cnt = double(strmid(data,pos0, pos1-pos0))

    pos0 = pos1
    post = strpos(data,'.',pos0)
    pos1 = strpos(data,' ',post)
    Cnt_err = double(strmid(data,pos0, pos1-pos0))

    Bgd_cnt[i]=Cnt
    Bgd_err[i]=Cnt_err

  endfor
  Print, Bgd_Cnt, Bgd_err

  ; Now we read the Crab Files and make sure we have the right sweeps.
  Crab_Files = FILE_SEARCH(Crab_Pol_Files)          ; get list of EVT input files
  nfiles = n_elements(Crab_Files)
  print, nfiles , '  This should be 9'

  Readcol, Crab_Files[0], Ebin, Counts, format='F,F'
  

  Crab_Nbins= N_elements(Ebin)
  Bsize = Ebin[1]-Ebin[0]

  Crab_array = DblArr(Crab_Nbins,9)   ; 18 bin x 9 files


  for p = 0, nfiles-1 do begin
    Readcol, Crab_Files[p], Ebin, Counts, format='F,F'

    filename = crab_files[p]
    pos0 = strpos(filename,'Sweep',0)
    pos1 = strpos(filename,'_Pola.txt',0)
    swp_no = fix(strmid(filename, pos0+6, pos1-pos0-6))
    Print, Swp_No
    case swp_no of
      92: xpos = 0
      93: xpos = 1
      94: xpos = 2
      95: xpos = 3
      96: xpos = 4
      97: xpos = 5
      98: xpos = 6
      99: xpos = 7
      100:xpos = 8
      Else: print, 'INVALID'
    endcase
    
    Crab_array[*,xpos]=Counts
  endfor

  ;===================

  ;Now divide the background evenly into the number of bins
  ;And create an array of that.
  Bgd_Cnt_arr = DblArr(Crab_Nbins,9)
  Bgd_Cnt_err = DblArr(Crab_Nbins,9)

  for i = 0, 8 do begin
    TScl_Bgd = DblArr(Crab_Nbins)+Bgd_Cnt[i]
    Scl_Bgd = TScl_Bgd/Crab_Nbins
    Bgd_Cnt_arr[*,i]= Scl_bgd

    TScl_Err = DblArr(Crab_Nbins)+Bgd_Err[i]
    ; Scl_Err = TScl_Err/Crab_Nbins
    Scl_Err = Sqrt(Tscl_Err^2/ (Crab_NBins))

    Bgd_Cnt_err[*,i]= Scl_err
  endfor


  Main_Crab=DblArr(Crab_Nbins)
  Main_Crab_err = Dblarr(Crab_Nbins)

  CgPS_Open, title+'_Flt_Pol_BackSub.ps', Font =1, /LandScape
  cgLoadCT, 13


  ;Now we subtract each sweep with its respective bgd.
  i = 0
  for i = 0, 8 do begin
    crab = Crab_array[*,i]
    crab_err = sqrt(abs(crab))

    bgd  = bgd_cnt_arr[*,i]
    bgd_err = bgd_cnt_err[*,i]

    print, total(Crab)
    Print, total(bgd)

    temp_sub = Crab-Bgd
    Main_Crab = Main_Crab+temp_Sub

    temp_err = crab_err*Crab_err + Bgd_err*Bgd_err
    main_Crab_err = main_Crab_err+temp_err

    Xval = Indgen(Crab_Nbins)*Bsize
    Xval1 = Xval+(Bsize/2.0)
    Xerr = FltArr(Crab_Nbins)+(Bsize/2.0)

    ymax = max(Crab)*1.2

    Cgplot, Xval1,Crab, psym=10, color='navy',$
      Err_ylow=Crab_err, Err_yhigh=Crab_err,  /err_clip, Xstyle=1, Xrange= [0,360], xtickinterval=45,$
      Title='Scat Angle Histogram for Sweep '+Strn(i+92), yrange=[0,ymax], ytitle='Counts', xtitle='Azi Scat Angle'
    CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')

    CgErase

    Cgplot, Xval1,Crab, psym=10, color='navy',$
      Err_ylow=Crab_err, Err_yhigh=Crab_err,  /err_clip, Xstyle=1, Xrange= [0,360], xtickinterval=45,$
      Title='Scat Angle Histogram for Sweep '+Strn(i+92), yrange=[0,ymax], ytitle='Counts', xtitle='Azi Scat Angle'
    Cgoplot,XVal1, Bgd, psym=10, color='red',Err_ylow=bgd_err, Err_yhigh=bgd_err,  /err_clip

    ;  CgText, !D.X_Size*0.70,!D.Y_Size*0.0,'Tot Src+Back='+STRN(total(Crab))+'+/-'+Strn(Sqrt(total(crab_err*crab_err))),/DEVICE, CHarSize=1.7,Color=CgColor('Navy')
    ;  CgText, !D.X_Size*0.70,!D.Y_Size*(-0.035),'Tot Bgd='+STRN(total(Bgd))+'+/-'+Strn(Sqrt(total(bgd_err*bgd_err))),/DEVICE, CHarSize=1.7,Color=CgColor('Red')
    ;  CgText, !D.X_Size*0.70,!D.Y_Size*(-0.07),'Tot Crab ='+STRN(total(Temp_Sub))+'+/-'+Strn(Sqrt(total(temp_err))),/DEVICE, CHarSize=1.7,Color=CgColor('Navy')

    T_bgd_err = Sqrt(total(bgd_err*bgd_err))
    T_Src_err = Sqrt(total(crab_err*crab_err))
    T_temp_err = Sqrt(total(temp_err))
    CgText, !D.X_Size*0.75,!D.Y_Size*0.0,'Total Src+Bgd='+STRN(FIX(total(Crab)))+'+/-' + STRn(FIX(T_Src_Err)),/DEVICE, CHarSize=1.7,Color=CgColor('Navy')
    CgText, !D.X_Size*0.75,!D.Y_Size*(-0.035),'Total Bgd='+STRN(FIX(total(Bgd)))+'+/-' + STRn(FIX(T_Bgd_Err)),/DEVICE, CHarSize=1.7,Color=CgColor('Red')
    CgText, !D.X_Size*0.75,!D.Y_Size*(-0.07),'Total Src='+STRN(FIX(total(Temp_Sub)))+'+/-' + STRn(FIX(T_temp_err)),/DEVICE, CHarSize=1.7,Color=CgColor('Red')

    CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')

    Cgerase
  endfor

  CgPS_Close
  Temp_Str = Cur+'/'+title+'_Flt_Pol_BackSub.ps'
  CGPS2PDF, Temp_Str,delete_ps=1,UNIX_CONVERT_CMD='pstopdf'

  ymax = max(Main_Crab)*1.2
  Main_err = Sqrt(Main_Crab_err)
  help, main_crab_err
  Tot_Main_err = Sqrt(total(Main_Crab_err))

  ;== Fitting

  Xfit1 = 2*!Pi*Xval1/360
  Main_HIst = Main_Crab
  Main_Hist_err = Main_Err
  A0 = Avg(Main_Hist)
  A1 = Max(Main_Hist)-Avg(Main_Hist)
  A2 = 1

  ;=== Some constraints
  Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)

  ;Par[1].limited(0) = 1
  ;Par[1].limits(0)  = Avg(Main_Hist)-Min(Main_Hist)
  Par[1].limited(0) = 1
  Par[1].limits(0)  = 1
  ;Par[1].limited(1) = 1
  ;Par[1].limits(1) = Max(Main_Hist)-Min(Main_HIst)+200

  Par[*].Value = [A0,A1,A2]
  Print, 'PAR'
  Print, Par
  ;Print, Avg(Final_Histogram)-Min(Final_Histogram), Max(Final_Histogram)-Min(Final_Histogram)+200

  ;=== Fitting Function ===
  ;expr = 'P[0] + P[1]*(cos(P[2]-X))^2'
  expr = 'p[0]+P[1]* cos(2*(X-P[2]))'
  Fit = mpfitexpr(expr, Xfit1, Main_Hist, Main_Hist_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/(Main_Hist_Err*Main_Hist_Err))
  print, fit, '**'
  Print, Er


  DOF     = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
  PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
  Print, BEstNorm , ' Sino Chi2, Dof:', DOF
  XFit2 =2*!Pi*FINDGEN(360)/360
  fitted = Fit[0] + Fit[1]*cos(2*(Xfit2-Fit[2]))

  Xfit1 = XFit1*360/(2*!PI)
  XFit2 = XFit2*360/(2*!PI)
  ;;Oplot, XFit1, fitted, Color=CgColor('Red')

  Print, Fit
  Print, PCERROR

  Modulation_Factor = Float(Fit[1]/float(Fit[0]))
  print, modulation_Factor

  Temp_Err_3 =  Modulation_Factor*Sqrt( (PCError[0]/Fit[0])^2 + (PCError[1]/Fit[1])^2 )
  ;Temp_Err_2 = SQRT( PCError[1]*PCError[1] + Temp_Err_1 * Temp_Err_1 )
  ;Temp_Err_3 = SQRT( ((PCError[1]/Fit[1])^2) + ((TEmp_Err_1/(Fit[1]+2*Fit[0]))^2)  )

  Modulation_Factor_Er = Modulation_Factor*Temp_Err_3
  Chisqr = (BESTNORM / DOF)
  Fit_Text11 = String(Format= '((F5.2,X))',Modulation_Factor)
  Fit_Text12 = String(Format= '((F5.2,X))',Modulation_Factor_Er)
  Fit_Text1 = Fit_text11+'+/-'+Fit_Text12
  Fit_Text5 = Strn(Fix(Fit[0]))+'+'+Strn(Fix(Fit[1]))+' Cos (2(X -'+Strn(Fit[2])+') )'
  Fit_Text2 = String(Format= '((F5.2,X))',Chisqr)


  CgPS_Open, title+'Main_Flt_Pol_BackSub.ps', Font =1, /LandScape
  cgLoadCT, 13
  CgPlot, Xval1,Main_Crab, psym=10,Err_ylow=main_err, Err_yhigh=main_err,  /err_clip $
    ,Xstyle=1, Xrange= [0,360], xtickinterval=45,err_width=0, thick=0, Err_Xhigh = Xerr, Err_Xlow=xerr $
    , yrange=[0,ymax], ystyle=1, ytitle='Counts', Xtitle='Azi Scat Angle', title='Total Scat angle Histogram (Celes Cord)'
  CgErase

  CgPlot, Xval1,Main_Crab, psym=10,Err_ylow=main_err, Err_yhigh=main_err,  /err_clip $
    ,Xstyle=1, Xrange= [0,360], xtickinterval=45,err_width=0, thick=0, Err_Xhigh = Xerr, Err_Xlow=xerr $
    , yrange=[0,ymax], ystyle=1, ytitle='Counts', Xtitle='Azi Scat Angle', title='Total Scat angle Histogram (Celes Cord)'
  CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')
  ;CgText, !D.X_Size*0.6,!D.Y_Size*0.0,'Total Counts='+STRN(total(Main_Crab)) +'(+/- '+Strn(tot_main_err)+')',/DEVICE, CHarSize=1.7,Color=CgColor('Black')
  CGoplot, Xfit2, Fitted, COlor='red'
  CgText,  !D.X_Size*0.6,!D.Y_Size*0.85, 'Modulation ('+CgGreek('mu')+')='+ Fit_Text1  , Color=CgColor('Black'),/DEVICE, CharSize =1.7
  CgText,  !D.X_Size*0.6,!D.Y_Size*0.82, 'Reduced Chisqr='+ Fit_Text2  , Color=CgColor('Black'),/DEVICE, CharSize =1.7
  CgText, !D.X_Size*0.6,!D.Y_Size*(-0.03),Fit_Text5,/DEVICE, CHarSize=1.7,Color=CgColor('Black')

  CgErase


  ;
  ;=== Now fit straight line ==
  ;
  Xfit3  = Xval1
  Final_histogram = Main_Crab
  Final_Histogram_err = Main_Err

  P0 = Avg(final_histogram)
  Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 1)

  Par[*].Value = [P0]

  Expr = 'P[0]'
  PRint, 'Strt'
  Print, 'P0=', P0
  Fit = mpfitexpr(expr, Xfit3, Final_Histogram, Final_Histogram_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/(Final_Histogram_Err*Final_Histogram_Err))
  Print, Fit
  Print, Er

  DOF     = N_ELEMENTS(XFit3) - N_ELEMENTS(Par) ; deg of freedom
  DOF = DOF ; since we fixed the P1
  Print, N_elements(main_Crab)
  Print, DOF
  PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
  Chisqr = (BESTNORM / DOF)
  Print, BEstnorm, 'Line Chi2 Dof:', DOF
  Fitted = Fit[0]+ 0.0*Xfit3

  Fit_Text2= STring(Format= '("Constant=" ,(F6.1,X)," +/- ",(F4.1) )',Fit[0], PCERROR[0])
  Fit_Text3= ''

  Fit_Text4 = String(Format= '((F5.2,X))',Chisqr)


  CgPlot, Xval1,Main_Crab, psym=10,Err_ylow=main_err, Err_yhigh=main_err,  /err_clip $
    ,Xstyle=1, Xrange= [0,360], xtickinterval=45,err_width=0, thick=0, Err_Xhigh = Xerr, Err_Xlow=xerr $
    , yrange=[0,ymax], ystyle=1, ytitle='Counts', Xtitle='Azi Scat Angle', title='Total Scat angle Histogram (Celes Cord)'
  CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')
  ;CgText, !D.X_Size*0.6,!D.Y_Size*0.0,'Total Counts='+STRN(total(Main_Crab)) +'(+/- '+Strn(tot_main_err)+')',/DEVICE, CHarSize=1.7,Color=CgColor('Black')

  CgOPlot, Xfit3, Fitted, Color=CgColor('red')
  CgText,  !D.X_Size*0.6,!D.Y_Size*0.85, Fit_Text2 , Color=CgColor('Black'),/DEVICE, CharSize =1.7

  CgText,  !D.X_Size*0.6,!D.Y_Size*0.82, 'Reduced Chisqr='+Fit_Text4  , Color=CgColor('Black'),/DEVICE, CharSize =1.7

  CgPS_Close
  Temp_Str = Cur+'/'+title+'Main_Flt_Pol_BackSub.ps'
  CGPS2PDF, Temp_Str,delete_ps=1,UNIX_CONVERT_CMD='pstopdf'


  Openw, lun1, 'MainHistogram.txt', /Get_lun
  for i = 0, n_elements(Main_Crab)-1 do begin
    printf, lun1, xval1[i],Main_Crab[i], Main_Err[i]
  endfor
  Free_lun, lun1
End