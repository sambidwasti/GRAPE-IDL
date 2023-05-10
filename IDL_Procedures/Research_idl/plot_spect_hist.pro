Pro Plot_Spect_Hist, File1, Title=Title, Log=Log, DBE=DBE



Title2 = ' Background Subtracted  '
Temp_Text1 = 'Pla = 12~200kev '
TEmp_Text2 = 'Cal = 30~400kev '
Temp_Text3 = ''
  LogFlag = 0
  Pflag =0
  IF Keyword_Set(Log) NE 0 Then LogFlag=1
  If KeyWord_Set(DBE) NE 0 then PFlag = 1
  IF Keyword_Set(Title) eq 0 Then Title= 'Try'
  CD, Cur = Cur

  ReadCol, File1, Xmin, Xmax, Y, YErr

  X = DblArr(N_Elements(Xmin))
  
  Xerr = DblArr(N_Elements(Xmin))
  HElp, Xmin, Y
  Print, LogFlag
  For i = 0, N_Elements(Xmin)-1 Do begin
    print, i
    X[i] = (Xmin[i]+Xmax[i])/2.0
    Xerr[i] = X[i]-Xmin[i]
    
    If PFlag Eq 1 Then Begin
        Y[i] = Y[i]/(Xmax[i]-Xmin[i])
        YErr[i] = YErr[i]/(Xmax[i]-Xmin[i])
        print, 'yess'
    Endif
  Endfor

  If Pflag Eq 1 Then Y_Title = 'Counts/Sec/Kev' Else Y_Title = 'Counts/Sec'


  CgPs_Open, Title+'_XL_Spect.ps', Font =1, /LandScape
  cgLoadCT, 13

  CgPlot, X, Y, PSYM =3, /XLOG, XRange= [40,400], YRange = [Min(y)-Max(Yerr),max(y)+Max(Yerr)+Min(YErr)],$
          XTitle = 'Energy(Kev)', YTitle=Y_Title, Title='Energy Loss Spectrum of Crab '
          
  CGText, !D.X_Size*0.355, !D.Y_Size*0.985, Title2 , /Device , CharSize=2.5
  
  CGText, !D.X_Size*0.75, !D.Y_Size*0.86, Temp_Text1 , /Device , CharSize=1.5
  CGText, !D.X_Size*0.75, !D.Y_Size*0.82, Temp_Text2 , /Device , CharSize=1.5
  
;  CGText, !D.X_Size*0.355, !D.Y_Size*0.985, Temp_Text3 , /Device , CharSize=2.5

  Print, X, Y, Xerr, Xmin
  OplotError, X, Y,Xerr, Yerr, PSYM =3

  ;-- Close the Device
  CgPs_Close

  ;-- Create the PDF File
  Temp_Str = Cur+'/'+Title+'_XL_Spect.ps'
  CGPS2PDF, Temp_Str,delete_ps=1

  Stop
End