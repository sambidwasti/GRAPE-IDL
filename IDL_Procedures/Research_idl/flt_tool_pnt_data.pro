pro Flt_Tool_Pnt_Data , Hrs_File, Drew_File
  ; - Read in our txt files.
  ; - Read in drew's txt file. *Trimble_extracted.txt this is the file without the bad date generated from the read_drew_data.pro

  ; - Creating PointingData.txt
  ;
  True = 1
  False =0
  cd, Cur=Cur


  ;
  ; Source = [ Ascent, Sun,     Blank-2, Cyg-X-1,    Blank-4,   Crab,  Termination(last sweep)]
  ;              0      1         2         3           4         5           6
  Source_Time = [0, 493944, 510056, 514710, 540383, 545811, 552552]

  data = ''
  ;
  ;************************************************************************************
  ;
  ; Drew's data grabbed in an array.
  Rows_File = File_Lines(Drew_File)
  Drew_Array = STRARR(Rows_File, 3)
  openr, Lun, Drew_File, /Get_Lun

  Readf, Lun, data
  a = 0
  While Not EOF(Lun) Do Begin
    Readf, Lun, data

    Pos0 = StrPos(Data, ' ', 0)
    Pos1 = StrPos(Data, ' ', Pos0+1)
    Pos0 = StrPos(Data, ' ', Pos1+1)
    Temp_Val = StrMid(Data, Pos1+1, Pos0-Pos1-1)
    Drew_Array[a,0] = Temp_Val

    Pos1 = StrPos(Data, ' ', Pos0+1)
    Temp_Val = StrMid(Data, Pos0+1, Pos1-Pos0-1)
    Drew_Array[a,1] = Temp_Val

    Pos0 = StrPos(Data, ' ', Pos1+1)
    Temp_Val = StrMid(Data, Pos1+1, Pos0-Pos1-1)
    Drew_Array[a,2] = Temp_Val

    a++
  EndWhile
  Free_Lun, Lun
  
  ;
  ;---------------------------------------------------------------------------------------
  ;

  ;------ Now the HRS File -------------

  ;
  ;****************************************************************************************
  ;

  Print, Drew_Array[5,0]

  ; We just want to interpolate for Blank4 and Crab.
  Rows_File1 = File_Lines(HRS_File)
  PRint, Rows_File1
  a =0
  openr, Lun1, Hrs_File, /Get_Lun
  Readf, Lun1, Data
  Readf, Lun1, Data
  Readf, Lun1, Data
  Readf, Lun1, Data


  Openw, Txt_Lun, Cur+'/Pnt_Data.txt', /Get_Lun
  Printf, Txt_Lun, 'GPS_TIME AZIAVG DataFile MINAZI MAXAZI ZEN COSAZI SINAZI COSZEN SINZEN'

   While Not EOF(Lun1) Do Begin
        Readf, Lun1, Data
        Data1 = STRSPLIT(Data ,/EXTRACT)
        Temp_Val = Long(data1[0])
    
        Gps_Time = Temp_Val/1000    ; in seconds.
    
        Zen = Float(data1[6])
        If Zen Gt 180 Then Zen = Zen-360.0
        
        Temp_Text = ''
        Text_Flag = False
        DataFile =''
        Avg_Azi = 0
        If (Gps_Time GE Source_Time[4]) and (Gps_Time LT Source_Time[6]) Then Begin
        
                If (Where(Gps_Time EQ Drew_Array[*,0]) Ne -1) Eq 0 Then Begin

                Endif Else Begin
                      XLocation = where(Gps_Time EQ Drew_Array[*,0])
                      
                      If Drew_Array[Xlocation,2] NE 0 THen Begin
                          Avg_Azi = Drew_Array[Xlocation,1]
                          Text_Flag = True
                          DataFile = 'Drew'
                      Endif
                  
                Endelse
    
        EndIf Else Begin
    
              If  ( (Data1[4] NE '343.64') and (Data1[5] NE '343.64') )Then Begin
                     If  ( (Data1[4] NE '0.00') and (Data1[5] NE '0.00') )Then Begin
                            Avg_Azi= Strn( ( Float(Data1[4]) +Float(Data1[5])     )/2  )
                            Text_Flag = True
                            DataFile ='HRS'
                     EndIf
              Endif
    
        Endelse
        ; The text: GPS Time.. , Avg_Azi, Zen.., Cos Azi, Sin Azi, Cos Zen, Sin Zen.
        Rad_Azi = Avg_Azi*!Const.DtoR
        Rad_Zen = Zen*!Const.DtoR
        
        Temp_Text = STRN(GPS_TIME)+' '+ Strn(Avg_Azi)+' '+Data1[4]+' '+Data1[5]+' '+DataFile+' '+STRN(Zen)+ ' '+STRN(Cos(Rad_Azi))+ ' '+STRN(Sin(Rad_Azi))+' '+STRN(Cos(Rad_Zen))+' '+STRN(Sin(Rad_Zen))
         If Text_Flag Eq True Then  Printf, Txt_Lun, Temp_Text
    
        If a mod 1000 eq 0 then print, a
        a++

  Endwhile
  Free_Lun, Txt_Lun
  Free_Lun, Lun1






End