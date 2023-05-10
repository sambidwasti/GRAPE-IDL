
Pro Flt_L1_quicklook 
; IITS OUTDATED PROGRAM> ONLY USE FOR REFERENCES>
; *************************************************************************
; *  Read and Do a Quick Look Plots or various Things with L1 Version 4/5 *
; *************************************************************************
; *  Purpose: To Check or to perform easy Test/Plots in order to check the*
; *           Validity of the Level or version.                           *
; *                                                                       * 
; *  Usage: Just a QuickLook program so everything is inputed in the      *
; *         Program. If program is going to be a major one then i will    *
; *         make the necessary changes and the respective documentation on*
; *         the program.                                                  *
; *                                                                       *
; * Author: 6/23/13   Sambid Wasti                                        *
; *                                                                       *
; * Revision History:                                                     *
; *                                                                       *
; *************************************************************************
; *************************************************************************         
          ; Sweep NO.
          SweepNo=[11,15,20,25,40,45,50,52,55,58,60,65,66,68,70,77,75,80,88,89,90,96,22,49,51]
          Filestartname='/Users/sam/Sam_Docs/L1Data_v05/Sweeps/Lv1V05_Sweep_'
          Fileendname ='.dat'
          
          ; Run for the Sweep No. in the Array.
              For p = 0, n_elements(SweepNo)-1 Do Begin
              Filename = FileStartname+STRN(SweepNo[p])+Fileendname
              OutputFileName = '/Users/sam/Public/MISC/L1_Check/L1V05_Sweep_'+STRN(SweepNo[p])
              Title_of_page = ' LV 1 PLOTS FOR SWEEP =' +STRN(SweepNo[p])
                    ;Structure Define
                    Struc = { Event_Time      :0.0D ,$              ; 8     8
                              Mod_Pos         :0B   ,$              ; 1     9
                              Mod_Ser_No      :0    ,$              ; 2     11
                              Event_Class     :0B   ,$              ; 1     12
                              Int_Mod_Flag    :0B   ,$              ; 1     13
                              No_Anodes       :0B   ,$              ; 1     14
                              
                              Anode_id1       :0    ,$              ; 2     16
                              Anode_id2       :0    ,$              ; 2     18
                              Anode_id3       :0    ,$              ; 2     20
                              Anode_id4       :0    ,$              ; 2     22
                              Anode_id5       :0    ,$              ; 2     24
                              Anode_id6       :0    ,$              ; 2     26
                              Anode_id7       :0    ,$              ; 2     28
                              Anode_id8       :0    ,$              ; 2     30
                              
                              
                              Anode_pha1      :0.0  ,$              ; 4     34
                              Anode_pha2      :0.0  ,$              ; 4     38
                              Anode_pha3      :0.0  ,$              ; 4     42
                              Anode_pha4      :0.0  ,$              ; 4     46
                              Anode_pha5      :0.0  ,$              ; 4     50
                              Anode_pha6      :0.0  ,$              ; 4     54
                              Anode_pha7      :0.0  ,$              ; 4     58
                              Anode_pha8      :0.0  ,$              ; 4     62
                              
                              
                              Anode_Ener1     :0.0  ,$              ; 4     66
                              Anode_Ener2     :0.0  ,$              ; 4     70
                              Anode_Ener3     :0.0  ,$              ; 4     74
                              Anode_Ener4     :0.0  ,$              ; 4     78
                              Anode_Ener5     :0.0  ,$              ; 4     82
                              Anode_Ener6     :0.0  ,$              ; 4     86
                              Anode_Ener7     :0.0  ,$              ; 4     90
                              Anode_Ener8     :0.0  ,$              ; 4     94
                              
                              Tot_Event_Ener  :0.0  ,$              ; 4     98
                              
                              Latitude        :0.0  ,$              ; 4     102
                              Longitude       :0.0  ,$              ; 4     106
                              Altitude        :0.0  ,$              ; 4     110
                              Atm_Depth       :0.0  ,$              ; 4     114
                              Pnt_Azimuth     :0.0  ,$              ; 4     118
                              Pnt_Zenith      :0.0  ,$              ; 4     122
                              
                              Sweep_No        :0    ,$              ; 2     124
                              Sweep_Strt_Time :0L   ,$              ; 4     128
                              Sweep_Pass_Time :0.0D ,$              ; 8     136
                              Table_Angle     :0.0  ,$              ; 4     140
                              Live_Time       :0.0  }               ; 4     144   TOTAL BYTES OF 1 Event =144 Bytes
                     
                     Packet_Len = 144L ; In Bytes
                     
                     ;   ** Open the binary file and dump it in Data and Close the file.
                     Openr, lun, Filename, /GET_Lun     
                     Data = read_binary(lun)         ; Putting the file in an array
                     Free_Lun, lun
              
                     TotPkt = n_elements(Data)/Packet_Len   ; To get this length of an array. 144 is the Total No. OF Bytes in 1 Event.
                     Event_data = replicate(Struc, TotPkt)  ; Now Create an array for the Struc size for each Evennt.
                     
                     
                     ; Input into defined Structure.
                     For i = 0, TotPkt-1 Do Begin
                              ;**=== Break into smaller Packet.** ===
                              ifirst = (i)*Packet_Len               ; first byte for this packet
                              ilast  = (ifirst+ Packet_Len)-1       ; last byte for this packet
                              pkt = data[ifirst:ilast]              ; this packet of 100Bytes length.            
               
                              ;     ** Now For Each Packet we know the position of each Value.        ** Start  Size.(Byte)                                                                              
                                  
                              Event_data[i].Event_Time       = Double(pkt,0)      ;0    8
                              Event_data[i].Mod_Pos          = pkt[8]             ;1    9
                              Event_data[i].Mod_Ser_No       = Fix(pkt,9)         ;2    11
                              Event_data[i].Event_Class      = pkt[11]            ;1    12
                              Event_data[i].Int_Mod_flag     = pkt[12]            ;1    13
                              Event_data[i].No_Anodes        = pkt[13]            ;1    14
                              
                              Event_data[i].Anode_id1        = Fix(pkt,14)        ;2    16
                              Event_data[i].Anode_id2        = Fix(pkt,16)        ;2    18
                              Event_data[i].Anode_id3        = Fix(pkt,18)        ;2    20  
                              Event_data[i].Anode_id4        = Fix(pkt,20)        ;2    22
                              Event_data[i].Anode_id5        = Fix(pkt,22)        ;2    24
                              Event_data[i].Anode_id6        = Fix(pkt,24)        ;2    26
                              Event_data[i].Anode_id7        = Fix(pkt,26)        ;2    28
                              Event_data[i].Anode_id8        = Fix(pkt,28)        ;2    30
                              
                              Event_data[i].Anode_pha1       = Float(pkt,30)      ;4    34
                              Event_data[i].Anode_pha2       = Float(pkt,34)      ;4    38
                              Event_data[i].Anode_pha3       = Float(pkt,38)      ;4    42
                              Event_data[i].Anode_pha4       = Float(pkt,42)      ;4    46
                              Event_data[i].Anode_pha5       = Float(pkt,46)      ;4    50
                              Event_data[i].Anode_pha6       = Float(pkt,50)      ;4    54
                              Event_data[i].Anode_pha7       = Float(pkt,54)      ;4    58
                              Event_data[i].Anode_pha8       = Float(pkt,58)      ;4    62
                              
                              Event_data[i].Anode_Ener1      = Float(pkt,62)      ;4    66
                              Event_data[i].Anode_Ener2      = Float(pkt,66)      ;4    70
                              Event_data[i].Anode_Ener3      = Float(pkt,70)      ;4    74
                              Event_data[i].Anode_Ener4      = Float(pkt,74)      ;4    78
                              Event_data[i].Anode_Ener5      = Float(pkt,78)      ;4    82
                              Event_data[i].Anode_Ener6      = Float(pkt,82)      ;4    86
                              Event_data[i].Anode_Ener7      = Float(pkt,86)      ;4    90
                              Event_data[i].Anode_Ener8      = Float(pkt,90)      ;4    94
                              
                              Event_data[i].Tot_Event_Ener   = Float(pkt,94)      ;4    98
                              
                              Event_data[i].Latitude         = Float(pkt,98)      ;4    102
                              Event_data[i].Longitude       = Float(pkt,102)      ;4    106
                              Event_data[i].Altitude        = Float(pkt,106)      ;4    110
                              Event_data[i].Atm_Depth       = Float(pkt,110)      ;4    114
                              Event_data[i].Pnt_Azimuth     = Float(pkt,114)      ;4    118
                              Event_data[i].Pnt_Zenith      = Float(pkt,118)      ;4    122
                              
                              Event_data[i].Sweep_No        = FIX(pkt,122)        ;2    124
                              Event_data[i].Sweep_Strt_Time = Long(pkt,124)       ;4    128
                              Event_data[i].Sweep_Pass_Time = Double(pkt,128)     ;8    136
                              Event_data[i].Table_Angle     = Float(pkt,136)      ;4    140
                              Event_data[i].Live_Time       = Float(pkt,140)      ;4    144
                                   
                     EndFor; /i

                  
                    ; NOW PLOTTING
                    Event_Hour = (Event_data.Event_Time/3600)
                    Set_Plot, 'ps'
                    Device, File = OutputFileName, /COLOR, /Portrait
                    device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.5, yoffset = 0.75, font_size = 15, scale_factor = 1.0 
                    !p.Multi = [0,2,3]
                            Plot, Event_Hour, Event_data.Latitude,     Title = ' Latitude',  XTITLE =' Event Time'
                            Plot, Event_Hour, Event_data.Longitude,    Title = ' Longitude', XTITLE =' Event Time'
                           
                            Plot, Event_Hour, Event_data.Altitude,     Title = 'Altitude',   XTITLE =' Event Time'
                            Plot, Event_Hour, Event_data.Atm_Depth,    Title= 'Atm Depth',   XTITLE =' Event Time'
                            
                            Plot, Event_Hour, Event_data.Pnt_Azimuth,  Title= 'Azimuth',     XTITLE =' Event Time'
                            Plot, Event_Hour, Event_data.Pnt_Zenith,   Title = 'Zenith',     XTITLE =' Event Time'
                            
                    xyouts, !D.X_Size/5, !D.Y_Size*1.02, Title_of_Page ,charsize = 1.6, /DEVICE  
                    xyouts, 0,-!D.Y_Size*0.01,(Filename), /DEVICE   
                    
                    Device, /CLOSE
                    Set_Plot, 'x'     
                    !P.Multi = 0  
              print, STRN(p),'   ', STRN(SweepNo[p])
         EndFor ;/p           

      
End