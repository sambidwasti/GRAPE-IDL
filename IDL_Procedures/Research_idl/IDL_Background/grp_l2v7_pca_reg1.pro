pro grp_l2v7_pca_reg1,  pcafile, N= N, LoEner = LoEner , HiEner = HiEner, title=title, fig=fig
  ;
  ; This has 74 lines. from swp 24 till 100
  ; 66 is background and 9 of them are
  ; Crab is 92-100 which is 9 sweeps.
  ; This is the child of pca regression. The purpose of this is to have
  ;    an input energy range array
  ;    a text file for counts
  ;    
  ;    SW:
  ;    Updating so the each sweep is c/s and not c/s/kev
  ;    
  ;    SW: 3/9/20
  ;    Updating to create another text file with the variables to make it easier to plot.
  ;    
  ;
  fsearch_str = '*L2*.dat'
  print, pcafile
  IF Keyword_Set(Title) Eq 0 Then title = 'Untitled' else title=title
  IF Keyword_Set(fig) Eq 0 Then Plot_flag=0 Else Plot_Flag=1
  text_title = title+'_Reg_back.txt'
  Openw, Lun201, text_title, /get_lun
  Printf, lun201, 'Text file with PCA and Background values'
  Printf, lun201, 'Swp: 92  93  94  95  96  97  98  99  100'
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
  DOF = 65-1-7
  ReadCol, pcafile, AllVar1, AllVar2, AllVar3, AllVar4, AllVar5,AllVar6,AllVar7,format='D,D,D,D,D,D,D'

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


  ;
  ;-- Starting the loop for the 
  ;
  
  For p = 0, No_e_range-1 Do Begin


      ;Inputing the rates for a specific energy range.
      InStruc = { $
        Swp :0,$
        Rate : 0.0, $
        Err : 0.0}
        Emin = Emin_a[p]
        Emax = Emax_a[p]
      InStruc = Grp_l2v7_PCA_rate_Gen_1( fsearch_Str,Emin=Emin, Emax=Emax)
        Bin_Size = Emax-Emin
    ;  InStruc = Grp_l2v7_PCA_rate_Gen( fsearch_Str,Emin=Emin_a[p], Emax=Emax_a[p])
      If n_elements(Instruc) ne N_Elements(AllVar1) Then Begin
        Print, 'ERROR ID 1: Not same amount of files for rate and PCA'
        stop
      Endif
      nfiles=N_elements(Instruc)
    
      ; Sort rates into arrays.
      RegSwp = InStruc[0:64].Swp
      RegRate= InStruc[0:64].Rate
      RegErr = Instruc[0:64].Err

      ;----
      CrabSwp = Instruc[65:73].Swp
      CrabRate= Instruc[65:73].rate
      CrabErr = Instruc[65:73].err
      
      ;
      Print, 'Crab Sweep', CrabSwp
      Print, ' Counts', CrabRate
      
      
      ;
      ;-- Regression
      ;
      X0 =  DblArr(N_Elements(RegVar1))+1.0
      X1 = [Transpose(X0),Transpose(RegVar1), Transpose(RegVar2), Transpose(RegVar3), Transpose(RegVar4),Transpose(RegVar5),Transpose(RegVar6),Transpose(RegVar7)]
      Zweight = DblArr(N_elements(RegErr))
     
     
      For q = 0, N_Elements(RegErr)-1 Do If Regerr[q] GT 0.0 Then Zweight[q]=1/(RegErr[q] * RegERr[q]) Else Zweight[q] = 1.0
        Print, Zweight
        PRint,'***'
    ;   REGRESS2,X,Y,W,Yfit,Sigma,Ftest,R,Rmul,Chisq, RELATIVE_WEIGHT=relative_weight
PRINT, CHECK_MATH(Print=1)
print,'---'
      Result1 = Regress2(X1, Regrate,ZWeight,YFit,Sigma,Ftest,R,Rmul, Chisq)
      Print, Result1[*]
      Print, Sigma
      print
      Print, Ftest
      Print
      
      PRint, R[*]
      PRint, Rmul[*]
print,'---'
      PRINT, CHECK_MATH(PRint=1)
Print, '***'
      
      Print, Chisq
      Yfit2=Result1[0]+CrabVar1*Result1[1]+CrabVar2*Result1[2]+CrabVar3*Result1[3]+CrabVar4*Result1[4]+$
      CrabVar5*Result1[5]+CrabVar6*Result1[6]+CrabVar7*Result1[7]

      Yfit1a = Result1[0]+RegVar1*Result1[1]+RegVar2*Result1[2]+RegVar3*Result1[3]+RegVar4*Result1[4]+$
      RegVar5*Result1[5]+RegVar6*Result1[6]+RegVar7*Result1[7]

      Fit_Err = Sigma[*]
      
      Yfit2_Err2 = Sigma[0]^2+ Sigma[1]*sigma[1]*CrabVar1*CrabVar1+ Sigma[2]*sigma[2]*CrabVar2*CrabVar2 + Sigma[3]*sigma[3]*CrabVar3*CrabVar3 +$
                  Sigma[4]*sigma[4]*CrabVar4*CrabVar4 + Sigma[5]*sigma[5]*CrabVar5*CrabVar5 + Sigma[6]*sigma[6]*CrabVar6*CrabVar6 + Sigma[7]*sigma[7]*CrabVar7*CrabVar7
      
      Yfit2_Err = Sqrt(Yfit2_Err2)
      Rchi = Chisq
    ; Crab Swp : 92, 93, 94,95, 96,  97, 98, 99, 100
    ; Rescaling for the per kev binning
    Yfit2_scl = Yfit2;/Bin_Size
    Yfit2_Err_Scl = Yfit2_Err;/BIn_Size
    Yfit_Scl = Yfit;/Bin_SIze
    Yfit1a_Scl = Yfit1a;/Bin_Size
    
      Temp_Text = String(Format='(F8.2, 1X, F8.2, 1X, F8.2)',Emin_a[p],Emax_a[p], Rchi)
      
      For j = 0,N_Elements(CrabSwp)-1 Do Begin
          
          Temp_Text = Temp_Text + String(Format = '(1X,F10.5,1X,F10.5)',Yfit2_Scl[j], Yfit2_Err_Scl[j] )
        
      Endfor
      Openw, Lun201, text_title, /get_lun, /append

       Printf,lun201, Temp_Text
      Free_Lun, lun201
      
       If Plot_flag Eq 1 Then Begin
     Ymax = Max(Instruc.Rate)*1.25
     Ymin = Min(Instruc.Rate)*0.8
          filename = title+STRN(FIX(EMIN_a[p]))+'_'+STRN(Fix(EMAX_a[p]))+'_PCA_Bgd'
          CGPS_open, filename+'.ps',/Landscape
          CgPlot, Instruc.Swp, Instruc.Rate, PSYM=4,SymSize=1,  Err_YHigh =Instruc.Err, Err_YLow= Instruc.Err, Xrange=[20,105],$
            title=title1, Yrange=[Ymin,Ymax]
          CGoPlot, RegSwp, Yfit, Color='Blue'
          CgoPlot, CrabSwp, Yfit2, Color='Red'
          CgoPlot, RegSwp, Yfit1a, Color='Green'
        
          CgText, !D.X_Size*0.70,!D.Y_Size*0.93,'R-Chi='+STRN(Rchi),/DEVICE, CHarSize=1.7,Color=CgColor('Black')
          CgText, !D.X_Size*0.70,!D.Y_Size*0.00,'Emin='+STRN(Emin_a[p]),/DEVICE, CHarSize=1.0,Color=CgColor('Black')
          CgText, !D.X_Size*(0.70),!D.Y_Size*0.03,'Emax='+STRN(Emax_a[p]),/DEVICE, CHarSize=1.0,Color=CgColor('Black')

          CGPS_Close
          CgPS2Pdf, filename+'.ps', delete_ps=1
          
      EndIf ; Plot_flag
       Close, /all
  EndFor ; P
  
  Openw, lun2, title+'_PlotVar_PCA_Reg1.txt',/Get_lun
  
  printf, lun2, 'RateGen file data'
  printf, lun2, ' Swp, Rate, Err'
  printf, lun2, ' '
  for i = 0, n_elements(Instruc)-1 do begin
    printf, lun2, Instruc[i].swp, Instruc[i].rate, Instruc[i].err
  Endfor
  printf, lun2, ' '
  printf, lun2, ' fitted values '
  printf, lun2, ' just fitted values'
  for i = 0, n_elements(Yfit)-1 do begin
    
    printf, lun2,RegSwp[i], yfit[i]
  EndFor
  printf,lun2,'Crab'
  for i = 0, n_elements(Yfit2)-1 do begin

    printf, lun2,CrabSwp[i], yfit2[i], Yfit2_Err[i]
  EndFor
  
  free_lun, Lun2

End