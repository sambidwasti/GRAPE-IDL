Pro Solving_Issues200
  ; Solving issues for retrieving eigen vectors and values using
  ; Eigenql
  ; Note the matrix is a n x n SYMMETRIC matrix.
 
  A1 = fix(10*RandomU(107,10))+5
  A2 = fix(11*RandomU(97,10))+12
  A3 =fix(3*RandomU(17,10))+15
  help, A1
  Main_Array = [ Transpose(A1), Transpose(A2), Transpose(A3)]
  
;  Print, A1
;  Print
;  Print, Main_Array
;  print
;  help, Main_Array
;  Print, '***'

  Std_Main = dblarr(3,10)
  For i =0, 2 do begin
      Cur_var = Main_Array[i,*]
      std =stddev(Cur_Var)
      av  =avg(Cur_Var)
      temp = (cur_var-av)/std
      std_Main(i,*) = temp
  Endfor

;  Print, Std_Main
;  help,std_main
  cormat = dblarr(3,3)
  for i = 0, 2 do begin
    for j = 0,2 do begin
         corval = Total(std_Main[i,*] * std_main[j,*])
   ;      print, i, j
         cormat[i,j]= corval/9
    endfor
  endfor
;  print
;  print,cormat
;  I have a correlation matrix. 
  Eigen_Val = EigenQL(CorMAt, EigenVectors = Eigen_Vecs, Residual = Residual)
  print, cormat
  print
  print
  print, eigen_vecs
  print
  print, eigen_Val
  
  Print, eigen_vecs(*,0)/eigen_vecs(2,0)
    Print, eigen_vecs(*,1)/eigen_vecs(2,1)
      Print, eigen_vecs(*,2)/eigen_vecs(2,2)
      print
  print, '--------------'
  print, std_main
  help, std_main
  print
  print
  print, std_main(*,0)
  print, eigen_vecs(*,0)
  print, total(std_main(*,0)*eigen_Vecs(*,0))
  
  
;  cormat = dblarr(3,3)
;  for i = 0, 2 do begin
;      for j = 0,2 do begin
;        corval = 0.0
;         for k = 0,9 do begin
;          corval = corval+(std_Main[i,k]*std_main[j,k])
;         endfor
;         cormat[i,j]= corval/9
;      endfor
;  endfor
;  print
;  print,cormat
 
;  Eigen_Val = EigenQL(CorMAtrix, EigenVectors = Eigen_Vecs, Residual = Residual)

End