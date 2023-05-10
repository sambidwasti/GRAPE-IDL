Pro Solving_Issues2
; checking the limitation of the array.
A = Double([ [1,2,3],[2,1,4],[3,4,5]])
print, a
help, a
B= Eigenql(A,EigenVectors = Eigen_Vecs, Residual = Residual)
Print, B
print
Print, Eigen_Vecs
Print
Print, Eigen_Vecs/Eigen_Vecs[2,2]
End