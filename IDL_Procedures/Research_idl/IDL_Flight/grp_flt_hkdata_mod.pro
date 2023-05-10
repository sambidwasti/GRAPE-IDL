Pro Grp_Flt_Hkdata_Mod, File1
;, File2
  ; File 1 : hrs data for each module in the SCC folder. EvtQuicklook file *hkd.txt 
  ; file 2 : Grp l2v7 flt investigate file.
  ; Purpose of the program is to interpolate the different values for each temp. and create a file.

  CD, Cur = Cur

  ReadCol, File1, GPSTime, ModID, ModHV, ModTemp, Trigs, PC, CC, C, PC_AC, CC_AC

  ;ReadCol, File2, GpsTime2, Alt2, Dep, Zen, Azi, Count , CountErr, Format='D,D,D,D,D,D,D'

  ; Now we want 1 textfile with these PC Counts for the ACRates file. We dont care about the time the collection
  ; of the data is here.

  ; Result = Interpol(Y,X, Xinterp)
  ; Here Y is PCCounts, X is PCCOunts time, Xintrep is ACRates GPSTImes)

;-- Temp --
;
;-- Quad 1 --
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 0 Then Begin
            Time[Cntr] = GPSTime[i]
            Tmp[Cntr]  = ModTemp[i]
            Cntr++
      EndIf
  Endfor
  Result0 = Tmp
  Time0 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 2 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result2 =  Tmp
  Time2 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 3 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result3 =  Tmp
  Time3 = Time

  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 4 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result4 =  Tmp
  Time4 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 6 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result6 =  Tmp
  Time6 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 7 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result7 =  Tmp
  Time7 = Time

;Quad -- 2-- 
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 9 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result9 = Tmp
  Time9   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 10 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result10 = Tmp
  Time10   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 11 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result11 = Tmp
  Time11   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 12 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result12 = Tmp
  Time12   = Time 

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 13 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result13 = Tmp
  Time13   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 14 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result14 = Tmp
  Time14   = Time
  
  ; Quad 3
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 17 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result17 = Tmp
  Time17   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 18 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result18 = Tmp
  Time18   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 19 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result19 = Tmp
  Time19   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 20 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result20 = Tmp
  Time20   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 21 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result21 = Tmp
  Time21   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 22 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result22 = Tmp
  Time22   = Time

; Quad 4

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 24 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result24 = Tmp
  Time24   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 25 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result25 = Tmp
  Time25   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 27 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result27 = Tmp
  Time27   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 28 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result28 = Tmp
  Time28   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 29 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result29 = Tmp
  Time29   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 31 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result31 = Tmp
  Time31   = Time

  openw,Lun2, Cur+'/Hkd_Mod_Temp.txt',/Get_Lun
  Printf, Lun2, 'Temp Time0 Mod0 Time2 Mod2 Time3 Mod3 Time4 Mod4 Time6 Mod6 Time7 Mod7 Time9 Mod9 Time10 Mod10 Time11 Mod11 Time12 Mod12 Time13 Mod13 Time14 Mod14 Time17 Mod17 Time18 Mod18 Time19 Mod19 Time20 Mod20 Time21 Mod21 Time22 Mod22 Time24 Mod24 Time25 Mod25 Time27 Mod27 Time28 Mod28 Time29 Mod29 Time31 Mod31'

  For i = 0,N_Elements(GPSTime)-1 Do Begin
    Printf, Lun2, Time0[i] , Result0[i],  Time2[i],  Result2[i],  Time3[i],   Result3[i],    Time4[i],   Result4[i],   Time6[i],   Result6[i],  Time7[i],  Result7[i],   Time9[i],  Result9[i],  Time10[i],  Result10[i],  Time11[i],  Result11[i],  Time12[i], Result12[i], Time13[i], Result13[i], Time14[i], Result14[i], $
                  Time17[i], Result17[i], Time18[i], Result18[i], Time19[i],  Result19[i],   Time20[i],  Result20[i],  Time21[i],  Result21[i], Time22[i], Result22[i],  Time24[i], Result24[i], Time25[i],  Result25[i],  Time27[i],  Result27[i],  Time28[i], Result28[i], Time29[i], Result29[i], Time31[i], Result31[i],$
      format = '(F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,  F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,  F8.2)'

  Endfor
  Free_Lun, Lun2
;--- Temp ---

;
;---- HV---
;

;
;;-- To make life easier just changing ModTemp = ModHV should solve everything.
;
ModTemp = ModHV
  ;-- Quad 1 --
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 0 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result0 = Tmp
  Time0 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 2 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result2 =  Tmp
  Time2 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 3 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result3 =  Tmp
  Time3 = Time
  
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 4 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result4 =  Tmp
  Time4 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 6 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result6 =  Tmp
  Time6 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 7 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result7 =  Tmp
  Time7 = Time
  
  ;Quad -- 2--
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 9 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result9 = Tmp
  Time9   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 10 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result10 = Tmp
  Time10   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 11 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result11 = Tmp
  Time11   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 12 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result12 = Tmp
  Time12   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 13 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result13 = Tmp
  Time13   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 14 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result14 = Tmp
  Time14   = Time
  
  ; Quad 3
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 17 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result17 = Tmp
  Time17   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 18 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result18 = Tmp
  Time18   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 19 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result19 = Tmp
  Time19   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 20 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result20 = Tmp
  Time20   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 21 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result21 = Tmp
  Time21   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 22 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result22 = Tmp
  Time22   = Time
  
  ; Quad 4
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 24 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result24 = Tmp
  Time24   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 25 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result25 = Tmp
  Time25   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 27 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result27 = Tmp
  Time27   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 28 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result28 = Tmp
  Time28   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 29 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result29 = Tmp
  Time29   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 31 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result31 = Tmp
  Time31   = Time


  openw,Lun2, Cur+'/Hkd_Mod_HV.txt',/Get_Lun
  Printf, Lun2, 'HV Time0 Mod0 Time2 Mod2 Time3 Mod3 Time4 Mod4 Time6 Mod6 Time7 Mod7 Time9 Mod9 Time10 Mod10 Time11 Mod11 Time12 Mod12 Time13 Mod13 Time14 Mod14 Time17 Mod17 Time18 Mod18 Time19 Mod19 Time20 Mod20 Time21 Mod21 Time22 Mod22 Time24 Mod24 Time25 Mod25 Time27 Mod27 Time28 Mod28 Time29 Mod29 Time31 Mod31'

  For i = 0,N_Elements(GPSTime)-1 Do Begin
    Printf, Lun2, Time0[i] , Result0[i],  Time2[i],  Result2[i],  Time3[i],   Result3[i],    Time4[i],   Result4[i],   Time6[i],   Result6[i],  Time7[i],  Result7[i],   Time9[i],  Result9[i],  Time10[i],  Result10[i],  Time11[i],  Result11[i],  Time12[i], Result12[i], Time13[i], Result13[i], Time14[i], Result14[i], $
                  Time17[i], Result17[i], Time18[i], Result18[i], Time19[i],  Result19[i],   Time20[i],  Result20[i],  Time21[i],  Result21[i], Time22[i], Result22[i],  Time24[i], Result24[i], Time25[i],  Result25[i],  Time27[i],  Result27[i],  Time28[i], Result28[i], Time29[i], Result29[i], Time31[i], Result31[i],$
      format = '(F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,  F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,  F8.2)'

  Endfor
  Free_Lun, Lun2
;--- HV ---


;
;---- Trigs---
;

  ;
  ;;-- To make life easier just changing ModTemp = ModHV should solve everything.
  ;
  ModTemp = Trigs
  ;-- Quad 1 --
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 0 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result0 = Tmp
  Time0 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 2 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result2 =  Tmp
  Time2 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 3 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result3 =  Tmp
  Time3 = Time
  
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 4 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result4 =  Tmp
  Time4 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 6 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result6 =  Tmp
  Time6 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 7 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result7 =  Tmp
  Time7 = Time
  
  ;Quad -- 2--
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 9 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result9 = Tmp
  Time9   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 10 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result10 = Tmp
  Time10   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 11 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result11 = Tmp
  Time11   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 12 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result12 = Tmp
  Time12   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 13 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result13 = Tmp
  Time13   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 14 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result14 = Tmp
  Time14   = Time
  
  ; Quad 3
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 17 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result17 = Tmp
  Time17   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 18 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result18 = Tmp
  Time18   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 19 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result19 = Tmp
  Time19   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 20 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result20 = Tmp
  Time20   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 21 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result21 = Tmp
  Time21   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 22 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result22 = Tmp
  Time22   = Time
  
  ; Quad 4
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 24 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result24 = Tmp
  Time24   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 25 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result25 = Tmp
  Time25   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 27 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result27 = Tmp
  Time27   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 28 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result28 = Tmp
  Time28   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 29 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result29 = Tmp
  Time29   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 31 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result31 = Tmp
  Time31   = Time
  
  
  openw,Lun2, Cur+'/Hkd_Mod_Trigs.txt',/Get_Lun
  Printf, Lun2, 'Trigs Time0 Mod0 Time2 Mod2 Time3 Mod3 Time4 Mod4 Time6 Mod6 Time7 Mod7 Time9 Mod9 Time10 Mod10 Time11 Mod11 Time12 Mod12 Time13 Mod13 Time14 Mod14 Time17 Mod17 Time18 Mod18 Time19 Mod19 Time20 Mod20 Time21 Mod21 Time22 Mod22 Time24 Mod24 Time25 Mod25 Time27 Mod27 Time28 Mod28 Time29 Mod29 Time31 Mod31'
  
  For i = 0,N_Elements(GPSTime)-1 Do Begin
    Printf, Lun2, Time0[i] , Result0[i],  Time2[i],  Result2[i],  Time3[i],   Result3[i],    Time4[i],   Result4[i],   Time6[i],   Result6[i],  Time7[i],  Result7[i],   Time9[i],  Result9[i],  Time10[i],  Result10[i],  Time11[i],  Result11[i],  Time12[i], Result12[i], Time13[i], Result13[i], Time14[i], Result14[i], $
      Time17[i], Result17[i], Time18[i], Result18[i], Time19[i],  Result19[i],   Time20[i],  Result20[i],  Time21[i],  Result21[i], Time22[i], Result22[i],  Time24[i], Result24[i], Time25[i],  Result25[i],  Time27[i],  Result27[i],  Time28[i], Result28[i], Time29[i], Result29[i], Time31[i], Result31[i],$
      format = '(F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,  F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,  F8.2)'
  
  Endfor
  Free_Lun, Lun2
;--- Trigs ---


;
;----PC---
;

    ;
    ;;-- To make life easier just changing ModTemp = ModHV should solve everything.
    ;
    ModTemp = PC
    ;-- Quad 1 --
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr =0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 0 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result0 = Tmp
    Time0 = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr =0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 2 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result2 =  Tmp
    Time2 = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 3 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result3 =  Tmp
    Time3 = Time
    
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 4 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result4 =  Tmp
    Time4 = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr=0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 6 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result6 =  Tmp
    Time6 = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr=0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 7 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result7 =  Tmp
    Time7 = Time
    
    ;Quad -- 2--
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr =0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 9 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result9 = Tmp
    Time9   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr=0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 10 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result10 = Tmp
    Time10   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr=0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 11 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result11 = Tmp
    Time11   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 12 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result12 = Tmp
    Time12   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr =0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 13 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result13 = Tmp
    Time13   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr=0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 14 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result14 = Tmp
    Time14   = Time
    
    ; Quad 3
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 17 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result17 = Tmp
    Time17   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr =0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 18 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result18 = Tmp
    Time18   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 19 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result19 = Tmp
    Time19   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr =0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 20 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result20 = Tmp
    Time20   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr =0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 21 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result21 = Tmp
    Time21   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 22 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result22 = Tmp
    Time22   = Time
    
    ; Quad 4
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 24 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result24 = Tmp
    Time24   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 25 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result25 = Tmp
    Time25   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 27 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result27 = Tmp
    Time27   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 28 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result28 = Tmp
    Time28   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 29 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result29 = Tmp
    Time29   = Time
    
    Time = DblArr(N_elements(GPSTime))
    Tmp  = DblArr(N_Elements(ModTemp))
    Cntr = 0L
    For i =0, N_elements(ModTemp)-1 Do Begin
      If ModID[i] EQ 31 Then Begin
        Time[Cntr] = GPSTime[i]
        Tmp[Cntr]  = ModTemp[i]
        Cntr++
      EndIf
    Endfor
    Result31 = Tmp
    Time31   = Time
    
    
    openw,Lun2, Cur+'/Hkd_Mod_PC.txt',/Get_Lun
    Printf, Lun2, 'PC Time0 Mod0 Time2 Mod2 Time3 Mod3 Time4 Mod4 Time6 Mod6 Time7 Mod7 Time9 Mod9 Time10 Mod10 Time11 Mod11 Time12 Mod12 Time13 Mod13 Time14 Mod14 Time17 Mod17 Time18 Mod18 Time19 Mod19 Time20 Mod20 Time21 Mod21 Time22 Mod22 Time24 Mod24 Time25 Mod25 Time27 Mod27 Time28 Mod28 Time29 Mod29 Time31 Mod31'
    
    For i = 0,N_Elements(GPSTime)-1 Do Begin
      Printf, Lun2, Time0[i] , Result0[i],  Time2[i],  Result2[i],  Time3[i],   Result3[i],    Time4[i],   Result4[i],   Time6[i],   Result6[i],  Time7[i],  Result7[i],   Time9[i],  Result9[i],  Time10[i],  Result10[i],  Time11[i],  Result11[i],  Time12[i], Result12[i], Time13[i], Result13[i], Time14[i], Result14[i], $
        Time17[i], Result17[i], Time18[i], Result18[i], Time19[i],  Result19[i],   Time20[i],  Result20[i],  Time21[i],  Result21[i], Time22[i], Result22[i],  Time24[i], Result24[i], Time25[i],  Result25[i],  Time27[i],  Result27[i],  Time28[i], Result28[i], Time29[i], Result29[i], Time31[i], Result31[i],$
        format = '(F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,  F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,  F8.2)'
    
    Endfor
    Free_Lun, Lun2
;--- PC ---


  ;
  ;----CC---
  ;
  
  ;
  ;;-- To make life easier just changing ModTemp = ModHV should solve everything.
  ;
  ModTemp = CC
  ;-- Quad 1 --
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 0 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result0 = Tmp
  Time0 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 2 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result2 =  Tmp
  Time2 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 3 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result3 =  Tmp
  Time3 = Time
  
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 4 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result4 =  Tmp
  Time4 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 6 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result6 =  Tmp
  Time6 = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 7 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result7 =  Tmp
  Time7 = Time
  
  ;Quad -- 2--
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 9 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result9 = Tmp
  Time9   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 10 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result10 = Tmp
  Time10   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 11 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result11 = Tmp
  Time11   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 12 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result12 = Tmp
  Time12   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 13 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result13 = Tmp
  Time13   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 14 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result14 = Tmp
  Time14   = Time
  
  ; Quad 3
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 17 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result17 = Tmp
  Time17   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 18 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result18 = Tmp
  Time18   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 19 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result19 = Tmp
  Time19   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 20 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result20 = Tmp
  Time20   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 21 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result21 = Tmp
  Time21   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 22 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result22 = Tmp
  Time22   = Time
  
  ; Quad 4
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 24 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result24 = Tmp
  Time24   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 25 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result25 = Tmp
  Time25   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 27 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result27 = Tmp
  Time27   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 28 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result28 = Tmp
  Time28   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 29 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result29 = Tmp
  Time29   = Time
  
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 31 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result31 = Tmp
  Time31   = Time
  
  
  openw,Lun2, Cur+'/Hkd_Mod_CC.txt',/Get_Lun
  Printf, Lun2, 'CC Time0 Mod0 Time2 Mod2 Time3 Mod3 Time4 Mod4 Time6 Mod6 Time7 Mod7 Time9 Mod9 Time10 Mod10 Time11 Mod11 Time12 Mod12 Time13 Mod13 Time14 Mod14 Time17 Mod17 Time18 Mod18 Time19 Mod19 Time20 Mod20 Time21 Mod21 Time22 Mod22 Time24 Mod24 Time25 Mod25 Time27 Mod27 Time28 Mod28 Time29 Mod29 Time31 Mod31'
  
  For i = 0,N_Elements(GPSTime)-1 Do Begin
    Printf, Lun2, Time0[i] , Result0[i],  Time2[i],  Result2[i],  Time3[i],   Result3[i],    Time4[i],   Result4[i],   Time6[i],   Result6[i],  Time7[i],  Result7[i],   Time9[i],  Result9[i],  Time10[i],  Result10[i],  Time11[i],  Result11[i],  Time12[i], Result12[i], Time13[i], Result13[i], Time14[i], Result14[i], $
      Time17[i], Result17[i], Time18[i], Result18[i], Time19[i],  Result19[i],   Time20[i],  Result20[i],  Time21[i],  Result21[i], Time22[i], Result22[i],  Time24[i], Result24[i], Time25[i],  Result25[i],  Time27[i],  Result27[i],  Time28[i], Result28[i], Time29[i], Result29[i], Time31[i], Result31[i],$
      format = '(F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,  F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,  F8.2)'
  
  Endfor
  Free_Lun, Lun2
  ;--- CC ---
  
  ;
  ;----C---
  ;

  ;
  ;;-- To make life easier just changing ModTemp = ModHV should solve everything.
  ;
  ModTemp = C
  ;-- Quad 1 --
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 0 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result0 = Tmp
  Time0 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 2 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result2 =  Tmp
  Time2 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 3 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result3 =  Tmp
  Time3 = Time


  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 4 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result4 =  Tmp
  Time4 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 6 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result6 =  Tmp
  Time6 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 7 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result7 =  Tmp
  Time7 = Time

  ;Quad -- 2--
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 9 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result9 = Tmp
  Time9   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 10 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result10 = Tmp
  Time10   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 11 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result11 = Tmp
  Time11   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 12 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result12 = Tmp
  Time12   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 13 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result13 = Tmp
  Time13   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 14 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result14 = Tmp
  Time14   = Time

  ; Quad 3
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 17 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result17 = Tmp
  Time17   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 18 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result18 = Tmp
  Time18   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 19 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result19 = Tmp
  Time19   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 20 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result20 = Tmp
  Time20   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 21 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result21 = Tmp
  Time21   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 22 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result22 = Tmp
  Time22   = Time

  ; Quad 4

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 24 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result24 = Tmp
  Time24   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 25 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result25 = Tmp
  Time25   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 27 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result27 = Tmp
  Time27   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 28 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result28 = Tmp
  Time28   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 29 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result29 = Tmp
  Time29   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 31 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result31 = Tmp
  Time31   = Time


  openw,Lun2, Cur+'/Hkd_Mod_C.txt',/Get_Lun
  Printf, Lun2, 'C Time0 Mod0 Time2 Mod2 Time3 Mod3 Time4 Mod4 Time6 Mod6 Time7 Mod7 Time9 Mod9 Time10 Mod10 Time11 Mod11 Time12 Mod12 Time13 Mod13 Time14 Mod14 Time17 Mod17 Time18 Mod18 Time19 Mod19 Time20 Mod20 Time21 Mod21 Time22 Mod22 Time24 Mod24 Time25 Mod25 Time27 Mod27 Time28 Mod28 Time29 Mod29 Time31 Mod31'

  For i = 0,N_Elements(GPSTime)-1 Do Begin
    Printf, Lun2, Time0[i] , Result0[i],  Time2[i],  Result2[i],  Time3[i],   Result3[i],    Time4[i],   Result4[i],   Time6[i],   Result6[i],  Time7[i],  Result7[i],   Time9[i],  Result9[i],  Time10[i],  Result10[i],  Time11[i],  Result11[i],  Time12[i], Result12[i], Time13[i], Result13[i], Time14[i], Result14[i], $
      Time17[i], Result17[i], Time18[i], Result18[i], Time19[i],  Result19[i],   Time20[i],  Result20[i],  Time21[i],  Result21[i], Time22[i], Result22[i],  Time24[i], Result24[i], Time25[i],  Result25[i],  Time27[i],  Result27[i],  Time28[i], Result28[i], Time29[i], Result29[i], Time31[i], Result31[i],$
      format = '(F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,  F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,  F8.2)'

  Endfor
  Free_Lun, Lun2
  ;--- C ---
  
  ;
  ;----PC_AC---
  ;

  ;
  ;;-- To make life easier just changing ModTemp = ModHV should solve everything.
  ;
  ModTemp = PC_AC
  ;-- Quad 1 --
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 0 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result0 = Tmp
  Time0 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 2 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result2 =  Tmp
  Time2 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 3 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result3 =  Tmp
  Time3 = Time


  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 4 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result4 =  Tmp
  Time4 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 6 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result6 =  Tmp
  Time6 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 7 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result7 =  Tmp
  Time7 = Time

  ;Quad -- 2--
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 9 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result9 = Tmp
  Time9   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 10 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result10 = Tmp
  Time10   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 11 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result11 = Tmp
  Time11   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 12 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result12 = Tmp
  Time12   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 13 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result13 = Tmp
  Time13   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 14 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result14 = Tmp
  Time14   = Time

  ; Quad 3
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 17 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result17 = Tmp
  Time17   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 18 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result18 = Tmp
  Time18   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 19 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result19 = Tmp
  Time19   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 20 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result20 = Tmp
  Time20   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 21 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result21 = Tmp
  Time21   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 22 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result22 = Tmp
  Time22   = Time

  ; Quad 4

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 24 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result24 = Tmp
  Time24   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 25 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result25 = Tmp
  Time25   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 27 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result27 = Tmp
  Time27   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 28 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result28 = Tmp
  Time28   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 29 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result29 = Tmp
  Time29   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 31 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result31 = Tmp
  Time31   = Time


  openw,Lun2, Cur+'/Hkd_Mod_PC_AC.txt',/Get_Lun
  Printf, Lun2, 'PC_AC Time0 Mod0 Time2 Mod2 Time3 Mod3 Time4 Mod4 Time6 Mod6 Time7 Mod7 Time9 Mod9 Time10 Mod10 Time11 Mod11 Time12 Mod12 Time13 Mod13 Time14 Mod14 Time17 Mod17 Time18 Mod18 Time19 Mod19 Time20 Mod20 Time21 Mod21 Time22 Mod22 Time24 Mod24 Time25 Mod25 Time27 Mod27 Time28 Mod28 Time29 Mod29 Time31 Mod31'

  For i = 0,N_Elements(GPSTime)-1 Do Begin
    Printf, Lun2, Time0[i] , Result0[i],  Time2[i],  Result2[i],  Time3[i],   Result3[i],    Time4[i],   Result4[i],   Time6[i],   Result6[i],  Time7[i],  Result7[i],   Time9[i],  Result9[i],  Time10[i],  Result10[i],  Time11[i],  Result11[i],  Time12[i], Result12[i], Time13[i], Result13[i], Time14[i], Result14[i], $
      Time17[i], Result17[i], Time18[i], Result18[i], Time19[i],  Result19[i],   Time20[i],  Result20[i],  Time21[i],  Result21[i], Time22[i], Result22[i],  Time24[i], Result24[i], Time25[i],  Result25[i],  Time27[i],  Result27[i],  Time28[i], Result28[i], Time29[i], Result29[i], Time31[i], Result31[i],$
      format = '(F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,  F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,  F8.2)'

  Endfor
  Free_Lun, Lun2
  ;--- PC_AC ---
  
  ;
  ;----CC_AC---
  ;

  ;
  ;;-- To make life easier just changing ModTemp = ModHV should solve everything.
  ;
  ModTemp = CC_AC
  ;-- Quad 1 --
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 0 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result0 = Tmp
  Time0 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 2 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result2 =  Tmp
  Time2 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 3 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result3 =  Tmp
  Time3 = Time


  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 4 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result4 =  Tmp
  Time4 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 6 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result6 =  Tmp
  Time6 = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 7 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result7 =  Tmp
  Time7 = Time

  ;Quad -- 2--
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 9 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result9 = Tmp
  Time9   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 10 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result10 = Tmp
  Time10   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 11 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result11 = Tmp
  Time11   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 12 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result12 = Tmp
  Time12   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 13 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result13 = Tmp
  Time13   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr=0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 14 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result14 = Tmp
  Time14   = Time

  ; Quad 3
  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 17 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result17 = Tmp
  Time17   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 18 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result18 = Tmp
  Time18   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 19 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result19 = Tmp
  Time19   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 20 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result20 = Tmp
  Time20   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 21 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result21 = Tmp
  Time21   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 22 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result22 = Tmp
  Time22   = Time

  ; Quad 4

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 24 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result24 = Tmp
  Time24   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 25 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result25 = Tmp
  Time25   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 27 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result27 = Tmp
  Time27   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 28 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result28 = Tmp
  Time28   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 29 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result29 = Tmp
  Time29   = Time

  Time = DblArr(N_elements(GPSTime))
  Tmp  = DblArr(N_Elements(ModTemp))
  Cntr = 0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If ModID[i] EQ 31 Then Begin
      Time[Cntr] = GPSTime[i]
      Tmp[Cntr]  = ModTemp[i]
      Cntr++
    EndIf
  Endfor
  Result31 = Tmp
  Time31   = Time


  openw,Lun2, Cur+'/Hkd_Mod_CC_AC.txt',/Get_Lun
  Printf, Lun2, 'CC_AC Time0 Mod0 Time2 Mod2 Time3 Mod3 Time4 Mod4 Time6 Mod6 Time7 Mod7 Time9 Mod9 Time10 Mod10 Time11 Mod11 Time12 Mod12 Time13 Mod13 Time14 Mod14 Time17 Mod17 Time18 Mod18 Time19 Mod19 Time20 Mod20 Time21 Mod21 Time22 Mod22 Time24 Mod24 Time25 Mod25 Time27 Mod27 Time28 Mod28 Time29 Mod29 Time31 Mod31'

  For i = 0,N_Elements(GPSTime)-1 Do Begin
    Printf, Lun2, Time0[i] , Result0[i],  Time2[i],  Result2[i],  Time3[i],   Result3[i],    Time4[i],   Result4[i],   Time6[i],   Result6[i],  Time7[i],  Result7[i],   Time9[i],  Result9[i],  Time10[i],  Result10[i],  Time11[i],  Result11[i],  Time12[i], Result12[i], Time13[i], Result13[i], Time14[i], Result14[i], $
      Time17[i], Result17[i], Time18[i], Result18[i], Time19[i],  Result19[i],   Time20[i],  Result20[i],  Time21[i],  Result21[i], Time22[i], Result22[i],  Time24[i], Result24[i], Time25[i],  Result25[i],  Time27[i],  Result27[i],  Time28[i], Result28[i], Time29[i], Result29[i], Time31[i], Result31[i],$
      format = '(F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,  F10.2,1X,  F8.2,1X,     F10.2,1X,    F8.2,1X,   F10.2,1X,    F8.2,1X,       F10.2,1X,    F8.2,1X,     F10.2,1X,     F8.2,1X,    F10.2,1X,    F8.2,1X,    F10.2,1X,  F8.2,1X,    F10.2,1X,    F8.2,1X,     F10.2,1X,    F8.2,1X,       F10.2,1X,  F8.2,1X,      F10.2,1X,    F8.2,1X,   F10.2,1X,  F8.2)'

  Endfor
  Free_Lun, Lun2
  ;--- CC_AC ---
Stop
End