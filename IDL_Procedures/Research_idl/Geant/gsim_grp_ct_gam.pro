 Pro Gsim_Grp_CT_Gam,filelist_arr, PSD=PSD, Side=Side, Cor=Cor, N=N, foldername=foldername

  ;
  ;Basically This should have various parameters needed to fit the parameter space
  ;Call the required procedures form csv.dat to smoothed model.
  ;All done accordingly for Gammas.
  ;
  ; N is the number of photos
  ;
  ; October 23, 2017
  ; Need to start skipping files with the parameter space already defined.
  
  ;
  nfiles = n_elements(filelist_arr)
    title1 = 'PSD_'+Strn(PSD)+'_Side_'+Strn(Side)+'_Cor_'+Strn(Cor)
    CD, Cur = Cur
  ;
  ;Step 1
  ;Level 2 Processing:
        For p = 0, nfiles-1 Do Begin
            filename = filelist_arr[p]


            ;
            ;-- Adding code to skip if the file already processed.
            ;
            temporary_infile = filename
            tempPos100 = 1L
            while TempPos100 GT 0 Do begin
              tempPos101 = TempPos100
              TempPos100 = StrPOs(temporary_Infile,'/',tempPos101+1)

            endwhile
            infile100 =  strmid(filename,TempPos101+1,StrLen(temporary_infile)-TempPos101)
    
            OutPos100 = StrPOs(infile100,'.csv',0)
            OutFile100 = infile100
            OutFile100 = foldername+title1+'_'+Outfile100 +'1.dat'
             Temp_a = file_search(outfile100, Count=File_number)

           if File_number EQ 0 Then Gsim_Grp_l1_Process2, filename,PsdEff=PSD, Per=Side, Cor=Cor, foldername=foldername

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
  fil_srch1 = 'PSD_'+Strn(PSD)+'_Side_'+Strn(Side)+'_Cor_'+Strn(Cor)+'*gamma*lvl1.dat'



  GSim_GRP_l1_com_gamma1, fil_srch1,title=title1,foldername=foldername
    GSim_GRP_l1_com_gamma1, fil_srch1,title=title1,type=1, foldername=foldername
      GSim_GRP_l1_com_gamma1, fil_srch1,title=title1,type=2, foldername=foldername
        GSim_GRP_l1_com_gamma1, fil_srch1,title=title1,type=3, foldername=foldername





End