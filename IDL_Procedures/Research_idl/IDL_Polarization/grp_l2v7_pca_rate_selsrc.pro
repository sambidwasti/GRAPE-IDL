pro grp_l2v7_pca_rate_selSrc, LoEner = LoEner , HiEner = HiEner, title=title, fig=fig, Swp_no=Swp_no
  ;
  ; This is to get a file of rates to debug the fits for pca on polarization. 
  ; This generates a single text file with Swp, Counts and error.
  ; getting rates take the most time. 
  ; Generating a file will expedite the resolution. 
  ;
  ;
  ; This is the child of pca regression. The purpose of this is to have
  ;    an input energy range array
  ;    a text file for counts
  ;
  ;    Updating so the each sweep is c/s and not c/s/kev
  ; Also double checking with regress.
  ;

  ;
  ;The sweepno gives us an ability of figuring out array location.
  ;

  ;There are a total of 74 files
  ; SUN : Swp24- Swp44 :: 0 - 19 (Sweep Excluded no. 38
  ; Bgd2: Swp45- Swp49 :: 20- 24
  ; Cyg1: Swp50- Swp84 :: 25- 57 (Sweep Excluded no. 70, 74
  ; Bgd4: Swp85- Swp91 :: 58- 64
  ; Crab: Swp92- Swp100:: 65- 73
  print, 'Selected Sweeps'
  print, Swp_no

  fsearch_str = '*L2*.dat'
  evtfiles_check = FILE_SEARCH(fsearch_str)          ; get list of EVT input files
  nfiles_1 = n_elements(evtfiles_check)
  print, nfiles_1

  ;Checking the number of files.
  If nfiles_1 Ne 74 Then begin
    print, 'ERROR: THe number of files in SSS folder is not correct. '
    print, ' grp_l2v7_pac_reg1_pol_SelSrc.pro'
    stop
  Endif

  IF Keyword_Set(Title) Eq 0 Then title = 'Untitled' else title=title
  IF Keyword_Set(fig) Eq 0 Then Plot_flag=0 Else Plot_Flag=1

  ; So initially we are selecting bgdarr all of the background
  Arr_beg = 0
  Arr_end = 73



  ;  SrcArr_beg = BgdArr_end+1
  ;  SrcArr_end = 30



  text_title = title+'_Reg_Pol_Rate.txt'
  Openw, Lun201, text_title, /get_lun
  Printf, lun201, 'Text file with PCA and Background values'
  t_text='  '
  for i = 0,N_elements(swp_no)-1 do t_text=t_text+strn(swp_no[i])+'  '
  help,t_text
 ; Printf, lun201, 'Swp: ' + t_Text
  Printf, lun201, ' Swp Count Err '

  Free_lun, Lun201
  IF Keyword_Set(LoEner) Eq 0 Then Emin_a = [80.0] else Emin_a = double(LoEner)
  IF Keyword_Set(HiEner) Eq 0 Then EMax_a = [300.0] else EMax_a = double(HiEner)


  If N_elements(Emin_a) NE N_elements(Emax_a)  Then Begin
    Print, 'ERROR: Number of Elements in Emin array and Emax array are not the same'
    Stop
  Endif

  No_E_range = N_elements(Emin_a)
  print, No_E_Range
  Title1 = ' PCA with 7 Var Hi'
 

  ;--- So sorted out at this point ----


  ;
  ;-- Starting the loop for the
  ;

  For p = 0, No_e_range-1 Do Begin


    ;Inputing the rates for a specific energy range.
    InStruc = { $
      Swp :0,$
      Rate : 0.0D, $
      Err : 0.0D}
    Emin = Emin_a[p]
    Emax = Emax_a[p]

    InStruc = Grp_l2v7_PCA_rate_Gen_1_pol(fsearch_Str, Emin=Emin , Emax=Emax)

    Bin_Size = Emax-Emin
    ;  InStruc = Grp_l2v7_PCA_rate_Gen( fsearch_Str,Emin=Emin_a[p], Emax=Emax_a[p])
    nfiles=N_elements(Instruc)

    ;
    ; All flight data collection
    ;
    AllSwp = InStruc[Arr_beg:Arr_End].Swp
    AllRate= InStruc[Arr_beg:Arr_End].Rate
    AllErr = Instruc[Arr_beg:Arr_End].Err
    Openw, Lun201, text_title, /get_lun, /append

    for i = 0, N_elements(ALLSWP)-1 do begin
 
      printf, lun201, ALLSWP[i], AllRate[i], AllErr[i]
      
    endfor
    Free_Lun, lun201

    ;
    ;=====Background and source selection=======
    ;
    sel_arr = [0] ; need to define an array to begin with.
    ;    BgdSwp = AllSwp
    ;    BgdRate= AllRate
    ;    BGdErr = AllErr

;    for i = 0, n_elements(Swp_no)-1 do begin ; we look at each of the selected sweep separately
;      Temp_D = where(Allswp EQ Swp_no[i], count)
;      sel_arr = [sel_arr,Temp_D] ; Storing the arrays
;
;      ;       Bgdarr =where(BgdSwp NE Swp_no[i])
;      ;       BGDSwp = BGDSwp[bgdarr]
;      ;       BgdRate= BgdRate[bgdarr]
;      ;       BgdErr = BgdErr[bgderr]
;      ;
;
;    endfor
;    sel_arr = sel_arr[1:n_elements(sel_arr)-1]
;
;    bgd_arr = [0]
;    for i = 0, 64 do begin
;      a = where(sel_arr Eq i, count)
;      if count ne 1 then bgd_arr=[bgd_arr,i]
;    endfor
;
;    bgd_arr =  bgd_arr[1:n_elements(bgd_arr)-1]
;
;    BgdSwp = AllSwp[bgd_arr]
;    BgdRate= AllRate[bgd_arr]
;    BgdErr = AllErr[bgd_arr]
;
;
;    SrcSwp = AllSwp[sel_arr]
;    SrcRate= Allrate[sel_arr]
;    SrcErr = Allerr[sel_arr]

  EndFor ; P

End