Pro Cal_Tool_Get_Info, INputFolder
    ; Get a text file of Rate, Thres Channel

    Search_Keyword = 'FM*Rate_and_Threshold*file.txt'
  FileNames = File_Search( InputFolder, Search_KeyWord)
  N_Files = N_Elements(FileNames)
      IF N_Files LE 1 Then BEgin
              Search_Keyword = 'FM*Event.txt'
              FileNames = File_Search( InputFolder, Search_KeyWord)
              N_Files = N_Elements(FileNames)
      EndIf

  ;For Each File..
  For q = 0,N_Files-1 DO Begin
        
        ; Grab the Module no.
        Input_File = FileNames[q]
        T_num = 0 ; Temporary Number Variable
        For k = 0, StrLen(Input_File)-5 Do Begin ; For Multiple / included with different folders.
          T_num = StrPos(Input_File, '/',k)
          If T_num NE -1 Then Pos = T_num
        EndFor; k
        File_Name = StrMid(Input_File,Pos+1,Strlen(Input_File)-Pos-1)   ; For creation of the Scat file.
        Module = StrMid(File_Name,2,3)
        
        
        Thres_Arr = StrArr(64)
        Rate_Arr  = StrArr(64)
        Counter = 0L
        Counter1= 0L
        Rate_Thres_Cntr =0
        ;Now open and read the file.
        
        
        Openr, Lun, Input_File, /Get_Lun
                Data =''
                Rate_Cntr=0L
                While NOT EOF(Lun) Do Begin
                    Readf,Lun,Data
                    
                    If STRPOS(Data,'Current Threshold', 0) GT 0 Then Begin
                    Rate_Thres_Cntr++        
                    IF Rate_Thres_Cntr GT 1 Then Goto, Jump_File      
                                  For i = 0,15 Do BEgin
                                         Readf, Lun, Data
                                         Readf, Lun, Data
                                         Pos0= 0
                                         For j = 0,2 Do begin
                                                  Pos1 = StrPos(Data,'=',Pos0)+2
                                                  Pos0 = StrPos(Data,' ',Pos1+1)
                                                  Temp_Str = StrMid(Data,Pos1, Pos0-Pos1)
                                                  Temp_Val = Strn(Long(Temp_Str))
                                                  Thres_Arr[Counter] = Temp_Val
                                                  COunter++
                                         EndFor; j
                                          
                                         Pos1 = StrPos(Data,'=',Pos0)+2
                                         Temp_Str = StrMid(Data,Pos1, StrLen(Data)-Pos1)
                                         Temp_Val = Strn(Long(Temp_Str))
                                         Thres_Arr[Counter] = Temp_Val
                                         COunter++
                                         
                                 EndFor; i
                      EndIF
                      
                      If STRPOS(Data,'Getting Rates', 0) GT 0 Then Begin
                      Rate_Thres_Cntr++
                      IF Rate_Thres_Cntr GT 1 Then Goto, Jump_File    
                                IF Rate_Cntr Gt 0 Then goto, JumpRate
                                 Rate_Cntr++
                                 Readf, Lun, Data
                                 For i = 0,15 Do BEgin
                                         Readf, Lun, Data
                                         Readf, Lun, Data
                                         Pos0= 0
                                         For j = 0,2 Do begin
                                                  Pos1 = StrPos(Data,'=',Pos0)+2
                                                  Pos0 = StrPos(Data,'c/s',Pos1+1)
                                                  Temp_Str = StrMid(Data,Pos1, Pos0-Pos1)
                                                  Temp_Val = Strn(Float(Temp_Str))
                                                  Rate_Arr[Counter1] = Temp_Val
                                                  COunter1++
                                         EndFor; j
                                          
                                         Pos1 = StrPos(Data,'=',Pos0)+2
                                         Temp_Str = StrMid(Data,Pos1, StrLen(Data)-Pos1)
                                         Temp_Val = Strn(Float(Temp_Str))
                                         Rate_Arr[Counter1] = Temp_Val
                                         COunter1++
                                         
                                 EndFor; i
                                 
                                 Readf, Lun, Data
                                 Readf, Lun, Data
                                 
                                 Pos1 = StrPos(Data,'=',0)+2
                                 Pos0 = StrPos(Data,'c/s',Pos1)
                                 Valid= STRN(LONG(STRMID(Data,Pos1,Pos0-Pos1)))
                                 
                                 JumpRate:
                      EndIF
                      
                EndWhile
        Free_LUn, Lun
        Jump_File:
        ;== Now create the GSE THreshold File with THXXX.txt file name
        Openw, Lun1, InputFolder+'/Temp_'+Module+'.txt',/Get_Lun
                  For i=0,63 do Begin
                           Temp_Data = Thres_Arr[i]+'    '+Rate_Arr[i]
                           Printf, Lun1, Temp_Data
                  EndFor
                  Printf, Lun1, 'O'+'    '+Valid
        Free_Lun, Lun1
        
  EndFor
    
End