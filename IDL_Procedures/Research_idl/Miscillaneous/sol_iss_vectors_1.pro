Pro Sol_Iss_Vectors_1
  ; Solving issues for retrieving eigen vectors and values using
  ; Eigenql
  ; Note the matrix is a n x n SYMMETRIC matrix. 
  A = Double([ [1,2,3],[2,4,5],[3,5,8]])
  print, a
  print
  B= Eigenql(A,EigenVectors = Eigen_Vecs, Residual = Residual)
  Print, B
  print , 'Eigen_Vecs'
  Print, Eigen_Vecs
  Print
  NewEigen = Eigen_Vecs/Eigen_Vecs[2,2]
  Print ,'New EIgen'
  Print, NewEigen[*,2]
  Print, 'Format styles'
  Print, NewEigen,  format='(F8.4,1X,F8.4,1X,F8.4)'
  
  ; From wolfram, we have eigenvalues the same
  ; Vectors are :
  ; 0.246, -1.81, 1 For -1.48 val. 
  ;
  ; So Eigenvalue at positon 2 referes to eigen vectors at Eigenvectors at [*,2]
  ;
  ;
  Print
  A1 = Double([[0.93,1],[1,0.93]])
  print, A1
  B1 = Eigenql(A1, EigenVectors =Eig)
  print, B1
  print
  Print, Eig
  Print, Eig[*,1]
  
End