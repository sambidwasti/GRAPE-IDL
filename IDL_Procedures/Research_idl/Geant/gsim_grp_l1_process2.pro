Pro GSim_GRP_l1_process2, fsearch_String, title=title, PSDeff=PSDeff, Per=Per, Cor = Cor, foldername=foldername
  ; The process2 has the added change of applying the Corner CT% independent of the side CT%
  ; 
  ; This reads. csv.dat file?
  ; 
  ; Built off of investigate1 file.
  ; Purpose of this is to apply CT, do the hardware threshold, decimation, psdeff, etc and then output levell1
  ; for further processing.
  ;
  ;Additional notes: on the way the program's algorithm work:
  ;     Need to update on the final crosstalk
  ;     Need to specify the inclusion either in filename or one of the structured parameters.
  ;
  ; October 18, 2016
  ;     - Format generated
  ;
  ; March 7, 2017
  ;    - Correcting the module ID. The sim output has 0~23 as the module ID  but the flight has the 0~31 format for the slots and only 24 are active.
  ;
  ;    - Read in the Auxilary Lower and Higher Anode thresholds. (Sim  has 0~63 as anodeID)
  ;    - These files are in the AUX folder of GRape which are directly linked here. /Users/Sam/Work/GRAPE/Grp_Flt_2014/auxpath/
  ; May 5, 2017
  ;    - added the psd efficiency in the naming of the output file.
  ; June 11, 2017
  ;     - Documenting the process2
  ;     - The corner adjacent is independent of side adjacent crosstalk %
  ;     
  ; September 12, 2017
  ;     - Updating the naming convention for a better information translation.
  ;     
  ; September 25, 2017
  ;     - Adding a folder option/keyword. 
  ;
  ; Jan 29, 2018 
  ;     - Updated teh link to Upper and lower threshold so that it can be read from a copied folder in dropbox
  ; April 9, 2018
  ;     - Adding few extra comments for the hardware threshold.    
  ;     
  ; May29, 2018
  ; Changing decimation to see the effect for various different parameters. This is temporary and should be reverted back
  ; depending on the results.
  ; 
  ; Feb  , 2019
  ; Reverted teh decimation. Then Few print out statements to fix it. 
  ; 
  ;;
  True =1
  False=0
  
  print, " Running gsim grp l1 process2 "
  print, fsearch_String

  ;-- CT file variable. --

  ; skip_Crosstalk = False

  if keyword_set(PSDeff) eq 0 then PSDeff = 100 ; note when the psd is input 0.. it outputs 100. we dont use 0 anyway.
  if keyword_set(Per) eq 0 then Per = 0 ; this is 0 but we have set the ct to be 15%
  if keyword_set(Cor) eq 0 then Per1 = 0 else Per1 = Cor; this is 0 but we have set the ct to be 15%

  if keyword_set(Title) NE 0 then Title = Title+'_' else title='' ; this is 0 but we have set the ct to be 15%
  
  folder_flag = false
  if keyword_set(foldername) ne 0 then folder_flag = True ; this is 0 but we have set the ct to be 15%
    
;
  ;
  ;=== PSD Efficiency ===
  ;% of the cross-talk stopped
  ;
  P_to_C_Percent = PSDEff;
  C_to_P_Percent = PSDEff;


  ;
  ;- SIm MOd pos vs Actual MOD ID
  ;This is done via another process. SW
  ;
  ;ModPos = [ 22,31,19,20,21,27,28,29,17,18,24,25, 6,7 ,13,14,2 ,3 ,4, 10,11,12,0 ,9 ]
  ;ModPos =    0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
  ;

  ;
  ;-- Hardware Limit files.
  ;Read the whole file in an array and get the array.
  ;
  ;/Users/Sam/Work/GRAPE/Grp_Flt_2014/auxpath/hdw_lower_limits.txt
  Hdw_Uplims = FltArr(32,64)
  Line1 = ' '

;  A copy is in drop box folder so that its easier to work from macbook.
;  Openr, inunit, '/Users/Sam/Work/GRAPE/Grp_Flt_2014/auxpath/hdw_upper_limits.txt', /GET_LUN
   Openr, inunit, '/Users/sam/Dropbox/Cur_Work/Grp_Flt_DropBox/auxpath/hdw_upper_limits.txt', /GET_LUN


  Readf, inunit, Line1
  Readf, inunit, Line1
  Readf, inunit, Line1

  Readf, inunit, Hdw_Uplims
  Free_lun, inunit

  ;

  Hdw_Lolims = FltArr(32,64)
  Line1 = ' '

;  Openr, inunit, '/Users/Sam/Work/GRAPE/Grp_Flt_2014/auxpath/hdw_lower_limits.txt', /GET_LUN
  Openr, inunit, '/Users/sam/Dropbox/Cur_Work/Grp_Flt_DropBox/auxpath/hdw_lower_limits.txt', /GET_LUN

  Readf, inunit, Line1
  Readf, inunit, Line1
  Readf, inunit, Line1

  Readf, inunit, Hdw_Lolims
  Free_lun, inunit

  ;===========================================================================================
  ;   INTRODUCTION OF THE FLAGGED ANODES  ---(SW)---
  ;   Flagged Anode and Respective Module Pos No.
  Flagged_Anode = [ 34, 38, 49, 45, 25,   33,   41,   7]
  Respect_Module= [ 3 , 11, 13, 14, 7,    7,    7,    9]
  ;Serial No.       4   6   7   8   18    18    18    21


  ;
  ;=== DECIMATION ===
  ;
  Dec_Factor = 0
  PRint, 'Dec Factor', Dec_Factor

  ;
  ;==== Hardware Threshold ====
  ;
  Hwd_Pla = 4.0
  Hwd_Cal = 20.0

  ;
  ;=== Get single or multiple files ====
  ;
  gSimFile = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
  nfiles = n_elements(gSimfile)
  print, 'nfiles:', nfiles
  ;
  ;=== Define the structure for each events.===
  ;
  GSim_Struc_0 = { $
    VERNO           :0B,            $   ; Data format version number

    In_Enrg         :0.0,           $   ; Incident Source

    NAnodes         :0B,            $   ; Number of triggered anodes (1-8)
    NPls            :0B,            $   ; Number of triggered plastic anodes
    NCal            :0B,            $   ; Number of triggered calorimeter anodes

    EvType          :0B,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)only for Nanodes 2
    EvClass         :0B,            $   ; Only Hardware Threshold here. ;C = 1, CC =2, PC =3, all PPs are 0
    

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types (Cal=1, Pla =2, Invalid =-1) Weird but thats how it has been used.

    IM_Flag         :0B,            $   ; Intermodule flag
    Mod_ID          :0B,            $   ; Module ID

    AnodeNrg        :FltArr(8),     $   ; Array of triggered anode energies Corrected

    TotEnrg         :0.0            $
  }
  Struc0_Size = 64



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
    EvClass         :0B,            $   ;Only Hardware Threshold here. ;C = 1, CC (C +Cs) =2  , PC (C+Ps) =3, all PPs are 0
    
    ;Software not used here C = 1, CC =2, PC =3, PP =4, PPC =6 more than 2 events 7 for now. P =5 1

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers 8
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types (Cal=1, Pla =2, Invalid =-1) Weird but thats how it has been used. 8

    IM_Flag         :0B,            $   ; Intermodule flag 1
    Mod_ID          :0B,            $   ; Module ID 1

    ANODENRG        :FLTARR(8),     $   ; Array of triggered anode energies 8 X 4 = 32

    TotEnrg         :0.0           $   ; 4
  }
  Struc1_Size = 64


  ;
  ;==== For Each File =====
  ;
  for p =0, nfiles-1 Do Begin

    infile = GsimFile[p]
    GsimData1 = GSim_Struc_1

    ;Print
    ;Print, ' **************************** '
    ;Print, ' File :', infile
    
    ;
    ;-- Define few of the file variables.
    ;
    F = File_Info(infile)           ; get inout file info
    if f.size eq 0 then goto, Skip_File
    Nevents = Long(f.size / Struc0_Size)            ; get number of events in input file
    GsimData0 = replicate(GSim_Struc_0, nevents)    ; initialize input data array

    Print, Nevents
    Print
    print, '*Nevents ::::*', nevents


    ;
    ;--- Open and read teh file in --
    ;
    openr, Lun, infile , /Get_Lun
    For i = 0L, nevents-1 do Begin

      readu, Lun, GSim_Struc_0        ; read one event
      GsimData0[i] = GSim_Struc_0       ; add it to input array
    Endfor
    Free_lun, Lun
;    print,'PC Before:', n_elements(gsimdata0[where(gsimdata0.EvClass eq 3)])

    ;
    ; == Rename and update the file name of level 1
    ;
    if folder_flag eq True then begin
          temp_infile = infile
          tempPos = 1L
          while TempPos GT 0 Do begin
             tempPos1 = TempPos
             tempPos = StrPOs(Infile,'/',tempPos1+1)
      ;       Print, TempPOs1, 'a', TempPos
          endwhile
      ;       Print, strmid(infile,TempPos1+1,StrLen(infile)-TempPos1)
       ; foldername = strmid(infile,0,tempPos1+1)
    infile =  strmid(infile,TempPos1+1,StrLen(infile)-TempPos1) 
    endif
    OutPos = StrPOs(Infile,'.csv',0)
    OutFile = INfile
    StrPut, OutFile, 'lvl',OutPos+5

    OutFile = 'PSD_'+Strn(Psdeff)+'_Side_'+Strn(Per)+'_Cor_'+STRN(Per1)+'_'+Outfile +'1.dat'

    Outfile =Title+OutFile

    if folder_flag eq true then outfile = foldername+outfile

    Openw, Lun1, Outfile, /Get_Lun

    tot_P2Cres=0L
    tot_C2Pres=0L

    Dec_Counter = 0L
    temp_n8_counter = 0L
    temp_n8_counter1 = 0L
    temp_evt_Counter=0L
    ;
    ;---- Process the file -----
    ;
    For i =0L, nevents-1 do Begin
    ;PRint, '--'
      data = GsimData0[i]        ; so we have stored the structure in data.
      Temp_gsim1 = Replicate(Gsim_Struc_1, 1)

      ;
      ;- Corrected Module Position
      ;
      Module_Position =Data.Mod_ID

      ;
      ;--- Now we re-process Each of these events. ---
      ;
      NoAnodes = data.NAnodes       ; No. of anodes triggered.
      New_AnID = data.AnodeID[0:NoAnodes-1]      ; Anode ID
      New_AnNrg= data.AnodeNrg[0:NoAnodes-1]       ; Each anode energy deposited.
      New_AnTyp= data.AnodeTyp[0:NoAnodes-1] 
;PRint, NEw_AnID
      If NoAnodes Eq 8 Then temp_n8_counter++
      ;
      ;        Check For Flagged Anodes (Quality -1)
      ;
      If module_position EQ 7 Then begin     ; We need this because module position 7 has multiple flagged anodes.

        For j = 0, NoAnodes-1  Do Begin
          If data.AnodeID[j] EQ Flagged_Anode[4] Then Goto,Skip_Event
          If data.AnodeID[j] EQ Flagged_Anode[5] Then Goto,Skip_Event
          If data.AnodeID[j] EQ Flagged_Anode[6] Then Goto,Skip_Event
        EndFor

      EndIf Else If  (Where(module_position EQ Respect_Module) NE -1 ) Then Begin
        For j = 0, NoAnodes-1  Do Begin
          If data.AnodeID[j] EQ Flagged_Anode[ where(module_position EQ  Respect_Module)] Then Goto, Skip_Event
        EndFor
      EndIf
      ;

      ;   If Skip_Crosstalk Eq False Then begin
      ;
      ;
      ;-- Now for each of these anodes triggered, we want to include the Cross-Talk.
      ;
      For k = 0,NoAnodes-1 Do Begin
        ;
        ; -- This puts everything in temp_Arr
        ;

        Temp_Arr = Grp_CT_Al_5(New_AnID[k],New_AnNrg[k],Per=Per,Corper=Per1)
        ;Temp_Arr = Grp_CT_Al_4(New_AnID[k],New_AnNrg[k],Per=Per)

        ;
        ;The above cross-talk algorithm takes in the adjacent anodes and gives it
        ;the energy and outputs an array with new IDs and Energies.
        ;

        ;
        ;-- Divide the Anode ID and Energy ID.
        ;


        Len = N_Elements(temp_arr)/3
        Temp_AnID = Fix(temp_arr[0:Len-1])
        Temp_AnNrg= temp_arr[len:Len*2-1]
        Temp_AnTyp = fix(temp_Arr[len*2:N_elements(temp_Arr)-1])

        New_AnID = [New_AnID ,Temp_AnID ]
        New_AnNrg= [New_AnNrg,Temp_AnNrg]
        New_AnTyp= [New_AnTyp,Temp_AnTyp]   ; june 1 update
      EndFor

      ;
      ;-- The new energies and Ids are stored in New_AnID and New_AnNrg
      ;

      New_NoAnodes = N_Elements(New_AnID)   ; newer no. of anodes
;PRint, NEw_AnID
;print,'**'
      ;
      ;== Energy Broadening ==
      ;
      New_Cor_Nrg = FltArr(New_NoAnodes)  ; Store the corrected broadened energy in this variable.
      ;      EndiF Else BEgin
      ;          New_NoAnodes  = NoAnodes
      ;          New_Cor_Nrg   =  FltArr(New_NoAnodes)
      ;
      ;      Endelse


      ;
      ;Energy Broadening Code

      For k =0,New_noAnodes-1 Do New_Cor_Nrg[k] = Correct_Energy(New_AnID[k],New_AnNrg[k])
      
      
      ;
      ;== June 1 Update for P2C and C2P
      ;
      P2C_flag = False
      C2P_Flag = False

      ;
      ;== Hardware Threshold ==
      ;
      Hwd_fil_AnID = [-1]
      Hwd_fil_AnNrg= [-1.0]
      Hwd_fil_AnTyp= [1]
      For k =0,New_noAnodes-1 Do Begin
        
        
        If New_Cor_Nrg[k] lt hdw_lolims[module_position,New_AnID[k]] Then goto, Skip_Filter1
        If New_Cor_Nrg[k] gt hdw_Uplims[module_position,New_AnID[k]] Then goto, Skip_Filter1

        Hwd_Fil_AnID= [Hwd_Fil_AnID,New_AnID[k]]
        Hwd_Fil_AnNrg=[Hwd_Fil_AnNrg,New_Cor_Nrg[k]]

        ;
        ;== June 1 Update for P2C and C2P
        ;
        if (New_AnTyp[k] Eq 4) or (New_AnTyp[k] eq 5) Then P2C_Flag = true
        if (New_AnTyp[k] Eq 6) or (New_AnTyp[k] eq 7) Then C2P_Flag = true
        Hwd_Fil_AnTyp=[Hwd_Fil_AnTyp,New_AnTyp[k]]

        Skip_Filter1:
      Endfor; k

      If N_ELements(Hwd_Fil_AnID) Eq 1 Then Goto, Skip_event

      Hwd_Fil_AnID  = Hwd_Fil_AnID[1:N_Elements(Hwd_Fil_AnID)-1]
      Hwd_Fil_AnNRg = Hwd_Fil_AnNrg[1:N_Elements(Hwd_Fil_AnNrg)-1]
      Hwd_Fil_AnTyp = Hwd_Fil_AnTyp[1:N_Elements(Hwd_Fil_AnTyp)-1]

      Hwd_Fil_NoANodes = N_Elements(Hwd_FIl_ANID)


      ; == PSD Variables ==
      ; if 20%, 5th one stopped. allows 4 but stops 1.
      ; if 100% efficient no CT between scint allowed.
      ; if 0% then all allowed.
      ;
      ; Furthermore:
      ;   - This means that % cross-talks blocked. So not reported in Hardware

      ;
      ;== Efficiency workings of Plastic to Calorimeter
      ;the percentage was to block. so we skip whenever that happens.
      ;

      ;== P 2 C

      temp_arr_id = IntArr(1)
      temp_arr_nrg= FltARr(1)
      if P2C_Flag Eq True then Begin
        p2cRes = 100 - P_to_C_Percent
        tot_P2Cres = tot_P2Cres + p2cRes

        if tot_P2Cres GE 100 Then Begin
          tot_P2Cres = tot_P2Cres -100
        endIf else Begin
          for k = 0, Hwd_Fil_NoANodes-1 Do Begin
            If (Hwd_Fil_AnTyp[k] NE 4) and (Hwd_Fil_AnTyp[k] NE 5) Then begin
              temp_arr_id = [temp_arr_id,Hwd_Fil_AnID[k]]
              temp_arr_Nrg = [temp_arr_Nrg,Hwd_Fil_AnNrg[k]]
            EndIf
          endfor
          If N_Elements(Temp_Arr_ID) EQ 1 THen goto, Skip_Event
          Hwd_Fil_AnID = temp_Arr_Id[1:N_Elements(Temp_Arr_ID)-1]
          Hwd_Fil_AnNrg= temp_Arr_Nrg[1:N_Elements(Temp_Arr_NRg)-1]
          Hwd_Fil_NoANodes = N_Elements(Hwd_FIl_ANID)

        endelse

      EndIf

      temp_arr_id = IntArr(1)
      temp_arr_nrg= FltARr(1)

      ;== C 2 P
      if C2P_Flag Eq True Then Begin
        c2pRes = 100 - C_to_P_Percent
        tot_C2Pres = tot_c2pRes + c2pRes


        if tot_C2Pres GE 100 Then Begin
          tot_C2Pres = tot_C2Pres -100
        endIf else Begin
          for k = 0, Hwd_Fil_NoANodes-1 Do Begin
            If (Hwd_Fil_AnTyp[k] NE 6) and (Hwd_Fil_AnTyp[k] NE 7) Then begin
              temp_arr_id = [temp_arr_id,Hwd_Fil_AnID[k]]
              temp_arr_Nrg = [temp_arr_Nrg,Hwd_Fil_AnNrg[k]]
            EndIf
          endfor

          if n_elements(Temp_Arr_ID) lE 1 Then goto, skip_event

          Hwd_Fil_AnID = temp_Arr_Id[1:N_Elements(Temp_Arr_ID)-1]
          Hwd_Fil_AnNrg= temp_Arr_Nrg[1:N_Elements(Temp_Arr_NRg)-1]
          Hwd_Fil_NoANodes = N_Elements(Hwd_FIl_ANID)
        endelse

      EndIf

      ;
      ;== Hardware Classification ==
      ;
      No_Cal = 0L
      No_Pla = 0L
      For k = 0,Hwd_Fil_NoAnodes-1 Do If Anode_type(Hwd_Fil_ANID[k]) EQ 1 THen No_Cal++ Else If Anode_type(HWd_Fil_ANID[k]) EQ 2 Then No_pla++

      Evt3Class = 0
      If No_Cal Gt 0 Then Begin ; If there are no calorimeter it is 0. We do not read these in hardware.
        If No_Pla GE 1 Then Evt3Class = 3 Else BEgin
          If No_Cal EQ 1 Then Evt3Class = 1 Else Evt3Class = 2
        EndElse
      Endif
      If Evt3Class Eq 0 Then Goto, Skip_Event

      ;
      ;=== HARDWARE DECIMATION ===
      ;Basically skip the event . 4 out of 5.
      ;Only for C and CC
      ;
      If (Evt3Class Eq 1) or (Evt3Class Eq 2) Then BEgin
        Dec_Counter ++
        If (Dec_Counter LT Dec_Factor)  Then GOTo, Skip_Event Else Dec_Counter = 0L
      Endif

      ;
      ;-- Tabulate the Hardawre classes.


      ;
      ;=======================
      ;
      ;Now we have a hardware trigger set up. We would not the EV3Class 0 which are no calorimeter events. So
      ;So we filter out these events.
      ;

      ;
      Fil_AnID =[-1]
      Fil_AnNrg=[-1.0]

      Hwd_NoAnodes = Hwd_Fil_NoAnodes
      Fil_AnID = [Fil_AnID,Hwd_Fil_AnID]
      Fil_AnNrg= [Fil_AnNrg,Hwd_Fil_AnNRg]


      ;
      ;== Now we have the new anodes that are above threshold energy in the Fil_AnID, Fil_AnNRg
      ;-- Fil = Filtered
      ;
      If N_ELements(Fil_AnID) Eq 1 Then Goto, Skip_event

      Fil_AnID = Fil_AnID[1:N_Elements(Fil_AnID)-1]
      Fil_AnNRg = Fil_AnNrg[1:N_Elements(Fil_AnNrg)-1]


      Fil_NoANodes = N_Elements(FIl_ANID)

;      Print, FIl_ANid
;      PRint, '&&&'
      If Fil_NOAnodes GT 8 Then begin
        temp_n8_counter1++
        Fil_ANID = Fil_ANID[0:7]
        Fil_ANNRG = Fil_ANNrg[0:7]
        Fil_noAnodes = 8
      Endif

      No_Pla =0l
      No_Cal =0l

;
;This is redundant for events with less than 8 no. of triggers.
;This is needed if it was doing software threshold here. 
;

      Anodetyp = intarr(Fil_NoANodes)
      For k = 0,Fil_NoAnodes-1 Do begin
        If Anode_type(Fil_ANID[k]) EQ 1 THen No_Cal++ Else If Anode_type(Fil_ANID[k]) EQ 2 Then No_pla++
        Anodetyp[k] = Anode_type(fil_anid[k])
      endfor


      EvtClass = 0


      ; Level 1 processing so keeping the hardware thresholds for here.
      EvtClass = 0
      If No_Cal Gt 0 Then Begin ; If there are no calorimeter it is 0. We do not read these in hardware.
        If No_Pla GE 1 Then EvtClass = 3 Else BEgin
          If No_Cal EQ 1 Then EvtClass = 1 Else EvtClass = 2
        EndElse
      Endif
      If EvtClass Eq 0 Then Goto, Skip_Event




      ;
      ;--- Tracking Array ---
      ;
      Temp_gsim1.VerNo    = Data.VerNo
      Temp_gsim1.In_Enrg  = Data.In_enrg
      Temp_gsim1.NAnodes  = Fil_NoANodes
      Temp_gsim1.NPls     = No_Pla
      Temp_gsim1.NCal     = No_Cal
      Temp_Gsim1.EvType   = Data.EvType    ; *****
      Temp_GSim1.EvClass  = EvtClass
      Temp_Gsim1.AnodeID  = Fil_ANID
      Temp_GSim1.AnodeTyp = AnodeTyp
      Temp_Gsim1.IM_Flag  = Data.IM_Flag  ; *****
      Temp_Gsim1.MOd_ID   = Module_Position
      Temp_Gsim1.AnodeNrg = Fil_AnNrg
      Temp_GSim1.TotEnrg  = Total(Fil_ANNrg)

      GsimData1 = [GsimData1, Temp_GSim1]
      ;    print, temp_Gsim1
      ;     stop
      Skip_Event:

      ;      If i gt 50 then stop
      if i mod 10000 eq 0 then print,i
;       IF i gt 50 then stop
    Endfor ; i
;    print, n_elements(gsimdata1[where(gsimdata1.EvClass eq 3)])
;    print, n_elements(gsimData1)
    If n_elements(GsimData1) Then GsimData1 = GsimData1 else  GsimData1=GsimData1[1:N_Elements(GsimData1)-1]

    WriteU, Lun1, GSimData1
    Free_Lun, Lun1
    Print, '======No of event more that 8 :'+Strn(temp_n8_counter1)
    Print, '======No of event at 8 :'+Strn(temp_n8_counter)

    Skip_File:
    print, p
  Endfor ; p
  ; Stop
End