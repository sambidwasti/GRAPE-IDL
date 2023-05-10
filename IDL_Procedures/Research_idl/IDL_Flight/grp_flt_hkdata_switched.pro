Pro Grp_Flt_HKdata_Switched, File1, File2, Title=Title
  ; File 1 = AC Rates File
  ; This is present in the SCC folder and named ***_ACrates.txt
  ; File 2 is the file from grp l2 invest.
  ; Gets AC in  the PC Times.
  CD, Cur=Cur
  ;Openr, Lun1, File1, /Get_Lun
  ;        Readf, Lun1, data
  ;        While NOT EOF(Lun1) Do BEgin
  ;              Readf, Lun1, data
  ;        Endwhile
  ;
  ;        print, data
  ;Free_Lun, Lun1

  ;AC File
  ReadCol, File1, GpsTime, Alt, Ac1, Ac2, Ac3, Ac4, Ac5, Ac6, TotAc, PC, PCfil,PCovr
  Print, 'ACDONE'
  ; PC Counts file

  ReadCol, File2, GpsTime2, Alt2, Dep, DepErr, Zen, ZenErr, Azi, Count , CountErr, Format='D,D,D,D,D,D'

  If Keyword_Set(Title) EQ 0 then Title = 'Try'
  ; Now we want 1 textfile with these PC Counts for the ACRates file. We dont care about the time the collection
  ; of the data is here.

  ; Result = Interpol(Y,X, Xinterp)
  ; Here Y is PCCounts, X is PCCOunts time, Xintrep is ACRates GPSTImes)
  
  ; ---- WE NEED TO FILTER OUT SOME BAD DATA -----
  Bad_Data_Flag = 0
  
  Temp_time = [0.0D]
  TempAc_1 = [0.0D]
  TempAc_2 = [0.0D]
  TempAc_3 = [0.0D]
  TempAc_4 = [0.0D]
  TempAc_5 = [0.0D]
  TempAc_6 = [0.0D]
  
  For i = 0, N_elements(GPSTime)-1 Do begin
      ;Float starts here
      If GPSTime[i] LT 493944.00 Then Bad_Data_Flag = 1
      
      ; Rough lower limit estimates
      If AC1[i] LT (Avg(AC1)/2.0) Then Bad_Data_Flag = 1
      If AC2[i] LT (Avg(AC2)/2.0) Then Bad_Data_Flag = 1
      If AC3[i] LT (Avg(AC3)/2.0) Then Bad_Data_Flag = 1
      If AC4[i] LT (Avg(AC4)/2.0) Then Bad_Data_Flag = 1
      If AC5[i] LT (Avg(AC5)/2.0) Then Bad_Data_Flag = 1
      If AC6[i] LT (Avg(AC6)/2.0) Then Bad_Data_Flag = 1
      
      ; Lower Limits
      If AC1[i] LT 7500.0 Then Bad_Data_flag = 1
      If AC2[i] LT 13000.00 Then bad_Data_Flag = 1
      If AC3[i] LT 13000.00 Then bad_Data_Flag = 1
      If AC4[i] LT 13000.00 Then bad_Data_Flag = 1
      If AC5[i] LT 9000.00 Then bad_Data_Flag = 1
      If AC6[i] LT 13000.00 Then bad_Data_Flag = 1

      
      ; Now Upper limits
      If AC1[i] GT 10500.0 Then Bad_Data_Flag = 1
      If AC5[i] GT 12000.0 Then Bad_Data_Flag = 1

     ; IF AC2[i] EQ 13265.000 Then Print, i
      ; Few Specific Values
      If (i Eq 1550) or  (i eq 1572) Then Bad_data_Flag = 1 ; For AC2
      
      If Bad_Data_flag Eq 0 Then begin
        Temp_time = [Temp_time, GPSTime[i]]
        TempAc_1 = [TempAc_1, AC1[i]]
        TempAc_2 = [TempAc_2, AC2[i]]
        TempAc_3 = [TempAc_3, AC3[i]]
        TempAc_4 = [TempAc_4, AC4[i]]
        TempAc_5 = [TempAc_5, AC5[i]]
        TempAc_6 = [TempAc_6, AC6[i]]
      Endif
      
      bad_data_flag = 0
  Endfor
   
  GPS_TIME = Temp_time[1:N_Elements(Temp_Time)-1]
  AC_1 = TempAC_1[1:N_Elements(TempAC_1)-1]
  AC_2 = TempAC_2[1:N_Elements(TempAC_2)-1]
  AC_3 = TempAC_3[1:N_Elements(TempAC_3)-1]
  AC_4 = TempAC_4[1:N_Elements(TempAC_4)-1]
  AC_5 = TempAC_5[1:N_Elements(TempAC_5)-1]
  AC_6 = TempAC_6[1:N_Elements(TempAC_6)-1]
  


  Result1 = Interpol(Ac_1, GPS_TIme, GPSTime2)
  print, '..'
  Result2= InterPol(AC_2, GPS_TIme, GPSTime2)
  print, '***'
  Result3= InterPol(Ac_3, GPS_TIme, GPSTime2)
  print, '***'
  Result4= InterPol(AC_4, GPS_TIme, GPSTime2)
  print, '***'
  Result5= InterPol(Ac_5, GPS_TIme, GPSTime2)
  print, '***'
  Result6= InterPol(Ac_6, GPS_TIme, GPSTime2)
  print, '***'
  Result7= InterPol(TotAc, GPSTIme, GPSTime2)
  print, '***'

  openw,Lun3, Cur+'/'+Title+'_AC_Interp_Switched.txt',/Get_Lun
  Printf, Lun3, 'The AC Rates are Accumulated in 5sec intervals'
  Printf, Lun3, 'GPS Time   Alt  Dep Zen  AC1 Ac2 Ac3 Ac4 Ac5 Ac6 TotAc '

  For i = 0,N_Elements(GPSTime2)-1 Do Begin
    Printf, Lun3, GpsTime2[i], Alt2[i]*3.28084, Dep[i], Zen[i], Result1[i], Result2[i],Result3[i], Result4[i],Result5[i], Result6[i], Result7[i],$
      format = '(F10.2,1X, F10.2,1X,F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2, 1X, F8.2)'



  Endfor
  Free_Lun, Lun3


  Stop
End