Pro Grp_Flt_PCA_Pol_rate
  ;, pcafile
  ; Generating this as the rate gen with scaling was an issues.
  ; The pol_Src file linked below needs to be modified for selected bgd and source sweep and array numbers.
  Elo = [70.0]
  Ehi = [200.0]
  pcafile='/Users/sam/Dropbox/Cur_Work/Drop_Grape_Flt_2014/SCC-all_1/pca_var.txt'

  ;We need to give the sweep numbers.
  Swp_no = [50,51,52,53,54,55]

  ;Creating a check for sweep excluded ones.
  ;There are a total of 74 files
  ; SUN : Swp24- Swp44 :: 0 - 19 (Sweep Excluded no. 38
  ; Bgd2: Swp45- Swp49 :: 20- 24
  ; Cyg1: Swp50- Swp84 :: 25- 57 (Sweep Excluded no. 70, 74
  ; Bgd4: Swp85- Swp91 :: 58- 64
  ; Crab: Swp92- Swp100:: 65- 73


  ; == Need to modify these for each of the Runs==
  ;===================
  title = 'PCA_Analysis_Pol_rate_70_200'
  Print, title
 ; grp_l2v7_pca_rate_selSrc, LoEner=Elo, HiEner=Ehi, title=title, Swp_no=Swp_no
  
  ; this will generate title+'_Reg_Pol_Rate.txt'

End