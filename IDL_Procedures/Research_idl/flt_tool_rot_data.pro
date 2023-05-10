Pro Flt_Tool_Rot_data, HRs_File

;
;Read in Hrs File and get the necessary format.
;

;
;-- Few Assumptions and exceptions in creating this file.
;-- We start with 2nd sweep of the flight since first sweep is 0bytes
;-- We use the status 4: ( waiting ) as a way to start the next sweep.
;-- Note its the next line that is the start of the sweep.
;-- Exception for this is sweep 44 which has the the status 7.
;


    True = 1
    False =0
    cd, Cur=Cur
    
    Openw,Lun1, Cur+'/Rot_Data.txt', /Get_Lun
    Printf, Lun1, 'rt_time rt_gpstime rt_swtime rt_sweep rt_status rt_step rt_angle'
    
    Data =''
    openr, Lun, Hrs_File, /Get_Lun
    Readf, Lun, Data
    Readf, Lun, Data
    Readf, Lun, Data
    Readf, Lun, Data
    
    Sweep_No = 2    ; Since we start at 2
    Sweep_Start_Time = 477466L
    Sweep_Flag = False
    While Not EOF(Lun) Do Begin
          Readf, Lun, Data
          Data1 = STRSPLIT(Data ,/EXTRACT)
          GPS_Time = Long(Data1[0])/1000
          
          If Sweep_Flag Eq True then begin
            Sweep_No++
            Sweep_Start_Time = GPS_Time
            Sweep_Flag = False
          Endif
 
          If GPS_Time GE 477466 Then Begin
            rt_status = Long(Data1[3])
            
            If (Rt_Status Eq 4) Or (Rt_Status Eq 0) Then Sweep_Flag = True
            
            If(Rt_Status Eq 4) Or (Rt_Status Eq 0) Then Print, Data
            ;Exception
            If GPS_Time EQ 510056 Then Begin
                  Sweep_No = 45
                  Sweep_Start_Time = GPS_TIme
            Endif
            rt_time = GPS_Time-477466
            rt_swtime = GPS_Time-Sweep_Start_Time
            rt_sweep = Sweep_No
            rt_step = Long(Data1[2])
            rt_angle = Long(Data1[1])
            
            
            Txt = STRN(rt_Time)+' '+ STRN(GPS_Time)+' '+ Strn(rt_swtime)+' '+ Strn(rt_sweep)+ ' '+Strn(rt_Status)+' '+Strn(Rt_step)+' '+Strn(Rt_Angle)
            Printf, Lun1, Txt
         

           
          Endif
          
          
    EndWhile

    Free_Lun, Lun
    Free_Lun, Lun1


End