Pro Regfit2, input_file, N=N
  ;Read in the input file and do a double regression.
  ;The input file must have a following format for Z = A +BX1 +C X2 . fit..
  ; Z Zerr, X, Y.., Four Columns
  CD, Cur = Cur
  If Keyword_Set(N) EQ 0 Then N = 2
  
  If N Eq 1 Then Begin
    ReadCol, input_file, Z, Zerr,X1, format ='D,D,D,D'
    
    X0 = DblArr(N_Elements(X1))
    for i = 0,N_elements(x1)-1 Do X0[i]=1.0

    X = [Transpose(X0), Transpose(X1)]
  Endif

  If N Eq 2 Then Begin
    ReadCol, input_file,Z, Zerr, X1, X2,  format ='D,D,D,D'
    
    X0 = DblArr(N_Elements(X1))
    for i = 0,N_elements(x1)-1 Do X0[i]=1.0
    
    X = [Transpose(X0), Transpose(X1), Transpose(X2)]
      
  Endif

  If N Eq 3 Then begin
    ReadCol, input_file,  Z, Zerr, X1, X2,X3,format ='D,D,D,D,D'
    
    X0 = DblArr(N_Elements(X1))
    for i = 0,N_elements(x1)-1 Do X0[i]=1.0
    
        X = [Transpose(X0), Transpose(X1), Transpose(X2), Transpose(X3)]

  Endif

  If N Eq 4 Then begin
    ReadCol, input_file,Z, Zerr, X1, X2,X3,X4,  format ='D,D,D,D,D,D'
    
    X0 = DblArr(N_Elements(X1))
    for i = 0,N_elements(x1)-1 Do X0[i]=1.0
    
    
    X = [Transpose(X0), Transpose(X1), Transpose(X2), Transpose(X3), Transpose(X4)]

  Endif

  If N Eq 5 Then begin
    ReadCol, input_file,Z, Zerr, X1, X2,X3,X4,X5,  format ='D,D,D,D,D,D,D'
     X0 = DblArr(N_Elements(X1))
    for i = 0,N_elements(x1)-1 Do X0[i]=1.0D

    X = [Transpose(X0), Transpose(X1), Transpose(X2), Transpose(X3), Transpose(X4), Transpose(X5)]

  Endif
  
  If N Eq 6 Then begin
    ReadCol, input_file, Z, Zerr, X1, X2,X3,X4,X5, X6,  format ='D,D,D,D,D,D,D'
    X0 = DblArr(N_Elements(X1))
    for i = 0,N_elements(x1)-1 Do X0[i]=1.0D

    X = [Transpose(X0), Transpose(X1), Transpose(X2), Transpose(X3), Transpose(X4), Transpose(X5), Transpose(X6)]

  Endif
  
  If N Eq 7 Then begin
    ReadCol, input_file, Z, Zerr, X1, X2,X3,X4,X5, X6,X7, format ='D,D,D,D,D,D,D'
    X0 = DblArr(N_Elements(X1))
    for i = 0,N_elements(x1)-1 Do X0[i]=1.0D

    X = [Transpose(X0), Transpose(X1), Transpose(X2), Transpose(X3), Transpose(X4), Transpose(X5), Transpose(X6), Transpose(X7)]

  Endif
  
  If N Eq 8 Then begin
    ReadCol, input_file, Z, Zerr, X1, X2,X3,X4,X5, X6,X7,X8, format ='D,D,D,D,D,D,D,D'
    X0 = DblArr(N_Elements(X1))
    for i = 0,N_elements(x1)-1 Do X0[i]=1.0D

    X = [Transpose(X0), Transpose(X1), Transpose(X2), Transpose(X3), Transpose(X4), Transpose(X5), Transpose(X6), Transpose(X7), Transpose(X8)]

  Endif
  
  If N Eq 9 Then begin
    ReadCol, input_file, Z, Zerr, X1, X2,X3,X4,X5, X6,X7,X8,X9, format ='D,D,D,D,D,D,D,D,D'
    X0 = DblArr(N_Elements(X1))
    for i = 0,N_elements(x1)-1 Do X0[i]=1.0D

    X = [Transpose(X0), Transpose(X1), Transpose(X2), Transpose(X3), Transpose(X4), Transpose(X5), Transpose(X6), Transpose(X7),Transpose(X8), Transpose(X9)]

  Endif
  
  ZWeight = 1/(Zerr*Zerr)
    
  Result1 = Regress2(X, Z,ZWeight,YFit,Sigma,Ftest,R,Rmul, Chisq)
  
  Print, 'First Coefficent is the Constant Term'
  Print, 'Coeeficients: ', Result1[*]
  Print, 'Standard Errors: ', Sigma[*]
  Print, 'Red Chi_Sqr: ',Chisq
  Print, 'R :', R
  Print, 'Rmul :', Rmul
  Print, '__'
  Print, 'DoF :', N_Elements(X1)-N
  ;Print, Yfit
  Print
  Print, 'No. of Regression: ',N
  
  OpenW, Lun1, Cur+'/regfit2.txt',/Get_Lun
      Printf, lun1 , 'First Coefficent is the Constant Term'
      Printf, lun1 , 'Coeeficients: ', Result1[*]
      Printf, lun1 , 'Standard Errors: ', Sigma[*]
      Printf, lun1 , 'Red Chi_Sqr: ',Chisq
      Printf, lun1 , 'R :', R
      Printf, lun1 , 'Rmul :', Rmul
      Printf, lun1 , '__'
      Printf, lun1 , 'DoF :', N_Elements(X1)-N
      Printf, lun1 , 'No. of Regression: ',N
  Free_lun, Lun1
  
  Stop
End