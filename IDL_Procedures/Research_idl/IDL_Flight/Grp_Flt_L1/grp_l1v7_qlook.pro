Pro Grp_l1v7_QLook, fsearch_String, nfiles=nfiles, title= title, noplot = noplot
  ; Reading in Level 1 version 7 data.
  ;
  ; May 4, 2016
  ; Updating this to compare with the sim file.
  ; 
  ; - Tailor it to read the calibration ground based files.
  ; 
  ; generates qlk.txt (quicklook file)
  ;   
  ; May 19, 2016
  ; Updating the EvtClasses to give the output to software Evt Classes.  
  ; 
  ; May 23, 2016
  ; Updating the code to include the software threshold. This was missing here and is not done in l1 processing.
  ; This is only for the plastic and calorimeters but not for the total energy.
  ;

  True = 1
  False= 0

  ;
  ;-- Energy Selection
  ;
  Pla_EMin = 10.0
  Pla_EMax = 200.00

  Cal_EMin = 40.0
  Cal_EMax = 400.00

;  Tot_EMin = 80.00
;  Tot_EMax = 200.00

  Print, 'Plastic', Pla_EMin, Pla_EMax
  Print, 'Calorim', Cal_EMin, Cal_Emax
  ;
  ;-- Get the array of event files.
  ;
  Evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]
  
  ;
  ;For few runs that have module 14 off.
  ;
  ;c2014 = [0,2,3,4,6,7,9,10,11,12,13,17,18,19,20,21,22,24,25,27,28,29,31]
  
  ;
  ;-- Total no. of files --
  ;
  If keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)

  Plot_Flag = True
  If Keyword_set(noplot) ne 0 Then Plot_Flag = False


  ;
  ;-- Title --
  ;
  IF Keyword_Set(title) Eq 0 Then Title='Test'


  ;
  ;-- Current Directory --
  ;
  CD, Cur = Cur


  ;== Define the Structure.
  Struc = { Version_Number    : 0B  ,$    ; 1 1
    Sweep_Number      : 0   ,$    ; 2 3
    Sweep_Start_Time  : 0.0D,$    ; 8 11
    Swept_Time        : 0.0D,$    ; 8 19
    Event_Time        : 0.0D,$    ; 8 27

    Mod_Position      : 0B  ,$    ; 1 28
    Mod_Serial        : 0B  ,$    ; 1 29

    Event_Class       : 0B  ,$    ; 1 30
    Int_Mod_Flag      : 0B  ,$    ; 1 31
    Anti_Co_Flag      : 0B  ,$    ; 1 32
    No_Anodes         : 0B  ,$    ; 1 33
    No_Pla            : 0B  ,$    ; 1 34
    No_Cal            : 0B  ,$    ; 1 35


    ANODEID:BYTARR(8),    $     ; Array of triggered anode numbers
    ANODETYP:BYTARR(8),   $     ; Array of triggered anode types
    ANODEPHA:INTARR(8),   $     ; Array of triggered anode pulse heights
    ANODENRG:FLTARR(8),   $     ; Array of triggered anode energies
    ANODESIG:FLTARR(8),   $     ; Array of triggered anode energy errors


    Total_Energy      : 0.0 ,$    ; 4 135
    Total_Energy_Err  : 0.0 ,$    ; 4 139

    Quality           : 0   ,$    ; 2 141

    Latitude          : 0.0 ,$    ; 4 145
    Longitude         : 0.0 ,$    ; 4 149
    Altitude          : 0.0 ,$    ; 4 153
    Depth             : 0.0 ,$    ; 4 157
    Point_Azimuth     : 0.0 ,$    ; 4 161
    Point_Zenith      : 0.0 ,$    ; 4 165

    Rotation_Angle    : 0.0 ,$    ; 4 169
    Rotation_Status   : 0   ,$    ; 2 171
    Live_Time         : 0.0 ,$    ; 4 175
    Cor_Live_Time     : 0.0 }     ; 4 179

  Packet_Len = 179L ; In Bytes
  ;
  ;------
  ;


  ;
  ;-- we have multiple sweeps or files for each run. 
  ;-- 
  ;   - Get the hardware event class statistics for now.
  ;
  Inv_Arr= LonARr(32)
  C_Arr = LONARR(32)
  CC_Arr = LONARR(32)
  PC_Arr = LONARR(32)
  P_Arr  = LonArr(32)
  PP_ARr = LonArr(32)
  PPC_Arr = LONARR(32) 
  Oth_ARr = LONARR(32) 
  
  TempC_Arr = LonArr(32)
  
  Tot_Time_Ran = 0.0D
  AVG_LT = DblArr(32)
  AVG_LT[*] = 0.0D
  all_evt = 0L
  ski_evt = 0l
  
  PC_HIST = DBLARR(32,1000)
  For p = 0, nfiles-1 Do Begin
  
    ;
    ;---- Each file
    ;
    fname = evtfiles[p]

    
    print, fname

    ;
    ;--- Grab some file info
    ;
    f = file_info(fname)

    ;
    ;--- Open the binary file and dump it in Data and Close the file.
    ;
    Openr, lun, fname, /GET_Lun

    ;
    ;--- Grab total no. of packets
    ;
    TotPkt = long(f.size/Packet_Len)
    all_evt = all_Evt+TotPkt
    ;
    ;--- Replicate the structure for each packets.
    ;
    Event_data = replicate(Struc, TotPkt)

    ;
    ;---- Grab all the event data all at once.----
    ;
    For i = 0, TotPkt-1 Do Begin
      readu, lun, Struc        ; read one event
      Event_data[i] =Struc        ; add it to input array
    EndFor
    Tot_Time_Ran = Tot_Time_Ran+ Event_Data[i-1].Swept_time
    ;
    ;--- Free Lun ----
    ;
    Free_Lun, lun
   
    ;
    ;-- Now read teh individual event data.
    ;
    print, TotPkt
    Cntr1 =0L
    Cntr2 =0L
    For i = 0, TotPkt-1 Do Begin
         Data = Event_Data[i]
         
         If Data.Quality LT 0 THen goto, SKip_Event
                             ;
         ;-- We are only interested in threshold and the event classifications here so.
         ;
         modno = Data.Mod_Position
         
               
         Temp_No = Data.No_Anodes
         N_NCal = 0L
         N_NPla = 0L
         
  
         ;
         ;-- Energy Threshold --
         ;
         Pla_energy = 0.0D
         cal_energy = 0.0D
         For j = 0, Temp_no-1 Do Begin
              ;
              ;1 plastic, 2 calorimter for this.
              ;
              If Data.AnodeTyp[j] Eq 1 Then  Begin
                  If ((Data.AnodeNRG[j] GT Pla_EMin) and (Data.AnodeNRG[j] LT Pla_EMax)) Then begin
                      N_Npla++
                      pla_energy = Data.AnodeNrg[j]
                  Endif      
              Endif else if Data.AnodeTyp[j] Eq 2 Then Begin
                  If ((Data.AnodeNRG[j] GT Cal_EMin) and (Data.AnodeNRG[j] LT Cal_EMax)) Then begin
                    N_NCal++
                     cal_energy = Data.AnodeNrg[j]
                  Endif
              Endif
          
         Endfor
         
         N_NAnodes = N_NCal+N_NPla
         
         If N_NAnodes Eq 0 Then begin
          ski_evt++
          goto, SKip_Event
         endif
         
         If N_NCal Eq 1 and N_NPla Eq 1 Then Begin
              
              PC_HIST[modno,(cal_energy+pla_energy)]++
         EndIf
;         if i gt 15 then begin
;         Print, Data.AnodeTyp
;         Print, Data.AnodeNrg
;         Print, N_NCal, N_NPla, N_Nanodes, Temp_No
;         print
;         endif
          
          
          
         ;
         ;-- Event Classification ---
         ;
          If (N_Nanodes EQ 1) Then Begin
          ;    Cntr1++

              If N_NCal Eq 1 Then C_Arr[modno]++ Else if N_Npla Eq 1 Then P_Arr[modno]++ Else INv_Arr[modno]++
          Endif Else Begin
       ;     Cntr2++
                  If N_Nanodes Eq 2 Then BEgin
                        ; check for pp, cc, pc
                        If N_NCal  Eq 2 Then CC_Arr[modno]++ Else IF N_Npla Eq 2 Then PP_Arr[modno]++ Else begin
                            If (N_NCal  Eq 1) and (N_Npla Eq 1) Then PC_Arr[modno]++ Else Inv_Ar[modno]++
                        EndElse
                  Endif Else BEgin
                        If N_Nanodes Eq 3 Then Begin
                            If (N_NCal  EQ 1) and (N_Npla Eq 2)Then PPC_Arr[modno]++ Else Oth_Arr[modno]++
                        Endif else begin
                            Oth_Arr[modno]++
                        EndElse  
                  EndElse
          Endelse
         if i mod 10000 eq 0 then print, i
         
;       if i gt 20 then stop
    Skip_Event:
    EndFor ; i
    
    
    For j=0,31 Do begin
        If (Where(j EQ c2014) Ne -1) NE 0 Then Begin
        Avg_LT[j] = Avg_LT[j]+Avg(Event_DAta[ Where( (Event_Data.Mod_Position EQ j) ,/Null )].Cor_Live_Time)
;        TempC = N_Elements( Event_Data [where ( ((Event_Data.Mod_Position EQ j) and( Event_data.No_Anodes eq 1 ) and (Event_Data.No_Cal Eq 1)), /Null)] )
;        TempC_Arr[j] = TempC_Arr[j]+TempC
        EndIf
    Endfor
    
    
  EndFor ; p
  AvgLt = Avg_LT/nfiles

  
  Textfile = Title+'_qlook.txt'
   OPenw, LUn1, TextFile, /Get_Lun
          Printf, Lun1, 'Title   ='+Title
          Printf, Lun1, 'NoFiles ='+Strn(NFiles)
          Printf, Lun1, 'TimeRan ='+STRN(Tot_Time_Ran)
          Data =''
          Data1=''
          Data2=''
          Data3=''
          Data4=''
          data5=''
          data6=''
          data7=''
          data8=''
          For j=0,31 Do begin
                Data = Data+Strn(C_Arr[j])+' '
                Data1= Data1+Strn(CC_Arr[j])+' '
                Data2= Data2+Strn(PC_Arr[j])+' '
                Data3= Data3+Strn(P_Arr[j])+' '
                Data4= Data4+Strn(PP_Arr[j])+' '
                Data5= Data5+Strn(PPC_Arr[j])+' '
                Data6= Data6+Strn(Oth_Arr[j])+' '

                Data7= Data7+Strn(AVGLT[j])+' '
                Data8= Data8+Strn(Inv_Arr[j])+' '
          EndFor
          
          ; LT
          Printf, Lun1, 'AvgLT:'
          Printf, Lun1, Data7
          
          
          Printf, Lun1, 'C:'
          Printf, Lun1, Data
          
          Printf, Lun1, 'CC:'
          Printf, Lun1, Data1
          
          Printf, Lun1, 'PC:'
          Printf, Lun1, Data2
          
          Printf, Lun1, 'P:'
          Printf, Lun1, Data3
          
          Printf, Lun1, 'PP:'
          Printf, Lun1, Data4
          
          Printf, Lun1, 'PPC:'
          Printf, Lun1, Data5
          
          Printf, Lun1, 'Oth:'
          Printf, Lun1, Data6
          
          Printf, Lun1, 'InV:'
          Printf, Lun1, Data8
          

          
   Free_Lun, Lun1
print, all_Evt, ski_evt
help, PC_HIST
Openw, Lun4, Title+'_Ener.txt',/Get_Lun

  printf, lun4, Title
  printf, lun4, 'Total Time Ran      ='+STRN(Tot_Time_Ran)
  printf, lun4, 'SIZE =1000.00'
  printf, lun4, '/Empty Line'
for i = 0,31 Do begin
    printf, lun4, 'Mod_Pos='+strn(i)
    printf, lun4, 'AVG_LT ='+Strn(AVGLT[i])
    data=''
    for j = 0, 999 do begin
        data = data+ strn(PC_HIST[i,j])+' '
    endfor
    printf, lun4, data
endfor

free_lun, lun4

  Stop
End