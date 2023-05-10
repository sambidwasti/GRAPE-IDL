Pro GSim_GRP_l1_com_gamma, fsearch_String, title=title, N=N, bin = bin
  ;
  ;--read the level1 output
  ; This is the base-quicklook class.
  ; this just has the hwd limit set.
  ; we need the software and then divide into various types.
  ;combine gammas and scale them accordingly.
  ; 
  ;
  ;- Today: Apply Hardware and software threshold. 
  ;-        Create the PC, CC and C spectrums.
  ;
  
  
  ;
  ;=== INITIALIZATION ==
  ;
  
  ; = Keywords= 
  If Keyword_Set(bin) Eq 0 Then bin = 10            ; Bin Size
  If Keyword_Set(Title) Eq 0 Then Title= 'Try'      ; Title
  If keyword_set(N) Eq 0 then N = 10000000          ; The number of particles that has been simulated. Default 1 mil.
  
  ; = Definitions =
  gSimFile = FILE_SEARCH(fsearch_string)            ; get list of EVT input files
  nfiles =n_elements(gsimFile)                      ; no. of files
  CD, Cur = Cur                                     ; Current Directory

  ; ==
  ; Defining the level 1 Structure.        this might get modified.
  ; ==
  GSim_Struc_1 = { $
    VERNO           :0B,            $   ; Data format version number 1

    In_Enrg         :0.0,           $   ; Incident Source 4

    NAnodes         :0B,            $   ; Number of triggered anodes (1-8) 1
    NPls            :0B,            $   ; Number of triggered plastic anodes 1
    NCal            :0B,            $   ; Number of triggered calorimeter anodes 1

    EvType          :0B,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)only for Nanodes 2 1
    EvClass         :0B,            $   ; 

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers 8
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types (Cal=1, Pla =2, Invalid =-1) Weird but thats how it has been used. 8

    IM_Flag         :0B,            $   ; Intermodule flag 1
    Mod_ID          :0B,            $   ; Module ID 1

    ANODENRG        :FLTARR(8),     $   ; Array of triggered anode energies 8
    AnodeNrg_Cor    :FltArr(8),     $   ; Array of triggered anode energies Corrected 8

    TotEnrg         :0.0,           $   ; 4
    TotEnrg_Cor     :0.0            $   ; 4
  }
  Struc1_Size = 100
  
  ;
  ; == Scaling Factors ==
  ; The 120 is the 120 cm surrounding sphere.
  ; The scale factor could be defined as a time-factor for the spectrum.
  ; to get the number N.
  ;
  Scl_Factor = [0.8356, 0.8156, 1, 0.1941]* !PI* 120* 120/N

  ;
  ;-- Define the various histograms.
  ;
  PC_Hist = [0.0]
  C_Hist  = [0.0]
  CC_Hist = [0.0]
  Tot_Hist= [0.0]
  
  
  ;=== few P
  ;Print Statements ===
  Print
  Print, '==========='
  Print, gSimFile
  Print, ' ======== '
  Print
  
  ; One thing is that the files have to be in ascending order. The print statement before should be checked.'
  ; == For each of the files ===
  For p = 0, Nfiles-1 Do Begin
    infile = GsimFile[p]
    
    ;
    ;-- Define few of the file variables.
    ;
    F = File_Info(infile)           ; get inout file info
    Nevents = Long(f.size / Struc1_Size)            ; get number of events in input file
    GsimData1 = replicate(GSim_Struc_1, nevents)    ; initialize input data array
  
    ;
    ;--- Open and read the file in --
    ;
    print, infile
    openr, Lun, infile , /Get_Lun
    For i = 0L, nevents-1 do Begin
  
      readu, Lun, GSim_Struc_1        ; read one event
      GsimData1[i] = GSim_Struc_1       ; add it to input array
    Endfor
    Free_lun, Lun
    
    Print, Nevents
    
    ;
    ;---- Now for each events -----
    ;
    For i =0L, nevents-1 do Begin
          data = GsimData1[i]        ; so we have stored the structure in data.
          tot_nrg = data.TotEnrg_Cor
          
          If data.evclass eq 1 then begin
               PC_Hist = [PC_Hist,tot_nrg]
          Endif
                
          If data.evclass eq 1 then  C_Hist  = [CC_Hist,tot_nrg]
          If data.evclass eq 2 then  CC_Hist = [CC_Hist,tot_nrg]
          Tot_Hist = [Tot_Hist,tot_nrg]
          
          Endfor ; i (events. per file)
          Temp_HistPC = CGHistogram(PC_Hist[1:n_elements(PC_Hist)-1], BINSIZE=bin, Locations=XArray, MAX=510, MIN=0)
          if p eq 0 Then gamma1_pc = temp_histPC Else If p eq 1 then gamma2_pc = temp_histPC else if p eq 2 then gamma3_pc = temp_histPC else if p eq 3 then gamma4_pc = temp_histPC
  EndFor ; p
  
   gamma1 = scl_factor[0]*gamma1_pc
   gamma2 = scl_factor[1]*gamma2_pc
   gamma3 = scl_factor[2]*gamma3_pc
   gamma4 = scl_factor[3]*gamma4_pc
   
   gamma_total = gamma1+gamma2+gamma3+gamma4
   
   window,0
   cgplot, xarray, gamma_total/bin, psym=10, /YLog, /Xlog , Xrange=[30,500], XStyle=1, YRange=[1E-5,10], YStyle=1, YMinor=10


End