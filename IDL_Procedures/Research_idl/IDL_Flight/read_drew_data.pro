Pro Read_Drew_Data, Input_File
; Reading CSBF Drew's data and doing some conversion to match the formats in HRS data.

    Data =''
    CD, Cur=Cur
    
    Openw, Lun1, Cur+'/Grape_Trimble_v1.txt', /GET_LUN
          Printf, Lun1, 'Date Time(HH:MM:SS) Time(StrtWeek) Heading Status(Drew) Elevation(kft) Lat Lon'
          
          
    openr, Lun, Input_File, /Get_Lun
    ; Skip first line.
    
    ; We need to add in the hours..
    
 
   
    Readf, Lun, Data
          While NOT EOF(Lun) do Begin
          Readf, Lun, Data
          ; Print, Data
          
          
          Data1 = STRSPLIT(Data, /EXTRACT)
    
          Temp_Val0 = Data1[0] 
          If Temp_Val0 eq '09/21/2014' Then goto, Skip_Line
         
          IF Temp_Val0 EQ '09/26/2014' Then Begin
                  Ini_Time = 432000  
          Endif Else  Begin
                  IF Temp_Val0 EQ '09/27/2014' Then Ini_Time = 518400 Else Goto, Skip_Line
          Endelse
       
          ;                                           Start of Friday 26th                                        Start of Sat 27th 
          
          
          Temp_Val = Data1[1]
          Pos0 = StrPos(Temp_Val,'.',0)
          Temp_Val1=StrMid(Temp_Val, 0, Pos0)
          
          ;Gotta extract, Hr, Min sec and get a total time since beg. of the week.\

          Pos1 = StrPos(Temp_Val,':',0)
          Temp_Hr = long(StrMid(Temp_Val, 0, Pos1))
          Temp_Time = Temp_Hr * 60 * 60 ; Now this is in seconds
          
          Pos2 = StrPos(Temp_Val,':',Pos1+1)
          Temp_Min =long(StrMid(Temp_Val, Pos1+1, Pos2-Pos1-1))
          Temp_Time = Temp_Time + (Temp_Min * 60)
           
          Pos3 = StrPos(Temp_Val,'.',Pos2+1)
          Temp_Sec =long(StrMid(Temp_Val, Pos2+1, Pos3-Pos2-1))
          Temp_Val_Time = Temp_Time + Temp_SEc + Ini_Time
          
       
          Temp_Val2 = Data1[2]
          
          Temp_Val3 = Data1[3]
          
          Temp_Val9 = Data1[9]
          
          Temp_Val10 = Data1[10]
          
          Temp_Val11 = Data1[11] 
          
          Str = Temp_Val0 +' '+ Temp_Val1 + ' '+ Strn(Temp_Val_Time)+ ' '+Temp_Val2 + ' '+Temp_Val3  + ' '+Temp_Val9 + ' '+Temp_Val10 + ' '+Temp_Val11 
          
          Printf, Lun1, Str
         Skip_LIne:
         EndWHile
    Free_LUn, Lun
    
    Free_Lun, Lun1

End