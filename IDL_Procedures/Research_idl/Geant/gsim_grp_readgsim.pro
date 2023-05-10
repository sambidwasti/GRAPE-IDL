Pro Gsim_GRP_readgsim, infile
;
;--Read the file created by the GSIM File. ---
;just a template to read the gmis file. 
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

P_Hist = [0.0]
C_Hist = [0.0]
For i = 0L, nevents-1 do Begin

  readu, Lun, GSim_Struc        ; read one event
  GsimData[i] = GSim_Struc       ; add it to input array
  
;  If (GSimData[i].EvClass EQ 3) and (GSimData[i].NAnodes EQ 2) Then begin
;        If GsimData[i].AnodeTyp[0] Eq 1 Then C_Hist = [C_hist,GsimData[i].AnodeNrg[0]] Else C_Hist = [C_Hist,GsimData[i].AnodeNrg[1] ]
;        
;        If GsimData[i].AnodeTyp[0] Eq 2 Then P_Hist = [P_Hist,GsimData[i].AnodeNrg[0]] Else P_Hist = [P_Hist,GsimData[i].AnodeNrg[1] ] 
;    
;  Endif
  
Endfor
Free_lun, Lun
;Temp_hist = CgHistogram(l1Data[where ((l1Data.EvClass EQ 3) )].TotEnrg, Binsize=Bin,Locations=XArray)
Temp_Hist = CGHistogram(GSimData.TotEnrg, BINSIZE=5, Locations=XArray)
;Temp_Hist1 = CGHistogram(P_HIST, BINSIZE=5, Locations=XArray1)
;TEMP_HIST2 =  CGHistogram(C_Hist, BinSize=5, locations=xArray2)
CGPlot, XArray, Temp_Hist, PSYM=10
;CGOPlot, Xarray2, temp_hist2, PSYM=10, Color='blue'

;CGOPlot, Xarray1, temp_hist1, PSYM=10, Color='red'

End