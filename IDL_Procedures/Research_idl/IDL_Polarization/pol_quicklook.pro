Pro Pol_Quicklook, Input_Folder
  True=1
  False=0
  
    Skip_Line =20
    Flag_Anode=34
    
    Ener_Hist= LonArr(500)
    ;=== Grabbing all the files===
    List_of_Files = File_Search(Input_Folder+'/*deg*.txt')
    N_Files = N_Elements(List_of_Files)
    
    ;--- Output Folder and file name selection ---
    T_num = 0 ; Temporary Number Variable
    For k = 0, StrLen(Input_Folder)-5 Do Begin ; For Multiple / included with different folders.
      T_num = StrPos(Input_Folder, '/',k)
      If T_num NE -1 Then Pos = T_num
    EndFor; k
    Output_Folder= StrMid(Input_Folder,0,Pos+1)
    File_Name = StrMid(Input_Folder,Pos+1,Strlen(Input_Folder)-Pos-1)
    
    
    Ener_Files = File_Search(Output_Folder+'/*Energy_Calibration*.txt')

        ;--- Check for the Energy File.
        If n_elements(Ener_Files) NE 1 Then BEgin
          Print, ' INVALID: Either no Energy File or Too many of them present '
          return
        EndIF
        
        Energy_Array = DblArr(64,2)     ; Array[0,0]= slope and Array[0,1]= Intercept
        
        ;--- Extract Energy Information. ---
        Openr, Lun1, Ener_Files[0], /Get_Lun
        
        Data1 =''
        Rows_File1 = File_Lines(Ener_Files[0])
        
        For j=0,Rows_File1-1 Do Begin
              Readf, Lun1, Data1
              
              If j Gt 9 Then Begin  ; For skipping comments. we start at 0 so GT 9 for 10 lines to skip.
              
                      Pos = StrPos(Data1,' ',1)
                      p = FIX(StrMid(Data1,0,Pos)) ; Anode
                      
                      Pos1 = StrPos(Data1,'.',Pos)
                      Pos2 = StrPos(Data1,' ',Pos1)
                      M = Double(StrMid(Data1,Pos+1,Pos2-Pos))
                      
                      Pos = Pos2
                      Pos1 = StrPos(Data1,'.',Pos)
                      Pos2 = StrPos(Data1,' ',Pos1)
                      
                      Pos = Pos2
                      Pos1 = StrPos(Data1,'.',Pos)
                      Pos2 = StrPos(Data1,' ',Pos1)
                      C = Double(StrMid(Data1,Pos+1,Pos2-Pos))
                      
                      Energy_Array[p,0]= M
                      Energy_Array[p,1]= C
                
              Endif
        EndFor
        Free_Lun, Lun1
    ;===================Finished Energy Extraction===================


;    ;============= Working on Histogram ============
;    Main_Histogram = LonArr(360)
    Live_Time =0L
    LT_Count=0L

;  
    ;--- Operating on all files ---
    For i=0, N_Files-1 Do Begin
        Fname = List_of_Files[i]
        
        ;---- Grabbing Sweep/Table Angle ------
        T_num = 0 ; Temporary Number Variable
        
        Openr, Lun, Fname, /Get_Lun
        data =''
        
        ;---- Skip Rates---
        For j =0, skip_line-1 Do Begin
          Readf, Lun, Data
        EndFor
        
        ;--- Read the whole file now and extract data---
        While not EOF(Lun) DO Begin
          Readf, Lun, Data
          
          ; -- Check for PC Data --
          IF Strmid(Data,0,1) NE '#' Then Goto, Jump_Line
          
          Pos1 = StrPos(Data,' ',0)
          Pos2 = StrPos(Data,' ',Pos1+1)

          
          ;---- Selecting 2 events for PC ------
          Pos1 = StrPos(Data,' ',0)
          Pos2 = StrPos(Data,' ',Pos1+1)
          Temp_Str = StrMid(Data, Pos1, Pos2-Pos1)
          IF FIx(Temp_Str) NE 2 then Goto, Jump_LIne
          
          ;---- Getting the Live Time ----
          Pos1 = StrPos(Data,' ', Pos2+1)
          Temp_Str = StrMid(Data, Pos2, Pos1-Pos2)
          Live_Time= Live_Time+ Fix(Temp_Str)
          LT_Count++

          
          ;---- Getting the Anodes and Pulse  Heights
          Pos2 = StrPos(Data,' ',Pos1+1)
          If (Pos2-Pos1) NE 6 Then Goto, Jump_Line      ; Checking for incorrect data format
          Temp_Str = StrMid(Data, Pos1, Pos2-Pos1)
          Anode1 = Fix(Strmid(Data,Pos1+1, 2))-1
          Pulse1 = Fix(Strmid(Data,Pos1+3, 3))
          
          Pos1 = StrPos(Data,' ', Pos2+1)
          If (Pos1- Pos2) NE 6 then Goto, Jump_Line     ; Checking for incorrect data format
          Temp_Str = StrMid(Data, Pos2, Pos1-Pos2)
          Anode2 = Fix(Strmid(Data,Pos2+1, 2))-1
          Pulse2 = Fix(Strmid(Data,Pos2+3, 3))
          
          ;----- For any flagged anodes ---- ( Modify Later )
          If (Anode1 Eq Flag_Anode) or (Anode2 Eq Flag_Anode) then Goto, Jump_Line
          
          
              Ener1 = Energy_Array[Anode1]*Pulse1+ Energy_Array[Anode1]
              Ener2 = Energy_Array[Anode2]*Pulse2+ Energy_Array[Anode2]
              Tot_Ener = Long(Ener1+Ener2)

          IF Tot_Ener LT 500 Then Ener_Hist[Tot_Ener]++

          Jump_Line:  ; Line to jump if any error occured.
        EndWhile
        Free_Lun, LUn
    EndFor;i
    Text_File_Name = FIle_Name+'Ener_File'
    Avg_LT = Double(Double(Live_Time)/Double(LT_Count))
;    ; ===== Now Need a Text-File of these Histogram ====
     Openw, Lunger, Output_Folder+Text_File_Name+'.txt', /Get_Lun
     
     ;=== Comment 10 lines ===
    Printf, Lunger, ' Files of Histogram for each of the scattering angles. '
    Printf, Lunger, ' Folder Name         ='+File_Name
    Printf, Lunger, ' Average LT          ='+ Strn(Avg_LT)
    Printf, Lunger, ' Time for each Sweep ='+ Strn(180)
    Printf, Lunger, ' Flagged             =34'
    Printf, Lunger, '/EmptyLine'
    Printf, Lunger, '/Empty Line'
    Printf, Lunger, '/Empty Line'
    Printf, Lunger, '/Empty Line'
    Printf, Lunger, '/Empty Line'
    
    ; Now write the histograms.
    For i = 0,499 Do Begin
      Temp_Str = Strn(Ener_Hist[i])
      Printf, Lunger, Temp_Str
    EndFor
    
    Free_Lun, Lunger

End