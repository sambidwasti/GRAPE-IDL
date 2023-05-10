Pro Grp_L2v7_Flt_Polarization_a, fsearch_String, title=title
  ; This is a variation to Grp_L2v7_Flt_Polarization to investigate the parallactic angle and rotate it accordingly.
  ; 
  ; This is created to generate a text file with columns of variables needed for generating
  ; Flight plan and other stuffs.

  ; Note the alt is the atmospheric alt
  ;
  ; Additional NOTE:
  ;   The level2 only processed fully the PC events with 2 anodes triggered.
  ;   This meant that the scat angles and the subsequent angles were only calculated for them.
  ;   After the software threshold applied, some of the events will change and that is not recorded
  ;         via the l2processing.
  ;   Hence the angle has to be recalculated here.
  ;



  True = 1
  False= 0

  bsize= 30.0
  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 10.0
  Pla_EMax = 200.00

  Cal_EMin = 40.0
  Cal_EMax = 400.00

  Tot_EMin = 70.00
  Tot_EMax = 200.00

  Class = 3
  Altitude = 131.5D

  Off_Ang=  151.6

  PMax= 1500 ; Max value of energy for energy histogram.
  Cd, Cur=Cur

  IF Keyword_Set(title) Eq 0 Then Title='Test1a'


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
  ;------
  ;

  Old_Time = 0L
  Spec_Old_Time = 0L

  CgPS_Open, title+'_Flt_Polarization_a.ps', Font =1, /LandScape
  cgLoadCT, 13

  For p = 0, nfiles-1 Do Begin ; open each file
    ; Counter for first and End Array
    A=0

    ;
    ;-- No. of Events Counter --
    ;
    No_Events = 0L


    ;
    ;---- Each file
    ;
    fname = evtfiles[p]
    print, fname

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
    ;- String manipulation for the files.
    ;

    pos1 = StrPos(fname,  '.dat',0)
    out_fname = Strmid(fname, 0,pos1)+'_Pola.txt'
    openw, lun2, out_Fname, /get_lun

    ;- OldTime
    ; If p eq 0 then old_time= Event_data[0].evtime

    Imflag_cnt=0
    Evt_Cnt=0L
    Rtang_arr = [0.0]
    sctang_arr = [0.0]
    pvang_arr = [0.0]

    LT_Array = DblArr(32)
    LT_Count = DblArr(32)


    ; The first value is going to be 0 so we have to be careful of getting rid of it.
    ; And i need to add them individually
    P0_Arr  = DBLArr(1)
    P2_Arr  = DBLArr(1)
    P3_Arr  = DBLArr(1)
    P4_Arr  = DBLArr(1)
    P6_Arr  = DBLArr(1)
    P7_Arr  = DBLArr(1)
    P9_Arr  = DBLArr(1)
    P10_Arr = DBLArr(1)
    P11_Arr = DBLArr(1)
    P12_Arr = DBLArr(1)
    P13_Arr = DBLArr(1)
    P14_Arr = DBLArr(1)
    P17_Arr = DBLArr(1)
    P18_Arr = DBLArr(1)
    P19_Arr = DBLArr(1)
    P20_Arr = DBLArr(1)
    P21_Arr = DBLArr(1)
    P22_Arr = DBLArr(1)
    P24_Arr = DBlArr(1)
    P25_Arr = DBlArr(1)
    P27_Arr = dblArr(1)
    P28_Arr = dBLArr(1)
    P29_Arr = DBLArr(1)
    P31_Arr = DBLArr(1)
    
    Para_array = [0.0]
    For i = 0, TotPkt-1 Do Begin
      data = Event_data[i]

      ;
      ;== Necessary Filters.==
      ;
      If Data.Qflag LT 0 Then goto, Jump_Packet
      If Data.ACflag EQ 1 Then Goto, Jump_Packet
      If Data.Nanodes LE 0 Then Goto, Jump_Packet

      NewAnodeId = [0]
      NewanodeNrg= [0.0]
      NewAnodeTyp= [0]
      NOCal = 0
      NoPla = 0

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
      If (Tot_Nrg LT Tot_Emin) OR  (TOt_NRg GT Tot_EMax) Then goto, Jump_Packet
      If data.imflag eq 1 then goto, jump_packet

      ; If data.imflag eq 1 then Begin

      ;    imflag_cnt++
      ;    Goto, Jump_packet
      ;  EndIf

      new_nevents = n_elements(newANodeID)
      If New_Nevents NE 2 Then goto, jump_packet


      ;================================
      ; Angular calculation for 2andoe PC event.
      ; Get primary : plastic and sec: calorimeter id and nrg
      ; Calculate angles
      For j = 0, New_NEvents-1 do begin

        If NewAnodeTyp[j] Eq 1 then Begin
          PlaANodeID = NewAnodeID[j]
          PlaANodeNrg= NewANodeNrg[j]
        EndIF Else IF NewAnodeTyp[j] Eq 2 then begin
          CalANodeID = NewAnodeID[j]
          CalANodeNrg= NewANodeNrg[j]
        ENdIF
      EndFor
      modid = data.pa_mod
      Scat_ang = Grp_ScatANg(modid, plaAnodeID, modid, CalANodeID)

      pres_ves_angle = scat_ang - data.rtang + off_Ang
      cirrange, pres_ves_angle
      ;============================


      mod_pos = data.Pa_Mod
      LiveTime = Data.CorrectLT
      LT_Array[mod_pos] = LT_Array[mod_pos]+LiveTime
      LT_Count[mod_pos]++

      If Mod_Pos EQ 0 Then P0_Arr  = [P0_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 2 Then P2_Arr  = [P2_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 3 Then P3_Arr  = [P3_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 4 Then P4_Arr  = [P4_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 6 Then P6_Arr  = [P6_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 7 Then P7_Arr  = [P7_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 9 Then P9_Arr  = [P9_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 10 Then P10_Arr = [P10_Arr,Pres_Ves_Angle]

      If Mod_Pos EQ 11 Then P11_Arr = [P11_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 12 Then P12_Arr = [P12_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 13 Then P13_Arr = [P13_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 14 Then P14_Arr = [P14_Arr,Pres_Ves_Angle]

      If Mod_Pos EQ 17 Then P17_Arr = [P17_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 18 Then P18_Arr = [P18_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 19 Then P19_Arr = [P19_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 20 Then P20_Arr = [P20_Arr,Pres_Ves_Angle]

      If Mod_Pos EQ 21 Then P21_Arr = [P21_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 22 Then P22_Arr = [P22_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 24 Then P24_Arr = [P24_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 25 Then P25_Arr = [P25_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 27 Then P27_Arr = [P27_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 28 Then P28_Arr = [P28_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 29 Then P29_Arr = [P29_Arr,Pres_Ves_Angle]
      If Mod_Pos EQ 31 Then P31_Arr = [P31_Arr,Pres_Ves_Angle]

      
      ; Now we need to add these into individual module array
      evt_cnt++
       
     ;   Print, data.RTANG, data.rtstat, data.sctang
     ;   Print, data.pvang, data.ppvang, data.hrang
     ;   print, data.parang, data.posang,  data.PNTZEN, data.PNTAzi
    ;    print, data.lat, data.alt, data.lon
        Elevation = 90.0-data.pntzen
        azimuth = data.PNTAzi
        latitude = data.lat
        altaz2hadec, elevation, azimuth, latitude, hrangle, dec
        parang = parangle(hrangle, dec, latitude, /degree) ; angle is between -180->180
        
   ;     print, hrangle, dec, parang
        Para_array = [para_array,parang]

      
        
      Jump_Packet:
      If i mod 100000 EQ 0 Then print, i
    EndFor; /i
    Para_array = Para_array[1:N_elements(Para_array)-1]
    Print, Min(Para_array), Max(Para_array), Avg(Para_array)
    CgPlot, Para_array, Title='variation of Parralactic angle for Sweep '+STRN(Data.sweepno), Yrange=[-180,180]
    CgText, !D.X_Size*0.82,!D.Y_Size*(0.87),'Min ='+Strn(Min(Para_array)) ,/DEVICE, CHarSize=1.0,Color=CgColor('Black')
    CgText, !D.X_Size*0.82,!D.Y_Size*(0.85),'Max ='+Strn(Max(Para_array)) ,/DEVICE, CHarSize=1.0,Color=CgColor('Black')
    CgText, !D.X_Size*0.82,!D.Y_Size*(0.83),'Avg ='+Strn(Avg(Para_array)) ,/DEVICE, CHarSize=1.0,Color=CgColor('Black')

CgErase


    
    AvgLT_Arr = dblArr(32)
    for j = 0,31 do if lt_count[j] ne 0 then  AvgLT_arr[j] = lt_array[j]/lt_count[j]
    ;     Print, AvgLT_Arr
    print, Evt_Cnt, 'EVT_CNT'

    ;
    ;-- Projection to Sky Coordinate System.
    ;
    P0_Arr = 270.0 - P0_Arr
    P2_Arr = 270.0 - P2_Arr
    P3_Arr = 270.0 - P3_Arr
    P4_Arr = 270.0 - P4_Arr
    P6_Arr = 270.0 - P6_Arr
    P7_Arr = 270.0 - P7_Arr
    P9_Arr = 270.0 - P9_Arr
    P10_Arr = 270.0 - P10_Arr

    P11_Arr = 270.0 - P11_Arr
    P12_Arr = 270.0 - P12_Arr
    P13_Arr = 270.0 - P13_Arr
    P14_Arr = 270.0 - P14_Arr

    P17_Arr = 270.0 - P17_Arr
    P18_Arr = 270.0 - P18_Arr
    P19_Arr = 270.0 - P19_Arr
    P20_Arr = 270.0 - P20_Arr

    P21_Arr = 270.0 - P21_Arr
    P22_Arr = 270.0 - P22_Arr
    P24_Arr = 270.0 - P24_Arr
    P25_Arr = 270.0 - P25_Arr
    P27_Arr = 270.0 - P27_Arr
    P28_Arr = 270.0 - P28_Arr
    P29_Arr = 270.0 - P29_Arr
    P31_Arr = 270.0 - P31_Arr



    ;
    ;-- Parallactic Angle added.
    ; ang is added and cirrange it.
    ; Swp 92 : 62.7
    ; Swp 93 : 62.9
    ; Swp 94 : 62.8
    ; Swp 95 : 63.1
    ; Swp 96 : 63.5
    ; Swp 97 : 63.0
    ; Swp 98 : 62.2
    ; Swp 99 : 62.1
    ; Swp 100: 61.3
    swp_no = data.sweepno
    case swp_no of 
    92: par_angle_avg = 62.7
    93: par_angle_avg = 62.9
    94: par_angle_avg = 62.8
    95: par_angle_avg = 63.1
    96: par_angle_avg = 63.5
    97: par_angle_avg = 63.0
    98: par_angle_avg = 62.2
    99: par_angle_avg = 62.1
    100:par_angle_avg = 61.3
    Else: par_angle_avg =0
    endcase
    
    
   
    P0_Arr = P0_Arr+par_angle_avg
    P2_Arr = P2_Arr+par_angle_avg
    P3_Arr = P3_Arr+par_angle_avg
    P4_Arr = P4_Arr+par_angle_avg
    P6_Arr = P6_Arr+par_angle_avg
    P7_Arr = P7_Arr+par_angle_avg
    P9_Arr = P9_Arr+par_angle_avg
    P10_Arr = P10_Arr+par_angle_avg
    
    P11_Arr = P11_Arr+par_angle_avg
    P12_Arr = P12_Arr+par_angle_avg
    P13_Arr = P13_Arr+par_angle_avg
    P14_Arr = P14_Arr+par_angle_avg

    P17_Arr = P17_Arr+par_angle_avg
    P18_Arr = P18_Arr+par_angle_avg
    P19_Arr = P19_Arr+par_angle_avg
    P20_Arr = P20_Arr+par_angle_avg

    P21_Arr = P21_Arr+par_angle_avg
    P22_Arr = P22_Arr+par_angle_avg
    P24_Arr = P24_Arr+par_angle_avg
    P25_Arr = P25_Arr+par_angle_avg
    P27_Arr = P27_Arr+par_angle_avg
    P28_Arr = P28_Arr+par_angle_avg
    P29_Arr = P29_Arr+par_angle_avg
    P31_Arr = P31_Arr+par_angle_avg

    cirrange, P0_Arr
    cirrange, P2_Arr
    cirrange, P3_Arr
    cirrange, P4_Arr
    cirrange, P6_Arr
    cirrange, P7_Arr
    cirrange, P9_Arr
    cirrange, P10_Arr
    
    cirrange, P11_Arr
    cirrange, P12_Arr
    cirrange, P13_Arr
    cirrange, P14_Arr
    
    
    cirrange, P17_Arr
    cirrange, P18_Arr
    cirrange, P19_Arr
    cirrange, P20_Arr
    
    cirrange, P21_Arr
    cirrange, P22_Arr
    cirrange, P24_Arr
    cirrange, P25_Arr
    cirrange, P27_Arr
    cirrange, P28_Arr
    cirrange, P29_Arr
    cirrange, P31_Arr

    ;
    ;=== Now we need to add them properly
    ;
    tot_raw = n_elements(p0_arr) +n_elements(p2_arr)+n_elements(p3_arr)+n_elements(p4_arr)+n_elements(p6_arr)+n_elements(p7_arr)+n_elements(p9_arr)+n_elements(p10_arr)-8+$
      n_elements(p11_arr)+n_elements(p12_arr)+n_elements(p13_arr)+n_elements(p14_arr)-4+$
      n_elements(p17_arr)+n_elements(p18_arr)+n_elements(p19_arr)+n_elements(p20_arr)-4+$
      n_elements(p21_arr)+n_elements(p22_arr)+n_elements(p24_arr)+n_elements(p25_arr)-4+$
      n_elements(p27_arr)+n_elements(p28_arr)+n_elements(p29_arr)+n_elements(p31_arr)-4
    print, tot_raw
    Angle_max = 359.99
    H0 = cghistogram(p0_arr[1:n_elements(p0_arr)-1], Binsize=bsize, Min=0.0, Max=Angle_max, Locations=Xarr)
    H2 = cghistogram(p2_arr[1:n_elements(p2_arr)-1], Binsize=bsize, Min=0.0, Max=Angle_max, Locations=Xarr)
    H3 = cghistogram(p3_arr[1:n_elements(p3_arr)-1], Binsize=bsize, Min=0.0, Max=Angle_max, Locations=Xarr)
    H4 = cghistogram(p4_arr[1:n_elements(p4_arr)-1], Binsize=bsize, Min=0.0, Max=Angle_max, Locations=Xarr)
    H6 = cghistogram(p6_arr[1:n_elements(p6_arr)-1], Binsize=bsize, Min=0.0, Max=Angle_max, Locations=Xarr)
    H7 = cghistogram(p7_arr[1:n_elements(p7_arr)-1], Binsize=bsize, Min=0.0, Max=Angle_max, Locations=Xarr)
    H9 = cghistogram(p9_arr[1:n_elements(p9_arr)-1], Binsize=bsize, Min=0.0, Max=Angle_max, Locations=Xarr)
    H10 = cghistogram(p10_arr[1:n_elements(p10_arr)-1], Binsize=bsize, Min=0.0, Max=Angle_max, Locations=Xarr)

    H11 = cghistogram(p11_arr[1:n_elements(p11_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H12 = cghistogram(p12_arr[1:n_elements(p12_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H13 = cghistogram(p13_arr[1:n_elements(p13_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H14 = cghistogram(p14_arr[1:n_elements(p14_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)

    H17 = cghistogram(p17_arr[1:n_elements(p17_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H18 = cghistogram(p18_arr[1:n_elements(p18_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H19 = cghistogram(p19_arr[1:n_elements(p19_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H20 = cghistogram(p20_arr[1:n_elements(p20_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)

    H21 = cghistogram(p21_arr[1:n_elements(p21_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H22 = cghistogram(p22_arr[1:n_elements(p22_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H24 = cghistogram(p24_arr[1:n_elements(p24_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H25 = cghistogram(p25_arr[1:n_elements(p25_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)

    H27 = cghistogram(p27_arr[1:n_elements(p27_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H28 = cghistogram(p28_arr[1:n_elements(p28_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H29 = cghistogram(p29_arr[1:n_elements(p29_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)
    H31 = cghistogram(p31_arr[1:n_elements(p31_arr)-1], Binsize=bsize, Min=0, Max=Angle_max, Locations=Xarr)

    ;check
    ;    Tot_H = H0+H2+H3+H4+H6+H7+H9+H10  +H11+H12+H13+H14    +H17+H18+H19+H20    +H21+H22+H24+H25   +H27+H28+H29+H31
    ;    print, Total(TOt_H) ,'Tot Bef'

    PolArr = dblarr(n_elements(h31))
    PolErr = Dblarr(n_elements(h31))
    ;== now we add each individual ones

    Time_diff = 1

    ;mod 0
    avlt  = AvgLt_arr[0]
    Temp_arr = H0
    Temp_Err = sqrt(H0)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod2
    avlt  = AvgLt_arr[2]
    Temp_arr = H2
    Temp_Err = sqrt(H2)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod3
    avlt  = AvgLt_arr[3]
    Temp_arr = H3
    Temp_Err = sqrt(H3)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod4
    avlt  = AvgLt_arr[4]
    Temp_arr = H4
    Temp_Err = sqrt(H4)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod6
    avlt  = AvgLt_arr[6]
    Temp_arr = H6
    Temp_Err = sqrt(H6)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod7
    avlt  = AvgLt_arr[7]
    Temp_arr = H7
    Temp_Err = sqrt(H7)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod9
    avlt  = AvgLt_arr[9]
    Temp_arr = H9
    Temp_Err = sqrt(H9)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod10
    avlt  = AvgLt_arr[10]
    Temp_arr = H10
    Temp_Err = sqrt(H10)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod11
    avlt  = AvgLt_arr[11]
    Temp_arr = H11
    Temp_Err = sqrt(H11)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod12
    avlt  = AvgLt_arr[12]
    Temp_arr = H12
    Temp_Err = sqrt(H12)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod13
    avlt  = AvgLt_arr[13]
    Temp_arr = H13
    Temp_Err = sqrt(H13)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod14
    avlt  = AvgLt_arr[14]
    Temp_arr = H14
    Temp_Err = sqrt(H14)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod17
    avlt  = AvgLt_arr[17]
    Temp_arr = H17
    Temp_Err = sqrt(H17)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod18
    avlt  = AvgLt_arr[18]
    Temp_arr = H18
    Temp_Err = sqrt(H18)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod19
    avlt  = AvgLt_arr[19]
    Temp_arr = H19
    Temp_Err = sqrt(H19)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod20
    avlt  = AvgLt_arr[20]
    Temp_arr = H20
    Temp_Err = sqrt(H20)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod21
    avlt  = AvgLt_arr[21]
    Temp_arr = H21
    Temp_Err = sqrt(H21)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod22
    avlt  = AvgLt_arr[22]
    Temp_arr = H22
    Temp_Err = sqrt(H22)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod24
    avlt  = AvgLt_arr[24]
    Temp_arr = H24
    Temp_Err = sqrt(H24)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod25
    avlt  = AvgLt_arr[25]
    Temp_arr = H25
    Temp_Err = sqrt(H25)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod27
    avlt  = AvgLt_arr[27]
    Temp_arr = H27
    Temp_Err = sqrt(H27)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod28
    avlt  = AvgLt_arr[28]
    Temp_arr = H28
    Temp_Err = sqrt(H28)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod29
    avlt  = AvgLt_arr[29]
    Temp_arr = H29
    Temp_Err = sqrt(H29)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )

    ; mod10
    avlt  = AvgLt_arr[31]
    Temp_arr = H31
    Temp_Err = sqrt(H31)

    If Avlt NE 0.0 Then PolArr = PolArr+Temp_Arr/(Avlt*Time_Diff)
    If Avlt NE 0.0 Then polErr = PolErr+( (Temp_Err/(Avlt*Time_Diff))*(Temp_Err/(Avlt*Time_Diff)) )



    pvang_arr_1 = Polarr
    pvang_err = sqrt(Polerr)
    Print, total(pvang_arr_1), 'TOTAL'
    ; cghistoplot, pvang_arr[1:N_Elements(pvang_arr)-1], BinSize=20.0;, Min=0, Max=359.0
    xerror = fltarr(n_elements(Xarr))+bsize/2

    yerror = sqrt(pvang_arr_1)
    Cgplot, Xarr+10.0, pvang_arr_1, xrange=[0,360], xstyle=1,$
      title='Scat Angle histogram (PV Coord)' +'  Swp:'+strn(data[0].sweepno), Ytitle='counts', xtitle='Angle',$
      Err_Xlow=xerror, Err_xHigh=xerror,Err_ylow=yerror, Err_yhigh=yerror, err_width=0, thick=0, psym=10, /err_clip,$
      xtickinterval=45

    CgText, !D.X_Size*0.65,!D.Y_Size*(-1)*0.01,fname,/DEVICE, CHarSize=1.0,Color=CgColor('Black')
    


    CgErase
    for j = 0,N_elements(pvang_arr_1)-1 do begin
      printf, lun2,xarr[j], pvang_arr_1[j]
    endfor

    Free_Lun, Lun2
  EndFor; /p

  CgPS_Close
  Temp_Str = Cur+'/'+title+'_Flt_Polarization_a.ps'
  CGPS2PDF, Temp_Str,delete_ps=1, UNIX_CONVERT_CMD='pstopdf'



End