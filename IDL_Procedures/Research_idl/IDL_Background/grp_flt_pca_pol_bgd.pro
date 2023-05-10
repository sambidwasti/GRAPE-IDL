Pro Grp_Flt_PCA_Pol_Bgd
;, pcafile
  ; Generating this as the rate gen with scaling was an issues.
  Elo = [70.0]
  Ehi = [200.0]
  title = 'PCA_Analysis_Bgd4_Pol_var_bin_70_200'
  pcafile='/Users/sam/Dropbox/Cur_Work/Drop_Grape_Flt_2014/SCC-all_1/pca_var.txt'
  grp_l2v7_pca_reg1_pol_bgd, pcafile, LoEner=Elo, HiEner=Ehi, title=title, fig=1
End