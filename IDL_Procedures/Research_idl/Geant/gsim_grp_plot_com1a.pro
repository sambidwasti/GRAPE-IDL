Pro Gsim_Grp_Plot_Com1a, fsearch_str , Title=Title,  foldername = foldername, Class = Class, ptitle=ptitle
  ;
  ;   This is a child of Com1 to plot the components
  ;-- This is a modified version of Gsim_Grp_Plot_Com to plot various normalized components.
  ;   The purpose of this is to Read in one or multiple normalized l1processed file and plot them.
  ;   Need more texts.. Need a label to the plots too. May be older way of defining the
  ;
  ;
  ;Right now all the normalized files are in a folder and running this program there.
  ;
  ;
  ;== GOAL for this program ==
  ; Read in the files.
  ; Probably through loops  read in Name/color of the plot. can put the color in the loop and get the number. ?
  ;
  ; Generate couple of different plots.
  ; One with all the plots.
  ; One with summed components..
  ; Just to see it clearly.
  ;
  ;
  ; Changing the format to 2D array.
  ;
  ; Sambid Wasti 02/22/2018
  ; Adding in the flight file even here to see the comparisions.
  ;
  If keyword_set(ptitle) eq 0 then ptitle = '' ; plot title
  If (n_params() EQ 0) Then fsearch_str = '*com.txt'

  ; PSD   Side Cor Min Enr  MAx Ener
  param_array = [ '95', '14', '2',  '120',  '400']

  Plot_title = 'Flt vs Simulated ' + ptitle
  Text1 = '(PSD:'+param_array[0]+ ' Side:'+param_array[1]+' Cor:'+param_array[2]+')'
  FileText1 = '('+param_array[0]+";"+param_array[1]+';'+param_array[2]+')
  FileText = '('+param_array[0]+";"+param_array[1]+';'+param_array[2]+')_model.txt'
print, filetext

  Xmin2 =60
  Xmax2 =500


  PRINT, '---------------------------------'
  PRint, 'COMBINE NORMALIZED SIM COMPONENTS'
  PRINT, '---------------------------------'

  True=1
  False=0
  Files = FILE_SEARCH(fsearch_str)
  print, n_elements(Files)


  If keyword_set(Class) eq 0 then Class = 3 ; Default to PC
  If (Class LT 1) or (Class  GT 3) THen Class = 3
  If class Eq 1 then CText = 'C' Else if Class Eq 2 Then CText = 'CC' Else IF Class Eq 3 Then CText ='PC' Else CText='Others'


;  infile_flag = False
;  if n_params() eq 2 then infile_Flag = True
;

  

   Flight_file = '/Users/sam/Dropbox/Cur_Work/Flight_Bin_10/10_40_PC_l2v7_inv3_rebin.txt'
   ReadCol, flight_file, Flight1, Flight1_err, format='F,F'

  If keyword_set(title) ne 1 then title2='' else Title2 = title+'_'

  if keyword_set(foldername) eq 0 then foldername = '' else foldername = foldername ; this is 0 but we have set the ct to be 15%

  folderflag = False
  If keyword_set(foldername) ne 0 then folderflag = true

  File_title = Title2+'Combined_Plot_'+CText
  cd, Cur = Cur
  BinSize = 10
  nbins = 1000/binsize
  ;
  ; Each files are two column 1000bin files.
  ; We add the components and rebin them to 10KeV binsize.
  ;

  nfiles = n_elements(Files)

  MainHist1 = DblARr(1000)
  MainHist1_Err = DblArr(1000)

  TempHistArr = DblArr(nfiles,1000)
  TempHistErrArr = DblArr(nfiles,1000)

  Neutron_pos =-1
  for p = 0, nfiles-1 do begin
    fname = Files[p]

    ;
    ;-- Creating bunch of selection so that we know what the spectrum is of
    ;
    if strpos(fname,'gamma',0) gt 0 then gamma_pos = p

    if strpos(fname,'Neutron',0) gt 0 then Neutron_pos = p

    if strpos(fname,'PriElec',0) gt 0 then PriElec_pos = p
    if strpos(fname,'PriPosi',0) gt 0 then PriPosi_pos = p
    if strpos(fname,'PriProt',0) gt 0 then PriProt_pos = p


    if strpos(fname,'SecUpElec',0) gt 0 then SecUpElec_pos =p
    if strpos(fname,'SecDownElec',0) gt 0 then SecDownElec_pos =p

    if strpos(fname,'SecUpPosi',0) gt 0 then SecUpPosi_pos =p
    if strpos(fname,'SecDownPosi',0) gt 0 then SecDownPosi_pos =p

    if strpos(fname,'SecUpProt',0) gt 0 then SecUpProt_pos =p
    if strpos(fname,'SecDownProt',0) gt 0 then SecDownProt_pos =p




    print, fname
    ReadCol,fname, Temp_Hist, Temp_Hist_Err, format='D,D'

    tempHistArr[p,*] = Temp_Hist[*]
    TempHistErrArr[p,*] = Temp_Hist_Err[*]



    for i = 0, 999 Do begin
      ;Add the components
      MainHist1[i] = MainHist1[i]+Temp_Hist[i]
      MainHist1_Err[i] = MainHist1_Err[i]+Temp_Hist_Err[i]*Temp_Hist_Err[i]
    endfor
  endfor
  MainHist1_Err = Sqrt(MainHist1_Err)





  MainHist = DblArr(100)
  MainHist_Err = DblArr(100)

  ;  tempHistArr[p,*] = Temp_Hist[*]
  ;  TempHistErrArr[p,*] = Temp_Hist_Err[*]

  ;
  ;==  Rebinning
  ;

  Temp_HistArr = DblArr(p,100)
  Temp_HistErrArr = DblArr(p,100)

  for p = 0, nfiles-1 do begin
    Cntr = 0L
    TempHist1 = TempHistArr[p,*]
    TempHist1_Err = TempHistErrArr[p,*]
    for i = 0, nbins-1 do begin
      TempH1 = 0.0D
      TempH1_Err = 0.0D
      for j = 0, binsize-1 do begin
        TempH1   = TempH1   + TempHist1[cntr]
        TempH1_Err = TempH1_Err +TempHist1_Err[cntr]*TempHist1_Err[cntr]
        cntr++
      endfor ;j

      Temp_HistArr[p,i] = TempH1
      Temp_HistErrArr[p,i] = Sqrt(TempH1_Err)
    EndFor ;i
  endfor;p

  Temp_HistArr = Temp_HistArr/binsize
  Temp_HistErrArr = Temp_HistErrArr/binsize


  cntr=0L
  for i = 0, nbins-1 do begin
    TempH = 0.0D
    TempH_Err = 0.0D
    for j = 0, binsize-1 do begin

      TempH   = TempH   + MainHist1[cntr]
      TempH_Err = TempH_Err +MainHist1_Err[cntr]*MainHist1_Err[cntr]
      cntr++
    endfor ;j

    MainHist[i] = TempH
    MainHist_Err[i] = Sqrt(TempH_Err)

  endfor ; i

  MainHist = MainHist/binsize
  MainHist_Err = MainHist_Err/binsize

  Hist1 = Temp_HistArr[gamma_pos,*]
  Hist1_Err = Temp_HistErrArr[gamma_pos,*]

  Hist2 = Temp_HistArr[SecUpElec_Pos, *]
  Hist2_Err = Temp_HistErrArr[SecUpElec_pos, *]


  Hist3 = Temp_HistArr[SecDownElec_Pos, *]
  Hist3_Err = Temp_HistErrArr[SecDownElec_pos, *]

  Hist4 = Temp_HistArr[SecUpPosi_Pos,*]
  Hist4_Err = temp_HistErrArr[SecUpPosi_Pos,*]

  Hist5 = Temp_HistArr[SecDownPosi_Pos,*]
  Hist5_Err = temp_HistErrArr[SecDownPosi_Pos,*]

  Hist6 = Temp_HistArr[SecUpProt_Pos,*]
  Hist6_Err = temp_HistErrArr[SecUpProt_Pos,*]

  Hist7 = Temp_HistArr[SecDownProt_Pos,*]
  Hist7_Err = temp_HistErrArr[SecDownProt_Pos,*]

  Hist8 = Temp_HistArr[PriPosi_Pos,*]
  Hist8_Err = temp_HistErrArr[PriPosi_Pos,*]


  Hist9 = Temp_HistArr[PriElec_Pos, *]
  Hist9_Err = Temp_HistErrArr[PriElec_pos, *]


  Hist10 = Temp_HistArr[PriProt_Pos, *]
  Hist10_Err = Temp_HistErrArr[PriProt_pos, *]

 ; if Neutron_Pos NE -1 Then Begin
    Hist11 = Temp_HistArr[Neutron_Pos, *]
    Hist11_Err = Temp_HistErrArr[Neutron_Pos, *]
;  EndIF


;  Gsim_Grp_Com_Sim, Files, title=title
;  Title2 = title+'_ComMod_1.txt'

  ;Gsim_grp_smoothfit, Title2, Emin= Fix(param_array[3]), EMax = Fix(param_array[4]), title=title
;  Title3 = title+'_ComMod_1_modfit.txt'

 ; gsim_grp_compare_gamma5, flight_File, title3,param_array=Param_array, ptitle=ptitle


  ;
  ;-- Various Plots
  ;

  ;ReadCol, Title3, Smoothed_total, Smoothed_Total_Err, format='D,D'



;  Color_Array = [ 'Blue'  ,'Black', 'Crimson', 'Orange'     ,  'Orange Red',  'Gray', 'Dark Gray','Lawn Green','Spring Green','Dark Khaki', 'Navy', 'Forest Green','Brown']
;  Legend_Array = ['Flight','Total',   'Gamma', 'Atm up Elec', 'Atm Dn Elec', 'Atm Up Posi', 'Atm Dn Posi', 'Atm Up Prot', 'Atm Dn Prot','Cos Posi','Cos Elec', 'Cos Prot', 'Neutrons']

;  Color=CgPickCOlorName()
;  Print, Color
  
  Title1 = File_Title+'_'+FileText1+'_1a'
  print, title1, '*****'
  CgPs_Open, Title1, Font =1, /LandScape
  ;
  ;      CGPlot,Indgen(100)*binsize,MainHist,Color= Color_array[1],$; PSYM=10
  ;        /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[30,500], YRange=[1E-8,2],Thick=5;,$
  ;        ;err_Yhigh = MainHist_Err, Err_YLow = MainHist_Err,/Err_Clip,Err_Color='Blue'
  ;
  ;      CgoPlot, Indgen(100)*binsize, Flight1, PSYM=10 ,  Color=Color_array[0]
  ;
  ;      CGoplot, Indgen(100)*binsize, Hist1, PSYM=10, Color=Color_array[2],$
  ;        err_Yhigh = Hist1_Err, Err_YLow =Hist1_Err,/Err_Clip,Err_Color=Color_array[2]
  ;
  ;      CGoplot, Indgen(100)*binsize, Hist2, PSYM=10, Color=Color_array[3],$
  ;        err_Yhigh = Hist2_Err, Err_YLow =Hist2_Err,/Err_Clip,Err_Color=Color_array[3]
  ;
  ;      CGoplot, Indgen(100)*binsize, hist3, PSYM=10, Color=Color_array[4],$
  ;        err_Yhigh = Hist3_Err, Err_YLow =Hist3_Err,/Err_Clip,Err_Color=Color_array[4]
  ;
  ;      CGoplot, Indgen(100)*binsize, Hist4, PSYM=10, Color=Color_array[5],$
  ;        err_Yhigh = Hist4_Err, Err_YLow =Hist4_Err,/Err_Clip,Err_Color=Color_array[5]
  ;
  ;      CGoplot, Indgen(100)*binsize, Hist5, PSYM=10, Color=Color_array[6],$
  ;        err_Yhigh = Hist5_Err, Err_YLow =Hist5_Err,/Err_Clip,Err_Color=Color_array[6]
  ;
  ;      CGoplot, Indgen(100)*binsize, Hist6, PSYM=10, Color=Color_array[7],$
  ;        err_Yhigh = Hist6_Err, Err_YLow =Hist6_Err,/Err_Clip,Err_Color=Color_array[7]
  ;
  ;      CGoplot, Indgen(100)*binsize, Hist7, PSYM=10, Color=Color_array[8],$
  ;        err_Yhigh = Hist7_Err, Err_YLow =Hist7_Err,/Err_Clip,Err_Color=Color_array[8]
  ;
  ;      CGoplot, Indgen(100)*binsize, Hist8, PSYM=10, Color=Color_array[9],$
  ;        err_Yhigh = Hist8_Err, Err_YLow =Hist8_Err,/Err_Clip,Err_Color=Color_array[9]
  ;
  ;      CGoplot, Indgen(100)*binsize, Hist9, PSYM=10, Color=Color_array[10],$
  ;        err_Yhigh = Hist9_Err, Err_YLow =Hist9_Err,/Err_Clip,Err_Color=Color_array[10]
  ;
  ;      CGoplot, Indgen(100)*binsize, Hist10, PSYM=10, Color=Color_array[11],$
  ;        err_Yhigh = Hist10_Err, Err_YLow =Hist10_Err,/Err_Clip,Err_Color=Color_array[11]
  ;If Neutron_Pos NE -1 Then BEgin
  ;      CGoplot, Indgen(100)*binsize, Hist11, PSYM=10, Color=Color_array[12],$
  ;        err_Yhigh = Hist11_Err, Err_YLow =Hist11_Err,/Err_Clip,Err_Color=Color_array[12]
  ;EndIF
  ;
  ;       CgLegend, Location=[0.93,0.9], Titles=Legend_array, Length =0, $
  ;        SymColors = Color_Array[0:12], TColors=Color_Array[0:12],Psyms=[1,28,1,1,1,1,1,1,1,1,1,1,1],/box, Charsize=1.2
  ;
  ;  CgErase
  
  
      Color_Array1  = ['Black','Crimson', 'Brown'   ,  'Forest Green', 'Orange'     ,   'Navy'   , 'Dodger Blue' , ' Violet'  , 'Lime Green'   ]
      Legend_Array1 = ['Total', 'Gamma' , 'Neutrons',  'Atm Posi'    , 'Atm Elec'   , 'Cos prot' , 'Atm Prot'    , 'Cos Elec' , 'Cos Posi' ]
     
    
      Xarray = Indgen(100)*binsize
      XtickVal = [40,50,60,70,80,90,100,200,300,400,500]
    
      CGPlot,Xarray,MainHist, Color=Color_array1[0], PSYM=10,$
        /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[Xmin2,Xmax2], YRange=[1E-8,2],Title=Plot_Title,$
        Xtitle= 'Energy (keV)', YTitle=' Counts / s / keV ',$
      err_Yhigh = MainHist_Err, Err_YLow = MainHist_Err,/Err_Clip,Err_Color='Black'
        
      CGoplot, Indgen(100)*binsize, Hist1, PSYM=10, Color=Color_array1[1],$
        err_Yhigh = Hist1_Err, Err_YLow =Hist1_Err,/Err_Clip,Err_Color=Color_array1[1]
    
      CGoplot, Indgen(100)*binsize, Hist11, PSYM=10, Color=Color_array1[2],$
        err_Yhigh = Hist11_Err, Err_YLow =Hist11_Err,/Err_Clip,Err_Color=Color_array1[2]
     
      Hist45 = Hist4 + Hist5
      Hist45_Err = Sqrt(Hist4_Err*Hist4_err + Hist5_err*Hist5_Err)
      CGoplot, Indgen(100)*binsize, Hist45, PSYM=10, Color=Color_array1[3],$
        err_Yhigh = Hist45_Err, Err_YLow =Hist45_Err,/Err_Clip,Err_Color=Color_array1[3]
    
            Hist23 = Hist2+Hist3
      Hist23_Err = Sqrt(Hist2_Err*Hist2_err + Hist3_err*Hist3_Err)
      CGoplot, Indgen(100)*binsize, Hist23, PSYM=10, Color=Color_array1[4],$
        err_Yhigh = Hist23_Err, Err_YLow =Hist23_Err,/Err_Clip,Err_Color=Color_array1[4]
    
      CGoplot, Indgen(100)*binsize, Hist10, PSYM=10, Color=Color_array1[5],$
        err_Yhigh = Hist10_Err, Err_YLow =Hist10_Err,/Err_Clip,Err_Color=Color_array1[5]
      
      Hist67 = Hist6 + Hist7
      Hist67_Err = Sqrt(Hist6_Err*Hist6_err + Hist7_err*Hist7_Err)
      CGoplot, Indgen(100)*binsize, Hist67, PSYM=10, Color=Color_array1[6],$
        err_Yhigh = Hist67_Err, Err_YLow =Hist67_Err,/Err_Clip,Err_Color=Color_array1[6]
    
    
      CGoplot, Indgen(100)*binsize, Hist9, PSYM=10, Color=Color_array1[7],$
        err_Yhigh = Hist9_Err, Err_YLow =Hist9_Err,/Err_Clip,Err_Color=Color_array1[7]
    
      CGoplot, Indgen(100)*binsize, Hist8, PSYM=10, Color=Color_array1[8],$
        err_Yhigh = Hist8_Err, Err_YLow =Hist8_Err,/Err_Clip,Err_Color=Color_array1[8]
    
      ;    CGoPlot,Indgen(100)*binsize,MainHist, Color='Black', Thick=3
      CGText, !D.X_Size*0.65,!D.Y_Size*(0.08), 'Model Params '+Text1,/DEVICE, CHarSize=1.2
    
      CGText, !D.X_Size*0.92,!D.Y_Size*(0.92),'('+ CText+' Events)',/DEVICE, CHarSize=1.8
     ; CGText, !D.X_Size*0.5,!D.Y_Size*(-0.03),Flight_File,/DEVICE, CHarSize=0.75
    
      CgLegend, Location=[0.93,0.9], Titles=Legend_array1, Length =0, $
        SymColors = Color_Array1, TColors=Color_Array1,Psyms=[1,1,1,1,1,1,1,1,1],/box, Charsize=1.2

  CgErase
  
      Legend_array3 = LEgend_array1[0:4]
      Color_array3  = Color_array1[0:4]
    
      CGPlot,Xarray,MainHist, Color=Color_array3[0], PSYM=10,$
        /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[Xmin2,Xmax2], YRange=[1E-5,2],Title=Plot_Title,$
        Xtitle= 'Energy (keV)', YTitle=' Counts / s / keV ',$
        err_Yhigh = MainHist_Err, Err_YLow = MainHist_Err,/Err_Clip,Err_Color=Color_array3[0];,YTIckFormat='(10E1.0)'
       
 
      CGoplot, Indgen(100)*binsize, Hist1, PSYM=10, Color=Color_array3[1],$
        err_Yhigh = Hist1_Err, Err_YLow =Hist1_Err,/Err_Clip,Err_Color=Color_array3[1]

      CGoplot, Indgen(100)*binsize, Hist11, PSYM=10, Color=Color_array3[2],$
        err_Yhigh = Hist11_Err, Err_YLow =Hist11_Err,/Err_Clip,Err_Color=Color_array3[2]

      Hist45 = Hist4 + Hist5
      Hist45_Err = Sqrt(Hist4_Err*Hist4_err + Hist5_err*Hist5_Err)
      CGoplot, Indgen(100)*binsize, Hist45, PSYM=10, Color=Color_array3[3],$
        err_Yhigh = Hist45_Err, Err_YLow =Hist45_Err,/Err_Clip,Err_Color=Color_array3[3]

      Hist23 = Hist2+Hist3
      Hist23_Err = Sqrt(Hist2_Err*Hist2_err + Hist3_err*Hist3_Err)
      CGoplot, Indgen(100)*binsize, Hist23, PSYM=10, Color=Color_array3[4],$
        err_Yhigh = Hist23_Err, Err_YLow =Hist23_Err,/Err_Clip,Err_Color=Color_array3[4]

      CgLegend, Location=[0.93,0.9], Titles=Legend_array3, Length =0, $
        SymColors = Color_Array3, TColors=Color_Array3,Psyms=[1,1,1,1,1],/box, Charsize=1.2
      CGText, !D.X_Size*0.65,!D.Y_Size*(0.08), 'Model Params '+Text1,/DEVICE, CHarSize=1.2

      CGText, !D.X_Size*0.92,!D.Y_Size*(0.92),'('+ CText+' Events)',/DEVICE, CHarSize=1.8


  CgERase
      Legend_array2 = ['Flight','Total','Gamma','Neutrons','Atm Posi','Atm Elec']
      Color_array2  = ['Blue','Black','Pink','Tan','GRN3','Org2']
      
        CGPlot,Xarray,MainHist, Color=Color_array2[1], PSYM=10,$
        /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[Xmin2,Xmax2], YRange=[1E-5,2],Title=Plot_Title,$
        Xtitle= 'Energy (keV)', YTitle=' Counts / s / keV ',$
      err_Yhigh = MainHist_Err, Err_YLow = MainHist_Err,/Err_Clip,Err_Color='Black'
    
         
      CgoPlot, Indgen(100)*binsize, Flight1, PSYM=10,Color= Color_array2[0],$
        err_Yhigh = Flight1_Err, Err_YLow =Flight1_Err,/Err_Clip,Err_Color=Color_Array2[0]
    
      CGoplot, Indgen(100)*binsize, Hist1, PSYM=10, Color=Color_array2[2],$
        err_Yhigh = Hist1_Err, Err_YLow =Hist1_Err,/Err_Clip,Err_Color=Color_array2[2]

      CGoplot, Indgen(100)*binsize, Hist11, PSYM=10, Color=Color_array2[3],$
        err_Yhigh = Hist11_Err, Err_YLow =Hist11_Err,/Err_Clip,Err_Color=Color_array2[3]

      Hist45 = Hist4 + Hist5
      Hist45_Err = Sqrt(Hist4_Err*Hist4_err + Hist5_err*Hist5_Err)
      CGoplot, Indgen(100)*binsize, Hist45, PSYM=10, Color=Color_array2[4],$
        err_Yhigh = Hist45_Err, Err_YLow =Hist45_Err,/Err_Clip,Err_Color=Color_array2[4]

      Hist23 = Hist2+Hist3
      Hist23_Err = Sqrt(Hist2_Err*Hist2_err + Hist3_err*Hist3_Err)
      CGoplot, Indgen(100)*binsize, Hist23, PSYM=10, Color=Color_array2[5],$
        err_Yhigh = Hist23_Err, Err_YLow =Hist23_Err,/Err_Clip,Err_Color=Color_array2[5]

      CGText, !D.X_Size*0.65,!D.Y_Size*(0.08), 'Model Params '+Text1,/DEVICE, CHarSize=1.2

      CGText, !D.X_Size*0.92,!D.Y_Size*(0.92),'('+ CText+' Events)',/DEVICE, CHarSize=1.8

   
      CgLegend, Location=[0.93,0.9], Titles=Legend_array2, Length =0, $
        SymColors = Color_Array2, TColors=Color_Array2,Psyms=[1,1,1,1,1,1],/box, Charsize=1.2
  CGErase
      Legend_array2 = ['Flight','Total','Gamma','Neutrons','Atm Posi','Atm Elec']
  Color_array2  = ['Blue','Black','Pink','Tan','GRN3','Org2']

  CGPlot,Xarray,MainHist, Color=Color_array2[1], PSYM=10,$
    /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[Xmin2,Xmax2], YRange=[1E-8,2],Title=Plot_Title,$
    Xtitle= 'Energy (keV)', YTitle=' Counts / s / keV ',$
    err_Yhigh = MainHist_Err, Err_YLow = MainHist_Err,/Err_Clip,Err_Color='Black'


  CgoPlot, Indgen(100)*binsize, Flight1, PSYM=10,Color= Color_array2[0],$
    err_Yhigh = Flight1_Err, Err_YLow =Flight1_Err,/Err_Clip,Err_Color=Color_Array2[0]

  CGoplot, Indgen(100)*binsize, Hist1, PSYM=10, Color=Color_array2[2],$
    err_Yhigh = Hist1_Err, Err_YLow =Hist1_Err,/Err_Clip,Err_Color=Color_array2[2]

  CGoplot, Indgen(100)*binsize, Hist11, PSYM=10, Color=Color_array2[3],$
    err_Yhigh = Hist11_Err, Err_YLow =Hist11_Err,/Err_Clip,Err_Color=Color_array2[3]

  Hist45 = Hist4 + Hist5
  Hist45_Err = Sqrt(Hist4_Err*Hist4_err + Hist5_err*Hist5_Err)
  CGoplot, Indgen(100)*binsize, Hist45, PSYM=10, Color=Color_array2[4],$
    err_Yhigh = Hist45_Err, Err_YLow =Hist45_Err,/Err_Clip,Err_Color=Color_array2[4]

  Hist23 = Hist2+Hist3
  Hist23_Err = Sqrt(Hist2_Err*Hist2_err + Hist3_err*Hist3_Err)
  CGoplot, Indgen(100)*binsize, Hist23, PSYM=10, Color=Color_array2[5],$
    err_Yhigh = Hist23_Err, Err_YLow =Hist23_Err,/Err_Clip,Err_Color=Color_array2[5]

  CGText, !D.X_Size*0.65,!D.Y_Size*(0.08), 'Model Params '+Text1,/DEVICE, CHarSize=1.2

  CGText, !D.X_Size*0.92,!D.Y_Size*(0.92),'('+ CText+' Events)',/DEVICE, CHarSize=1.8


  CgLegend, Location=[0.93,0.9], Titles=Legend_array2, Length =0, $
    SymColors = Color_Array2, TColors=Color_Array2,Psyms=[1,1,1,1,1,1],/box, Charsize=1.2
    
  CgErase
  Legend_array4 = ['Flight','Total']
  Color_array4  = ['Blue','Black']

  CGPlot,Xarray,MainHist, Color=Color_array4[1], PSYM=10,$
    /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[Xmin2,Xmax2], YRange=[1E-5,2],Title=Plot_Title,$
    Xtitle= 'Energy (keV)', YTitle=' Counts / s / keV ',$
    err_Yhigh = MainHist_Err, Err_YLow = MainHist_Err,/Err_Clip,Err_Color='Black'


  CgoPlot, Indgen(100)*binsize, Flight1, PSYM=10,Color= Color_array4[0],$
    err_Yhigh = Flight1_Err, Err_YLow =Flight1_Err,/Err_Clip,Err_Color=Color_Array4[0]

 
  CGText, !D.X_Size*0.65,!D.Y_Size*(0.08), 'Model Params '+Text1,/DEVICE, CHarSize=1.2

  CGText, !D.X_Size*0.92,!D.Y_Size*(0.92),'('+ CText+' Events)',/DEVICE, CHarSize=1.8


  CgLegend, Location=[0.93,0.9], Titles=Legend_array4, Length =0, $
    SymColors = Color_Array4, TColors=Color_Array4,Psyms=[1,1],/box, Charsize=1.2
  CgPS_Close
  CGPS2PDF, Title1+'.ps', Title1+'.pdf', /delete_ps

  close,/all


Openw, Lun1, FileText, /Get_lun
  For i = 0, N_Elements(MainHist)-1 Do begin
        Printf, lun1,Xarray[i], MainHist[i], MainHist_Err[i]
  Endfor
Free_lun, Lun1
End