Pro Grp_Hdw_Limit, fsearch_String, Title= Title, nfiles=nfiles, type = type
  
  ;
  ;      Create Energy plots (lower and upper) to see what the lower/upper limits are
  ;      From L1 version 6 files.
  ;
  
  


  EMAX= 3000 ; Max value of energy for energy histogram.
  Cd, Cur=Cur

  IF Keyword_Set(title) Eq 0 Then Title='Test'
  
  
  c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration

  ;
  ;  Calorimeter element anode ids (0..63)
  ;
  Cal_anodes = [0,1,2,3,4,5,6,7,8,15,16,23,24,31,32,39,40,47,48,55,56,57,58,59,60,61,62,63]

  ;
  ;=========================================================================================
  ;
  ;  Plastic element anode Ids (0..63)
  ;
  Pls_anodes = [9,10,11,12,13,14,17,18,19,20,21,22,25,26,27,28,29,30,33,34,35,36,37,38,41, $
    42,43,44,45,46,49,50,51,52,53,54]
    
    
  ;===========
  evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
  if keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)

  ;== Define the Structure.
  Struc = { Version_Number    : 0B  ,$    ; 1 1
    Sweep_Number      : 0   ,$    ; 2 3
    Sweep_Start_Time  : 0.0D,$    ; 8 11
    Swept_Time        : 0.0D,$    ; 8 19
    Event_Time        : 0.0D,$    ; 8 27

    Mod_Position      : 0B  ,$    ; 1 28
    Mod_Serial        : 0B  ,$    ; 1 29

    Event_Class       : 0B  ,$    ; 1 30
    Int_Mod_Flag      : 0B  ,$    ; 1 31
    Anti_Co_Flag      : 0B  ,$    ; 1 32
    No_Anodes         : 0B  ,$    ; 1 33
    No_Pla            : 0B  ,$    ; 1 34
    No_Cal            : 0B  ,$    ; 1 35

    Anode_Id_1        : 0B  ,$    ; 1 36
    Anode_Id_2        : 0B  ,$    ; 1 37
    Anode_Id_3        : 0B  ,$    ; 1 38
    Anode_Id_4        : 0B  ,$    ; 1 39
    Anode_Id_5        : 0B  ,$    ; 1 40
    Anode_Id_6        : 0B  ,$    ; 1 41
    Anode_Id_7        : 0B  ,$    ; 1 42
    Anode_Id_8        : 0B  ,$    ; 1 43

    Anode_Type_1      : 0B  ,$    ; 1 44
    Anode_Type_2      : 0B  ,$    ; 1 45
    Anode_Type_3      : 0B  ,$    ; 1 46
    Anode_Type_4      : 0B  ,$    ; 1 47
    Anode_Type_5      : 0B  ,$    ; 1 48
    Anode_Type_6      : 0B  ,$    ; 1 49
    Anode_Type_7      : 0B  ,$    ; 1 50
    Anode_Type_8      : 0B  ,$    ; 1 51

    Anode_Pha_1       : 0   ,$    ; 2 53
    Anode_Pha_2       : 0   ,$    ; 2 55
    Anode_Pha_3       : 0   ,$    ; 2 57
    Anode_Pha_4       : 0   ,$    ; 2 59
    Anode_Pha_5       : 0   ,$    ; 2 61
    Anode_Pha_6       : 0   ,$    ; 2 63
    Anode_Pha_7       : 0   ,$    ; 2 65
    Anode_Pha_8       : 0   ,$    ; 2 67

    Anode_Energy_1    : 0.0 ,$    ; 4 71
    Anode_Energy_2    : 0.0 ,$    ; 4 75
    Anode_Energy_3    : 0.0 ,$    ; 4 79
    Anode_Energy_4    : 0.0 ,$    ; 4 83
    Anode_Energy_5    : 0.0 ,$    ; 4 87
    Anode_Energy_6    : 0.0 ,$    ; 4 91
    Anode_Energy_7    : 0.0 ,$    ; 4 95
    Anode_Energy_8    : 0.0 ,$    ; 4 99

    Anode_Energy_Err_1: 0.0 ,$    ; 4 103
    Anode_Energy_Err_2: 0.0 ,$    ; 4 107
    Anode_Energy_Err_3: 0.0 ,$    ; 4 111
    Anode_Energy_Err_4: 0.0 ,$    ; 4 115
    Anode_Energy_Err_5: 0.0 ,$    ; 4 119
    Anode_Energy_Err_6: 0.0 ,$    ; 4 123
    Anode_Energy_Err_7: 0.0 ,$    ; 4 127
    Anode_Energy_Err_8: 0.0 ,$    ; 4 131

    Total_Energy      : 0.0 ,$    ; 4 135
    Total_Energy_Err  : 0.0 ,$    ; 4 139

    Latitude          : 0.0 ,$    ; 4 143
    Longitude         : 0.0 ,$    ; 4 147
    Altitude          : 0.0 ,$    ; 4 151
    Depth             : 0.0 ,$    ; 4 155
    Point_Azimuth     : 0.0 ,$    ; 4 159
    Point_Zenith      : 0.0 ,$    ; 4 163

    Rotation_Angle    : 0.0 ,$    ; 4 167
    Rotation_Status   : 0   ,$    ; 2 169
    Live_Time         : 0.0 ,$    ; 4 173
    Cor_Live_Time     : 0.0 }     ; 4 177

  Packet_Len = 177L ; In Bytes
  ;==== Struc Defined =======

  
  ;
  ;--- Define the arrays ---
  ;
 EnergyArray = INTArr(32,64,EMAX)

  For p = 0, nfiles-1 Do Begin ; open each file


    ;
    ;---- Each file
    ;
    fname = evtfiles[p]
    print, fname

    ;
    ;--- Grab some file info
    ;
    f = file_info(fname)

    ;
    ;--- Open the binary file and dump it in Data and Close the file.
    ;
    Openr, lun, fname, /GET_Lun

    ;
    ;--- Grab total no. of packets
    ;
    TotPkt = long(f.size/Packet_Len)

    ;
    ;--- Replicate the structure for each packets.
    ;
    Event_data = replicate(Struc, TotPkt)

    ;
    ;---- Grab all the event data all at once.----
    ;
    For i = 0, TotPkt-1 Do Begin
      readu, lun, Struc        ; read one event
      Event_data[i] =Struc        ; add it to input array
    EndFor

    ;
    ;--- Free Lun ----
    ;
    Free_Lun, lun

    For i = 0, TotPkt-1 Do Begin
        Nanodes = Event_Data[i].No_Anodes
        ModuleNo= Event_Data[i].Mod_Position
  ;         If NAnodes GE 2 Then goto, Jump_Packet     
        ; 1st anode
        
        Anode = Event_Data[i].Anode_ID_1
        Energy= LONG(Event_Data[i].Anode_Energy_1)
        
        If Energy LT EMAX Then EnergyArray[ModuleNo, ANode, Energy]++
        
        If NAnodes LT 2 Then goto, Jump_Packet
        
        ; 2nd anode

        Anode = Event_Data[i].Anode_ID_2
        Energy= LONG(Event_Data[i].Anode_Energy_2)

        If Energy LT EMAX Then EnergyArray[ModuleNo, ANode, Energy]++

        If NAnodes LT 3 Then goto, Jump_Packet
        
        ; 3rd anode

        Anode = Event_Data[i].Anode_ID_3
        Energy= LONG(Event_Data[i].Anode_Energy_3)

        If Energy LT EMAX Then EnergyArray[ModuleNo, ANode, Energy]++

        If NAnodes LT 4 Then goto, Jump_Packet
        
        ; 4th anode

        Anode = Event_Data[i].Anode_ID_4
        Energy= LONG(Event_Data[i].Anode_Energy_4)

        If Energy LT EMAX Then EnergyArray[ModuleNo, ANode, Energy]++

        If NAnodes LT 5 Then goto, Jump_Packet
        
        ; 5th anode

        Anode = Event_Data[i].Anode_ID_5
        Energy= LONG(Event_Data[i].Anode_Energy_5)

        If Energy LT EMAX Then EnergyArray[ModuleNo, ANode, Energy]++

        If NAnodes LT 6 Then goto, Jump_Packet
        
        ; 6th anode

        Anode = Event_Data[i].Anode_ID_6
        Energy= LONG(Event_Data[i].Anode_Energy_6)

        If Energy LT EMAX Then EnergyArray[ModuleNo, ANode, Energy]++

        If NAnodes LT 7 Then goto, Jump_Packet
        
        ; 7th anode

        Anode = Event_Data[i].Anode_ID_7
        Energy= LONG(Event_Data[i].Anode_Energy_7)

        If Energy LT EMAX Then EnergyArray[ModuleNo, ANode, Energy]++

        If NAnodes LT 8 Then goto, Jump_Packet
        
        ; 8th anode

        Anode = Event_Data[i].Anode_ID_8
        Energy= LONG(Event_Data[i].Anode_Energy_8)

        If Energy LT EMAX Then EnergyArray[ModuleNo, ANode, Energy]++
        
        
        Jump_Packet:
    If i mod 100000 EQ 0 Then print, i
    EndFor; /i

  EndFor; /p
  

 
  cgPS_Open, Title+'_Lower_Hdw.ps', Font=1
  cgDisplay, 800, 800
  cgLoadCT, 13

  Plot_Counter = 1
  For i = 0, 31 do begin
      
      If (where (i EQ c2014) GE 0) Then Begin
       
            For j = 0, 63 Do Begin
              
                If (where (j EQ pls_anodes) GE 0) Then Begin
                        Str_Title = 'Module = '+Strn(i)+' Anode = '+Strn(j) + ' Plastic'
                        Xmax = 50
                        Ymax = Max(EnergyArray[i,j,*])*1.2
                        
                        CgPlot, Indgen(EMAX), EnergyArray[i,j,*], Xtitle ='Energy (kEv) ',Title=Str_Title,$
                          XRange=[0,Xmax],XStyle=1, PSYM=10, YRange=[0,Ymax],YStyle=1,$
                          Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/NoData
                          
                          CgPlot, Indgen(EMAX), EnergyArray[i,j,*], Xtitle ='Energy (kEv) ',Title=Str_Title,$
                          XRange=[0,Xmax],XStyle=1, PSYM=10, YRange=[0,Ymax],YStyle=1,Color=CgColor('Blue'),$
                          Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/Overplot
                          
                          
                Endif Else Begin
                        Str_Title = 'Module = '+Strn(i)+' Anode = '+Strn(j) + ' Cal'
                        Xmax = 150
                        ;Xmax = 500
                        YMax = Max(EnergyArray[i,j,*])*1.2
                        
                        CgPlot, Indgen(EMAX), EnergyArray[i,j,*], Xtitle ='Energy (kEv) ',Title=Str_Title,$
                          XRange=[0,Xmax],XStyle=1,Xtickinterval=10, PSYM=10, YRange=[0,Ymax],YStyle=1,$
                          Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/NoData
                          
                          CgPlot, Indgen(EMAX), EnergyArray[i,j,*], Xtitle ='Energy (kEv) ',Title=Str_Title,$
                          XRange=[0,Xmax],XStyle=1,Xtickinterval=10, PSYM=10, YRange=[0,Ymax],YStyle=1,Color=CgColor('red'),$
                          Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/Overplot
                EndElse 
             
            

              
                If Plot_Counter EQ 1 THen Plot_Counter =2 Else Begin
                        Plot_Counter = 1
                        CgErase
                EndElse
                
            EndFor
      EndIf
  EndFor
  cgPS_Close

  Temp_Str = Title+'_Lower_Hdw.ps'
  CGPS2PDF, Temp_Str,delete_ps=1
  
  
  cgPS_Open, Title+'_Upper_Hdw.ps', Font=1
  cgDisplay, 800, 800
  cgLoadCT, 13

  Plot_Counter = 1
  For i = 0, 31 do begin

    If (where (i EQ c2014) GE 0) Then Begin

      For j = 0, 63 Do Begin

        If (where (j EQ pls_anodes) GE 0) Then Begin
            Str_Title = 'Module = '+Strn(i)+' Anode = '+Strn(j) + ' Plastic'
            Xmax = 500
            Xmin = 50
      
            CgPlot, Indgen(EMAX), EnergyArray[i,j,*], Xtitle ='Energy (kEv) ',Title=Str_Title,$
              XRange=[Xmin,Xmax],XStyle=1, PSYM=10, $
              Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/NODATA
            CgPlot, Indgen(EMAX), EnergyArray[i,j,*], Xtitle ='Energy (kEv) ',Title=Str_Title,$
              XRange=[Xmin,Xmax],XStyle=1, PSYM=10,Color=CgColor('Blue'), $
              Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/Overplot
  
        Endif Else Begin
            Str_Title = 'Module = '+Strn(i)+' Anode = '+Strn(j) + ' Cal'
;            Xmax = 2500
;            Xmin = 600
             Xmax = 1500
             Xmin = 200
            CgPlot, Indgen(EMAX), EnergyArray[i,j,*], Xtitle ='Energy (kEv) ',Title=Str_Title,$
              XRange=[Xmin,Xmax],XStyle=1, PSYM=10,$;/XLOG , 
              Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/NODATA
             CgPlot, Indgen(EMAX), EnergyArray[i,j,*], Xtitle ='Energy (kEv) ',Title=Str_Title,$
              XRange=[Xmin,Xmax],XStyle=1, PSYM=10,Color=CgColor('red'), $;/XLOG ,
              Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/Overplot 
        EndElse




        If Plot_Counter EQ 1 THen Plot_Counter =2 Else Begin
          Plot_Counter = 1
          CgErase
        EndElse

      EndFor
    EndIf



  EndFor
  cgPS_Close

  Temp_Str = Title+'_Upper_Hdw.ps'
  CGPS2PDF, Temp_Str,delete_ps=1
  Stop



End