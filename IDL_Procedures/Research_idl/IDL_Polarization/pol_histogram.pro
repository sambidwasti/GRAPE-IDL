Pro Pol_Histogram, Input_Folder, Time=Time, Flag = Flag, Energy=Energy

  ;NOTE: THe data read in ranges from 1 to 64 rather than 0~63 so care.
  ;The energy file must be in the foler.
  ;Might need to change the flag anodes to an array if more than 1 flagged anodes.
  ;

; For ease of understanding.
  True=1
  False=0
  ; === INITIALIZATION  ===
    
    ; Software Threshold Values.
    Cal_Thresh_Max=400.0
    Cal_Thresh_Min=20.0
    
    Pla_Thresh_Max=200.0
    Pla_Thresh_Min=5.0
    
    ; Dwell time at each Sweep.
    If Keyword_Set(Time) EQ 0 Then Time= 30
    
    ;Flag Anode No. (Right now only 1 anode)
    If Keyword_Set(Flag) EQ 0 Then Flag_Anode= False Else Begin
      Flag_Anode = True
      F_Anode = Flag
    EndElse
    
    ;Need the Peak Energy.(Range is +/- 50)
    If Keyword_Set(Energy) EQ 0 Then Energy_Flag =False Else Begin
      Energy_Flag = True
      Ener= Fix(Energy)
      Ener_Range = 50
    EndElse

    ;=== Grabbing all the files===
    List_of_Files = File_Search(Input_Folder+'/*deg*.txt')
    N_Files = N_Elements(List_of_Files)
    ; END OF INITIALIZATION
     
    ;--- Output Folder and file name selection ---
    T_num = 0 ; Temporary Number Variable
    For k = 0, StrLen(Input_Folder)-5 Do Begin ; For Multiple / included with different folders.
          T_num = StrPos(Input_Folder, '/',k)
          If T_num NE -1 Then Pos = T_num
    EndFor; k
    Output_Folder= StrMid(Input_Folder,0,Pos+1)
    File_Name = StrMid(Input_Folder,Pos+1,Strlen(Input_Folder)-Pos-1)   ; For creation of the Scat file.

    ;===== Grabbing Energy Information =====
    If Energy_Flag Eq True Then Begin
        Energy_Histogram = LonArr(Ener+550)  ; Creating an array for the energy histogram.
        Ener_Files = File_Search(Output_Folder+'/*Energy_Calibration*.txt')
        
        ;--- Check for the Energy File.
        If n_elements(Ener_Files) NE 1 Then BEgin
          Print, ' INVALID: Either no Energy File or Too many of them present '
          return
        EndIF
        
        Energy_Array = FltArr(64,2)     ; Array[0,0]= slope and Array[0,1]= Intercept
        
        ;--- Extract Energy Information. ---
        Openr, Lun1, Ener_Files[0], /Get_Lun
        
        Data1 =''
        Rows_File1 = File_Lines(Ener_Files[0])
        
        For j=0,Rows_File1-1 Do Begin
              Readf, Lun1, Data1
              
              If j Gt 9 Then Begin  ; For skipping comments. we start at 0 so GT 9 for 10 lines to skip.
              
                      Pos = StrPos(Data1,' ',1)
                      p = FIX(StrMid(Data1,0,Pos)) ; Anode
                      
                      Pos1 = StrPos(Data1,'.',Pos)
                      Pos2 = StrPos(Data1,' ',Pos1)
                      M = Float(StrMid(Data1,Pos+1,Pos2-Pos))
      
                      Pos = Pos2
                      Pos1 = StrPos(Data1,'.',Pos)
                      Pos2 = StrPos(Data1,' ',Pos1)
                      
                      Pos = Pos2
                      Pos1 = StrPos(Data1,'.',Pos)
                      Pos2 = StrPos(Data1,' ',Pos1)
                      C = Float(StrMid(Data1,Pos+1,Pos2-Pos))
                      
                      Energy_Array[p,0]= M
                      Energy_Array[p,1]= C
                      
                      
              Endif
        EndFor
        Free_Lun, Lun1
    EndIf ; Energy_Flag
    ;===================Finished Energy Extraction===================

    ;============= Working on Histogram ============
    Main_Histogram = DBLArr(361)
    Avg_Live_Time =0.0
    Live_Time_Count=0L
    Tot_Counts_All=0L
    
    Err_Counter=0
    
        Rates_Plot = FltArr(360,64)
        Tot_Rates_Plot= FltArr(360)
        Compton_Angle = FltArr(181)
    
    ;--- Operating on all files ---
    For i=0, N_Files-1 Do Begin
        Fname = List_of_Files[i]
        
        ;---- Grabbing Sweep/Table Angle ------
        T_num = 0 ; Temporary Number Variable
        
        For k = 0, StrLen(Fname)-5 Do Begin ; For Multiple / included with different folders.
            T_num = StrPos(Fname, '/',k)
            If T_num NE -1 Then Pos = T_num
        EndFor
        Pos1 = StrPos(Fname,'deg',pos)
        
        
        ;Sweep Angle Extraction   ( negative corrects the Theta direction )
        Sweep_Angle= -Float(StrMid(Fname,Pos+1,Pos1-Pos-1))           
        Openr, Lun, Fname, /Get_Lun
        data =''
        If Sweep_Angle EQ 180 Then Goto, Jump_Sweep ; Skipping 180 as it happens twice.
 
 
        ;==============RATES===============
        
        ;---- Rates and Rate Plots---
         Readf, Lun, Data
         Readf, Lun, Data
         
         For k = 0, 15 Do Begin
                Readf, Lun, Data
                
                Temp_Value = LONG((-Sweep_Angle)+180-1) ; Making the sweep -180 0 and going to 360 for the arrray
                                                      ; going to correct this in the plot procedure.
                
                ;---- Extract Chan and Rates ---
                
                ;----- 1st Column -----
                Pos0 = StrPos(Data,'Chan',0)
                Pos1 = StrPos(Data,'='   ,Pos0)
                Temp_Str = Strmid(Data,Pos0+4,2)
                Chan = FIX(Temp_Str)-1
                
                Pos0 =Pos1+1
                Pos1 = StrPos(Data,'c/s'   ,Pos0)
                Temp_Str = Strmid(Data,Pos0,Pos1-Pos0)
                Rate = DOuble(Temp_Str)
                
                Rates_Plot(Temp_Value,Chan)= Rate
                
                ;----  2nd Column ------
                Pos0 = StrPos(Data,'Chan',Pos1)
                Pos1 = StrPos(Data,'='   ,Pos0)
                Temp_Str = Strmid(Data,Pos0+4,2)
                Chan = FIX(Temp_Str)-1
                
                Pos0 =Pos1+1
                Pos1 = StrPos(Data,'c/s'   ,Pos0)
                Temp_Str = Strmid(Data,Pos0,Pos1-Pos0)
                Rate = DOuble(Temp_Str)
                
                Rates_Plot(Temp_Value,Chan)= Rate
                
                ;----- 3rd Column ------
                Pos0 = StrPos(Data,'Chan',Pos1)
                Pos1 = StrPos(Data,'='   ,Pos0)
                Temp_Str = Strmid(Data,Pos0+4,2)
                Chan = FIX(Temp_Str)-1
                
                Pos0 =Pos1+1
                Pos1 = StrPos(Data,'c/s'   ,Pos0)
                Temp_Str = Strmid(Data,Pos0,Pos1-Pos0)
                Rate = DOuble(Temp_Str)
                
                Rates_Plot(Temp_Value,Chan)= Rate
                
                ;---- 4th Column ----------
                Pos0 = StrPos(Data,'Chan',Pos1)
                Pos1 = StrPos(Data,'='   ,Pos0)
                Temp_Str = Strmid(Data,Pos0+4,2)
                ;IF i Gt 221 Then Print, Data
                Chan = FIX(Temp_Str)-1
                
                Pos0 =Pos1+1
                Pos1 = StrPos(Data,'c/s'   ,Pos0)
                Temp_Str = Strmid(Data,Pos0,Pos1-Pos0)
                Rate = DOuble(Temp_Str)
                
                Rates_Plot(Temp_Value,Chan)= Rate
         EndFor
         
         ; Get the valid Rate 
         Readf, Lun, Data
                Pos0 = StrPos(Data,'=',0)+1
                Pos1 = StrPos(Data,'c/s',Pos0)
                Temp_Str =StrMid(Data,Pos0,Pos1-Pos0)
                Tot_Rates_Plot(Temp_Value)= Float(Temp_Str)
         
         ;========== Rates DOne.=======       
        
         Readf, Lun, Data

         ;--- Read the whole file now and extract data---
        While not EOF(Lun) DO Begin
          Readf, Lun, Data
          ; -- Check for PC Data --
          IF Strmid(Data,0,1) NE '#' Then Goto, Jump_Line

          
          ;---- Selecting 2 events for PC ------
          Pos1 = StrPos(Data,' ',0)
          Pos2 = StrPos(Data,' ',Pos1+1)
          Temp_Str = StrMid(Data, Pos1, Pos2-Pos1)
          IF FIx(Temp_Str) NE 2 then Goto, Jump_LIne
          Tot_Counts_All++
          
          ;---- Getting the Live Time ----
          Pos1 = StrPos(Data,' ', Pos2+1)
          Temp_Str = StrMid(Data, Pos2, Pos1-Pos2)
          Live_Time= Float(Temp_Str)

         
          ;---- Getting the Anodes and Pulse  Heights
          Pos2 = StrPos(Data,' ',Pos1+1)

          If (Pos2-Pos1) NE 6 Then Goto, Jump_Line      ; Checking for incorrect data format
          Temp_Str = StrMid(Data, Pos1, Pos2-Pos1)
          Anode1 = Fix(Strmid(Data,Pos1+1, 2))-1
          Pulse1 = Fix(Strmid(Data,Pos1+3, 3))
         
          Pos1 = StrPos(Data,' ', Pos2+1)
          If (Pos1- Pos2) NE 6 then Goto, Jump_Line     ; Checking for incorrect data format
          Temp_Str = StrMid(Data, Pos2, Pos1-Pos2)
          Anode2 = Fix(Strmid(Data,Pos2+1, 2))-1
          Pulse2 = Fix(Strmid(Data,Pos2+3, 3))
          
          Avg_Live_Time= Avg_Live_Time+Live_Time
          Live_Time_Count++
          ;----- For any flagged anodes ---- ( Modify Later )
          If Flag_Anode EQ True Then If (Anode1 Eq F_Anode) or (Anode2 Eq F_Anode) then Goto, Jump_Line

          ;---- Define Primary or Secondary Anode ----
                        If (AnodeType(Anode1+1) EQ 2) or (AnodeType(Anode2+1) Eq 2) Then Begin
                          Print, 'INVALID: Anode out of range:'+Data
                          Return
                        Endif
                        If AnodeType(Anode1+1) EQ 1 Then Begin
                                              Prime_Anode=Anode1 
                                              Prime_Pulse= Pulse1
                        EndIF Else Begin
                                              Prime_Anode=Anode2 
                                              Prime_Pulse= Pulse2
                        EndElse
                                              
                        If AnodeType(Anode1+1) EQ 0 Then Begin
                                               Second_Anode=Anode1
                                               Second_Pulse=Pulse1
                        EndIF Else Begin
                                               Second_Anode=Anode2
                                               Second_Pulse=Pulse2
                        EndElse
          ;--------------------------

          ;----- Selecting Energy Range Before Even starting to transforming ----
          If Energy_Flag Eq True Then Begin
              Ener_Pla = Energy_Array[Prime_Anode,0]*Prime_Pulse+ Energy_Array[Prime_Anode,1]
              Ener_Cal = Energy_Array[Second_Anode,0]*Second_Pulse+ Energy_Array[Second_Anode,1]
              Tot_Ener = Ener_Pla+Ener_Cal

              ;---------------------------- Checking Compton Consistencies ---------------------------------;
              ; E(Final) = E(Initial)/( 1 + E(initial)*(1-cos(theta))/511 )  : Compton Scattering formula   ;
              ; Using Energy We get                                                                         ;
              ; Cos(Theta) = 1 - 511* ( E(initial)/E(final) -1) /E(Initial) )                               ;
              ; For validitym Cos(theta) < |1|                                                              ;
              ;---------------------------------------------------------------------------------------------;

              Temp_Value= 1 - (511.0*( (Tot_Ener/Ener_Cal)-1)/ Tot_Ener)
              If (Temp_Value LT -1) or (Temp_Value GT 1) Then BEgin
                         ; Print, Temp_Value, Ener_Pla, Ener_Cal, Tot_Ener
                          Goto, Jump_Line
              EndIF 
              Theta_Value = Long(!Radeg*ACos(Temp_Value))
              If (Theta_Value LT 45) or (Theta_Value GT 90) Then Goto, Jump_Line
              Compton_Angle[Theta_Value]++
              
              ;----- Software Threshold Implementation ----
              If ((Ener_Pla LT Pla_Thresh_Min) or (Ener_Pla GT Pla_Thresh_Max)) Then Goto, Jump_Line
              If ((Ener_Cal LT Cal_Thresh_Min) or (Ener_Cal GT Cal_Thresh_Max)) Then Goto, Jump_Line
              
              If (Tot_Ener LT Ener+549) then Energy_Histogram[Tot_Ener]++
              If ( Tot_Ener LT (Ener-Ener_Range)) OR (Tot_Ener GT (Ener+Ener_Range))Then Goto,Jump_Line
              
          EndiF

;          ;----- Grab the Co-ordinates. ----
          Pri_Cord = Pol_Tool_Coordinate(Prime_Anode)
          Sec_Cord = Pol_Tool_Coordinate(Second_Anode)
          
          P_X_0 = Pri_Cord[0]       ; Primary X0
          P_Y_0 = Pri_Cord[1]       ; Primary Y0
          
          S_X_0 = Sec_Cord[0]       ; Secondary X0
          S_Y_0 = Sec_Cord[1]       ; Secondary Y0
          ;--- Sweep Angle Modification to correct angle ---
          
           Angle = Sweep_Angle*!PI/180       ; Change to Rad Accordingly
          ;-------------
          ;----- Now Transform the coordinates before getting the angle ----;
          ;      For CCW rotation angle                                     ;
          ;            ( X' ) =  X0*Cos(Ang) - Y0*Sin(Ang)                  ;
          ;            ( Y' ) =  X0*Sin(Ang) + Y0*Cos(Ang)                  ;
          ;-----------------------------------------------------------------;
          P_X = P_X_0*Cos(Angle) - P_Y_0*Sin(Angle)
          P_Y = P_X_0*Sin(Angle) + P_Y_0*Cos(Angle)
          
          S_X = S_X_0*Cos(Angle) - S_Y_0*Sin(Angle)
          S_Y = S_X_0*Sin(Angle) + S_Y_0*Cos(Angle)
          
          Diff_Y= S_Y-P_Y
          Diff_X= S_X-P_X
          
          ;---- Gets angle from -180 to 180 so change the lower half to +ve angle by adding 360
          Lab_Scat_Angle= !Radeg*(Atan(Diff_Y,DIff_X))
          Scat_Angle=Lab_Scat_Angle
          
          If Scat_Angle LT 0.0 Then Scat_Angle=Scat_Angle+360.0
          Main_Histogram[Scat_Angle]++
    ;      Print, -Sweep_Angle,Lab_Scat_Angle, '**', Scat_Angle , Prime_Anode, Second_Anode
          
          Jump_Line:  ; Line to jump if any error occured.
        EndWhile
        
        Free_Lun, LUn
        Jump_Sweep:
        
        Print, Fname ; to keep track of file being worked on.
    EndFor;i
    

     Set_Plot, 'PS'
     loadct, 13                           ; load color
            Device, File = Output_Folder+'Total_Rates_of_'+File_Name, /COLOR,/Landscape
                      Plot, INDGEN(360)-180,Tot_Rates_Plot,Title='Total Rates (Valid) Vs Sweep No.   '+File_Name, $
                               XTitle='Sweep No', YTitle='Rates'$
                              ,Xrange=[-180,180],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0 $
                              ,XTickInterval=20, XMinor=5, Yrange=[0,25], Ystyle=1
   
     Device,/Close
     Set_Plot, 'X'
     
    ; ===== HISTOGRAM CREATED ====
    
    Total_Avg_Live_Time = Float(Double(Avg_Live_Time)/Double(Live_Time_Count))
    Print, Tot_Counts_All
    
    ; ===== Now Need a Text-File of these Histogram ====
    Text_File_Name = File_Name+'_Scat'
    Openw, Lunger, Output_Folder+Text_File_Name+'.txt', /Get_Lun
   
          ;=== Comment 10 lines ===
          Printf, Lunger, ' Files of Histogram for each of the scattering angles. '
          Printf, Lunger, ' Folder Name         ='+File_Name
          Printf, Lunger, ' Average LT          ='+ Strn(Total_Avg_Live_Time)
          Printf, Lunger, ' Time for each Sweep ='+ Strn(Time)
          If Flag_Anode Eq True Then Temp_Str= Strn(F_Anode) Else Temp_Str ='NONE'
          Printf, Lunger, ' Flagged             ='+Temp_Str
          Printf, Lunger, ' Energy              ='+STRN(Ener)
          Printf, Lunger, ' Energy Range        ='+Strn(Ener_Range)
          Printf, Lunger, '/Empty Line'
          Printf, Lunger, '/Empty Line'
          Printf, Lunger, '/Empty Line'
    
          ; Now write the histograms.
          For i = 0,359 Do Begin
            Temp_Str = Strn(i)+'  '+Strn(Main_Histogram[i])
            Printf, Lunger, Temp_Str
          EndFor
          
          
          Printf, Lunger, ''
          Printf, Lunger, ''
          
          ; Now write the Energy
          Print,Strn(N_Elements(Energy_Histogram))
          If Energy_Flag Eq True Then Begin
      
            Printf, Lunger, 'Energy Histogram(Array_Length):'+Strn(N_Elements(Energy_Histogram))
            For i = 0,N_Elements(Energy_Histogram)-1 Do Begin
              Printf, Lunger,Strn(Energy_Histogram[i])
            EndFor
          EndIF
    Free_Lun, Lunger
    
    ;======== Compton Angle Plot ======== 
;    Set_Plot, 'PS'
;     loadct, 13                           ; load color
;            Device, File = Output_Folder+'Compton_Angle_'+File_Name, /COLOR,/Landscape
;                      Plot, INDGEN(361),Compton_Angle,Title='Compton Angle Distribution'+File_Name, $
;                               XTitle='Angle', YTitle='Counts'$
;                              ,Xrange=[0,180],XStyle=1, XGridStyle=1, XTickLen=1.0, YGridStyle=1, YTickLen=1.0 $
;                              ,XTickInterval=20, XMinor=10
;   
;     Device,/Close
;     Set_Plot, 'X'
;===================================================
End