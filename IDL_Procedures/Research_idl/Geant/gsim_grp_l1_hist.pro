Pro GSim_Grp_l1_hist, fsearch_String, title=title, Bsize=Bsize
  ;
  ; This is to read l1 processed (with ct algorithm)
  ; Further more add filters and generate histogram. 
  ; Create individual histogram file. Here we are binning to what we want. 
  ;

  True =1
  False=0


  gSimFile = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  nfiles =n_elements(gsimFile)                      ; no. of files
  CD, Cur = Cur


PRint, 'No. Of Files:', nfiles

  Type_Flag=false

;  If Keyword_SEt(Type) NE 0 Then Type_Flag = true
  If keyword_set(title) ne 1 then title=''
  If keyword_set(Bsize) ne 1 then Bsize=20
  title = title +'_b'+strn(BSize)
  Event_Class = 3

  ;
  ;===Software Energy Thresholds (keV) ===
  ;
  Pla_EMin = 12.0
  Pla_EMax = 200.00

  Cal_EMin = 30.0
  Cal_Emax = 400.00

  Tot_Emin = 70.00
  Tot_EMax = 300.00

 
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
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers 8 ( 0~ 63)
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types (Cal=1, Pla =2, Invalid =-1) Weird but thats how it has been used. 8

    IM_Flag         :0B,            $   ; Intermodule flag 1
    Mod_ID          :0B,            $   ; Module ID of 1st. This is from 0-31. 2014 config.

    ANODENRG        :FLTARR(8),     $   ; Array of triggered anode energies 8 X 4 = 32

    TotEnrg         :0.0           $   ; 4
  }
  Struc1_Size = 64

     Nbins = 360/Bsize

  ; Note :No Scaling. We are trying to just build the histogram in this case.
  xval = INDGEN(NBINS)*BSIZE
  


  
  CgPs_Open, title+'_Gsim_Grp_L1.ps', Font =1, /LandScape
  cgLoadCT, 13
  

 ; Main_ScatHist=0
  EnerHist = 0.0D
  For p = 0, Nfiles-1 Do Begin
     Scat_Arr =[0.0]
    infile = GsimFile[p]

    ;
    ;-- Define few of the file variables.
    ;
    F = File_Info(infile)           ; get inout file info
    Nevents = Long(f.size / Struc1_Size)            ; get number of events in input file
    GsimData1 = replicate(GSim_Struc_1, nevents)    ; initialize input data array

    ; print, infile
    openr, Lun, infile , /Get_Lun
    For i = 0L, nevents-1 do Begin

      readu, Lun, GSim_Struc_1        ; read one event
      GsimData1[i] = GSim_Struc_1       ; add it to input array
    Endfor
    Free_lun, Lun

    ScatHist = DBLARR(360)
    ;      Print
    ;      Print, ' **************************** '
    ;      Print, ' File :', infile
    ;      Print, Nevents
    ;      Print

    Temp_Hist = [0.0]

    ;
    ;--- Open and read teh file in --
    ;

    For i = 0L, nevents-1 do Begin

      data = GsimData1[i]        ; so we have stored the structure in data.

;     ; if data.mod_ID eq 0 then print, data.Mod_ID
;      if data.mod_ID eq 1 then print, '32 Mod ID'
;      
;     ; PRint, data.AnodeID
;      For l = 0, data.Nanodes-1 do begin
;        
;       ; If data.anodeID[l] eq 0 then print, '0-valid'
;         IF data.anodeID[l] eq 64 then print, '64-valid'
;      Endfor

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

          If (data.AnodeNrg[j] lt Cal_EMin) or (data.AnodeNrg[j] gt Cal_EMax) then goto, Skip_Event
          NewAnID = [NewAnID ,Data.AnodeID[j]]
          NewAnNrg= [NewAnNrg,Data.AnodeNrg[j]]
          NEwAnTyp= [NewAnTyp,Data.Anodetyp[j]]
          NoCal++

        EndIf else if data.Anodetyp[j] eq 2 Then begin

          If (data.AnodeNrg[j] lt Pla_EMin) or (data.AnodeNrg[j] gt Pla_EMax) then goto, Skip_Event
          NewAnID = [NewAnID ,Data.AnodeID[j]]
          NewAnNrg= [NewAnNrg,Data.AnodeNrg[j]]
          NEwAnTyp= [NewAnTyp,Data.Anodetyp[j]]
          NoPla++

        EndIf
        Skip_Anode:
      Endfor

      tot_nrg = total(NewAnNrg)
      EnerHist = [EnerHist,tot_nrg]
      if tot_nrg lt Tot_Emin or tot_nrg gt Tot_EMax then goto, skip_Event

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
      ;Event Class filter.
      If (evtclass Eq Event_Class) and (NoAn Eq 2)Then begin
    
        If NewAnTyp[0] eq NewANtyp[1] Then begin
              Print,' WRONG CLASS'
              Stop
        EndIF
        
        If newAnTyp[0] eq 1 Then Sec_an = newAnID[0] Else Sec_An = newANID[1]
        If newAnTyp[1] eq 2 Then PRi_an = newAnID[1] Else Pri_An = newANID[0]

        
    ;    Print, data.Mod_id, Pri_An, Sec_An
        scat_ang = grp_scatang(data.Mod_ID,Pri_An,data.Mod_ID,Sec_An)
        Scat_arr = [Scat_arr, Scat_ang]
      
        ;pv_ang = grp
    
      EndIF ; EventClass
      Skip_Event:

    Endfor ; i (events. per file)
    
    ScatHist = CGHistogram(Scat_arr, Min=0, Max=360, Locations=Xarr, Binsize=1)
    ScatHist1 = Histogram(Scat_arr, Min=0, Max=360, Locations=Xarr1, Binsize=1)
;    print, xarr
    help,xarr, scathist
    help, xarr1, scathist1
    
   
   If p eq 0 then Main_ScatHist=ScatHist else Main_ScatHist=Main_ScatHist +ScatHIst 
 CgPlot, xarr,Main_ScatHIst, PSYM=10, Xrange=[0,360], title='Simulation'
 Cgerase
 CgPlot, xarr1,ScatHIst1, PSYM=10, Xrange=[0,360]
 
; print, xarr1
; 
; Print, xarr
Cgerase
;window,2 
;CGPLot, Main_ScatHist1 =MAIN_SCATHIST1 + RESIZE_SCATHIST1
  Endfor ; p
  
  EnerHist = EnerHist[1:N_Elements(EnerHist)-1] 
  Ener = CgHistogram(EnerHist, Min=0, Max=500, Binsize=5, locations=Xval1)


CgErase  
  
  CgPlot,Xval1, Ener, PSYM=10

  CgPs_Close
  Temp_Str = Cur+'/'+title+'_Gsim_Grp_L1.ps'
  CGPS2PDF, Temp_Str,delete_ps=1
  CGPLOT,xval ,MAIN_SCATHIST, PSYM=10
  Error = Sqrt(Main_ScatHist) ; this is ok as we are just adding them and the basic addition is still possion.
  openw, lun, title+'_Grp_l1_ins_ScatHist.txt', /Get_lun
      for i = 0, nbins-1 do begin
            printf, lun, xarr[i], main_scatHist[i], error[i]
        
      endfor

  free_lun, lun
  
  openw, lun1, title+'_Grp_l1_pv_ScatHist.txt', /Get_lun
  for i = 0, nbins-1 do begin
    printf, lun1, xval[i], main_scatHist1[i], error1[i]

  endfor

  free_lun, lun1

End