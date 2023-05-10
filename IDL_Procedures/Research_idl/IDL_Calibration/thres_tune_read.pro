Pro Thres_Tune_Read,Input_File, Count=Count, XMax=XMax, Type=Type

True=1
False=0
    If Keyword_Set(Xmax) Eq 0 then X_Max=50 Else X_Max=XMax-1
    
    If Keyword_Set(Type)  EQ 0 Then Type_Flag = False Else Begin
                        Type_Flag = True
                        If (Type NE 2) and (Type NE 1) Then BEgin
                                  Print, ' TYPE ERROR: Enter 2 for Plastics and 1 for Calorimeters.
                                  Return
                        EndIf
                        If Type Eq 2 then Type =0
    EndElse 

    T_num = 0 ; Temporary Number Variable
    For k = 0, StrLen(Input_File)-5 Do Begin ; For Multiple FM included with different folders.
          T_num = StrPos(Input_File, 'FM',k)
          If T_num NE -1 Then Pos = T_num
    EndFor              
    Module  = StrMid(Input_File, Pos, 5)
    Input_Folder = StrMid(Input_File,0,Pos)

    Current_Rate = FltArr(64,15)
    Main_Array = FltArr(64,131)
    Error_Array= Fltarr(64,131)
    Current_Threshold = LonArr(64)
    
    Data=''
    Openr, Lun, Input_File, /Get_Lun
    
    C = 0L
    R_C = 0L
    Number_Counter =0L
    
    While Not EOF(Lun) DO Begin
                Readf, Lun, Data
                If Data EQ '' Then Goto, Jump_Empty_Line
                C++                  ; Line Counter
                
                ; If S pressed. ( Set Threshold ) read and averge the rates. 
                If STRPOS(Data, 'Current Thresholds:',0) GT 1 Then Begin
;             Print, Number_Counter, R_C
                        If Number_Counter GE 1 Then Begin  ; Skip for the first
                        
                                    ; Read and Get the Current Threshold.
                                    For i=0,15 Do BEgin
                                            Readf, Lun, Data
                                            Readf, Lun, Data
                                            Pos = StrPos(Data,'Chan',0)
                                            Pos1= StrPos(Data,'=',Pos)
                                            Pos2= StrPos(Data,'Chan',Pos1)
                                            Temp_Data = StrMid(Data,Pos+4, Pos1-Pos-4)
                                            Temp_Data2= StrMid(Data, Pos1+1,Pos2-Pos1-1)
                                            Chan=Fix(Temp_Data)-1
                                            Thres= Fix(Temp_Data2)
                                            Current_Threshold[Chan]= Thres
                                             
                                            Pos = StrPos(Data,'Chan',Pos1)
                                            Pos1= StrPos(Data,'=',Pos)
                                            Pos2= StrPos(Data,'Chan',Pos1)
                                            Temp_Data = StrMid(Data,Pos+4, Pos1-Pos-4)
                                            Temp_Data2= StrMid(Data, Pos1+1,Pos2-Pos1-1)
                                            Chan=Fix(Temp_Data)-1
                                            Thres= Fix(Temp_Data2)
                                            Current_Threshold[Chan]= Thres
                                            
                                            Pos = StrPos(Data,'Chan',Pos1)
                                            Pos1= StrPos(Data,'=',Pos)
                                            Pos2= StrPos(Data,'Chan',Pos1)
                                            Temp_Data = StrMid(Data,Pos+4, Pos1-Pos-4)
                                            Temp_Data2= StrMid(Data, Pos1+1,Pos2-Pos1-1)
                                            Chan=Fix(Temp_Data)-1
                                            Thres= Fix(Temp_Data2)
                                            Current_Threshold[Chan]= Thres
                                            
                                            Pos = StrPos(Data,'Chan',Pos1)
                                            Pos1= StrPos(Data,'=',Pos)
                                            Pos2= StrPos(Data,'Chan',Pos1)
                                            Temp_Data = StrMid(Data,Pos+4, Pos1-Pos-4)
                                            Temp_Data2= StrMid(Data, Pos1+1,Strlen(data)-Pos1)
                                            Chan=Fix(Temp_Data)-1
                                            Thres= Fix(Temp_Data2)
                                            Current_Threshold[Chan]= Thres
                                    EndFor ; i
                                    
                                    ; Average The Rates.  
                                    Temp_Rate=FltArr(R_C)                      
                                    For i = 0,63 Do Begin

                                            For j=0,R_C-1 Do Begin
                                                  Temp_Rate[j]=Current_Rate[i,j]
                                            EndFor;j
                                            
                                            Avg_Rate = Mean(Temp_Rate)
                                            Rate_Err = StdDev(Temp_Rate)
                                            Thres = Current_Threshold[i]
                                            Main_Array[i,Thres]= Avg_Rate
                                            Error_Array[i,Thres]= Rate_Err
                                            
                                     
                                    EndFor;i
                                    
                        EndIF
                        R_C = 0L
                        Number_Counter++
                EndIF
                
                ; If R pressed store teh Rates and average once its done. 
                If STRPOS(Data, 'Getting Rates:',0) GT 1 Then Begin
               
                        Readf, Lun, Data
                        For i = 0,15 Do Begin
                                Readf, Lun, Data
                                Readf, Lun, Data
                                Pos = StrPos(Data,'Chan',0)
                                Pos1= StrPos(Data,'=',Pos)
                                Pos2= StrPos(Data,'c/s',Pos1)
                                Temp_Data =StrMID( Data,Pos+4,2)
                                Temp_Data2=StrMid(Data,Pos1+1, Pos2-Pos1-1)
                                Chan= Fix(Temp_Data)-1
                                Rate = Float(Temp_Data2)
                                Current_Rate[Chan,R_C]=Rate
                                
                                Pos = StrPos(Data,'Chan',Pos1)
                                Pos1= StrPos(Data,'=',Pos)
                                Pos2= StrPos(Data,'c/s',Pos1)
                                Temp_Data =StrMID( Data,Pos+4,2)
                                Temp_Data2=StrMid(Data,Pos1+1, Pos2-Pos1-1)
                                Chan= Fix(Temp_Data)-1
                                Rate = Float(Temp_Data2)
                                Current_Rate[Chan,R_C]=Rate
                                
                                Pos = StrPos(Data,'Chan',Pos1)
                                Pos1= StrPos(Data,'=',Pos)
                                Pos2= StrPos(Data,'c/s',Pos1)
                                Temp_Data =StrMID( Data,Pos+4,2)
                                Temp_Data2=StrMid(Data,Pos1+1, Pos2-Pos1-1)
                                Chan= Fix(Temp_Data)-1
                                Rate = Float(Temp_Data2)
                                Current_Rate[Chan,R_C]=Rate
                                
                                Pos = StrPos(Data,'Chan',Pos1)
                                Pos1= StrPos(Data,'=',Pos)
                                Pos2= StrPos(Data,'c/s',Pos1)
                                Temp_Data =StrMID( Data,Pos+4,2)
                                Temp_Data2=StrMid(Data,Pos1+1, Pos2-Pos1-1)
                                Chan= Fix(Temp_Data)-1
                                Rate = Float(Temp_Data2)
                                Current_Rate[Chan,R_C]=Rate
                        EndFor; i
                        R_C++
                EndIF
          Jump_Empty_Line:
    EndWhile
    Free_Lun, Lun

    ; ======== Now Plot the Functions ===========
    ; may be use the Counts keyword to draw a line to see the threshold tuning factor. ..
    ; Also could include the graphical interface to generate the Channel value so that it is easier to convert to Energy and look at it.
    Output_Folder_Path = Input_Folder+'/'+Module+'_Thres_Rate'
    If Dir_Exist(Output_Folder_Path) EQ False Then File_MKdir, Output_Folder_Path
                 
    For i = 0,63 Do begin
       IF (Type_Flag Eq True) Then If (AnodeType(p+1) EQ Type) then Goto, Jump_Skip_Type
              Fname = Output_Folder_Path+'/'+Module+'_Rate_Vs_Chan_Anode_'+Strn(i)
              Plot_Thresh = Main_Array[i,*]
              Temp_Err_Arr = FltArr(131)
              For j=0,130 Do Temp_Err_Arr[j]= Error_Array[i,j]
              
;              Plot, Plot_Thresh , PSYM=10,Xrange=[0,X_Max],XStyle=1
;              OplotErr, Plot_Thresh, Temp_Err_Arr
;              
;              Cursor,X,Y,/Down,/Device
Y_Max=30; Max(Plot_Thresh)*1.2              
              Set_Plot, 'PS'
              loadct, 13                           ; load color
              Device, File = Fname, /COLOR,/Portrait
              Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                      
                      Plot, Plot_Thresh , PSYM=10, Title='Anode='+strn(i), CharSize=2.0,Xrange=[0,X_Max],$
                            XStyle=1, XTitle='Threshold(Channel)',YTitle='Counts per Second (C/s)' ,$
                            YStyle=1, YRange=[0,Y_MAX]
                      OplotErr, Plot_Thresh, Temp_Err_Arr
                      
             Device,/Close
             Set_Plot, 'X'
        Jump_Skip_Type:
    EndFor

End