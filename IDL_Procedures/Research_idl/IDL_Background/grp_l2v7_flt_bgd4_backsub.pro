Pro Grp_L2v7_Flt_Bgd4_BackSub, Bgd4_Pol_Files, PCA_bgdfile , title=title
  ; This is created to background subtract the scatter angle histograms.
  ; this uses 2 files.
  ; The crab files are processed through grp_l2v7_flt_polarization
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
  ;   To-do-list
  ;   Need to change the specific no. of bins to file specific so it is versatile.


  title='test'
  cd,cur=cur
  
  ; We read the BGd4 Files and make sure we have the right sweeps.
  Bgd4_Files = FILE_SEARCH(Bgd4_Pol_Files)          ; get list of EVT input files
  nfiles = n_elements(Bgd4_Files)
  print, nfiles , '  This should be 7'
  Readcol, Bgd4_Files[0], Ebin, Counts, format='F,F'



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
  ;there are 7 sweeps.
  ; 92sweep is 1st(or 0th position in array)
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


  Bgd4_Nbins= N_elements(Ebin)
  Bsize = Ebin[1]-Ebin[0]

  Bgd4_array = DblArr(Bgd4_Nbins,7)   ; bins x 7 files


  for p = 0, nfiles-1 do begin
    Readcol, Bgd4_Files[p], Ebin, Counts, format='F,F'

    filename = bgd4_files[p]
    pos0 = strpos(filename,'Sweep',0)
    pos1 = strpos(filename,'.txt',0)
    swp_no = fix(strmid(filename, pos0+6, pos1-pos0-6))

    case swp_no of
      85: xpos = 0
      86: xpos = 1
      87: xpos = 2
      88: xpos = 3
      89: xpos = 4
      90: xpos = 5
      91: xpos = 6
      Else: print, 'INVALID'
    endcase
    Bgd4_array[*,xpos]=Counts
  endfor

  ;===================

  ;Now divide the background evenly into the number of bins
  ;And create an array of that.
  Bgd_Cnt_arr = DblArr(BGd4_Nbins,nfiles)
  Bgd_Cnt_err = DblArr(Bgd4_Nbins,nfiles)

  for i = 0, nfiles-1 do begin
    TScl_Bgd = DblArr(Bgd4_Nbins)+Bgd_Cnt[i]
    Scl_Bgd = TScl_Bgd/Bgd4_Nbins
    Bgd_Cnt_arr[*,i]= Scl_bgd

    TScl_Err = DblArr(BGd4_Nbins)+Bgd_Err[i]
    Scl_Err = TScl_Err/BGd4_Nbins
    Bgd_Cnt_err[*,i]= Scl_err
  endfor


  Main_Src=DblArr(Bgd4_Nbins)
  Main_Src_err = Dblarr(Bgd4_Nbins)

  CgPS_Open, title+'_Flt_Bgd4_BackSub.ps', Font =1, /LandScape
  cgLoadCT, 13


  ;Now we subtract each sweep with its respective bgd.
  i = 0
  for i = 0, nfiles-1 do begin
    bgd4 = Bgd4_array[*,i]
    bgd4_err = sqrt(abs(Bgd4))

    bgd  = bgd_cnt_arr[*,i]
    bgd_err = bgd_cnt_err[*,i]

    print, total(Bgd4), i
    Print, total(bgd)

    temp_sub = Bgd4-Bgd
    Main_Src = Main_Src+temp_Sub

    temp_err = bgd4_err*bgd4_err + Bgd_err*Bgd_err
    main_Src_err = main_Src_err+temp_err

    Xval = Indgen(Bgd4_Nbins)*Bsize
    Xval1 = Xval+(Bsize/2.0)
    Xerr = FltArr(Bgd4_Nbins)+(Bsize/2.0)

    ymax = max(Bgd4)*1.2
    ymin = 0;min(bdg4)*1.2

    Cgplot, Xval1,bgd4, psym=10, color='navy',$
      Err_ylow=bgd4_err, Err_yhigh=bgd4_err,  /err_clip, Xstyle=1, Xrange= [0,360], xtickinterval=45,$
      Title='Scat Angle Histogram for Sweep '+Strn(i+85), yrange=[ymin,ymax], ytitle='Counts', xtitle='Angle'
    Cgoplot,XVal1, Bgd, psym=10, color='red',Err_ylow=bgd_err, Err_yhigh=bgd_err,  /err_clip

    CgText, !D.X_Size*0.70,!D.Y_Size*0.0,'Total Bgd4='+STRN(total(BGd4)),/DEVICE, CHarSize=1.7,Color=CgColor('Navy')
    CgText, !D.X_Size*0.70,!D.Y_Size*(-0.035),'Total Bgd='+STRN(total(Bgd)),/DEVICE, CHarSize=1.7,Color=CgColor('Red')

    CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')

    Cgerase
  endfor

  CgPS_Close
  Temp_Str = Cur+'/'+title+'_Flt_bgd4_BackSub.ps'
  CGPS2PDF, Temp_Str,delete_ps=1


  CgPS_Open, title+'Total_Flt_BGd4_BackSub.ps', Font =1, /LandScape
  cgLoadCT, 13

  ymax = 0
  ymin = min(Main_Src)*1.2
  print, max(main_src), min(main_Src)
  Main_err_total= Sqrt(Total(Main_Src_eRr))
  Main_err = Sqrt(Main_Src_err)
  print, main_err
  CgPlot, Xval1,Main_Src, psym=10,Err_ylow=main_err, Err_yhigh=main_err,  /err_clip $
    ,Xstyle=1, Xrange= [0,360], xtickinterval=45,err_width=0, thick=0, Err_Xhigh = Xerr, Err_Xlow=xerr $
    , ystyle=1, ytitle='Counts', Xtitle='Angle', title='Total Scat angle Histogram (PV Cord)' ,yrange=[ymin,ymax]
  CgText, !D.X_Size*0.8,!D.Y_Size*(0.91),'Bin Size='+STRN(Fix(Bsize)),/DEVICE, CHarSize=1.7,Color=CgColor('Black')
  CgText, !D.X_Size*0.60,!D.Y_Size*0.0,'Total Counts='+STRN(total(Main_Src))+'+/-'+Strn(Main_err_Total),/DEVICE, CHarSize=1.7,Color=CgColor('Black')


  CgPS_Close
  Temp_Str = Cur+'/'+title+'Total_Flt_Bgd4_BackSub.ps'
  CGPS2PDF, Temp_Str,delete_ps=1

End