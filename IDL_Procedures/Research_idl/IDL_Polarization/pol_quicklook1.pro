Pro Pol_QuickLook1, Input_File, Bin=Bin
True=1
False=0
; Read a Scat file and Plot the energy and Scattering Plots.
    Bin_Flag =False
    If Keyword_Set(Bin) NE 0 Then Bin_Flag = True Else Bin=1
    
        ;--- Output Folder and file name selection ---
    T_num = 0 ; Temporary Number Variable
    For k = 0, StrLen(Input_File)-5 Do Begin ; For Multiple / included with different folders.
          T_num = StrPos(Input_File, '/',k)
          If T_num NE -1 Then Pos = T_num
    EndFor; k
    Output_Folder= StrMid(Input_File,0,Pos+1)
    File_Name = StrMid(Input_File,Pos+1,Strlen(Input_File)-Pos-1-4)   ; For creation of the Scat file.

    Openr, Lun, Input_File, /Get_Lun
          Data =''
                 
                  Readf, Lun, Data      ; Headline
                  Readf, Lun, Data      ; File name
                  
                  Readf, Lun, Data ; Average LT.
                  Readf, Lun, Data ; Time Ran
                  
                  Readf, Lun, Data ; Flagged Anode
                  Pos0 = StrPos(Data,'=',0)
                  Temp_Str = StrMid(Data,Pos0+1,Strlen(Data)-Pos0)
                  Flag_Anode =Fix(Temp_Str)
                  
                  Readf, Lun, Data ;Energy
                  Readf, Lun, Data ;Energy Range
                  
                  Readf, Lun, Data ;Empty Line
                  Readf, Lun, Data ;Empty Line
                  Readf, Lun, Data ;Empty Line
                  
                  Temp_Scat_Hist = FltArr(360)
                  ; Now the Extraction of Angle information and data.
                  For i = 0, 359 Do Begin
                          Readf, Lun, Data
                          Pos0 = StrPos(Data,' ',0)
                          Temp_Str = StrMid(Data,0,Pos0)
                          Ang = Float(Temp_Str)

                          Pos1 = StrPos(Data,' ',Pos0+1)
                          Temp_Str = StrMid(Data,Pos0,StrLen(Data)-Pos0)
                          Temp_Value= Double(Temp_Str)
                                                   
                          Temp_Scat_Hist[Ang]= Temp_Value
                  EndFor
;                  If Energy_Flag EQ True Then Begin
;                  
;                          Readf, Lun, Data ; Empty
;                          Readf, Lun, Data ; Empty\
;                          Readf, Lun, Data ; Empty
;
;                          ;------- Energy Information --------
;                          Pos0=StrPos(Data,':',0)
;                          Temp_Str = StrMid(Data,Pos0+1,StrLen(Data)-Pos0-1)
;                          Print,Long(Temp_Str)
;                          Temp_Energy_Hist = LonArr(Long(Temp_Str))
;                          For i = 0, Long(Temp_Str)-1 Do Begin
;                                  Readf, Lun, Data
;                                  Temp_Energy_Hist[i]=Long(Data)
;                          EndFor
;                  EndIF
;                  ;---- Get the Background and Source Data Respectively ----
;                  Print, p, ' ',Back_Index,' ',List_of_Files[p]
;                  If p Eq Back_Index Then Begin
;                          Print, p
;                              Back_Scat_Hist = Temp_Scat_Hist
;                          If Energy_Flag Eq True Then    Back_Ener_Hist = Temp_Energy_Hist
;                  EndIf Else Begin
;                              Src_Scat_Hist = Temp_Scat_Hist
;                          If Energy_Flag Eq True Then     Src_Ener_Hist = Temp_Energy_Hist
;                              Src_Index = p
;                  EndElse
;                  
    
    Free_Lun,Lun
    Set_Plot, 'PS'
     loadct, 13                           ; load color
            Device, File = Output_Folder+'Pol_Angle_'+File_Name, /COLOR,/Landscape
                      Plot, INDGEN(361),Temp_Scat_Hist,Title='Pol'+File_Name, $
                               XTitle='Angle', YTitle='Counts'$
                              ,Xrange=[0,360],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0 $
                              ,XTickInterval=20, XMinor=10
   
     Device,/Close
     Set_Plot, 'X'


End