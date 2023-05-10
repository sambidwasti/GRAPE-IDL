Pro Cal_Tool_Compare, InputFileFolderPath,BIN=BIN, All=All, Scl=Scl, Log= Log
; *************************************************************************
; *         Calibration Tool to Compare different Spectrum Files          *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read the different Spectrum Files and then Plot them        *
; *           in order to Compare.                                        *
; *                                                                       *
; *                                                                       *
; * Usage:                                                                *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *     BIN = Number of Bins for Rebinning. Default is 1024               *
; *           We can only input 512, 256 and 128.                         *
; *     All = Whether to plot all the spectrums in 1 plot or not          *
; *           Defaults to Different Files( 1 for each source )            *
; *     Scl = This scales the Maximum height so that we can see the       *
; *           relative peak w.r.t the rates.                              *
; *     Log = Changes to log-scale
; *                                                                       *
; *     Inputs::                                                          *
; *           InputFileFolderPath: Path of the Folder that contains the   *
; *                   The Input files. Need this parameter to run the     *
; *                   The Program.                                        *
; *                                                                       *
; *     Outputs::                                                         *
; *           All the outputs are in the same folder as the Input Folder  *
; *                                                                       *
; *           A PS file for each anode ran.                               *
; *                                                                       *
; * File Formats:   ASCII TEXT FILES                                      *
; *       Takes in the Spectrum File for each sources.                    *
; *                                                                       *
; * Author: 10/22/13  Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; *                                                                       *
; *                                                                       *
; * NOTE:                                                                 *
; *                                                                       *
; *************************************************************************
; *************************************************************************

  True = 1
  False= 0
         
        ; === Initial Parameters and File Locations:===
        InputFileFolderPath = Rmv_Bk_Slash(InputFileFolderPath)     ; Removes the Back Slash if there are any.
        Search_KeyWord = '*000deg*Spect.txt'                        ; For Flood Spectrum File Selection
        InputFileFolderPath = InputFileFolderPath+'/'
        
        ;== Number of BINS ==
        If Keyword_Set(BIN) EQ 0 Then BIN=1024 Else Begin
              If (1024 mod BIN) NE 0 Then Begin
                       Print, 'ERROR: Please make BIN an integer divisible of 1024'
                       Return
              Endif
              If ( BIN LT 128) Then Begin
                        Print, 'ERROR: Too Small Binsize: Please make it >= 128'
                        Return
              EndIf
        EndElse 
        BIN_Scale = FIX(1024/BIN)
        ;== ALL ==
        If Keyword_Set(All) EQ 0 Then All_Flag = False   Else All_Flag = True
        If Keyword_Set(Scl) EQ 0 Then Scale_Flag = False Else Scale_Flag = True
        If Keyword_Set(Back)EQ 0 Then Back_Flag = False  Else Back_Flag = True
        If Keyword_Set(log) EQ 0 Then Log_Flag = False Else Log_Flag = True
        
;        C0=['Red','Blue','Black','Green','Pink','Orange']
        C0=['Blue','Red','Black','Green','Orange']
        
        ;== Files ==
        FileNames = File_Search( InputFileFolderPath, Search_KeyWord) 
        If( N_elements(FileNames)) EQ 0 Then Begin
                       Print, 'ERROR: NO FILE EXISTS WITH *000deg*Spect*.txt'
                       Return
        EndIf
        NSrc = N_elements(FileNames)          ; Number of Source File( usually at max 2 with Background) 
        
        C = StrArr( NSrc )
        For i= 0,NSrc-1 Do C[i] = C0[i]
        ;== Defining few Variables ==
        Anode_Histogram = LONArr(NSrc,64,1024)            ; The 3D Array of Values for Histogram.
        
        Live_Time = FLTARR(NSRC)  
        Source    = StrArr(NSRC)
        Time_Ran  = LONARR(NSRC) ; in MINS
        Module    = StrArr(NSRC)
        File_Name = StrArr(NSRC)
        
        ;== Read the Text files and grab the Values back to respective arrays::
        For q = 0, NSrc-1 Do Begin
                  Fname = FileNames[q]
                  Temp_Count = 0L
                  Print, Fname
                  Openr, Lun, Fname, /Get_Lun
                  data=''
                  
                  ReadF, Lun, data   ; This is File location
                  Pos = StrPos(Data,':',1)+1
                  Pos1= StrLen(Data)
                  File_Name[q]= Strmid(Data, Pos,Pos1-Pos)
                  
                  ReadF, Lun, data   ; This is Source 
                  Pos = StrPos(Data,':',1)+1
                  Pos1= StrLen(Data)
                  Source[q] = Strmid(Data, Pos,Pos1-Pos)
                  
                  ReadF, Lun, data   ; This is for the Module
                  Pos = StrPos(Data,':',1)+1
                  Pos1= StrLen(Data)
                  Module[q] = Strmid(Data, Pos,Pos1-Pos)
   
                  ReadF, Lun, data   ; This Empty
                  Pos = StrPos(Data,':',1)+1
                  Pos1= StrLen(Data)

                  ReadF, Lun, data   ; This is for the Average Live Time
                  Pos = StrPos(Data,':',1)+1
                  Pos1= StrLen(Data)
                  Live_Time[q] = Float(Strmid(Data, Pos,Pos1-Pos))
                  
                  ReadF, Lun, Data   ; This is for the Total time ran
                  Pos = StrPos(Data,':',1)+1
                  Pos1= StrLen(Data)
                  Time_Ran[q] = Long(Strmid(Data, Pos,Pos1-Pos))
                 
                  ReadF, Lun, Data   ; This is for the Total time ran
                  ReadF, Lun, Data   ; This is for the Total time ran
                  ReadF, Lun, Data   ; This is for the Total time ran
                  ReadF, Lun, Data   ; This is for the Total time ran
                  
                  Temp_Pos = 0
                  ; Now read the histograms 
                  While Not EOF(Lun) DO Begin
                          ReadF, Lun, Data
                          p = Fix(strmid(Data,0,2)); Anode no.
                          For i = 0 , 1023 Do BEgin
                                  Pos = StrPos(Data, ' ', Temp_Pos)
                                  Temp_Pos = StrPos(Data, ' ',Pos+1)
                                  Anode_Histogram[q,p,i] = Float(StrMid(Data,Pos+1,Temp_Pos-Pos-1))
                          EndFor
                  EndWhile
                  Free_Lun, Lun
         Endfor ; End q
         ;=== Now all the values are in the the 3D Array : Anode_Histogram[Source, Anode, PulseHeightCounts] ==              

         ; X Values 
         XFit = Float(INDGEN(BIN)*BIN_Scale)
         Selected_Source= 0
         For p=0,63 Do Begin
                 
                 Scl_Max = max(Anode_Histogram[Selected_Source,p,*]) 
                 ;If All_Flag EQ True Then Y_Max=Scl_Max*10 Else
                  Y_Max=Scl_Max*2
                 ; if Log_Flag Eq True then Y_Max = 5
                 Anode= p
                 IF (AnodeType(p+1) EQ 2) then Goto, Jump2
                       
                 ;====== For Each Source File=====
                 X_MIN_Val= 0L
                 X_MAX_Val= 800L        
                 
                 ;Creating an OverPlot for different sources so
                 Output_Folder_Path = InputFileFolderPath+'/Quick_Compare'
                 If Dir_Exist(Output_Folder_Path) EQ False Then File_MKdir, Output_Folder_Path
                 
                 If All_Flag EQ True Then Output_File= Output_Folder_Path+'/'+'FM104_Quick_Compare_Files_Anode_All_'+STRN(p) Else Output_File= Output_Folder_Path+'/'+'FM104_Quick_Compare_Files_Anode_'+STRN(p)
                 
                 Set_Plot, 'PS'
                 loadct, 13                           ; load color
                 Device, File = Output_File, /COLOR,/Portrait
                 Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
                 
                 If (All_Flag EQ True) and (Log_Flag EQ True) Then Plot, XFIT,INDGEN(1024), PSYM=10,XRANGE=[X_Min_Val,X_Max_Val],XSTYLE=1,YRange=[1,Y_Max],/YLOG,Title= 'Anode = '+STRN(Anode), XTitle='Channel No', YTitle = 'Counts', CharSize= 2,/NODATA
                 
                 If (All_Flag EQ True) and (Log_Flag EQ False) Then Plot, XFIT,INDGEN(1024), PSYM=10,XRANGE=[X_Min_Val,X_Max_Val],XSTYLE=1,YRANGE=[0,Y_Max],YSTYLE=1,Title= 'Anode = '+STRN(Anode), XTitle='Channel No', YTitle = 'Counts', CharSize= 2,/NODATA
                 
                 For q= 0,NSrc-1 Do Begin
                        
                        ; Rescaling the Input values with the Bins.  
                        X_MIN_Ar= FIX(Float(X_Min_Val)/Float(BIN_SCALE))
                        X_MAX_Ar= FIX(Float(X_Max_Val)/Float(BIN_SCALE))
              
                        Temp_Hist     = LonArr(1024) 
                        Hist          = LonArr(BIN)
                        Hist_Err      = DblArr(BIN)
                        Total_Counts  = 0L
                        Temp_Hist_Ct  = 0L
                       
                        For i=0,1023 Do Temp_Hist[i] = Anode_Histogram[q,p,i]
                       
                        For i=0,1023 do Begin
                                  Temp_Val=0L
                                  For j = 0,Bin_Scale-1 Do Begin
                                            Temp_Val= Temp_Val+ Temp_Hist[i+j]
                                  EndFor
                                  Hist[Temp_Hist_Ct] = Temp_Val
                                  Temp_Hist_Ct++
                                  Total_Counts = Total_Counts+Temp_Val
                                  i=i+j-1
                        EndFor
                       
                        ; Now Lets Scale the Histogram if OverPlotting.
                        If (All_Flag Eq True) and ( Scale_Flag Eq True ) then Begin
                                          Temp_Max = Max(Hist)
                                         
                                          Time_Scale_Factor = Float(Float(Time_Ran[selected_source])/Float(Time_Ran[q]))
                                          Live_Time_Factor  = Float(Float(Live_Time[selected_Source])/Float(Live_Time[q]))
                                          
                                          Scale_factor = Time_Scale_Factor*Live_Time_Factor 
                                         
                                          Hist1= Hist
                                          Hist = FIX(Hist1*Scale_factor)
                        EndIF
;                        IF Log_Flag Eq True then Begin
;                                For i = 0,N_elements(Hist)-1 Do If Hist[i] LE 0 then Hist[i]= 0 Else Hist[i] = Alog(Hist[i])
;                        EndIF
                         Temp_Str1= Module[q]
                        Temp_Str2= 'BINS='+STRN(BIN)
                        Temp_Str0= Source[q]
                        If All_Flag Eq True Then Begin
                               
                              OPlot, XFIT,Hist, Color=CgColor(C[q]), PSYM=10
                              XYOUTS,!D.X_Size*0.8,!D.Y_Size*0.97, Temp_Str1, CharSize=2.5,/DEvice
                              XYOUTS,!D.X_Size*0.8,!D.Y_Size*0.03, Temp_Str2, CharSize=2.5,/DEvice
                        EndIF Else BEgin
                              Plot, XFIT,Hist, PSYM=10,XRANGE=[X_Min_Val,X_Max_Val],XSTYLE=1,YRANGE=[0,Y_MAX],YSTYLE=1, Title= 'Anode = '+STRN(Anode), XTitle='Channel No', YTitle = 'Counts', CharSize= 2
                              XYOUTS,!D.X_Size*0.2,!D.Y_Size*0.97, Temp_Str0, CharSize=2.5,/Device
                              XYOUTS,!D.X_Size*0.8,!D.Y_Size*0.97, Temp_Str1, CharSize=2.5,/DEvice
                              XYOUTS,!D.X_Size*0.8,!D.Y_Size*0.03, Temp_Str2, CharSize=2.5,/DEvice
                       EndElse                        
        EndFor ; q
        
                  Device,/Close
                  Set_Plot, 'X'
                 ; Print, Scale_Factor
        Jump2:
      EndFor ; end p
End