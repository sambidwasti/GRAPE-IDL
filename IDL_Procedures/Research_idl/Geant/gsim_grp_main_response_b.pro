Function GSim_GRP_Main_response_b, infile, title=title, bin=bin, N=N, Input_Ener= Input_Ener, Class=Class, type=type

  ; Similar to Gsim_Grp_Main_Response_a but checking effective area for hardware threshold
  ; This is a general program to normalize a single l1 file.
  ; This is a modification of GsimGrp l1 norm single program.
  ; That has a scaling constant but for single gamma, mainly for the response matrix its 1.
  ; Also making sure this iwll hace a keyword for N.
  ; Currently The scale factor is 1. This has to be function for our purpose so renaming atm.
  ;
  ;This has to return a matrix with Energies?
  ;Need to check whether the input energy is consistent.
  ;1 file at a time.
  ; March 16: Sambid Wasti
  ;           Adding the class keyword
  ;           Adding the type keyword
  ;


  True =1
  False=0
  ; If Keyword_Set(bin) Eq 0 Then bin = 1            ; Bin Size
  IF Keyword_Set(title) Eq 0 Then Title='Test'
  If Keyword_Set(class) eq 0 then Class= 3

  Type_Flag= 0
  If Keyword_set(type) ne 0 Then Type_Flag = 1



  N =1; 10000000

  ; depends on the simulated geometry.
  ; Verify the run in that respect.
  Scl_Const = 1         ; A
  Scl_Int = 1; 10.345251 ; MEV
  Scl_geo =   1;    2* !PI       ; Str
  Scl_area= 1;  !PI* 1.20*1.20    ; m^2
  Scl_Factor =1/N; Scl_Const * Scl_Int* Scl_Area * Scl_Geo /N     ; This is 1.2 and not 120 for the m^2 and only hemisphere steradian(6.2832 = 2 Pi) 0~90

  ;
  ;-- Out file
  ;
  title1 = title;



  ;
  ;=== Get single or multiple files ====
  ;
  tsimfile = file_search(infile)


  gSimFile = tsimfile
  CD, Cur = Cur


  ;
  ;===Software Energy Thresholds (keV) ===
  ;
  Cal_Min = 40.0
  Cal_Max = 400.0

  Pla_Min = 10.0
  Pla_MAx = 200.0

  Total_Min = 0.0
  Total_MAx = 600.0

  Print, 'C', Cal_Min, Cal_Max
  Print, 'P', Pla_Min, Pla_Max

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
  ;-- Define few of the file variables.
  ;
  F = File_Info(infile)           ; get inout file info
  Nevents = Long(f.size / Struc1_Size)            ; get number of events in input file
  GsimData1 = replicate(GSim_Struc_1, nevents)    ; initialize input data array

  print, infile
  openr, Lun, infile , /Get_Lun
  For i = 0L, nevents-1 do Begin

    readu, Lun, GSim_Struc_1        ; read one event
    GsimData1[i] = GSim_Struc_1       ; add it to input array
  Endfor
  Free_lun, Lun

  Print
  Print, ' **************************** '
  Print, ' File :', infile
  Print, Nevents
  Print

  PC_Hist = [0.0]

  ;
  ;--- Open and read teh file in --
  ;

  For i = 0L, nevents-1 do Begin

    data = GsimData1[i]        ; so we have stored the structure in data.

    If Input_Ener NE data.in_Enrg Then Begin
      If data.in_enrg EQ 0.0 Then goto, skip_event

      print, i, '**I**'
      Print, data
      Print, 'Input Energy:'+Strn(Data.In_Enrg)+' Not Equal with file name energy:'+Strn(Input_Ener)
      stop
    EndIf
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
    ; Hardware Class
    ;
    EvtClass = 0
    If NoCal GT 0 Then Begin
      
      If (NoCal EQ 1) Then Begin
        
        If NoPla Eq 0 Then EvtClass = 1 Else EvtClass = 3
        
      Endif Else EvtClass = 2
      
    EndIf Else EvtClass = 9 

    If EvtClass Eq 0 Then Goto, Skip_Event
    If NoAn GT 2 Then goto, Skip_Event

    tot_nrg = total(NewAnNrg)


    ;PC
    ; If (evtclass Eq 3) and (NoAn eq 2) Then begin
    If (evtclass Eq class) Then begin
      if type_flag eq 1 then begin
        If  Eventtype(newAnID[0],NewAnID[1]) ne Type then goto, skip_event
      endif
      PC_Hist = [PC_Hist,tot_nrg]
    EndIF
    Skip_Event:
  Endfor ; i (events. per file)

  If n_elements(PC_HIST) GT 1 Then Temp_HistPC = CGHistogram(PC_Hist[1:n_elements(PC_Hist)-1], BINSIZE=1, Locations=XArray, MAX=1000, MIN=0) Else Temp_HISTPC = PC_HIST

  Print, ' **************************** '


  temp_Hist_err = scl_factor*sqrt(abs(Temp_HistPC))

  Temp_Hist = Temp_HistPC * Scl_factor
  ;  Help, Temp_Hist

  Return, Temp_Hist


End