Pro Grp_l2v7_pca_File_gen_2, File1, File2,File3,File4, Title=Title

  ; Inherited from Grp_flt_LRData_Switched.
  ;                Grp_Flt_hkdata_switched.
  ;
  ; Using one procedure to get one huge file with all the data.
  ;
  ; File1 = Grp l2v7 pca_File_Gen_1 created.
  ;       = This has Time, ZEn, Depth Info for each sweep.
  ;         (Note if we want a different time interval, this should be modified)
  ; File 2 = lrs Data.. that has onboard temperature (MIB) data.
  ; File 3 = AC Rates data
  ; File 4 = *mod interp output. named *1a. It already is interpreted so just copying the files.
  ; 
  ; Old::::
  ; File 1 : lrs data. in the SCC folder. from quicklook? onboard_temp_data.txt
  ; THe file for the whole flight is copied in the main folder.
  ;
  ; file 2 : Grp l2v7 flt investigate file.
  ; Purpose of the program is to interpolate the different values for each temp. and create a file.
  ; Created this to read and generate respectively the various files.
  ;
  ; 
  ;Note the AC rates are to be averaged by 5. Due to updates. look at thenotes.
  ;
  IF Keyword_Set(title) Eq 0 Then Title='Test'
  Print, File1
  Print, File2
  Print, File3
  CD, Cur = Cur
  ; ReadCol, File1, SwpNo, GpsTime2, Alt2, Dep, Zen, Azi, Count , CountErr, Format='I,D,D,D,D,D,D'
  ReadCol, File1, SwpNo, GpsTime, Alt, Dep, Zen,Azi, Format='I,D,D,D,D,D'

  ReadCol, File2, GPSTime1, Mib_T1, Mib_T2, Mib_T3, Mib_T4, Mib_T5, Mib_T6, Mib_T7, Mib_T8

  ReadCol, File3, GpsTime2, Alt2, Ac1, Ac2, Ac3, Ac4, Ac5, Ac6, TotAc, PC, PCfil,PCovr

  ReadCol, File4, GPSTime3, ModTemp
; Check the number of elements of file 4 with file 1
  Print, N_Elements(GPSTIME3), N_Elements(GPSTIME)
  ; Now we want 1 textfile with these PC Counts for the ACRates file. We dont care about the time the collection
  ; of the data is here.

  ; Result = Interpol(Y,X, Xinterp)
  ; Here Y is PCCounts, X is PCCOunts time, Xintrep is ACRates GPSTImes)

  ; Interpolate Temp1
  Result1 = Interpol(Mib_T1, GPSTIme1, GPSTime)

  ; Interpolate Temp2
  Result2= InterPol(Mib_T2, GPSTIme1, GPSTime)

  ; Interpolate Temp3
  Result3= InterPol(Mib_T3, GPSTIme1, GPSTime)

  ; Interpolate Temp4
  Result4= InterPol(Mib_T4, GPSTIme1, GPSTime)

  ; Interpolate Temp5
  Result5= InterPol(Mib_T5, GPSTIme1, GPSTime)

  ; Interpolate Temp6
  Result6= InterPol(Mib_T6, GPSTIme1, GPSTime)

  ; Interpolate Temp7
  Result7= InterPol(Mib_T7, GPSTIme1, GPSTime)

  ; Interpolate Temp8
  Result8= InterPol(Mib_T8, GPSTIme1, GPSTime)

  ; FILE 3
  ;****************** AC DATA ************************
  ; ---- WE NEED TO FILTER OUT SOME BAD DATA -----
  ; THere were a lot of fluctuations in the AC Data so averaging it out with flags.
  ; Still needs to average over 5s. Need to find that in citation of where is it written.
  Bad_Data_Flag = 0

  Temp_time =[0.0D]
  TempAc_1 = [0.0D]
  TempAc_2 = [0.0D]
  TempAc_3 = [0.0D]
  TempAc_4 = [0.0D]
  TempAc_5 = [0.0D]
  TempAc_6 = [0.0D]

  For i = 0, N_elements(GPSTime2)-1 Do begin
    ;Float starts here
    If GPSTime2[i] LT 493944.00 Then Bad_Data_Flag = 1

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
      Temp_time = [Temp_time, GPSTime2[i]]
      TempAc_1 = [TempAc_1, AC1[i]]
      TempAc_2 = [TempAc_2, AC2[i]]
      TempAc_3 = [TempAc_3, AC3[i]]
      TempAc_4 = [TempAc_4, AC4[i]]
      TempAc_5 = [TempAc_5, AC5[i]]
      TempAc_6 = [TempAc_6, AC6[i]]
    Endif

    bad_data_flag = 0
  Endfor


  GPS_TIME2 = Temp_time[1:N_Elements(Temp_Time)-1]
  AC_1 = TempAC_1[1:N_Elements(TempAC_1)-1]
  AC_2 = TempAC_2[1:N_Elements(TempAC_2)-1]
  AC_3 = TempAC_3[1:N_Elements(TempAC_3)-1]
  AC_4 = TempAC_4[1:N_Elements(TempAC_4)-1]
  AC_5 = TempAC_5[1:N_Elements(TempAC_5)-1]
  AC_6 = TempAC_6[1:N_Elements(TempAC_6)-1]



  ResultAC1= Interpol(Ac_1, GPS_TIme2, GPSTime)
  ResultAC2= InterPol(AC_2, GPS_TIme2, GPSTime)
  ResultAC3= InterPol(Ac_3, GPS_TIme2, GPSTime)
  ResultAC4= InterPol(AC_4, GPS_TIme2, GPSTime)
  ResultAC5= InterPol(Ac_5, GPS_TIme2, GPSTime)
  ResultAC6= InterPol(Ac_6, GPS_TIme2, GPSTime)
  ResultAC7= InterPol(TotAc, GPSTIme2, GPSTime)




  openw,Lun2, Cur+'/'+Title+'_flt_pca_2.txt',/Get_Lun
  Printf, Lun2, 'Sweep GPSTime      MibT1    MibT2    MibT3    MibT4    MibT5    MibT6    MibT7    MibT8     AC1    AC2     AC3      AC4      AC5     AC6      ACTotal     Alt(ft)         Dep     Zen      Azi   ModTemp'

  For i = 0,N_Elements(GPSTime)-1 Do Begin
    Printf, Lun2,SwpNo[i], GpsTime[i], Result1[i], Result2[i], Result3[i], Result4[i], Result5[i], Result6[i], Result7[i], Result8[i]$
      , ResultAC1[i],ResultAC2[i],ResultAC3[i],ResultAC4[i],ResultAC5[i],ResultAC6[i],ResultAC7[i]$
      ,Alt[i], Dep[i], Zen[i],Azi[i], ModTemp[i], $
      format = '(I4,1X,F10.2,1X, F8.2,1X,F8.2,1X,F8.2,1X,F8.2,1X,F8.2,1X, F8.2,1X,F8.2,1X, F8.2,1X,F8.2, 1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X,F12.2 ,1X, F8.2,1X, F8.2,1X, F8.2, 1X, F8.2)'
      ;format   GPSTime,   T1     T2      T3       T4      T5      T6       T7       T8      AC1      AC2       AC3       AC4     AC5       AC6     ACTot     Alt        Dep     Zen    Azi

  Endfor
  Free_Lun, Lun2


  Stop

End