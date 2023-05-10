Pro Grp_Flt_Bootstrap_inv3, fsearch_String,Title= Title, Type=Type, Class = Class, Sep = Sep, BootNo = BootNo

;Ay me matey Captain Bootstrap
;Currently : Read in each file
;     Read each event and create a pseudo histogram for each module
;     Scale (Time wise)each of the histogram and add overall
;     Add for each files.
;     
;     Bootstrap.. Only change till histogram process then do the same stuffs.
;     Slightly Different way. 
;     Since we have arrays depending on the modules,
;     We have 24 Buckets. 
;       - From these 24 Buckets, we bootstrap the events
;       - Build the spect, scale and add. 
;       - This is done 1 Bootstrap per 24 buckets to make 1 main hist.
;       
;     For more than 1 file, just keep increasing the array and averaging the lt. 
;     
;     Also changing that we directly get a bin 10 array
;

  bin =10

  True = 1
  False= 0

  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 10.0
  Pla_EMax = 200.00

  Cal_EMin = 40.0
  Cal_EMax = 400.00

  Tot_EMin = 50.00
  Tot_EMax = 600.00

  bsize = 10

  Print,'-----------'
  Print, Pla_Emin
  Print, Tot_EMin
  Print, Tot_EMax
  Print,'-----------'

  Altitude = 131.5D

  PMax= 1500 ; Max value of energy for energy histogram.
  Cd, Cur=Cur

  IF Keyword_Set(title) Eq 0 Then Title='Test'
  IF Keyword_Set(Class) Eq 0 Then Class = 3
  If Keyword_Set(BOOTNO) NE 0 Then Boot_No = BootNO Else Boot_No = 100L
  If Keyword_Set(Type) NE 0 Then Type_Flag =1 else Type_Flag=0

  If (Class Lt 1) or (Class Gt 3) Then Class = 7
  ;
  ;For output file.
  ;
  IF Class Eq 3 then Evt_Text = 'PC' Else IF Class Eq 2 then Evt_Text = 'CC' Else If Class Eq 1 Then Evt_Text = 'C' Else Evt_Text = 'Other'

  Print, 'CLASS: ',Class,Evt_Text

  If (Class NE 3) and (Class NE 2) Then Type_Flag = False  ; Fail Safe for Type Flag
  If Type_Flag Gt 4 Then Type_Flag = False
  If Type_flag Eq True then Sel_Type = Type Else SEl_TYpe=0

  Sep_Flag = False
  If keyword_set(Sep) ne 0 then Sep_Flag =True
  If (class NE 3) and (Class NE 2) Then Sep_Flag = False ; Fail Safe for Sep_Flags

  IF Sep_Flag eq true then Sep = Sep else sep = 0

  Print, Type_Flag, Class, Sep_Flag
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
  EnerArr1 = DblArr(1000)
  EnerArr2 = DblArr(1000)
  EnerArr3 = DblArr(1000)
  EnerArr4 = DblARr(1000)

  EnerErr = DblArr(1000)
  EnerErr1= DblArr(1000)
  EnerErr2= DblArr(1000)
  EnerErr3= DblArr(1000)
  EnerErr4= DblArr(1000)



  TEner_Arr = [0.0D]
  TEner_Arr0 = [0.0D]
;  TEner_Arr1 = [0.0D]
;  TEner_Arr2 = [0.0D]
;  TEner_Arr3 = [0.0D]
;  TEner_Arr4 = [0.0D]
;  TEner_Arr5 = [0.0D]
;  TEner_Arr6 = [0.0D]
;  TEner_Arr7 = [0.0D]
;  TEner_Arr8 = [0.0D]
;  TEner_Arr9 = [0.0D]
;  TEner_Arr10 = [0.0D]
;  TEner_Arr11 = [0.0D]
;  TEner_Arr12 = [0.0D]
;  TEner_Arr13 = [0.0D]
;  TEner_Arr14 = [0.0D]
;  TEner_Arr15 = [0.0D]
;  TEner_Arr16 = [0.0D]
;  TEner_Arr17 = [0.0D]
;  TEner_Arr18 = [0.0D]
;  TEner_Arr19 = [0.0D]
;  TEner_Arr20 = [0.0D]
;  TEner_Arr21 = [0.0D]
;  TEner_Arr22 = [0.0D]
;  TEner_Arr23 = [0.0D]
;  TEner_Arr24 = [0.0D]
;  TEner_Arr25 = [0.0D]
;  TEner_Arr26 = [0.0D]
;  TEner_Arr27 = [0.0D]
;  TEner_Arr28 = [0.0D]
;  TEner_Arr29 = [0.0D]
;  TEner_Arr30 = [0.0D]
;  TEner_Arr31 = [0.0D]
  
    LiveT_Array = DblArr(32)
    LiveT_Count = DblArr(32) 
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

    LT_Array = DblArr(32)
    LT_Count = DblArr(32)
    A =0  ; First Time Stamp

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
        if P  eq 0 then B_old_Time = Time
      Endif
      A=1
      Time_Diff = Time - Old_Time

      ;
      ;== Necessary Filters.==
      ;
      If (data.totNrg ge 1000) or (data.totNrg le 0) then goto, jump_Packet
      If Data.Qflag LT 0 Then goto, Jump_Packet
      If Data.ACflag EQ 1 Then Goto, Jump_Packet

      NewAnodeId = [0]
      NewanodeNrg= [0.0]
      NewAnodeTyp= [0]
      NOCal = 0
      NoPla = 0

      ;      Print, data.nanodes
      ;
      ;== Applying the software Thresholds ==
      ;
      for j = 0, Data.Nanodes-1 Do Begin
        If data.anodetyp[j] EQ 1 Then Begin    ; Its a Plastic so check these
          If (data.AnodeNRG[j] LT Pla_EMIN) or (data.AnodeNRG[j] GT Pla_EMAX) Then Goto, Jump_anode
          NewANodeID = [NewAnodeId,data.anodeid[j]]
          NewAnodeNrg= [NewAnodeNrg,data.anodenrg[j]]
          NewAnodeTyp= [NewAnodeTyp,data.anodetyp[j]]
          NOPla++
        EndIf Else If  data.AnodeTyp[j] EQ 2 Then Begin    ; cal
          If (data.AnodeNRG[j]LT Cal_EMIN) or (data.AnodeNRG[j] GT Cal_EMAX) Then Goto, Jump_anode
          NewANodeID = [NewAnodeId,data.anodeid[j]]
          NewAnodeNrg= [NewAnodeNrg,data.anodenrg[j]]
          NewAnodeTyp= [NewAnodeTyp,data.anodetyp[j]]
          NOCal++
        EndIf
        jump_anode:
      endfor
      If N_Elements(newAnodeId) eq 1 then goto, JUmp_Packet
      NewANodeID = NewAnodeId[1:N_elements(NewAnodeID)-1]
      NewAnodeNrg= NewAnodeNrg[1:N_Elements(NewAnodeNrg)-1]
      NewAnodeTyp= NewAnodeTyp[1:N_Elements(NewAnodeTyp)-1]

      Tot_Nrg = Total(NewANodeNrg)


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
      
      ;
      ;== Boot Strapping ==
      ;
      LiveT_Array[m] = LiveT_Array[m]+LiveTime
      LiveT_Count[m]++
      

      ;
      ;-- This is for the PC all histogram
      ;
      Temp_EnerArr[Tot_Nrg,m]++
      
      
      ;
      ;For each of the modules, we have a different array
      ;
      ;
      Case m of 
        0: TEner_Arr0 = [TEner_Arr0,Tot_Nrg]
;        1: TEner_Arr1 = [TEner_Arr1,Tot_Nrg]
;        2: TEner_Arr2 = [TEner_Arr2,Tot_Nrg]
;        3: TEner_Arr3 = [TEner_Arr3,Tot_Nrg]
;        4: TEner_Arr4 = [TEner_Arr4,Tot_Nrg]
;        5: TEner_Arr5 = [TEner_Arr5,Tot_Nrg]
;        6: TEner_Arr6 = [TEner_Arr6,Tot_Nrg]
;        7: TEner_Arr7 = [TEner_Arr7,Tot_Nrg]
;        8: TEner_Arr8 = [TEner_Arr8,Tot_Nrg]
;        9: TEner_Arr9 = [TEner_Arr9,Tot_Nrg]
;        10: TEner_Arr10 = [TEner_Arr10,Tot_Nrg]
;        11: TEner_Arr11 = [TEner_Arr11,Tot_Nrg]
;        12: TEner_Arr12 = [TEner_Arr12,Tot_Nrg]
;        13: TEner_Arr13 = [TEner_Arr13,Tot_Nrg]
;        14: TEner_Arr14 = [TEner_Arr14,Tot_Nrg]
;        15: TEner_Arr15 = [TEner_Arr15,Tot_Nrg]
;        16: TEner_Arr16 = [TEner_Arr16,Tot_Nrg]
;        17: TEner_Arr17 = [TEner_Arr17,Tot_Nrg]
;        18: TEner_Arr18 = [TEner_Arr18,Tot_Nrg]
;        19: TEner_Arr19 = [TEner_Arr19,Tot_Nrg]
;        20: TEner_Arr20 = [TEner_Arr20,Tot_Nrg]
;        21: TEner_Arr21 = [TEner_Arr21,Tot_Nrg]
;        22: TEner_Arr22 = [TEner_Arr22,Tot_Nrg]
;        23: TEner_Arr23 = [TEner_Arr23,Tot_Nrg]
;        24: TEner_Arr24 = [TEner_Arr24,Tot_Nrg]
;        25: TEner_Arr25 = [TEner_Arr25,Tot_Nrg]
;        26: TEner_Arr26 = [TEner_Arr26,Tot_Nrg]
;        27: TEner_Arr27 = [TEner_Arr27,Tot_Nrg]
;        28: TEner_Arr28 = [TEner_Arr28,Tot_Nrg]
;        29: TEner_Arr29 = [TEner_Arr29,Tot_Nrg]
;        30: TEner_Arr30 = [TEner_Arr30,Tot_Nrg]
;        31: TEner_Arr31 = [TEner_Arr31,Tot_Nrg]
        Else: ;Print, 'Invalid module',m
        
      Endcase



      Jump_Packet:
      If i mod 100000 EQ 0 Then print, i
    EndFor; /i
;
;
;    TEner_ARR = TEner_Arr[1:N_Elements(TEner_Arr)-1]  ; Remove the first array values.
;     Arr_LEn = N_Elements(TEner_Arr)
;    
      
;        
;     EndFor
    
    ;
    ;Create the histogram and errors.
    ; 
 
    ; == Checks ==

    ; print, time_Diff

    ;
    ; === Average Live Time ====
    ;
    AvgLT_Arr = dblArr(32)
    for j = 0,31 do if lt_count[j] ne 0 then  AvgLT_arr[j] = lt_array[j]/lt_count[j]
    

    ;
    ;=== Errors ===
    ;
    Temp_EnerErr = Sqrt(Abs( Temp_EnerArr ))

    For j = 0,31 Do Begin
      If (where (j EQ c2014) GE 0) Then Begin
        Temp_arr = Temp_EnerArr[*,j]
        Temp_err = Temp_EnerErr[*,j]
 

        If AvgLt_Arr[j] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Temp_Arr/(AvgLT_Arr[j]*Time_Diff)
        If AvgLt_Arr[j] EQ 0.0 Then EnerErr =EnerERr Else EnerErr= EnerErr+((Temp_Err/(AvgLT_Arr[j]*Time_Diff))*Temp_Err/(AvgLT_Arr[j]*Time_Diff) )


      EndIf
    EndFor
;PRint, EnerErr
  EndFor; /p
;  Print, N_Elements(TEner_Arr0), N_Elements(TEner_Arr1), N_Elements(TEner_Arr2)
 ; Print, TEner_Arr0


       AvgLiveT_Arr = dblArr(32)
      for j = 0,31 do if livet_count[j] ne 0 then  AvgLiveT_arr[j] = livet_array[j]/livet_count[j] else AvgLiveT_arr[j]=0.0
;s      Print, AVgLiveT_Arr
      

      
      ; We are creating histogram from 0-1000 keV with binsize 10 so 100 of them. 
      ; We need Boot_No * 100 double array
      
      Boot_Histo_ARr = DblArr(Boot_No,100)
      Total_Time_Diff = Time-B_Old_Time
      ;For boot loop
      ; note time atm is just one file
      ;CREATING A BOOT STRAP ARRAY
      ; FIRST DEAL WITH   THE Buckets
            
;Help, TEner_Arr0
;Help, TEner_Arr1
;Help, TEner_Arr2
;Help, TEner_Arr3
;Help, TEner_Arr5
;Help, TEner_Arr4
;Help, TEner_Arr6
;Help, TEner_Arr7
;Help, TEner_Arr8
;Help, TEner_Arr9
;Help, TEner_Arr10
;Help, TEner_Arr11
;Help, TEner_Arr12
;Help, TEner_Arr13
;Help, TEner_Arr15
;Help, TEner_Arr14
;Help, TEner_Arr16
;Help, TEner_Arr17
;Help, TEner_Arr18
;Help, TEner_Arr19
;Help, TEner_Arr20


TEner_Arr0 = TEner_Arr0[1:N_Elements(TEner_Arr0)-1]
;TEner_Arr2 = TEner_Arr2[1:N_Elements(TEner_Arr2)-1]
;TEner_Arr3 = TEner_Arr3[1:N_Elements(TEner_Arr3)-1]
;TEner_Arr4 = TEner_Arr4[1:N_Elements(TEner_Arr4)-1]
;TEner_Arr6 = TEner_Arr6[1:N_Elements(TEner_Arr6)-1]
;TEner_Arr7 = TEner_Arr7[1:N_Elements(TEner_Arr7)-1]
;TEner_Arr9 = TEner_Arr9[1:N_Elements(TEner_Arr9)-1]
;TEner_Arr10 = TEner_Arr10[1:N_Elements(TEner_Arr10)-1]
;TEner_Arr11 = TEner_Arr11[1:N_Elements(TEner_Arr11)-1]
;TEner_Arr12 = TEner_Arr12[1:N_Elements(TEner_Arr12)-1]
;TEner_Arr13 = TEner_Arr13[1:N_Elements(TEner_Arr13)-1]
;TEner_Arr14 = TEner_Arr14[1:N_Elements(TEner_Arr14)-1]
;TEner_Arr17 = TEner_Arr17[1:N_Elements(TEner_Arr17)-1]
;TEner_Arr18 = TEner_Arr18[1:N_Elements(TEner_Arr18)-1]
;TEner_Arr19 = TEner_Arr19[1:N_Elements(TEner_Arr19)-1]
;TEner_Arr20 = TEner_Arr20[1:N_Elements(TEner_Arr20)-1]
;TEner_Arr21 = TEner_Arr21[1:N_Elements(TEner_Arr21)-1]
;TEner_Arr22 = TEner_Arr22[1:N_Elements(TEner_Arr22)-1]
;TEner_Arr24 = TEner_Arr24[1:N_Elements(TEner_Arr24)-1]
;TEner_Arr25 = TEner_Arr25[1:N_Elements(TEner_Arr25)-1]
;TEner_Arr27 = TEner_Arr27[1:N_Elements(TEner_Arr27)-1]
;TEner_Arr29 = TEner_Arr29[1:N_Elements(TEner_Arr29)-1]
;TEner_Arr28 = TEner_Arr28[1:N_Elements(TEner_Arr28)-1]
;TEner_Arr31 = TEner_Arr31[1:N_Elements(TEner_Arr31)-1]


;
;=== BootStrapping === Arrr!!
;
      For z = 0, Boot_No-1 Do begin     
            ; For each of the 24 buckets.
            ; Need to randomly choose events from the Bin. 
            ; Create a spect. (add)
            ; NOrmalize
            ; Add
            
            TempB_Hist = DblArr(32,100)
       
            ; Module 0     
            Arr_Size = N_Elements(TEner_Arr0)
            TempB_Arr = DblArr(Arr_Size)
            For i = 0, Arr_Size-1 Do Begin
                RanLoc = Fix( Randomu(seed,1)*Arr_Size)
                TempB_ARr[i] = TEner_Arr0[RanLoc]
            Endfor
            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
            AvgLtB_Arr = AvgLiveT_Arr[0]
            TempB_Hist[0,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;            ; Module 2
;            Arr_Size = N_Elements(TEner_Arr2)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr2[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[2]
;            TempB_Hist[2,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;         
;            ; Module 3
;            Arr_Size = N_Elements(TEner_Arr3)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr3[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[3]
;            TempB_Hist[3,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;         
;            ; Module 4
;            Arr_Size = N_Elements(TEner_Arr4)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr4[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[4]
;            TempB_Hist[4,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;            
;            ; Module 6
;            Arr_Size = N_Elements(TEner_Arr6)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr6[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[6]
;            TempB_Hist[6,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;            ; Module 7
;            Arr_Size = N_Elements(TEner_Arr7)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr7[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[7]
;            TempB_Hist[7,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;            ; Module 9
;            Arr_Size = N_Elements(TEner_Arr9)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr9[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[9]
;            TempB_Hist[9,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;            ; Module 10
;
;            Arr_Size = N_Elements(TEner_Arr10)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr10[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[10]
;            TempB_Hist[10,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;            ; Module 11
;            Arr_Size = N_Elements(TEner_Arr11)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr11[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[11]
;            TempB_Hist[11,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;            
;            ; Module 12
;            Arr_Size = N_Elements(TEner_Arr12)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr12[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[12]
;            TempB_Hist[12,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;            Arr_Size = N_Elements(TEner_Arr13)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr13[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[13]
;            TempB_Hist[13,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;            
;            ;14
;            Arr_Size = N_Elements(TEner_Arr14)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr14[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[14]
;            TempB_Hist[14,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;
;            ;17
;            Arr_Size = N_Elements(TEner_Arr17)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr17[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[17]
;            TempB_Hist[17,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;            
;            ;18
;            Arr_Size = N_Elements(TEner_Arr18)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr18[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[18]
;            TempB_Hist[18,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;            
;            ;19
;            Arr_Size = N_Elements(TEner_Arr19)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr19[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[19]
;            TempB_Hist[19,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;            ;20
;            Arr_Size = N_Elements(TEner_Arr20)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr20[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[20]
;            TempB_Hist[20,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;            ;21
;            Arr_Size = N_Elements(TEner_Arr21)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr21[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[21]
;            TempB_Hist[21,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;
;            ;22
;            Arr_Size = N_Elements(TEner_Arr22)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr22[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[22]
;            TempB_Hist[22,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;            ;24
;            Arr_Size = N_Elements(TEner_Arr24)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr24[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[24]
;            TempB_Hist[24,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;            
;
;            ;25
;            Arr_Size = N_Elements(TEner_Arr25)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr25[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[25]
;            TempB_Hist[25,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;            
;
;            ;27
;            Arr_Size = N_Elements(TEner_Arr27)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr27[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[27]
;            TempB_Hist[27,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;      
;
;            ;28
;            Arr_Size = N_Elements(TEner_Arr28)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr28[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[28]
;            TempB_Hist[28,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;
;
;            ;29
;            Arr_Size = N_Elements(TEner_Arr29)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr29[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[29]
;            TempB_Hist[29,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
;            
;            ;31
;            Arr_Size = N_Elements(TEner_Arr31)
;            TempB_Arr = DblArr(Arr_Size)
;            For i = 0, Arr_Size-1 Do Begin
;              RanLoc = Fix( Randomu(seed,1)*Arr_Size)
;              TempB_ARr[i] = TEner_Arr31[RanLoc]
;            Endfor
;            TempoB_Hist = (CGHistogram(TempB_ARr, BINSIZE=bin, Locations=XArray, MAX=999, MIN=0))/Double(bin)
;            AvgLtB_Arr = AvgLiveT_Arr[31]
;            TempB_Hist[31,*] = TempoB_Hist/(AvgLtB_Arr*Total_Time_Diff)
      
            ;-- Add the Normalized histogram to generate 1 bootstrap histogram and put it in boot-strap-array
            ;-- The empty ones dont matter as they are just 0.
;            Hist_Temp_0 = DblArr(100)
;            For i = 0,31 Do Begin
;                Hist_Temp_0 = Hist_Temp_0 + TempB_Hist[i,*]
;                ;Print, hist_temp_0
;            Endfor
            Hist_Temp_0 = TempB_Hist[0,*]
             Boot_Histo_ARr[z,*] = Hist_temp_0
       EndFor ; z

       ;-------------------
       ; WE HAVE AN ARRAY. 
       ; Get ERrors.
       
       B_Hist_ERr = DBlArr(100)
       For i = 0, 99 Do Begin
          Temp_Boot_Err_Arr = Boot_Histo_Arr[*,i]
          B_Hist_Err[i] = StdDev(Temp_Boot_Err_Arr,/Double)
       EndFor
       
       Temp100_err = (Boot_Histo_Arr[*,10])
       temp100_hist = CGHistogram(Temp100_err, Locations=XArray1)
       CgPlot, Xarray1, Temp100_Hist,Title='100keV Bootstrap ='+Strn(Boot_No)
       
       Print, Mean(Temp100_err)
       Print, StdDev(Temp100_err)


        ;===========================
       ;Flight Rebinning for Plotting
       Cntr=0L
 
       EnerArr = EnerArr/nfiles
       EnerErr = SQRT(EnerErr)/nfiles
       
       Flt = DblArr(100)
       Flt_Err = DblArr(100)
       
       for i = 0, 99 do begin
         tempFli   = 0.0

         tempFli_err   = 0.0
         for j = 0, bin-1 do begin
         ; print, Cntr
           tempFli   = tempfli   + EnerArr[cntr]
           tempFli_err   = tempFli_err   + EnerErr[cntr]*EnerErr[cntr]
           cntr++
         endfor

         Flt[i] = tempFli
         Flt_Err[i] = Sqrt(tempFli_Err)

       endfor ; i
        Flt = Flt/10.0D
        Flt_Err = Flt_Err/10.0D
     ;============
     Print, Flt[10], Flt_Err[10]
      stop
      ; Mod Pos: 0, 2, 3,4, 6,7,9,10,11 ,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31
;window,0
  ;CgPlot, Indgen(1000), EnerArr, color='red', psym=10
;Print, Flt_Err
;PRint, EnerERr
Window,2
CgPlot, XArray, Flt, PSYM=10, Color='Black', err_Yhigh=Flt_Err, Err_YLow =FLt_Err,/Err_Clip,Err_Color='Blue',$;,$
 Xrange = [0,500], Title='Mod0 Bootstrap ='+Strn(Boot_No),ERR_Thick=2
 ; /Ylog,/Xlog, XRange=[30,400], Yrange =[10E-8,2] 
  
  CgOPlot, Xarray, Flt, color='Black',psym=10,  err_Yhigh=B_Hist_Err, Err_YLow =B_Hist_Err,/Err_Clip,Err_Color='Red'
 
Window,0
NewArr = DblArr(100)
For i = 0, 99 do IF Flt_Err[i] LE 0.0 Then NewArr[i]=0.0 Else NewArr[i]=B_Hist_Err[i]/Flt_Err[i]
CgPlot, XArray, NewArr, Title='Mod0 Bootstrap ='+Strn(Boot_No), Xrange = [0,500]

 

;
End