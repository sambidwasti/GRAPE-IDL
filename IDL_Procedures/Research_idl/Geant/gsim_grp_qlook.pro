Pro GSim_GRP_Qlook, fsearch_String, nfiles=nfiles
  ;
  ;--Read the file created by the GSIM file from readCsv1. ---



  gSimFile = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  ;if keyword_set(nfiles) ne 1 then nfiles = n_elements(gSimfile)
  nfiles =1
  infile = GsimFile[0]

  GSim_Struc = { $
    VERNO           :0B,            $   ; Data format version number

    In_Enrg         :0.0,           $   ; Incident Source
    ;    In_XPos         :0.0,           $   ; Incident Photon X Pos
    ;    In_YPos         :0.0,           $   ; Incident Photon Y Pos
    ;    In_ZPos         :0.0,           $   ; Incident Photon Z Pos

    NAnodes         :0B,            $   ; Number of triggered anodes (1-8)
    NPls            :0B,            $   ; Number of triggered plastic anodes
    NCal            :0B,            $   ; Number of triggered calorimeter anodes

    EvType          :0B,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)only for Nanodes 2
    EvClass         :0B,            $   ; C = 1, CC =2, PC =3, PP =4, PPC =6 more than 2 events 7 for now. P =5

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types (Cal=1, Pla =2, Invalid =-1) Weird but thats how it has been used.

    IM_Flag         :0B,            $   ; Intermodule flag
    Mod_ID          :0B,            $   ; Module ID

    ;    ANODENRG_Uncor  :FLTARR(8),     $   ; Array of triggered anode energies
    AnodeNrg        :FltArr(8),     $   ; Array of triggered anode energies Corrected

    ;    TotEnrg_Uncor   :0.0,           $
    TotEnrg         :0.0            $
  }
  Struc_Size = 64

  ;
  ;-- Define few of the file variables.
  ;
  F = File_Info(infile)           ; get inout file info
  Nevents = Long(f.size / Struc_Size)            ; get number of events in input file
  GsimData = replicate(GSim_Struc, nevents)    ; initialize input data array

  ;
  ;--- Open and read teh file in --
  ;
  print, infile
  openr, Lun, infile , /Get_Lun
  For i = 0L, nevents-1 do Begin

    readu, Lun, GSim_Struc        ; read one event
    GsimData[i] = GSim_Struc       ; add it to input array
  Endfor
  Free_lun, Lun

  Print, Nevents


;
  P_Hist = [0.0]
  C_Hist = [0.0]
  PC_Hist = [0.0]

  J_C_Hist = [0.0]

  ;
  ;---- Process the file -----
  ;
  For i =0L, nevents-1 do Begin
    data = GsimData[i]        ; so we have stored the structure in data.


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

    ;
    ;== For the Histogram plot of the Clean PC events
    ;

    If (data.EvClass EQ 3) and (data.NAnodes EQ 2) Then begin

      PC_Hist = [PC_Hist,total(New_Cor_Nrg)]
      If GsimData[i].AnodeTyp[0] Eq 1 Then C_Hist = [C_hist,New_Cor_Nrg[0]] Else C_Hist = [C_Hist,New_Cor_Nrg[1] ]

      If GsimData[i].AnodeTyp[0] Eq 2 Then P_Hist = [P_Hist,New_Cor_Nrg[0]] Else P_Hist = [P_Hist,New_Cor_Nrg[1] ]

    Endif

    If (data.EvClass Eq 1) and (data.NAnodes Eq 1) then Begin
      J_C_Hist = [ J_C_Hist, total(New_Cor_Nrg)]
      
    Endif

    Skip_Event:

    if i mod 10000 eq 0 then print,i
  Endfor

  Temp_Hist = CGHistogram(PC_Hist, BINSIZE=5, Locations=XArray)
  Temp_Hist1 = CGHistogram(P_HIST, BINSIZE=5, Locations=XArray1)
  TEMP_HIST2 =  CGHistogram(C_Hist, BinSize=5, locations=xArray2)
  CGPlot, XArray, Temp_Hist, PSYM=10, Xrange=[0,400]
 ; CGOPlot, Xarray2, temp_hist2, PSYM=10, Color='blue'

 ; CGOPlot, Xarray1, temp_hist1, PSYM=10, Color='red'

  Temp_Hist3 = CGHistogram(J_C_Hist, BINSIZE=5, Locations=XArray3)
  Window,1 
  CGPlot, Xarray3, Temp_Hist3, PSYM=10, title=infile, XRANGE=[0,500], XSTyle=1


End