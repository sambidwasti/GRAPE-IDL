Pro GSim_GRP_readcsv2_a, fsearch_String, nfiles=nfiles
  ; Temporarily modifying this from readcsv2 to verify whether the procedure is doing what its expected
  ;   - Checking if the energies are being added
  ;   - Checking if i am doubling the energies somehow
  ;   - Checking if things are being done properly. 
  ;  Readcsv2_b is reading 4.9.6 That was done to see the difference in physics and other output to verify
  ;  neutron sims.
  ;  
  ; Updated from ReadCSV1. to read in version grape 8.1
  ;
  ;
  ;   Outputs gsim file
  ;   GSim = Geant Related IDL procedures.
  ;   Grp Sims. Reading the CSV file
  ;   ReadCol has the ability to read a comma separated or space separated columns
  ;   ENERGY IS THE UNCORRECTED:
  ;  Revision History: May 11 2016:
  ;         Sambid Wasti :  -adding features to do the processing for multiple files at once.
  ;                         -fixed an issue where the long formatting of no. of events got truncated
  ;                         from scientific notation. Example: 1.0 E12 was being read as 1.
  ;                         -adding a feature to deal with more than 8 anodes triggered which should not be reported
  ;                         in the output
  ;                         - Note the event class here is the hardware classification. However, this is not that
  ;                         important since the energy broadening is applied in the next stage of processing
  ;                         and reclassified.
  ;
  ;  May 18, 2016 Sambid Wasti
  ;                      :  - Reclassifying to the software threshold since it helps to understand the
  ;                         physics of the interaction in next section better.
  ;                         Used for the A1.2 and A1.3
  ;
  ;  May 24, 2016 Sambid Wasti
  ;                      ;  - In order to recreate the hardware output with hardware threshold, we redefine
  ;                         the classification to hardware classificiation with hardware threshold. We would apply
  ;                         the hardware threshold in the next stage.
  ;
  ;  Feb 22, 2017 Sambid Wasti
  ;                      ; - The shield events are not being veto-ed which needed correction.
  ;                      ; - can either add a flag or remove the events.
  ;                      ; - removing the event for now. If needed to analyze the shield rates, it needs to be added here.
  ;
  ;  EventType is not there yet. Its in the further processing.
  ;
  ;  =------=== for version 8.1
  ;  Steps:
  ;  Read 1 event at a time.
  ;  The shields are not an issue anymore as there is a shield threshold and use that to Veto out
  ;  Its set at 400 keV
  ;  the energy conversion is being done.
  ;  also adding a counter to keep track of how many ion ionization occurs.
  ;  need to remove the event type flag for the events.

  ;
  ;==== Initiation (Defining variables, structure, etc)
  ;
  True = 1
  False = 0


  AC_Threshold = 400.0D ; keV

  CsvFiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
  If keyword_set(nfiles) NE 1 Then nfiles = n_elements(Csvfiles)

  ;
  ; Define the structure for each events.
  ;
  GSim_Struc = { $
    VERNO           :0B,            $   ; Data format version number

    In_Enrg         :0.0,           $   ; Incident Source

    NAnodes         :0B,            $   ; Number of triggered anodes (1-8)
    NPls            :0B,            $   ; Number of triggered plastic anodes
    NCal            :0B,            $   ; Number of triggered calorimeter anodes

    EvType          :0B,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)only for Nanodes 2
    EvClass         :0B,            $   ; C = 1, CC =2, PC =3,(P,PP,PPP =0)

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types (Cal=1, Pla =2, Invalid =-1) Weird but thats how it has been used.

    IM_Flag         :0B,            $   ; Intermodule flag
    Mod_ID          :0B,            $   ; Module ID

    AnodeNrg        :FltArr(8),     $   ; Array of triggered anode energies Corrected

    TotEnrg         :0.0            $
  }
  Stuc_Size = 64

  NO_Event = 0L
  No_Event_1 = 0L
  No_Event_2 = 0L


  ;
  ;==== For Each files
  ;
  For p = 0,nfiles-1 Do begin
    Infile = CsvFiles[p]
    print, infile
    ;
    ; The Columns of these data files are as follows
    ; RunID EventID SourceEnergy Type(plastic/cal [2/1]) Cluster(ModuleID) Anodeno EnergyDeposited
    ;
    ReadCol, Infile, runID0, eventID0, SourceNrg0, SctTyp0, FMID0, AnodeID0, DepNrg0, Phys0, Particle0, ParticleMass0 ,/Silent, $
      format='A,LL,D,LL,LL,LL,D,A,A,D', Delimiter = ','

    GSim_Data = Gsim_Struc

    ;    OldLoc = where( runID0 Eq '&')  ; Gives teh array location of the older format style.
    ;    runID = runID0[where( runID0 Eq '&')]
    ;    eventID = eventID0[where( runID0 Eq '&')]
    ;    SourceNRg = SourceNrg0[where( runID0 Eq '&')]
    ;    SctTyp = SctTyp0[where( runID0 Eq '&')]
    ;    FmID = FMID0[where( runID0 Eq '&')]
    ;    AnodeID = AnodeID0[where( runID0 Eq '&')]
    ;    DepNrg = DepNRg0[where( runID0 Eq '&')]

    runID = runID0
    eventID = eventID0
    SourceNRg = SourceNrg0
    SctTyp = SctTyp0
    FmID = FMID0
    AnodeID = AnodeID0
    DepNrg = DepNRg0
    PHys = Phys0
    PartMass = ParticleMass0

    ; ~~~ Output file naming ~~~
    ;
    OutPos = StrPOs(Infile,'.csv',0)
    OutFile = INfile
    StrPut, OutFile, '.gsi',OutPos
    OutFile = Outfile + 'm.csv.dat'
    Openw, Lun2, Outfile, /Get_Lun

    ;~~~~~ Additional Variables ~~~~~~
    ;
    EvtID = 0L                ; A counter to see some information (Stats)
    EvClass = LonArr(4)       ; Array of Event Class Counters to see the stats at the end of each file

    ;~~~~ Per event Variables ~~~~
    No_Anodes   = 0L          ; A counter for no. of anodes triggered
    TempType    = [-5]        ; Array to store All Type   (AC and Scint)
    TempMod     =[-5]         ; Array to store Module No. (AC and Scint)
    TempAnID    =[0]          ; Array to store All ID     (AC and Scint)
    TempNRG     =[0.0D]        ; Array to store All Energies(AC and Scint)

    No_Pla      = 0L          ; No of Plastics Triggered
    No_Cal      = 0L          ; No of Calorimeters Triggered

    AnID_Arr    = INTArr(8)   ; Arrays of size 8 for max 8 events
    AnTyp_Arr   = INTArr(8)   ; Arrays of size 8 for max 8 events
    AnNRG_Arr   = FltARr(8)   ; Arrays of size 8 for max 8 events

    Temp_AC_ENERGY = DblArr(6)  ; AC Energy Array, Setting it for 6 acs
    Temp_anode_NRG = DblArr(64) ; Anode Energy Array Setting it for 64 Anodes
    Temp_Anode_Typ = IntArr(64) ; Anode Types Setting it for 64 Anodes

    Ion_Flag       = False    ; A flag with the counter to track the statistics of Ion-Ionization
    Ion_Counter    = 0L       ; Counter to track Statistics
    Ion_Counter1   = 0L       ; Counter to track Statistics

    Pre_EvtID      = 0        ;

    Misc_Counter   = 0L
    ; ~~~ Print ~~~
    Print,'No. of lines =', N_Elements(runID)
    
    Temp_CheckEvt = LonArr( (EventId[N_elements(EventId)-1] ) +1 )
    
    ;
    ;==== READING EACH LINE ====
    ;
    For i = 0,N_Elements(runID)-1 Do Begin

      Cur_EvtID = EventID[i]                        ; Define current event id
    
     ; Print, Cur_EvtID
      Temp_checkEvt[Cur_EvtId] = 1                  ; Changing the flag value of the event to 1. 

      If RunId[i] eq '&' Then goto, Skip_line       ; Skip this line (This is the output of previous version) Is a good check.


      ;~~~~ Same Event ~~~~~
      ;
      If Cur_EvtID Eq Pre_EvtID Then Begin

        ;----Read each line and group them---
        ;
        Temp_FMID     = Double(FMID[i])             ; Module ID
        Temp_DepNrg   = Double(DepNrg[i])           ; Energy Deposited
        Temp_Phy      = Phys[i]                     ; Physics of the process
        Temp_PartMass = partmass[i]                 ; Particle Mass (Though not needed)

        ;=== Electron Equivalent Conversion for Ions
        ;
        If (Temp_Phy Eq 'ionIoni') then begin
         
          Temp_Conv_Ener = Gsim_Grp_Equi_Nrg_Alpha(Temp_DepNrg)
         ;  Temp_Conv_Ener = Temp_DepNrg
          Ion_flag = true
          Ion_Counter++
        Endif

        ;=== Electron Equivalent Conversion for Protons
        ;
        If (Temp_Phy Eq 'hIoni')  Then begin
          ; Get the electron equivalent energy for proton equivalent

          Temp_Conv_Ener = Gsim_Grp_Equi_Nrg_Proton(Temp_DepNrg)
          ;Temp_Conv_Ener = Temp_DepNrg
        Endif Else Temp_Conv_Ener = Temp_DepNrg

        ;~~~~~ Event Arrays ~~~~~~
        ;Note: Storing everything and separating it in the next step
        ;
        TempMod  = [TempMod, FMID[i] ]          ; Module ID
        TempAnID = [TempAnID, AnodeID[i]]       ; Anode ID
        TempNRG  = [TempNRG, Temp_Conv_Ener]    ; Energy Array
        TempType = [TempType,SctTyp[i]]         ; Type Array

      Endif Else Begin ; If not the same event. Its a different event so the whole event is being processed.

        If i eq 0 then goto, skip_event         ; A failsafe for the first loop.

        ;Print, '~~~~~~~~~~~~'
        ;Print, Pre_EvtID
        ;PRint, 'AnID :',TempAnID
        ;Print, 'AnNrg:',TempNRG
        ;PRint, 'ANTyp:',TempType
        ;~~~~ Separate the blocked group ~~~~~~
        for j = 1, N_elements(TempAnId)-1 Do BEgin  ; NOTE:start at 1 because first one is not data
          If TempType[j] Eq 0 Then BEgin  ;If its AC
            ;add energies. (There are 4 AC channels)
            temp_ac_pos = TempMod[j]
            Temp_AC_ENERGY[temp_ac_pos] = Temp_AC_ENERGY[temp_ac_pos] + TempNrg[j]
            ; Print, 'AC0', Temp_ac_pos, TempNrg[j], TempType[j]

          Endif Else BEgin  ; if its not AC
            ;Sum up the energies
            temp_anode_pos = TempAnID[j]
            Temp_Anode_Nrg[temp_anode_pos] = Temp_Anode_Nrg[temp_anode_pos]+ TempNrg[j]
            Temp_Anode_Typ[temp_anode_pos] = TempType[j]
            ModNo = TempMod[j]
            ; Print, 'Scint', Temp_anode_pos, TempNrg[j], TempType[j]
          Endelse
        endfor  ;-- Src energy and module no.
        ;~~ The AC and Scint are sorted now ~~

        ;
        ;
        Temp_B = where(Temp_anode_Nrg GT 0.0, count)      ; Scint Anode ID that has been triggered.
        No_anodes = count
        
        No_Event_1++
        If No_Anodes LE 0 Then goto, Skip_Event

        ; Misc_Counter++
        ; Print, Temp_AC_Energy
        ; If Misc_Counter gE 2 Then Stop

        If ion_flag eq true then Ion_Counter1++

        ; Now we check the Shield Threshold to veto
        No_Event_2++
        For j=0,5 do begin
          If Temp_AC_Energy[j] GT AC_Threshold Then Goto, Skip_Event ; Condition to Veto the event out.
        Endfor

        ; Process the non-veto Valid events..
        Src_Nrg = 999.00

        ;Need anode id informations.
        Temp_Type     = Temp_Anode_Typ[Temp_B]   ; Scint Anode Types
        Temp_AnID     = Temp_B                   ; Scint Anode ID
        Temp_Nrg      = Temp_Anode_Nrg[Temp_B]   ; Scint Anode Energy

        ; ~~~~ Need this as this condition present in the Hardware ~~~~
        ; First 8
        If No_anodes GE 8 Then No_Anodes =8
        For k = 0,No_Anodes-1 Do Begin
          AnTyp_Arr[k]=Temp_Type[k]
          AnNRG_Arr[k]=Temp_NRG[k]
          AnID_Arr[k]=Temp_AnID[k]
          If TempType[k] Eq 1 Then No_Cal++ Else If TempType[k] EQ 2 Then No_Pla++
        Endfor

        ;
        ;-- Event Class --  May 24 update
        ;C = 1, CC =2, PC =3, all PPs are 0
        ;

        EvtClass =0
        If No_Cal Gt 0 Then Begin ; If there are no calorimeter it is 0. We do not read these in hardware.
          If No_Pla GE 1 Then EvtClass = 3 Else BEgin
            If No_Cal EQ 1 Then EvtClass = 1 Else EvtClass = 2
          EndElse
        Endif

        ;
        ;~~~~~~Store in the structure ~~~~~~~~~~~~
        ;
        Temp_gsim = Replicate(Gsim_Struc, 1)

        Temp_Gsim.VerNo    = 3
        Temp_GSim.In_Enrg  = Src_Nrg          ; This is not correct atm
        Temp_GSim.NAnodes  = No_Anodes
        Temp_GSim.Npls     = No_Pla
        Temp_GSim.Ncal     = No_Cal

        Temp_GSim.EvType   = 0
        Temp_GSim.EvClass  = EvtClass

        Temp_GSim.AnodeID  = AnID_Arr
        Temp_GSim.AnodeTyp = AnTyp_Arr

        Temp_GSim.IM_Flag  = 0                ; Not Obsolete atm
        Temp_GSim.Mod_ID   = ModNo

        Temp_GSim.AnodeNrg = Float(AnNRG_Arr)
        Temp_GSim.TotEnrg  = Float(TOTAL(double(AnNRG_Arr)))

        GSim_Data = [GSim_Data,Temp_Gsim]
        ;~~~~~~~~~~~~~~~~

        NO_Event++
        EvClass[EvtClass]++

        ;===== SKIP EVENT =====
        Skip_Event:
        EvtID++

        ;==== RESET Parameters
        ;
        TempType    = [-5]        ; Array to store All Type   (AC and Scint)
        TempMod     =[-5]         ; Array to store Module No. (AC and Scint)
        TempAnID    =[0]          ; Array to store All ID     (AC and Scint)
        TempNRG     =[0.0D]        ; Array to store All Energies(AC and Scint)

        No_Pla      = 0L          ; No of Plastics Triggered
        No_Cal      = 0L          ; No of Calorimeters Triggered

        AnID_Arr    = INTArr(8)   ; Arrays of size 8 for max 8 events
        AnTyp_Arr   = INTArr(8)   ; Arrays of size 8 for max 8 events
        AnNRG_Arr   = FltARr(8)   ; Arrays of size 8 for max 8 events

        Temp_AC_ENERGY = DblArr(6)  ; AC Energy Array, Setting it for 6 acs
        Temp_anode_NRG = DblArr(64) ; Anode Energy Array Setting it for 64 Anodes
        Temp_Anode_Typ = IntArr(64) ; Anode Types Setting it for 64 Anodes

        Ion_Flag       = False    ; A flag with the counter to track the statistics of Ion-Ionization

        ;==== Read the First Line =====
        ;

        ;----Read each line and group them---
        ;
        Temp_FMID     = Double(FMID[i])             ; Module ID
        Temp_DepNrg   = Double(DepNrg[i])           ; Energy Deposited
        Temp_Phy      = Phys[i]                     ; Physics of the process
        Temp_PartMass = partmass[i]                 ; Particle Mass (Though not needed)

        ;=== Electron Equivalent Conversion for Ions
        ;
        If (Temp_Phy Eq 'ionIoni') then begin
          Temp_Conv_Ener = Gsim_Grp_Equi_Nrg_Alpha(Temp_DepNrg)
          Ion_flag = true
          Ion_Counter++
        Endif

        ;=== Electron Equivalent Conversion for Protons
        ;
        If (Temp_Phy Eq 'hIoni')  Then begin
          ; Get the electron equivalent energy for proton equivalent
          Temp_Conv_Ener = Gsim_Grp_Equi_Nrg_Proton(Temp_DepNrg)
        Endif Else Temp_Conv_Ener = Temp_DepNrg

        ;~~~~~ Event Arrays ~~~~~~
        ;Note: Storing everything and separating it in the next step
        ;
        TempMod  = [TempMod, FMID[i] ]          ; Module ID
        TempAnID = [TempAnID, AnodeID[i]]       ; Anode ID
        TempNRG  = [TempNRG, Temp_Conv_Ener]    ; Energy Array
        TempType = [TempType,SctTyp[i]]         ; Type Array
      Endelse

      Pre_EvtID = Cur_EvtID

      Skip_line:
      ;   if i gt 100 then stop
      if i mod 10000 Eq 0 Then Print, i

    Endfor ;i
    
    Print, 'Total Unique Events:',Total(Temp_checkEvt)
    Print, 'Before No Anodes only AC:', No_Event_1 
    Print, 'After No Anodes only AC:', EvtID- No_Event_2

    Print, 'Before AC Flag :' , No_Event_2
    Print, ' After AC FLAG :', No_Event 
   
    Print, 'After skip evt:',EvtID
    
    Print,  'Total Valid :',NO_Event
   
    print, 'Ion Ioni',IOn_counter
    Print, 'Ion Event', Ion_Counter1
    
    ;    print, Gsim_Data
    
    GSim_Data = GSim_Data[1:N_Elements(GSim_Data)-1]
    WriteU, Lun2, GSim_Data
    Free_Lun, Lun2
    ;    Print, EvClass
    ;    Print, evtID
  EndFor ; p
  print, NO_Event
  Stop
End