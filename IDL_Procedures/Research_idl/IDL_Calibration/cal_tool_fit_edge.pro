Pro Cal_Tool_fit_Edge , Input_File, Ener=Ener
; Fix the Ener part
Ener = 215
Fname = Input_File

Pos0 = StrPos(Fname,'pla_KEV.txt',0)
Pos1 = StrPos(Fname,'_',Pos0-6)

Out_File = Strmid(Fname,0,Pos1)
OName = Out_File+'_'+Strn(Ener)+'_pla_KEV.txt'


     Openr, Lun, Fname, /Get_Lun
     Openw, Lunger, OName, /Get_Lun
     
                  data=''
                  
                  ReadF, Lun, data   ; Reading Line   Headline
                  PrintF,Lunger, data
                  
                  ReadF, Lun, data   ; Reading Line   Raw data File name
                  PrintF,Lunger, data
                  
                  ReadF, Lun, data   ; Reading Line   Module
                  PrintF,Lunger, data
                  
                  ReadF, Lun, data   ; Reading Line   Source
                  PrintF,Lunger, data
                  
                  ReadF, Lun, data   ; Reading Line   Avg Live Time
                  PrintF,Lunger, data
                  
                  ReadF, Lun, data   ; Reading Line   Time Ran
                  PrintF,Lunger, data

                  ReadF, Lun, data   ; Fitting function numbering
                  PrintF,Lunger, data
                  
                  ReadF, Lun, data   ; Fitting Function 0
                  PrintF,Lunger, data
                  
                  ReadF, Lun, data   ; Fitting Function 1
                  PrintF,Lunger, data
                  
                  ReadF, Lun, data   ; Fitting Function 2
                  PrintF,Lunger, data
                  
                  ReadF, Lun, data   ; Fitting Function 3
                  PrintF,Lunger, data
                  
                  ReadF, Lun, data   ; Fitting Function 4
                  PrintF,Lunger, data
                  
                  
                  Readf, Lun, data   ; Empty Line right now.
                  PrintF,Lunger, data
                  
                  
                  ReadF, Lun, data   ; Reading Line Column Label
                  PrintF,Lunger, data
                  
                  ReadF, Lun, Data   ; Reading Line Just a ==== Boundary
                  PrintF,Lunger, data
                  
                  ; Now the actual File Begins.
                  While Not EOF(Lun) DO Begin
                          Temp_String=''
                          ReadF, Lun, Data
                          Pos1=0
                          Pos3=3
                          p = Fix(strmid(Data,0,2)); Anode no.
                          Temp_String =Strn(p)
                          Pos1 = StrPos(Data,' ',1)
                          Pos3 = StrPos(Data, ' ', 4)
                          
                          Temp_String = TEmp_String+ '  9  '+Strn(Ener)
                          
                          Pos1 = StrPos(Data,' ',Pos3)
                          Pos3 = StrPos(Data,' ',Pos1+3)
                          
                          For i = 0 , 6 Do BEgin
                                  Pos = StrPos(Data, '.', Pos3)
                                  Pos1= StrPos(Data, ' ', Pos)
                                  Temp_Value = (StrMid(data,Pos3+2, Pos1-Pos3-2))
                                  
                                  Pos3 = Pos1
                                  If i LT 2 Then  Temp_String  = Temp_String+Temp_Value
                                  If i Eq 2 Then  Temp_Cent    = FLoat(Temp_Value)
                                  If i Eq 3 Then  Temp_Cent_Er = Float(Temp_Value)
                                  If i Eq 4 Then  Temp_SIg     = Float(Temp_Value)
                                  If i Eq 5 Then  Temp_Sig_Er  = Float(Temp_Value)     
                                  If i Eq 6 Then  Temp_String1  = '0.00000'
                          EndFor
                          
                          Value = Temp_Cent+2.355*Temp_Sig/2
                          Value_Err = Sqrt( (Temp_Cent_Er*Temp_Cent_ER) + (Temp_Sig_Er*Temp_Sig_Er) )
                          Temp_String = Temp_String+'   '+Strn(Value)+'       '+Strn(Value_Err)+ '     '+Temp_String1
                          PrintF,Lunger,Temp_String
                   EndWhile
      Free_Lun, Lunger           
      Free_Lun, Lun

End