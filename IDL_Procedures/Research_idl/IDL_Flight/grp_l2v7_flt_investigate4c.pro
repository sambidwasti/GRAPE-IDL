Pro Grp_L2v7_Flt_Investigate4c, fsearch_String, Title= Title, Type=Type, Class = Class, Sep = Sep, Bin=bin

  ;This is a variation of investigate4 file.
  ;This variation creates one energy loss spectra file for each file (sweep).
  ;This is all catered towards pha files
  ;9/10/2019
  ;       Adding lines to create an additional files for each sweep which are data files for fcreate in xspec
  ;       The data files for counts are in formats of E13.7 (This is scientific notation with 7 decimals)
  ;       Also changed the counts/s/kev to counts/s as the xpsec does per kev
  ;
  
  close, /all
  ;If keyword_set(bin) eq 0 then bin = 10 ; Binsize
 ; print, 'binsize =', bin
  Class=3
  ;

  Ebin_lo = [70,90 ,120,160,200]
  Ebin_hi = [90,120,160,200,300]

  True = 1
  False= 0

  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 10.0
  Pla_EMax = 200.00

  Cal_EMin = 40.0
  Cal_EMax = 400.00

  Tot_EMin = 60.00
  Tot_EMax = 300.00

;  Xlow_Cut = Fix(Tot_Emin/bin)
;  Xhigh_Cut = Fix(Tot_Emax/bin)-1
  Print,'-----------'
  Print, Pla_Emin
  Print, Cal_Emin
  Print, Tot_EMin
  Print, Tot_EMax
  Print,'-----------'

  Altitude = 131.5D

  Cd, Cur=Cur
  text_title1 ='_Grp2014_Crab_'
  text_title2 = '_Inves4c'
  IF Keyword_Set(title) Eq 0 Then Title='Test'
  IF Keyword_Set(Class) Eq 0 Then Class = 3

  If Keyword_Set(Type) NE 0 Then Type_Flag =1 else Type_Flag=0

  If (Class Lt 1) or (Class Gt 3) Then Class = 7
  ;
  ;For output file.
  ;
  IF Class Eq 3 then Evt_Text = 'PC' Else IF Class Eq 2 then Evt_Text = 'CC' Else If Class Eq 1 Then Evt_Text = 'C' Else Evt_Text = 'Other'
  ptitle = 'Energy-Loss Spec (Src+Bgd) PC'
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


  ;
  ;-- For Each File --
  ;
  For p = 0, nfiles-1 Do Begin ; open each file
    EnerArr = DblArr(1000)
    EnerErr = DblArr(1000)

    EnerVal = EnerVal
    TotEner = [0.0D]
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

      If (Tot_Nrg LT Tot_Emin) OR  (TOt_NRg GT Tot_EMax) Then goto, Jump_Packet

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

    ; print, time_Diff
    Time_DIff = 720.0
    ;
    ; === Average Live Time ====
    ;
    AvgLT_Arr = dblArr(32)
    for j = 0,31 do if lt_count[j] ne 0 then AvgLT_arr[j] = lt_array[j]/lt_count[j]

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
    EnerErr = Sqrt(ENerErr)

    ;   window,0
    ;  CGPlot, EnerArr
    print, total(EnerArr), '**'
    auc = Tsum(EnerArr)
    print, auc, 'Area'

    ;
    ; == REbin ==
    ; Modifying this from 4b. 
    ; Now we have a variable binning.
    nbins = n_elements(Ebin_lo)
;    xval2 = indgen(nbins)*bin
;    xval3 = indgen(nbins)*bin+bin

    Flight2 = DblArr(nbins)
    Flight2_Err = DblArr(nbins)


    for i = 0, nbins-1 do begin
      Elo = Ebin_lo[i]
      Ehi = Ebin_hi[i]
      
      tempFli   = 0.0
      tempFli_err   = 0.0
      

      for j = Elo, Ehi-1 do begin

            TempFli = TempFli + EnerArr[j]
            TempFli_err = TempFli_err + EnerErr[j]*EnerErr[j]
      endfor

      Flight2[i] = tempFli
      Flight2_Err[i] = Sqrt(tempFli_Err)
    endfor ; i
    print
    print, total(Flight2)

    bin = Ebin_hi-Ebin_lo
    help, bin
    Print, 'BIN = '
    Print,Bin
    Flight2 = Flight2

    Flight2_Err = Flight2_err
     XVal2a = Float(Ebin_lo)
     Xval3a = Float(Ebin_hi)

    auc = Tsum(Xval2a,Flight2)
    print, auc, 'Area'

    ;    window, 1
    ;   Cgplot, Flight2
    ;Text files
    Swp=event_data[0].sweepno
    text_title= title+text_title1+'Swp'+Strn(Swp)+text_title2

    print, text_title
    openw, lun1,text_title+'temp.txt' ,/GET_LUN
    for i = 0, n_elements(Xval2a)-1 do begin
      datai = Strn(xval2a[i]) + '    '+Strn(xval3a[i])+ '    '+ Strn(Flight2[i]) + '    '+ Strn(Flight2_Err[i])
      printf, lun1, datai
    endfor
    Free_Lun, lun1

    text_title2= title+text_title1+'Swp'+Strn(Swp)+'data.txt'
    openw, lun2, text_title2, /Get_lun
    for i = 0, n_elements(Xval2a)-1 do begin
      data_count = String(Format='( E13.7 ,X)', Flight2[i])
      data_error = String(Format='( E13.7 ,X)', Flight2_err[i])

      printf, lun2, '          '+Strn(i),'   ',data_Count,'   ', Data_error
    endfor
    free_lun, lun2
    ; Plot
    ; ===
    ;  ---- Opening the Device for further plots and various things -----
    CgPs_Open, Text_Title+'.ps', Font =1, /LandScape
    cgLoadCT, 13
    !P.Font=1

    ;    xticks = loglevels([xmin,xmax])
    ;    nticks = n_elements(xticks)
    xmin=50
    xmax=350
    ymin= 0.0001
    ymax=Max(Flight2) * 2
    ;
    ; Page 1: Flight vs gamma
    ;
    xtitle = 'Energy (keV)'
    ytitle = ' Counts (C/s)'

    Cgplot, Xval2a,Flight2, PSYM=10, XRANGE=[Xmin,Xmax],Xstyle=1, /Xlog,/Ylog, YRAnge=[Ymin,Ymax],  YStyle=1,$;
      title=ptitle, xtitle=xtitle, ytitle=ytitle,$;linestyle=1, $
      err_Yhigh=Flight2_Err, err_Ylow = Flight2_Err, /Err_Clip,Err_Color='black',Err_Width=er_wid,$
      err_XHigh = Xerr, Err_Xlow=Xerr,xgridstyle=1, xticklen=1, yticklen=1, ygridstyle=1


    CgText, !D.X_Size*0.85,!D.Y_Size*0.93,'Swp='+STRN(Swp),/DEVICE, CHarSize=1.7,Color=CgColor('Black')


    CgPs_Close

    ;-- Create the PDF File
    Temp_Str = Cur+'/'+Text_Title+'.ps'
    CGPS2PDF, Temp_Str,delete_ps=1,UNIX_CONVERT_CMD='pstopdf'


  EndFor; /p



  ;
  ;=== Text file for pha ==
  ; Elow Ehigh Counts/S Error.
  ;




  Stop
End