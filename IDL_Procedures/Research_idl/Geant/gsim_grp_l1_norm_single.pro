Pro GSim_GRP_l1_norm_single, fsearch_String, title=title, bin=bin

  ;
  ; This is a general program to normalize a single l1 file. 

  True =1
  False=0
  If Keyword_Set(bin) Eq 0 Then bin = 1            ; Bin Size
  IF Keyword_Set(title) Eq 0 Then Title='Test'
  
;
;-- Normalization Factors --
;

; Primary  [395.50583,4.07616, 0.345251]

  N = 10000000

  Scl_Const = 1         ; A
  Scl_Int =  0.345251 ; MEV
  Scl_geo =       2* !PI       ; Str
  Scl_area=   !PI* 1.20*1.20    ; m^2
  Scl_Factor = Scl_Const * Scl_Int* Scl_Area * Scl_Geo /N     ; This is 1.2 and not 120 for the m^2 and only hemisphere steradian(6.2832 = 2 Pi) 0~90

;
;-- Out file 
;
  ;title1 = title+'_l1_priproton.txt'
  ;title1 = title+'_l1_prielectron.txt'
 title1 = title+'_l1_pripositron.txt



  ;
  ;=== Get single or multiple files ====
  ;
  tsimfile = file_search(fsearch_string)
  n_tfiles = n_elements(tsimfile)
  
  if n_tfiles gt 1 then begin
      print, ' more than 1 file'
      Stop
    
  endif


 
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




 ; For p = 0, Nfiles-1 Do Begin

    infile = GsimFile

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
      ; Software Class
      ;
      EvtClass = 0
      If NoCal GT 0 Then Begin
        If (NoCal EQ 1) Then Begin
          If NoPla Eq 0 Then EvtClass = 1 Else Begin
            If Nopla Eq 1 Then EvtClass = 3 Else If NoPla Eq 2 Then EvtClass = 6 Else if NoPla Gt 2 Then EvtClass = 7
          EndElse
        Endif Else if NoCal Gt 1 Then begin
          If NoCal eq 2 then EvtClass = 2 Else EvtClass = 7
        Endif
      EndIf Else BEgin ; This is if no_cal =0
        If Nopla EQ 1 Then EvtClass = 5 Else If NoPla Eq 2 Then EvtClass = 4 Else EvtClass = 7
      Endelse

      If EvtClass Eq 0 Then Goto, Skip_Event
      If NoAn GT 2 Then goto, Skip_Event

      tot_nrg = total(NewAnNrg)

      ;PC
      If (evtclass Eq 3) and (NoAn eq 2) Then begin
        PC_Hist = [PC_Hist,tot_nrg]
      EndIF
      Skip_Event:
    Endfor ; i (events. per file)

    help, pc_Hist
    Temp_HistPC = CGHistogram(PC_Hist[1:n_elements(PC_Hist)-1], BINSIZE=bin, Locations=XArray, MAX=1000, MIN=0)

    Print, ' **************************** '

;  Endfor ; p

  temp_Hist_err = scl_factor*sqrt(abs(Temp_HistPC))

  Temp_Hist = Temp_HistPC * Scl_factor


   cgplot, indgen(N_elements(temp_hist)), temp_hist, psym=10, /YLog, /Xlog , Xrange=[30,500]
   print, temp_hist
  ;   xtitle= 'Energy(keV)', ytitle= 'Counts/s/keV', Title='PC All'




  openw, lun1, title1,/Get_Lun

  for i = 0, 999 do begin
    Printf, Lun1, Strn(temp_hist[i]), ' ', strn(temp_hist_err[i])
  endfor
  free_lun, lun1
End