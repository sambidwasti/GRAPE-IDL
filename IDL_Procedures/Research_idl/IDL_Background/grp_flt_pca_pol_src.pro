Pro Grp_Flt_PCA_Pol_Src
  ;, pcafile
  ; Generating this as the rate gen with scaling was an issues.
  ; The pol_Src file linked below needs to be modified for selected bgd and source sweep and array numbers.
  Elo = [70.0]
  Ehi = [200.0]
  pcafile='/Users/sam/Dropbox/Cur_Work/Drop_Grape_Flt_2014/SCC-all_1/pca_var.txt'


  ; == Need to modify these for each of the Runs==
  ;===================
  title = 'PCA_Analysis_Cyg_Pol_var_bin_70_200'
  Print, title
  grp_l2v7_pca_reg1_pol_Src, pcafile, LoEner=Elo, HiEner=Ehi, title=title, fig=1
End