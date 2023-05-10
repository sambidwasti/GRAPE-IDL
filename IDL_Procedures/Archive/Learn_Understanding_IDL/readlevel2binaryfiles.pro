; Program to Read in the Binary File ( FLight Data )
; Level 2: Version 6 Data Structure.
; NOTE: Was going to use read_binary( dim, data_type) But hard as we do not know the File size.
; Use This as a master File. 
; 
; NOTE: If we are not careful we might misinterpret the array of bytes to array of values so care.
; Sambid Wasti, 5/30/13

Pro Readlevel2BinaryFiles


; ==============** USER DEFINE OR CHANGE VARIABLES **================
  
      NBINS = 20
  
  ;                 File Path and Name
      pathToFile="/Users/sam/Sam_research_main/"                     ; PATH: Location of the Folder and Name in next line
      filename = String('Lv2V06_W38_UT470274_S001.dat')         ; Need to follow this route as in " the 0 has some function and it doesnt take it like a text.    
      file = pathToFile+filename
    
; ==============** ------------------------------- **=================


; Define the Structure
; REFER TO LEVEL2 : Version 6 of Grape Processed Event Doccument for further Explaination of the following Structure
                                                      ;Size ( Bytes)
      Struc = { Target_Source   :0    ,$              ; 2     2
                Sweep_Num       :0    ,$              ; 2     4
                Trun_Jul_Day    :0.0D ,$              ; 8     12  
                Event_Time      :0.0D ,$              ; 8     20
                Scnd_Sweep_Strt :0.0D ,$              ; 8     28
                
                Event_Class     :0B   ,$              ; 1     29
                Event_Type      :0    ,$              ; 2     31
                
                Prm_Mod_Pos     :0    ,$              ; 2     33
                Prm_Anode_Id    :0    ,$              ; 2     35
                Prm_Anode_Ener  :0.0  ,$              ; 4     39
                
                Sec_Mod_Pos     :0    ,$              ; 2     41
                Sec_Anode_Id    :0    ,$              ; 2     43
                Sec_Anode_Ener  :0.0  ,$              ; 4     47
                
                Total_Event_Ener:0.0  ,$              ; 4     51
                Compt_Scat_Angle:0.0  ,$              ; 4     55
                Atm_Depth       :0.0  ,$              ; 4     59
                Target_Airmass  :0.0  ,$              ; 4     63
                
                Pnt_Azimuth     :0.0  ,$              ; 4     67
                Pnt_Zenith      :0.0  ,$              ; 4     71
                Src_Azimuth     :0.0  ,$             ; 4/8     75/79
                Src_Zenith      :0.0  ,$              ; 4/8   79
                
                Target_Off      :0.0  ,$              ; 4/8     83
                Table_Angle     :0.0  ,$              ; 4     87
                Motion_Flag     :0B   ,$              ; 1     88
                Scat_Angle_Inst :0.0  ,$              ; 4/8   92
                Pos_Angle       :0.0  ,$              ; 4/8     96
                Live_Time       :0.0  }               ; 4     100   TOTAL BYTES OF 1 Event =100 Bytes
                
       Packet_Len = 100L ; In Bytes                 This makes ifirst and ilast long format too. Or else we have an overflow error causing negative.
;   ** Binary File Operation
        Openr, lun, file, /GET_Lun     
        Data = read_binary(lun)         ; Putting the file in an array
        Free_Lun, lun
        
        TotPkt = n_elements(Data)/Packet_Len   ; To get this length of an array. 100 is the Total No. OF Bytes in 1 Event.
;        print, 'Total No. Of Events', TotPkt
          
;     Now Create an array for the Struc size.
        Event_data = replicate(Struc, TotPkt) 
                
; ** ================ Lets Read the data into the respective Arrays. ===================
; Notice FIX(_ _) Changes into Int.
; As these are in d 100 Byte Length Each, We want to break those into smaller Packets and then process them.
 
       For i = 0, 300000 Do Begin
              ;**=== Break into smaller Packet.** ===
              ifirst = (i)*Packet_Len              ; first byte for this packet
              ilast  = ifirst+ Packet_Len-1              ; last byte for this packet
              pkt = data[ifirst:ilast]        ; this packet             

;     ** Now For Each Packet we know the position of each Value.        ** Start  Size.(Byte)                                                                              
              Event_data[i].Target_Source    = Fix(pkt, 0)              ;  0    2
              Event_data[i].Sweep_Num        = Fix(pkt, 2)              ;  2    4   
              Event_data[i].Trun_Jul_Day     = Double(pkt, 4)           ;  4    8
              Event_data[i].Event_Time       = Double(pkt, 12)          ; 12    8
              Event_data[i].Scnd_Sweep_Strt  = Double(pkt, 20)          ; 20    8
              
              Event_data[i].Event_Class      = pkt[28]                  ; 28    1
              Event_data[i].Event_Type       = Fix(pkt, 29)             ; 29    2
        
              Event_data[i].Prm_Mod_Pos      = Fix(pkt, 31)             ; 31    2
              Event_data[i].Prm_Anode_Id     = Fix(pkt, 33)             ; 33    2
              Event_data[i].Prm_Anode_Ener   = Float(pkt, 35)           ; 35    4
        
              Event_data[i].Sec_Mod_Pos      = Fix(pkt, 39)             ; 39    2
              Event_data[i].Sec_Anode_Id     = Fix(pkt, 41)             ; 41    2
              Event_data[i].Sec_Anode_Ener   = Float(pkt, 43)           ; 43    4
                
              Event_data[i].Total_Event_Ener = Float(pkt, 47)           ; 47    4
              Event_data[i].Compt_Scat_Angle = Float(pkt, 51)           ; 51    4
              Event_data[i].Atm_Depth        = Float(pkt, 55)           ; 55    4
              Event_data[i].Target_Airmass   = Float(pkt, 59)           ; 59    4
              
              Event_data[i].Pnt_Azimuth      = Float(pkt, 63)           ; 63    4
              Event_data[i].Pnt_Zenith       = Float(pkt, 67)           ; 67    4
              Event_data[i].Src_Azimuth      = Float(pkt, 71)           ; 71    4
              Event_data[i].Src_Zenith       = Float(pkt, 75)           ; 75    4
              
              Event_data[i].Target_Off       = Float(pkt, 79)           ; 79    4
              Event_data[i].Table_Angle      = Float(pkt, 83)           ; 83    4
              Event_data[i].Motion_Flag      = pkt[87]                  ; 87    1
              Event_data[i].Scat_Angle_Inst  = Float(pkt, 88)           ; 88    4
              Event_data[i].Pos_Angle        = Float(pkt, 92)           ; 92    4
              Event_data[i].Live_Time        = Float(pkt, 96)           ; 96    4                      
        EndFor


; **================== Various Checks to Make sure we are getting right Data**


; **==============     PLOTTING     =================**


;for i = 0, 2 DO Begin
;      print, ss_data[i].Target_Source, ss_data[i].Sweep_Num,ss_data[i].Trun_Jul_Day,  ss_data[i].Event_Time,  ss_data[i].Scnd_Sweep_Strt, $
;                ss_data[i].Event_Class,   ss_data[i].Event_Type, ss_data[i].Prm_Mod_Pos,   ss_data[i].Prm_Anode_Id, ss_data[i].Prm_Anode_Ener, ss_data[i].Sec_Mod_Pos, ss_data[i].Sec_Anode_Id, $
;                ss_data[i].Sec_Anode_Ener, ss_data[i].Total_Event_Ener,ss_data[i].Compt_Scat_Angle, ss_data[i].Atm_Depth,  ss_data[i].Target_Airmass,  ss_data[i].Pnt_Azimuth, ss_data[i].Pnt_Zenith, $
;                ss_data[i].Src_Azimuth, ss_data[i].Src_Zenith,ss_data[i].Target_Off,ss_data[i].Table_Angle,  ss_data[i].Motion_Flag, ss_data[i].Scat_Angle_Inst, ss_data[i].Pos_Angle,$
;                ss_data[i].Live_Time
;            print, ' ================= '


End
