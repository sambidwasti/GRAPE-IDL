Pro Grp_Flt_back_plot, fsearch_String, Title= Title, nfiles=nfiles, Scl_Time=Scl_Time


  ;
  ;      Create Energy plots (lower and upper) to see what the lower/upper limits are
  ;      From L1 version 7 files.
  ;

  IF Keyword_Set(Scl_Time) Eq 0 Then Scl_Time =1

  Altitude = 131.5D
  
  PMax= 1500 ; Max value of energy for energy histogram.
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

    Quality           :0    ,$    ; Quality

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

  Packet_Len = 179L ; In Bytes
  ;==== Struc Defined =======

  Avg_Alt = [0.0D]
  Avg_Zen = [0.0D]
  Avg_Cnt = [0.0D]
  
;  PC_Avg_Alt = [0.0D]
;  PC_Avg_Zen = [0.0D]
;  PC_Avg_Cnt = [0.0D]
;  
  Spec_Cnt = [0.0D]
  Spec_Zen = [0.0D]
  Spec_Tot_Zen = 0.0D
  Spec_Tot_Cnt = 0.0D
  Spec_No_Events = 0L
  Spec_Tot_LT = 0.0D
  
  A=0
  
  Total_Counts = 0.0D
  Total_Altitude = 0.0D
  Total_Zenith   = 0.0D
  Total_LT        =0.0D
  No_Events = 0L
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
        Print, Event_Data[i].Mod_Position, ' ',Event_Data[i].Mod_Serial
      
      No_Anodes = Event_Data[i].No_Anodes
      Time = Event_Data[i].Event_Time
      LiveTime = Event_Data[i].Cor_Live_Time
      
      If( (Event_Data[i].Rotation_Status LT 5) Or (Event_Data[i].Rotation_Status GT 6) )Then Goto, Jump_Packet
;      IF Event_Data[i].rotation_Status NE 6 Then goto, Jump_PAcket
;  If No_Anodes NE 2 Then goto, Jump_Packet
;  IF Event_Data[i].Event_Class NE 3 Then goto, Jump_Packet
      
      Total_Counts = Total_Counts+ No_Anodes
      Total_Altitude = Total_Altitude + Event_Data[i].Altitude
      Zenith = Event_Data[i].Point_Zenith
      Total_LT = Total_LT+LiveTime
      If Zenith GT 60 THen Zenith= Zenith - 360.0D
      Total_Zenith = total_Zenith+Zenith
      
      No_Events++
      
      If ( ((Double(Event_Data[i].Altitude)/1000.0D) GT  Altitude-0.1) and  ((Double(Event_Data[i].Altitude)/1000.0D) LT  Altitude+0.1) ) Then Begin
        Spec_No_Events++
        Spec_Tot_Cnt = Spec_Tot_Cnt+No_Anodes
        Spec_Tot_Zen = Spec_Tot_Zen+Zenith
        Spec_Tot_Lt  = Spec_Tot_Lt+LiveTime
      Endif
      
      
      If A EQ 0 Then Begin
              Old_Time = Time
              Spec_Old_Time = Time
      Endif
      A=1
      
      Time_Diff = Time - Old_Time
      Spec_Time_Diff = Time - Spec_Old_Time
      
      If (Spec_Time_Diff GE Scl_Time) and (Spec_No_Events GE 1)  Then begin
        Temp_LT = Double(Spec_Tot_LT)/Double(Spec_No_Events)
        
        Temp_Cnt = Double(Double(Spec_Tot_Cnt)*Scl_Time/Double(Spec_Time_Diff*Temp_LT))
        Spec_Cnt = [Spec_Cnt,Temp_Cnt]

        Temp_Zen = Double(Spec_Tot_Zen)/Double(Spec_No_Events)
        Spec_Zen = [ Spec_Zen,Temp_Zen ]
        
        Spec_Tot_Cnt = 0L
        Spec_Old_Time = Time
        Spec_No_Events=0L
        Spec_Tot_Zen =0L
        Spec_Tot_LT = 0.0D
      Endif
     

      If Time_Diff GE Scl_Time Then begin
            TEmp_LT = Double(Total_LT)/Double(No_Events)
            
            Temp_Cnt = Double(Double(Total_Counts)*Scl_Time/Double(Time_Diff*Temp_LT))
            Avg_Cnt = [Avg_Cnt,Temp_Cnt]
            
            Temp_Alt = DOuble(Total_Altitude/(No_Events*1000))
            Avg_Alt = [Avg_Alt,Temp_Alt]
            
            Temp_Zen = Double(Total_Zenith)/Double(No_Events)
            Avg_Zen = [ Avg_Zen,Temp_Zen ]

            Total_Counts = 0L
            Total_Altitude = 0L
            Old_Time = Time
            No_Events=0L
            Total_Zenith =0L
            Total_LT =0.0D
      Endif
      
Jump_Packet:
      If i mod 100000 EQ 0 Then print, i
    EndFor; /i

  EndFor; /p
  Avg_Cnt = Avg_Cnt[1:N_Elements(Avg_Cnt)-1]
    Avg_Alt = Avg_Alt[1:N_Elements(Avg_Alt)-1]
      Avg_Zen = Avg_Zen[1:N_Elements(Avg_Zen)-1]
         Spec_Cnt= Spec_Cnt[1:N_Elements(Spec_Cnt)-1]
              Spec_Zen = Spec_Zen[1:N_Elements(Spec_Zen)-1]

;dist1 = Scatterplot3d(Avg_Alt, Avg_Zen, Avg_Cnt, Sym_Object=ORB(), /SYM_Filled, $
;       XTITLE='Altitude', $
;       YTITLE='Zen', $
;       ZTITLE='Total', $
;       TITLE='dafsdfasdfas', $
;       RGB_TABLE=7, AXIS_STYLE=2, SYM_SIZE=1, MAGNITUDE=Avg_Cnt)



  cgPS_Open, Title+'_Plots.ps', Font=1
  cgDisplay, 800, 800
  cgLoadCT, 13

         Str_Title = Title+'_Counts Vs Zenith Angle'
             
         Ymax = Max(Avg_Cnt)*1.2

         ; Counts vs Zenith
         CgScatter2D, Avg_Zen, Avg_Cnt, Fit=0, Xtitle ='Zenith Angle (Deg)',Title=Str_Title,Ytitle='Counts',$
            YRange=[0,Ymax],YStyle=1,AxisColor='Black',SymSize=0.5,$
            Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), PSYM=7,Color='red',/noerase
          
          CgText, !D.X_Size*0.78,!D.Y_Size*0.00, 'Data Collected Per '+STRN(Scl_Time)+'s',/DEVICE, CHarSize=2.0
          
         ;Counts vs Altitude 
          Str_Title = Title+'_Counts Vs Altitude'
         
       
          CgScatter2D, Avg_Alt, Avg_Cnt, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Counts',$
            YRange=[0,Ymax],YStyle=1,AxisColor='Black',SymSize=0.5,Color='RED',$
            Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]),PSYM=7, /noerase
          
      CgErase
          ;Zenith vs altitude
      Str_Title = Title+'_Zenith Vs Altitude'
     
      
      CgScatter2D, Avg_Alt, Avg_Zen, Fit=0, Xtitle ='Altitude (kFt)',Title=Str_Title,Ytitle='Zenith (Deg)',$
              Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), AxisColor='Black',SymSize=0.5,$
              Color='Blue',PSYM=7,/noerase
              
      CgText, !D.X_Size*0.78,!D.Y_Size*0.00, 'Data Collected Per '+STRN(Scl_Time)+'s',/DEVICE, CHarSize=2.0
 
      YMax  = Max(Spec_Cnt)*1.1
      Str_Title = Title+'_Counts vs Zenith'
      
      CgScatter2D, Spec_Zen, Spec_Cnt, Fit=0, Xtitle ='Zenith Angle (Deg)',Title=Str_Title,Ytitle='Counts',$
        Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), AxisColor='Black',SymSize=0.5,$
        Color='Blue',PSYM=7,/noerase, XRange=[36,42],YRange=[0,YMAX],XStyle=1,YStyle=1
        CgText, !D.X_Size*0.78,!D.Y_Size*0.45, 'Altitude =('+STRN(Float(Altitude))+'+/- 0.1)kFt',/DEVICE, CHarSize=2.0
       cgPS_Close

  Temp_Str = Title+'_Plots.ps'
  CGPS2PDF, Temp_Str,delete_ps=1
Stop
;
;  cgPS_Open, Title+'_Upper_Pulse_Hdw.ps', Font=1
;  cgDisplay, 800, 800
;  cgLoadCT, 13
;
;  Plot_Counter = 1
;;  For i = 0, 31 do begin
;;
;;    If (where (i EQ c2014) GE 0) Then Begin
;;
;;      For j = 0, 63 Do Begin
;;
;;        If (where (j EQ pls_anodes) GE 0) Then Begin
;;          Str_Title = 'Module = '+Strn(i)+' Anode = '+Strn(j) + ' Plastic'
;;          Xmax = 1000
;;          Xmin = 0
;;          CgPlot, Indgen(PMAX), EnergyArray[i,j,*], Xtitle ='Chan ',Title=Str_Title,$
;;            XRange=[Xmin,Xmax],XStyle=1, PSYM=10,  YRange=[0,100],YStyle=1, $
;;            Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/NODATA
;;          CgPlot, Indgen(PMAX), EnergyArray[i,j,*], Xtitle ='Chan ',Title=Str_Title,$
;;            XRange=[Xmin,Xmax],XStyle=1, PSYM=10,Color=CgColor('Blue'),  YRange=[0,100],YStyle=1, $
;;            Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/Overplot
;;
;;        Endif Else Begin
;;          Str_Title = 'Module = '+Strn(i)+' Anode = '+Strn(j) + ' Cal'
;;          Xmax = 1000
;;          Xmin = 0
;;          CgPlot, Indgen(PMAX), EnergyArray[i,j,*], Xtitle ='Chan ',Title=Str_Title,$
;;            XRange=[Xmin,Xmax],XStyle=1, PSYM=10,  YRange=[0,400],YStyle=1,$;/XLOG ,
;;            Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/NODATA
;;          CgPlot, Indgen(PMAX), EnergyArray[i,j,*], Xtitle ='Chan ',Title=Str_Title,$YStyle=1,$;/XLOG ,
;;            XRange=[Xmin,Xmax],XStyle=1, PSYM=10,  YRange=[0,400],YStyle=1,Color=CgColor('Red'),$;/XLOG ,
;;            Position= cgLayout([1,2,Plot_Counter], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase,/Overplot
;;        EndElse
;;
;;
;;
;;
;;        If Plot_Counter EQ 1 THen Plot_Counter =2 Else Begin
;;          Plot_Counter = 1
;;          CgErase
;;        EndElse
;;
;;      EndFor
;;    EndIf
;;
;;
;;
;;  EndFor
;  cgPS_Close
;
;  Temp_Str = Title+'_Upper_Pulse_Hdw.ps'
;  CGPS2PDF, Temp_Str,delete_ps=1
;  Stop



End