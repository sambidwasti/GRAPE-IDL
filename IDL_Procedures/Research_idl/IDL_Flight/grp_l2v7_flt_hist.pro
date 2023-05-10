Pro Grp_L2v7_Flt_Hist, fsearch_String, Title= Title, Type=Type, Class = Class, Sep = Sep, Bin=bin

  ; Child of Grp_l2v7_Flt_investigate4
  ; This is to just generate a histogramfile of lvl2v7 file
  ; Mainly created to deal with ground process.
  ;   Few Assumptions: 
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
  close, /all
  If keyword_set(bin) eq 0 then bin = 5 ; Binsize

  Class=3
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
    Free_lun, lun

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


      If EvtClass NE Class Then goto, Jump_Packet ;

      m = data.Pa_Mod


      ;
      ;== Live time ==
      ;
      LiveTime = Data.CorrectLT
      LT_Array[m] = LT_Array[m]+LiveTime
      LT_Count[m]++

      ;
      ;-- This is for the PC all histogram
      ;
      Temp_EnerArr[Tot_Nrg,m]++




      Jump_Packet:
      If i mod 100000 EQ 0 Then print, i
    EndFor; /i

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
    Temp_EnerErr = Sqrt(Abs( Temp_EnerArr ))
    ;
    ;== Need to normalize and add them each file at a time, for each module.
    ;
    For j = 0,31 Do Begin
      If (where (j EQ c2014) GE 0) Then Begin
        Temp_arr = Temp_EnerArr[*,j]
        Temp_err = Temp_EnerErr[*,j]

        If AvgLt_Arr[j] EQ 0.0 Then EnerArr = EnerArr Else EnerArr= EnerArr+Temp_Arr/(AvgLT_Arr[j]*Time_Diff)
        If AvgLt_Arr[j] EQ 0.0 Then EnerErr =EnerERr Else EnerErr= EnerErr+((Temp_Err/(AvgLT_Arr[j]*Time_Diff))*Temp_Err/(AvgLT_Arr[j]*Time_Diff) )

      
      EndIf
    EndFor

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
  xmax=150
  ymin= 0.003
  ymax=0.2
  ;
  ; Page 1: Flight vs gamma
  ;
print, flight2
  Cgplot, Xval2,Flight2, PSYM=10, XRANGE=[Xmin,Xmax],Xstyle=1, $; /Xlog,/Ylog, YStyle=1,$;
    title=ptitle, xtitle=xtitle, ytitle=ytitle,$;linestyle=1, $
    err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color='black',Err_Width=er_wid,$
    err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1


  CgPs_Close

  ;-- Create the PDF File
  Temp_Str = Cur+'/'+Title+'_FltHist.ps'
  CGPS2PDF, Temp_Str,delete_ps=1, UNIX_CONVERT_CMD='pstopdf'

  Stop
End