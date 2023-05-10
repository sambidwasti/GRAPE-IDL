Pro Gsim_GRP_Quicklook, infile
  ;
  ;--Read the file created by readcsv file that takes in the csvfile and outputs gsim.csv.dat file. ---
  ;-- hmm.. but it doesnt combine with normalization.. might not be useful atm but migh tbe useful later. 
  ;UPDATE REQUIRED>
  ;Quicklook without the CT. needs to update it. 
  ;


  ;
  ; Define the structure for each events.
  ;

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

  F = File_Info(infile)           ; get inout file info
  Nevents = Long(f.size / Struc_Size)            ; get number of events in input file

  GsimData = replicate(GSim_Struc, nevents)    ; initialize input data array

  openr, Lun, infile , /Get_Lun

  For i = 0L, nevents-1 do Begin

    readu, Lun, GSim_Struc        ; read one event
    GsimData[i] = GSim_Struc       ; add it to input array
  Endfor
  Free_lun, Lun
  
  ;
  ;---- Process the file -----
  ;
  
  For i =0L, nevents-1 do Begin
    data = GsimData[i]        ; so we have stored the structure in data.

    ;
    ;--- Now we re-process Each of these events. ---
    ;

    NoAnodes = data.NAnodes       ; No. of anodes triggered.
    AnID     = data.AnodeID       ; Anode ID
    AnNrg    = data.AnodeNrg      ; Each anode energy deposited.

    New_AnID = AnID[0:NoAnodes-1]
    New_AnNrg= AnNRg[0:NoANodes-1]
    ;
    ;-- Now for each of these anodes triggered, we want to include the Cross-Talk.
    ;
    for k = 0,NoAnodes-1 Do Begin
      ; -- This puts everything in temp_Arr
      Temp_Arr = Grp_CT_Algo1(New_AnID[k],New_AnNrg[k])

      ;-- Divide the Anode ID and Energy ID.
      ;
      Len = N_Elements(temp_arr)/2
      Temp_AnID = Fix(temp_arr[0:Len-1])
      Temp_AnNrg= temp_arr[len:N_elements(Temp_arr)-1]

      New_AnID = [New_AnID ,Temp_AnID ]
      New_AnNrg= [New_AnNrg,Temp_AnNrg]
    endfor
    New_NoAnodes = N_Elements(New_AnID)

    ;
    ;== Energy Broadening ==
    ;
    New_Cor_Nrg = FltArr(New_NoAnodes)
    For k =0,New_noAnodes-1 Do New_Cor_Nrg[k] = Correct_Energy(New_AnID[k],New_AnNrg[k])

    ;
    ;== Energy Thresholds ==
    ;
    ;* NOTE : Selecting only the ones above the threshold energy.
    Fil_AnID =[-1]
    Fil_AnNrg=[-1.0]
    For k =0,New_noAnodes-1 Do Begin
      If (Anode_Type(New_AnID[k] EQ 1) )Then Begin

        If ( New_AnNRg[k] LT Cal_Min) Or ( New_AnNRg[k] GT Cal_Max) Then Goto, Skip_Filter
      Endif Else If (Anode_Type(New_AnID[k]) EQ 2) Then Begin

        If ( New_AnNRg[k] LT Pla_Min) Or ( New_AnNRg[k] GT Pla_Max) Then Goto, Skip_Filter
      Endif
      Fil_AnID = [Fil_AnID,New_AnID[k]]
      Fil_AnNrg= [Fil_AnNrg,New_AnNrg[k]]

      Skip_Filter:
    Endfor

    If N_ELements(Fil_AnID) Eq 1 Then Goto, Skip_event

    Fil_AnID = Fil_AnID[1:N_Elements(Fil_AnID)-1]
    Fil_AnNRg = Fil_AnNrg[1:N_Elements(Fil_AnNrg)-1]

    ;
    ;-- New Data / Reclassifying them.
    ;

    ;
    ;-- Event Class --
    ;
    Fil_NoANodes = N_Elements(FIl_ANID)



    New_Events++
    ;      Print, ANID, Fil_ANID, EvtClass
    Skip_Event:
    if i mod 10000 eq 0 then print,i


  Endfor
  ;Temp_hist = CgHistogram(l1Data[where ((l1Data.EvClass EQ 1) )].TotEnrg, Binsize=Bin,Locations=XArray)
;  
;  cgPS_Open, infile+'_quicklook.ps', XSize=5, YSize=6,/NoMatch, Landscape=0,/Inch, Font=1
;        Temp_Hist = CGHistogram(GSimData[ where(GSimData.EvClass EQ 3 ) ].TotEnrg, BINSIZE=5, Locations=XArray)
;        CGPlot, XArray, Temp_Hist, PSYM=10
;        
;  cgPS_Close
;        Temp_Str = infile+'_quicklook.ps'
;  CGPS2PDF, Temp_Str,delete_ps=1
End