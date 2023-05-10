pro solving_issues23,fsearch_string
; Using this to verify the counts histogram for the same file for pca and teh polarization to be the same
files = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

Grp_L2v7_Flt_Polarization, files
A = Grp_l2v7_PCA_rate_Gen_1_pol( files, Emin = 70.0, Emax = 200.0)
print, A


end