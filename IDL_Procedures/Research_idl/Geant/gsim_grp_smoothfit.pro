Pro gsim_grp_smoothfit, Infile, Title=Title, Emin=Emin, Emax=Emax, bin=bin, foldername= foldername
  ;
  ; This reads in the Summed (rebinned file) with errors
  ; We do not need to rebin it here.
  ; Now we are translating the errors.

  True =1
  False=0


 If keyword_set(bin) ne 0 then binsize=bin else binsize=10
 If keyword_set(title) eq 0 then title=''

 folder_flag = false
 if keyword_set(foldername) ne 0 then folder_flag = True ; this is 0 but we have set the ct to be 15%
 
  OutPos = StrPOs(Infile,'_ComMod',0)
  OutFile = INfile
  print, infile
  StrPut, OutFile, '_mod',OutPos+9
  Outfile = Outfile+'fit.txt'
  print, outfile
  Red_Chi = 0.0D
  ;
  ;=== Get single files ====
  ;
;  IF Keyword_Set(title) Eq 0 Then Title='Test'
  IF Keyword_Set(Emin) Eq 0 Then Emin=70
  IF Keyword_Set(Emax) Eq 0 Then Emax=300
  
  Smoothed_Fit = DblArr(100)

      ReadCol,Infile, Temp_Hist, Temp_Hist_Err, format='D,D'
  xval2 = indgen(n_elements(Temp_Hist))*binSize
; Need to figure out the array location for the energy
      EminLoc = Fix(Emin/binsize) 
      EmaxLoc = Fix(EMax/binsize)
      Hist = Temp_Hist[EminLoc:EmaxLoc]
      Hist_Err = Temp_Hist_Err[EminLoc:EmaxLoc]


      Temp_smooth_var = DblArr(100)
      Temp_Smooth_Err = DblArr(100)
      
      Red_Chi = 0.0D
      Smoothing_Deg =1
      
      Check_Flag = False
      Check_Counter = 0L
      best_Deg = 3
      Temp_RedChi = 0.0D
      ;While Smoothing_Deg LT 10.0 Do begin
       While Check_Flag EQ False DO Begin

          Smoothing_Deg=Smoothing_Deg+2
          ; So we have empty temp_smooth, Hist and hist_err
          Temp_Smooth = Smooth(Hist,Smoothing_Deg,/Edge_truncate)
  
          ; The idea is that the model (Smoothened) is the one that has a reduced Chi-Square 1.
          Dof = N_elements(Hist)-2
          Diff = (Temp_Smooth- Hist)^2
  
          Temp_Chiarr = DblArr(n_elements(Hist_Err))
  
          For i = 0,n_elements(Temp_Chiarr)-1 do if (Hist_Err[i] ne 0.0) then Temp_Chiarr[i] = Diff[i]/(Hist_Err[i]*Hist_err[i]) else Temp_Chiarr[i] =0.0
  
          Red_Chi = Total(Temp_ChiArr)/DOF
          Print, Red_Chi, '**'
          If Red_Chi GT 1 Then Begin
              If Smoothing_Deg NE 3 Then Begin
                Print, Check_Counter
                   If Check_Counter EQ 0 Then BEst_Deg=Smoothing_Deg ; For the first above 1 fit.

                   If Red_Chi gt Temp_RedChi then begin
                        Check_Counter++
                        print, 'a'
                   Endif Else Begin
                    Temp_Redchi = Red_Chi
                    Best_Deg = Smoothing_Deg
                        print, 'b'
                   Endelse

              Endif Else Begin
                  best_Deg =3
                  Temp_RedChi = Red_Chi
                  Check_Counter++
                    print,'c'
              Endelse
              
          endIf Else Begin
              If Red_Chi gt Temp_RedChi then begin
                    Temp_RedChi = Red_Chi
                    Best_Deg = Smoothing_Deg

              Endif
              print,'d'
          endelse
;          Cgplot, (Indgen(n_elements(Hist))*Binsize+Emin), Hist, err_Yhigh =Hist_Err, err_Ylow = Hist_Err, /Err_Clip,Err_Color='Green'
 ;         Cgoplot,(Indgen(n_elements(Hist))*Binsize+Emin), Temp_Smooth, Color='Red'
          print, Red_Chi, DOF, Smoothing_Deg, Best_Deg, Temp_REdChi, Check_Counter
          if check_counter Gt 2 then check_flag = true
          if Smoothing_Deg Gt 17 then check_flag = true
       Endwhile
      
      ;
      ;** Smooth it with the best smoothing deg
      ;
      Smoothing_Deg = Best_Deg
       Temp_Smooth = Smooth(Hist,Smoothing_Deg,/Edge_truncate)
       Diff = (Temp_Smooth- Hist)^2
       Temp_Chiarr = DblArr(n_elements(Hist_Err))
       For i = 0,n_elements(Temp_Chiarr)-1 do if (Hist_Err[i] ne 0.0) then Temp_Chiarr[i] = Diff[i]/(Hist_Err[i]*Hist_err[i]) else Temp_Chiarr[i] =0.0
       Red_Chi = Total(Temp_ChiArr)/DOF
       
       print, Red_Chi, DOF, Smoothing_Deg, Best_Deg, Check_Counter

      Temp_Smooth_Var[EminLoc:EmaxLoc] = Temp_Smooth
      Smoothed_fit = Temp_Smooth_Var
      
      ; Adding errors in quadrature. 
      ; Depends on smoothing deg. 
      ; Edges are truncated.
      New_Hist_Err = DblArr(N_Elements(Hist_Err))
      
      For i = 0, N_Elements(Hist)-1 Do BEgin
        Temp_Hist_Err = 0.0D
        For j = 0, Best_Deg-1 Do begin
          Cur_Pos = i-(Best_Deg-1)/2+j
          ; Fixing for truncate keyword
          If Cur_Pos Lt 0 then Cur_Pos = 0
            If Cur_Pos Gt N_Elements(Hist)-1 Then Cur_Pos =  N_Elements(Hist)-1
                Temp_Hist_Err = Temp_Hist_Err + (Hist_Err[Cur_Pos]*Hist_Err[Cur_Pos])
        Endfor;j
        Temp_hist_Err = Sqrt(Temp_Hist_Err)/Best_Deg
        New_Hist_Err[i] = Temp_Hist_Err
     Endfor;i
     Temp_Smooth_Err[EminLoc:EmaxLoc] = New_Hist_Err

      
    CgPs_Open,Title+'SmoothFit', Font =1, /LandScape
          
      Cgplot, (Indgen(n_elements(Hist))*Binsize+Emin), Hist, err_Yhigh =Hist_Err, err_Ylow = Hist_Err, /Err_Clip,Err_Color='Green', title='Smoothing the total'
      Cgoplot,(Indgen(n_elements(Hist))*Binsize+Emin), Temp_Smooth, Color='Red'
      CGText, !D.X_Size*0.75,!D.Y_Size*(0.01), 'Smooth Deg:'+Strn(Best_Deg)+ '  Chi ='+Strn(Red_Chi),/DEVICE, CHarSize=1.2

    CGPS_Close
    CGPS2PDF, title+'SmoothFit.ps', title+'SmoothFit.pdf', /delete_ps
    
    Openw, Lun1, Outfile, /Get_lun
      for i=0,99 do begin
        printf, lun1, Strn(smoothed_fit[i]), '   ', Strn(Temp_Smooth_Err[i])
      endfor
    Free_lun, Lun1
 

End

