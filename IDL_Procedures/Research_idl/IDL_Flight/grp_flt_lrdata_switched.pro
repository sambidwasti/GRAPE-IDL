Pro Grp_Flt_LRdata_Switched, File1, File2, Title=Title
  ; File 1 : lrs data. in the SCC folder. from quicklook? onboard_temp_data.txt
  ; file 2 : Grp l2v7 flt investigate file.
  ; Purpose of the program is to interpolate the different values for each temp. and create a file.
  ; Since this is switched, we get interpolated data from AC to PC 
  IF Keyword_Set(title) Eq 0 Then Title='Test'

  CD, Cur = Cur

  ReadCol, File1, GPSTime, Mib_T1, Mib_T2, Mib_T3, Mib_T4, Mib_T5, Mib_T6, Mib_T7, Mib_T8

  ReadCol, File2, GpsTime2, Alt2, Dep, Zen, Azi, Count , CountErr, Format='D,D,D,D,D,D,D'

  ; Now we want 1 textfile with these PC Counts for the ACRates file. We dont care about the time the collection
  ; of the data is here.

  ; Result = Interpol(Y,X, Xinterp)
  ; Here Y is PCCounts, X is PCCOunts time, Xintrep is ACRates GPSTImes)

  ; Interpolate Temp1
  Result1 = Interpol(Mib_T1, GPSTIme, GPSTime2)

  ; Interpolate Temp2
  Result2= InterPol(Mib_T2, GPSTIme, GPSTime2)

  ; Interpolate Temp3
  Result3= InterPol(Mib_T3, GPSTIme, GPSTime2)

  ; Interpolate Temp4
  Result4= InterPol(Mib_T4, GPSTIme, GPSTime2)
  
  ; Interpolate Temp5
  Result5= InterPol(Mib_T5, GPSTIme, GPSTime2)
  
  ; Interpolate Temp6
  Result6= InterPol(Mib_T6, GPSTIme, GPSTime2)
  
  ; Interpolate Temp7
  Result7= InterPol(Mib_T7, GPSTIme, GPSTime2)
  
  ; Interpolate Temp8
  Result8= InterPol(Mib_T8, GPSTIme, GPSTime2)

  openw,Lun2, Cur+'/'+Title+'_Temp_Int_Switch.txt',/Get_Lun
  Printf, Lun2, ' GPSTime   MibT1 MibT2 MibT3 MibT4 MibT5 MibT6 MibT7 MibT8 Dep Zen Count CountErr'

  For i = 0,N_Elements(GPSTime2)-1 Do Begin
    Printf, Lun2, GpsTime2[i], Result1[i], Result2[i], Result3[i], Result4[i], Result5[i], Result6[i], Result7[i], Result8[i], Dep[i], Zen[i], Count[i], CountErr[i], $
      format = '(F10.2,1X, F10.2,1X,     F8.2,1X,     F8.2,1X,  F8.2,1X,    F8.2,1X, F8.2,1X,     F8.2,1X, F8.2,1X,    F8.2, 1X, F8.2, 1X,    F8.3   ,  1X,    F8.4)'

  Endfor
  Free_Lun, Lun2


  Stop

End