Pro Grp_L2v7_FltHist1a, fsearch_String, Title= Title, Type=Type, Class = Class, Sep = Sep;, Bin=bin

  ; GrandChild of Grp_l2v7_Flt_investigate4
  ; Child of L2v7_flt_hist
  ; Variation from L2v7_FltHist1
  ; 
  ; This is similar to FltHist1 but with proper binning.
  ;
  ; This is an update for check errors.
  ; We are binning it before we scale/normalize
  ; We are also using a bootstrapping for errors.
  ; Each sweep/file generates a energy histogram of counts per sec for the bin.
  ; That is added further.
  ;
  ; More notes on investigate4 and flt_hist (also the *checkerror1)
  True = 1
  False= 0

  close, /all

  ;
  ;- Bin INformations
;  If keyword_set(bin) eq 0 then bin_Size = 5 Else Bin_Size = Bin ; Binsize


  ; - Number of BootStrap -
  N_Boot = 10000

  Ebin_lo = [65,70,90 ,120,160,200]
  Ebin_hi = [70,90,120,160,200,300]
  
  Min_Bin = Ebin_lo[0]
  Max_Bin = Ebin_hi[N_elements(Ebin_hi)-1]
  


  Class=3

  ;-- Energy Selection
  ;
  Pla_EMin = 10.0
  Pla_EMax = 200.00

  Cal_EMin = 40.0
  Cal_EMax = 400.00

  Tot_EMin = 50.00
  Tot_EMax = 500.00

;  Xlow_Cut = Fix(Tot_Emin/bin_size)
;  Xhigh_Cut = Fix(Tot_Emax/bin_Size)
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


  ;  Openw, lun101, 'Check_Error.txt', /Get_lun
  ;  printf, lun101, STring(evtfiles)


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


  ;  EnerArr1 = DblArr(1000)
  ;  EnerArr2 = DblArr(1000)
  ;  EnerArr3 = DblArr(1000)
  ;  EnerArr4 = DblARr(1000)


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

    ;

    For i = 0, nevents-1 Do begin
      readu, lun, Struc
      Event_Data[i] = struc
    Endfor

    ; = Output file name =
    Sweep = Event_data[0].SweepNo
    Pos0 = StrPos(infile, '.dat', 0)
    Temp_Str = StrMid(infile, 0, Pos0)
    Out_Tfile = Temp_str+'_Swp'+Strn(Sweep)+'_FltHist1.txt'
    Openw, lun102, Out_TFile, /Get_lun
    Printf, lun102, 'LoEner(keV)  HiEner(keV) c/s  Error



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

    ;  BOOT STRAPPING .. For each individual array.
  ;  Ori_Plot=Cghistogram(TempMod_0[1:N_Elements(TempMod_0)-1], BINSIZE=Bin_Size,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
   
    NBin = N_elements(Ebin_lo)

    
    TempMOd_0_Boot  = FltARr(N_Boot,NBin)
    TempMOd_2_Boot  = FltARr(N_Boot,NBin)
    TempMOd_3_Boot  = FltARr(N_Boot,NBin)
    TempMOd_4_Boot  = FltARr(N_Boot,NBin)
    TempMOd_6_Boot  = FltARr(N_Boot,Nbin)
    TempMOd_7_Boot  = FltARr(N_Boot,NBin)
    TempMOd_9_Boot  = FltARr(N_Boot,NBin)
    TempMOd_10_Boot = FltARr(N_Boot,Nbin)

    TempMOd_11_Boot = FltARr(N_Boot,NBin)
    TempMOd_12_Boot = FltARr(N_Boot,NBin)
    TempMOd_13_Boot = FltARr(N_Boot,NBin)
    TempMOd_14_Boot = FltARr(N_Boot,NBin)
    TempMOd_17_Boot = FltARr(N_Boot,NBin)
    TempMOd_18_Boot = FltARr(N_Boot,NBin)
    TempMOd_19_Boot = FltARr(N_Boot,NBin)
    TempMOd_20_Boot = FltARr(N_Boot,NBin)

    TempMOd_21_Boot = FltARr(N_Boot,NBin)
    TempMOd_22_Boot = FltARr(N_Boot,NBin)
    TempMOd_24_Boot = FltARr(N_Boot,NBin)
    TempMOd_25_Boot = FltARr(N_Boot,NBin)
    TempMOd_27_Boot = FltARr(N_Boot,NBin)
    TempMOd_28_Boot = FltARr(N_Boot,NBin)
    TempMOd_29_Boot = FltARr(N_Boot,NBin)
    TempMOd_31_Boot = FltARr(N_Boot,NBin)

    ;--- BootStrap Loop ---
    For b = 0, N_boot-1 Do Begin

      ; Mod 0
      Temp_Array  = TempMod_0[1:N_Elements(TempMod_0)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap. 
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
          temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
          a [j] = count
      Endfor
    ;  a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_0_boot[b,*]=a
      
      ; Mod 2
      Temp_Array  = TempMod_2[1:N_Elements(TempMod_2)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
     ; a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_2_boot[b,*]=a

      ; Mod 3
      Temp_Array  = TempMod_3[1:N_Elements(TempMod_3)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_3_boot[b,*]=a

      ; Mod 4
      Temp_Array  = TempMod_4[1:N_Elements(TempMod_4)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_4_boot[b,*]=a

      ; Mod 6
      Temp_Array  = TempMod_6[1:N_Elements(TempMod_6)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_6_boot[b,*]=a

      ; Mod 7
      Temp_Array  = TempMod_7[1:N_Elements(TempMod_7)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_7_boot[b,*]=a

      ; Mod 9
      Temp_Array  = TempMod_9[1:N_Elements(TempMod_9)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_9_boot[b,*]=a

      ; Mod 10
      Temp_Array  = TempMod_10[1:N_Elements(TempMod_10)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_10_boot[b,*]=a

      ; Mod 11
      Temp_Array  = TempMod_11[1:N_Elements(TempMod_11)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_11_boot[b,*]=a

      ; Mod 12
      Temp_Array  = TempMod_12[1:N_Elements(TempMod_12)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_12_boot[b,*]=a

      ; Mod 13
      Temp_Array  = TempMod_13[1:N_Elements(TempMod_13)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_13_boot[b,*]=a

      ; Mod 14
      Temp_Array  = TempMod_14[1:N_Elements(TempMod_14)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_14_boot[b,*]=a

      ; Mod 17
      Temp_Array  = TempMod_17[1:N_Elements(TempMod_17)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_17_boot[b,*]=a

      ; Mod 18
      Temp_Array  = TempMod_18[1:N_Elements(TempMod_18)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_18_boot[b,*]=a

      ; Mod 19
      Temp_Array  = TempMod_19[1:N_Elements(TempMod_19)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_19_boot[b,*]=a

      ; Mod 20
      Temp_Array  = TempMod_20[1:N_Elements(TempMod_20)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_20_boot[b,*]=a

      ; Mod 21
      Temp_Array  = TempMod_21[1:N_Elements(TempMod_21)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_21_boot[b,*]=a

      ; Mod 22
      Temp_Array  = TempMod_22[1:N_Elements(TempMod_22)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_22_boot[b,*]=a

      ; Mod 24
      Temp_Array  = TempMod_24[1:N_Elements(TempMod_24)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_24_boot[b,*]=a

      ; Mod 25
      Temp_Array  = TempMod_25[1:N_Elements(TempMod_25)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_25_boot[b,*]=a

      ; Mod 27
      Temp_Array  = TempMod_27[1:N_Elements(TempMod_27)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_27_boot[b,*]=a

      ; Mod 28
      Temp_Array  = TempMod_28[1:N_Elements(TempMod_28)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_28_boot[b,*]=a

      ; Mod 29
      Temp_Array  = TempMod_29[1:N_Elements(TempMod_29)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_29_boot[b,*]=a

      ; Mod 31
      Temp_Array  = TempMod_31[1:N_Elements(TempMod_31)-1]
      N_bucket    = N_Elements(Temp_Array)
      Temp_X      = FIX(N_Bucket*Randomu(Seed,N_bucket))
      New_TArray  = Temp_Array[Temp_X]
      ; bin a histogram for the bootstrap.
      a = Fltarr(Nbin)
      For j = 0, Nbin-1 do begin
        temp_a = New_TArray[where( (New_Tarray GE Ebin_lo[j] ) and ( New_TArray LT Ebin_hi[j]) , count, /NULL)]
        a [j] = count
      Endfor
      ;a =Cghistogram(New_TArray, BINSIZE=Bin_Size ,LOCATIONS=XVar, Min=Min_Bin, Max=Max_Bin)
      tempmod_31_boot[b,*]=a

    EndFor

    Mod0_Arr = FltArr(Nbin)
    Mod2_Arr = FltArr(Nbin)
    Mod3_Arr = FltArr(Nbin)
    Mod4_Arr = FltArr(Nbin)
    Mod6_Arr = FltArr(Nbin)
    Mod7_Arr = FltArr(Nbin)
    Mod9_Arr = FltArr(Nbin)
    Mod10_Arr = FltArr(Nbin)

    Mod11_Arr = FltArr(Nbin)
    Mod12_Arr = FltArr(Nbin)
    Mod13_Arr = FltArr(Nbin)
    Mod14_Arr = FltArr(Nbin)
    Mod17_Arr = FltArr(Nbin)
    Mod18_Arr = FltArr(Nbin)
    Mod19_Arr = FltArr(Nbin)
    Mod20_Arr = FltArr(Nbin)

    Mod21_Arr = FltArr(Nbin)
    Mod22_Arr = FltArr(Nbin)
    Mod24_Arr = FltArr(Nbin)
    Mod25_Arr = FltArr(Nbin)
    Mod27_Arr = FltArr(Nbin)
    Mod28_Arr = FltArr(Nbin)
    Mod29_Arr = FltArr(Nbin)
    Mod31_Arr = FltArr(Nbin)

    ;---------

    Mod0_Err = FltArr(Nbin)
    Mod2_Err = FltArr(Nbin)
    Mod3_Err = FltArr(Nbin)
    Mod4_Err = FltArr(Nbin)
    Mod6_Err = FltArr(Nbin)
    Mod7_Err = FltArr(Nbin)
    Mod9_Err = FltArr(Nbin)
    Mod10_Err = FltArr(Nbin)

    Mod11_Err = FltArr(Nbin)
    Mod12_Err = FltArr(Nbin)
    Mod13_Err = FltArr(Nbin)
    Mod14_Err = FltArr(Nbin)
    Mod17_Err = FltArr(Nbin)
    Mod18_Err = FltArr(Nbin)
    Mod19_Err = FltArr(Nbin)
    Mod20_Err = FltArr(Nbin)

    Mod21_Err = FltArr(Nbin)
    Mod22_Err = FltArr(Nbin)
    Mod24_Err = FltArr(Nbin)
    Mod25_Err = FltArr(Nbin)
    Mod27_Err = FltArr(Nbin)
    Mod28_Err = FltArr(Nbin)
    Mod29_Err = FltArr(Nbin)
    Mod31_Err = FltArr(Nbin)

    For i = 0, Nbin-1 do begin

      ;Mod0
      TempArr = TempMod_0_Boot[*,i]
      Mod0_Arr[i] = Avg(TempArr)
      Mod0_Err[i] = Stddev(TempArr)

      ;Mod2
      TempArr = TempMod_2_Boot[*,i]
      Mod2_Arr[i] = Avg(TempArr)
      Mod2_Err[i] = Stddev(TempArr)

      ;Mod3
      TempArr = TempMod_3_Boot[*,i]
      Mod3_Arr[i] = Avg(TempArr)
      Mod3_Err[i] = Stddev(TempArr)

      ;Mod4
      TempArr = TempMod_4_Boot[*,i]
      Mod4_Arr[i] = Avg(TempArr)
      Mod4_Err[i] = Stddev(TempArr)

      ;Mod6
      TempArr = TempMod_6_Boot[*,i]
      Mod6_Arr[i] = Avg(TempArr)
      Mod6_Err[i] = Stddev(TempArr)

      ;Mod7
      TempArr = TempMod_7_Boot[*,i]
      Mod7_Arr[i] = Avg(TempArr)
      Mod7_Err[i] = Stddev(TempArr)

      ;Mod9
      TempArr = TempMod_9_Boot[*,i]
      Mod9_Arr[i] = Avg(TempArr)
      Mod9_Err[i] = Stddev(TempArr)

      ;Mod10
      TempArr = TempMod_10_Boot[*,i]
      Mod10_Arr[i] = Avg(TempArr)
      Mod10_Err[i] = Stddev(TempArr)

      ;Mod11
      TempArr = TempMod_11_Boot[*,i]
      Mod11_Arr[i] = Avg(TempArr)
      Mod11_Err[i] = Stddev(TempArr)

      ;Mod12
      TempArr = TempMod_12_Boot[*,i]
      Mod12_Arr[i] = Avg(TempArr)
      Mod12_Err[i] = Stddev(TempArr)

      ;Mod13
      TempArr = TempMod_13_Boot[*,i]
      Mod13_Arr[i] = Avg(TempArr)
      Mod13_Err[i] = Stddev(TempArr)

      ;Mod14
      TempArr = TempMod_14_Boot[*,i]
      Mod14_Arr[i] = Avg(TempArr)
      Mod14_Err[i] = Stddev(TempArr)

      ;Mod17
      TempArr = TempMod_17_Boot[*,i]
      Mod17_Arr[i] = Avg(TempArr)
      Mod17_Err[i] = Stddev(TempArr)

      ;Mod18
      TempArr = TempMod_18_Boot[*,i]
      Mod18_Arr[i] = Avg(TempArr)
      Mod18_Err[i] = Stddev(TempArr)

      ;Mod19
      TempArr = TempMod_19_Boot[*,i]
      Mod19_Arr[i] = Avg(TempArr)
      Mod19_Err[i] = Stddev(TempArr)

      ;Mod20
      TempArr = TempMod_20_Boot[*,i]
      Mod20_Arr[i] = Avg(TempArr)
      Mod20_Err[i] = Stddev(TempArr)

      ;Mod21
      TempArr = TempMod_21_Boot[*,i]
      Mod21_Arr[i] = Avg(TempArr)
      Mod21_Err[i] = Stddev(TempArr)

      ;Mod22
      TempArr = TempMod_22_Boot[*,i]
      Mod22_Arr[i] = Avg(TempArr)
      Mod22_Err[i] = Stddev(TempArr)

      ;Mod24
      TempArr = TempMod_24_Boot[*,i]
      Mod24_Arr[i] = Avg(TempArr)
      Mod24_Err[i] = Stddev(TempArr)

      ;Mod25
      TempArr = TempMod_25_Boot[*,i]
      Mod25_Arr[i] = Avg(TempArr)
      Mod25_Err[i] = Stddev(TempArr)

      ;Mod27
      TempArr = TempMod_27_Boot[*,i]
      Mod27_Arr[i] = Avg(TempArr)
      Mod27_Err[i] = Stddev(TempArr)

      ;Mod28
      TempArr = TempMod_28_Boot[*,i]
      Mod28_Arr[i] = Avg(TempArr)
      Mod28_Err[i] = Stddev(TempArr)

      ;Mod29
      TempArr = TempMod_29_Boot[*,i]
      Mod29_Arr[i] = Avg(TempArr)
      Mod29_Err[i] = Stddev(TempArr)

      ;Mod31
      TempArr = TempMod_31_Boot[*,i]
      Mod31_Arr[i] = Avg(TempArr)
      Mod31_Err[i] = Stddev(TempArr)

    EndFor



    ; == Scale/Normalize to c/s and Add ==
    time_Diff = 720

    ;
    ; === Average Live Time ====
    ;
    AvgLT_Arr = dblArr(32)
    for j = 0,31 do if lt_count[j] ne 0 then  AvgLT_arr[j] = lt_array[j]/lt_count[j]

    ;=== Errors ===
    Temp_EnerErr = Sqrt(Abs( Temp_EnerArr )) ; /older.. wrong
    Temp_EnerERr_2_root = Sqrt(Temp_EnerERr_2) ; proper translation

    ;= Cant do in a loop as the arrays are not in an array.
    EnerArr = FltArr(NBin)
    EnerERr = FltArr(NBin)

    ;--Mod0--
    If AvgLt_Arr[0] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod0_Arr/(AvgLT_Arr[0]*Time_Diff)
    If AvgLt_Arr[0] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod0_Err/(AvgLT_Arr[0]*Time_Diff))*Mod0_Err/(AvgLT_Arr[0]*Time_Diff) )

    ;--Mod2--
    If AvgLt_Arr[2] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod2_Arr/(AvgLT_Arr[2]*Time_Diff)
    If AvgLt_Arr[2] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod2_Err/(AvgLT_Arr[2]*Time_Diff))*Mod2_Err/(AvgLT_Arr[2]*Time_Diff) )

    ;--Mod3--
    If AvgLt_Arr[3] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod3_Arr/(AvgLT_Arr[3]*Time_Diff)
    If AvgLt_Arr[3] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod3_Err/(AvgLT_Arr[3]*Time_Diff))*Mod3_Err/(AvgLT_Arr[3]*Time_Diff) )

    ;--Mod4--
    If AvgLt_Arr[4] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod4_Arr/(AvgLT_Arr[4]*Time_Diff)
    If AvgLt_Arr[4] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod4_Err/(AvgLT_Arr[4]*Time_Diff))*Mod4_Err/(AvgLT_Arr[4]*Time_Diff) )

    ;--Mod6--
    If AvgLt_Arr[6] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod6_Arr/(AvgLT_Arr[6]*Time_Diff)
    If AvgLt_Arr[6] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod6_Err/(AvgLT_Arr[6]*Time_Diff))*Mod6_Err/(AvgLT_Arr[6]*Time_Diff) )

    ;--Mod7--
    If AvgLt_Arr[7] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod7_Arr/(AvgLT_Arr[7]*Time_Diff)
    If AvgLt_Arr[7] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod7_Err/(AvgLT_Arr[7]*Time_Diff))*Mod7_Err/(AvgLT_Arr[7]*Time_Diff) )

    ;--Mod9--
    If AvgLt_Arr[9] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod9_Arr/(AvgLT_Arr[9]*Time_Diff)
    If AvgLt_Arr[9] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod9_Err/(AvgLT_Arr[9]*Time_Diff))*Mod9_Err/(AvgLT_Arr[9]*Time_Diff) )

    ;--Mod10--
    If AvgLt_Arr[10] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod10_Arr/(AvgLT_Arr[10]*Time_Diff)
    If AvgLt_Arr[10] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod10_Err/(AvgLT_Arr[10]*Time_Diff))*Mod10_Err/(AvgLT_Arr[10]*Time_Diff) )

    ;--Mod11--
    If AvgLt_Arr[11] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod11_Arr/(AvgLT_Arr[11]*Time_Diff)
    If AvgLt_Arr[11] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod11_Err/(AvgLT_Arr[11]*Time_Diff))*Mod11_Err/(AvgLT_Arr[11]*Time_Diff) )

    ;--Mod12--
    If AvgLt_Arr[12] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod12_Arr/(AvgLT_Arr[12]*Time_Diff)
    If AvgLt_Arr[12] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod12_Err/(AvgLT_Arr[12]*Time_Diff))*Mod12_Err/(AvgLT_Arr[12]*Time_Diff) )

    ;--Mod13--
    If AvgLt_Arr[13] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod13_Arr/(AvgLT_Arr[13]*Time_Diff)
    If AvgLt_Arr[13] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod13_Err/(AvgLT_Arr[13]*Time_Diff))*Mod13_Err/(AvgLT_Arr[13]*Time_Diff) )

    ;--Mod14--
    If AvgLt_Arr[14] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod14_Arr/(AvgLT_Arr[14]*Time_Diff)
    If AvgLt_Arr[14] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod14_Err/(AvgLT_Arr[14]*Time_Diff))*Mod14_Err/(AvgLT_Arr[14]*Time_Diff) )

    ;--Mod17--
    If AvgLt_Arr[17] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod17_Arr/(AvgLT_Arr[17]*Time_Diff)
    If AvgLt_Arr[17] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod17_Err/(AvgLT_Arr[17]*Time_Diff))*Mod17_Err/(AvgLT_Arr[17]*Time_Diff) )

    ;--Mod18--
    If AvgLt_Arr[18] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod18_Arr/(AvgLT_Arr[18]*Time_Diff)
    If AvgLt_Arr[18] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod18_Err/(AvgLT_Arr[18]*Time_Diff))*Mod18_Err/(AvgLT_Arr[18]*Time_Diff) )

    ;--Mod19--
    If AvgLt_Arr[19] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod19_Arr/(AvgLT_Arr[19]*Time_Diff)
    If AvgLt_Arr[19] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod19_Err/(AvgLT_Arr[19]*Time_Diff))*Mod19_Err/(AvgLT_Arr[19]*Time_Diff) )

    ;--Mod20--
    If AvgLt_Arr[20] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod20_Arr/(AvgLT_Arr[20]*Time_Diff)
    If AvgLt_Arr[20] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod20_Err/(AvgLT_Arr[20]*Time_Diff))*Mod20_Err/(AvgLT_Arr[20]*Time_Diff) )

    ;--Mod21--
    If AvgLt_Arr[21] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod21_Arr/(AvgLT_Arr[21]*Time_Diff)
    If AvgLt_Arr[21] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod21_Err/(AvgLT_Arr[21]*Time_Diff))*Mod21_Err/(AvgLT_Arr[21]*Time_Diff) )

    ;--Mod22--
    If AvgLt_Arr[22] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod22_Arr/(AvgLT_Arr[22]*Time_Diff)
    If AvgLt_Arr[22] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod22_Err/(AvgLT_Arr[22]*Time_Diff))*Mod22_Err/(AvgLT_Arr[22]*Time_Diff) )

    ;--Mod24--
    If AvgLt_Arr[24] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod24_Arr/(AvgLT_Arr[24]*Time_Diff)
    If AvgLt_Arr[24] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod24_Err/(AvgLT_Arr[24]*Time_Diff))*Mod24_Err/(AvgLT_Arr[24]*Time_Diff) )

    ;--Mod25--
    If AvgLt_Arr[25] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod25_Arr/(AvgLT_Arr[25]*Time_Diff)
    If AvgLt_Arr[25] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod25_Err/(AvgLT_Arr[25]*Time_Diff))*Mod25_Err/(AvgLT_Arr[25]*Time_Diff) )

    ;--Mod27--
    If AvgLt_Arr[27] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod27_Arr/(AvgLT_Arr[27]*Time_Diff)
    If AvgLt_Arr[27] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod27_Err/(AvgLT_Arr[27]*Time_Diff))*Mod27_Err/(AvgLT_Arr[27]*Time_Diff) )

    ;--Mod28--
    If AvgLt_Arr[28] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod28_Arr/(AvgLT_Arr[28]*Time_Diff)
    If AvgLt_Arr[28] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod28_Err/(AvgLT_Arr[28]*Time_Diff))*Mod28_Err/(AvgLT_Arr[28]*Time_Diff) )

    ;--Mod29--
    If AvgLt_Arr[29] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod29_Arr/(AvgLT_Arr[29]*Time_Diff)
    If AvgLt_Arr[29] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod29_Err/(AvgLT_Arr[29]*Time_Diff))*Mod29_Err/(AvgLT_Arr[29]*Time_Diff) )

    ;--Mod31--
    If AvgLt_Arr[31] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Mod31_Arr/(AvgLT_Arr[31]*Time_Diff)
    If AvgLt_Arr[31] EQ 0.0 Then EnerErr = EnerERr Else EnerErr= EnerErr+((Mod31_Err/(AvgLT_Arr[31]*Time_Diff))*Mod31_Err/(AvgLT_Arr[31]*Time_Diff) )

    ; With the binning issue. we have nbin-2 as the last bin was empty.
    EnerErr= Sqrt(EnerErr)
    For i = 0, NBin-1 Do Begin
      PRintf, lun102, Ebin_lo[i], Ebin_hi[i], EnerArr[i], EnerErr[i]
    EndFor

    Free_lun, lun102
  EndFor; /p

  Stop
End