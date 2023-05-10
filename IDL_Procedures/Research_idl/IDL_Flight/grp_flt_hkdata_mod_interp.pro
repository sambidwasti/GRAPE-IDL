Pro Grp_Flt_Hkdata_Mod_Interp, File1, File2, Title=Title
 
  ; File 1 : hrs data for each module in the SCC folder. EvtQuicklook file *hkd.txt
  ; file 2 : Grp l2v7 flt investigate file.
  ; Purpose of the program is to interpolate the different values for each temp. and create a file.
  IF Keyword_Set(title) Eq 0 Then Title='Test'

  CD, Cur = Cur

  ReadCol, File1, GPSTime, ModID, ModHV, ModTemp, Trigs, PC, CC, C, PC_AC, CC_AC

  ReadCol, File2, GpsTime2, Alt2, Dep, DepErr, Zen, ZenErr, Azi, Count , CountErr, Format='D,D,D,D,D,D,D,D,D'

  ; Now we want 1 textfile with these . We dont care about the time the collection
  ; of the data is here.

  ; Result = Interpol(Y,X, Xinterp)
  ; Here Y is PCCounts, X is PCCOunts time, Xintrep is ACRates GPSTImes)

  ;-- Temp --
  ;
  ;-- Quad 1 --
  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin

    If (ModID[i] EQ 0) and (ModTemp[i] LT 50)  Then Begin
        
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
    
  Endfor
  Result0 = Tmp[1:N_Elements(Tmp)-1]
  Time0 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 2) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result2 = Tmp[1:N_Elements(Tmp)-1]
  Time2 = Time[1:N_Elements(Time)-1]


  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 3) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result3 = Tmp[1:N_Elements(Tmp)-1]
  Time3 = Time[1:N_Elements(Time)-1]


  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 4) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result4 = Tmp[1:N_Elements(Tmp)-1]
  Time4 = Time[1:N_Elements(Time)-1]
  
  
  
  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 6) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result6 = Tmp[1:N_Elements(Tmp)-1]
  Time6 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 7) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result7 = Tmp[1:N_Elements(Tmp)-1]
  Time7 = Time[1:N_Elements(Time)-1]

  ;Quad -- 2--
  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 9) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result9 = Tmp[1:N_Elements(Tmp)-1]
  Time9 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 10) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result10 = Tmp[1:N_Elements(Tmp)-1]
  Time10 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 11) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result11 = Tmp[1:N_Elements(Tmp)-1]
  Time11 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 12) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result12 = Tmp[1:N_Elements(Tmp)-1]
  Time12 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 13) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result13 = Tmp[1:N_Elements(Tmp)-1]
  Time13 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 14) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result14 = Tmp[1:N_Elements(Tmp)-1]
  Time14 = Time[1:N_Elements(Time)-1]

  ; Quad 3
  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 17) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result17 = Tmp[1:N_Elements(Tmp)-1]
  Time17 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 18) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result18 = Tmp[1:N_Elements(Tmp)-1]
  Time18 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 19) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result19 = Tmp[1:N_Elements(Tmp)-1]
  Time19 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 20) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result20 = Tmp[1:N_Elements(Tmp)-1]
  Time20 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 21) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result21 = Tmp[1:N_Elements(Tmp)-1]
  Time21 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 22) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result22 = Tmp[1:N_Elements(Tmp)-1]
  Time22 = Time[1:N_Elements(Time)-1]

  ; Quad 4

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 24) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result24 = Tmp[1:N_Elements(Tmp)-1]
  Time24 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 25) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result25 = Tmp[1:N_Elements(Tmp)-1]
  Time25 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 27) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result27 = Tmp[1:N_Elements(Tmp)-1]
  Time27 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 28) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result28 = Tmp[1:N_Elements(Tmp)-1]
  Time28 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 29) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result29 = Tmp[1:N_Elements(Tmp)-1]
  Time29 = Time[1:N_Elements(Time)-1]

  Time = [0.0D]
  Tmp  = [0.0D]
  Cntr =0L
  For i =0, N_elements(ModTemp)-1 Do Begin
    If (ModID[i] EQ 31) and (ModTemp[i] LT 50) Then Begin
      Time = [Time,GPSTime[i]]
      Tmp  = [Tmp,ModTemp[i]]
      Cntr++
    EndIf
  Endfor
  Result31 = Tmp[1:N_Elements(Tmp)-1]
  Time31 = Time[1:N_Elements(Time)-1]

;Now Interpolate and Average the temps.

  Res0 = Interpol(Result0, Time0, GPSTime2)
  Res2 = Interpol(Result2, Time2, GPSTime2)
  Res3 = Interpol(Result3, Time3, GPSTime2)
  Res4 = Interpol(Result4, Time4, GPSTime2)
  Res6 = Interpol(Result6, Time6, GPSTime2)
  Res7 = Interpol(Result7, Time7, GPSTime2)
  
  Res9 = Interpol(Result9, Time9, GPSTime2)
  Res10 = Interpol(Result10, Time10, GPSTime2)
  Res11 = Interpol(Result11, Time11, GPSTime2)
  Res12 = Interpol(Result12, Time12, GPSTime2)
  Res13 = Interpol(Result13, Time13, GPSTime2)
  Res14 = Interpol(Result14, Time14, GPSTime2)

  Res17 = Interpol(Result17, Time17, GPSTime2)
  Res18 = Interpol(Result18, Time18, GPSTime2)
  Res19 = Interpol(Result19, Time19, GPSTime2)
  Res20 = Interpol(Result20, Time20, GPSTime2)
  Res21 = Interpol(Result21, Time21, GPSTime2)
  Res22 = Interpol(Result22, Time22, GPSTime2)

  Res24 = Interpol(Result24, Time24, GPSTime2)
  Res25 = Interpol(Result25, Time25, GPSTime2)
  Res27 = Interpol(Result27, Time27, GPSTime2)
  Res28 = Interpol(Result28, Time28, GPSTime2)
  Res29 = Interpol(Result29, Time29, GPSTime2)
  Res31 = Interpol(Result31, Time31, GPSTime2)
  openw,Lun2, Cur+'/'+Title+'_Hkd_Mod_Temp_Interp.txt',/Get_Lun
  Printf, Lun2, 'Temp Time Mod0 Mod2 Mod3 Mod4 Mod6 Mod7 Mod9 Mod10 Mod11 Mod12 Mod13 Mod14 Mod17 Mod18 Mod19 Mod20 Mod21 Mod22 Mod24 Mod25 Mod27 Mod28 Mod29 Mod31'

  For i = 0,N_Elements(GPSTime2)-1 Do Begin
    Printf, Lun2, GPSTime2[i] , Res0[i],  Res2[i],  Res3[i],   Res4[i],  Res6[i],  Res7[i],  Res9[i],  Res10[i],  Res11[i],  Res12[i], Res13[i], Res14[i], $
                                Res17[i], Res18[i], Res19[i],  Res20[i], Res21[i], Res22[i], Res24[i], Res25[i],  Res27[i],  Res28[i], Res29[i], Res31[i],$
      format = '(F10.2,1X,      F8.2,1X,  F8.2,1X,  F8.2,1X,   F8.2,1X,  F8.2,1X,  F8.2,1X,  F8.2,1X,  F8.2,1X,   F8.2,1X,   F8.2,1X,  F8.2,1X,  F8.2,1X, F8.2,1X,  F8.2,1X,  F8.2,1X,   F8.2,1X,  F8.2,1X,  F8.2,1X,  F8.2,1X,  F8.2,1X,   F8.2,1X,   F8.2,1X,  F8.2,1X,   F8.2)'

  Endfor
  Free_Lun, Lun2
  
  Stop
End