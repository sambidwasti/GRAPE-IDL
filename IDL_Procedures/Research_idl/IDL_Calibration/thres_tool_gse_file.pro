Pro Thres_Tool_GSE_File, InputFolder
  ; The files should have file.txt extension.
  ; Must include, Rate_and_Threshold tagline somewhere in teh name
  ; Must start with FMXXX module signature.
  
  ; Some of them are FM*Threshold*Event.txt
  Search_Keyword = 'FM*Threshold*file.txt'
  FileNames = File_Search( InputFolder, Search_KeyWord)
  N_Files = N_Elements(FileNames)
  
  ;For Each File..
  For q = 0,N_Files-1 DO Begin
        
        
        ; Grab the Module no.
        Input_File = FileNames[q]
        Print, Input_File
        T_num = 0 ; Temporary Number Variable
        For k = 0, StrLen(Input_File)-5 Do Begin ; For Multiple / included with different folders.
          T_num = StrPos(Input_File, '/',k)
          If T_num NE -1 Then Pos = T_num
        EndFor; k
        File_Name = StrMid(Input_File,Pos+1,Strlen(Input_File)-Pos-1)   ; For creation of the Scat file.
        Module = StrMid(File_Name,2,3)
        
        
        Temp_Arr = StrArr(64)
        Counter = 0L
        ;Now open and read the file.
        
        
        Openr, Lun, Input_File, /Get_Lun
                Data =''
                
                While NOT EOF(Lun) Do Begin
                    Readf,Lun,Data
                    If STRPOS(Data,'Current Threshold', 0) GT 0 Then Begin
                                  
                                  For i = 0,15 Do BEgin
                                         Readf, Lun, Data
                                         Readf, Lun, Data
                                         Pos0= 0
                                         Print,Data
                                         For j = 0,2 Do begin
                                                  Pos1 = StrPos(Data,'=',Pos0)+2
                                                  Pos0 = StrPos(Data,' ',Pos1+1)
                                                  Temp_Str = StrMid(Data,Pos1, Pos0-Pos1)
                                                  Temp_Val = Strn(Long(Temp_Str))
                                                  Temp_Arr[Counter] = Temp_Val
                                                  COunter++
                                         EndFor; j
                                          
                                         Pos1 = StrPos(Data,'=',Pos0)+2
                                         Temp_Str = StrMid(Data,Pos1, StrLen(Data)-Pos1)
                                         Temp_Val = Strn(Long(Temp_Str))
                                         Temp_Arr[Counter] = Temp_Val
                                         COunter++
                                         
                                 EndFor; i
                  EndIF

                EndWhile
        Free_LUn, Lun
        
        ;== Now create the GSE THreshold File with THXXX.txt file name
        Openw, Lun1, InputFolder+'/TH'+Module+'.txt',/Get_Lun
                  For i=0,63 do Begin
                           Temp_Data = Temp_Arr[i]
                           Printf, Lun1, Temp_Data
                  EndFor
        Free_Lun, Lun1

  EndFor
  
  
End
