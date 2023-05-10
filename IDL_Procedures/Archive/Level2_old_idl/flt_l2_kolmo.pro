Pro Flt_L2_Kolmo, InputFileFolderPath,  SweepNo, OutputFileFolderPath, PC_Type = PC_Type, CC_Type = CC_Type

; *************************************************************************
; *     GET THE KOLMOGOROV TEST FOR THE LEVEL 2 DATA                      *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read the Level 2 Version 6/7 Binary File and Do the         *
; *           Kolmogorov-Smirnovv Test For the Scattering Angle Instr.    *
; *           Write a TextFile with various results.                      *
; *                                                                       *
; * References: readlevelbinaryfiles.pro                                  *
; *            [ Reads in binary files of certain structure ]             *
; *            [ This Structure follows the Doccuments of Structure of    *
; *                   Level-2 Version 6 Doccumented Data.             ]   *
; *             Dir_Exist.pro                                             *
; *            [ Checks the Existence of Directory]                       *
; *                                                                       *
; * Usage:                                                                *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *           Sweep No. = Sweep No. To be compared with                   *
; *                   Can only range from 1~97 in Version 6 and           *
; *                                       18~97 in Version 7              *
; *                   NOTE: If invalid Entry, Runs for all Files.         *
; *           PC_Type = 1,2,3                                             *
; *                         Note: If Not Defined Or Invalidly Defined     *
; *                               then PC_Type=1                          *
; *           CC_Type = 1,2,3                                             *
; *                         Note: If Not Defined Or Invalidly Defined     *
; *                               then PC_Type=1                          *
; *                                                                       *
; *     Inputs::                                                          *
; *           InputFileFolderPath: Path of the Folder that contains the   *
; *                   The Input files. Need this parameter to run the     *
; *                   The Program.                                        *
; *           OutputFilFolderPath:  This parameter is the the path of the *
; *                   The output files/folders. If Not defined, the       *
; *                   Default path is the Directory its open in           *
; *                                                                       *
; * Involved Non-Library Procedures:                                      *
; *           -Dir_Exist.pro                                              *
; *                                                                       *
; * Libraries Imported:                                                   *  
; *           -Coyote Full Library                                        *
; *           -Astronomy Full Library                                     *
; *                                                                       *
; * File Formats: Takes in the Binary file of Level 2 Version 7 Data Files*
; *            Usually are packets of 100 Bytes For Each Event            *
; *           - The format it reads is That starts with Lv2....dat        *
; *           - Also we get Sweep No. From File Name hence it should      *
; *             Follow the standard way of labelling file as in           *
; *             Level 2, Version 6/7 DataFiles                            *
; *                                                                       *
; *           -Look For Documentation on Lvl 2 Ver 7 Data Structure       *
; *                                                                       *
; * Error Handling: As we take in a specific File Structure and Format    *
; *            Error for Reading the data is not a problem if it is read  *
; *            properly.                                                  *
; *            Another Error could be entering the parameters which       *
; *            could be easily figured out by carefully examining the     *
; *            Documentation above in the USAGE part.                     *
; *                                                                       *
; * Author: 5/31/13   Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; *         6/21/13   Modifications are Transformed into this new program *
; *                   Standard Way of Using/Defining Usage at the Begining*
; *                   Defining a Flag with True/False rather than 1/0     *
; *                   For Clarity.                                        *
; *         6/21/13   Started Modifying to User Input Usage from command  *
; *                   line and Set Different Parameters.                  *
; *                   Also Working with File Name and Directory           *
; *         6/24/13   Finished Modification.                              *
; *                   Labelled This Version as Version 1.6                *
; *                                                                       *
; *************************************************************************
; *************************************************************************

    True = 1
    False = 0
          ; Check for No. Of Parameters
          If n_params() LT 1 Then Begin
                Print, 'ERROR:: Invalid way to Call the Procedure. Please put 1~3 Parameters'
                Print, '        Look a the Documentation for more information.'
                Return
          EndIf
          
          ; Get the List of Files     
          ListofFiles = File_search(InputFileFolderPath+'/Lv2*.dat') ; List of All the Files. 
          If n_elements(ListofFiles) LE 1 Then Begin
                Print, 'ERROR:: Please Select the right Directory'
                Print, '        There is only 1 or Less Files.   '
                Return
          EndIf
          
          ; Current Directory Path/ Or 1 subdirectory
          CD, Current = theDirectory ; This inputs the current Directory to theDirectory
          If Dir_Exist(theDirectory+'/Scat_Angle_Inst') Then theDirectory=theDirectory+'/Scat_Angle_Inst' 
                  
          ; Getting to the Output Folder,File
          If N_Params() EQ 2 Then OutputPath = theDirectory Else  OutputPath = OutputFileFolderPath
          OutFile = OutputPath+'/KolmogorovTest.Txt'
               
          ; Checking for PC_Type Keyword and Making to Default if Error Input.
          If Keyword_Set(PC_Type) EQ False Then PC_Type =1 Else If PC_Type GT 3 Then PC_Type =1
                
          ; Checking for CC_Type Keyword and Making to Default if Error Input.
          If Keyword_Set(CC_Type) EQ False Then CC_Type =1 Else If CC_Type GT 3 Then CC_Type =1     

          ;   Histogram
          BIN_SIZE = 20                                                ; For the Histogram
          N_BINS = 18                                                  ; Binsize = Max - min/(NBINS -1)
          X_Angle = 20                                             ; Value to be multiplied to get the X units.
   
          ; ==============** **=================
          CompareFile =''
          ; Now need to go over file names and extract the file with the correct sweep No.
          For p = 0, N_Elements(ListofFiles)-1 Do Begin
                       StartPos = StrPos(ListofFiles[p], 'Lv2')
                       Ver      = Strn(StrMid(ListofFiles[p],StartPos+4,2))
                       If StrMid(ListofFiles[p], StartPos+22, 2) EQ SweepNo Then CompareFile = ListofFiles[p]
          EndFor

          ; NOTE: We run 1 extra loop for the File to be compared.
          
          For p =0, N_Elements(ListofFiles) Do Begin
                  If p EQ 0 Then file = CompareFile Else file=ListofFiles[p-1]
                  StartPos = StrPos(file, 'Lv2')
                  Sweep    = Strn(StrMid(file,StartPos+22,2))
                  

          ;===== Read and Do the regular Binary File Reading Procedure.
          ; REFER TO LEVEL2 : Version 6 of Grape Processed Event Doccument for further Explaination of the following Structure
                                                      ;Size ( Bytes)
          Struc = { Target_Source :0  ,$          ; 2     2
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
                Src_Azimuth     :0.0  ,$              ; 4     75
                Src_Zenith      :0.0  ,$              ; 4     79
                
                Target_Off      :0.0  ,$              ; 4     83
                Table_Angle     :0.0  ,$              ; 4     87
                Motion_Flag     :0B   ,$              ; 1     88
                Scat_Angle_Inst :0.0  ,$              ; 4     92
                Pos_Angle       :0.0  ,$              ; 4     96
                Live_Time       :0.0  }               ; 4     100   TOTAL BYTES OF 1 Event =100 Bytes
                
            Packet_Len = 100L ; In Bytes         
            
            ;   ** Binary File Operation
            Openr, lun, file, /GET_Lun     
            Data = read_binary(lun)         ; Putting the file in an array
            Free_Lun, lun
            
            TotPkt = n_elements(Data)/Packet_Len   ; To get this length of an array. 100 is the Total No. OF Bytes in 1 Event.
            
            ;Now Create an array for the Struc size.
            Event_data = replicate(Struc, TotPkt) 
            
            ; ** ================ Lets Read the data into the respective Arrays. ===================
            For i = 0, TotPkt-1 Do Begin
                  ;**=== Break into smaller Packet.** ===
                  ifirst = (i)*Packet_Len             ; first byte for this packet
                  ilast  = (ifirst+ Packet_Len)-1       ; last byte for this packet
                  pkt = data[ifirst:ilast]            ; this packet             
                  
                  ;** Now For Each Packet we know the position of each Value.        ** Start  Size.(Byte)                                                                              
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
            EndFor ; For i
           ; **==========  Extraction of Interested Data ===========**
            
            If p EQ 0 Then Begin
                PC_Hist1  =Float(histogram( Event_data[where(Event_data.Event_Class EQ 3)].Scat_Angle_Inst, BINSIZE= BIN_SIZE, MIN=0, MAX=360)) 
                PCT_Hist1 =Float(histogram( Event_data[where((Event_data.Event_Class EQ 3) And ( Event_data.Event_Type EQ 1))].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360))
                CC_Hist1  =Float(histogram( Event_data[where(Event_data.Event_Class EQ 2)].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360))
                CCT_Hist1 =Float(histogram( Event_data[where((Event_data.Event_Class EQ 2) And ( Event_data.Event_Type EQ 1))].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360))        
                CCI_Hist1 =Float(histogram( Event_data[where(Event_data.Event_Class EQ 4)].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360))           
            EndIF  Else   BEgin
                PC_Hist   =Float(histogram( Event_data[where(Event_data.Event_Class EQ 3)].Scat_Angle_Inst, BINSIZE= BIN_SIZE, MIN=0, MAX=360))                ; Defining the Histogram.WE need this for various other calculations. Float to be consistent.
                PCT_Hist  =Float(histogram( Event_data[where((Event_data.Event_Class EQ 3) And ( Event_data.Event_Type EQ 1))].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360))
                CC_Hist   =Float(histogram( Event_data[where(Event_data.Event_Class EQ 2)].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360) )
                CCT_Hist  =Float(histogram( Event_data[where((Event_data.Event_Class EQ 2) And ( Event_data.Event_Type EQ 1))].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360))        
                CCI_Hist  =Float(histogram( Event_data[where(Event_data.Event_Class EQ 4)].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360) )    
            EndElse
            
            
            ;** Create a header so that it is easier to Create Multiple File with similar name but different distinguishable Files.
            Header1 = '**************************************************'
            Header2 = ' KOLMOGOROV SMIRNOV TEST FOR THE FOLLOWING DATA   '
            Header3 = ' Level 2: Version ='+Strn(Ver)
            Header4 = ' Pc_Type ='+ String(PC_Type)+' And '+' CC_Type= '+ String(CC_Type)
            Header5 = '*********-------Sambid Wasti-------***************'
            Header6 = '**************************************************'
            Header7 = ' Format: '
            Header8 = 'Sweep Total_Count Total_PC Kol_Pro_PC Total_PCT Kol_Pro_PCT Total_CC Kol_Pro_CC Total_CCT Kol_Pro_CCT Total_CCT Kol_Pro_CCT'                 
            If P EQ 0 Then Begin
                  Openw, lunger, Outfile, /GET_Lun     ; Creating a File where we can append Later. We can also add Info about the file.
                          Printf, Lunger, Header1
                          Printf, Lunger, Header2
                          Printf, Lunger, Header3
                          Printf, Lunger, Header4
                          Printf, Lunger, Header5
                          Printf, Lunger, Header6
                          Printf, Lunger, Header7
                          Printf, Lunger, Header8
                  Free_lun, lunger
            EndIF Else Begin
                  ; Comparing Kolmogorov-Smirnov Test w.r.t Selected Sweep.  
                    PC_Hist  =Float(histogram( Event_data[where (Event_data.Event_Class EQ 3)].Scat_Angle_Inst, BINSIZE= BIN_SIZE, MIN=0, MAX=360))                ; Defining the Histogram.WE need this for various other calculations. Float to be consistent.
                    PCT_Hist =Float(histogram( Event_data[where ((Event_data.Event_Class EQ 3) And ( Event_data.Event_Type EQ 1))].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360))
                    CC_Hist  =Float(histogram( Event_data[where (Event_data.Event_Class EQ 2)].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360))
                    CCT_Hist =Float(histogram( Event_data[where ((Event_data.Event_Class EQ 2) And ( Event_data.Event_Type EQ 1))].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360))        
                    CCI_Hist =Float(histogram( Event_data[where (Event_data.Event_Class EQ 4)].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360))
                    
                    kstwo, PC_Hist1,  PC_Hist,    D1, Pro1
                    kstwo, PCT_Hist1, PCT_Hist1,  D2, Pro2
                    kstwo, CC_Hist1,  CC_Hist,    D3, Pro3
                    kstwo, CCT_Hist1, CCT_Hist,   D4, Pro4
                    kstwo, CCI_Hist1, CCI_Hist,   D5, Pro5
                    Aver=Total(Event_data.Pnt_Zenith)/(n_Elements(Event_data.Pnt_Zenith)) 
 
                    sentence =String( Strn(Sweep)+' '+Strn(TotPkt)+' '+Strn(Total(PC_Hist))+' '+ Strn(Pro1)+ ' '+ Strn(Total(PCT_Hist))+' '+ Strn(Pro2)+' '+$
                                                                Strn(Total(CC_Hist))+' '+ Strn(Pro3)+ ' '+ Strn(Total(CCT_Hist))+' '+ Strn(Pro4)+' '+$
                                                                Strn(Total(CCI_Hist))+' '+Strn(Pro5)+ ' '+ Strn(Min(Event_data.Pnt_Zenith))+ ' '+$
                                                                Strn(Max(Event_data.Pnt_Zenith)) + ' '+Strn(Aver) )
                    Openw, lunger, Outfile, /GET_Lun, /Append  
                          printf, lunger, sentence    
                    Free_lun, lunger 
                  
             EndElse     
       ;======= ** Print For Keeping Track of Running Program.    
       print, p   ; Keeping Track of Data
       Endfor
End
