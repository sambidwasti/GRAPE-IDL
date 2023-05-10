Pro Grp_l2v7_PCA_main_debug, spreadsheet_col_File, Title= Title, nfiles=nfiles
  ;
  ; - This is derived from pca file gen 1.
  ; Input:
  ;   -  It takes in the file pca file gen2 (aux_spread_File)
  ;           - note with the edition of the files, the reading in should be changed.
  ;           - right now.. ver1.0
  ;   -  It takes in the energy ranges for the sweeps
  ;           - Default 1 energy range, Emin - Emax
  ;           - Typically input the array of Emax and Emin.
  ;           - and generates a rate and rate error.
  ;   -  It does the pca afterwards.
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
  ;Additional Notes:
  ;     - Currently only selecting few since we know a lot of them are redundant
  ;     - AC Rates. AC1 Bottom, AC5 (Top) ,A2(one of the side) and total
  ;     - Temp, T1 module air, Mod Temp, Electric base plate.
  ;     - Alt, Zen, Azi
  ;
  ;

  IF Keyword_Set(title) Eq 0 Then Title=''else Title=title+'_'

  PCA_Val = 99
  ;********** Read in the column file and sort it into arrays ************
  ReadCol, spreadsheet_col_File, SwpNo, GpsTime, T1, T2, T3, T4, T5, T6, T7, T8,$
    Ac1, AC2, Ac3, Ac4, Ac5, Ac6, AcTot, $
    Alt, Dep, Zen, Azi,modTemp, $
    Format='I,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D'
  ; Format =            Line1   ;             ;
  ;**************************************************************************

  Openw, Lun22, 'PCA_Text_Log.txt',/Get_Lun
  printf, lun22, ' An output of the PCA workings '
  printf, lun22, ' Currently selecting 10.  Alt, Ze,  ACtot, AC1, AC2,AC3,AC4 AC5,AC6 T1,T2, T8, ModT'
  printf, lun22, ''
  printf, lun22, ''

  ; PCA doesnt require Rate and Rate Error.

  ; So we have various parameters:
  ;  SwpNo, Time, T1, T2, T3, T4, T5, T6, T7, T8, AC1, AC2, AC2, AC3, AC4, AC5, AC6, ACTot, Alt, Dep, ZEn, Azi, modTemp
  ; Only selecting. T1, T8, ModTemp, AC1, AC2, AC5, ACTot, Alt, Zen, Azi, ModTemp
  ; Standardize these and get them in an array.

  NoSwp = N_Elements(SwpNO)

  Init_MainArray = [Transpose(Alt),Transpose(Zen),Transpose(AcTot),Transpose(AC1),Transpose(AC2),Transpose(AC3),Transpose(AC4),Transpose(AC5), Transpose(AC6),Transpose(T1),Transpose(T8),Transpose(ModTemp)]


  ;  Init_MainArray = [Transpose(Alt),Transpose(Dep),Transpose(Zen),Transpose(AcTot),Transpose(AC1),Transpose(AC2),Transpose(AC3),Transpose(AC4),Transpose(AC5), Transpose(AC6),Transpose(T1),Transpose(T2),Transpose(T8),Transpose(ModTemp)]

  ;  Init_MainArray = [Transpose(Alt),Transpose(Dep),Transpose(Zen),Transpose(AcTot),Transpose(AC1),Transpose(AC2),Transpose(AC3),Transpose(AC4),Transpose(AC5), Transpose(AC6),Transpose(T1),Transpose(T2),Transpose(T8),Transpose(ModTemp)]

  ; INIT_MAINARRAY  DOUBLE    = Array[74, 19]
  Help, Init_MainArray

  printf, lun22, 'Main Spreadsheet'
  printf, lun22, Init_MainArray,  format='(F12.4,1X,F10.4,1X,F10.4,1X,F10.4,1X,F10.4,1X,F10.4,1X,F10.4,1X,F10.4,1X,F10.4,1X,F10.4,1X,F10.4,1X,F10.4)'
  printf, lun22, ''
  printf, lun22, ''


  ; Standardize it. We need Std and mean.
  NoVar = 12
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
  printf, lun22, ' Standardized Array '
  printf, lun22, ' ------------------- '
  printf, lun22, Std_MainArray, format='(F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'
  printf, lun22, ''
  printf, lun22, ''

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
  ; Print, CorMatrix

  Eigen_Val = EigenQL(CorMAtrix, EigenVectors = Eigen_Vecs, Residual = Residual)
  printf, lun22, 'Correlation Matrix'
  printf, lun22, CorMatrix, format='(F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'
  printf, lun22, ''
  printf, lun22, ''

  printf, lun22, 'Eigen Values: '
  Printf, lun22, Eigen_val,format='(F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'
  Printf, Lun22, ''


  Sum_Eigen = Total(Eigen_Val)
  Rel_Eigen_Val = 100*Eigen_Val/Sum_Eigen
  Var_Eigen_Val = Rel_Eigen_Val * 0.0D

  Printf, lun22, ' Variance of the Eigen values '
  printf, lun22, Rel_eigen_val, format='(F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'

  ;  print, sum_eigen
  ;  Print, rel_eigen_Val
  ;  print, var_eigen_Val
  ;  stop
  For i = 0, N_Elements(Rel_Eigen_Val)-1 Do begin
    Var_Eigen_Val[i] = Total(Rel_Eigen_Val[0:i])
  Endfor
  print, var_eigen_Val
  printf, lun22, Var_eigen_val, format='(F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'
  printf, lun22, ''
  printf, lun22, 'Eigen Vector'
  printf, lun22, Eigen_Vecs,  format='(F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'

  ; Now each PC component is a linear combination of Eigen Vector and standardized values.
  ; Check for usage of Eigen Vector and values in sol_iss_vectors series.

  A =where( Var_Eigen_Val GT PCA_Val)
  PCA_no = Fix(A[0])
  PCA_Var = DblArr(PCA_no+1,NoSwp)

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
  printf, lun22, ''
  printf, lun22, ' Variation covered by 99% into principal components '
  printf, lun22, PCA_Var,  format='(F8.4,1X, F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'
  free_lun, Lun22
  PRint, 'NO of Principle component covering '+STRN(PCA_VAL)+'% of the variation is '+STRN(PCA_No+1)
  ; Get a file of these principle components and variables.
  ; along with sweep no.
  Openw, Lun1, title+'pca_var.txt', /Get_lun
  printf,Lun1, 'These are PCA Variables that covers 97% var'
  printf, Lun1, 'THese ar for the sweeps '+STRN(SWPno[0])+' till '+STRN(SWPno[NoSwp-1])
  printf, lun1, 'Crab sweeps : 92-100'
  ;   printf,lun1, PCa_Var , format='(F8.4,1X, F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'
  ;   printf,lun1, PCa_Var , format='(F8.4,1X, F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'
  printf,lun1, PCa_Var , format='(F8.4,1X, F8.4,1X,F8.4,1X,F8.4,1X,F8.4,1X,F8.4)'

  Free_LUN, Lun1







  Stop
End