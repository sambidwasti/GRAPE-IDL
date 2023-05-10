Pro Gsim_Grp_CT_SecElec,filelist_arr, PSD=PSD, Side=Side, Cor=Cor, N=N, foldername=foldername, UP=UP

  ;
  ;The secondary electron input spectrum for upward and downward is the same.
  ;It is only simulated for different geometry for the incoming spectrum. 
  ;
  ; N is the number of photos

  ;These should be the four gamma sim files.
  ;
  ;The naming of the gamma file should be
  ;
  ;Run##_gamma$$_N.gsim.csv.dat
  ;$$ is the component of the gamma that is needed for combined
  ;
  True =1
  False =0
  
  nfiles = n_elements(filelist_arr)

 If keyword_set(Up) ne 0 then Upflag = true Else Upflag = false
 PRint, UpFlag
  ;
  ;Step 1
  ;Level 2 Processing:

  For p = 0, nfiles-1 Do Begin
    filename = filelist_arr[p]
    Gsim_Grp_l1_Process2, filename,PsdEff=PSD, Per=Side, Cor=Cor, foldername=foldername
  Endfor

  ;;
  ;Output of obove will be
  ;PSD_##_Side_##_Cor_##_Run##_gamma$_
  ;
  ;Combine the gamma files.
  ;Typically, its sorted by name so it automatically chooses the right files.
  ;We need to fix that.

  ;
  ;
  ;Step 2
  ; Combine and Normalize the component.
  ; CAREFUL about the normalization constant. That is the N value of the photons.
  ;
  title1 = 'PSD_'+Strn(PSD)+'_Side_'+Strn(Side)+'_Cor_'+Strn(Cor)

  if UpFlag Eq True then begin

    fil_srch1 = foldername+'PSD_'+Strn(PSD)+'_Side_'+Strn(Side)+'_Cor_'+Strn(Cor)+'*SecUpElec*lvl1.dat'
    GSim_GRP_com_sec_electron_up, fil_srch1,title=title1,foldername=foldername
    GSim_GRP_com_sec_electron_up, fil_srch1,title=title1,foldername=foldername,type=1
    GSim_GRP_com_sec_electron_up, fil_srch1,title=title1,foldername=foldername,type=2
    GSim_GRP_com_sec_electron_up, fil_srch1,title=title1,foldername=foldername,type=3
  endif Else Begin
    fil_srch1 = foldername+'PSD_'+Strn(PSD)+'_Side_'+Strn(Side)+'_Cor_'+Strn(Cor)+'*SecDownElec*lvl1.dat'
    GSim_GRP_com_sec_electron_down, fil_srch1,title=title1,foldername=foldername
    GSim_GRP_com_sec_electron_down, fil_srch1,title=title1,foldername=foldername,type=1
    GSim_GRP_com_sec_electron_down, fil_srch1,title=title1,foldername=foldername,type=2
    GSim_GRP_com_sec_electron_down, fil_srch1,title=title1,foldername=foldername,type=3
  EndElse

  

Print, 'Grp_CT_SECELEC'



End