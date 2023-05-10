; We want to get my energy file and then taylor's and see the difference in intercept wise with errors. 
Pro Cal_Tool_Taylor_Compare, My_File, Taylor_File, Type = Type
;Read My file
;Read Taylor FIle
;Plot Together
True = 1
False= 0
      
      My_File_Array     = FltArr(64,4)
      Taylor_File_Array = FltArr(64,4)
      
      Openr, Lun, My_File, /Get_Lun
      Data = ''
      
            readf, lun, data
            readf, lun, data
            readf, lun, data
            readf, lun, data
            readf, lun, data
            readf, lun, data
            readf, lun, data
            readf, lun, data
            readf, lun, data
            readf, lun, data
            
            
            While Not EOF(Lun) DO Begin
                  ReadF, Lun, Data
                      If Data NE '' Then BEgin
                           Pos=StrPos(Data,' ',1)
                           p= FIX(Strmid(Data,0,Pos))
                           
                           Pos1 = StrPos(Data,'.',Pos)
                           Pos2 = StrPos(Data,' ',Pos1)
                           Slope= Float(Strmid(Data,Pos+1,Pos2-Pos-1))
                           Pos=Pos2
                           
                           Pos1 = StrPos(Data,'.',Pos)
                           Pos2 = StrPos(Data,' ',Pos1)
                           Slope_err= Float(Strmid(Data,Pos+1,Pos2-Pos-1))
                           Pos=Pos2
                           
                           Pos1 = StrPos(Data,'.',Pos)
                           Pos2 = StrPos(Data,' ',Pos1)
                           Inter= Float(Strmid(Data,Pos+1,Pos2-Pos-1))
                           Pos=Pos2
                           
                           Pos1 = StrPos(Data,'.',Pos)
                           Pos2 = StrPos(Data,' ',Pos1)
                           Inter_Err= Float(Strmid(Data,Pos+1,Pos2-Pos-1))
                           
                      My_File_Array[p,0]= Slope
                      My_File_Array[p,1]= Slope_Err
                      My_File_Array[p,2]= Inter
                      My_File_Array[p,3]= Inter_Err
                      
                      EndIF
            EndWhile
      Free_lun, Lun
      
      Openr, Lunger, Taylor_File, /Get_Lun
      Data = ''
             While Not EOF(Lun) DO Begin
             readf, lunger, data
             
                  If Data NE '' Then BEgin
                           Pos=StrPos(Data,'.',1)
                           Pos1= StrPos(Data,' ',Pos)
                           p= Fix(Strmid(Data,0,Pos1-0))-1
                           Pos=Pos1
                    
                           Pos1 = StrPos(Data,'.',Pos)
                           Pos2 = StrPos(Data,' ',Pos1)
                           Slope= Float(Strmid(Data,Pos+1,Pos2-Pos-1))
                           Pos=Pos2
                      
                           Pos1 = StrPos(Data,'.',Pos)
                           Pos2 = StrPos(Data,' ',Pos1)
                           Inter= Float(Strmid(Data,Pos+1,Pos2-Pos-1))
                           Pos=Pos2
                           
                           Pos1 = StrPos(Data,'.',Pos)
                           Pos2 = StrPos(Data,' ',Pos1)
                           Slope_err= Float(Strmid(Data,Pos+1,Pos2-Pos-1))
                           Pos=Pos2
                 
                           Inter_Err= Float(Strmid(Data,Pos+1,StrLen(Data)-Pos))
                          
                      Taylor_File_Array[p,0]= Slope
                      Taylor_File_Array[p,1]= Slope_Err
                      Taylor_File_Array[p,2]= Inter
                      Taylor_File_Array[p,3]= Inter_Err
                      
                 EndIF
            EndWhile
      Free_Lun,Lunger
      
      T_num = 0 ; Temporary Number Variable
              For k = 0, StrLen(My_File)-5 Do Begin ; For Multiple FM included with different folders.
                    T_num = StrPos(My_File, 'FM',k)
                    If T_num NE -1 Then Pos = T_num
              EndFor              
      Input_Folder = StrMid(My_File,0,Pos)
      Module  = StrMid(My_File, Pos, 5)
      Out_folder = Input_Folder+Module+'_Calibration_Compare/'
      If Dir_Exist(Out_Folder) EQ False Then File_MKdir, Out_Folder
      
      NX=800
      X=INDGEN(NX)
      
      
      For p = 0,63 Do Begin
      
           Y_my = My_File_Array[p,0]*X+My_File_Array[p,2]
           y_my_1= (My_file_Array[p,0]+My_file_Array[p,1])*X+My_File_Array[p,2]+My_File_Array[p,3]
           y_my_2= (My_file_Array[p,0]-My_file_Array[p,1])*X+My_File_Array[p,2]-My_File_Array[p,3]
           
           Y_Tay= Taylor_File_Array[p,0]*X+Taylor_File_Array[p,2]
           y_Tay_1= (taylor_file_Array[p,0]+Taylor_file_Array[p,1])*X+Taylor_File_Array[p,2]+Taylor_File_Array[p,3]
           y_Tay_2= (Taylor_file_Array[p,0]-taylor_file_Array[p,1])*X+Taylor_File_Array[p,2]-Taylor_File_Array[p,3]
           Output_File = Out_Folder+Module+'_Cal_Compare_Old_New_Anode_'+Strn(p)
           
           Temp_Text_4 = 'Y=('+ Strn(My_File_Array[p,0])+ '+/-' + Strn(My_File_Array[p,1]) + ')X +(' +Strn(My_File_Array[p,2])+'+/-'+Strn(My_File_Array[p,3])+')
           Temp_Text_5 = 'Y=('+ Strn(Taylor_File_Array[p,0])+ '+/-' + Strn(Taylor_File_Array[p,1]) + ')X +(' +Strn(Taylor_File_Array[p,2])+'+/-'+Strn(Taylor_File_Array[p,3])+')
           
           Set_Plot, 'PS'
           loadct, 13                           ; load color
                Device, File = Output_File, /COLOR,/Portrait
                Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                           Plot, X, Y_my , XRange=[0,50], XStyle=1, Title = 'Anode ='+Strn(p), XTitle= 'Channel',$
                                                       YTitle= 'Energy',CharSize=2,/NoData, YRange=[0,200], YStyle=1
                           Oplot, X, Y_my,  Color=CgColor('Red'), Thick=2
                           Oplot, X, Y_my_1, Color=CgColor('pink')
                           Oplot, X, Y_my_2, Color=CgColor('pink')
                           
                           OPlot, X, Y_Tay, Color=CgColor('Blue'),Thick=2 
                           Oplot, X, Y_Tay_1, Color=CgColor('Sky Blue')
                           Oplot, X, Y_Tay_2, Color=CgColor('Sky Blue')

                           Temp_Text_1 = 'Old_Calibration'
                           Temp_Text_2 = 'New_Calibration'
                           Temp_Text_3 = Module
                           
                           XYOUTS,!D.X_Size*0.7,!D.Y_Size*0.96, Temp_Text_1, CharSize=2,Color=CgColor('Blue'),/DEvice
                           XYOUTS,!D.X_Size*0.7,!D.Y_Size*0.99, Temp_Text_2, CharSize=2,Color=CgColor('Red'),/DEvice
                           XYOUTS,!D.X_Size*0.2,!D.Y_Size*0.97, Temp_Text_3, CharSize=2.5,/DEvice 
                           
                           ;Equations
                           XYOUTS,!D.X_Size*0.35,!D.Y_Size*(-0.03), Temp_Text_5, CharSize=1.5,Color=CgColor('Blue'),/DEvice
                           XYOUTS,!D.X_Size*0.35,!D.Y_Size*(-0.01), Temp_Text_4, CharSize=1.5,Color=CgColor('Red'),/DEvice
                Device,/Close
            Set_Plot, 'X'
     EndFor       
End