Pro GSim_GRP_readcsv1a, fsearch_String, nfiles=nfiles
  ; 
  ;   This is upgraded from ReadCsv1 which was upgradedfrom ReadCsv.
  ;   Not much is changed afterwards.
  ; 
  ;
  ;  Jan 22, 2018 Sambid Wasti
  ;                      ; The shields should not be skipping.
  ;                      ; Shields need to be Veto-ed out.
  ;                      ; Additionally it needs to have a threshold of 400keV
  ;                      ; the proton-ionization needs to be converted to electron-ionization if needed.  ( Most probably not in this)
  ;
  ;steps
  ; Define structure
  ; Read File and put into respective array through readcol
  ; 
  ;   Feb 6, 2018 Sambid Wasti
  ;    Updating comments : This is what is being used process the response function.
  ;   This is also assumed to be responsible for the gammas and non-hadronic sims.
  ;   
  ;   May 23, 2019 Sambid Wasti
  ;   Adding few more comments and seeing how things are done for veto events.
  ;     : We are reading one line at a time. 
  ;       If we read an AC panel and check the energy and if it is higher, it is flagged (Veto)
  ;       And then skip event if it is veto-ed
  ;   
  ;   July, 16, 2019 Sambid Wasti 
  ;   The anodes and the Modules are not mapped properly to the instrument. 
  ;   Created few anode/module map procedures to correct that in the read-csv level.
  ;
  ;   Aug, 19, 2019 Sambid Wasti
  ;   Added a line to overcome the issue that was being created for files without events.
  ;
  ;   March 28, 2020 Sambid Wasti
  ;   Checking small bug for low (10keV to 30kev) runs where input energy is somehow wrong.
  ;   
  ;
  


  True = 1
  False = 0

  ;
  ;-- Turns on the print-statements to understand and resolve the code.
  ;
  Debug_Flag = False
  NO_Event = 0L
  ;
  ;==========
  ;
  CsvFiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  if keyword_set(nfiles) ne 1 then nfiles = n_elements(Csvfiles)
 
  AC_Threshold = 400.0D ; keV
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
        ReadCol, Infile, runID, eventID, SourceNrg, SctTyp, FMID, AnodeID, DepNrg, /Silent, count=nlines, $
          format='LL,L,D,LL,LL,LL,D', Delimiter = ','
    
        ;
        ;These data also produces or reports Anticoincidence-Data. 
        ;The AC data needs to be applied a filter/threshold and then the event has to be veto-ed out accordingly. 
        ;The data is produced for each anode element per line so An event can comprise of multiple lines. 
        ;The only way to know the event is completed is by reading the next line which is of diffrent event ID. 0
        ;
    
        GSim_Data = Gsim_Struc
       ; Help, Gsim_Data, '*************8'
        
        ;
        ;-- Variables
        ;
        EvtID     = 0L  ; This is the no event in that file (valid + invalid)
        No_Anodes = 0L
        EvtID1    = 0L  ; A counter for valid event in that file. 
    
        TempType  = [-5]
        TempMod   = [-5]
        TempAnID  = [0]
        TempNRG   = [0.0]
    
        No_Pla    = 0L
        No_Cal    = 0L
    
        EvClass   = LonArr(4)
    
        
        ;
        ;   - Output File --
        ;
        OutPos    = StrPOs(Infile,'.csv',0)
        OutFile   = INfile
        StrPut, OutFile, '.gsi',OutPos
        
        OutFile   = Outfile + 'm.csv.dat'
        Openw, Lun2, Outfile, /Get_Lun
     ;   Help, eventID
      ;  Print, nlines
        if nlines Eq 0 then begin
          Print, 'TRIGGERED -----'
          goto, skip_file_read
        endif
        ;Filter out the events.
        AnID_Arr = INTArr(8)
      ;  AnID_Arr = [65,65,65,65,65,65,65,65]
        AnTyp_Arr= INTArr(8)
        AnNRG_Arr= FltARr(8)
    
        ;-- Flags --
        Cur_evt_flag  = False
        AC_Flag       = False
    
        Veto_events   = False
        Pre_EvtID     = EventID[0]
        Cntr          =1
    
        Loop_flag = True
    
        Print,'No. of lines =', nlines
    
        Pre_EvtID = 0
        
        ; EACH LINE READ:::::::
  ;      print, N_Elements(runID)
    
        For i = 0,nlines-1 Do Begin
          
              Cur_EvtID = EventID[i] ; Define current event id
              
              If SctTyp[i] Eq 0 Then  AC_Flag = True Else AC_Flag = False
        
              Temp_gsim = Replicate(Gsim_Struc, 1)
              
              ;$$ Debug
              If Debug_Flag Eq True then PRint,i,' STep 0', Cur_EvtID
              
              If Cur_EvtID Eq Pre_EvtID Then Begin
                    ;$$ Debug
                    If Debug_Flag Eq True then  Print,i, ' StepA1'
                    
                    If AC_Flag eq True then begin
                          ;
                          ;  For version 8, each AC line in an event is the sum energy deposited in that AC panel. 
                          ;  So a direct threshold calculation can be done to veto out. 
                          ;  Basically, if the energy is less than an amount, then do nothing
                          ;             if it is more, than veto it out. 
                          ;  Note this section executes when its the same Event happening for when its the same Event ID. 
                          Temp_AC_Energy = DepNrg[i]    ; get the respective energy
                 
                          If (Temp_AC_Energy GT AC_Threshold) Then Veto_Events = True
                          If Temp_AC_ENergy Eq Ac_Threshold then print, 'wut'
                              goto, skip_line ; we are just checking the AC energy and skipping since we dont want to store the value.
                     Endif
                              
                     No_Anodes++
                     TempMod  = [TempMod, FMID[i] ]
                     TempAnID = [TempAnID, AnodeID[i]]
                     TempNRG  = [TempNRG, DepNrg[i]]
                     
                     If SctTyp[i] EQ 1 Then TempType=[TempType,1] Else If SctTyp[i] EQ 2 Then TempType=[TempType,2] Else begin
                                TempType=[TempType,-1]
                              ;  print, scttyp[i]
                               ; print, temp.gsim
                     EndElse
                          
                Endif Else Begin  ; CurEvent = Previous event condition ended. 
                ; If its another event then this executes. 
                ; First process previous event and read in this event.
                ;
                
                ;$$ Debug
                If Debug_Flag Eq True then Print,i, VEto_Events ,' StepA2', No_Anodes
                
                
                if no_anodes Eq 0 Then goto, Skip_Event
                if i eq 0 then goto, skip_event
                ;
                ;Skip Veto-ed Event. 
                ;from previous event, we have a veto flag.
                ;
                
                If Veto_Events eq True then goto, Skip_Event
                ;-- Src energy and module no.
                Src_Nrg = SourceNrg[i]
                ModNo = FMID[i]
                
                ;  print, i, Scttyp[i], No_anodes
                If No_anodes GE 8 Then No_Anodes =8
                ;   print, N_Elements(TemPType)
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


                        New_anID_Arr = IntArr(N_elements(ANID_Arr))
                        For r = 0,N_elements(AnId_Arr)-1 do begin
                            New_AnID_arr[r] = Grp_sim_anode_map(AnID_Arr[r])
                        EndFor 
;    PRint, anID_Arr
;    print,New_anID_Arr
;    print, '***                    

                Temp_GSim.AnodeID  = New_AnID_arr
                ; Types are still the same. 
                Temp_GSim.AnodeTyp = AnTyp_Arr
        
                Temp_GSim.IM_Flag   = 0
   ;           print, modno
                         new_modno = Grp_sim_module_map(ModNo)
;                  print, new_modno
;                  
;                 print, '----'      
                Temp_GSim.Mod_ID   = new_ModNo
                
        
        
                Temp_GSim.AnodeNrg = AnNRG_Arr
                ;           Temp_GSim.AnodeNrg = Cor_Energy
        
                Temp_GSim.TotEnrg  = TOTAL(double(AnNRG_Arr))
                ;           Temp_GSim.TotEnrg  = TOTAL(Cor_Energy)
        
        
                ;
                ;-- We want to skip this for AC events --
                ;
                GSim_Data = [GSim_Data,Temp_Gsim]
        
                ;Print, Pre_EvtID
                ;Print, Temp_GSim
                NO_Event++
                ;       If Debug_Flag Eq True Then Print,Temp_GSim;'>>>',  EvtID , No_Anodes, No_Pla, No_Cal, EvtClass, AnID_Arr
        
                EvtID1++
                skip_Event:
        
        
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
               ;AnID_Arr = [65,65,65,65,65,65,65,65]

                AnTyp_Arr= IntArr(8)
                AnNRG_Arr= FltARr(8)
        
                Veto_Events= False
                ;
                ;--- Read this event to be processed for next --
                ;
                
                
                ;    print, 'RESET'
                If SctTyp[i] Eq 0 Then  AC_Flag = True Else AC_Flag = False
                If AC_Flag Eq True then begin
                  Temp_AC_Energy = DepNrg[i]    ; get the respective energy
                  If (Temp_AC_Energy GT AC_Threshold)  Then Veto_Events = True
        
                Endif Else Begin  ; If this Event line is not an AC. 
                  
                  No_Anodes++
                  TempMod  = [TempMod, FMID[i] ]
                  TempAnID = [TempAnID, AnodeID[i]]
                  TempNRG  = [TempNRG, DepNrg[i]]
        
                  If SctTyp[i] EQ 1 Then TempType=[TempType,1] Else If SctTyp[i] EQ 2 Then TempType=[TempType,2] Else TempType=[TempType,-1]
                EndElse
                
        
              Endelse
        
        
              Pre_EvtID = Cur_EvtID
                
              Skip_line:
        
              If Debug_Flag Eq True then if i GT 15 Then Stop
          
              if i mod 10000 Eq 0 Then Print, i
        
     ;   if i gt 100  then stop
        
        Endfor ;i
    
       Tot_Events_Valid = N_elements(Gsim_Data)
       If Tot_Events_Valid LE 1 Then Goto, Skip_File
       
        GSim_Data = GSim_Data[1:N_Elements(GSim_Data)-1]
Skip_File_Read:
;help, gsim_data, '&&&&&&&&&'
  ;      PRint, Gsim_Data
        WriteU, Lun2, GSim_Data
        Free_Lun, Lun2
   ;     Print, EvClass
    ;    Print, strn(evtID)
        Print, 'Valid Events: ',Strn(EvtID1)
    
        Skip_File:
  EndFor ; p
  print, NO_Event
  Stop
End