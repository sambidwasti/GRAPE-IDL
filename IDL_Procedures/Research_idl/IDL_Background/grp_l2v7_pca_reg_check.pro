pro grp_l2v7_pca_reg_check, fsearch_str, pcafile, N= N
  ; this si from pca regression to check with the excel output with 7 pca var.
  ; This has 74 lines. from swp 24 till 100
  ; 66 is background and 9 of them are
  ; Crab is 92-100 which is 9 sweeps.
  print, pcafile
  ReadCol, pcafile, AllVar1, AllVar2, AllVar3, AllVar4, AllVar5, AllVar6,AllVar7,format='D,D,D,D,D,D,D'

  RegVar1 = AllVar1[0:64]
  RegVar2 = AllVar2[0:64]
  RegVar3 = AllVar3[0:64]
  RegVar4 = AllVar4[0:64]
  RegVar5 = AllVar5[0:64]
  RegVar6 = AllVar6[0:64]
  RegVar7 = AllVar7[0:64]

  CrabVar1= AllVar1[65:73]
  CrabVar2= AllVar2[65:73]
  CrabVar3= AllVar3[65:73]
  CrabVar4= AllVar4[65:73]
  CrabVar5= AllVar5[65:73]
  CrabVar6= AllVar6[65:73]
  CrabVar7= AllVar7[65:73]

  ;--- So sorted out at this point ----
  Emin_a = 80.0
  Emax_a = 200.0
  ;Inputing the rates for a specific energy range.
  InStruc = { $
    Swp :0,$
    Rate : 0.0, $
    Err : 0.0}

  InStruc = Grp_l2v7_PCA_rate_Gen( fsearch_Str,Emin=Emin_a, Emax=Emax_a);,Nfiles=10)
  If n_elements(Instruc) ne N_Elements(AllVar1) Then Begin
    Print, 'ERROR ID 1: Not same amount of files for rate and PCA'
  Endif
  ;Print, INstruc

  nfiles=N_elements(Instruc)
  print, Nfiles
  help, regvar1
  ;RegVar1 = RegVar1[0:nfiles-1]
  ;RegVar2 = RegVar2[0:nfiles-1]
  ;RegVar3 = RegVar3[0:nfiles-1]
  ;RegVar4 = RegVar4[0:nfiles-1]
  help, regVar4
  ; Sort rates into arrays.
  RegSwp = InStruc[0:64].Swp
  RegRate= InStruc[0:64].Rate
  RegErr = Instruc[0:64].Err
  Print, RegSwp
  print,'((()))'
  ;----
  CrabSwp = Instruc[65:73].Swp
  CrabRate= Instruc[65:73].rate
  CrabErr = Instruc[65:73].err
  Print, CrabSwp
  ; Do a regression.

  ;ZWeight =1/( RegErr*RegErr)

  ;X0 =  DblArr(N_Elements(RegErr))
  ;help, X0, Zweight
  ;X = [Transpose(X0), Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4)]

  X1 = [Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4),Transpose(RegVar5), Transpose(RegVar6), Transpose(RegVar7)]
  ;X1 = [Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4)];,Transpose(RegVar5), Transpose(RegVar6), Transpose(RegVar7), Transpose(RegVar8), Transpose(RegVar9)]

  ;Result=Regress2(X, RegRate,ZWeight,YFit,Sigma,Ftest,R,Rmul, Chisq)
  Help, X1
  result1 = Regress(X1, RegRate, Measure_Errors=RegErr, Chisq=Chi, Const=con, Yfit=Yfit)
  print, result1[*]
  print, Chi, '**'
  Print, Con[*]
  ; And then plot it .
  ; Do it for the one huge energy range.
  Yfit2=Con+CrabVar1*Result1[0]+CrabVar2*Result1[1]+CrabVar3*Result1[2]+CrabVar4*Result1[3]+$
    CrabVar5*Result1[4]+CrabVar6*Result1[5]+CrabVar7*Result1[6]

  Yfit1a = Con+RegVar1*Result1[0]+RegVar2*Result1[1]+RegVar3*Result1[2]+RegVar4*Result1[3]+$
    RegVar5*Result1[4]+RegVar6*Result1[5]+RegVar7*Result1[6]

  Print, total(yfit2)
  filename = 'PCA_'+STRN(FIX(EMIN_a))+'_'+STRN(Fix(EMAX_a))+'PC_7var_lowExcel'
  CGPS_open, filename+'.ps',/Landscape
  CgPlot, Instruc.Swp, Instruc.Rate, PSYM=4,SymSize=1, Yrange=[12,20], Err_YHigh =Instruc.Err, Err_YLow= Instruc.Err, Xrange=[20,105]
  CGoPlot, RegSwp, Yfit, Color='Blue'
  CgoPlot, CrabSwp, Yfit2, Color='Red'
  CgoPlot, RegSwp, Yfit1a, Color='Green'
  CGPS_Close
  CgPS2Pdf, filename+'.ps', delete_ps=1

  Print, Yfit2 - CrabRate
  Print, Total(Yfit2-Crabrate)

End