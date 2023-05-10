Pro Grp_Flt_LRdata, File1, File2
; File 1 : lrs data. in the SCC folder. from quicklook? onboard_temp_data.txt
; file 2 : Grp l2v7 flt investigate file.
; Purpose of the program is to interpolate the different values for each temp. and create a file.

CD, Cur = Cur

ReadCol, File1, GPSTime, Mib_T1, Mib_T2, Mib_T3, Mib_T4, Mib_T5, Mib_T6, Mib_T7

ReadCol, File2, GpsTime2, Alt2, Dep, Zen, Azi, Count , CountErr, Format='D,D,D,D,D,D,D'

; Now we want 1 textfile with these PC Counts for the ACRates file. We dont care about the time the collection
; of the data is here.

; Result = Interpol(Y,X, Xinterp)
; Here Y is PCCounts, X is PCCOunts time, Xintrep is ACRates GPSTImes)

; Interpolate Depth
Result = Interpol(Dep, GPSTIme2, GPSTime)

; Interpolate Zen
Result1= InterPol(Zen, GPSTIme2, GPSTime)

; Interpolate PC Count
Result2= InterPol(Count, GPSTIme2, GPSTime)

; Interpolate PC Error
Result3= InterPol(CountErr, GPSTIme2, GPSTime)

openw,Lun2, Cur+'/Temperature_Interp.txt',/Get_Lun
Printf, Lun2, 'GPSTime   MibT1 MibT2 MibT3 MibT4 MibT5 MibT6 MibT7 Dep Zen Count CountErr'

For i = 0,N_Elements(GPSTime)-1 Do Begin
  Printf, Lun2, GpsTime[i], Mib_T1[i], Mib_T2[i], Mib_T3[i], Mib_T4[i], Mib_T5[i], Mib_T6[i], Mib_T7[i], Result[i], Result1[i], Result2[i], Result3[i], $
    format = '(F10.2,1X, F10.2,1X,     F8.2,1X,     F8.2,1X,  F8.2,1X,    F8.2,1X, F8.2,1X,     F8.2,1X, F8.2,1X,    F8.2, 1X,    F8.3   ,  1X,    F8.4)'

Endfor
Free_Lun, Lun2


Stop
End