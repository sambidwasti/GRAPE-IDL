Pro gsim_grp_compare_gamma5, file1,file2,Type=Type, Com=Com, param_array=Param_array, folder=folder, ptitle = ptitle, ComChi =ComChi
  
  ;
  ; Modifiied from copare gamma 3 to deal with 1 parameter at a time.
  ; This shouldonly compare the flight vs One main model fit at a time.
  ; and create the text file.
  ; May 10, 2018 The sim model file now has errors.
  

  True = 1
  False = 0
  
  If keyword_set(ComChi) ne 0 then Chiflag = True else ChiFlag = False
  Print
  Print, '*** CHI FLAG : '+STRN(ChiFlag)+'***'
  Print
  ;
 ; Param_Array = [Strn(PSD), Strn(Side), Strn(Cor), Strn(Min_Ener), Strn(Max_Ener)]

  If Keyword_Set(param_array) eq 0 then param_array=['100','0','0','70','300']
  If Keyword_Set(ptitle) eq 0 then ptitle =' PC Flight vs model'
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
  ReadCol, file1, Flight1, Flight1_err, format='D,D'

  ;
  ;-- Read in the sims --
  ;
  simfile1 = file2[0]
  print, simfile1
  nfiles_sim = n_elements(file2)

  ReadCol, simfile1, gamma1, gamma1_Err, format='D,D'

  ;
  ; -- Just add the errors in quadrature.
  ;
  If ChiFlag Eq True Then Begin
  Com_Err = Sqrt(Flight1_Err*Flight1_Err + Gamma1_Err*Gamma1_Err)
  EndIF Else Com_Err = Flight1_Err
  help, gamma1, flight1


  Total_gamma = gamma1
  St_Estimated = Total_Gamma[sel_min:sel_max]
  St_Measured  = Flight1[Sel_Min:Sel_MAx]
  St_Var1 = (Com_Err[sel_min:sel_max])^2

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
  
  Model_param = '('+param_array[0]+':'+Param_Array[1]+':'+param_Array[2]+')'

  CgPs_Open, 'ModelFit', Font =1, /LandScape
;  CGPlot,(Indgen(n_elements(St_Measured))*Bin+Sel_energy_min),St_Measured, Color='Black', PSYM=10,$
    CGPlot,Indgen(N_Elements(flight1))*10,flight1, Color='Blue', PSYM=10,$
   /Xlog, /Ylog, XStyle=1, YStyle=1 , XRange=[30,500], YRange=[1E-8,2],Title=PTitle,$
    Xtitle= 'Energy (keV)', YTitle=' Counts / s / keV ',$
     err_Yhigh = Flight1_Err, Err_YLow =Flight1_Err,/Err_Clip,Err_Color='Blue'
   
   ;CgOplot, Indgen(N_Elements(Gamma1)) *10,Gamma1, color='grey'
     
 Cgoplot,(Indgen(n_elements(St_Estimated))*Bin+Sel_energy_min), St_Estimated, Color='Red' , Thick=5,$
   err_Yhigh = gamma1_Err, Err_YLow =gamma1_Err,/Err_Clip,Err_Color='Red'

 
  CGText, !D.X_Size*0.75,!D.Y_Size*(0.01), 'Model Params '+Model_param,/DEVICE, CHarSize=1.2
  CGText, !D.X_Size*0.85,!D.Y_Size*(0.92), 'Red Chi '+Strn(Red_Chi0),/DEVICE, CHarSize=1.5
  CGText, !D.X_Size*0.75,!D.Y_Size*(0.06), 'DOF:'+Strn(DOF) + '  Chisqr:'+Strn(Chi0) ,/DEVICE, CHarSize=1.5


CgPS_Close
CGPS2PDF, 'ModelFit.ps', 'ModelFit.pdf', /delete_ps

  file_text = Strn(Com) +'  '+ Param_Array[0] + '  '  +  Param_Array[1] +'  '+Param_Array[2]+'  '+ Strn(Chi0)+'  '+ Strn(DOF)+ '  '+Strn(Red_Chi0)+ '  '+Param_Array[3]+ '  '+Param_Array[4]
  print, file_text
  openw, lun1, par_file, /Get_lun, /append
  printf, lun1,file_Text
  free_lun, lun1
End