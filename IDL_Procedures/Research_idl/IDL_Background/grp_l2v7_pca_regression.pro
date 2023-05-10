pro grp_l2v7_pca_regression, fsearch_str, pcafile, N= N
;
; This has 74 lines. from swp 24 till 100
; 66 is background and 9 of them are 
; Crab is 92-100 which is 9 sweeps.
print, pcafile
Title1 = ' PCA with 7 Var Hi'
DOF = 65-1-7
;ReadCol, pcafile, AllVar1, AllVar2, AllVar3, AllVar4, AllVar5, AllVar6,AllVar7,AllVar8,AllVar9,format='D,D,D,D,D,D,D,D,D'
ReadCol, pcafile, AllVar1, AllVar2, AllVar3, AllVar4, AllVar5,AllVar6,AllVar7,format='D,D,D,D,D,D,D'

;ReadCol, pcafile, AllVar1, AllVar2, AllVar3, AllVar4, AllVar5,AllVar6,format='D,D,D,D,D,D'
;ReadCol, pcafile, AllVar1, AllVar2, AllVar3, AllVar4, AllVar5,format='D,D,D,D,D'


RegVar1 = AllVar1[0:64]
RegVar2 = AllVar2[0:64]
RegVar3 = AllVar3[0:64]
RegVar4 = AllVar4[0:64]
RegVar5 = AllVar5[0:64]
RegVar6 = AllVar6[0:64]
RegVar7 = AllVar7[0:64]
;RegVar8 = AllVar8[0:64]
;RegVar9 = AllVar9[0:64]

CrabVar1= AllVar1[65:73]
CrabVar2= AllVar2[65:73]
CrabVar3= AllVar3[65:73]
CrabVar4= AllVar4[65:73]
CrabVar5= AllVar5[65:73]
CrabVar6= AllVar6[65:73]
CrabVar7= AllVar7[65:73]
;CrabVar8= AllVar8[65:73]
;CrabVar9= AllVar9[65:73]

;--- So sorted out at this point ---- 
Emin_a = 80.0
Emax_a = 300.0
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

;

X0 =  DblArr(N_Elements(RegVar1))+1.0
;help, X0, Zweight
;X = [Transpose(X0), Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4)]

;X1 = [Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4),Transpose(RegVar5)]
;X1 = [Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4),Transpose(RegVar5),Transpose(RegVar6)]
;X1 = [Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4),Transpose(RegVar5),Transpose(RegVar6),Transpose(RegVar7)]

X1 = [Transpose(X0),Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4),Transpose(RegVar5),Transpose(RegVar6),Transpose(RegVar7)]
Zweight = 1/RegRate
  Result1 = Regress2(X1, Regrate,ZWeight,YFit,Sigma,Ftest,R,Rmul, Chisq)
;Result1 = Regress( X1, Regrate, Zweight, Yfit, A0, SIgma, Chisq, Sigma0)
print, result1[*]
Print, Sigma[*]

Print, Chisq
Print, Chisq/DOF
print, '^^^'
;X1 = [Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4)];,Transpose(RegVar5), Transpose(RegVar6), Transpose(RegVar7), Transpose(RegVar8), Transpose(RegVar9)]

;Result=Regress2(X, RegRate,ZWeight,YFit,Sigma,Ftest,R,Rmul, Chisq)
Help, X1
;result1 = Regress(X1, RegRate, Measure_Errors=RegErr, Chisq=Chi, Const=con, Yfit=Yfit, Sigma=Sigma, Status = Status)

;print, Chi, '**'
;Print, Con[*]
;print, result1[*]
;print, 'Sigma:'
;Print, Sigma[*]
;PRint, Status
; And then plot it . 
; Do it for the one huge energy range.
;Yfit2=A0+CrabVar1*Result1[0]+CrabVar2*Result1[1]+CrabVar3*Result1[2]+CrabVar4*Result1[3]+$
;    CrabVar5*Result1[4]+CrabVar6*Result1[5]+CrabVar7*Result1[6];+CrabVar8*Result1[7]+CrabVar9*Result1[8]
;
;Yfit1a = A0+RegVar1*Result1[0]+RegVar2*Result1[1]+RegVar3*Result1[2]+RegVar4*Result1[3]+$
;          RegVar5*Result1[4]+RegVar6*Result1[5]+RegVar7*Result1[6];+RegVar8*Result1[7]+RegVar9*Result1[8]
;          Print, CrabSwp
Yfit2=Result1[0]+CrabVar1*Result1[1]+CrabVar2*Result1[2]+CrabVar3*Result1[3]+CrabVar4*Result1[4]+$
  CrabVar5*Result1[5]+CrabVar6*Result1[6]+CrabVar7*Result1[7];+CrabVar8*Result1[7]+CrabVar9*Result1[8]

Yfit1a = Result1[0]+RegVar1*Result1[1]+RegVar2*Result1[2]+RegVar3*Result1[3]+RegVar4*Result1[4]+$
  RegVar5*Result1[5]+RegVar6*Result1[6]+RegVar7*Result1[7];+RegVar8*Result1[7]+RegVar9*Result1[8]
Print, CrabSwp
Print, 'count and error)
Print, total(yfit2)
sig2 = sigma *  sigma
help, sig2
print, sig2
Yfit2_error = Sqrt(Total(Sig2))
print, yfit2_error
     print, '&&&'

filename = 'PCA_'+STRN(FIX(EMIN_a))+'_'+STRN(Fix(EMAX_a))+'PC_7_var_high'
CGPS_open, filename+'.ps',/Landscape
    CgPlot, Instruc.Swp, Instruc.Rate, PSYM=4,SymSize=1,  Err_YHigh =Instruc.Err, Err_YLow= Instruc.Err, Xrange=[20,105],Yrange=[11,16],$
      title=title1
    CGoPlot, RegSwp, Yfit, Color='Blue'
    CgoPlot, CrabSwp, Yfit2, Color='Red'
    CgoPlot, RegSwp, Yfit1a, Color='Green'
    Rchi = Chisq/DOF 
          CgText, !D.X_Size*0.70,!D.Y_Size*0.93,'R-Chi='+STRN(Rchi),/DEVICE, CHarSize=1.7,Color=CgColor('Black')
              CgText, !D.X_Size*0.7,!D.Y_Size*0.00,'Emin='+STRN(Emin_a),/DEVICE, CHarSize=1.0,Color=CgColor('Black')
          CgText, !D.X_Size*(0.7),!D.Y_Size*0.03,'Emax='+STRN(Emax_a),/DEVICE, CHarSize=1.0,Color=CgColor('Black')

CGPS_Close
CgPS2Pdf, filename+'.ps', delete_ps=1

;Print, Yfit2 - CrabRate
;Print, Total(Yfit2-Crabrate)

End