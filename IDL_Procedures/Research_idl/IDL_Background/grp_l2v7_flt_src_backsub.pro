Pro Grp_L2v7_Flt_Src_BackSub, Src_Pol_Files, PCA_bgdfile , title=title
  ; This is created to background subtract the scatter angle histograms.
  ; this uses 2 files.
  ; The Src files are processed through grp_l2v7_flt_polarization
  ; The background pca file is generated via grp_l2v

  ;Notes: -Flow-
  ;Basic structure of the files
  ; Sr  files are per sweep column files with two columns, angle and counts.
  ;         Error can be inferred as squareroot.
  ; PCA background file has Erange, counts, error in a line . so that needs to be extracted in that form.
  ;
  ;Flow of the program
  ;   Read the files.
  ;   Subtract and plot individual plots
  ;   Add them with proper error propagation.
  ;
  ;   To-do-list
  ;   Need to change the specific no. of bins to file specific so it is versatile.
  ;   One issue for this is about verifying the sweep numbers and defining the array position for bgd subtraction
  ;   Even the background data has number of columns for each sweep.
  ;


IF Keyword_Set(Title) Eq 0 Then title = 'Untitled' else title=title

  cd,cur=cur

  ; We read the BGd4 Files and make sure we have the right sweeps.
  Src_Files = FILE_SEARCH(Src_Pol_Files)          ; get list of EVT input files
  nfiles = n_elements(Src_Files)
  print, nfiles , '  This should be 6'
  Readcol, Src_Files[0], Ebin, Counts, format='F,F'



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

  Bgd_cnt = dblarr(nfiles)
  Bgd_err = dblarr(nfiles)
  ;Number of  sweeps depends on the seleciton
  ; The sweep number at 0th array depends on the selection.
  for i =0, nfiles-1 do begin
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

  Src_Nbins= N_elements(Ebin)
  Bsize = Ebin[1]-Ebin[0]

  Src_array = DblArr(Src_Nbins,nfiles)   ; bins x 7 files


  for p = 0, nfiles-1 do begin
    Readcol, Src_Files[p], Ebin, Counts, format='F,F'

    filename = Src_files[p]
    pos0 = strpos(filename,'Sweep',0)
    pos1 = strpos(filename,'.txt',0)
    swp_no = fix(strmid(filename, pos0+6, pos1-pos0-6))

    case swp_no of
      50: xpos = 0
      51: xpos = 1
      52: xpos = 2
      53: xpos = 3
      54: xpos = 4
      55: xpos = 5
      Else: print, 'INVALID'
    endcase
    Src_array[*,xpos]=Counts
  endfor


  ;===================

  ;Now divide the background evenly into the number of bins
  ;And create an array of that.
  Bgd_Cnt_arr = DblArr(Src_Nbins,nfiles)
  Bgd_Cnt_err = DblArr(Src_Nbins,nfiles)

  for i = 0, nfiles-1 do begin
    TScl_Bgd = DblArr(Src_Nbins)+Bgd_Cnt[i]
    Scl_Bgd = TScl_Bgd/Src_Nbins
    Bgd_Cnt_arr[*,i]= Scl_bgd       ; Dividing BGd by n 

    TScl_Err = DblArr(Src_Nbins)+Bgd_Err[i]
    ;Scl_Err = TScl_Err/Src_Nbins  
    ; Note Error might not be this way, 
    ; Might have to think in terms of each bin error adding in quadrature to get this value. 
    ; so sqrt(nbins* X^2) = Error. ; multiply by nbins because its teh same error here or else you can add X^2 nbins times. 
    ; X = sqrt(Error^2/nbins)
    Scl_Err = Sqrt(Tscl_Err^2/ (Src_NBins))
    Bgd_Cnt_err[*,i]= Scl_err       ; Dividibng Bgd Err by n

  endfor
  ; We have del b2

  Main_Src=DblArr(Src_Nbins)
  Main_Src_err = Dblarr(Src_Nbins)

  CgPS_Open, title+'_Flt_Src_BackSub.ps', Font =1, /LandScape
  cgLoadCT, 13


  ;Now we subtract each sweep with its respective bgd.
  i = 0
  for i = 0, nfiles-1 do begin
    Src = Src_array[*,i]
    Src_err = sqrt(abs(Src))
    ; del M
    ;== We are working with the full array==

    bgd  = bgd_cnt_arr[*,i]
    bgd_err = bgd_cnt_err[*,i]

    print, total(Src), i
    Print, total(bgd)

    temp_sub = Src-Bgd
    Main_Src = Main_Src+temp_Sub

    temp_err = bgd_err*bgd_err + Src_err*Src_err ; del s^2
    main_Src_err = main_Src_err+temp_err ; sum of del s^2 per file (this is an array)
    
    T_Src = Total(Src)
    T_bgd = Total(bgd)
    T_Src_Err = Sqrt(Total(Src_err*Src_err))
    T_bgd_Err = Sqrt(Total(Bgd_err*Bgd_err))
    T_Cnt = T_Src-T_Bgd
    T_Cnt_Err =Sqrt( T_Src_err*T_Src_err+ T_bgd_Err* T_bgd_Err)
    
    
    Xval = Indgen(Src_Nbins)*Bsize
    Xval1 = Xval+(Bsize/2.0)
    Xerr = FltArr(Src_Nbins)+(Bsize/2.0)

    ymax = max(Src)*1.2
    ymin = 0; -1*max(Src);min(bdg4)*1.2
    Cgplot, Xval1,Src, psym=10, color='navy',$
      Err_ylow=SRc_err, Err_yhigh=Src_err,  /err_clip, Xstyle=1, Xrange= [0,360], xtickinterval=45,$
      Title='Scat Angle Histogram for Sweep '+Strn(i+50), yrange=[ymin,ymax], ytitle='Counts', xtitle='Azi Scat Angle'
   
      CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')
     CgErase
    Cgplot, Xval1,Src, psym=10, color='navy',$
      Err_ylow=SRc_err, Err_yhigh=Src_err,  /err_clip, Xstyle=1, Xrange= [0,360], xtickinterval=45,$
      Title='Scat Angle Histogram for Sweep '+Strn(i+50), yrange=[ymin,ymax], ytitle='Counts', xtitle='Azi Scat Angle'
      
    Cgoplot,XVal1, Bgd, psym=10, color='red',Err_ylow=bgd_err, Err_yhigh=bgd_err,  /err_clip


    CgText, !D.X_Size*0.75,!D.Y_Size*0.0,'Total Src='+STRN(FIX(T_Src))+'+/-' + STRn(FIX(T_Src_Err)),/DEVICE, CHarSize=1.7,Color=CgColor('Navy')
    CgText, !D.X_Size*0.75,!D.Y_Size*(-0.035),'Total Bgd='+STRN(FIX(T_bgd))+'+/-' + STRn(FIX(T_Bgd_Err)),/DEVICE, CHarSize=1.7,Color=CgColor('Red')
    CgText, !D.X_Size*0.75,!D.Y_Size*(-0.07),'Total Cnt='+STRN(FIX(T_Cnt))+'+/-' + STRn(FIX(T_Cnt_Err)),/DEVICE, CHarSize=1.7,Color=CgColor('Red')

    CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')

    Cgerase
  endfor

  CgPS_Close
  Temp_Str = Cur+'/'+title+'_Flt_Src_BackSub.ps'
  CGPS2PDF, Temp_Str,delete_ps=1,UNIX_CONVERT_CMD='pstopdf'



  Main_err = Sqrt(Main_Src_err)     ; This is an array with error for 1 spectra but with all files.
;  help, main_crab_err
  Tot_Main_err = Sqrt(total(Main_Src_Err))

  ;== Fitting
  ;

  Xfit1 = 2*!Pi*Xval1/360
  Main_HIst = Main_Src
  Main_Hist_err = Main_Err
  A0 =  Avg(Main_Hist)
  A1 =  Max(Main_Hist)-Avg(Main_Hist)
  A2 = 1

  ;=== Some constraints
  Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)

; 
  Par[*].Value = [A0,A1,A2]

  Print, Par
  ;Print, Avg(Final_Histogram)-Min(Final_Histogram), Max(Final_Histogram)-Min(Final_Histogram)+200

  ;=== Fitting Function ===
  expr = 'p[0]+P[1]* cos(2*(X-P[2]))'
  Fit = mpfitexpr(expr, Xfit1, Main_Hist, Main_Hist_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/(Main_Hist_Err*Main_Hist_Err))
  print, fit, '**'
  Print, Er

  
  DOF     = N_ELEMENTS(XFit1) - N_ELEMENTS(Par) ; deg of freedom
  PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties

  XFit2 =2*!Pi*FINDGEN(360)/360
  fitted = Fit[0] + Fit[1]*cos(2*(Xfit2-Fit[2]))
  ;
  Xfit1 = XFit1*360/(2*!PI)
  XFit2 = XFit2*360/(2*!PI)
  ;;Oplot, XFit1, fitted, Color=CgColor('Red')

  Print, Fit
  Print, PCERROR

  Modulation_Factor = Float(Fit[1]/float(Fit[0]))
  print, modulation_Factor

;  Temp_Err_1 = 2 * PCError[0]
;  Temp_Err_2 = SQRT( PCError[1]*PCError[1] + Temp_Err_1 * Temp_Err_1 )
 Temp_Err_3 =  Modulation_Factor*Sqrt( (PCError[0]/Fit[0])^2 + (PCError[1]/Fit[1])^2 )

  Modulation_Factor_Er = Modulation_Factor*Temp_Err_3
  Chisqr = (BESTNORM / DOF)
  Fit_Text11 = String(Format= '((F5.2,X))',Modulation_Factor)
  Fit_Text12 = String(Format= '((F5.2,X))',Modulation_Factor_Er)
  Fit_Text1 = Fit_text11+'+/-'+Fit_Text12
  Fit_Text5 = Strn(Fix(Fit[0]))+'+'+Strn(Fix(Fit[1]))+' Cos (2(X -'+Strn(Fit[2])+') )'
  Fit_Text2 = String(Format= '((F5.2,X))',Chisqr)
  
  
  ymax = max(Main_Src)*2
  ymin = -1*ymax;min(bdg4)*1.2


  CgPS_Open, title+'Total_Flt_Src_BackSub.ps', Font =1, /LandScape
  cgLoadCT, 13
  CgPlot, Xval1,Main_Src, psym=10,Err_ylow=main_err, Err_yhigh=main_err,  /err_clip $
    ,Xstyle=1, Xrange= [0,360], xtickinterval=45,err_width=0, thick=0, Err_Xhigh = Xerr, Err_Xlow=xerr $
    , ystyle=1, ytitle='Counts', Xtitle='Azi Scat Angle', title='Total Scat angle Histogram (PV Cord)' ,yrange=[ymin,ymax]
  CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')
;  CgText, !D.X_Size*0.70,!D.Y_Size*0.0,'Total Counts='+STRN(Fix(total(Main_Src)))+'(+/- '+Strn(fix(tot_main_err))+')',/DEVICE, CHarSize=1.7,Color=CgColor('Black')
CgErase
  print, max(main_src), min(main_Src)
  CgPlot, Xval1,Main_Src, psym=10,Err_ylow=main_err, Err_yhigh=main_err,  /err_clip $
    ,Xstyle=1, Xrange= [0,360], xtickinterval=45,err_width=0, thick=0, Err_Xhigh = Xerr, Err_Xlow=xerr $
    , ystyle=1, ytitle='Counts', Xtitle='Azi Scat Angle', title='Total Scat angle Histogram (PV Cord)' ,yrange=[ymin,ymax]
  CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')
;  CgText, !D.X_Size*0.70,!D.Y_Size*0.0,'Total Counts='+STRN(Fix(total(Main_Src)))+'(+/- '+Strn(fix(tot_main_err))+')',/DEVICE, CHarSize=1.7,Color=CgColor('Black')

  CGoplot, Xfit2, Fitted, COlor='red'
  CgText,  !D.X_Size*0.6,!D.Y_Size*0.85, 'Modulation ('+CgGreek('mu')+')='+ Fit_Text1  , Color=CgColor('Black'),/DEVICE, CharSize =1.7
  CgText,  !D.X_Size*0.6,!D.Y_Size*0.82, 'Reduced Chisqr='+ Fit_Text2  , Color=CgColor('Black'),/DEVICE, CharSize =1.7
  CgText, !D.X_Size*0.7,!D.Y_Size*(-0.03),Fit_Text5,/DEVICE, CHarSize=1.7,Color=CgColor('Black')

  CgErase
  
  ;
  ;=== Now fit straight line ==
  ;
  Xfit3  = Xval1
  Final_histogram = Main_Src
  Final_Histogram_err = Main_Err

  P0 = Avg(final_histogram)

  Par = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 1)



  Expr = 'P[0]'

  Fit = mpfitexpr(expr, Xfit3, Final_Histogram, Final_Histogram_Err, ParInfo=Par, NPRINT=0, PError=Er, BestNorm= BEstNorm, Weights=1/(Final_Histogram_Err*Final_Histogram_Err))
  Print, Er

  DOF     = N_ELEMENTS(XFit3) - N_ELEMENTS(Par) ; deg of freedom
  PCERROR = Er * SQRT(BESTNORM / DOF)   ; scaled uncertainties
  Chisqr = (BESTNORM / DOF)

  Fitted = Fit[0]+ 0.0*Xfit1

 ; Fit_Text1= String(Format= '("Slope   =" ,(F6.1,X)," +/- ",(F4.1) )',Fit[1], PCERROR[1])
  Fit_Text2= STring(Format= '("Constant=" ,(F6.1,X)," +/- ",(F4.1) )',Fit[0], PCERROR[0])
  Fit_Text3= ''

  Fit_Text4 = String(Format= '((F5.2,X))',Chisqr)


  CgPlot, Xval1,Main_Src, psym=10,Err_ylow=main_err, Err_yhigh=main_err,  /err_clip $
    ,Xstyle=1, Xrange= [0,360], xtickinterval=45,err_width=0, thick=0, Err_Xhigh = Xerr, Err_Xlow=xerr $
    , yrange=[ymin,ymax], ystyle=1, ytitle='Counts', Xtitle='Azi Scat Angle', title='Total Scat angle Histogram (PV Cord)'
  CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')
;  CgText, !D.X_Size*0.7,!D.Y_Size*0.0,'Total Counts='+STRN(Fix(total(Main_Src))) +'(+/- '+Strn(Fix(tot_main_err))+')',/DEVICE, CHarSize=1.7,Color=CgColor('Black')

  CgOPlot, Xfit3, Fitted, Color=CgColor('red')
  CgText,  !D.X_Size*0.6,!D.Y_Size*0.85, Fit_Text2 , Color=CgColor('Black'),/DEVICE, CharSize =1.7

  CgText,  !D.X_Size*0.6,!D.Y_Size*0.82, 'Reduced Chisqr='+Fit_Text4  , Color=CgColor('Black'),/DEVICE, CharSize =1.7
  
  
  CgPS_Close
  Temp_Str = Cur+'/'+title+'Total_Flt_Src_BackSub.ps'
  CGPS2PDF, Temp_Str,delete_ps=1,UNIX_CONVERT_CMD='pstopdf'

End