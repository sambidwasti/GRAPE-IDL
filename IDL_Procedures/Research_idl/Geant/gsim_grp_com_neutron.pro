Pro GSim_GRP_com_neutron, fsearch_String, title=title, bin=bin, N=N, Type = Type, Class=Class, foldername=foldername , Sep = Sep
  ; The neutron normalization procedure.
  ; The neutron spectrum input was following the Simpsons and Armstrongs (1973)
  ;
  ; It is programmed to only do a selection of PC Events atm.
  ;
  ; It works on the presumption that there are three files,
  ;   Neutron 1, 2, 3 (Usually Neutron 1 is empty as energy threshold too low)
  ;
  ; Step 1) Read the file and process it until it histograms it.
  ;
  ; read teh individual available files
  ; Figure out which spectrum it is
  ; And normalize accordingly
  ; different Constant types
  ; Same angle normalization
  ;


  ;
  ;==== Defining Variables =====
  ;
  True =1
  False=0

  If keyword_Set(N) Eq 0 then N = 10000000
  
  if keyword_set(foldername) eq 0 then foldername = '' else foldername = foldername ;
  folderflag = False
  If keyword_set(foldername) ne 0 then folderflag = true


  type_Flag= false
  If Keyword_SEt(Type) NE 0 Then Type_Flag = true

  If Keyword_Set(bin) Eq 0 Then bin = 1            ; Bin Size

  IF Keyword_Set(title) Eq 0 Then Title='Test'

  gSimFile = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
  nfiles =n_elements(gsimFile)                      ; no. of files
  CD, Cur = Cur

  Event_Class = 3
  If keyword_set(Class) ne 0 then Event_Class = Class
  If event_class gt 3 then Event_Class = 7

  If (Event_Class NE 3) and (Event_Class NE 2) Then Type_Flag = False  ; Fail Safe for Type Flag
  If Type_flag Eq True then Sel_Type = Type Else SEl_TYpe=0
  If Sel_Type GT 4 then Type_Flag = False


  Sep_Flag = False
  If keyword_set(Sep) ne 0 then Sep_Flag =True
  If (Event_class NE 3) and (Event_Class NE 2) Then Sep_Flag = False ; Fail Safe for Sep_Flags

  IF Sep_Flag eq true then Sep = Sep else sep = 0

  ;
  ;For output file.
  ;
  IF Event_Class Eq 3 then Evt_Text = 'PC' Else IF Event_Class Eq 2 then Evt_Text = 'CC' Else If Event_Class Eq 1 Then Evt_Text = 'C' Else Evt_Text = 'Other'

  ;
  ;===Software Energy Thresholds (keV) ===
  ;
  Cal_Min = 40.0
  Cal_Max = 400.0

  Pla_Min = 10.0
  Pla_MAx = 200.0

  Total_Min = 50.0
  Total_MAx = 600.0

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

  Neutron_Hist1 = LonArr(1000)
  Neutron_Hist2 = LonArr(1000)
  Neutron_Hist3 = LonArr(1000)

  For p = 0, Nfiles-1 Do Begin

    infile = GsimFile[p]

    ;
    ;~~ Per file variables ~~
    ;

    F = File_Info(infile)           ; get inout file info
    Nevents = Long(f.size / Struc1_Size)            ; get number of events in input file
    GsimData1 = replicate(GSim_Struc_1, nevents)    ; initialize input data array

    openr, Lun, infile , /Get_Lun
    For i = 0L, nevents-1 do Begin

      readu, Lun, GSim_Struc_1        ; read one event
      GsimData1[i] = GSim_Struc_1       ; add it to input array
    Endfor
    Free_lun, Lun

;    Print
;    Print, ' **************************** '
;    Print, ' File :', infile
;    Print, Nevents
;    Print

    Temp_Hist = [0.0]

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

      If EvtClass Eq 0 Then Goto, Skip_Event

      tot_nrg = total(NewAnNrg)


      ;Event Class filter.
      If evtclass Eq Event_Class Then begin

        If Type_Flag Eq true then Begin
          If Sel_Type Eq 4 Then begin
            
            If (EventType(NewAnID[0],NewAnID[1]) Eq 2 ) Or (EventType(NewAnID[0],NewAnID[1]) Eq 3 ) Then Begin
                Temp_Hist = [Temp_Hist, TOt_Nrg]
            Endif
         
          EndIF Else If Sel_Type Eq  EventType(NewAnID[0],NewAnID[1]) Then begin

              If Sep_Flag eq true then begin

                IF Grp_Anode_Separation(NewANID[0],NewAnID[1]) GE SEp then  Temp_Hist = [Temp_Hist, TOt_Nrg]

              Endif else  Temp_Hist = [Temp_Hist, TOt_Nrg]

          endif ; Sel Type.
          
          
        EndIf Else  Temp_Hist = [Temp_Hist,tot_nrg] ; Type Flag
      EndIF ; EventClass
      
      Skip_Event:
    Endfor ; i (events. per file)

    Temp_Histogram = CGHistogram(Temp_Hist[1:n_elements(Temp_Hist)-1], BINSIZE=bin, Locations=XArray, MAX=1000, MIN=0)
    If StrPos(Infile,'Neutron1',0) GT 0 Then neutron_hist1 = Temp_Histogram  Else IF StrPos(Infile,'Neutron2',0) GT 0 Then neutron_hist2  = Temp_Histogram Else IF StrPos(Infile,'Neutron3',0) GT 0 Then neutron_hist3 = Temp_Histogram 

  Endfor ; p

  ;
  ;== So we have the neutrons on the separate arrays.
  ; now need to scale them and add.
  ;

  ;
  ; == Scaling Factors ==
  ; This is different than the other ones. The other ones had a different angular sections but this one has a different constants.
  ; The 120 is the 120 cm surrounding sphere. (1.2 m)
  ; The input is counts/ s / sr/ MeV/ m^2
  scale_str = !PI*4     ; Isotropic so 4pi (sr)s
  scale_cons= [3.9402, 682.67, 102.87]   ; (MeV)
  Scl_val = scale_str*scale_cons
  Scl_Factor = scl_val * !PI* 1.20*1.20/N ;(m^2)

;  Print, Scl_Factor

  Neutron1_Err = Scl_Factor[0]*Sqrt(abs(Neutron_hist1))
  Neutron2_Err = Scl_Factor[1]*Sqrt(abs(Neutron_hist2))
  Neutron3_Err = Scl_Factor[2]*Sqrt(abs(Neutron_hist3))

  Neutron_1 = Scl_Factor[0]*Neutron_hist1
  Neutron_2 = Scl_Factor[1]*Neutron_hist2
  Neutron_3 = Scl_Factor[2]*Neutron_hist3

  Neutron = Neutron_1 + Neutron_2 + Neutron_3
  Neutron_Err = Sqrt(Neutron1_Err*Neutron1_Err + NEutron2_Err*NEutron2_Err + NEutron3_Err*NEutron3_Err)
;
;
;  window,0
;  cgplot, xarray, neutron_3, psym=10, /YLog, /Xlog , Xrange=[30,500], XStyle=1, YRange=[1E-7,2], YStyle=1, YMinor=10,$
;    xtitle= 'Energy(keV)', ytitle= 'Counts/s/keV', Title='Neutrons Sum (Blue), N2 (red), N3(Orange)', color='Orange'
;  cgoplot, xarray, neutron_2, psym=10, color ='Red';, YRange=[1E-7,1], YStyle=1, YMinor=10,$
;  cgoplot, xarray, neutron, psym=10, color ='Blue';, YRange=[1E-7,1], YStyle=1, YMinor=10,$

  If Type_Flag eq true Then title1=title+'_Type_'+Strn(Sel_Type) Else Title1=title
  If Sep_FLag eq true then title1 =title1 +'_AnSep'+STrn(Sep) Else Title1= Title1

  foldername1 =''
  if folderflag eq true then begin
    if type_flag eq true then foldername1 = 'Type'+Strn(Sel_Type)+'/' else foldername1='TypeAll/'
    foldername1 = foldername+foldername1
  endif else foldername1 = foldername

  openw, lun1,foldername1+title1+'_'+Evt_Text+'_l1_Neutron_com.txt',/Get_Lun
  for i = 0, 999 do begin
    Printf, Lun1, Strn(neutron[i]), ' ', strn(neutron_err[i])
  endfor
  free_lun, lun1

End