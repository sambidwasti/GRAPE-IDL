Pro GSim_GRP_Investigate4, fsearch_String, title=title, nfiles= nfiles, PSDeff=PSDeff, Per=Per
  ;
  ; Renamed from Investigate5 procedure.
  ; Process the gsim file to replicate the calibration process.
  ;

  ;
  ;Additional notes: on the way the program's algorithm work:
  ;
  ;- Read in GSIM File
  ;  - Run through each event.
  ;     - For each anode in each event, apply a cross-talk algorithm
  ;       for the adjacent anodes.
  ;     - Do the energy broadening for each of the anodes (including new anodes)
  ;     - June 1, 2016
  ;         Added the efficiency algorithm here.
  ;         (this step looks at a event, sees if there is any successful cross-talk
  ;           and if there is one, filters in or takes in % of these cross-talk between
  ;           different scintillator types)
  ;     - June 16, 2016
  ;         Add a C and CC filter. Decimation factor.
  ;     - Energy Threshold (Hardware defined here)
  ;     - This is where we meet the hardware classifications.
  ;     - Re-Classify the events (Hardware classification)
  ;       May 24,
  ;           - Do a software threshold
  ;           - Do a software classification of the filtered events
  ;     -Output the statistics file.
  ;
  ;
  ;;
  True =1
  False=0

  ;-- CT file variable. --



  if keyword_set(Per) ne 1 then Per = 0
  Crs_talk = 'Inv_Ct4_7a_'+strn(per)+'_'+ STRN(PSDEff)
  print, 'Crs_Talk % =', Per
  print, 'file=',Crs_talk
  ;
  ;=== PSD Efficiency ===
  ;% of the cross-talk stopped
  ;
  P_to_C_Percent = 0
  C_to_P_Percent = PSDEff;69


  ;
  ;===Software Energy Thresholds (keV) ===
  ;
  Cal_Min = 30.0
  Cal_Max = 400.0

  Pla_Min = 10.0
  Pla_MAx = 200.0

  Print, 'C', Cal_Min, Cal_Max
  Print, 'P', Pla_Min, Pla_Max

  ;
  ;=== DECIMATION ===
  ;
  Dec_Factor = 5

  ;
  ;==== Hardware Threshold ====
  ;
  Hwd_Pla = 4.0
  Hwd_Cal = 30.0

  ;
  ;=== Get single or multiple files ====
  ;
  gSimFile = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
  if keyword_set(nfiles) ne 1 then nfiles = n_elements(gSimfile)

  ;
  ;=== Define the structure for each events.===
  ;

  GSim_Struc = { $
    VERNO           :0B,            $   ; Data format version number

    In_Enrg         :0.0,           $   ; Incident Source
    ;    In_XPos         :0.0,           $   ; Incident Photon X Pos
    ;    In_YPos         :0.0,           $   ; Incident Photon Y Pos
    ;    In_ZPos         :0.0,           $   ; Incident Photon Z Pos

    NAnodes         :0B,            $   ; Number of triggered anodes (1-8)
    NPls            :0B,            $   ; Number of triggered plastic anodes
    NCal            :0B,            $   ; Number of triggered calorimeter anodes

    EvType          :0B,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)only for Nanodes 2
    EvClass         :0B,            $   ; C = 1, CC =2, PC =3, PP =4, PPC =6 more than 2 events 7 for now. P =5

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types (Cal=1, Pla =2, Invalid =-1) Weird but thats how it has been used.

    IM_Flag         :0B,            $   ; Intermodule flag
    Mod_ID          :0B,            $   ; Module ID

    ;    ANODENRG_Uncor  :FLTARR(8),     $   ; Array of triggered anode energies
    AnodeNrg        :FltArr(8),     $   ; Array of triggered anode energies Corrected

    ;    TotEnrg_Uncor   :0.0,           $
    TotEnrg         :0.0            $
  }
  Struc_Size = 64


  ;
  ;==== For Each File =====
  ;
  for p =0, nfiles-1 Do Begin

    infile = GsimFile[p]
    print, infile

    ;
    ;-- Reading in the data --
    ;
    F = File_Info(infile)                           ; get inout file info
    Nevents = Long(f.size / Struc_Size)             ; get number of events in input file
    GsimData = replicate(GSim_Struc, nevents)       ; initialize input data array

    Print, 'No: Events = '+STRN(NEvents)

    ;
    ;-- Open and read in the file as structure defined --
    ;
    Openr, Lun, infile , /Get_Lun
    For i = 0L, nevents-1 do Begin

      Readu, Lun, GSim_Struc                        ; read one event
      GsimData[i] = GSim_Struc                      ; add it to input array

    Endfor ; i
    Free_lun, Lun

    ;
    ;-- Define variables ---
    ;
    Ev_Inv = LONARR(8)
    Ev_P  = LONARR(8)
    Ev_C = LONARR(8)
    Ev_CC= LONARR(8)
    Ev_PC= LONARR(8)
    Ev_PP= LONARR(8)
    Ev_PPC= LONARR(8)
    Ev_Othr= LONARR(8)

    New_Events=0L

    Ev1 = LonArr(8) ; just a random array for the event class.
    Ev2 = LonArr(8)
    Ev3 = LonArr(8)
    Ev4 = LonArr(8)
    Ev5 = LonArr(8)

    ; PSDs
    tot_C2Pres  = 0L
    tot_P2Cres  = 0L

    Dec_Counter = 0L

    ;
    ;-- Now for each event, we want to read in.
    ;
    For i =0L, nevents-1 do Begin


      data = GsimData[i]        ; so we have stored the structure in data.

      Ev2[data.EvClass]++       ; Store the previous event class.

      ;
      ;--- Now we re-process Each of these events. ---
      ;

      NoAnodes = data.NAnodes       ; No. of anodes triggered.
      AnID     = data.AnodeID       ; Anode ID
      AnNrg    = data.AnodeNrg      ; Each anode energy deposited.

      ;
      ;-- well we didnt need this but helps to clear things better.
      ;
      New_AnID = AnID[0:NoAnodes-1]
      New_AnNrg= AnNRg[0:NoANodes-1]
      New_AnTyp= INTARR(NOAnodes)

      ;        If data.EvClass Eq 3 Then begin
      ;              Print
      ;              Print, i
      ;              Print, AnID
      ;              Print, data.ANodeTyp
      ;              PRint, Data.ANodeNrg
      ;        Endif

      ;
      ;
      ;-- Now for each of these anodes triggered, we want to include the Cross-Talk.
      ;
      For k = 0,NoAnodes-1 Do Begin
        ;
        ; -- This puts everything in temp_Arr
        ;
        Temp_Arr = Grp_CT_Al_4(New_AnID[k],New_AnNrg[k],Per=Per)

        ;
        ;The above cross-talk algorithm takes in the adjacent anodes and gives it
        ;the energy and outputs an array with new IDs and Energies.
        ;

        ;
        ;-- Divide the Anode ID and Energy ID.
        ;


        Len = N_Elements(temp_arr)/3
        Temp_AnID = Fix(temp_arr[0:Len-1])
        Temp_AnNrg= temp_arr[len:Len*2-1]
        Temp_AnTyp = fix(temp_Arr[len*2:N_elements(temp_Arr)-1])

        New_AnID = [New_AnID ,Temp_AnID ]
        New_AnNrg= [New_AnNrg,Temp_AnNrg]
        New_AnTyp= [New_AnTyp,Temp_AnTyp]   ; june 1 update
      EndFor

      ;
      ;-- The new energies and Ids are stored in New_AnID and New_AnNrg
      ;

      New_NoAnodes = N_Elements(New_AnID)   ; newer no. of anodes

      ;
      ;== Energy Broadening ==
      ;
      New_Cor_Nrg = FltArr(New_NoAnodes)  ; Store the corrected broadened energy in this variable.

      For k =0,New_noAnodes-1 Do New_Cor_Nrg[k] = Correct_Energy(New_AnID[k],New_AnNrg[k])

      ;
      ;== June 1 Update for P2C and C2P
      ;
      P2C_flag = False
      C2P_Flag = False

      ;
      ;== Hardware Threshold ==
      ;
      Hwd_fil_AnID = [-1]
      Hwd_fil_AnNrg= [-1.0]
      Hwd_fil_AnTyp= [1]
      For k =0,New_noAnodes-1 Do Begin
        If (Anode_Type(New_AnID[k]) EQ 1 )Then Begin

          If ( New_Cor_Nrg[k] LT Hwd_Cal) Then Goto, Skip_Filter1

        Endif Else If (Anode_Type(New_AnID[k]) EQ 2) Then Begin
          If ( New_Cor_Nrg[k] LT Hwd_Pla) Then Goto, Skip_Filter1

        Endif
        Hwd_Fil_AnID= [Hwd_Fil_AnID,New_AnID[k]]
        Hwd_Fil_AnNrg=[Hwd_Fil_AnNrg,New_Cor_Nrg[k]]

        ;
        ;== June 1 Update for P2C and C2P
        ;
        if (New_AnTyp[k] Eq 4) or (New_AnTyp[k] eq 5) Then P2C_Flag = true
        if (New_AnTyp[k] Eq 6) or (New_AnTyp[k] eq 7) Then C2P_Flag = true
        Hwd_Fil_AnTyp=[Hwd_Fil_AnTyp,New_AnTyp[k]]

        Skip_Filter1:
      Endfor

      If N_ELements(Hwd_Fil_AnID) Eq 1 Then Goto, Skip_event

      Hwd_Fil_AnID  = Hwd_Fil_AnID[1:N_Elements(Hwd_Fil_AnID)-1]
      Hwd_Fil_AnNRg = Hwd_Fil_AnNrg[1:N_Elements(Hwd_Fil_AnNrg)-1]
      Hwd_Fil_AnTyp = Hwd_Fil_AnTyp[1:N_Elements(Hwd_Fil_AnTyp)-1]

      Hwd_Fil_NoANodes = N_Elements(Hwd_FIl_ANID)


      ; == PSD Variables ==
      ; if 20%, 5th one stopped. allows 4 but stops 1.
      ; if 100% efficient no CT between scint allowed.
      ; if 0% then all allowed.
      ;
      ; Furthermore:
      ;   - This means that % cross-talks blocked. So not reported in Hardware

      ;
      ;== Efficiency workings of Plastic to Calorimeter
      ;the percentage was to block. so we skip whenever that happens.
      ;

      ;== P 2 C

      temp_arr_id = IntArr(1)
      temp_arr_nrg= FltARr(1)
      if P2C_Flag Eq True then Begin
        p2cRes = 100 - P_to_C_Percent
        tot_P2Cres = tot_P2Cres + p2cRes

        if tot_P2Cres GE 100 Then Begin
          tot_P2Cres = tot_P2Cres -100
        endIf else Begin
          for k = 0, Hwd_Fil_NoANodes-1 Do Begin
            If (Hwd_Fil_AnTyp[k] NE 4) and (Hwd_Fil_AnTyp[k] NE 5) Then begin
              temp_arr_id = [temp_arr_id,Hwd_Fil_AnID[k]]
              temp_arr_Nrg = [temp_arr_Nrg,Hwd_Fil_AnNrg[k]]
            EndIf
          endfor

          Hwd_Fil_AnID = temp_Arr_Id[1:N_Elements(Temp_Arr_ID)-1]
          Hwd_Fil_AnNrg= temp_Arr_Nrg[1:N_Elements(Temp_Arr_NRg)-1]
          Hwd_Fil_NoANodes = N_Elements(Hwd_FIl_ANID)

        endelse

      EndIf




      temp_arr_id = IntArr(1)
      temp_arr_nrg= FltARr(1)

      ;== C 2 P
      if C2P_Flag Eq True Then Begin
        c2pRes = 100 - C_to_P_Percent
        tot_C2Pres = tot_c2pRes + c2pRes


        if tot_C2Pres GE 100 Then Begin
          tot_C2Pres = tot_C2Pres -100
        endIf else Begin
          for k = 0, Hwd_Fil_NoANodes-1 Do Begin
            If (Hwd_Fil_AnTyp[k] NE 6) and (Hwd_Fil_AnTyp[k] NE 7) Then begin
              temp_arr_id = [temp_arr_id,Hwd_Fil_AnID[k]]
              temp_arr_Nrg = [temp_arr_Nrg,Hwd_Fil_AnNrg[k]]
            EndIf
          endfor

          if n_elements(Temp_Arr_ID) lE 1 Then goto, skip_event

          Hwd_Fil_AnID = temp_Arr_Id[1:N_Elements(Temp_Arr_ID)-1]
          Hwd_Fil_AnNrg= temp_Arr_Nrg[1:N_Elements(Temp_Arr_NRg)-1]
          Hwd_Fil_NoANodes = N_Elements(Hwd_FIl_ANID)
        endelse

      EndIf



      ;
      ;== Hardware Classification ==
      ;

      No_Cal = 0L
      No_Pla = 0L
      For k = 0,Hwd_Fil_NoAnodes-1 Do If Anode_type(Hwd_Fil_ANID[k]) EQ 1 THen No_Cal++ Else If Anode_type(HWd_Fil_ANID[k]) EQ 2 Then No_pla++

      Evt3Class = 0
      If No_Cal Gt 0 Then Begin ; If there are no calorimeter it is 0. We do not read these in hardware.
        If No_Pla GE 1 Then Evt3Class = 3 Else BEgin
          If No_Cal EQ 1 Then Evt3Class = 1 Else Evt3Class = 2
        EndElse
      Endif

      Ev5[Evt3Class]++
      ;
      ;=== HARDWARE DECIMATION ===
      ;Basically skip the event . 4 out of 5.
      ;Only for C and CC
      ;
      If (Evt3Class Eq 1) or (Evt3Class Eq 2) Then BEgin
        Dec_Counter ++
        If (Dec_Counter LT Dec_Factor)  Then GOTo, Skip_Event Else Dec_Counter = 0L
      Endif

      ;
      ;-- Tabulate the Hardawre classes.
      ;
      Ev3[Evt3Class]++

      ;        If data.EvClass Eq 3 Then begin
      ;          Print, 'Hwd Threshold'
      ;          Print, Hwd_Fil_AnID
      ;          Print, Hwd_Fil_AnNrg
      ;          Print, EVT3CLASS
      ;        Endif

      ;
      ;=======================
      ;
      ;Now we have a hardware trigger set up. We would not the EV3Class 0 which are no calorimeter events. So
      ;So we filter out these events.
      ;

      If Evt3Class Eq 0 Then Goto, Skip_Event

      ;
      ;== Software Threshold ==
      ;
      Fil_AnID =[-1]
      Fil_AnNrg=[-1.0]

      Hwd_NoAnodes = Hwd_Fil_NoAnodes

      For k =0, Hwd_NoAnodes-1 Do Begin

        If (Anode_Type(Hwd_Fil_AnID[k]) EQ 1) Then Begin
          If ( Hwd_Fil_AnNRg[k] LT Cal_Min) Or ( Hwd_Fil_AnNRg[k] GT Cal_Max) Then Goto, Skip_Filter

        Endif Else If (Anode_Type(Hwd_Fil_AnID[k]) EQ 2) Then Begin
          If ( Hwd_Fil_AnNRg[k] LT Pla_Min) Or ( Hwd_Fil_AnNRg[k] GT Pla_Max) Then Goto, Skip_Filter
        Endif
        Fil_AnID = [Fil_AnID,Hwd_Fil_AnID[k]]
        Fil_AnNrg= [Fil_AnNrg,Hwd_Fil_AnNRg[k]]

        Skip_Filter:
      Endfor

      ;
      ;== Now we have the new anodes that are above threshold energy in the Fil_AnID, Fil_AnNRg
      ;-- Fil = Filtered
      ;
      If N_ELements(Fil_AnID) Eq 1 Then Goto, Skip_event

      Fil_AnID = Fil_AnID[1:N_Elements(Fil_AnID)-1]
      Fil_AnNRg = Fil_AnNrg[1:N_Elements(Fil_AnNrg)-1]

      ;
      ;-- Event Class --
      ;
      Fil_NoANodes = N_Elements(FIl_ANID)

      No_Pla =0l
      No_Cal =0l

      For k = 0,Fil_NoAnodes-1 Do If Anode_type(Fil_ANID[k]) EQ 1 THen No_Cal++ Else If Anode_type(Fil_ANID[k]) EQ 2 Then No_pla++

      ;
      ;== Keeping track of the hardware and software classes.
      ;
      Evt4Class = 0
      If No_Cal Gt 0 Then Begin ; If there are no calorimeter it is 0. We do not read these in hardware.
        If No_Pla GE 1 Then Evt4Class = 3 Else BEgin
          If No_Cal EQ 1 Then Evt4Class = 1 Else Evt4Class = 2
        EndElse
      Endif
      Ev4[Evt4Class]++



      EvtClass = 0
      ;
      ;-- Event Class --  May 18 changed from hardware to software.
      ;C = 1, CC =2, PC =3, PP =4, PPC =6 more than 2 events 7 for now. P =5
      ;
      EvtClass = 0
      If No_Cal GT 0 Then Begin
        If (No_Cal EQ 1) Then Begin
          If No_Pla Eq 0 Then EvtClass = 1 Else Begin
            If No_pla Eq 1 Then EvtClass = 3 Else If No_Pla Eq 2 Then EvtClass = 6 Else if No_Pla Gt 2 Then EvtClass = 7
          EndElse
        Endif Else if No_Cal Gt 1 Then begin
          If No_Cal eq 2 then EvtClass = 2 Else EvtClass = 7
        Endif
      EndIf Else BEgin ; This is if no_cal =0
        If No_pla EQ 1 Then EvtClass = 5 Else If No_Pla Eq 2 Then EvtClass = 4 Else EvtClass = 7
      Endelse

      Ev1[EvtClass]++

      ;
      ;--- Tracking Array ---
      ;
      If data.evclass EQ 0 Then Ev_P[evtclass]++
      If data.evclass Eq 1 THen Ev_C[EvtClass]++
      If data.evclass EQ 2 Then Ev_CC[evtclass]++
      If data.evclass EQ 3 Then Ev_PC[evtclass]++

      New_Events++

      Skip_Event:

      ;      If i gt 50 then stop
      if i mod 10000 eq 0 then print,i

    Endfor ; i for event
    Print, 'No Newer Events='+Strn(New_Events)
    Print, Ev2 , Total(Ev2)
    Print, Ev3 , Total(Ev3)
    Print, Ev4 , Total(Ev4)
    Print, Ev1 , Total(Ev1)
    ;
    ;-- Trim the infile name --
    ;

    Temp_Pos = STRPOS(infile, 'csv1.dat',0)
    Outfile= Strmid(infile, 0,Temp_pos)+Crs_talk+'.Inv.Ssts.txt'



    Openw, Lun3, OUtfile,/Get_lun, width=150
    Printf, lun3, 'file = '+infile
    printf, lun3, 'Event Classes: Starts at inval, C, CC, PC, PP, P, PPC, Oth '
    Printf, lun3, 'Event class before and after the procedure.'
    Printf, lun3, 'Before_CT  Hard_after_CT Hard_after_Dec Hard_after_ST Soft'
    for i =0,7 Do begin
      Printf, lun3,Ev2[i],' ', Ev5[i], Ev3[i],Ev4[i],Ev1[i]

    Endfor

    Printf, lun3, ''
    Printf, lun3, ' Keeping track of Event classifications '
    ; Printf, lun3, ' Inv', Ev_Inv
    Printf, Lun3, ' C  ', Ev_C
    Printf, Lun3, ' CC ', Ev_CC
    Printf, Lun3, ' PC ', Ev_PC
    ; Printf, Lun3, ' PP ', Ev_PP
    Printf, Lun3, ' P  ', Ev_P
    ; Printf, Lun3, ' PPC', Ev_PPC
    ;Printf, Lun3, ' Oth', Ev_Othr

    Printf, Lun3
    Printf, Lun3
    Printf, lun3, Cal_min, Cal_max, Pla_min, Pla_max
    Printf, lun3, dec_factor
    Free_lun, Lun3

  Endfor ; p
  ; Stop
End