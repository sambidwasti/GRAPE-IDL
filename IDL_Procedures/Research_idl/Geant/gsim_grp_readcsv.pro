Pro GSim_GRP_readcsv, fsearch_String, nfiles=nfiles
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
  ;
  ;


  True = 1
  False = 0

  ;
  ;-- Turns on the print-statements to understand and resolve the code.
  ;
  Debug_Flag = True
  NO_Event = 0L
  ;
  ;==========
  ;
  CsvFiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  if keyword_set(nfiles) ne 1 then nfiles = n_elements(Csvfiles)

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

  ;
  ;==== each files
  ;
  For p = 0,nfiles-1 Do begin
    Infile = CsvFiles[p]
    print, infile
    ;
    ; The Columns of these data files are as follows
    ; RunID EventID SourceEnergy Type(plastic/cal [2/1]) Cluster(ModuleID) Anodeno EnergyDeposited
    ;
    ReadCol, Infile, runID, eventID, SourceNrg, SctTyp, FMID, AnodeID, DepNrg, /Silent, $
      format='LL,L,D,LL,LL,LL,D', Delimiter = ','




    ;
    ;These data also produces or reports Anticoincidence-Data. We need to identify them and probably remove them.
    ;EventID gives us idea about each event. Each reading is outputed on each line so a PC event will be in two lines.
    ;Need to process this data to each event and output a processed file/files of runs.
    ;Each Run corresponds to each file name (for energy) and the succesive runs will have a diffrent RunID.
    ;

    GSim_Data = Gsim_Struc


    ;
    ;--- Need various flags and Variables ----
    ;

    ;
    ;-- Flags --
    ;
    Cur_evt_flag = False
    AC_Flag = False
    AC_Flag_Evt = 0L

    ;
    ;-- Variables
    ;
    EvtID = 0L  ; This is the valid event that shoud identify each events.
    No_Anodes = 0L

    TempType=[-5]
    TempMod=[-5]
    TempAnID =[0]
    TempNRG  =[0.0]

    No_Pla = 0L
    No_Cal = 0L

    EvClass = LonArr(4)
    ;
    ;  Openr,Lun, Filename, /Get_Lun
    ;  Data=''
    OutPos = StrPOs(Infile,'.csv',0)
    OutFile = INfile
    StrPut, OutFile, '.gsi',OutPos
    OutFile = Outfile + 'm.csv.dat'
    Openw, Lun2, Outfile, /Get_Lun

    ;
    ;Filter out the events.
    ;

    AnID_Arr = INTArr(8)
    AnTyp_Arr= INTArr(8)
    AnNRG_Arr= FltARr(8)



    Pre_EvtID = EventID[0]
    ;
    ;-- Resolving the issue when the first event is not an event but AC Panel event. --
    ;
    Loop_flag = True
    cntr =0L
    WHile(loop_flag EQ True) Do begin
      If SctTyp[cntr] NE 0 Then begin
        Pre_EvtID = EventID[Cntr]
        Loop_flag = False
      Endif Else Cntr++
    EndWhile

    Print,'No. of lines =', N_Elements(runID)

    ;    Temp_file_len = Long(N_Elements(runID)

    For i = Cntr,N_Elements(runID)-1 Do Begin

      Cur_EvtID = EventID[i] ; Define current event id
      ;
      ;--- Veto out the AC events ---
      ;
      If SctTyp[i] Eq 0 Then begin
        AC_Flag = True
        AC_Flag_Evt = Cur_EvtID
        Goto, SKip_line
      Endif


      ;
      ;
      Temp_gsim = Replicate(Gsim_Struc, 1)


      If Cur_EvtID Eq Pre_EvtID Then Begin

        ;
        ;
  ;      If Debug_Flag Eq True Then Print, i,'@@'

        No_Anodes++
        TempMod  = [TempMod, FMID[i] ]
        TempAnID = [TempAnID, AnodeID[i]]
        TempNRG  = [TempNRG, DepNrg[i]]
        If SctTyp[i] EQ 1 Then TempType=[TempType,1] Else If SctTyp[i] EQ 2 Then TempType=[TempType,2] Else begin
          TempType=[TempType,-1]
           print, scttyp[i]
          print, temp.gsim
        EndElse




      Endif Else Begin
If AC_Flag_Evt Eq Pre_EvtID then goto, Skip_Event
        If Debug_Flag Eq True Then Print, i,'@----@'
        Print, Cur_EvtID, Pre_EvtID
        ;
        ;--- Process and Reset parameters ---
        ;We first process the previous event and reset and re-read the variables.
        ;Since we can only know that the event has ended from reading the next line/event.
        ;

        ;
        ;-- Src energy and module no.
        ;
        Src_Nrg = SourceNrg[i]
        ModNo = FMID[i]

        If No_anodes GE 8 Then No_Anodes =8

        Temp_Type = TempType[1:N_Elements(TempType)-1]
        Temp_NRG = TempNRG[1:N_Elements(TempNRG)-1]
        Temp_AnID = TempAnID[1:N_Elements(TempAnID)-1]

        For k = 0,No_Anodes-1 Do Begin
          AnTyp_Arr[k]=Temp_Type[k]
          AnNRG_Arr[k]=Temp_NRG[k]
          AnID_Arr[k]=Temp_AnID[k]
        Endfor

        For k = 0, N_elements(AnTyp_Arr)-1 Do If AnTyp_Arr[k] EQ 1 Then No_Cal++ Else If AnTyp_Arr[k] EQ 2 Then No_pla++

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
        ;Store
        ;
        Temp_Gsim.VerNo    = 1
        Temp_GSim.In_Enrg  = Src_Nrg
        Temp_GSim.NAnodes  = No_Anodes
        Temp_GSim.Npls     = No_Pla
        Temp_GSim.Ncal     = No_Cal

        Temp_GSim.EvType   = 0
        Temp_GSim.EvClass  = EvtClass
        EvClass[EvtClass]++

        Temp_GSim.AnodeID  = AnID_Arr
        Temp_GSim.AnodeTyp = AnTyp_Arr

        Temp_GSim.IM_Flag   = 0
        Temp_GSim.Mod_ID   = ModNo


        Temp_GSim.AnodeNrg = AnNRG_Arr
        ;           Temp_GSim.AnodeNrg = Cor_Energy

        Temp_GSim.TotEnrg  = TOTAL(double(AnNRG_Arr))
        ;           Temp_GSim.TotEnrg  = TOTAL(Cor_Energy)


        ;
        ;-- We want to skip this for AC events --
        ;
        GSim_Data = [GSim_Data,Temp_Gsim]

        If Debug_Flag Eq True Then Print,Temp_GSim;'>>>',  EvtID , No_Anodes, No_Pla, No_Cal, EvtClass, AnID_Arr


        skip_Event:
        AC_Flag = False
        
        NO_Event++
        ;
        ;-- Reset or increment parameters--
        ;
        EvtID++

        No_Anodes =0
        No_Pla = 0L
        No_Cal = 0L

        TempType=[-5]
        TempMod =[-5]
        TempAnID =[0]
        TempNRG  =[0.0]

        AnID_Arr = INTArr(8)
        AnTyp_Arr= IntArr(8)
        AnNRG_Arr= FltARr(8)
       

        ;
        ;--- Read this event to be processed for next --
        ;
        No_Anodes++
        TempMod  = [TempMod, FMID[i] ]
        TempAnID = [TempAnID, AnodeID[i]]
        TempNRG  = [TempNRG, DepNrg[i]]

        If SctTyp[i] EQ 1 Then TempType=[TempType,1] Else If SctTyp[i] EQ 2 Then TempType=[TempType,2] Else TempType=[TempType,-1]
       



      Endelse

 ;     If Debug_Flag Eq True then if i GT 10000 Then Stop

      Pre_EvtID = Cur_EvtID

      Skip_line:

      if i mod 10000 Eq 0 Then Print, i

    Endfor ;i


    GSim_Data = GSim_Data[1:N_Elements(GSim_Data)-1]
    WriteU, Lun2, GSim_Data
    Free_Lun, Lun2
    Print, EvClass
    Print, evtID
  EndFor ; p
  print, NO_Event
  Stop
End