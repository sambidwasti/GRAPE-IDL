pro Pol_QuickEner, Input_Folder
    Files = FIle_search(Input_Folder+'/*Ener_File*.txt')
    For f = 0,N_Elements(files)-1 Do BEgin
        Print, Files[f]
        Openr, Lun, Files[f], /Get_Lun
        Rows_File = File_Lines(Files[f])
        Temp_Hist = LonArr(Rows_FIle)
        
        Data=''
        Readf, Lun, Data
        Readf, Lun, Data
        Readf, Lun, Data
        Pos0 = StrPos(Data,'=',0)
        Temp_Str = StrMid(Data,Pos0+1,Strlen(Data)-Pos0)
        Avg_LT = Float(Temp_Str)
        
        Readf, Lun, Data ; Time Ran
        Pos0 = StrPos(Data,'=',0)
        Temp_Str = StrMid(Data,Pos0+1,Strlen(Data)-Pos0)
        Time_Ran = Long(Temp_Str)*361         
        
        Readf, Lun, Data
        Readf, Lun, Data
        Readf, Lun, Data
        Readf, Lun, Data
        Readf, Lun, Data
        Readf, Lun, Data
        line_Cnt =0L
        While Not EOF(Lun) DO BEgin
                Readf, Lun, Data
                Temp_Data = Long(Data)
                Temp_Hist[Line_Cnt]=Temp_Data
                Line_Cnt++
        EndWhile
        Free_Lun, LUn
        print, Avg_LT
        If StrPos(Files[f],'Back',0) GT 0 Then begin
            Back_Hist = Temp_Hist
            Back_LT  = Avg_LT
            Back_Run = Time_Ran
        EndIF Else Begin
            Src_Hist= Temp_Hist
            Src_LT = Avg_LT
            Src_Run= Time_Ran
        EndElse
    EndFor ;/f
    
    Src_Scl = Double(Src_LT*Src_Run*361.0/255.0)
    Back_Scl= Double(Back_LT*Back_Run*361.0/255.0)
    Scale = Src_Scl/Back_Scl
    Print, Scale
    
                                  Plot, INDGEN(N_ELEMENTS(Src_Hist)), Src_Hist, PSYM=10, Title= 'Energy Histogram Correcting',CharSize=2,$
                                       XTitle='KeV', YTitle='Counts',Xrange=[0,450],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0$
                                       ,XTickInterval=50, XMinor=5
                                  OPLOT,INDGEN(N_ELEMENTS(Src_Hist)), Back_Hist*Scale, PSYM=10, Color=CgColor('red')
                                  OPLOT,INDGEN(N_ELEMENTS(Src_Hist)), Src_Hist-Scale*Back_Hist, PSYM=10
    
    Set_Plot, 'PS'
    loadct, 13                           ; load color
                      Device, File = Input_Folder+'/Energy.ps', /COLOR,/Portrait
                      Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                                  Plot, INDGEN(N_ELEMENTS(Src_Hist)), Src_Hist, PSYM=10, Title= 'Energy Histogram Correcting',CharSize=2,$
                                       XTitle='KeV', YTitle='Counts',Xrange=[0,450],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0$
                                       ,XTickInterval=50, XMinor=5
                                  OPLOT,INDGEN(N_ELEMENTS(Src_Hist)), Back_Hist*Scale, PSYM=10, Color=CgColor('red')
                                  OPLOT,INDGEN(N_ELEMENTS(Src_Hist)), Src_Hist-Scale*Back_Hist, PSYM=10
                      Device,/Close
    Set_Plot, 'X'
    
    
End