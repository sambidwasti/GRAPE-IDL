Pro Solving_Issues14
  fsearch_str = '*L2*.dat'
  ;Inputing the rates for a specific energy range.
  InStruc = { $
    Swp :0,$
    Rate : 0.0, $
    Err : 0.0}
  Emin = 90
  Emax = 120
;  InStruc = Grp_l2v7_PCA_rate_Gen_1( fsearch_Str,Emin=Emin, Emax=Emax)
InStruc = Grp_l2v7_PCA_rate_Gen_1_debug( fsearch_Str,Emin=Emin, Emax=Emax, nfiles=1)

help, instruc
print,'***', n_elements(Instruc)
CGPlot, Instruc.Swp, Instruc.Rate, Err_Yhigh = Instruc.Err, Err_YLow = Instruc.Err
for i = 0, N_Elements(Instruc) -1 Do Begin
  Print, INstruc.Swp[i], Instruc.Rate[i],Instruc.Err[i]
endfor
Stop
End