Pro gsim_grp_compare_gamma4, file2,Type=Type, Com=Com, param_array=Param_array, folder=folder
  ; 
  ; Modified from compare gamma 3 to plot a single spectrum. 
  ; Gamma 3 does for multiple / automation
  ; This shouldonly compare the flight vs One main model fit at a time.
  ; and create the text file.

  file1 ='/Users/sam/Dropbox/Cur_Work/Flight_Bin_10/10_40_l2v7_inv3_rebin.txt'
  True = 1
  False = 0
  Plot_Title = 'PSD100 Side0 Cor0'
  YMax = 1
  YMin = 1E-3
  
  If Keyword_Set(param_array) eq 0 then param_array=['100','0','0','70','300']

  Type_Flag = False
  If Keyword_SEt(Type) NE 0 Then Type_Flag = true
  If Keyword_Set(Folder) EQ 0 Then Folder=''
  if Keyword_set(Com) Eq 0 THen Com=1
  If Type_Flag Eq True then  par_file = folder+'Type'+Strn(Type)+'_parameter_file.txt' Else par_file = folder+'TypeAll_parameter_file.txt'

  temp_a=file_search(par_file,count=count)
  print, par_file
  if count EQ 0 Then begin
    header = 'Com PSD Side Cor Chi DoF RChi Min Max'
    openw, lun1,par_file, /Get_Lun
    printf, lun1, header
    free_lun, lun1

  endif




  ; File 2 is the Combined and smoothed file.
  print, file2
  print, param_array
  print, com


  bin =10
  True =1
  False = 0


  Sel_energy_min = Float(param_array[3])
  sel_energy_max = Float(param_array[4])
  Sel_min = fix(sel_energy_min/bin)
  Sel_max = fix(sel_energy_max/bin)

  Print, Sel_Min, Sel_MAx

  ; Read in the flight --
  ReadCol, file1, Flight1, Flight1_err, format='F,F'

  ;
  ;-- Read in the sims --
  ;
  simfile1 = file2[0]
  print, simfile1
  nfiles_sim = n_elements(file2)

  ReadCol, simfile1, gamma1,  format='F'


  help, gamma1, flight1


  Total_gamma = gamma1
  St_Estimated = Total_Gamma[sel_min:sel_max]
  St_Measured  = Flight1[Sel_Min:Sel_MAx]
  St_Chiarr1_ele = N_Elements(Flight1_Err[where(Flight1_Err[sel_min:sel_max] ne 0.0)])
  St_Var1 = (Flight1_Err[sel_min:sel_max])^2

  ; Diff
  St_Diff_0 = (St_estimated - St_measured)^2
  ;PRint, St_Diff_0, St_Var1
  ; Dividing by error squared
  St_Chiarr_0 = DblArr(n_elements(St_Diff_0))
  For i = 0,n_elements(St_Diff_0)-1 do if (St_Var1[i] ne 0.0) then  St_Chiarr_0[i] = St_Diff_0[i]/(St_Var1[i]) else St_Chiarr_0[i] =0.0

  ;Sum = Chisquare
  Chi0 = Total(st_chiarr_0)
  ;print, Chi0
  DOF = N_elements(st_chiarr_0) -2
  Red_Chi0 = Chi0/DOF

  ;print, St_Estimated, St_MEasured
  print, DOF, Red_Chi0
  Title1 = 'Compare_Plot'
  CgPs_Open, Title1, Font =1, /LandScape

  Cgplot,  (Indgen(n_elements(Flight1))*Bin),Flight1, Yrange=[YMin,Ymax], psym=10,Title = Plot_Title,$
    /xlog,/ylog, Xstyle=1, Ystyle=1, Xrange=[50,300], Xtitle='Energy (keV)', Ytitle ='Counts (c/s/keV)',$
    err_Yhigh = Flight1_Err, Err_YLow =Flight1_Err,/Err_Clip
    
  Cgoplot,(Indgen(n_elements(St_Estimated))*Bin+Sel_energy_min), St_Estimated, Color='Red' , PSYM=10
  
  CgErase
  
  Cgplot,  (Indgen(n_elements(Flight1))*Bin),Flight1, Yrange=[1E-8,2], psym=10,Title = Plot_Title,$
    /xlog,/ylog, Xstyle=1, Ystyle=1, Xrange=[50,300], Xtitle='Energy (keV)', Ytitle ='Counts (c/s/keV)',$
    err_Yhigh = Flight1_Err, Err_YLow =Flight1_Err,/Err_Clip

  Cgoplot,(Indgen(n_elements(St_Estimated))*Bin+Sel_energy_min), St_Estimated, Color='Red' , PSYM=10
  
  CgPS_Close
  CGPS2PDF, Title1+'.ps', Title1+'.pdf', /delete_ps
Stop
  file_text = Strn(Com) +'  '+ Param_Array[0] + '  '  +  Param_Array[1] +'  '+Param_Array[2]+'  '+ Strn(Chi0)+'  '+ Strn(DOF)+ '  '+Strn(Red_Chi0)+ '  '+Param_Array[3]+ '  '+Param_Array[4]
  print, file_text
  openw, lun1, par_file, /Get_lun, /append
  printf, lun1,file_Text
  free_lun, lun1
End