Pro Grp_L2v7_Flt_Hist_checkerror1, fsearch_String, Title= Title, Type=Type, Class = Class, Sep = Sep, Bin=bin

  ; GrandChild of Grp_l2v7_Flt_investigate4
  ; Child of L2v7 flt hist
  ; This is to look at one module and print and plot to see and compare the results.
  ;
  ; This is replication to see the difference between binning before normalization vs
  ; Binning after normalizion in respect to the errors.
  ;
  ; Checking errors.
  ; This is to just generate a histogramfile of lvl2v7 file
  ; Mainly created to deal with ground process.
  ;   Few Assumptions, the Energy histogram is a count histogram so the errors are square root 
  ;                    But the energy (total energy) has some inherent energy error that goes in to binning. 
  ;                    
  ;                    1st of all binning before scaling. 
  ;                    See the effects then use a bootstrap tech.
  ;   
  ;
  ;   We get an average live time for all the anodes.
  ;   Since these do not vary a lot this assumption is ok.
  ;   More proper way would be individual histogram bins for the each modules (as we have
  ;   livetime for each modules not each anodes).
  ;
  ;   Secondly, time ran is assumed to be 720s for each sweep.
  ;   Some sweeps are few decimal values less or more but on average this is an acceptable
  ;   assumptions. One of the sweep of r121 sweep no. 15 has negative time diff of 23
  ;
  ;   Fltl1_ener.pro was used to create a enerhist previously and those files with background used to plot
  ;
  ; 
  ;
  close, /all
  If keyword_set(bin) eq 0 then bin = 5 ; Binsize

  Class=3
  ;
  
  N_Boot = 10000

  True = 1
  False= 0


  CGPS_Open, 'ErrorCheck_NBOOT_170'+STRN(N_BOOT)+'.ps'
  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 10.0
  Pla_EMax = 200.00

  Cal_EMin = 40.0
  Cal_EMax = 400.00

  Tot_EMin = 50.00
  Tot_EMax = 500.00

  Xlow_Cut = Fix(Tot_Emin/bin)
  Xhigh_Cut = Fix(Tot_Emax/bin)
  Print,'-----------'
  Print, Pla_Emin
  Print, Cal_Emin
  Print, Tot_EMin
  Print, Tot_EMax
  Print,'-----------'

  Altitude = 131.5D

  Cd, Cur=Cur

  IF Keyword_Set(title) Eq 0 Then Title='Test'
  IF Keyword_Set(Class) Eq 0 Then Class = 3

  If Keyword_Set(Type) NE 0 Then Type_Flag =1 else Type_Flag=0

  If (Class Lt 1) or (Class Gt 3) Then Class = 7
  ;
  ;For output file.
  ;
  IF Class Eq 3 then Evt_Text = 'PC' Else IF Class Eq 2 then Evt_Text = 'CC' Else If Class Eq 1 Then Evt_Text = 'C' Else Evt_Text = 'Other'
  ptitle = 'Energy Loss Spectrum (PC)'
  Print, 'CLASS: ',Class,Evt_Text

  If (Class NE 3) and (Class NE 2) Then Type_Flag = False  ; Fail Safe for Type Flag
  If Type_Flag Gt 4 Then Type_Flag = False
  If Type_flag Eq True then Sel_Type = Type Else SEl_TYpe=0
  ;Sep_Flag = False
  ;If keyword_set(Sep) ne 0 then Sep_Flag =True
  ;If (class NE 3) and (Class NE 2) Then Sep_Flag = False ; Fail Safe for Sep_Flags

  ;IF Sep_Flag eq true then Sep = Sep else sep = 0

  ;Print, Type_Flag, Class, Sep_Flag
  ; If Etype eq 0 then Etype_Text = '' else Etype_Text = '_'+Strn(EType)

  c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration

  ;
  ;  Calorimeter element anode ids (0..63)
  ;
  Cal_anodes = [0,1,2,3,4,5,6,7,8,15,16,23,24,31,32,39,40,47,48,55,56,57,58,59,60,61,62,63]

  ;
  ;=========================================================================================
  ;
  ;  Plastic element anode Ids (0..63)
  ;
  Pls_anodes = [9,10,11,12,13,14,17,18,19,20,21,22,25,26,27,28,29,30,33,34,35,36,37,38,41, $
    42,43,44,45,46,49,50,51,52,53,54]


  ;===========
  evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
  if keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)


  Openw, lun101, 'Check_Error.txt', /Get_lun
  printf, lun101, STring(evtfiles)


  ;
  ;
  ;  Here we define the structure to hold the output L2 event data.
  ;
  Struc = {                $
    VERNO:0B,            $   ; Data format version number
    QFLAG:0,             $   ; Event quality flag
    SWEEPNO:0,           $   ; Sweep Number
    SWSTART:0.0D,        $   ; Start time of sweep
    SWTIME:0.0D,         $   ; Time since start of sweep (secs)
    EVTIME:0.0D,         $   ; Event Time (secs in gps time - from 0h UT Sunday)
    TJD:0.0D,            $   ; Truncated Julian Date

    EVCLASS:0,           $   ; Event Class (1=C, 2=CC, 3=PC, 4= intermdule)
    IMFLAG:0B,           $   ; = 1 for intermodule (2 module) event
    ACFLAG:0B,           $   ; = 1 for anticoincidence

    NANODES:0B,          $   ; Number of triggered anodes (1-8)
    NPLS:0B,             $   ; Number of triggered plastic anodes
    NCAL:0B,             $   ; Number of triggered calorimeter anodes
    EVTYPE:0,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)

    ANODEID:BYTARR(8),   $   ; Array of triggered anode numbers
    ANODETYP:BYTARR(8),  $   ; Array of triggered anode types
    ANODENRG:FLTARR(8),  $   ; Array of triggered anode energies
    ANODESIG:FLTARR(8),  $   ; Array of triggered anode energy errors

    PA_MOD:0,            $   ; Primary Anode Module Position No.
    PA_SER:0,            $   ; Primary Anode Module Serial No.
    PA_ID:0,             $   ; Primary Anode No.
    PA_NRG:0.0,          $   ; Primary Anode Energy (keV)
    PA_SIG:0.0,          $   ; Primary Anode Energy Uncertainty (keV)

    SA_MOD:0,            $   ; Secondary Anode Module Position No.
    SA_SER:0,            $   ; Secondary Anode Module Serial No.
    SA_ID:0,             $   ; Secondary Anode No.
    SA_NRG:0.0,          $   ; Secondary Anode Energy (keV)
    SA_SIG:0.0,          $   ; Secondary Anode Energy Uncertainty (keV)

    TOTNRG:0.0,          $   ; Total Event Energy (keV)
    TOTSIG:0.0,          $   ; Total Event Energy Uncertainty (keV)

    COMPANG:0.0,         $   ; Caluculated Compton Scatter Angle (deg)
    COMPSIG:0.0,         $   ; Compton Scatter Angle Uncertainty (deg)

    LAT:0.0,             $   ; Latitude (degs)
    LON:0.0,             $   ; Longitude (degs)
    ALT:0.0,             $   ; Altitude (feet)
    DEPTH:0.0,           $   ; Atm Depth (g cm^-2)
    SOURCE:0B,           $
    AIRMASS:0.0,         $
    PNTAZI:0.0,          $   ; Pointing Azimuth (degs)
    PNTZEN:0.0,          $   ; Pointing Zenith (degs)
    SRCAZI:0.0,          $
    SRCZEN:0.0,          $
    SRCOFF:0.0,          $

    RTANG:0.0,           $   ; Rotation Table Angle (degs)
    RTSTAT:0B,           $   ; Rotation Table Status
    SCTANG:0.0,          $   ; Scatter Angle in instrument coords (degs)
    PVANG:0.0,           $   ; Scatter Angle in pressure vessel coords (degs)
    PPVANG:0.0,          $   ; Scatter Angle in projected PV coords (degs)
    HRANG:0.0,           $   ; Hour Angle (degs)
    PARANG:0.0,          $   ; Paralactic Angle (degs)
    POSANG:0.0,          $   ; Position angle of the scatter vector (deg)

    LIVETIME:0.0,        $
    CORRECTLT:0.0        $
  }
  ;Total 248 Bytes

  Packet_Len = 248 ; In Bytes
  ;

  EnerArr = DblArr(1000)
  ;  EnerArr1 = DblArr(1000)
  ;  EnerArr2 = DblArr(1000)
  ;  EnerArr3 = DblArr(1000)
  ;  EnerArr4 = DblARr(1000)

  EnerErr = DblArr(1000)
  ;  EnerErr1= DblArr(1000)
  ;  EnerErr2= DblArr(1000)
  ;  EnerErr3= DblArr(1000)
  ;  EnerErr4= DblArr(1000)

  ;
  ;-- For Each File --
  ;
  For p = 0, nfiles-1 Do Begin ; open each file

    ;
    ;== Open and read the files ==
    ;
    infile = evtfiles[p]
    Print, Infile
    f = file_info(infile)
    Openr, lun, infile, /GET_Lun
    nevents = long(f.size/Packet_Len)
    Event_data = replicate(Struc, nevents)

    For i = 0, nevents-1 Do begin
      readu, lun, Struc
      Event_Data[i] = struc
    Endfor


    Temp_EnerArr = DblArr(1000,32)
    Temp_EnerErr = DblArr(1000,32)
    Temp_ENerErr_2 = DblArr(1000,32)

    LT_Array = DblArr(32)
    LT_Count = DblArr(32)
    A =0  ; First Time Stamp

    ; We need each module bins.
    ;
    ;c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration
    TempMod_0 = [0.0]
    TempMod_2 = [0.0]
    TempMod_3 = [0.0]
    TempMod_4 = [0.0]
    TempMod_6 = [0.0]
    TempMod_7 = [0.0]
    TempMod_9 = [0.0]
    TempMod_10 = [0.0]

    TempMod_11 = [0.0]
    TempMod_12 = [0.0]
    TempMod_13 = [0.0]
    TempMod_14 = [0.0]
    TempMod_17 = [0.0]
    TempMod_18 = [0.0]
    TempMod_19 = [0.0]
    TempMod_20 = [0.0]
    
    TempMod_21 = [0.0]
    TempMod_22 = [0.0]
    TempMod_24 = [0.0]
    TempMod_25 = [0.0]
    TempMod_27 = [0.0]
    TempMod_28 = [0.0]
    TempMod_29 = [0.0]
    TempMod_31 = [0.0]

    ;
    ;--- For Each Packet ---
    ;
    For i = 0, Nevents-1 Do Begin
      data = event_Data[i]
      ;       if data.EvClass Eq 2 then begin
      ;        print, data.Qflag , 'ok', i, data.totNrg
      ;       endif
      ;
      ; == Time ==
      ;
      Time = data.EvTime             ; Time
      If A EQ 0 Then Begin
        Old_Time = Time
      Endif
      A=1
      Time_Diff = Time - Old_Time

      ;
      ;== Necessary Filters.==
      ;
      If (data.totNrg ge 1000) or (data.totNrg le 0) then goto, jump_Packet
      If Data.Qflag LT 0 Then goto, Jump_Packet
      If Data.ACflag EQ 1 Then Goto, Jump_Packet
      If Data.Nanodes LE 0 Then Goto, Jump_Packet

      NewAnodeId = [0]
      NewanodeNrg= [0.0]
      NewAnodeTyp= [0]
      NewAnodesig = [0.0]
      NOCal = 0
      NoPla = 0

      ;      Print, data.nanodes
      ;
      ;== Applying the software Thresholds ==
      ;
      ;     Print, Data.Nanodes, '**'
      for j = 0, Data.Nanodes-1 Do Begin
        If data.anodetyp[j] EQ 1 Then Begin    ; Its a Plastic so check these
          If (data.AnodeNRG[j] LT Pla_EMIN) or (data.AnodeNRG[j] GT Pla_EMAX) Then Goto, Jump_anode
          NewANodeID = [NewAnodeId,data.anodeid[j]]
          NewAnodeNrg= [NewAnodeNrg,data.anodenrg[j]]
          NewAnodeTyp= [NewAnodeTyp,data.anodetyp[j]]
          NewAnodeSig= [NewAnodeSig,data.anodesig[j]]
          NOPla++
        EndIf Else If  data.AnodeTyp[j] EQ 2 Then Begin    ; cal
          If (data.AnodeNRG[j]LT Cal_EMIN) or (data.AnodeNRG[j] GT Cal_EMAX) Then Goto, Jump_anode
          NewANodeID = [NewAnodeId,data.anodeid[j]]
          NewAnodeNrg= [NewAnodeNrg,data.anodenrg[j]]
          NewAnodeTyp= [NewAnodeTyp,data.anodetyp[j]]
          NewAnodeSig= [NewAnodeSig,Data.anodesig[j]]
          NOCal++
        EndIf
        jump_anode:
      endfor
      If N_Elements(newAnodeId) eq 1 then goto, JUmp_Packet
      NewANodeID = NewAnodeId[1:N_elements(NewAnodeID)-1]
      NewAnodeNrg= NewAnodeNrg[1:N_Elements(NewAnodeNrg)-1]
      NewAnodeTyp= NewAnodeTyp[1:N_Elements(NewAnodeTyp)-1]
      NewAnodeSig= NewAnodeSig[1:N_Elements(NewAnodeSig)-1]

      Tot_Nrg = Total(NewANodeNrg)
      Temp_nrg_sig2 =NewAnodeSig^2
      Tot_Nrg_Sig2 = Total( Temp_nrg_sig2 )


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


      If EvtClass NE Class Then goto, Jump_Packet ;

      m = data.Pa_Mod


      ;
      ;== Live time ==
      ;
      LiveTime = Data.CorrectLT
      LT_Array[m] = LT_Array[m]+LiveTime
      LT_Count[m]++
      ;c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration

      case m of 
        0: TempMod_0 = [TempMod_0,Tot_Nrg]
        2: TempMod_2 = [TempMod_2,Tot_Nrg]
        3: TempMod_3 = [TempMod_3,Tot_Nrg]
        4: TempMod_4 = [TempMod_4,Tot_Nrg]
        6: TempMod_6 = [TempMod_6,Tot_Nrg]
        7: TempMod_7 = [TempMod_7,Tot_Nrg]
        9: TempMod_9 = [TempMod_9,Tot_Nrg]
        10:TempMod_10 = [TempMod_10,Tot_Nrg]
        
        11: TempMod_11 = [TempMod_11,Tot_Nrg]
        12: TempMod_12 = [TempMod_12,Tot_Nrg]
        13: TempMod_13 = [TempMod_13,Tot_Nrg]
        14: TempMod_14 = [TempMod_14,Tot_Nrg]
        17: TempMod_17 = [TempMod_17,Tot_Nrg]
        18: TempMod_18 = [TempMod_18,Tot_Nrg]
        19: TempMod_19 = [TempMod_19,Tot_Nrg]
        20: TempMod_20 = [TempMod_20,Tot_Nrg]
        
        21: TempMod_21 = [TempMod_21,Tot_Nrg]
        22: TempMod_22 = [TempMod_22,Tot_Nrg]
        24: TempMod_24 = [TempMod_24,Tot_Nrg]
        25: TempMod_25 = [TempMod_25,Tot_Nrg]
        27: TempMod_27 = [TempMod_27,Tot_Nrg]
        28: TempMod_28 = [TempMod_28,Tot_Nrg]
        29: TempMod_29 = [TempMod_29,Tot_Nrg]
        31: TempMod_31 = [TempMod_31,Tot_Nrg]
        
        else: Begin 
              print, 'Error in mod no:' +STrn(m)
              print, ' This module no. is not compatible'
              Stop
              End
      endcase
      ;
      ;-- This is for the PC all histogram
      ;
      Temp_EnerArr[Tot_Nrg,m]++
      Temp_EnerErr_2[Tot_Nrg,m] =   Temp_EnerErr_2[Tot_Nrg,m]+Tot_Nrg_sig2

    ;  PRint, Tot_NRG,  Sqrt(Tot_Nrg_Sig2)
 
    ;  if i Gt 50 then stop



      Jump_Packet:
      If i mod 100000 EQ 0 Then print, i
    EndFor; /i
    
    ; We need to ready the buckets for the bootstrapping:
    ; Remove the initial 0 value. 
    ; Might encounter a 0 value array.


   ; TempMod_0 = TempMod_0[1:N_Elements(TempMod_0)-1]
    TempMod_2 = TempMod_2[1:N_Elements(TempMod_2)-1]
    TempMod_3 = TempMod_3[1:N_Elements(TempMod_3)-1] 
    TempMod_4 = TempMod_4[1:N_Elements(TempMod_4)-1] 
    TempMod_6 = TempMod_6[1:N_Elements(TempMod_6)-1] 
    TempMod_7 = TempMod_7[1:N_Elements(TempMod_7)-1]
    TempMod_9 = TempMod_9[1:N_Elements(TempMod_9)-1]
    TempMod_10 = TempMod_10[1:N_Elements(TempMod_10)-1]

    TempMod_11 = TempMod_11[1:N_Elements(TempMod_11)-1]
    TempMod_12 = TempMod_12[1:N_Elements(TempMod_12)-1]
    TempMod_13 = TempMod_13[1:N_Elements(TempMod_13)-1]
    TempMod_14 = TempMod_14[1:N_Elements(TempMod_14)-1]
    TempMod_17 = TempMod_17[1:N_Elements(TempMod_17)-1]
    TempMod_18 = TempMod_18[1:N_Elements(TempMod_18)-1]
    TempMod_19 = TempMod_19[1:N_Elements(TempMod_19)-1]
    TempMod_20 = TempMod_20[1:N_Elements(TempMod_20)-1]

    TempMod_21 = TempMod_21[1:N_Elements(TempMod_21)-1]
    TempMod_22 = TempMod_22[1:N_Elements(TempMod_22)-1]
    TempMod_24 = TempMod_24[1:N_Elements(TempMod_24)-1]
    TempMod_25 = TempMod_25[1:N_Elements(TempMod_25)-1]
    TempMod_27 = TempMod_27[1:N_Elements(TempMod_27)-1]
    TempMod_28 = TempMod_28[1:N_Elements(TempMod_28)-1]
    TempMod_29 = TempMod_29[1:N_Elements(TempMod_29)-1]
    TempMod_31 = TempMod_31[1:N_Elements(TempMod_31)-1]
    
    
    ;  BOOT STRAPPING .. For each individual array.
    ;  From Main Bucket, Generate various boot strap buckets.
   
   ; TempMod_0_Boot = FltArr(N_boot,N_ELements(tempMod_0)-1)
    TempMOd_0_Boot = FltARr(N_Boot,51)
    

    Ori_Plot=Cghistogram(TempMod_0[1:N_Elements(TempMod_0)-1], BINSIZE=5.0,LOCATIONS=XVar, Min=50, Max=300)
   For b = 0, N_boot-1 Do Begin
      
    ; Mod 0
    Temp_Array  = TempMod_0[1:N_Elements(TempMod_0)-1]
    N_bucket    = N_Elements(Temp_Array)
    Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
    New_TArray  = Temp_Array[Temp_X]
    a =Cghistogram(New_TArray, BINSIZE=5.0,LOCATIONS=XVar, Min=50, Max=300)
 ;   help, a
  tempmod_0_boot[b,*]=a
    
   ; TempMOd_0_boot[b,*]= 
   ; Help, New_TArray, TempMod_0_Boot, Temp_Array
    
  ;  TempMod_0_Boot[b,*] = New_TARray
    EndFor
    
    Help, Temp_mod_0_Boot, New_TArray
    
    
    
    Mod0_n = 51 ;
    Mod0_arr = FltArr(Mod0_n)
    Mod0_err = FltArr(Mod0_n)
    Mod_test_Err = FLtArr(N_Boot)
    
    
    Help, Mod0_n
    For i = 0, Mod0_n-1 do begin
        TempArr = TempMod_0_Boot[*,i] 
        Mod0_arr[i] = Avg(TempArr)
        Mod0_err[i] = Stddev(TempArr)
        If i eq 24 then Avg_15= Avg(TempArr)
    EndFor
    
    TempArr = TempMod_0_Boot[*,24]
    TempErr_check = (TempArr);-Avg_15)
    Help, TempArr, TempERR_Check
    Help, Mod0_Arr
    HElp, MOd0_Err
    XVar= INDGEN(51)*5+50
;Mod0_Hist =  Cghistogram(Mod0_Arr, BINSIZE=5.0,LOCATIONS=XVar, Min=50, Max=300)
help, Xvar, Mod0_Arr, Mod0_Err, MOd0_Arr
;window,0
CGPLot, XVar, MOd0_Arr, PSYM=10, err_ylow=Mod0_Err, err_yhigh=MOd0_Err,$
  XTitle='keV', Ytitle='Counts', Title='Mod 0 before scaling boot_n='+Strn(N_boot)
 CgOplot, Xvar, Ori_Plot, PSYM=10, Color='red' 
 
 
  CgERase
 Error_histo = CgHistogram(TempERr_Check, NBins=20, Locations=Xvar0) 
 Print, Total(Error_Histo), Min(ERror_histo)
 CgPlot,Xvar0, Error_histo, psym=10, Title='Error Distribution (y - ybar) for 170kev'
  CgErase
  

  CgPlot, Xvar,Mod0_Err, title='Error ', PSYM=10, XTitle='keV'
  
  Cgerase
  Error_histo2 = Cghistogram(Mod0_err, locations=Xvar1, MIN=0.1, Max=Max(Mod0_err), nbins=20)
  
  Cgplot, xvar1, error_histo2, psym=10
CGPS_CLose
    Temp_Str = Cur+'/'+'ErrorCheck_NBOOT_170'+STRN(N_BOOT)+'.ps'
        CGPS2PDF, Temp_Str,delete_ps=1
    for i = 0,n_elements(Mod0_Err)-1 do begin
          Printf,lun101,i, Xvar[i], Mod0_arr[i], Mod0_Err[i]
    Endfor
Free_lun, lun101


    ;
    ;
    Print, Nevents
    Help,  TempMod_0
    stop
    ; == Checks ==

    time_Diff = 720

    ;
    ; === Average Live Time ====
    ;
    AvgLT_Arr = dblArr(32)
    for j = 0,31 do if lt_count[j] ne 0 then  AvgLT_arr[j] = lt_array[j]/lt_count[j]

    ;
    ;=== Errors ===
    ;
    Temp_EnerErr = Sqrt(Abs( Temp_EnerArr )) ; /older.. wrong
    Temp_EnerERr_2_root = Sqrt(Temp_EnerERr_2) ; proper translation
    
    
    ;
    ;== Need to normalize and add them each file at a time, for each module.
    ;
    For j = 0,31 Do Begin
      If (where (j EQ c2014) GE 0) Then Begin
        Temp_arr = Temp_EnerArr[*,j]
      ; Temp_Err = Temp_ENerErr[*,j]
        Temp_err = Temp_EnerErr_2_root[*,j]

        printf, lun101
        Printf, lun101, '--------'
        printf, lun101, j
        for k = 0, 999 do begin
          If Temp_arr[k] ne 0 then begin

            printf, lun101, Temp_arr[k], Temp_err[k], 100*temp_err[k]/Temp_arr[k] , format='(F8.4,1X, F8.4,1X,F8.4)'

          Endif
        ENdFor
        ;        Printf, lun101
        ;        Printf, LUn101, 'AvgLt:', Strn(Avglt_ARr[j])
        ;        Printf, lun101, Strn(j), ' ', Temp_Arr
        ;        Printf, Lun101, Strn(j), ' ', String(Temp_err)
        ;        Printf, lun101

        If AvgLt_Arr[j] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Temp_Arr/(AvgLT_Arr[j]*Time_Diff)
        If AvgLt_Arr[j] EQ 0.0 Then EnerErr =EnerERr Else EnerErr= EnerErr+((Temp_Err/(AvgLT_Arr[j]*Time_Diff))*Temp_Err/(AvgLT_Arr[j]*Time_Diff) )


      EndIf
    EndFor

    Printf, lun101
    Printf, lun101, 'Time diff:', Time_Diff
    Printf, lun101, 'm AvgLT SclTime SclFactor'
    For j = 0,31 Do Begin
      If (where (j EQ c2014) GE 0) Then Begin

        Printf, lun101, j, AvgLT_ARr[j], AvgLT_Arr[j]*Time_Diff, 1/(AvgLt_Arr[j]*TIme_Diff), format='(F8.4,1X, F8.4,1X,F8.4,1X,F8.4)'

      EndIF
    EndFor

    Printf, lun101
    printf, lun101, 'Averages
    printf,lun101, Total(AvgLT_ARR)/24, Total(AvgLT_ARR)*Time_DIff/24, 24/(Total(AvgLT_ARR)*Time_DIff)

    Printf, lun101
    Printf, lun101

    For k = 0, 999 do begin
      If EnerArr[k] NE 0 Then begin
        Percent=100*(SQRT(ENerErr[k]))/EnerArr[k]
        Printf, lun101,k, EnerArr[k], SQRT(ENerErr[k]) , Percent , format='(F8.1,1X,F8.4,1X, F8.4,1X,F8.4)'
      Endif
    Endfor


  EndFor; /p



  EnerArr = EnerArr/nfiles
  EnerErr = (SQRT(EnerErr))/nfiles ; may be this is not right.

  ;
  ; == REbin ==
  ;
  nbins = (1000/bin)
  xval2 = indgen(nbins)*bin
  xval3 = indgen(nbins)*bin+bin
  Cntr = 0L

  Flight2 = DblArr(nbins)
  Flight2_Err = DblArr(nbins)

  Cntr=0L

  for i = 0, nbins-1 do begin
    tempFli   = 0.0
    tempFli_err   = 0.0
    for j = 0, bin-1 do begin

      tempFli   = tempfli   + EnerArr[cntr]
      tempFli_err   = tempFli_err   + EnerErr[cntr]*EnerErr[cntr]
      cntr++
    endfor

    Flight2[i] = tempFli
    Flight2_Err[i] = Sqrt(tempFli_Err)
  endfor ; i
  Flight2 = Flight2/bin
  Flight2_Err = Flight2_err/bin


  Free_lun, lun101
  
  ;
  ;=== Text file for pha ==
  ; Elow Ehigh Counts/S Error.
  ;

  XVal2a = Float(Xval2[xlow_cut:xhigh_cut])
  Xval3a = Float(Xval3[xlow_cut:xhigh_cut])
  Flight2a = Float(Flight2[xlow_cut:xhigh_cut])
  Flight2a_Err = Float(Flight2_err[xlow_cut:xhigh_cut])
  openw, lun1, Title+'_fltHist.txt',/GET_LUN
  for i = 0, n_elements(Xval2a)-1 do begin
    datai = Strn(xval2a[i]) + '    '+Strn(xval3a[i])+ '    '+ Strn(Flight2a[i]) + '    '+ Strn(Flight2a_Err[i])
    printf, lun1, datai
  endfor
  Free_Lun, lun1

  ;===
  ;---- Opening the Device for further plots and various things -----
  CgPs_Open, Title+'_FltHist.ps', Font =1, /LandScape
  cgLoadCT, 13
  !P.Font=1

  ;    xticks = loglevels([xmin,xmax])
  ;    nticks = n_elements(xticks)
  xmin=50
  xmax=300
  ymin= 0.003
  ymax=0.2
  ;
  ; Page 1: Flight vs gamma
  ;
 ; print, flight2
  Cgplot, Xval2,Flight2, PSYM=10, XRANGE=[Xmin,Xmax],Xstyle=1, $; /Xlog,/Ylog, YStyle=1,$;
    title=ptitle, xtitle=xtitle, ytitle=ytitle,$;linestyle=1, $
    err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color='black',Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1


  CgPs_Close

  ;-- Create the PDF File
  Temp_Str = Cur+'/'+'ErrorCheck_NBOOT_170'+STRN(N_BOOT)+'.ps''
  CGPS2PDF, Temp_Str,delete_ps=1

  Stop
End