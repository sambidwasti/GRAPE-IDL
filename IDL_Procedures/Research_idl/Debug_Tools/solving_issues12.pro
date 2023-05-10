Pro solving_issues12, pcafile
  ;  Elo = [65,70,90, 120,160,200]
   ; Ehi = [70,90,120,160,200,300]
    Elo = [70]
   Ehi = [200]
    title = 'PCA_Analysis_Var_Pic_bin_70_200'
    grp_l2v7_pca_reg1, pcafile, LoEner=Elo, HiEner=Ehi, title=title, fig=1
End