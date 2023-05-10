Pro grp_l2v7_Pca_files, pcafile

    Elo = [65,70,90, 120,160,200]
    Ehi = [70,90,120,160,200,300]
  ;  Elo = [80]
  ;  

  ; Ehi = [300]
    title = 'PCA_Analysis_1j_var_bin_65_300'
    grp_l2v7_pca_reg1, pcafile, LoEner=Elo, HiEner=Ehi, title=title, fig=1

End