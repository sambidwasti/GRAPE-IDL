Pro gsim_grp_plot_Compare1, type= type

  ; This shouldonly compare the flight vs One main model fit at a time.
  ; and plot them 
  ; This is supposed to be a plotter.. Just an individual one if needed.
  ; Replicating Gsim_Grp_compare_gamma3 for our purpose
  ; Redefining few params to make it stand alone. 
  ; IT takes into account of each of the component.
  ; running through temp folder. 
  
;  model_file_all = foldername22+'TypeAll/'+Temp_Title+'_ComMod_'+Strn(Com)+'_modfit.txt'
;  model_file_T1 = foldername22+'Type1/'+Temp_Title+'_Type_1_ComMod_'+Strn(Com)+'_modfit.txt'
;  model_file_T2 = foldername22+'Type2/'+Temp_Title+'_Type_2_ComMod_'+Strn(Com)+'_modfit.txt'
;  model_file_T3 = foldername22+'Type3/'+Temp_Title+'_Type_3_ComMod_'+Strn(Com)+'_modfit.txt'
;
;  gsim_grp_compare_gamma3, flt_all, model_file_all,param_array=Param_array,com=com, folder=foldername22
;  gsim_grp_compare_gamma3, flt_typ1, model_file_T1,param_array=Param_array,com=com,TYpe=1, folder=foldername22
;  gsim_grp_compare_gamma3, flt_typ2, model_file_T2,param_array=Param_array,com=com,TYpe=2, folder=foldername22
;  gsim_grp_compare_gamma3, flt_typ3, model_file_T3,param_array=Param_array,com=com,TYpe=3, folder=foldername22

If Keyword_Set(type) NE 0 Then Type=STRN(Type) Else Type='All Type'



PSD = 91
Side = 10
Cor = 5
Min_Ener = 70
Max_Ener = 300
bin = 10
Com= 5
CD, Cur=Cur
foldername22 = cur+'/com'+Strn(Com)+'/'

Temp_Title =    'PSD_'+Strn(PSD)+'_Side_'+Strn(Side)+'_Cor_'+Strn(Cor)

model_file_all = foldername22+'TypeAll/'+Temp_Title+'_ComMod_'+Strn(Com)+'_modfit.txt'
model_file_T1 = foldername22+'Type1/'+Temp_Title+'_Type_1_ComMod_'+Strn(Com)+'_modfit.txt'
model_file_T2 = foldername22+'Type2/'+Temp_Title+'_Type_2_ComMod_'+Strn(Com)+'_modfit.txt'
model_file_T3 = foldername22+'Type3/'+Temp_Title+'_Type_3_ComMod_'+Strn(Com)+'_modfit.txt'
  

; ------Flight Files------
; Bins of 10
flt_all = '/Users/Sam/Work/Sam_programming/GEANT4_Stuffs/GRAPEv8_2014-build/Grp8_Cur_work/Flight_Bin_10/10_40_l2v7_inv3_rebin.txt'
flt_typ1= '/Users/Sam/Work/Sam_programming/GEANT4_Stuffs/GRAPEv8_2014-build/Grp8_Cur_work/Flight_Bin_10/10_40_Type1_l2v7_inv3_rebin.txt'
flt_typ2= '/Users/Sam/Work/Sam_programming/GEANT4_Stuffs/GRAPEv8_2014-build/Grp8_Cur_work/Flight_Bin_10/10_40_Type2_l2v7_inv3_rebin.txt'
flt_typ3= '/Users/Sam/Work/Sam_programming/GEANT4_Stuffs/GRAPEv8_2014-build/Grp8_Cur_work/Flight_Bin_10/10_40_Type3_l2v7_inv3_rebin.txt'


;GAMMAS
Gamma_com_all = cur+'/gammas/TypeAll/'+Temp_Title+'_l1_gamma_com.txt'
Gamma_com_T1 = cur+'/gammas/Type1/'+Temp_Title+'_Type_1_l1_gamma_com.txt'
Gamma_com_T2 = cur+'/gammas/Type2/'+Temp_Title+'_Type_2_l1_gamma_com.txt'
Gamma_com_T3 = cur+'/gammas/Type3/'+Temp_Title+'_Type_3_l1_gamma_com.txt'

;Secondary Electrons Up
Sec_Elec_Up_all = cur+'/SecElec/data_files_up/TypeAll/'+Temp_Title+'_l1_SecUpElec_com.txt'
Sec_Elec_Up_T1  = cur+'/SecElec/data_files_up/Type1/'+Temp_Title+'_Type_1_l1_SecUpElec_com.txt'
Sec_Elec_Up_T2  = cur+'/SecElec/data_files_up/Type2/'+Temp_Title+'_Type_2_l1_SecUpElec_com.txt'
Sec_Elec_Up_T3  = cur+'/SecElec/data_files_up/Type3/'+Temp_Title+'_Type_3_l1_SecUpElec_com.txt'

;Secondary Electrons Down
Sec_Elec_Down_all = cur+'/SecElec/data_files_down/TypeAll/'+Temp_Title+'_l1_SecDownElec_com.txt'
Sec_Elec_Down_T1  = cur+'/SecElec/data_files_down/Type1/'+Temp_Title+'_Type_1_l1_SecDownElec_com.txt'
Sec_Elec_Down_T2  = cur+'/SecElec/data_files_down/Type2/'+Temp_Title+'_Type_2_l1_SecDownElec_com.txt'
Sec_Elec_Down_T3  = cur+'/SecElec/data_files_down/Type3/'+Temp_Title+'_Type_3_l1_SecDownElec_com.txt'

;Secondary Positrons Up
Sec_Posi_Up_all = cur+'/SecPosi/data_files_up/TypeAll/'+Temp_Title+'_l1_SecUpPosi_com.txt'
Sec_Posi_Up_T1  = cur+'/SecPosi/data_files_up/Type1/'+Temp_Title+'_Type_1_l1_SecUpPosi_com.txt'
Sec_Posi_Up_T2  = cur+'/SecPosi/data_files_up/Type2/'+Temp_Title+'_Type_2_l1_SecUpPosi_com.txt'
Sec_Posi_Up_T3  = cur+'/SecPosi/data_files_up/Type3/'+Temp_Title+'_Type_3_l1_SecUpPosi_com.txt'

;Secondary Positrons Down
Sec_Posi_Down_all = cur+'/SecPosi/data_files_down/TypeAll/'+Temp_Title+'_l1_SecDownPosi_com.txt'
Sec_Posi_Down_T1  = cur+'/SecPosi/data_files_down/Type1/'+Temp_Title+'_Type_1_l1_SecDownPosi_com.txt'
Sec_Posi_Down_T2  = cur+'/SecPosi/data_files_down/Type2/'+Temp_Title+'_Type_2_l1_SecDownPosi_com.txt'
Sec_Posi_Down_T3  = cur+'/SecPosi/data_files_down/Type3/'+Temp_Title+'_Type_3_l1_SecDownPosi_com.txt'

;Primary Electrons
Pri_Elec_all = cur+'/PriElec/TypeAll/'+Temp_Title+'_l1_PriElec_com.txt'
Pri_Elec_T1  = cur+'/PriElec/Type1/'+Temp_Title+'_Type_1_l1_PriElec_com.txt'
Pri_Elec_T2  = cur+'/PriElec/Type2/'+Temp_Title+'_Type_2_l1_PriElec_com.txt'
Pri_Elec_T3  = cur+'/PriElec/Type3/'+Temp_Title+'_Type_3_l1_PriElec_com.txt'

;Primary Electrons
Pri_Posi_all = cur+'/PriPosi/TypeAll/'+Temp_Title+'_l1_PriPosi_com.txt'
Pri_Posi_T1  = cur+'/PriPosi/Type1/'+Temp_Title+'_Type_1_l1_PriPosi_com.txt'
Pri_Posi_T2  = cur+'/PriPosi/Type2/'+Temp_Title+'_Type_2_l1_PriPosi_com.txt'
Pri_Posi_T3  = cur+'/PriPosi/Type3/'+Temp_Title+'_Type_3_l1_PriPosi_com.txt'


SimFiles_all = [Gamma_com_all, Sec_Elec_Up_all, Sec_Elec_Down_all,SEc_Posi_Up_all, Sec_Posi_Down_all, Pri_Elec_all, Pri_Posi_all]
SimFiles_T1  = [Gamma_com_T1,  Sec_Elec_Up_T1,  Sec_Elec_Down_T1, Sec_Posi_Up_T1,  Sec_Posi_Down_T1,  Pri_Elec_T1,  Pri_Posi_T1]
SimFiles_T2  = [Gamma_com_T2,  Sec_Elec_Up_T2,  Sec_Elec_Down_T2, Sec_Posi_Up_T2,  Sec_Posi_Down_T2,  Pri_Elec_T2,  Pri_Posi_T2]
SimFiles_T3  = [Gamma_com_T3,  Sec_Elec_Up_T3,  Sec_Elec_Down_T3, Sec_Posi_Up_T3,  Sec_Posi_Down_T3,  Pri_Elec_T3,  Pri_Posi_T3]


  Param_Array = [Strn(PSD), Strn(Side), Strn(Cor), Strn(Min_Ener), Strn(Max_Ener)]


;------- Now we plot the All types first.
  BinSize = 10
  nbins = 1000/binsize
  
  
  ;
  ; Each files are two column 1000bin files.
  ; We add the components and rebin them to 10KeV binsize.
  ;

  nfiles = 7

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

  If Type EQ 'All Type' Then Begin
     Files = SImFiles_all 
     Plot_Title ='Flight vs Model (PC All Type)' 
     File_Title = Temp_Title+'Com'+Strn(Com)+'AllType.ps'
     EndIf Else If Type EQ '1' Then BEgin
       Files = SImFiles_T1
       Plot_Title ='Flight vs Model (PC Type 1)'
        File_Title = Temp_Title+'Com'+Strn(Com)+'Type1.ps'
  EndIF Else If Type EQ '2' Then BEgin
       Files = SImFiles_T2
       Plot_Title ='Flight vs Model (PC Type 2)'
        File_Title = Temp_Title+'Com'+Strn(Com)+'Type2.ps'
     EndIF Else If Type EQ '3'Then BEgin
       Files = SImFiles_T3
       Plot_Title ='Flight vs Model (PC Type3)'
       File_Title = Temp_Title+'Com'+Strn(Com)+'Type3.ps'
     EndIF


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

;Need Rebinning
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



;  CGPlot,Indgen(100)*binsize,MainHist, PSYM=10, Color='Blue',$
;    /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[50,400], YRange=[10E-8,0.2],$
;    err_Yhigh = MainHist_Err, Err_YLow = MainHist_Err,/Err_Clip,Err_Color='Blue'

  
  
  
  True = 1
  False = 0
  
  simfile_all = model_file_all
    simfile_typ1 = model_file_T1
      simfile_typ2 = model_file_T2
        simfile_typ3 = model_file_T3

Color_array = ['Black','Blue', 'red', 'Purple', 'Dark Green', 'Navy', 'Deep Pink', 'Dark Gray', 'Orange']
Color_Title = ['Flight','Model Fit','Sim Gamma', 'Sim Sec Elec Up', 'Sim Sec Elec Down', 'Sim Sec Posi Up','Sim Sec Posi Down', 'Sim Pri Elec', 'Sim Pri Posi']
; All Type
 
  ; Read in the flight --
  ReadCol, flt_all, Flight1_All, Flight1_All_err, format='F,F'
   ReadCol, flt_typ1, Flight1_typ1, Flight1_typ1_err, format='F,F'
    ReadCol, flt_typ2, Flight1_typ2, Flight1_typ2_err, format='F,F'
     ReadCol, flt_typ3, Flight1_typ3, Flight1_typ3_err, format='F,F'


  ReadCol, simfile_all, gamma_all,  format='F'
    ReadCol, simfile_typ1, gamma_typ1,  format='F'
      ReadCol, simfile_typ2, gamma_typ2,  format='F'
        ReadCol, simfile_typ3, gamma_typ3,  format='F'

   XErr= 5
   Title = Cur+'/'+File_Title
   CgPs_Open, Title, Font =1, /LandScape
     
   CGPlot,Indgen(100)*10,flight1_all, PSYM=3, Color='Black',$;linestyle=0,$
     /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[50,400], YRange=[10E-9,0.2],$
     err_Yhigh = flight1_all_Err, Err_YLow = flight1_all_Err,/Err_Clip,Err_Color='Black',$
     err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0, Xgridstyle=2, Xtitle='Energy (keV)', YTitle= 'Counts /(keV s)',$
     title= Plot_TItle 
   CgOplot, Indgen(100)*10,gamma_all, Color='Blue',Thick=5;,PSYM=3,  err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0,/Err_Clip
   vline, 70, color='Blue',linestyle=3
   vline, 300, color='Blue',linestyle=2
  
   CGText, !D.X_Size*0.93,!D.Y_Size*(0.3), 'Model Params',/DEVICE, CHarSize=1.2
   CGText, !D.X_Size*0.93,!D.Y_Size*(0.27), 'PSD Eff= 91',/DEVICE, CHarSize=1
   CGText, !D.X_Size*0.93,!D.Y_Size*(0.24), 'Side CT= 10',/DEVICE, CHarSize=1
   CGText, !D.X_Size*0.93,!D.Y_Size*(0.21), 'Cor  CT= 5',/DEVICE, CHarSize=1
   
   CgLegend, SymColors=Color_array,PSyms=[1,1,1,1,1,1,1,1,1], Location=[0.94,0.90],$
     Titles=Color_title,length=0, Tcolors=Color_array,  charsize=0.85
  
  ;Gamma
    CGoplot, Indgen(100)*binsize, Temp_hist1, PSYM=3, Color=Color_array[2],$
     err_Yhigh = Temp_Hist1_Err, Err_YLow =Temp_Hist1_Err,/Err_Clip,Err_Color=Color_array[2],err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0

  ;Sec Elec Up
   CGoplot, Indgen(100)*binsize, Temp_hist2, PSYM=3, Color=Color_array[3],$
     err_Yhigh = Temp_Hist2_Err, Err_YLow =Temp_Hist2_Err,/Err_Clip,Err_Color=Color_array[3],err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0
     ;Sec Elec Down
   CGoplot, Indgen(100)*binsize, Temp_hist3, PSYM=3, Color=Color_array[4],$
     err_Yhigh = Temp_Hist3_Err, Err_YLow =Temp_Hist3_Err,/Err_Clip,Err_Color=Color_array[4],err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0
     
  ;Sec Posi Up
   CGoplot, Indgen(100)*binsize, Temp_hist4, PSYM=3, Color=Color_array[5],$
     err_Yhigh = Temp_Hist4_Err, Err_YLow =Temp_Hist4_Err,/Err_Clip,Err_Color=Color_array[5],err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0

   CGoplot, Indgen(100)*binsize, Temp_hist5, PSYM=3, Color=Color_array[6],$
     err_Yhigh = Temp_Hist5_Err, Err_YLow =Temp_Hist5_Err,/Err_Clip,Err_Color=Color_array[6],err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0

   CGoplot, Indgen(100)*binsize, Temp_hist6, PSYM=3, Color=Color_array[7],$
     err_Yhigh = Temp_Hist6_Err, Err_YLow =Temp_Hist6_Err,/Err_Clip,Err_Color=Color_array[7],err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0


   CGoplot, Indgen(100)*binsize, Temp_hist7, PSYM=3, Color=Color_array[8],$
     err_Yhigh = Temp_Hist7_Err, Err_YLow =Temp_Hist7_Err,/Err_Clip,Err_Color=Color_array[8],err_XHigh = Xerr, Err_Xlow=Xerr, Err_Width=0

   CgPS_Close
   CGPS2PDF, Title,delete_ps=1

End