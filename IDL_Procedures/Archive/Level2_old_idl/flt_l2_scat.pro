Pro Flt_L2_Scat, InputFileFolderPath, OutputFileFolderPath,Sweep=Sweep, CFit=CFit,  PA=PA, PC_Type= PC_Type , CC_Type= CC_Type

; *************************************************************************
; *     READ LEVEL2 BINARY FILE AND PLOT GRAPHS                           *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read the Level 2 Version 6/7 Binary File and Plot Different *
; *           Graphs or Write a TextFile with various information.        *
; *                                                                       *
; *           -Plots: It looks at different kinds of events               *
; *            Selects the following Event and Plot the various Plots     *
; *            PC, PC TYPE, CC, CC TYPE, CC INTER          VERSUS         *
; *            TABLE POSITION ANGLE or SCATTERING ANGLE INSTRUMENT        *
; *            Depending on the Flags defined at usage                    *
; *            And at the End, Plots Table Angle Vs Event Time            *
; *           -This program DOES NOT do Kolmogorov Test                   *
; *           -Also creates a file with Chi Squared for Cc Events         *
; *                                                                       *
; * References: readlevelbinaryfiles.pro                                  *
; *            [ Reads in binary files of certain structure ]             *
; *            [ This Structure follows the Doccuments of Structure of    *
; *                   Level-2 Version 6 Doccumented Data.             ]   *
; *             Dir_Exist.pro                                             *
; *            [ Checks the Existence of Directory]                       *
; *                                                                       *
; * Usage:     As shown in the function above. Least no. of params = 1    *
; *                     ******KEYWORDS*******                             *
; *     KeyWord Flags::    Integers( Zero or NonZero)                     *
; *           CFit = Curve Fitting.                                       *
; *                          Non-Zero = True                              *
; *                          Zero     = False    (DEFAULT)                *
; *           PA = Position or Scattering Angle                           *
; *                          Non-Zero = Position Angle                    *
; *                          Zero    = Scattering Ange Instrument(DEFAULT)*
; *     Keyword Parameters::                                              *
; *           Sweep = Sweep No. If not defined, runs for all files.       *
; *                   Can only range from 1~97 in Version 6 and           *
; *                                       18~97 in Version 7              *
; *                   NOTE: If invalid Entry, Runs for all Files.         *
; *           PC_Type = 1,2,3                                             *
; *                         Note: If Not Defined Or Invalidly Defined     *
; *                               then PC_Type=1                          *
; *           PC_Type = 1,2,3                                             *
; *                         Note: If Not Defined Or Invalidly Defined     *
; *                               then PC_Type=1                          *
; *     Inputs::                                                          *
; *           InputFileFolderPath: Path of the Folder that contains the   *
; *                   The Input files. Need this parameter to run the     *
; *                   The Program.                                        *
; *           OutputFileFolderPath:  This parameter is the the path of the*
; *                   The output files/folders. If Not defined, the       *
; *                   current directory is chosen as Default.             *
; *                                                                       *
; *                                                                       *
; * Involved Non-Library Procedures:                                      *
; *           -Figureplot.pro                                             *
; *           -gfunct.pro                                                 *
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
; *           -File Names could be a problem. So i saw a pattern in       *
; *            the file names so Depending on the Anode Number, the       *
; *           -File chooses the specific file name by comparing and       *
; *            finding those filenames based on the pattern and the       *
; *            Anode Number                                               *
; *                                                                       *
; * Author: 5/31/13   Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; *         6/24/13   Modifications  on how the Inputs are done.          *
; *                   Now the Inputs are being done from the Terminal     *
; *                                                                       *
; *************************************************************************
; *************************************************************************

    True  = 1         ; Define True Flag
    False = 0         ; Define False Flag

    If (n_params()) LT 1 OR (n_params() GT 2) Then Begin
          PRINT, 'ERROR: NO. OF PARAMETER SHOULD BE AT LEAST 1 which is the INPUT FILE FOLDER PATH'
          Return
    EndIF

           ; Flags
                CFit = Keyword_Set(CFit)        ; Flag for Curve Fit. Default = 0 = False
                PosScat = Keyword_Set(PA)       ; Working on With Position or scattering Angle. Default Scattering.  
                SweepCheck = Keyword_Set(Sweep) ; Checks whether Sweep Entered or not.
       
           ; Define Variables
                ListofFiles = File_search(InputFileFolderPath+'/Lv2*.dat') ; List of All the Files. 

                ; Checking for PC_Type Keyword and Making to Default if Error Input.
                If Keyword_Set(PC_Type) EQ False Then PC_Type =1 Else If PC_Type GT 3 Then PC_Type =1
                
                ; Checking for CC_Type Keyword and Making to Default if Error Input.
                If Keyword_Set(CC_Type) EQ False Then CC_Type =1 Else If CC_Type GT 3 Then CC_Type =1
                

                           
           ;** Checking for SweepCheck and grabbing one specific Sweep File. 
                If SweepCheck EQ True Then Begin
                        For i = 0, n_elements(ListofFiles)-1 Do Begin
                               StartPos = StrPos(Filename, 'Lv2')
                               If StrMid(ListofFiles[i],StartPos+22,2) EQ Sweep Then Filename = ListofFiles[i] Else SweepCheck = False
                        EndFor
                EndIf Else Begin ; If SweepCheck is False,Running for all files 
                        If n_elements(ListofFiles) LT 1 Then Begin
                              print, 'ERROR : Folder Must Have at least 1 Valid Input File.
                              Return
                         EndIf
                EndElse
                
                ; Current Directory Path
                CD, Current = theDirectory ; This inputs the current Directory to theDirectory
          
                If N_params() EQ 1 Then OutPutFolder =theDirectory ELSE OutPutFolder = String(OutputFileFolderPath)
                
                If PosScat EQ True Then Outname=  String('Pos_Angle') Else $       ; File name different. Also it is later defined properly. this is the other half of plot names.
                                        Outname=  String('Scat_Angle_Inst')  
       
              ; For Histogram
                  BIN_SIZE = 20                                                ; For the Histogram  N_BINS = 18; Binsize = Max - min/(NBINS -1)
           
              ; Plot Parameters
                  Angle_Interval = 90                                          ; Angle Interval for the Ticks
                  Ymax_Scale = 2                                               ; Scale by which the Y range increases. 1.5 brings it to around middle. Always want GT 1
     
          ;Checks Multiple file or Single File and uses Loop accordingly.
          If SweepCheck EQ True Then Goto, Jump1
              For p = 0, n_elements(listofFiles)-1 Do Begin
                       Filename = ListofFiles[p]
          Jump1:     
                     StartPos = StrPos(Filename, 'Lv2')
                     ; Grab Version and Sweep No. from the File Name.
                     Ver = Strn(StrMid(ListofFiles[p],StartPos+4,2))
                     SweepNo = StrMid(ListofFiles[p],StartPos+22,2)
  
                     Title_of_Page = ' Plots for Sweep = '+ SweepNo ; Define a String of Title of the Page.
                     
                     ; Checking Folder Existence and Creating if it doesnt exist.
                     OutputFolderName = OutputFolder+'/L2_V'+Ver+'_Plots'
                     FolderName = OutputFolderName+'/'+Outname
                     If Dir_Exist(OutputFolderName) EQ False Then File_MKdir, OutputFolderName
                     If Dir_Exist(Foldername) EQ False Then File_MKdir, FolderName
                     
                     ;Output File names
                     OutputFileName = Foldername+"/Sweep_"+SweepNo+"_Multiple_"+Outname
                     OutputTextFile = Foldername + "/ChiSquared.Txt"
                     If (PosScat EQ True) and (p Eq 0) Then Begin     ; Since we only need Chi-square sheet for Pos~angle.
                                Openw, lunger, OutputTextFile, /GET_Lun  
                                Free_lun, lunger
                     EndIf
                                          
                    ; Define the Structure
                    ; REFER TO LEVEL2 : Version 6/7 of Grape Processed Event Doccument for further Explaination of the following Structure
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
                              Src_Azimuth     :0.0  ,$              ; 4     75
                              Src_Zenith      :0.0  ,$              ; 4     79
                              
                              Target_Off      :0.0  ,$              ; 4     83
                              Table_Angle     :0.0  ,$              ; 4     87
                              Motion_Flag     :0B   ,$              ; 1     88
                              Scat_Angle_Inst :0.0  ,$              ; 4     92
                              Pos_Angle       :0.0  ,$              ; 4     96
                              Live_Time       :0.0  }               ; 4     100   TOTAL BYTES OF 1 Event =100 Bytes
                              
                     Packet_Len = 100L ; In Bytes         
                     
                     ;   ** Open the binary file and dump it in Data and Close the file.
                     Openr, lun, Filename, /GET_Lun     
                     Data = read_binary(lun)         ; Putting the file in an array
                     Free_Lun, lun
              
                     TotPkt = n_elements(Data)/Packet_Len   ; To get this length of an array. 100 is the Total No. OF Bytes in 1 Event.
                     Event_data = replicate(Struc, TotPkt)  ; Now Create an array for the Struc size for each Evennt.
 
                     ; As these are in d 100 Byte Length Each, We want to break those into smaller Packets and then process them.
                     ; As we already have defined Event_data be an array of size TotPkt and each array has the Structure..We store each event in the array position.
                     For i = 0, TotPkt-1 Do Begin
                              ;**=== Break into smaller Packet.** ===
                              ifirst = (i)*Packet_Len               ; first byte for this packet
                              ilast  = (ifirst+ Packet_Len)-1       ; last byte for this packet
                              pkt = data[ifirst:ilast]              ; this packet of 100Bytes length.            
                
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
                      
                      ;Plot Settings For the Device and ETC
                      Set_Plot, 'ps'
                      Device, File = OutputFileName, /COLOR, /Portrait
                      device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.5, yoffset = 0.75, font_size = 15, scale_factor = 1.0 
                      !p.Multi = [0,2,3]
                      TypeVariable = 0      ; Just created this value so that we get a systematic way of using it to identify Type. So if All then Type = 0  
                            ;=======** Plotting **========
                            ;PC   ; Defining the Histogram.WE need this for various other calculations. Float to be consistent. Further Histogram are similar.
                            If PosScat EQ True Then PC_Hist = Float(histogram( Event_data[where(Event_data.Event_Class EQ 3)].Pos_Angle,        BINSIZE= BIN_SIZE, MIN=0, MAX=360, LOCATIONS= XFIT)) Else $
                                                    PC_Hist = Float(histogram( Event_data[where(Event_data.Event_Class EQ 3)].Scat_Angle_Inst,  BINSIZE= BIN_SIZE, MIN=0, MAX=360, LOCATIONS= XFIT)) 
                                                    figureplot, XFIT, PC_Hist, CFit, [1,3, Angle_Interval,TypeVariable, SweepNo],OutputTextFile, PosScat
 
                            ;PC Type 1
                            If PosScat EQ True Then PCT_Hist =Float(histogram(Event_data[where ((Event_data.Event_Class EQ 3) And ( Event_data.Event_Type EQ PC_Type))].Pos_Angle,        BINSIZE = BIN_SIZE, MIN= 0, MAX = 360, LOCATIONS= XFIT)) Else $
                                                    PCT_Hist =Float(histogram(Event_data[where ((Event_data.Event_Class EQ 3) And ( Event_data.Event_Type EQ PC_Type))].Scat_Angle_Inst,  BINSIZE = BIN_SIZE, MIN= 0, MAX = 360, LOCATIONS= XFIT))
                                                    figureplot, XFIT, PCT_Hist,CFit, [2,3, Angle_Interval, PC_Type, SweepNo],OutputTextFile, PosScat
          
                            ;CC
                            If PosScat EQ True Then CC_Hist = Float(histogram( Event_data[where(Event_data.Event_Class EQ 2)].Pos_Angle, BINSIZE =        BIN_SIZE, MIN= 0, MAX = 360, LOCATIONS= XFIT)) Else $
                                                    CC_Hist = Float(histogram( Event_data[where(Event_data.Event_Class EQ 2)].Scat_Angle_Inst, BINSIZE =  BIN_SIZE, MIN= 0, MAX = 360, LOCATIONS= XFIT))
                                                    figureplot, XFIT, CC_Hist, CFit, [1, 2, Angle_Interval,TypeVariable, SweepNo],OutputTextFile, PosScat
            
                            ;CC Type 1
                            If PosScat EQ True Then CCT_Hist = Float(histogram( Event_data[where ((Event_data.Event_Class EQ 2) And ( Event_data.Event_Type EQ CC_Type))].Pos_Angle,        BINSIZE = BIN_SIZE, MIN= 0, MAX = 360, LOCATIONS= XFIT))Else $        
                                                    CCT_Hist = Float(histogram( Event_data[where ((Event_data.Event_Class EQ 2) And ( Event_data.Event_Type EQ CC_Type))].Scat_Angle_Inst,  BINSIZE = BIN_SIZE, MIN= 0, MAX = 360, LOCATIONS= XFIT))  
                                                    figureplot, XFIT, CCT_Hist, CFit, [2, 2, Angle_Interval,CC_Type, SweepNo],OutputTextFile, PosScat
                      
                            ;CC INter
                            If PosScat EQ True Then CCI_Hist = Float(histogram( Event_data[where(Event_data.Event_Class EQ 4)].Pos_Angle,       BINSIZE = BIN_SIZE, MIN= 0, MAX = 360, LOCATIONS= XFIT)) Else $     
                                                    CCI_Hist = Float(histogram( Event_data[where(Event_data.Event_Class EQ 4)].Scat_Angle_Inst, BINSIZE = BIN_SIZE, MIN= 0, MAX = 360, LOCATIONS= XFIT)) 
                                                    figureplot, XFIT, CCI_Hist, CFit, [1,1, Angle_Interval,TypeVariable, SweepNo],OutputTextFile, PosScat
            
                            ;Event Time vs Table Angle     
                            plot, Event_data.Event_Time, Event_data.Table_Angle,charsize = 1.5, Xcharsize = 0.6,$
                                                    XTITLE =' Event Time', YTITLE = ' Table Angle', TITLE= 'TABLE ANGLE VS EVENT TIME',$
                                                    YRANGE=[0,360], YSTYLE=1
                                          
                            
                            xyouts, 0,-!D.Y_Size*0.01,Strmid(Filename, StartPos, 28), /DEVICE       
                            xyouts, !D.X_Size/5, !D.Y_Size*1.02, Title_of_Page ,charsize = 2.5, /DEVICE
                            ;=========End Plotting======
                              
                      Device, /CLOSE
                      
                      Set_Plot, 'x'     
                      !P.Multi = 0
                      ;======= ** Print For Keeping Track of Running Program.    
        If SweepCheck EQ True Then Goto, Jump2
              Print, SweepNo, '**'
              EndFor
        Jump2:       
       
End

