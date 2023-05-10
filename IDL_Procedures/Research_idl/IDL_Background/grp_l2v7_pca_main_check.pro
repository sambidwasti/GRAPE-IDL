Pro Grp_l2v7_PCA_main_check, spreadfile, Title= Title, nfiles=nfiles
  ;
  ; - This is derived from pca main 
  ; This is to check the older pCA from IDL version. Here we are just reading in the prn file 
  ;   forom older analysis
  ; Input:
  ;   -  It takes prn file.
  ;NOTE:
  ;   - For PCA,
  ;       We approximate Background observations and apply that to crab observation.
  ;Additional Note:
  ;   - Currently doing Sweep wise. To change this for time wise, we add filters for time and not sweep.
  ;   - Sweep 101 = Termination
  ;   - Sweep 92- 100 Grp
  ;
  ; OUTPUT:
  ;   -   This generates a text file with new principle component vectors.
  ;

  IF Keyword_Set(title) Eq 0 Then Title=''else Title=title+'_'

  PCA_Val = 99
  ;********** Read in the column file and sort it into arrays ************
  ReadCol, spreadFile, SwpNo, GpsTime, Alt, Dep, Zen, $ 
   AcTot, Ac1, AC2, Ac3, Ac4, Ac5, Ac6,  $
   T1, T2, T3,T4, PC, PCErr
    Format='I,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D'
  ; Format =            Line1   ;             ;
  ;**************************************************************************

  ; PCA doesnt require Rate and Rate Error.

  ; So we have various parameters:
  ;  SwpNo, Time, T1, T2, T3, T4, T5, T6, T7, T8, AC1, AC2, AC2, AC3, AC4, AC5, AC6, ACTot, Alt, Dep, ZEn, Azi

  ; Standardize these and get them in an array.
  ; Its 20variables.

  NoSwp = N_Elements(SwpNO)
  Init_MainArray = [Transpose(Alt),Transpose(Dep),Transpose(Zen),Transpose(AcTot),Transpose(AC1),Transpose(AC2),Transpose(AC3),Transpose(AC4),Transpose(AC5),Transpose(AC6),Transpose(T1),Transpose(T2),Transpose(T3),Transpose(T4)]
  ; FLOAT     = Array[14, 74]
  Help, Init_MainArray


  ; Standardize it. We need Std and mean.
  NoVar = 14
  StdArr = DblArr(NoVar)
  MeanArr = DblArr(NoVar)
  Std_MainArray = Dblarr(NoVar,NoSwp)
  for i =0, NoVar-1 Do Begin
    tempvar = Init_MainArray[i,*]
    stdval = stddev(tempvar)
    avgval = avg(tempvar)
    newtempvar = (tempvar-avgval)/stdval
    Std_MainArray[i,*] = newtempvar
  endfor
    
   Openw, Lun99, 'CorMat_Excel_Check.txt',/Get_lun
   Printf, Lun99, Std_MainArray, format='(f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3)'

  ;- We have a standardize array.
  ; Now we need a correlation matrix.
  ; For each variable in A, we just need a sum of (A[i] * A[j] / noRows-1) which would give us a n*n dimensional array.
  CorMatrix = DblArr(NOVar,NoVar)
  For i = 0,NoVar-1 Do begin
    For j = 0, NoVar-1 DO begin
      CorVal =  Total((Std_MAinArray[i,*])*(Std_MAinArray[j,*]))/(NOSWP-1)
      CorMatrix[i,j] = CorVal
    Endfor
  Endfor
; Print, CorMatrix, format='(f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3)'
  
 Printf, Lun99, ''
  Printf, Lun99, ''
   Printf, Lun99, ''
 Printf, Lun99, ''
 Printf, Lun99, 'Cor Matrix'
 Printf, Lun99, CorMatrix, format='(f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3)'
 

  ; Print, CorMatrix
;  Print, CorMatrix
  Eigen_Val = EigenQL(CorMAtrix, EigenVectors = Eigen_Vecs, Residual = Residual)
  Printf, Lun99, ''
  Printf, Lun99, ''
  Printf, Lun99, 'Eigen Val'

  printf,Lun99, eigen_val, format='(f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3)



  Sum_Eigen = Total(Eigen_Val)
  Rel_Eigen_Val = 100*Eigen_Val/Sum_Eigen
  Var_Eigen_Val = Rel_Eigen_Val * 0.0D
  ;  print, sum_eigen
  ;  Print, rel_eigen_Val
  ;  stop
  For i = 0, N_Elements(Rel_Eigen_Val)-1 Do begin
    Var_Eigen_Val[i] = Total(Rel_Eigen_Val[0:i])
  Endfor
  Printf, lun99, 'Variation'
  printf,Lun99, Var_eigen_val, format='(f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3)
 
 printf,lun99,' '
 printf, lun99,' '
 Printf, lun99, 'Eigen Vectors'
  printf,Lun99, Eigen_Vecs, format='(f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3)


   ; Now each PC component is a linear combination of Eigen Vector and standardized values.
  ; Check for usage of Eigen Vector and values in sol_iss_vectors series.

  A =where( Var_Eigen_Val GT PCA_Val)
  PCA_no = 6;Fix(A[0])
  PCA_Var = DblArr(PCA_no+1,NoSwp)
  help, pca_Var

  ; Now doing linear combinations to get the new pca
  for j = 0, NoSwp-1 Do begin
    for i = 0, PCA_no Do begin
      Main_Array_Hor = Std_MainArray[*,j]
      Cur_Eigen = Eigen_Vecs[*,i]
      Lin_Com = Total(Cur_Eigen * Main_Array_Hor)

      PCA_Var[i,j]=Lin_Com
    Endfor
  EndFor
  print
  print
  Temp_vec = FltArr(pca_no+1,noVar)
  help, temp_vec
  for i = 0, Pca_no do begin
    Temp_vec[i,*] = Eigen_vecs[*,i]
  endfor

  PRint, 'NO of Principle component covering '+STRN(PCA_VAL)+'% of the variation is '+STRN(PCA_No+1)
;  help, pca_var
  ; Get a file of these principle components and variables.
  ; along with sweep no.

  Openw, Lun1, title+'pca_var_excelCheck.txt', /Get_lun
  printf,Lun1, 'These are PCA Variables that covers 97% var'
  printf, Lun1, 'THese ar for the sweeps '+STRN(SWPno[0])+' till '+STRN(SWPno[NoSwp-1])
  printf, lun1, 'Crab sweeps : 92-100'
  printf,lun1, PCa_Var , format='(f8.4,1X,f8.4,1X,f8.4,1X,f8.4,1X,f8.4,1X,f8.4,1X,f8.4)'
  Free_LUN, Lun1
  
;  Print, 'Vectors PCA'
;  print, PCa_Var , format='(F8.4,1X, F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'
;
;
;
  
 printf,lun99,' '
 printf, lun99,' '
  printf,Lun99, pca_var, format='(f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3,1X,f6.3)'
  free_lun,Lun99


X10 = pca_var[0,*]
X20 = pca_var[1,*]
X30 = pca_var[2,*]
X40 = pca_var[3,*]
X50 = pca_var[4,*]
X60 = pca_var[5,*]
X70 = pca_var[6,*]

X1 = X10[0:64]
X2 = X20[0:64]
X3 = X30[0:64]
X4 = X40[0:64]
X5 = X50[0:64]
X6 = X60[0:64]
X7 = X70[0:64]

Crab1 = X10[65:73]
Crab2 = X20[65:73]
Crab3 = X30[65:73]
Crab4 = X40[65:73]
Crab5 = X50[65:73]
Crab6 = X60[65:73]
Crab7 = X70[65:73]


X0 = [ Transpose(X1) ,Transpose(X2) ,Transpose(X3) ,Transpose(X4) ,Transpose(X5) ,Transpose(X6) ,Transpose(X7) ]


Y = PC[0:64]

Yerr= PCErr[0:64]
Swp = SwpNo[0:64]
Swp2 = SwpNo[65:73]
result1 = Regress(X0, Y, Measure_errors=Yerr, Chisq=Chi, Const=con, Yfit=Yfit)
Print, Chi
Print, result1[*]

Yfit2 = Con + Crab1*Result1[0]+ Crab2*Result1[1]+Crab3*Result1[2]+Crab4*Result1[3]+Crab5*Result1[4]+Crab6*Result1[5]+Crab7*Result1[6]

window,0
CgPlot, SwpNo, PC, YRange=[12,20], XRange=[20,105], PSYM=4 , Err_YHigh=PCerr, Err_Ylow=PCerr
CgoPlot, Swp, Yfit, Color='Blue'
CgOplot, Swp2, Yfit2, Color='red'
;, PCErr
  Stop
End