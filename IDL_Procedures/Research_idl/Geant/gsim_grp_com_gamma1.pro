Pro GSim_GRP_com_gamma1, fsearch_String, title=title, bin=bin, Type = Type, N = N, foldername=foldername, Class= Class, Sep = Sep
  
  ;
  ; This is based off on Gsim_Grp_Com_Gamma but bootstrapping to see errors. 
  ; So, do the same filtering. 
  ; But instead of creating the histogram in the end of each file, we have arrays.
  ;
  ;

  True =1
  False=0

  If Keyword_Set(N) Eq 0 Then N=100000000


  if keyword_set(foldername) eq 0 then foldername = '' else foldername = foldername ;
  folderflag = False
  If keyword_set(foldername) ne 0 then folderflag = true

  ;
  ;=== Get single or multiple files ====
  ;
  gSimFile = FILE_SEARCH(foldername+fsearch_string)          ; get list of EVT input files

  nfiles =n_elements(gsimFile)                      ; no. of files
  CD, Cur = Cur

  Type_Flag=false

  If Keyword_Set(bin) Eq 0 Then bin = 10            ; Bin Size
  If Keyword_SEt(Type) NE 0 Then Type_Flag = true
  If keyword_set(title) ne 1 then title=''

  Event_Class = 3
  If keyword_set(Class) ne 0 then Event_Class = Class
  If event_class gt 3 then Event_Class = 7

  If (Event_Class NE 3) and (Event_Class NE 2) Then Type_Flag = False  ; Fail Safe for Type Flag

  If Type_flag Eq True then Sel_Type = Type Else SEl_TYpe=0
  If Sel_Type GT 4 then Type_Flag = False

  Sep_Flag = False
  If keyword_set(Sep) ne 0 then Sep_Flag =True
  If (Event_class NE 3) and (Event_Class NE 2) Then Sep_Flag = False ; Fail Safe for Sep_Flags

  IF Sep_Flag eq true then Sep = Sep else sep = 0
  ;
  ;For output file.
  ;
  IF Event_Class Eq 3 then Evt_Text = 'PC' Else IF Event_Class Eq 2 then Evt_Text = 'CC' Else If Event_Class Eq 1 Then Evt_Text = 'C' Else Evt_Text = 'Other'

  ;
  ;===Software Energy Thresholds (keV) ===
  ;
  Cal_Min = 40.0
  Cal_Max = 400.0

  Pla_Min = 10.0
  Pla_MAx = 200.0

  Total_Min = 50.0
  Total_MAx = 600.0


  ;
  ; === Level 1 Processing ===
  ;
  ; Level 1

  GSim_Struc_1 = { $
    VERNO           :0B,            $   ; Data format version number 1

    In_Enrg         :0.0,           $   ; Incident Source 4

    NAnodes         :0B,            $   ; Number of triggered anodes (1-8) 1
    NPls            :0B,            $   ; Number of triggered plastic anodes 1
    NCal            :0B,            $   ; Number of triggered calorimeter anodes 1

    EvType          :0B,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)only for Nanodes 2 1
    EvClass         :0B,            $   ; C = 1, CC =2, PC =3, PP =4, PPC =6 more than 2 events 7 for now. P =5 1

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers 8
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types (Cal=1, Pla =2, Invalid =-1) Weird but thats how it has been used. 8

    IM_Flag         :0B,            $   ; Intermodule flag 1
    Mod_ID          :0B,            $   ; Module ID 1

    ANODENRG        :FLTARR(8),     $   ; Array of triggered anode energies 8 X 4 = 32

    TotEnrg         :0.0           $   ; 4
  }
  Struc1_Size = 64

  ;
  ; == Scaling Factors ==
  ; The 120 is the 120 cm surrounding sphere.
  ; The scale factor could be defined as a time-factor for the spectrum.
  ; to get the number N.
  ;
  scale_str = [3.627,3.203,3.491,2.244]
  scale_cons= [1.52,1.68,1.89,0.571]
  Scl_val = scale_str*scale_cons
  Scl_Factor = scl_val * !PI* 120*120/N

  ;  Scl_Factor = [0.8356, 0.8156, 1, 0.1941]* !PI* 1.2* 1.2/N


  For p = 0, Nfiles-1 Do Begin

    infile = GsimFile[p]

    ;
    ;-- Define few of the file variables.
    ;
    F = File_Info(infile)           ; get inout file info
    Nevents = Long(f.size / Struc1_Size)            ; get number of events in input file
    GsimData1 = replicate(GSim_Struc_1, nevents)    ; initialize input data array

    ; print, infile
    openr, Lun, infile , /Get_Lun
    For i = 0L, nevents-1 do Begin

      readu, Lun, GSim_Struc_1        ; read one event
      GsimData1[i] = GSim_Struc_1       ; add it to input array
    Endfor
    Free_lun, Lun


    ;      Print
    ;      Print, ' **************************** '
    ;      Print, ' File :', infile
    ;      Print, Nevents
    ;      Print

    Temp_Hist = [0.0]

    ;
    ;--- Open and read teh file in --
    ;

    For i = 0L, nevents-1 do Begin

      data = GsimData1[i]        ; so we have stored the structure in data.

      NewAnID = [0]
      NewAnNrg= [0.0]
      NewAnTyp= [0]

      ;
      ;== Software threshold and Filters
      ;
      NoCal = 0
      NoPla = 0
      for j = 0, data.Nanodes -1 Do begin
        ; Applying threshold
        If data.Anodetyp[j] eq 1 Then begin

          If (data.AnodeNrg[j] lt Cal_Min) or (data.AnodeNrg[j] gt Cal_Max) then goto, Skip_Anode
          NewAnID = [NewAnID ,Data.AnodeID[j]]
          NewAnNrg= [NewAnNrg,Data.AnodeNrg[j]]
          NEwAnTyp= [NewAnTyp,Data.Anodetyp[j]]
          NoCal++

        EndIf else if data.Anodetyp[j] eq 2 Then begin

          If (data.AnodeNrg[j] lt Pla_Min) or (data.AnodeNrg[j] gt Pla_Max) then goto, Skip_Anode
          NewAnID = [NewAnID ,Data.AnodeID[j]]
          NewAnNrg= [NewAnNrg,Data.AnodeNrg[j]]
          NEwAnTyp= [NewAnTyp,Data.Anodetyp[j]]
          NoPla++

        EndIf
        Skip_Anode:
      Endfor

      tot_nrg = total(NewAnNrg)
      if tot_nrg lt 0.0 or tot_nrg gt 999 then goto, skip_Event

      If N_Elements(NewAnID) EQ 1 Then goto,Skip_Event

      NewAnID = NewAnID[1:N_Elements(NEwAnID)-1]
      NewAnNrg= NewAnNrg[1:N_Elements(NEwAnNrg)-1]
      NEwAnTyp= NewAnTyp[1:N_Elements(NEwAnTyp)-1]
      NoAn = N_Elements(NewAnID)



      ;
      ; === Re-Classifying the Event Class ===
      ; Software Class
      ;C = 1, CC =2, PC =3, PP =4, PPC =6 more than 2 events 7 for now. P =5 1
      EvtClass = 0
      If NoCal GT 0 Then Begin

        If (NoCal EQ 1) Then Begin
          If NoPla Eq 0 Then EvtClass = 1 Else Begin  ; Condition for C
            ;Condition for PC, PPC or Others
            If Nopla Eq 1 Then EvtClass = 3 Else If NoPla Eq 2 Then EvtClass = 6 Else if NoPla Gt 2 Then EvtClass = 7
          EndElse
        Endif Else if NoCal Gt 1 Then begin
          If ((NoCal eq 2) and (NoPla eq 0)) then EvtClass = 2 Else EvtClass = 7 ; Condition for CC or Others
        Endif

      EndIf Else BEgin ; This is if no_cal =0
        ; For P, PP, Others
        If Nopla EQ 1 Then EvtClass = 5 Else If NoPla Eq 2 Then EvtClass = 4 Else if NoPla GT 2 Then EvtClass = 7 Else EvtClass =0

      Endelse

      If EvtClass Eq 0 Then Goto, Skip_Event

      tot_nrg = total(NewAnNrg)

      ;Event Class filter.
      If evtclass Eq Event_Class Then begin

        If Type_Flag Eq true then Begin
          If Sel_Type Eq 4 Then begin

            If (EventType(NewAnID[0],NewAnID[1]) Eq 2 ) Or (EventType(NewAnID[0],NewAnID[1]) Eq 3 ) Then Begin
              Temp_Hist = [Temp_Hist, TOt_Nrg]
            Endif

          EndIF Else If Sel_Type Eq  EventType(NewAnID[0],NewAnID[1]) Then begin

            If Sep_Flag eq true then begin

              IF Grp_Anode_Separation(NewANID[0],NewAnID[1]) GE SEp then  Temp_Hist = [Temp_Hist, TOt_Nrg]

            Endif else  Temp_Hist = [Temp_Hist, TOt_Nrg]

          endif ; Sel Type.


        EndIf Else  Temp_Hist = [Temp_Hist,tot_nrg] ; Type Flag
      EndIF ; EventClass
      Skip_Event:
    Endfor ; i (events. per file)

    ; Modifying for Bootstrap
    ;   help, pc_Hist
    ;Temp_Histogram = CGHistogram(Temp_Hist[1:n_elements(Temp_Hist)-1], BINSIZE=bin, Locations=XArray, MAX=1000, MIN=0)
   ; if p eq 0 Then gamma1_pc = temp_histogram Else If p eq 1 then gamma2_pc = temp_histogram else if p eq 2 then gamma3_pc = temp_histogram else if p eq 3 then gamma4_pc = temp_histogram
   
   if p eq 0 Then gamma1_pc = temp_hist Else If p eq 1 then gamma2_pc = temp_hist else if p eq 2 then gamma3_pc = temp_hist else if p eq 3 then gamma4_pc = temp_hist


    ;    Print, ' **************************** '

  Endfor ; p

  ; Each gamam1's hold the array not the histogram. 
  ; So each array is the "bucket"
  ; IN the new bucket, we are choosing a random event. 

  Boot_Run = 20
  GammaHist1 = LonArr(100,Boot_Run)
  GammaHist2 = LonArr(100,Boot_Run)
  GammaHist3 = LonArr(100,Boot_Run)
  GammaHist4 = LonArr(100,Boot_Run)
  
  For i = 0, Boot_Run-1 Do begin
      
        Gamma1_Len = (N_Elements(Gamma1_pc))
        NewGammaPC1 = FltArr(Gamma1_LEn)
        for j = 0, Gamma1_Len-1 Do BEgin
                RanLoc = Fix( Randomu(seed,1)*Gamma1_Len)  
                NewGammaPC1[j] = Gamma1_PC[ranLoc]        
        endfor
        GammaHist1[*,i] = CGHistogram(NewGammaPC1[1:n_elements(NewGammaPC1)-1], BINSIZE=bin, Locations=XArray, MAX=999, MIN=0)

        Gamma2_Len = (N_Elements(Gamma2_pc))
        NewGammaPC2 = FltArr(Gamma2_LEn)
        for j = 0, Gamma2_Len-1 Do BEgin
          RanLoc = Fix( Randomu(seed,1)*Gamma2_Len)
          NewGammaPC2[j] = Gamma2_PC[ranLoc]
        endfor
        GammaHist2[*,i] = CGHistogram(NewGammaPC2[1:n_elements(NewGammaPC2)-1], BINSIZE=bin, Locations=XArray, MAX=999, MIN=0)
        
        Gamma3_Len = (N_Elements(Gamma3_pc))
        NewGammaPC3 = FltArr(Gamma3_LEn)
        for j = 0, Gamma3_Len-1 Do BEgin
          RanLoc = Fix( Randomu(seed,1)*Gamma3_Len)
          NewGammaPC3[j] = Gamma3_PC[ranLoc]
        endfor
        GammaHist3[*,i] = CGHistogram(NewGammaPC3[1:n_elements(NewGammaPC3)-1], BINSIZE=bin, Locations=XArray, MAX=999, MIN=0)
        
        Gamma4_Len = (N_Elements(Gamma4_pc))
        NewGammaPC4 = FltArr(Gamma4_LEn)
        for j = 0, Gamma4_Len-1 Do BEgin
          RanLoc = Fix( Randomu(seed,1)*Gamma4_Len)
          NewGammaPC4[j] = Gamma4_PC[ranLoc]
        endfor
        GammaHist4[*,i] = CGHistogram(NewGammaPC4[1:n_elements(NewGammaPC4)-1], BINSIZE=bin, Locations=XArray, MAX=999, MIN=0)

  Endfor
  
  ;Now average and get each histogram std dev and mean.
  

  Gam1_Err = DblArr(100)
  Gam11_Err = DblArr(100)



  Gam2_Err = DblArr(100)

  Gam3_Err = DblArr(100)

  Gam4_Err = DblArr(100)
  
  For i = 0,99 do begin
      
      Temp_Arr1 = GammaHist1[i,*]/10
      std_temp1 = Stddev(Temp_Arr1,/Double)
      gam1_err[i]= std_Temp1
      
      Temp_Arr11 = GammaHist1[i,*]
      std_temp11 = Stddev(Temp_Arr11,/Double)
      gam11_err[i]= std_Temp11
      
      Temp_Arr2 = GammaHist2[i,*]
      std_temp2 = Stddev(Temp_Arr2,/Double)
      gam2_err[i]= std_Temp2
      
      Temp_Arr3 = GammaHist3[i,*]
      std_temp3 = Stddev(Temp_Arr3,/Double)
      gam3_err[i]= std_Temp3
      
      Temp_Arr4 = GammaHist4[i,*]
      std_temp4 = Stddev(Temp_Arr4,/Double)
      gam4_err[i]= std_Temp4
  EndFor
  

 Gam1= CGHistogram(gamma1_pc[1:n_elements(gamma1_pc)-1], BINSIZE=bin, Locations=XArray, MAX=999, MIN=0)
 Gam1_reg_ERr = Sqrt(Gam1)/bin
 Gam11_Reg_ERr = Sqrt(Gam1)
 Gam11 = Gam1
 Gam1 = Gam1/bin
   Gam2= CGHistogram(gamma2_pc[1:n_elements(gamma2_pc)-1], BINSIZE=bin, Locations=XArray, MAX=999, MIN=0)
    Gam3= CGHistogram(gamma3_pc[1:n_elements(gamma3_pc)-1], BINSIZE=bin, Locations=XArray, MAX=999, MIN=0)
     Gam4= CGHistogram(gamma4_pc[1:n_elements(gamma4_pc)-1], BINSIZE=bin, Locations=XArray, MAX=999, MIN=0)
 help, gam1
 window,0
  Cgplot, Xarray, Gam1, Err_Yhigh = Gam1_Reg_Err, Err_Ylow = Gam1_Reg_Err,Err_Color='Black',$
    XRange =[0,400],/ERr_Clip,psym=10, Yrange=[0,15]
   Cgoplot, Xarray, Gam1, Err_Yhigh = Gam1_Err, Err_Ylow = Gam1_Err,Err_Color='Red',psym=10, /Err_Clip
   
  Window,1
 Cgplot, Xarray, Gam11, Err_Yhigh = Gam11_Reg_Err, Err_Ylow = Gam11_Reg_Err,Err_Color='Black',$
    XRange =[0,400],/ERr_Clip,psym=10
   Cgoplot, Xarray, Gam11, Err_Yhigh = Gam11_Err, Err_Ylow = Gam11_Err,Err_Color='Red',psym=10, /Err_Clip
  
  diff_err = DblArr(100)
  help, diff_Err
  For i = 0,99 do begin
   if gam1_reg_err[i] LE 0 Then Diff_Err[i] = 0.0 Else Diff_Err[i]=Gam1_Err[i]/Gam1_Reg_Err[i]
  EndFor
  Window, 3
  CgPlot, Indgen(100)*10, Diff_Err, Color = 'Green', XRange =[0,400],/ERr_Clip

  
Stop

  ;  print, total(gamma1_pc), total(gamma2_pc), total(gamma3_pc), total(gamma4_pc)
  gamma1_err = scl_factor[0]*sqrt(abs(gamma1_pc))
  gamma2_err = scl_factor[1]*sqrt(abs(gamma2_pc))
  gamma3_err = scl_factor[2]*sqrt(abs(gamma3_pc))
  gamma4_err = scl_factor[3]*sqrt(abs(gamma4_pc))


  gamma1 = scl_factor[0]*gamma1_pc
  gamma2 = scl_factor[1]*gamma2_pc
  gamma3 = scl_factor[2]*gamma3_pc
  gamma4 = scl_factor[3]*gamma4_pc

  gamma_total = gamma1+gamma2+gamma3+gamma4
  gamma_total_err = sqrt(gamma1_err*gamma1_err+gamma2_err*gamma2_err+gamma3_err*gamma3_err+gamma4_err*gamma4_err)
  ; window,0
  ;   cgplot, xarray, gamma_total/bin, psym=10, /YLog, /Xlog , Xrange=[30,500], XStyle=1, YRange=[1E-7,1], YStyle=1, YMinor=10,$
  ;         xtitle= 'Energy(keV)', ytitle= 'Counts/s/keV', Title='PC All'


  If Type_Flag eq true Then title1=title+'_Type_'+Strn(Sel_Type) Else Title1=title
  If Sep_FLag eq true then title1 =title1 +'_AnSep'+STrn(Sep) Else Title1= Title1

  foldername1 =''
  if folderflag eq true then begin
    if type_flag eq true then foldername1 = 'Type'+Strn(Sel_Type)+'/' else foldername1='TypeAll/'
    foldername1 = foldername+foldername1
  endif else foldername1 = foldername

  openw, lun1,foldername1+title1+'_'+Evt_Text+'_l1_gamma_com.txt',/Get_Lun
  for i = 0, 999 do begin
    Printf, Lun1, Strn(gamma_total[i]), ' ', strn(gamma_total_err[i])
  endfor
  free_lun, lun1

End