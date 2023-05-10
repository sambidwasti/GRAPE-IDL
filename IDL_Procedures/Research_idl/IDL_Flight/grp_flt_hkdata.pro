Pro Grp_Flt_HKdata, File1, File2
; File 1 = AC Rates File
; This is present in the SCC folder and named ***_ACrates.txt
; File 2 is the file from grp l2 invest.
; Gets Depth,zen in the AC Times.
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

ReadCol, File2, GpsTime2, Alt2, Dep, Zen, Count , CountErr, Format='D,D,D,D,D,D'

; Now we want 1 textfile with these PC Counts for the ACRates file. We dont care about the time the collection 
; of the data is here. 

; Result = Interpol(Y,X, Xinterp)
; Here Y is PCCounts, X is PCCOunts time, Xintrep is ACRates GPSTImes)

Result = Interpol(Dep, GPSTIme2, GPSTime)
print, '..'
Result1= InterPol(Zen, GPSTIme2, GPSTime)
print, '***'
openw,Lun2, Cur+'/AC_Other_Interp.txt',/Get_Lun
Printf, Lun2, 'GPS Time   Alt    AC1 Ac2 Ac3 Ac4 Ac5 Ac6 TotAc Dep Zen'

      For i = 0,N_Elements(GPSTime)-1 Do Begin
                        Printf, Lun2, GpsTime[i], Alt[i]*3.28084, Ac1[i], Ac2[i], Ac3[i], Ac4[i], Ac5[i], Ac6[i], TotAc[i], Result[i], Result1[i], $
                     format = '(F10.2,1X, F10.2,1X,F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2,1X, F8.2, 1X, F8.2)'

            
            
      Endfor
Free_Lun, Lun2


Stop
End