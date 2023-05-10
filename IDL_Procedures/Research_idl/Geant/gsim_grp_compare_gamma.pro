Pro gsim_grp_compare_gamma, fsearch_str, infile, title=title

  ; Now it is trying to plot couple of spectrum against flight for comparisions
  ; 
  ; This is being updated from previous where it was fitting the total with flight without smoothing.
  ; Feb 19, 2018
  ; Upgrading the program to what is relevant atm 
  ; The files are already binned for 10
  ;
  ;April 22, 2018
  ;Adding in an option for 2 input parameter, the second parameter should be the file to compare with. 
  ;
  
  
  True =1
  False = 0
    If keyword_set(title) ne 1 then title=''

    simfiles = FILE_SEARCH(fsearch_str)          ; get list of EVT input files
    if keyword_set(nfiles) ne 1 then nfiles = n_elements(simfiles)
    
     

  ;
  ;==== PLOT Variables
  ;
  temp11 =title+'';'(PC All)'
 ;  Read, temp11, PROMPT=' Enter Title for the plot : ' 
  PTitle = temp11
  Xtitle = ' Energy (keV) '
  Ytitle = ' C/s/keV '

  ;Range
  Xmin  = 40
  Xmax  = 400
 ;       ymin = 1E-7
  Ymin  = 1E-8
  Ymax  = 2
  ;--- Current Directory
  CD, Cur = Cur

  if keyword_set(bin) ne 1 then bin = 10

;
; Selecting flight files
;
  infile_flag = False
  if n_params() eq 2 then infile_Flag = True

  If Infile_flag Eq True then begin
    Print
    Print, '***********************'
    Print, ' THIS HAS TO BE NON-REBINNED Flight FILE'
    Print, ' Comparing FLight File = '+infile
    Print, ' *********************** '
    Print
    File1 = Infile
  EndIF Else begin

    file1 ='/Users/Sam/Dropbox/Cur_Work/Flightfile/10_40_PC_l2v7_Inv3.txt' ; non -rebin flight file

  Endelse

  
  
  ; Read in the flight --
  ReadCol, file1, Flight1, Flight1_err, format='F,F'


  
  ;
  ;-- Read in the sims --
  ;

  Legend_Array = ['Flight PC']
  Color_Array = ['Black','Red','Orange','Purple','Green','Blue']
  
  Legend_Array1=['Red-Chisqr']
  Legend_Array2=['Chisqr']
  ;,'Green','Blue','Red','Orange']
  
;  temp_Str_Array =['0Per', '5per', '10Per', '15Per']
  ;Legend_Array =[LEgend_ARray,temp_Str_Array]

  
  For p =0,nfiles-1 do begin
  print, p,' ', simfiles[p]
  
      Temp=''
      Temp_Col=''
      Read, temp, PROMPT=' Enter Legend for this File : ' 
     ; Read, temp_col, PROMPT=' Enter Color for this Data : '
     ; Color_Array = [Color_Array,temp_col]
      Legend_ARray = [LEgend_ARray,temp]
      
      ReadCol, simfiles[p], Temp1, Temp1_err, format='D,D'
      If p eq 0 Then Begin
          Gamma1 = Temp1
          Gamma1_Err = Temp1_Err
          Endif Else If  p eq 1 Then Begin
              Gamma2 = Temp1
              Gamma2_Err = Temp1_Err
              Endif Else If  p eq 2 Then Begin
                  Gamma3 = Temp1
                  Gamma3_Err = Temp1_Err
                  Endif Else If  p eq 3 Then Begin
                          Gamma4 = Temp1
                          Gamma4_Err = Temp1_Err
                          EndIF Else If  p eq 4 Then Begin
                              Gamma5 = Temp1
                              Gamma5_Err = Temp1_Err
                          EndIF
          
  Endfor

  ;
  ; Rebinning here:
  nbins = (1000/bin) + 1
  xval2 = indgen(nbins)*bin

  ;
  ;-- FLight
  ;
  Flight2 = DblArr(nbins)
  Flight2_Err = DblArr(nbins)

  ;
  ;-- Gammas
  ;
  Gamma12 = DblArr(nbins)
  Gamma12_Err = DblArr(nbins)

  Gamma22 = DblArr(nbins)
  Gamma22_Err = DblArr(nbins)

  Gamma32 = DblArr(nbins)
  Gamma32_Err = DblArr(nbins)

  Gamma42 = DblArr(nbins)
  Gamma42_Err = DblArr(nbins)

  Gamma52 = DblArr(nbins)
  Gamma52_Err = DblArr(nbins)

  TotErr = DblArr(nbins)

  Cntr=0L

  for i = 0, nbins-2 do begin
    tempFli   = 0.0
    tempGam1   = 0.0
    tempGam2   = 0.0
    tempGam3   = 0.0
    tempGam4   = 0.0
    tempGam5   = 0.0


    tempFli_err   = 0.0
    tempGam1_err   = 0.0D
    tempGam2_err   = 0.0
    tempGam3_err   = 0.0
    tempGam4_err   = 0.0
    tempGam5_err   = 0.0

    for j = 0, bin-1 do begin

      tempFli   = tempfli   + Flight1[cntr]

      tempGam1   = tempGam1   + Gamma1[cntr]
      if nfiles ge 2 then tempGam2   = tempGam2   + Gamma2[cntr]
      if nfiles ge 3 then tempGam3   = tempGam3   + Gamma3[cntr]
      if nfiles ge 4 then tempGam4   = tempGam4   + Gamma4[cntr]
      if nfiles ge 5 then tempGam5   = tempGam5   + Gamma5[cntr]

      ;
      ;-- Errors --
      ;

      tempFli_err   = tempFli_err   + Flight1_Err[cntr]*Flight1_Err[cntr]

      tempGam1_err   = tempGam1_err   + Gamma1_Err[cntr]*Gamma1_Err[cntr]
      if nfiles ge 2 then tempGam2_err   = tempGam2_err   + Gamma2_Err[cntr]*Gamma2_Err[cntr]
      if nfiles ge 3 then tempGam3_err   = tempGam3_err   + Gamma3_Err[cntr]*Gamma3_Err[cntr]
      if nfiles ge 4 then tempGam4_err   = tempGam4_err   + Gamma4_Err[cntr]*Gamma4_Err[cntr]
      if nfiles ge 5 then tempGam5_err   = tempGam5_err   + Gamma5_Err[cntr]*Gamma5_Err[cntr]

      cntr++
    endfor

    Flight2[i] = tempFli

    Gamma12[i]  = tempGam1
    if nfiles ge 2 then Gamma22[i]  = tempGam2
    if nfiles ge 3 then Gamma32[i]  = tempGam3
    if nfiles ge 4 then Gamma42[i]  = tempGam4
    if nfiles ge 5 then Gamma52[i]  = tempGam5

    Flight2_Err[i] = Sqrt(tempFli_Err)

    Gamma12_Err[i]  = Sqrt(tempGam1_Err)
    
    if nfiles ge 2 then Gamma22_Err[i]  = Sqrt(tempGam2_Err)
    if nfiles ge 3 then Gamma32_Err[i]  = Sqrt(tempGam3_Err)
    if nfiles ge 4 then Gamma42_Err[i]  = Sqrt(tempGam4_Err)
    if nfiles ge 5 then Gamma52_Err[i]  = Sqrt(tempGam5_Err)

  
  endfor


  ;
  ;=== Per bin scaling ===
  ;
  Flight2 = Flight2/bin
  Flight2_Err = Flight2_err/bin


  Gamma12_Err  = Gamma12_err/bin
  Gamma12  = Gamma12/bin
  
  If nfiles ge 2 then begin
      Gamma22_Err  = Gamma22_err/bin
    Gamma22  = Gamma22/bin
  Endif

  If nfiles ge 3 then begin
    Gamma32_Err  = Gamma32_err/bin
    Gamma32  = Gamma32/bin
  Endif
  
  If nfiles ge 4 then begin
    Gamma42_Err  = Gamma42_err/bin
    Gamma42  = Gamma42/bin
  Endif
  
  If nfiles ge 5 then begin
    Gamma52_Err  = Gamma52_err/bin
    Gamma52  = Gamma52/bin
  Endif
  
 
 ; print, total(st_chiarr_1), total(st_chiarr_1)/(St_Chiarr1_ele), total(st_chiarr_2), total(st_chiarr_2)/(St_Chiarr2_ele)
  ;******************

  ; More Plot Param
  Xerr = intarr(n_elements(xval2))
  Xerr[*] = bin/2
  er_wid = 0.001
 Print,'Checkpoint'
;===
  CgPs_Open, Title+'_Com.ps', Font =1, /LandScape
cgLoadCT, 13
!P.Font=1

xticks = loglevels([xmin,xmax])
nticks = n_elements(xticks)

;
; Page 1: Flight vs gamma
;
PSYM_Arr = IntArr(nfiles+1)
PSYM_Arr[*]=1


Cgplot, Xval2,Flight2, PSYM=3, XRANGE=[Xmin,Xmax],Xstyle=1, /Xlog,/Ylog,  YRAnge=[Ymin,Ymax], YStyle=1,$
  title=ptitle, xtitle=xtitle, ytitle=ytitle,linestyle=1,$
  err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color='black',Err_Width=er_wid,$
  err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1
Cgoplot, Xval2,Flight2,Color='black'


        
        CgLegend, SymColors=Color_Array[0:nfiles],PSyms=PSYM_Arr[0:nfiles], Location=[0.93,0.9],$
          Titles=Legend_Array,length=0, Tcolors=Color_Array[0:nfiles], /box, charsize=1
        
 CGoplot, Xval2,Gamma12, PSYM=3 , Color=Color_Array[1],    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
   err_Ylow = Gamma12_Err ,err_Yhigh = Gamma12_Err, Err_Color=Color_array[1],/Err_Clip 
  
if nfiles ge 2 then begin
CGoplot, Xval2,Gamma22, PSYM=3, Color=Color_Array[2],    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
  err_Yhigh = Gamma22_Err ,err_Ylow = Gamma22_Err , /Err_Clip, Err_Color=Color_array[2]
endif

if nfiles ge 3 then begin
  CGoplot, Xval2,Gamma32, PSYM=3, Color=Color_Array[3],    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Yhigh = Gamma32_Err, err_Ylow = Gamma32_Err , /Err_Clip, Err_Color=Color_array[3]
endif
    
 if nfiles ge 4 then begin
  CGoplot, Xval2,Gamma42, PSYM=3, Color=Color_array[4],    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Yhigh = Gamma42_Err, err_Ylow = Gamma42_Err , /Err_Clip, Err_Color=Color_array[4]
endif

if nfiles ge 5 then begin
  CGoplot, Xval2,Gamma52, PSYM=3, Color=Color_array[5],    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
    err_Yhigh = Gamma52_Err, err_Ylow = Gamma52_Err , /Err_Clip, Err_Color=Color_array[5]
endif

  CGoplot, Xval2,Gamma12+Gamma22, PSYM=9, Color=Color_array[5];,    err_XHigh = Xerr, Err_Xlow=Xerr,Err_Width=er_wid,$
;  ;  err_Yhigh = Gamma52_Err, err_Ylow = Gamma52_Err , /Err_Clip, Err_Color=Color_array[5]

CgPs_Close

;-- Create the PDF File
Temp_Str = Cur+'/'+Title+'_Com.ps'
CGPS2PDF, Temp_Str,delete_ps=1


print,'end'
Stop

End