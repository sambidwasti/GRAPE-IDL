function Grp_l2v7_PCA_rate_Gen_1_debug, fsearch_String, Emin = Emin, Emax = Emax, nfiles=nfiles

  ; This is to generate a rate input for a specific energy range for the pca.
  ;
  ;

  True = 1
  False= 0

  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 10.0
  Pla_EMax = 200.00

  Cal_EMin = 40.0
  Cal_EMax = 400.00

  ;
  IF Keyword_Set(Emin) Eq 0 Then Tot_EMin = 50.00 else Tot_Emin=Emin
  IF Keyword_Set(Emax) Eq 0 Then Tot_Emax = 300.00 Else Tot_Emax= Emax

  Class = 3 ; For PC



  Print,'-----------'
  Print,'Energy Range'
  Print, Tot_EMin
  Print, Tot_EMax
  Print, Cal_Emin
  Print, Pla_Emin
  Print,'-----------'

  ; ************* STANDARD INITIATIONS ******************
  Cd, Cur=Cur
  IF Keyword_Set(title) Eq 0 Then Title='Test'


  ;
  ;******************STANDARD FILTERING AND PROCESSING*********************
  ;
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
  Sum_Sweep = [0]
  ;**************************** STANDARD INITIATION **************************

  Out_Struc = { $
    Swp :0,$
    Rate : 0.0, $
    Err : 0.0}
  Out_Struc = Replicate(OUt_Struc,nfiles)
  ;******* Procedure Specific *************

  LT_Array = DblArr(32)
  LT_Count = DblArr(32)

  Sum_Count = [0.0D]
  Sum_Count_Err = [0.0D]
  
  Openw,lun101, 'rate_gen1_debug.txt',/get_lun


  ; ******* Standard Each File ************
  For p = 0, nfiles-1 Do Begin ; open each file
    ;-- No. of Events Counter --
    No_Events = 0L

    ;
    ;-- Few Values --
    ;
    ;    Total_Altitude = 0.0D
    ;    Total_Zenith   = 0.0D
    ;    Total_Depth    = 0.0D
    ;    Total_LT       = 0.0D
    ;    Total_Azimuth  = 0.0D

    End_Swp_Flag = False    ; Need this to make sure we are not wasting time in the end of file.

    ;
    ;---- Each file
    ;
    fname = evtfiles[p]
    printf, lun101, fname
    ;
    ;--- Grab some file info
    ;
    f = file_info(fname)

    ;
    ;--- Open the binary file and dump it in Data and Close the file.
    ;
    Openr, lun, fname, /GET_Lun

    ;
    ;--- Grab total no. of packets
    ;
    TotPkt = long(f.size/Packet_Len)

    ;
    ;--- Replicate the structure for each packets.
    ;
    Event_data = replicate(Struc, TotPkt)
    ;
    ;---- Grab all the event data all at once.----
    ;
    For i = 0, TotPkt-1 Do Begin
      readu, lun, Struc        ; read one event
      Event_data[i] =Struc        ; add it to input array
    EndFor

    ;
    ;--- Free Lun ----
    ;
    Free_Lun, lun


    ;
    ;--- For Each Packet ---
    ;
    For i = 0, TotPkt-1 Do Begin
      data = event_Data[i]
      ;       if data.EvClass Eq 2 then begin
      ;        print, data.Qflag , 'ok', i, data.totNrg
      ;       endif
      ;
      ; == Time ==
      ;
      Time = data.EvTime             ; Time

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

      ;
      ; Reclassified so additional filters.
      ;

      If (Tot_Nrg LT Tot_Emin) OR  (TOt_NRg GT Tot_EMax) Then goto, Jump_Packet
      If EvtClass NE Class Then goto, Jump_Packet ;

      m = data.Pa_Mod


      ;
      ;== Live time ==
      ;
      LiveTime = Data.CorrectLT
      LT_Array[m] = LT_Array[m]+LiveTime
      LT_Count[m]++


      Jump_Packet:
      If i mod 100000 EQ 0 Then print, i
    EndFor; /i


    Tot_Count = 0.0D
    Tot_Count_Er = 0.0D
    Temp_Err_Val = 0.0D
    ;
    ;-- We do this for each of the module position --
    ;
    Time_diff = 720.00

    Temp_Cnt   = 0.0D


    ;
    ; === Average Live Time ====
    ;
    AvgLT_Arr = dblArr(32)
    for j = 0,31 do if lt_count[j] ne 0 then  AvgLT_arr[j] = lt_array[j]/lt_count[j]
    Print, AvgLT_Arr
    EnerArr = 0.0D
    EnerERr = 0.0D
    ;
    ;=== Errors ===
    ;
    ;   Temp_EnerErr = Sqrt(Abs( Temp_EnerArr ))
    ;
    ;== Need to normalize and add them each file at a time, for each module.
    ;
    
    
    printf, lun101, 'mod', 'SclFact', ' ', 'Counts',' ','Err'

    For j = 0,31 Do Begin
      If (where (j EQ c2014) GE 0) Then Begin
        Temp_arr = lt_Count[j]
        Temp_Err = Sqrt(Temp_arr)
        Printf, lun101, j, AvgLT_arr[j]*Time_Diff, ' ',Temp_arr, ' ', Temp_Err
        
        If AvgLt_Arr[j] NE 0.0 Then EnerArr = EnerArr+Temp_Arr/(AvgLT_Arr[j]*Time_Diff)
        If AvgLt_Arr[j] NE 0.0 Then EnerErr = EnerErr+( (Temp_Err/(AvgLT_Arr[j]*Time_Diff))*(Temp_Err/(AvgLT_Arr[j]*Time_Diff)) )


      EndIf
    EndFor


    ; Error propagation.. one multiplication and then adding in quadrature.
    Tot_Count_Err = Sqrt(EnerErr)
    
    Printf,lun101, 'Tot Count', EnerArr
    Printf,lun101, 'Tot Err Sq', EnerErr
    Printf,lun101, 'TOt Err', Tot_Count_Err
    ;;

    Sum_Count = [SUm_Count,EnerArr]
    Sum_Count_Err=[Sum_Count_Err, Tot_Count_Err]
    Swpno = Event_Data[1].Sweepno
    Sum_Sweep = [Sum_Sweep, Swpno]
    ;Print, Tot_Count

    ;
    ;=== Statistic Stuffs ====
    ;

    For j =0, 31 Do Begin
      LT_Array[j]=0.0D
      LT_COunt[j]=0.0D
    EndFor

    Tot_Count = 0.0D

    Print, Event_Data[i-1].SweepNo
  EndFor; /p For file

  Free_lun, Lun101
  ;
  ;-- Trim these arrays for removal for the 1st value--
  ; Not scaling to files
  ;
  for i = 1, n_elements(Sum_Count)-1 Do Begin

    Out_Struc[i-1].swp = Sum_Sweep[i]
    Out_Struc[i-1].Rate= Sum_Count[i]
    Out_Struc[i-1].Err = Sum_Count_err[i]

  Endfor

  
  return, Out_Struc
  ;
  ;  Openw, Lun1, Cur+'/'+Title+'_flt_rate.txt',/Get_Lun
  ;  Printf,lun1, 'Erange = '+Strn(Tot_Emin)+'  '+Strn(Tot_EMax)
  ;  Printf,lun1, 'Sweep     Count    CountErr'
  ;  For i=1,  N_Elements(Sum_Count)-1 Do Begin
  ;    Printf, Lun1, Sum_Sweep[i],Sum_Count[i], Sum_Count_Err[i],$
  ;      format = '(I4,1X,  1X,F8.2, 1X, F8.4 )'
  ;  Endfor
  ;  Free_Lun, Lun1


End