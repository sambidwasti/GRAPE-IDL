Pro Cal_Tool_Process, File, Calibration_File

  ;
  ;-- Calibration Statistics to compare with the sims.
  ;

  True =1
  False=0
  
  ;
  ;--- Filters ---
  ;
  Pla_Min = 5.0
  Cal_Min = 20.0
  
  ;
  ; -- Energy Calibration File ---
  ;
  ReadCol, Calibration_File, Cal_File_id, Cal_File_Slope, Cal_File_SlopeErr, Cal_File_Inter, Cal_File_Inter_Err, Chisqr, format='I,F,F,F,F,F',/Silent
  ; -- Anodes are 0~63


  Data =''

  ;-- Define Stucture --
  ; Since its easier to process a structure

  Cal_Event_struc = {$
    
    Live_Time       :0.0,           $   ; Fractional LiveTIme = value/255..

    NAnodes         :0B,            $   ; Number of triggered anodes (1-8)
    NPls            :0B,            $   ; Number of triggered plastic anodes
    NCal            :0B,            $   ; Number of triggered calorimeter anodes

    EvType          :0B,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)
    EvClass         :0B,            $   ; C = 1, CC =2, PC =3, PP =4, PPC =6 more than 2 events 7 for now. P =5

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types

    AnodeNrg        :FltArr(8),     $   ; Array of triggered anode energies Corrected

    TotEnrg         :0.0            $
  }

  Cal_Event = Cal_Event_Struc

  Tot_event = 0L
  Openr, Lun, file, /Get_lun

  Total_lines = File_Lines(File)
  Print, Total_lines/2

  OutFile = File +'_calprocess.dat'
  Openw, Lun2, Outfile, /Get_lun
  While Not EOF(Lun) Do Begin
    Readf, Lun, Data

    ;
    ;-- Work with an event --
    ;

    If Strmid(Data,0,1) EQ '#' Then Begin
      If StrMid(Data,2,5) EQ 'Valid' Then Goto, Skip_Event
      Temp_Event = replicate(Cal_Event_Struc,1)
      Tot_event++
      EOL = StrLen(Data)

      ;
      ;-- This is the Live-Time --
      ;
      Pos1 = StrPos(Data,' ',2)
      Pos2 = StrPos(Data,' ',Pos1+1)
      LiveTime = (Double(Strn(Strmid(Data,Pos1, Pos2-Pos1)))/255.0)
      
      
      ;
      ;Now the event starts
      ;
      Anode_Counter =0L
      Nplastic = 0L
      Ncalorim = 0L
      Tem_nrg = 0.0
      ID_Array = IntArr(8)
      ID_Type  = IntArr(8)
      ID_Nrg   = FltArr(8)
      While (pos2 LE EOL) and ( Pos2 GT -1) Do Begin

        ;
        ;-- Separate each anode triggers --
        ;
        Pos1 = Pos2
        Pos2 = StrPos(Data,' ',Pos1+1)

        Temp_Anodedata = StrTrim(StrMId(Data, Pos1, Pos2-Pos1),2)
        
        
        If Temp_Anodedata NE '' Then Begin
          If Anode_Counter GT 7 Then goto, skip_anodes

          An_ID = Fix(StrMid(Temp_AnodeData,0, 2))-1 ; this reporting is from 1~64 so we need to subtract 1.
          If An_ID Eq 34 then Goto, Skip_Event

          
          An_Pul = Fix(StrMid(Temp_AnodeData,2,4))
          An_nrg = Cal_File_Slope[An_ID]*AN_Pul + Cal_File_Inter[AN_Id]

          ;
          ;--- Energy Filters ---
          ;
          If (ANodeType(An_ID) Eq 0) and (an_nrg LT Cal_min) then goto, Skip_Event
          If (AnodeType(An_ID) Eq 1) and (an_nrg LT Pla_min) then goto, Skip_Event
           If AN_nrg lt 5.0 Then Print, An_Nrg, AN_ID

          Tem_nrg = tem_nrg + An_nrg

          

          If anodetype(An_ID) EQ 0 Then Ncalorim++
          If anodetype(An_ID) EQ 1 Then NPlastic++

          
          ID_Array(Anode_Counter) = An_ID
          ID_Type(Anode_Counter)  = AnodeType(An_ID)
          ID_Nrg(Anode_Counter)   = An_Nrg
          
     
          Anode_Counter++

        Endif ; ''

        
        skip_anodes:
        
        Temp_Event.AnodeID= Id_Array
        Temp_Event.AnodeNrg= Id_Nrg
        Temp_Event.AnodeTyp= Id_Type
        
        Temp_Event.NAnodes = Anode_Counter
        Temp_Event.NPls    = NPlastic
        Temp_Event.NCal    = NCalorim

        If Anode_Counter EQ 1 Then begin
          If NPlastic Eq 1 Then Temp_Event.EvClass = 5 Else IF NCalorim Eq 1 Then Temp_Event.EvClass=1
          Temp_Event.EvType = 0
         
        Endif Else Begin
          If Anode_Counter Eq 2 Then Begin
            Temp_Event.EvClass = EventClass(Temp_Event.AnodeID[0], Temp_Event.AnodeID[1])
            Temp_Event.EvType  = EventType(Temp_Event.AnodeID[0],Temp_Event.AnodeID[1])
          Endif Else Begin
            If Anode_Counter Eq 3 then begin
              If (NPlastic Eq 2) and (NCalorim Eq 1) Then Temp_Event.EvClass = 6
              Temp_Event.EvType = 0
            Endif Else BEgin
              Temp_Event.EvClass = 7
              Temp_Event.EvType = 0
            Endelse

          Endelse

        Endelse

        Temp_Event.TotEnrg = tem_nrg
        Temp_Event.Live_Time = LiveTime
        writeu, lun2, Temp_Event
      EndWhile; POS..

      If Tot_Event mod 10000 Eq 0 Then print, Tot_Event
    Endif ; #

    Skip_Event:

  Endwhile ; EOF

  PRint, Tot_event
  Free_Lun, Lun



  Free_Lun, Lun2
End