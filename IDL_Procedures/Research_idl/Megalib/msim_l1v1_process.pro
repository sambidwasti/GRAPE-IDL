Pro MSim_l1v1_process, Filename
  ;
  ; This is to read the SIM file created form Cosima
  ; Right now it prints out each event with evttime, anode anode energy. in each column.
  ;   Modifying as evt time is not necessary. Just one comment thing was sufficient.
  ;   Want to also create a binary file with structures including
  ;           EventType, EventClass, Energy, Etc.. Since reading and processing Structure is easier.
  ;
  
  ;
  ;-- Energy Broadening--
  ; 
  
  True = 1
  False =0

  ; VERSION
  Version = 1

  ; -- Counter --
  Counter = 0L

  ;
  ; -- Define the Structure --
  ;
  ; Byte = 1, INT = 2, Double =8, Float = 4.
  Sim_L1Event = { $
    VERNO     :0B,            $   ; Data format version number
    
    In_Enrg   :0.0,           $   ; Incident Energy
    In_XPos   :0.0,           $   ; Incident Photon X Pos
    In_YPos   :0.0,           $   ; Incident Photon Y Pos
    In_ZPos   :0.0,           $   ; Incident Photon Z Pos

    NAnodes   :0B,            $   ; Number of triggered anodes (1-8)
    NPls      :0B,            $   ; Number of triggered plastic anodes
    NCal      :0B,            $   ; Number of triggered calorimeter anodes

    EvType    :0B,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)
    EvClass   :0B,            $   ; Event Class (1=C, 2=CC, 3=PC, 4= intermdule)

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types
    
    ANODENRG_Uncor  :FLTARR(8),     $   ; Array of triggered anode energies    
    AnodeNrg        : FltArr(8),    $   ; Array of corrected Anode Energies.
    
    TotEnrg_Uncor   :0.0,           $
    TotEnrg         :0.0            $
  }
  Event_Lenth = 110

  l1data = Sim_l1Event

  ;
  ;---
  ;
  ANodeID = INTARR(8)
  ANodeNRG= FLTARR(8)
  ANodeNRG_Uncor= FLTARR(8)

  AnodeTyp= INTARR(8)

  

  Start_time = 0.0D
  Main_Data_Flag = False


  Openr,Lun, Filename, /Get_Lun
  Data=''

  Readf, Lun, Data      ; The first line of simulation data file
  Readf, Lun, Data      ; The first line of simulation data file


  Output_File = Filename +'.txt'
  Outfile     = Filename + '.l1data.dat'
  Openw, Lun1, Output_File, /Get_Lun
  Openw, Lun2, OutFile, /Get_Lun
  
  In_Ener= 0.0
  In_Ener_Pos = [0.0, 0.0, 0.0]
  
  evtevt =0L
  While not EOF(lun) Do Begin


    Readf, Lun, Data      ; The first line of simulation data file
    If Data EQ '' Then Goto, Next_Line

    If StrMid(Data,0,2) EQ 'TB' Then Begin
      Main_Data_Flag = True
      Start_Time = Double(Strn(StrMid(Data,3,StrLEn(Data)-3)))
    Endif


    ;
    ;-- The simulatiion starts now.
    ;
    If Main_Data_Flag EQ True Then Begin
      ;
      ;-- Now we need to separate each events---
      ; Dump each event in the text file.
      ;

      ;Each event starts with SE (Start of an event)
      ;
      ;If StrMid(Data,0,2) EQ 'SE'Then Begin
      While StrMid(Data,0,2) EQ 'SE' Do Begin
        
         evtevt++
         If evtevt mod 1000 eq 0 Then Print, Evtevt  
        ;
        ;-- Define the structure --
        ;
        Temp_l1data = Replicate(Sim_L1Event, 1)

        ;
        ;-- We already know the version no.
        ;
        Temp_l1data.VERNO = Byte(Version)

        Temp_PStr=''
        ;
        ;-- Next line is the Event ID, typically this is the event counter.
        ;
        Readf, Lun, Data


        ;
        ;--- Now the Observation time of the event.
        ;
        Readf, Lun, Data
        Temp_Str = Double(Strn(Strmid(Data,2,StrLen(Data)-2))) ; ths is in second.
        Evt_Time = Temp_Str * 1000 ; in ms
        ;                  Temp_PStr= String(Format='(I010,X)', EVT_TIme) + '   '


        ;
        ;--- Energy Deposited Total.
        ;
        Readf, Lun, Data
        Temp_Str = Float(Strn(Strmid(Data,2,StrLen(Data)-2))) ; ths is in second.
        In_Ener = Temp_Str
        
        ;
        ;--- Energy Escaped Total.
        ;
        Readf, Lun, Data
        Temp_Str = Float(Strn(Strmid(Data,2,StrLen(Data)-2))) ; ths is in second.
        In_Ener = In_Ener+Temp_Str
        
        ;
        ;--- Energy Deposited in not the sensitive material. (NS)
        ;
        Readf, Lun, Data

        ;
        ;--- Now the Interaction information starts.
        ; We dont know how many lines of these happen but they start with IA.
        ; The first one is usually the incindent photon.
        ;
        Readf, Lun, Data
        If (StrMid(Data,0,2) NE 'IA') Then  Readf, Lun, Data
        
        While (StrMid(Data,0,2) EQ 'IA') Do Begin
              If (StrMid(Data,3,4) EQ 'INIT') Then begin
                    Pos2 = 1
                    For j =0,2 Do begin
                       Pos1= StrPos(Data,';',Pos2) 
                       Pos2= StrPos(Data,';',Pos1+1) 
                    Endfor
                                   
                    ; Now the position of the incident photon.
                    Pos1= StrPos(Data,';',Pos2)
                    Pos2= StrPos(Data,';',Pos1+1)
                    InXPos = STRN(StrMid(Data,Pos1+1, Pos2-Pos1-1))
                    
                    Pos1= StrPos(Data,';',Pos2)
                    Pos2= StrPos(Data,';',Pos1+1)
                    InYPos = STRN(StrMid(Data,Pos1+1, Pos2-Pos1-1))
                    
                    Pos1= StrPos(Data,';',Pos2)
                    Pos2= StrPos(Data,';',Pos1+1)
                    InZPos = STRN(StrMid(Data,Pos1+1, Pos2-Pos1-1))
                    
                
              Endif

          ;
          ;--- Read the Interaction data.
          ;
          ;  Print, Data
          Readf, Lun, Data

        EndWhile

        ;
        ;--- HT data --
        ;
        ANode_Counter = 0L
        While (StrMid(Data,0,2) EQ 'HT') Do Begin
          ; HT
         
          ;
          ;--We skip the Detector ID as this is not that important
          ;

          ;
          ;-- We have the Detector coordinates. We are only intersted in XY.
          ;
          ;
          ;-- X Cordinate --
          ;

          Pos1= StrPos(Data,';',0)
          Pos2= StrPos(Data,';',Pos1+1)
          Temp_data = StrMid(Data, Pos1+1, Pos2-Pos1-1)
          X_Cord = Strn(Temp_Data)

          ;
          ;-- Y Cordinate --
          ;
          Pos1= Pos2+1
          Pos2= StrPos(Data,';',Pos1+1)
          Temp_data = StrMid(Data, Pos1+1, Pos2-Pos1-1)
          Y_Cord = Strn(Temp_Data)

          ;
          ;-- Z Cordinate -- We dont need this yet.
          ;
          Pos1= Pos2+1
          Pos2= StrPos(Data,';',Pos1+1)
          Temp_data = StrMid(Data, Pos1+1, Pos2-Pos1-1)
          Z_Cord = Strn(Temp_Data)

          ;
          ;-- Now the Energy Deposited in the anode --
          ;
          Pos1= Pos2+1
          Pos2= StrPos(Data,';',Pos1+1)
          Temp_data = StrMid(Data, Pos1+1, Pos2-Pos1-1)
          Energy_Dep = Strn(Temp_Data)

          ;
          ;-- Time Since start of the Event -- Not needed.
          ;
          Pos1= Pos2+1
          Pos2= StrPos(Data,';',Pos1+1)
          Temp_data = StrMid(Data, Pos1+1, Pos2-Pos1-1)

          ;                      Print, Data

          Readf, Lun, Data
          ;                      Print, Data
          Temp_Arr = [X_Cord, Y_Cord]
          Anode = Grp_GETID(Temp_Arr)
          Temp_PStr = Temp_PStr + String(Format='(I02,X)', Anode) + String(Format='(D07.2,X)', Energy_Dep)+ '   '
          ;                                            print, Temp_PStr
          If Anode_Counter LT 8 Then Begin
            AnodeID[Anode_Counter] = Anode
            AnodeNrg_UnCor[Anode_Counter]= Energy_Dep
            AnodeNrg[Anode_Counter] = Correct_Energy(Anode,Energy_Dep)
          EndIf
         

          Anode_Counter++

          ;
          ;--- .
          ;

        EndWhile ;/HT

        ;
        ;-- More Processing and collection--
        ;
        NoAnodes = ANode_Counter
        NoPla = 0
        NoCal =0
        Tot_Energy = 0.0
        Tot_Energy_Uncor =0.0
        For i = 0, NoAnodes-1 Do Begin
          Anodetyp[i] = anodetype(AnodeID[i])

          If AnodeTyp[i] EQ 0 Then NoCal++
          If AnodeTyp[i] EQ 1 Then NoPla++
          Tot_Energy = AnodeNrg[i]+ Tot_Energy
          Tot_Energy_Uncor= AnodeNrg_UnCor[i]+ Tot_Energy_Uncor
        EndFor

        ;
        ;-- For the Event Class cases --
        ;
        ; We need to define various ones first.
        ; C = 1, CC =2, PC =3, PP =4, more than 2 events 7 for now. P =5
        ; We want to include PPC as 6 and move others to 7
        EvtType = 0
        EvtClass = 0
        If NoAnodes GT 2 Then Begin
          If NoAnodes EQ 3 Then Begin
              If Check_PPC(AnodeID[0],AnodeID[1],AnodeID[2]) EQ True then EvtClass =6 Else EVTClass = 7
            
          EndIF Else EvtClass = 7
        
        EndIf Else BEgin
          If NoAnodes EQ 1 Then BEgin
            If AnodeTyp[0] EQ 0 Then EvtClass = 1 Else If AnodeTyp[0] EQ 1 Then EvtClass = 5; For Calorimeter
          Endif Else Begin
              If NoAnodes EQ 2 Then BEgin
              EvtClass = EventClass(AnodeID[0],AnodeID[1])
              EvtType  = EventType(ANodeID[0],AnodeID[1])
              Endif else if NoAnodes EQ 0 Then EvtClass =0
          Endelse
        EndElse
        
        
        ;
        ;--- Define the L1Data Values ---
        ;

        Temp_l1data.NAnodes = Byte(NoAnodes)
        Temp_l1Data.NPls = Byte(NoPla)
        Temp_l1Data.NCal = Byte(NoCal)
        
        Temp_l1Data.In_Enrg = Float(In_Ener)
        Temp_l1Data.In_XPos = Float(InXPos)
        Temp_l1Data.In_YPos = Float(InYPos)
        Temp_l1Data.In_ZPos = Float(InZPos)

        Temp_l1Data.EvType = EvtType
        Temp_l1Data.EvClass = EvtClass

        Temp_l1Data.AnodeID  = Byte(AnodeID)
        Temp_l1Data.AnodeTyp = Byte(AnodeTyp)
        
        Temp_l1Data.AnodeNrg_Uncor = Float(AnodeNrg_Uncor)
        Temp_l1Data.AnodeNrg = Float(AnodeNrg)

        Temp_l1Data.TotEnrg = Tot_Energy
        Temp_l1Data.TotEnrg_Uncor = Tot_Energy_Uncor

        ;
        ; Dump Each Event into a different Text File.
        ;

        ; We would like the following format for now.
        ; Time(ms) IDENER  ID = anode id, ENER=Energy in KEV.
        ; IDENER  ID = anode id, ENER=Energy in KEV. Updated.

        ;                                        print, Temp_PStr
;if evtevt gt 20 then stop
        Printf, Lun1,Temp_PStr
        Counter++

        l1Data = [l1Data,Temp_l1Data]
        ;                  Print
      EndWhile ; Strmid

    Endif


    Next_Line:
  Endwhile

  L1Data = L1Data[1:N_Elements(L1Data)-1]
  ;
  ;------ Generating Statistics ------
  ;
  Sts_TotEvt = n_elements(l1Data)
  Sts_C      = n_elements(l1Data[where((l1Data.EvClass EQ 1), /Null)])
  Sts_CC     = n_elements(l1Data[where((l1Data.EvClass EQ 2), /Null)])
  Sts_PC     = n_elements(l1Data[where((l1Data.EvClass EQ 3), /Null)])
  Sts_PP     = n_elements(l1Data[where((l1Data.EvClass EQ 4), /Null)])
  Sts_P      = n_elements(l1Data[where((l1Data.EvClass EQ 5), /Null)])
  Sts_PPC    = n_elements(l1Data[where((l1Data.EvClass EQ 6), /Null)])
  Sts_Rest   = n_elements(l1Data[where((l1Data.EvClass EQ 7), /Null)])
  Sts_Rests  = n_elements(l1Data[where((l1Data.EvClass EQ 0), /Null)])




  Print, n_elements(l1Data)
  ;Print, L1data[where(l1Data.EvClass EQ 0, /Null)]
  Print, Sts_C, Sts_CC, Sts_PC, Sts_PP, Sts_P, Sts_PPC, Sts_Rest, Sts_Rests

  Writeu, Lun2, L1Data

  Free_Lun, Lun2
  Free_Lun, Lun1
  Free_lun, Lun
End