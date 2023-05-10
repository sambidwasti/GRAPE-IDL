Pro GSim_GRP_l1_qlook, fsearch_String, title=title
  ; This is a quicklook program to read in the level 1 file.
  
  True =1
  False=0


  ;
  ;=== Get single or multiple files ====
  ;
  gSimFile = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
  nfiles = n_elements(gSimfile)



  ;
  ;===Software Energy Thresholds (keV) ===
  ;
;  Cal_Min = 30.0
;  Cal_Max = 400.0
;
;  Pla_Min = 10.0
;  Pla_MAx = 200.0
;
;  Print, 'C', Cal_Min, Cal_Max
;  Print, 'P', Pla_Min, Pla_Max

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


    infile = GsimFile[0]


    ;
    ;-- Define few of the file variables.
    ;
    F = File_Info(infile)           ; get inout file info
    Nevents = Long(f.size / Struc1_Size)            ; get number of events in input file
    GsimData1 = replicate(GSim_Struc_1, nevents)    ; initialize input data array

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

      readu, Lun, GSim_Struc_1        ; read one event
      GsimData1[i] = GSim_Struc_1       ; add it to input array
    Endfor
    Free_lun, Lun

    MOdID_Hist=LonArr(32)

    ;
    ;---- Process the file -----
    ;
    For i =0L, nevents-1 do Begin

      data = GsimData1[i]        ; so we have stored the structure in data.


      if data.mod_id ne 0 then MOdID_HIST[fix(data.Mod_ID)]++


      EvtClass = 0
      ;
      ;-- Event Class --  May 18 changed from hardware to software.
      ;C = 1, CC =2, PC =3, PP =4, PPC =6 more than 2 events 7 for now. P =5
      ;
;      EvtClass = 0
;      If No_Cal GT 0 Then Begin
;        If (No_Cal EQ 1) Then Begin
;          If No_Pla Eq 0 Then EvtClass = 1 Else Begin
;            If No_pla Eq 1 Then EvtClass = 3 Else If No_Pla Eq 2 Then EvtClass = 6 Else if No_Pla Gt 2 Then EvtClass = 7
;          EndElse
;        Endif Else if No_Cal Gt 1 Then begin
;          If No_Cal eq 2 then EvtClass = 2 Else EvtClass = 7
;        Endif
;      EndIf Else BEgin ; This is if no_cal =0
;        If No_pla EQ 1 Then EvtClass = 5 Else If No_Pla Eq 2 Then EvtClass = 4 Else EvtClass = 7
;      Endelse


      Skip_Event:

      ;      If i gt 50 then stop
      if i mod 10000 eq 0 then print,i

    Endfor ; i
        Print, ' **************************** '
        print, modid_hist
    CGPLOT, Indgen(n_elements(ModID_HIST)),MODID_HIST, psym=10

End