Pro GSim_GRP_com_sec_proton_down, fsearch_String, title=title, bin=bin, N=N, Type = Type, foldername = foldername, Class = Class, Sep = Sep

  ;
  ; This is to normalize and combine the secondary Proton downward flux
  ; There are 7 files. They are the lvl1.dat  (l1 process files)
  ; The flux is in c /( s m^2 sr MeV )
  ; Sambid Wasti : 02/21/2018 
  ; Commented and Idented properly
  
  ; === Initialization/ Defining variables ===
  ;
  True =1
  False=0

  If keyword_Set(N) Eq 0 then N = 10000000
  
  If Keyword_Set(bin) Eq 0 Then bin = 1            ; Bin Size
  IF Keyword_Set(title) Eq 0 Then Title='Test'

  type_Flag= false
  If Keyword_SEt(Type) NE 0 Then Type_Flag = true

  folderflag = False
  If keyword_set(foldername) ne 0 then folderflag = true
  
  gsimfile = file_search(fsearch_string)
  nfiles = n_elements(gsimfile)

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


  ;~~~ Software Energy Thresholds (keV) ~~~
  ;
  Cal_Min = 40.0
  Cal_Max = 400.0

  Pla_Min = 10.0
  Pla_MAx = 200.0

  Total_Min = 50.0
  Total_MAx = 600.0

  ; ~~~~ Level 1 Processing ~~~~
  ;
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

  ;=== For Each Files
  ;
  For p = 0, Nfiles-1 Do Begin

    infile = GsimFile[p]

    F = File_Info(infile)           ; get inout file info
    Nevents = Long(f.size / Struc1_Size)            ; get number of events in input file
    GsimData1 = replicate(GSim_Struc_1, nevents)    ; initialize input data array

    openr, Lun, infile , /Get_Lun
    For i = 0L, nevents-1 do Begin
      readu, Lun, GSim_Struc_1        ; read one event
      GsimData1[i] = GSim_Struc_1       ; add it to input array
    Endfor
    Free_lun, Lun

    Print, ' **************************** '
    Print, ' File :', infile
    Print, ' No. Of Events :',Nevents

    Temp_Hist = [0.0]

    ;~~ Process Each Event ~~
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
 ;   Print,n_elements(Temp_Hist)
    If N_Elements(Temp_Hist) Eq 1 Then Temp_Hist = IntArr(1000)*0 Else Temp_Histogram = CGHistogram(Temp_Hist[1:n_elements(Temp_Hist)-1], BINSIZE=bin, Locations=XArray, MAX=1000, MIN=0)

    if p eq 0 then hist0= Temp_Histogram else if p eq 1 then hist1= Temp_Histogram else if p eq 2 then hist2 = Temp_Histogram else if p eq 3 then hist3 = Temp_Histogram $
    else if p eq 4 then hist4 =Temp_Histogram else if p eq 5 then hist5 = Temp_Histogram else if p eq 6 then hist6 = Temp_Histogram

  Endfor ; p

  ; == Scaling Factors ==
  ; There are 7 files
  Scl_ang = [5,15,25,35,45,55,60]
  rad_ang = !DtoR*scl_ang
  y = cos(rad_ang)
  scl_cos = 1/y
  ; Integrating steredian for solid angle gives
  ; 2pi* - costheta (theta =a,b)
  ; we have 0-10,10-20,20-30,30-40,40-50,50-60,60-90
  ; Wolfram alpha = 0.0954558, 0.283467, 0.462865, 0.628199, 0.774446, 0.897173, 3.1416
  scl_str = [0.0954558, 0.283467, 0.462865, 0.628199, 0.774446, 0.897173, 3.1416]
  mev_Const = 92.4560+23.8381
  Scl_Factor = mev_Const*scl_str*scl_cos * !PI* 1.20*1.20/N     ; This is 1.2 and not 120 for the m^2
  
  
  hist0_err = scl_factor[0]*sqrt(abs(hist0))
  hist1_err = scl_factor[1]*sqrt(abs(hist1))
  hist2_err = scl_factor[2]*sqrt(abs(hist2))
  hist3_err = scl_factor[3]*sqrt(abs(hist3))
  hist4_err = scl_factor[4]*sqrt(abs(hist4))
  hist5_err = scl_factor[5]*sqrt(abs(hist5))
  hist6_err = scl_factor[6]*sqrt(abs(hist6))

  hist0 = scl_factor[0]*hist0
  hist1 = scl_factor[1]*hist1
  hist2 = scl_factor[2]*hist2
  hist3 = scl_factor[3]*hist3
  hist4 = scl_factor[4]*hist4
  hist5 = scl_factor[5]*hist5
  hist6 = scl_factor[6]*hist6

  hist_tot = hist0 + hist1 + hist2 + hist3 + hist4 + hist5 + hist6
  hist_err = sqrt(hist0_err*hist0_err + hist1_err*hist1_err + hist2_err*hist2_err + hist3_err*hist3_err + hist4_err*hist4_err +hist5_err*hist5_err + hist6_err*hist6_err)
  
  ; Cgplot, Hist_tot
  
  If Type_Flag eq true Then title1=title+'_Type_'+Strn(Sel_Type) Else Title1=title
  If Sep_FLag eq true then title1 =title1 +'_AnSep'+STrn(Sep) Else Title1= Title1

  foldername1 =''
  if folderflag eq true then begin
    if type_flag eq true then foldername1 = 'Type'+Strn(Sel_Type)+'/' else foldername1='TypeAll/'

    foldername1 = foldername+foldername1
  endif else foldername1 = foldername1

  openw, lun1,foldername1+title1+'_'+Evt_Text+'_l1_SecDownProt_com.txt',/Get_Lun
  
  for i = 0, 999 do begin
    Printf, Lun1, Strn(hist_tot[i]), ' ', strn(hist_err[i])

  endfor
  free_lun, lun1

End