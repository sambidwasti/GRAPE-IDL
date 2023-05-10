Pro Cal_Tool_Combine_Energy_Files, First_File_Folder, Second_File_Folder

True=1
False=0
        If (n_params() EQ 2) Then Files_Flag = True Else IF (n_params() EQ 1) Then Files_Flag = False Else Begin
              Print,'INVALID input parameters'
              Return
        EndElse    

        If Files_Flag EQ True Then File_Name= [First_File_Folder,Second_File_Folder] 
        
        If Files_Flag EQ False Then Begin
              Search_KeyWord = 'FM*Energy*.txt'         ; For Flood File Selection
              InputFileFolderPath = First_File_Folder+'/'
              File_Name = File_Search( InputFileFolderPath, Search_KeyWord) 
              If( N_elements(File_Name)) EQ 0 Then Begin
                         Print, 'ERROR: NO FILE EXISTS WITH *000Deg..*'
                         Return
              EndIf
        EndIf
        
                T_num = 0 ; Temporary Number Variable
                For k = 0, StrLen(File_Name[0])-5 Do Begin ; For Multiple FM included with different folders.
                            T_num = StrPos(File_Name[0], '/',k)
                            If T_num NE -1 Then Pos = T_num
                EndFor   
                Temp_Name = StrMid(File_Name[0],Pos+1,Strlen(File_Name[0])-Pos-1)
                Input_Folder = StrMid(File_Name[0],0,Pos+1)
                Module = Strmid(Temp_Name,2,3)
                Main_Str_Array = StrArr(64)
        
        For i = 0, n_elements(File_Name)-1 Do Begin

              EnergyFile= File_Name[i]
              Lines = File_Lines(EnergyFile)
             
              Openr, Lun,EnergyFile, /Get_Lun
              data=''
              
              For j=0,Lines-1 Do Begin  ; Skip_Lines
             
                      Readf, Lun, Data
                      If j Gt 9 Then Begin
                            Pos = StrPos(Data,' ',1)
                            p = FIX(StrMid(Data,0,Pos)) ; Anode
                            ; print, Main_Str_Array[p]
                            Main_Str_Array[p]=Data
                            ; print, Main_Str_Array[p]
                            ; Stop
                      Endif
                      
              EndFor
              Free_Lun, Lun
             
         EndFor        
         OutPut_File= Input_Folder + 'FM'+Module+'_Energy_Calibration.txt'
         Openw, Lunger, Output_File, /Get_Lun
                 Printf, Lunger, 'LINEAR FITTED ENERGY CALIBRATION FILE'
                 Printf, Lunger, 'Module          : '+ Module
                 Printf, Lunger, 'Fitted for      : All Anodes'
                 Printf, Lunger, 'Linear Fit      : Energy = slope* Channel + Intercept'
                 printf, Lunger, 'line 5'
                 printf, Lunger, 'line 6'
                 printf, Lunger, 'line 7'
                 printf, Lunger, 'line 8'
                 printf, Lunger, 'line 9'
                 Printf, Lunger, 'Anode Slope  SlopeErr  Intercept InterceptErr  Chisquare(Non-Scaled)'
                For i = 0,63 Do begin
                      Printf, Lunger, Main_Str_Array[i]
                EndFor
         Free_Lun,Lunger
              
End