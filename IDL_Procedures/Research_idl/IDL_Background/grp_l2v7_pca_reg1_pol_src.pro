pro grp_l2v7_pca_reg1_pol_Src,  pcafile, N= N, LoEner = LoEner , HiEner = HiEner, title=title, fig=fig
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
  BgdArr_beg = 0
  BgdArr_end = 24
    
  SrcArr_beg = BgdArr_end+1
  SrcArr_end = 30

  fsearch_str = '*L2*.dat'
  print, pcafile
  IF Keyword_Set(Title) Eq 0 Then title = 'Untitled' else title=title
  IF Keyword_Set(fig) Eq 0 Then Plot_flag=0 Else Plot_Flag=1
  text_title = title+'_Reg_Pol_back.txt'
  Openw, Lun201, text_title, /get_lun
  Printf, lun201, 'Text file with PCA and Background values'
  Printf, lun201, 'Swp: 85  86  87  88  89  91'
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

  RegVar1 = AllVar1[BgdArr_beg:BgdArr_End]
  RegVar2 = AllVar2[BgdArr_beg:BgdArr_End]
  RegVar3 = AllVar3[BgdArr_beg:BgdArr_End]
  RegVar4 = AllVar4[BgdArr_beg:BgdArr_End]
  RegVar5 = AllVar5[BgdArr_beg:BgdArr_End]
  RegVar6 = AllVar6[BgdArr_beg:BgdArr_End]
  RegVar7 = AllVar7[BgdArr_beg:BgdArr_End]  


  ; Changing CrabVar1 to BgdVar1
  SrcVar1= AllVar1[SrcArr_beg:SrcArr_End]
  SrcVar2= AllVar2[SrcArr_beg:SrcArr_End]
  SrcVar3= AllVar3[SrcArr_beg:SrcArr_End]
  SrcVar4= AllVar4[SrcArr_beg:SrcArr_End]
  SrcVar5= AllVar5[SrcArr_beg:SrcArr_End]
  SrcVar6= AllVar6[SrcArr_beg:SrcArr_End]
  SrcVar7= AllVar7[SrcArr_beg:SrcArr_End]

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

    ; Sort rates into arrays.
    RegSwp = InStruc[BgdArr_beg:BgdArr_End].Swp
    RegRate= InStruc[BgdArr_beg:BgdArr_End].Rate
    RegErr = Instruc[BgdArr_beg:BgdArr_End].Err

    ;----
    SrcSwp = Instruc[SrcArr_beg:SrcArr_End].Swp
    SrcRate= Instruc[SrcArr_beg:SrcArr_End].rate
    SrcErr = Instruc[SrcArr_beg:SrcArr_End].err

    ;
    Print, 'Bgd Sweep', RegSwp
    Print, 'Src Sweep', Srcswp
    Print, 'Src Counts', SrcRate

    PRint, 'Err', SrcErr


    ;
    ;-- Regression 2
    ;
    X0 =  DblArr(N_Elements(RegVar1))+1.0
    X1 = [Transpose(X0),Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4),Transpose(RegVar5),Transpose(RegVar6),Transpose(RegVar7)]
    Zweight = DblArr(N_elements(RegErr))

    Help, X0
    Help, RegVar1
    Help, RegErr
    Print, REgERr


    Help, Zweight
    
    Print, Zweight

    For q = 0, N_Elements(RegErr)-1 Do If Regerr[q] GT 0.0 Then Zweight[q]=1/(RegErr[q] * RegERr[q]) Else Zweight[q] = 1.0
    Print, Zweight
    PRint,'***'
    ;   REGRESS2,X,Y,W,Yfit,Sigma,Ftest,R,Rmul,Chisq, RELATIVE_WEIGHT=relative_weight
    PRINT, CHECK_MATH(Print=1)
    print,'---'
    Result1 = Regress2(X1, Regrate,ZWeight,YFit,Sigma,Ftest,R,Rmul, Chisq)
    Print, Result1[*]
    Print, Sigma


;    ;
;    ;;  == Using Regress for sanity check. ;;
;    ;;
;    Print, '=====Regress ===='
;    RX=[Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4),Transpose(RegVar5),Transpose(RegVar6),Transpose(RegVar7)]
;    Regress_result = Regress(RX, Regrate, measure_errors=RegErr, SIgma=reg_sigma, Const=Reg_const,Chisq=Reg_Chi)
;
;    Print, 'Const : ',Reg_Const
;    Print, 'COef  : ',regress_result[*]
;    Print, 'Errors :',Reg_Sigma
;
;    Fit_Regress = Reg_Const+ RegVar1*Regress_result[0]+RegVar2*Regress_result[1]+RegVar3*Regress_result[2]+RegVar4*Regress_result[3]+$
;      RegVar5*Regress_result[4]+RegVar6*Regress_result[5]+RegVar7*Regress_result[6]
;   
;    Fit_reg_Src = Reg_Const+SrcVar1*Regress_result[0]+SrcVar2*Regress_result[1]+SrcVar3*Regress_result[2]+SrcVar4*Regress_result[3]+$
;      SrcVar5*Regress_result[4]+SrcVar6*Regress_result[5]+SrcVar7*Regress_result[6]
;
;    Reg_DOF= n_elements(RegSwp)-7-1
;    Reg_RChi = Reg_Chi/Reg_DOF
;
;    Reg_Yfit2_Err2 =  Reg_Sigma[0]*REg_sigma[0]*SrcVar1*SrcVar1+ Reg_Sigma[1]*Reg_sigma[1]*SrcVar2*SrcVar2 + Reg_Sigma[2]*Reg_sigma[2]*SrcVar3*SrcVar3 +$
;      Reg_Sigma[3]*Reg_sigma[3]*SrcVar4*SrcVar4 + Reg_Sigma[4]*Reg_sigma[4]*SrcVar5*SrcVar5 + Reg_Sigma[5]*Reg_sigma[5]*SrcVar6*SrcVar6 + Reg_Sigma[6]*Reg_sigma[6]*SrcVar7*SrcVar7
;    Reg_Yfit2_Err = Sqrt(REg_Yfit2_Err2)


    print,'============='
    print

    ;  print, 'ftest'
    ;  Print, Ftest
    Print

    ;  PRint, R[*]
    ;  PRint, Rmul[*]
    print,'---'
    ;  PRINT, CHECK_MATH(PRint=1)
    Print, '***'

    Print, Chisq
    Yfit2=Result1[0]+SrcVar1*Result1[1]+SrcVar2*Result1[2]+SrcVar3*Result1[3]+SrcVar4*Result1[4]+$
      SrcVar5*Result1[5]+SrcVar6*Result1[6]+SrcVar7*Result1[7]

    Yfit1a = Result1[0]+RegVar1*Result1[1]+RegVar2*Result1[2]+RegVar3*Result1[3]+RegVar4*Result1[4]+$
      RegVar5*Result1[5]+RegVar6*Result1[6]+RegVar7*Result1[7]

    Fit_Err = Sigma[*]

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
      CgPlot, Instruc.Swp, Instruc.Rate, PSYM=4,SymSize=1,  Err_YHigh =Instruc.Err, Err_YLow= Instruc.Err, Xrange=[20,105],$
        title=title1, Yrange=[Ymin,Ymax]
      ;  CGoPlot, RegSwp, Yfit, Color='Blue'
      CgoPlot, SrcSwp, Yfit2, Color='Firebrick', Err_YHigh=Yfit2_err,Err_YLow=Yfit2_err, Err_Color='Light Salmon',err_width=0, thick=2
      CgoPlot, RegSwp, Yfit1a, Color='Green'

    ;  CGoPlot, RegSwp, Fit_Regress, Color='Blue'
     ; Cgoplot, bgdSwp, Fit_Reg_bgd, Color='Blue',Err_YHigh=Reg_Yfit2_err,Err_YLow=Reg_Yfit2_err, Err_Color='Cornflower Blue',err_width=0, thick=2

      CgText, !D.X_Size*0.70,!D.Y_Size*0.93,'R-Chi='+STRN(Rchi),/DEVICE, CHarSize=1.7,Color=CgColor('Red')
      CgText, !D.X_Size*0.70,!D.Y_Size*0.00,'Emin='+STRN(Emin_a[p]),/DEVICE, CHarSize=1.0,Color=CgColor('Black')
      CgText, !D.X_Size*(0.70),!D.Y_Size*0.03,'Emax='+STRN(Emax_a[p]),/DEVICE, CHarSize=1.0,Color=CgColor('Black')
   ;   CgText, !D.X_Size*0.70,!D.Y_Size*0.96,'R-Chi='+STRN(reg_rchi),/DEVICE, CHarSize=1.0,Color=CgColor('Blue')

      CGPS_Close
      CgPS2Pdf, filename+'.ps', delete_ps=1

    EndIf ; Plot_flag

    openw, lun555, Title+'Src_qlook.txt', /get_lun
    for j = 0, N_Elements(Instruc.swp)-1 Do Begin
      printf, lun555, Instruc[j].swp, instruc[j].rate



    endfor

    for j = 0, n_elements(Srcswp)-1 do begin
      printf, lun555
      printf, lun555, Srcswp[j], yfit2[j]
    endfor
    free_lun, lun555

    Close, /all
  EndFor ; P

End