Pro Gsim_Grp_Plot_Com, Files , Title=Title, Com=Com, foldername = foldername
  ;
  ;-- Just a new program to combine all the processed component to generate a combined file
  ;   to be smoothed. (This is used by the program when needed to check) 
  ;


  PRINT, '---------------------------------'

  PRint, 'COMBINE NORMALIZED SIM COMPONENTS'
  PRINT, '---------------------------------'

  True=1
  False=0

  Type_Flag = False
  If Keyword_SEt(Type) NE 0 Then Type_Flag = true
  If keyword_set(title) ne 1 then title=''
  If keyword_set(com) eq 0 then com=1

  if keyword_set(foldername) eq 0 then foldername = '' else foldername = foldername ; this is 0 but we have set the ct to be 15%

  folderflag = False
  If keyword_set(foldername) ne 0 then folderflag = true



  BinSize = 10
  nbins = 1000/binsize
  ;
  ; Each files are two column 1000bin files.
  ; We add the components and rebin them to 10KeV binsize.
  ;

  nfiles = n_elements(Files)

  MainHist1 = DblARr(1000)
  MainHist1_Err = DblArr(1000)
  
  TempHist1 = DblARr(1000)
  TempHist2 = DblARr(1000)
  TempHist3 = DblARr(1000)
  TempHist4 = DblARr(1000)
  TempHist5 = DblARr(1000)
  TempHist6 = DblARr(1000)
  TempHist7 = DblARr(1000)
  TempHist8 = DblARr(1000)
  TempHist9 = DblARr(1000)
  
  TempHist1_Err = DblArr(1000)
    TempHist2_Err = DblArr(1000)
      TempHist3_Err = DblArr(1000)
        TempHist4_Err = DblArr(1000)
          TempHist5_Err = DblArr(1000)
              TempHist6_Err = DblArr(1000)
                 TempHist7_Err = DblArr(1000)
                    TempHist8_Err = DblArr(1000)
                       TempHist9_Err = DblArr(1000)
  
  
  for p = 0, nfiles-1 do begin
    fname = Files[p]
    print, fname
    ReadCol,fname, Temp_Hist, Temp_Hist_Err, format='D,D'
    
    if p eq 0 Then begin
        Temphist1 = Temp_hist
        TempHist1_Err= Temp_Hist_Err
    endif Else if p eq 1 Then Begin
      Temphist2 = Temp_hist
      TempHist2_Err= Temp_Hist_Err
     endif Else if p eq 2 Then Begin
      Temphist3 = Temp_hist
      TempHist3_Err= Temp_Hist_Err
      endif Else if p eq 3 Then Begin
      Temphist4 = Temp_hist
      TempHist4_Err= Temp_Hist_Err
      endif Else if p eq 4 Then Begin
      Temphist5 = Temp_hist
      TempHist5_Err= Temp_Hist_Err
     endif Else if p eq 5Then Begin
      Temphist6 = Temp_hist
      TempHist6_Err= Temp_Hist_Err
     endif Else if p eq 6Then Begin
       Temphist7 = Temp_hist
       TempHist7_Err= Temp_Hist_Err      
     endif Else if p eq 7Then Begin
       Temphist8 = Temp_hist
       TempHist8_Err= Temp_Hist_Err           
     endif Else if p eq 8Then Begin
       Temphist9 = Temp_hist
       TempHist9_Err= Temp_Hist_Err
    endif
    
    
    for i = 0, 999 Do begin
      ;Add the components
      MainHist1[i] = MainHist1[i]+Temp_Hist[i]
      MainHist1_Err[i] = MainHist1_Err[i]+Temp_Hist_Err[i]*Temp_Hist_Err[i]
    endfor
  endfor
  MainHist1_Err = Sqrt(MainHist1_Err)

  ;Rebinning all components
  Temp_hist1 = DblArr(100)
  Temp_Hist2 = DblArr(100)
  Temp_Hist3 = DblArr(100)
  Temp_Hist4 = DblArr(100)
  Temp_Hist5 = DblArr(100)
  Temp_Hist6 = DblArr(100)
  Temp_Hist7 = DblArr(100)
  Temp_Hist8 = DblArr(100)
  Temp_Hist9 = DblArr(100)
  
  
  
  
  Temp_Hist1_Err = DblArr(100)
  Temp_Hist2_err = DblArr(100)
  Temp_Hist3_err = DblArr(100)
  Temp_Hist4_err = DblArr(100)
  Temp_Hist5_err = DblArr(100)
  Temp_Hist6_err = DblArr(100)
  Temp_Hist7_err = DblArr(100)
  Temp_Hist8_err = DblArr(100)
  Temp_Hist9_err = DblArr(100)
  
  
  MainHist = DblArr(100)
  MainHist_Err = DblArr(100)
  
  Cntr = 0L
  for i = 0, nbins-1 do begin
        
    TempH   = 0.0D
    TempH_Err = 0.0D
  
        TempH1   = 0.0D
          TempH2   = 0.0D
            TempH3   = 0.0D
               TempH4   = 0.0D
                  TempH5   = 0.0D
                    TempH6   = 0.0D
                      TempH7   = 0.0D
                        TempH8   = 0.0D
                          TempH9   = 0.0D
        
        TempH1_Err = 0.0D
           TempH2_Err = 0.0D
              TempH3_Err = 0.0D
                 TempH4_Err = 0.0D
                    TempH5_Err = 0.0D
                      TempH6_Err = 0.0D
                        TempH7_Err = 0.0D
                          TempH8_Err = 0.0D
                            TempH9_Err = 0.0D
                    
        for j = 0, binsize-1 do begin
          
           TempH   = TempH   + MainHist1[cntr]
           TempH_Err = TempH_Err +MainHist1_Err[cntr]*MainHist1_Err[cntr]
           
          TempH1   = TempH1   + TempHist1[cntr]
            TempH2   = TempH2   + TempHist2[cntr]
              TempH3   = TempH3  + TempHist3[cntr]
                TempH4   = TempH4   + TempHist4[cntr]
                  TempH5   = TempH5   + TempHist5[cntr]
                    TempH6   = TempH6   + TempHist6[cntr]
                      TempH7   = TempH7  + TempHist7[cntr]
                        TempH8   = TempH8   + TempHist8[cntr]
                          TempH9   = TempH9   + TempHist9[cntr]
          ;-- Errors --
          TempH1_Err = TempH1_Err +TempHist1_Err[cntr]*TempHist1_Err[cntr]
               TempH2_Err = TempH2_Err +TempHist2_Err[cntr]*TempHist2_Err[cntr]
                   TempH3_Err = TempH3_Err +TempHist3_Err[cntr]*TempHist3_Err[cntr] 
                         TempH4_Err = TempH4_Err +TempHist4_Err[cntr]*TempHist4_Err[cntr]
                               TempH5_Err = TempH5_Err +TempHist5_Err[cntr]*TempHist5_Err[cntr]
                                    TempH6_Err = TempH6_Err +TempHist6_Err[cntr]*TempHist6_Err[cntr]
                                          TempH7_Err = TempH7_Err +TempHist7_Err[cntr]*TempHist7_Err[cntr]
                                                TempH8_Err = TempH8_Err +TempHist8_Err[cntr]*TempHist8_Err[cntr]
                                                      TempH9_Err = TempH9_Err +TempHist9_Err[cntr]*TempHist9_Err[cntr]
          cntr++  
        endfor ;j

        MainHist[i] = TempH
        MainHist_Err[i] = Sqrt(TempH_Err)
    
    Temp_hist1[i] = TempH1
    Temp_Hist2[i] = TempH2
    Temp_Hist3[i] = TempH3
    Temp_Hist4[i] = TempH4
    Temp_Hist5[i] = TempH5
    Temp_Hist6[i] = TempH6
    Temp_Hist7[i] = TempH7
    Temp_Hist8[i] = TempH8
    Temp_Hist9[i] = TempH9
            

    Temp_Hist1_Err[i] = (Sqrt( TempH1_Err))
    Temp_Hist2_err[i] = (Sqrt( TempH2_Err))
    Temp_Hist3_err[i] = (Sqrt( TempH3_Err))
    Temp_Hist4_err[i] = (Sqrt( TempH4_Err))
    Temp_Hist5_err[i] = (Sqrt( TempH5_Err))
    Temp_Hist6_err[i] = (Sqrt( TempH6_Err))
    Temp_Hist7_err[i] = (Sqrt( TempH7_Err))
    Temp_Hist8_err[i] = (Sqrt( TempH8_Err))
    Temp_Hist9_err[i] = (Sqrt( TempH9_Err))
    
  endfor ; i

  MainHist = MainHist/binsize
  MainHist_Err = MainHist_Err/binsize
  
  Temp_hist1 = Temp_Hist1/binsize
  Temp_hist2 = Temp_Hist2/binsize   
  Temp_hist3 = Temp_Hist3/binsize
  Temp_hist4 = Temp_Hist4/binsize
  Temp_hist5 = Temp_Hist5/binsize
  Temp_hist6 = Temp_Hist6/binsize
  Temp_hist7 = Temp_Hist7/binsize
  Temp_hist8 = Temp_Hist8/binsize
  Temp_hist9 = Temp_Hist9/binsize

  Temp_Hist1_Err = Temp_Hist1_Err/binsize
  Temp_Hist2_Err = Temp_Hist2_Err/binsize
  Temp_Hist3_Err = Temp_Hist3_Err/binsize  
  Temp_Hist4_Err = Temp_Hist4_Err/binsize
  Temp_Hist5_Err = Temp_Hist5_Err/binsize
  Temp_Hist6_Err = Temp_Hist6_Err/binsize
  Temp_Hist7_Err = Temp_Hist7_Err/binsize
  Temp_Hist8_Err = Temp_Hist8_Err/binsize
  Temp_Hist9_Err = Temp_Hist9_Err/binsize
  

 
  CGPlot,Indgen(100)*binsize,MainHist, PSYM=10, Color='Blue',$
    /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[50,400], YRange=[10E-8,0.2],$
    err_Yhigh = MainHist_Err, Err_YLow = MainHist_Err,/Err_Clip,Err_Color='Blue'
    
        CGoplot, Indgen(100)*binsize, Temp_hist1, PSYM=10, Color='Red',$
             err_Yhigh = Temp_Hist1_Err, Err_YLow =Temp_Hist1_Err,/Err_Clip,Err_Color='Red'
            
        CGoplot, Indgen(100)*binsize, Temp_hist2, PSYM=10, Color='Green',$
            err_Yhigh = Temp_Hist2_Err, Err_YLow =Temp_Hist2_Err,/Err_Clip,Err_Color='Green'

        CGoplot, Indgen(100)*binsize, Temp_hist3, PSYM=10, Color='Purple',$
          err_Yhigh = Temp_Hist3_Err, Err_YLow =Temp_Hist3_Err,/Err_Clip,Err_Color='Purple'
          
        CGoplot, Indgen(100)*binsize, Temp_hist4, PSYM=10, Color='Orange',$
          err_Yhigh = Temp_Hist4_Err, Err_YLow =Temp_Hist4_Err,/Err_Clip,Err_Color='Orange'

        CGoplot, Indgen(100)*binsize, Temp_hist5, PSYM=10, Color='Pink',$
          err_Yhigh = Temp_Hist5_Err, Err_YLow =Temp_Hist5_Err,/Err_Clip,Err_Color='Pink'
          
        CGoplot, Indgen(100)*binsize, Temp_hist6, PSYM=10, Color='Yellow',$
          err_Yhigh = Temp_Hist6_Err, Err_YLow =Temp_Hist6_Err,/Err_Clip,Err_Color='Yellow'
          
          
        CGoplot, Indgen(100)*binsize, Temp_hist7, PSYM=10, Color='Navy',$
          err_Yhigh = Temp_Hist7_Err, Err_YLow =Temp_Hist7_Err,/Err_Clip,Err_Color='Navy'
 
End