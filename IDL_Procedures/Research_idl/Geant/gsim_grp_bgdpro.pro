Pro GSim_GRP_BgdPro, fsearch_String, nfiles=nfiles
  ;
  ;--Read the file created by the GSIM file from readCsv1. ---
  ; Background Processing without the Crosstalk.
  ; This is to just do the energy broadening and output a new data file called l1 (level 1)
  ; with the information. For Cross-talk 
  ;



  gSimFile = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  ;if keyword_set(nfiles) ne 1 then nfiles = n_elements(gSimfile)
  nfiles =1
  infile = GsimFile[0]

  GSim_Struc_0 = { $
    VERNO           :0B,            $   ; Data format version number 1

    In_Enrg         :0.0,           $   ; Incident Source 4

    NAnodes         :0B,            $   ; Number of triggered anodes (1-8)1
    NPls            :0B,            $   ; Number of triggered plastic anodes1
    NCal            :0B,            $   ; Number of triggered calorimeter anodes1

    EvType          :0B,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)only for Nanodes 2 1
    EvClass         :0B,            $   ; C = 1, CC =2, PC =3, PP =4, PPC =6 more than 2 events 7 for now. P =5 1

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers 8
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types (Cal=1, Pla =2, Invalid =-1) Weird but thats how it has been used. 8

    IM_Flag         :0B,            $   ; Intermodule flag 1
    Mod_ID          :0B,            $   ; Module ID 1

    AnodeNrg        :FltArr(8),     $   ; Array of triggered anode energies Corrected 32

    TotEnrg         :0.0           $   ;  4
  }
  Struc0_Size = 64


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

  ANODENRG        :FLTARR(8),     $   ; Array of triggered anode energies 8
  AnodeNrg_Cor    :FltArr(8),     $   ; Array of triggered anode energies Corrected 8

  TotEnrg         :0.0,           $   ; 4
  TotEnrg_Cor     :0.0            $   ; 4
}
Struc1_Size = 100

  GsimData1 = GSim_Struc_1
  ;
  ;-- Define few of the file variables.
  ;
  F = File_Info(infile)           ; get inout file info
  Nevents = Long(f.size / Struc0_Size)            ; get number of events in input file
  GsimData0 = replicate(GSim_Struc_0, nevents)    ; initialize input data array

  ;
  ;--- Open and read teh file in --
  ;
  print, infile
  openr, Lun, infile , /Get_Lun
  For i = 0L, nevents-1 do Begin

    readu, Lun, GSim_Struc_0        ; read one event
    GsimData0[i] = GSim_Struc_0       ; add it to input array
  Endfor
  Free_lun, Lun

  Print, Nevents

  OutPos = StrPOs(Infile,'.csv',0)
  OutFile = INfile
  StrPut, OutFile, 'lvl',OutPos+6
  OutFile = Outfile + '1.dat'
  print, outfile
  Openw, Lun1, Outfile, /Get_Lun

  ;
  P_Hist = [0.0]
  C_Hist = [0.0]
  PC_Hist = [0.0]

  J_C_Hist = [0.0]

  ;
  ;---- Process the file -----
  ;
  For i =0L, nevents-1 do Begin
    data = GsimData0[i]        ; so we have stored the structure in data.
    Temp_gsim1 = Replicate(Gsim_Struc_1, 1)

    ;
    ;--- Now we re-process Each of these events. ---
    ;
    NoAnodes = data.NAnodes       ; No. of anodes triggered.
    New_AnID     = data.AnodeID       ; Anode ID
    AnNrg    = data.AnodeNrg      ; Each anode energy deposited.

    ;
    ;== Energy Broadening ==
    ;
    New_Cor_Nrg = FltArr(NoAnodes)
    For k =0,NoAnodes-1 Do begin
      New_Cor_Nrg[k] = Correct_Energy(New_AnID[k],AnNrg[k])
    Endfor

    if i mod 10000 eq 0 then print,i

    
    Temp_gsim1.VerNo  = Data.VerNo
    Temp_gsim1.In_Enrg= Data.In_enrg
    Temp_gsim1.NAnodes= Data.NAnodes
    Temp_gsim1.NPls   = Data.NPls
    Temp_gsim1.NCal   = Data.NCal
    Temp_Gsim1.EvType= Data.EvType
    Temp_GSim1.EvClass=Data.EvClass
    Temp_Gsim1.AnodeID= Data.AnodeID
    Temp_GSim1.AnodeTyp=Data.AnodeTyp
    Temp_Gsim1.IM_Flag= Data.IM_Flag
    Temp_Gsim1.MOd_ID = Data.Mod_ID
    Temp_Gsim1.AnodeNrg=Data.AnodeNrg
    Temp_GSim1.TotEnrg= Data.TotEnrg
    Temp_Gsim1.AnodeNrg_Cor = New_Cor_Nrg
    Temp_Gsim1.TotEnrg_Cor = Total(New_Cor_Nrg)
    
    GsimData1 = [GsimData1, Temp_GSim1]
  Endfor
  
  WriteU, Lun1, GSimData1
  Free_Lun, Lun1



End