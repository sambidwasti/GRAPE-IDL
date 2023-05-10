Pro Gsim_Grp_Com_Sim1, Files , Type=Type, Title=Title, Com=Com, foldername = foldername
  ;
  ;-- Just a new program to combine all the processed component to generate a combined file
  ;   to be smoothed.
  ; This is same as gsim grp com sim, but more stand alone to search for files.


  PRINT, '---------------------------------'
  PRint, 'COMBINE NORMALIZED SIM COMPONENTS'
  PRINT, '---------------------------------'

  True=1
  False=0

  Type_Flag = False
  If Keyword_SEt(Type) NE 0 Then Type_Flag = true
  If keyword_set(title) ne 1 then title=''
  If keyword_set(com) eq 0 then com=1

  if keyword_set(foldername) eq 0 then foldername = '' else foldername = foldername ; this is 0 but we have set the ct to be 15%

  folderflag = False
  If keyword_set(foldername) ne 0 then folderflag = true



  BinSize = 10
  nbins = 1000/binsize
  ;
  ; Each files are two column 1000bin files.
  ; We add the components and rebin them to 10KeV binsize.
  ;

  nfiles = n_elements(Files)
  print, nfiles, files
  print
  MainHist1 = DblARr(1000)
  MainHist1_Err = DblArr(1000)
  for p = 0, nfiles-1 do begin
    fname = Files[p]
    print, fname
    ReadCol,fname, Temp_Hist, Temp_Hist_Err, format='D,D'

    for i = 0, 999 Do begin
      ;Add the components
      MainHist1[i] = MainHist1[i]+Temp_Hist[i]
      MainHist1_Err[i] = MainHist1_Err[i]+Temp_Hist_Err[i]*Temp_Hist_Err[i]
    endfor
  endfor
  MainHist1_Err = Sqrt(MainHist1_Err)

  ;
  ;-- Rebinning --
  ;
  MainHist = DblArr(100)
  MainHist_Err = DblArr(100)

  ;
  ;Rebinning:
  ;
  Cntr = 0L
  for i = 0, nbins-1 do begin
    TempH   = 0.0D
    TempH_Err = 0.0D
    for j = 0, binsize-1 do begin

      TempH   = TempH   + MainHist1[cntr]

      ;-- Errors --
      TempH_Err = TempH_Err +MainHist1_Err[cntr]*MainHist1_Err[cntr]

      cntr++
    endfor ;j

    MainHist[i] = TempH
    MainHist_Err[i] = Sqrt(TempH_Err)
  endfor ; i

  MainHist = MainHist/binsize
  MainHist_Err = MainHist_Err/binsize

  ;
  ;-- Now Print the output as ModelFit.
  ;
  If Type_Flag eq true Then title1=title+'_Type_'+Strn(Type) Else Title1=title

  foldername1 =''

  if folderflag eq true then begin
    if type_flag eq true then foldername1 = 'Type'+Strn(Type)+'/' else foldername1='TypeAll/'
    foldername1 = foldername+foldername1
  endif else foldername1 = foldername

  print,foldername1+Title1+'_ComMod_'+Strn(Com)+'.txt'
  openw, Lun2, foldername1+Title1+'_ComMod_'+Strn(Com)+'.txt', /Get_lun
  for i = 0, n_elements(MainHist)-1 do begin
    printf, lun2, strn(MainHist[i])+'  '+Strn(MainHist_Err[i])
  endfor
  free_lun, Lun2

End