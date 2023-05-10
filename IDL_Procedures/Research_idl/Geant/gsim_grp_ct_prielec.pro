Pro Gsim_Grp_CT_PriElec,filelist_arr, PSD=PSD, Side=Side, Cor=Cor, N=N, foldername=foldername

  ;
  ;The Primary electron input spectrum for upward and downward is the same.
  ;It is only simulated for different geometry for the incoming spectrum.
  ;
  ; N is the number of photos

  ;These should be the four gamma sim files.
  ;
  ;The naming of the gamma file should be
  ;

  ;
  True =1
  False =0

  nfiles = n_elements(filelist_arr)

  ;
  ;Step 1
  ;Level 2 Processing:

  For p = 0, nfiles-1 Do Begin
    filename = filelist_arr[p]
        Gsim_Grp_l1_Process2, filename,PsdEff=PSD, Per=Side, Cor=Cor, foldername=foldername
  Endfor

  title1 = 'PSD_'+Strn(PSD)+'_Side_'+Strn(Side)+'_Cor_'+Strn(Cor)

    fil_srch1 = foldername+'PSD_'+Strn(PSD)+'_Side_'+Strn(Side)+'_Cor_'+Strn(Cor)+'*PriElectrons*lvl1.dat'
    GSim_GRP_l1_norm_pri_elec, fil_srch1,title=title1,foldername=foldername
        GSim_GRP_l1_norm_pri_elec, fil_srch1,title=title1,foldername=foldername,Type=1
             GSim_GRP_l1_norm_pri_elec, fil_srch1,title=title1,foldername=foldername, Type=2
                  GSim_GRP_l1_norm_pri_elec, fil_srch1,title=title1,foldername=foldername, Type=3
  Print, 'Grp_CT_PRiElec'



End