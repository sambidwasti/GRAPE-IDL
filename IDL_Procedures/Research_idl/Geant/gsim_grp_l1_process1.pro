Pro GSim_GRP_l1_process1, fsearch_String, title=title, PSDeff=PSDeff, Per=Per
  ; Built off of investigate1 file.
  ; Purpose of this is to apply CT, do the hardware threshold, decimation, psdeff, etc and then output levell1
  ; for further processing.
  ;
  ;Additional notes: on the way the program's algorithm work:
  ;     Need to update on the final crosstalk
  ;     Need to specify the inclusion either in filename or one of the structured parameters.
  ;
  ; October 18, 2016
  ;     - Format generated
  ;
  ;
  ;;
  True =1
  False=0

  ;-- CT file variable. --

  ; skip_Crosstalk = False

  if keyword_set(PSDeff) eq 0 then PSDeff = 100 ; note when the psd is input 0.. it outputs 100. we dont use 0 anyway.
  if keyword_set(Per) eq 0 then Per = 0 ; this is 0 but we have set the ct to be 15%


  ;
  ;=== PSD Efficiency ===
  ;% of the cross-talk stopped
  ;
  P_to_C_Percent = PSDEff;
  C_to_P_Percent = PSDEff;



  ;
  ;
  ;=== DECIMATION ===
  ;
  Dec_Factor = 5

  ;
  ;==== Hardware Threshold ====
  ;
  Hwd_Pla = 4.0
  Hwd_Cal = 20.0

  ;
  ;=== Get single or multiple files ====
  ;
  gSimFile = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
  nfiles = n_elements(gSimfile)

  ;
  ;=== Define the structure for each events.===
  ;
  GSim_Struc_0 = { $
    VERNO           :0B,            $   ; Data format version number

    In_Enrg         :0.0,           $   ; Incident Source

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

    AnodeNrg        :FltArr(8),     $   ; Array of triggered anode energies Corrected

    TotEnrg         :0.0            $
  }
  Struc0_Size = 64



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
  ;==== For Each File =====
  ;
  for p =0, nfiles-1 Do Begin

    infile = GsimFile[p]
    GsimData1 = GSim_Struc_1

    ;
    ;-- Define few of the file variables.
    ;
    F = File_Info(infile)           ; get inout file info
    Nevents = Long(f.size / Struc0_Size)            ; get number of events in input file
    GsimData0 = replicate(GSim_Struc_0, nevents)    ; initialize input data array

    Print
    Print, ' **************************** '
    Print, ' File :', infile
    Print, Nevents
    Print

    ;
    ;--- Open and read teh file in --
    ;
    openr, Lun, infile , /Get_Lun
    For i = 0L, nevents-1 do Begin

      readu, Lun, GSim_Struc_0        ; read one event
      GsimData0[i] = GSim_Struc_0       ; add it to input array
    Endfor
    Free_lun, Lun

    print,'PC Before:', n_elements(gsimdata0[where(gsimdata0.EvClass eq 3)])

    ;
    ; == Rename and update the file name of level 1
    ;
    OutPos = StrPOs(Infile,'.csv',0)
    OutFile = INfile
    StrPut, OutFile, 'ct_',OutPos+5
    OutFile = Outfile + strn(per)+'_lvl1.dat'

    print, outfile
    Openw, Lun1, Outfile, /Get_Lun

    tot_P2Cres=0L
    tot_C2Pres=0L

    Dec_Counter = 0L

    temp_evt_Counter=0L
    ;
    ;---- Process the file -----
    ;
    For i =0L, nevents-1 do Begin

      data = GsimData0[i]        ; so we have stored the structure in data.

      Temp_gsim1 = Replicate(Gsim_Struc_1, 1)

      ;
      ;- Corrected Module Position
      ;
      Module_Position =ModPos[Data.Mod_ID]

      ;
      ;--- Now we re-process Each of these events. ---
      ;
      NoAnodes = data.NAnodes       ; No. of anodes triggered.
      New_AnID = data.AnodeID       ; Anode ID
      New_AnNrg= data.AnodeNrg      ; Each anode energy deposited.
      New_AnTyp= data.AnodeTyp


      ;   If Skip_Crosstalk Eq False Then begin
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
      ;      EndiF Else BEgin
      ;          New_NoAnodes  = NoAnodes
      ;          New_Cor_Nrg   =  FltArr(New_NoAnodes)
      ;
      ;      Endelse


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
      If Evt3Class Eq 0 Then Goto, Skip_Event

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
      ;=======================
      ;
      ;Now we have a hardware trigger set up. We would not the EV3Class 0 which are no calorimeter events. So
      ;So we filter out these events.
      ;

      ;
      Fil_AnID =[-1]
      Fil_AnNrg=[-1.0]

      Hwd_NoAnodes = Hwd_Fil_NoAnodes
      Fil_AnID = [Fil_AnID,Hwd_Fil_AnID]
      Fil_AnNrg= [Fil_AnNrg,Hwd_Fil_AnNRg]


      ;
      ;== Now we have the new anodes that are above threshold energy in the Fil_AnID, Fil_AnNRg
      ;-- Fil = Filtered
      ;
      If N_ELements(Fil_AnID) Eq 1 Then Goto, Skip_event

      Fil_AnID = Fil_AnID[1:N_Elements(Fil_AnID)-1]
      Fil_AnNRg = Fil_AnNrg[1:N_Elements(Fil_AnNrg)-1]


      Fil_NoANodes = N_Elements(FIl_ANID)

      If Fil_NOAnodes GT 8 Then begin
        Fil_ANID = Fil_ANID[0:7]
        Fil_ANNRG = Fil_ANNrg[0:7]
        Fil_noAnodes = 8
      Endif

      No_Pla =0l
      No_Cal =0l

      Anodetyp = intarr(Fil_NoANodes)
      For k = 0,Fil_NoAnodes-1 Do begin
        If Anode_type(Fil_ANID[k]) EQ 1 THen No_Cal++ Else If Anode_type(Fil_ANID[k]) EQ 2 Then No_pla++
        Anodetyp[k] = Anode_type(fil_anid[k])
      endfor


      EvtClass = 0


      ; Level 1 processing so keeping the hardware thresholds for here.
      EvtClass = 0
      If No_Cal Gt 0 Then Begin ; If there are no calorimeter it is 0. We do not read these in hardware.
        If No_Pla GE 1 Then EvtClass = 3 Else BEgin
          If No_Cal EQ 1 Then EvtClass = 1 Else EvtClass = 2
        EndElse
      Endif
      If EvtClass Eq 0 Then Goto, Skip_Event




      ;
      ;--- Tracking Array ---
      ;
      Temp_gsim1.VerNo    = Data.VerNo
      Temp_gsim1.In_Enrg  = Data.In_enrg
      Temp_gsim1.NAnodes  = Fil_NoANodes
      Temp_gsim1.NPls     = No_Pla
      Temp_gsim1.NCal     = No_Cal
      Temp_Gsim1.EvType   = Data.EvType    ; *****
      Temp_GSim1.EvClass  = EvtClass
      Temp_Gsim1.AnodeID  = Fil_ANID
      Temp_GSim1.AnodeTyp = AnodeTyp
      Temp_Gsim1.IM_Flag  = Data.IM_Flag  ; *****
      Temp_Gsim1.MOd_ID   = Module_Position
      Temp_Gsim1.AnodeNrg = Fil_AnNrg
      Temp_GSim1.TotEnrg  = Total(Fil_ANNrg)

      GsimData1 = [GsimData1, Temp_GSim1]
      ;    print, temp_Gsim1
      ;     stop
      Skip_Event:

      ;      If i gt 50 then stop
      if i mod 10000 eq 0 then print,i

    Endfor ; i
    print, n_elements(gsimdata1[where(gsimdata1.EvClass eq 3)])
    print, n_elements(gsimData1)
    If n_elements(GsimData1) Then GsimData1 = GsimData1 else  GsimData1=GsimData1[1:N_Elements(GsimData1)-1]

    WriteU, Lun1, GSimData1
    Free_Lun, Lun1


  Endfor ; p
  ; Stop
End