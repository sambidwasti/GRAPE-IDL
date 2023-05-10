pro grp_l2v7_pca_reg1_pol_selSrc,  pcafile, N= N, LoEner = LoEner , HiEner = HiEner, title=title, fig=fig, Swp_no=Swp_no
  ; 
  ; This is further modified for the ability to input sweep numbers of source. 
  ; The background source is configured by extracting out these sweeps.
  ; The array no and sweeps are related.
  ; Note that there ar some sweeps excluded which is always needs to be conserved.
  ; 
  ; Creating this so that we can specify the sweep numbers here to avoid generating multiple sweeps.
  ; This is variation from pca_reg1_pol for focusing on Cyg.
  ; This is the main procedure to modify.
  ; The rate gen file is the same.
  ;
  ; This has 74 lines. from swp 24 till 100
  ; 66 is background and 9 of them are
  ;
  ;
  ; Crab is 92-100 which is 9 sweeps.
  ; Bgd4 is 85-91 which is 7 sweeps.
  ; Cyg is 50-84 analyis is on 5 sweeps. 50-54 array : 25-29
  ;
  ; Few sweeps are not included 38,71 abd 75,
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

  print, pcafile
  IF Keyword_Set(Title) Eq 0 Then title = 'Untitled' else title=title
  IF Keyword_Set(fig) Eq 0 Then Plot_flag=0 Else Plot_Flag=1

; So initially we are selecting bgdarr all of the background  
  Arr_beg = 0
  Arr_end = 64
  


;  SrcArr_beg = BgdArr_end+1
;  SrcArr_end = 30

  

  text_title = title+'_Reg_Pol_back.txt'
  Openw, Lun201, text_title, /get_lun
  Printf, lun201, 'Text file with PCA and Background values'
  t_text='  '
  for i = 0,N_elements(swp_no)-1 do t_text=t_text+strn(swp_no[i])+'  '
  help,t_text
  Printf, lun201, 'Swp: ' + t_Text
  Printf, lun201, ' Elo Ehi Chisq{{ Count (C/s) CountERr } per sweep}

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
  ; DOF = 65-1-7
  ReadCol, pcafile, AllVar1, AllVar2, AllVar3, AllVar4, AllVar5,AllVar6,AllVar7,format='D,D,D,D,D,D,D'



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
    If n_elements(Instruc) ne N_Elements(AllVar1) Then Begin
      Print, 'ERROR ID 1: Not same amount of files for rate and PCA'
      stop
    Endif
    nfiles=N_elements(Instruc)
    
    ;
    ; All flight data collection
    ;
    AllSwp = InStruc[Arr_beg:Arr_End].Swp
    AllRate= InStruc[Arr_beg:Arr_End].Rate
    AllErr = Instruc[Arr_beg:Arr_End].Err

    ;
    ;=====Background and source selection=======
    ;
    sel_arr = [0] ; need to define an array to begin with.
;    BgdSwp = AllSwp
;    BgdRate= AllRate
;    BGdErr = AllErr
    
    for i = 0, n_elements(Swp_no)-1 do begin ; we look at each of the selected sweep separately
       Temp_D = where(Allswp EQ Swp_no[i], count)
       sel_arr = [sel_arr,Temp_D] ; Storing the arrays
        
;       Bgdarr =where(BgdSwp NE Swp_no[i])
;       BGDSwp = BGDSwp[bgdarr]
;       BgdRate= BgdRate[bgdarr]
;       BgdErr = BgdErr[bgderr]
;       
      
    endfor
    sel_arr = sel_arr[1:n_elements(sel_arr)-1]
    
    bgd_arr = [0]
    for i = 0, 64 do begin
      a = where(sel_arr Eq i, count)
      if count ne 1 then bgd_arr=[bgd_arr,i]
    endfor
    
    bgd_arr =  bgd_arr[1:n_elements(bgd_arr)-1]
    
    BgdSwp = AllSwp[bgd_arr]
    BgdRate= AllRate[bgd_arr]
    BgdErr = AllErr[bgd_arr]
    
    
    SrcSwp = AllSwp[sel_arr]
    SrcRate= Allrate[sel_arr]
    SrcErr = Allerr[sel_arr]


   print, bgdswp
   print, SrcSwp
   
   ; We have the selected sweep. 
   ; Now we select the relative X components from PCA file 
   
   RegVar1 = AllVar1[bgd_arr]
   RegVar2 = AllVar2[bgd_arr]
   RegVar3 = AllVar3[bgd_arr]
   RegVar4 = AllVar4[bgd_arr]
   RegVar5 = AllVar5[bgd_arr]
   RegVar6 = AllVar6[bgd_arr]
   RegVar7 = AllVar7[bgd_arr]
   
   SrcVar1= AllVar1[sel_arr]
   SrcVar2= AllVar2[sel_arr]
   SrcVar3= AllVar3[sel_arr]
   SrcVar4= AllVar4[sel_arr]
   SrcVar5= AllVar5[sel_arr]
   SrcVar6= AllVar6[sel_arr]
   SrcVar7= AllVar7[sel_arr]

 
help, Regvar1

    ;
    ;-- Regression 2
    ;
    X0 =  DblArr(N_Elements(RegVar1))+1.0
    X1 = [Transpose(X0),Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4),Transpose(RegVar5),Transpose(RegVar6),Transpose(RegVar7)]
    Zweight = DblArr(N_elements(BgdErr))


    For q = 0, N_Elements(BgdErr)-1 Do If Bgderr[q] GT 0.0 Then Zweight[q]=1/(BgdErr[q] * BgdERr[q]) Else Zweight[q] = 1.0
   ; Print, Zweight
    PRint,'***'
    ;   REGRESS2,X,Y,W,Yfit,Sigma,Ftest,R,Rmul,Chisq, RELATIVE_WEIGHT=relative_weight
  ;  PRINT, CHECK_MATH(Print=1)
    print,'---'
    print, x1
    print, bgdrate
    
    Result1 = Regress2(X1, Bgdrate,ZWeight,YFit,Sigma,Ftest,R,Rmul, Chisq)
    
    Print, R
    
    
    Print, Result1[*]
    Print, Sigma
    Print, Chisq
    
    Yfit2=Result1[0]+SrcVar1*Result1[1]+SrcVar2*Result1[2]+SrcVar3*Result1[3]+SrcVar4*Result1[4]+$
      SrcVar5*Result1[5]+SrcVar6*Result1[6]+SrcVar7*Result1[7]

    Yfit1a = Result1[0]+RegVar1*Result1[1]+RegVar2*Result1[2]+RegVar3*Result1[3]+RegVar4*Result1[4]+$
      RegVar5*Result1[5]+RegVar6*Result1[6]+RegVar7*Result1[7]

    Yfit2_Err2 = Sigma[0]^2+ Sigma[1]*sigma[1]*SrcVar1*SrcVar1+ Sigma[2]*sigma[2]*SrcVar2*SrcVar2 + Sigma[3]*sigma[3]*SrcVar3*SrcVar3 +$
      Sigma[4]*sigma[4]*SrcVar4*SrcVar4 + Sigma[5]*sigma[5]*SrcVar5*SrcVar5 + Sigma[6]*sigma[6]*SrcVar6*SrcVar6 + Sigma[7]*sigma[7]*srcVar7*srcVar7

    Yfit2_Err = Sqrt(Yfit2_Err2)
    Rchi = Chisq
    ; Crab Swp : 92, 93, 94,95, 96,  97, 98, 99, 100
    ; Rescaling for the per kev binning
    Yfit2_scl = Yfit2;/Bin_Size
    Yfit2_Err_Scl = Yfit2_Err;/BIn_Size
    Yfit_Scl = Yfit;/Bin_SIze
    Yfit1a_Scl = Yfit1a;/Bin_Size



    ;
    ;;  == Using Regress for sanity check. ;;
    ;;
    Print, '=====Regress ===='
    RX=[Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4),Transpose(RegVar5),Transpose(RegVar6),Transpose(RegVar7)]
    Regress_result = Regress(RX, Bgdrate, measure_errors=BgdErr, SIgma=reg_sigma, Const=Reg_const,Chisq=Reg_Chi, Yfit=Fit_Regress)

    Print, 'Const : ',Reg_Const
    Print, 'COef  : ',regress_result[*]
    Print, 'Errors :',Reg_Sigma

    Fit_Regress_eval = Reg_Const+ RegVar1*Regress_result[0]+RegVar2*Regress_result[1]+RegVar3*Regress_result[2]+RegVar4*Regress_result[3]+$
      RegVar5*Regress_result[4]+RegVar6*Regress_result[5]+RegVar7*Regress_result[6]


    Fit_reg_Src = Reg_Const+ SrcVar1*Regress_result[0]+SrcVar2*Regress_result[1]+SrcVar3*Regress_result[2]+SrcVar4*Regress_result[3]+$
      SrcVar5*Regress_result[4]+SrcVar6*Regress_result[5]+SrcVar7*Regress_result[6]

    Reg_DOF= n_elements(RegSwp)-7-1
    Reg_RChi = Reg_Chi/Reg_DOF

    Reg_Yfit2_Err2 =  Reg_Sigma[0]*REg_sigma[0]*SrcVar1*SrcVar1+ Reg_Sigma[1]*Reg_sigma[1]*SrcVar2*SrcVar2 + Reg_Sigma[2]*Reg_sigma[2]*SrcVar3*SrcVar3 +$
      Reg_Sigma[3]*Reg_sigma[3]*SrcVar4*SrcVar4 + Reg_Sigma[4]*Reg_sigma[4]*SrcVar5*SrcVar5 + Reg_Sigma[5]*Reg_sigma[5]*SrcVar6*SrcVar6 + Reg_Sigma[6]*Reg_sigma[6]*SrcVar7*SrcVar7
    Reg_Yfit2_Err = Sqrt(REg_Yfit2_Err2)




    Temp_Text = String(Format='(F8.2, 1X, F8.2, 1X, F8.2)',Emin_a[p],Emax_a[p], Rchi)

    For j = 0,N_Elements(SrcSwp)-1 Do Begin

      Temp_Text = Temp_Text + String(Format = '(1X,F10.2,1X,F10.2)',Yfit2_Scl[j], Yfit2_Err_Scl[j] )

    Endfor
    Openw, Lun201, text_title, /get_lun, /append

    Printf,lun201, Temp_Text
    Free_Lun, lun201

    If Plot_flag Eq 1 Then Begin
      Ymax = Max(Instruc.Rate)*1.25
      Ymin = Min(Instruc.Rate)*0.8
      filename = title+'_PCA_Pol_Bgd'
      CGPS_open, filename+'.ps',/Landscape
      CgPlot, Allswp, Allrate, PSYM=4,SymSize=1,  Err_YHigh =AllErr, Err_YLow= AllErr, Xrange=[20,105],$
        title=title1, Yrange=[Ymin,Ymax]
;        CGoPlot, BgdSwp, Yfit, Color='green'
;      CgoPlot, SrcSwp, Yfit2, Color='Firebrick', Err_YHigh=Yfit2_err,Err_YLow=Yfit2_err, Err_Color='Light Salmon',err_width=0, thick=2, psym=1
;     CgoPlot, BgdSwp, Yfit1a, Color='Blue' , psym=7, symsize=1

        CGoPlot, BgdSwp, Fit_Regress, Color='Blue', psym=7
        Cgoplot, SrcSwp, Fit_Reg_Src, Color='FireBrick',Err_YHigh=Reg_Yfit2_err,Err_YLow=Reg_Yfit2_err, Err_Color='FireBrick',psym=7;err_width=0, thick=2, psym=7, symsize=4

;      CgText, !D.X_Size*0.70,!D.Y_Size*0.93,'R-Chi='+STRN(Rchi),/DEVICE, CHarSize=1.7,Color=CgColor('Red')
;      CgText, !D.X_Size*0.70,!D.Y_Size*0.00,'Emin='+STRN(Emin_a[p]),/DEVICE, CHarSize=1.0,Color=CgColor('Black')
;      CgText, !D.X_Size*(0.70),!D.Y_Size*0.03,'Emax='+STRN(Emax_a[p]),/DEVICE, CHarSize=1.0,Color=CgColor('Black')
;      ;   CgText, !D.X_Size*0.70,!D.Y_Size*0.96,'R-Chi='+STRN(reg_rchi),/DEVICE, CHarSize=1.0,Color=CgColor('Blue')

      CGPS_Close
      CgPS2Pdf, filename+'.ps', delete_ps=1

    EndIf ; Plot_flag

    openw, lun555, Title+'Src_qlook.txt', /get_lun
    for j = 0, N_Elements(AllSwp)-1 Do Begin
      printf, lun555, Allswp[j],Allrate[j], AllErr[j]
    endfor
      print
    for j = 0, n_elements(Srcswp)-1 do begin
      printf, lun555
      printf, lun555, Srcswp[j], yfit2[j], yfit2_err[j]
    endfor
    free_lun, lun555

    Close, /all
  EndFor ; P


  Openw, lun2, title+'_PlotVar_PCA_Reg1_Pol_SElSrc.txt',/Get_lun

  printf, lun2, 'RateGen file data'
  printf, lun2, ' Swp, Rate, Err'
  printf, lun2, ' '
  for i = 0, n_elements(Instruc)-1 do begin
    printf, lun2, Instruc[i].swp, Instruc[i].rate, Instruc[i].err
  Endfor
  printf, lun2, ' '
  printf, lun2, ' All Bgd values '
  printf, lun2, ' BGD Swp, Rate, Err, Fitted'
  for i = 0, n_elements(BgdSwp)-1 do begin


    printf, lun2,BgdSwp[i], BgdRate[i], BGdErr[i], Fit_Regress_eval[i]
  EndFor
  printf,lun2,'Selected Source'
  Printf, lun2, ' Swp, Rate, Err, Extrap, Err'
  for i = 0, n_elements(SrcSwp)-1 do begin

    printf, lun2,SrcSwp[i], SrcRate[i], SrcErr[i],Fit_reg_Src[i], Reg_Yfit2_Err[i]

;
;    printf, lun2,CrabSwp[i], yfit2[i]
 EndFor

  free_lun, Lun2
  

End