pro Cal_Quicklook, InputFileFolderPath , LOG=log, Lim = Lim

; *************************************************************************
; *   A quick look to the Data with Pulse Height Count and Channel No.    *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read the Ascii File of Calibration File which has the       *
; *           Anode No. and Pulse Height. And get a Pulse height          *
; *           distribution for different anodes.                          *
; *                                                                       *
; * References: readDataFiles.pro                                         *
; *            [ Reads in Ascii files for Calibration ]                   *
; *                                                                       *
; * Usage:                                                                *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *     Inputs::                                                          *
; *           InputFileFolderPath: Path of the Folder that contains the   *
; *                   The Input files. Need this parameter to run the     *
; *                   The Program.                                        *
; *                                                                       *
; * Involved Non-Library Procedures/functions:                            *
; *           -Dir_Exist.pro                                              *
; *           -Rmv_Bk_Slash.pro                                           *
; *                                                                       *
; * Libraries Imported:                                                   *  
; *           -Coyote Full Library                                        *
; *           -Astronomy Full Library                                     *
; *                                                                       *
;; * File Formats:   ASCII TEXT FILES                                     *
; *             Usually from HyperTerminal Text Files of the following    *
; *             Format:                                                   *
; *             # LLL VALUE VALUE VALUE...                                *
; *             - #   : Shield Status                                     *
; *             - LLL : LIVETIME                                          *
; *             - VALUE:Value that has Andoe no. and pulse height.        *
; *                                                                       *
; * Error Handling: As we take in a specific File Structure and Format    *
; *            Error for Reading the data is not a problem if it is read  *
; *            properly. There are exceptions on the data and sometimes   *
; *            Unexpected error occurs so we try to EXCLUDE those within  *
; *            program and EXCLUDE them from calculations.                *
; *            - I Have ##### in the comments for specific errors         *
; *                                                                       *
; *            Another Error could be entering the parameters which       *
; *            could be easily figured out by carefully examining the     *
; *            Documentation above in the USAGE part.                     *
; *                                                                       *
; * Author: 7/19/13   Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; *                                                                       *
; *************************************************************************
; *************************************************************************


      True  = 1         ; Define True             
      False = 0         ; Define False
      
      ;== INITIALIZATION AND DEFINITION ==
      N_Bins = 1024
          
              ;==** Flags
              If (N_params()) LT 1 Then Begin
                        Print,  ' ERROR: No. of Parameters Should be at least 1'
                        Print,  '        Enter the File Name and Path          '
                        Return
              EndIF Else  InputFileFolderPath = Rmv_Bk_Slash(InputFileFolderPath)     ; Removes the Back Slash if there are any.
              file = InputFileFolderPath
             
              ; Software Threshold Set up 
              If Keyword_Set(Lim) EQ 0 Then Lim = 0L Else Begin
                        Lim = FIX(Lim)
                        If ( Lim LT 0) OR ( Lim GT 1024) Then Begin
                                Print, 'ERROR: Non-Valid Entry for Pulse Threshold'
                                Print, 'VALUE CAN ONLY BE BETWEEN 0 and 1024 or None '
                                Return
                        EndIf
              EndElse
             
              ; Log Parameter
              If Keyword_Set(log) EQ 0 Then log=False Else Begin
                        log = True
                        If ( log NE 1) Then Begin
                                Print, 'ERROR: INVALID Flag for LOG'
                                Print, 'SET THE VALUE TO 1 to ENABLE LOG PLOT '
                                Return
                        EndIf
              EndElse
              
              CD, Current = theDirectory                  ; This inputs the current Directory to theDirectory
              
              ; Selecting the String
              T_num = 0 ; Temporary Number Variable
              For k = 0, StrLen(file)-5 Do Begin
                    T_num = StrPos(file, 'FM',k)
                    If T_num NE -1 Then Pos = T_num
              EndFor              

              ;Extracting Few Information :For a standard File name = FM###_###Deg_Source_MMDDYY_****.txt ( *** YEt to figure. ); Extract Info.
              Module = StrMid(file, Pos, 5)
              Angle  = StrMid(file, Pos+6, 3)
              Pos1 = StrPos(file,'_',Pos+14)
              Src = StrMid(file, Pos+13,Pos1-Pos-13)

              Thresh = StrMid(file,Pos1+9,3)

              Pos2 = StrPos(file,'_',Pos1+11)+1
              Pos3 = StrPos(file,'.txt',Pos1+11)
              Pos5 = StrPos(file,'_',Pos1+3)+1
              
              If StrMid(File, Pos5, 1) EQ 'T' Then Str_Mins = StrMid(file, Pos2, Pos3-Pos2) Else Begin
                                                        Pos4 = StrPos(file, '_', Pos2+2)+1
                                                        Str_Mins = StrMid(file, Pos4, Pos3-Pos4)
                                                       
              EndElse
              Event = 1
  
              OutputFolderName = theDirectory+'/QuickLook/'                        ; Checks For Folder Module
              OutputFileFolderName = OutputFolderName+Angle+'Deg_'+Src+'_'+Thresh+'/'
              If Dir_Exist(OutputFolderName) EQ False Then File_MKdir, OutputFolderName   ; Create Folder if it Does Not Exist.
              If Dir_Exist(OutputFileFolderName) EQ False Then File_MKdir, OutputFileFolderName   ; Create Folder if it Does Not Exist.

              ;=== INPUT : Reading and Manipulating the File ==
                    ; ===========**Open File**=============
                    OPENR, logicUnit, file, /GET_LUN                          ; Open the file. 
                    data ='' 
                    ;========== Work With The Data =============    
                    Pulse = lonarr(64,1024)                                   ; At first we create an array of file length to store the Pulse Heights
  
                    SLen = 0L                                                 ; Each String Length ( Each Line )
                    Errorcount = 0L                                           ; Total No. Of Error lines encountered.
                    

                    Temp_Count = 0L
                    ; Operating on Each line of the File  
                     ; Operating on Each line of the File         
                    While not EOF(logicunit) DO Begin
                              Temp_Count++
                              READF, logicUnit, data                                    ; Read the file and dump everything in the String Array.
                              
                              SLen = strlen(data)                                ; Length of the Line    
                              Flag = False                                       ; A flag to check the validity of Data or Substring( Checking Errors..)
                              N_Counter = 0                                      ; Event to check no. of anodes fired
                              
                                    If strmid(data,0,1) NE '#' Then Flag = True        ; Check for good data.
                                    
                                    jstart= strpos(data, " ", 0) +1                    ; The Live time is of only 3 Digit. 
                                   
                                    ;============== **ERROR CHECKING** =================
                                    jstart= strpos(data, " ",4) +1                     ; Next Space + 1 location is the starting of the values. 
                                    For j = jstart,SLen-5 Do Begin                                    ; SLen-4 just operate it quicker
                                              If ( strmid(data,j-1,1) NE " ") OR ( strmid(data,j+6,1) NE " ")  Then  Flag = True     ;####  If the format is invalid 
                                              N_Counter++
                                              j = j+6                                                  ; We are only doing j = j+5 instead of j + 6 because for loop increments 1 for us.     
                                    EndFor  ;j 
                                    If strmid(data,jstart,1)EQ " " Then Flag =True                ; ####Error For Two Spaces.. 
                                    If jstart GT 6 Then Flag = True                                  ; ####IF there is no space in the start. The position goes around to next which might be valid so this check needs to be done.
                                    If N_Counter NE Event Then Flag = True                            ; Selects only 1 Anode Event
                                    ;===================================================
                                  
                                    ;=========Data Collection===========================
                                    If Flag EQ False Then Begin ; If No Errors.
                                          For j = jstart,SLen-4 Do Begin     
                                          
                                                  panode= FIX(strmid(data,j,2))                 ; Grab the Anode No.
                                                  p=panode-1
                                                  Temp_Pulse = FIX(strmid(data,j+2,4))-1
                                                  If Temp_Pulse GT Lim Then  Pulse[p,Temp_pulse]++
                                                  j = j+6
                                          EndFor
                                       
                                    EndIf  Else Begin
                                            Errorcount++
                                    EndElse
                                    ;====================================================
;                    EndFor ; End i ( Each Line )
                    If (Temp_Count mod 100000) EQ 0 Then Print, Temp_Count
                    EndWHile
                    
     
                    ; ===========**Close File**=============
     
                           FREE_LUN, logicUnit                                       ; Closing the file 

;=================== = =========== *********DATA SELECTION AND PROCESSING******** ================== = =
                    ;****************************************************************
                    ;*  We have the 2-D Array with Anode and Pulse Counts           *
                    ;*  So, we extract those cleverly for plotting multiple Pages   *
                    ;****************************************************************
                     XFit = INDGEN(N_BINS)*(1024/N_BINS) 
                    For p = 0, 63 Do Begin                          ; Now we have extracted all the anode pulse heights. Now we process for Each Anode.
                          Anode = p+1
                          ;If AnodeType(Anode) EQ 0 Then Goto, JUmp1
                          ;===== Work With the Pulse Height ( Select the right Row/column from 3-D
                          Pulse_Height = LonArr(1024)
                          For i = 0, 1023 Do Pulse_Height[i] = Pulse[p,i]                     ; Moved all the Pulse Height to a smaller array. As it is not necessary that all event had the anode no. 
                          hist = Pulse_Height
                        
                       
                          IF log EQ True then hist = Alog(Hist)
     
                          If AnodeType(Anode) EQ 0 Then X_MAX = 700 Else X_MAX = 200
                                
                          If log EQ True Then LName='Log_+' Else LName=''
                          
                          Set_Plot, 'ps'
                          loadct, 13                           ; load color
                          Device, File = OutputFileFolderName+'/'+'Quick_Anode_'+LName+ STRN(String(Anode)), /COLOR
                         
                                  plot,XFIT,hist,XTITLE = 'Channel No.',YTITLE = 'No. of Counts',Title = ' Anode = ' + Strn(p+1) ,$
                                                PSYM=10,/NODATA, XRange=[0,X_MAX],XSTYLE=1 , YRange=[0,2000], YSTYLE=1
                                  oplot,XFIT,hist, PSYM=10
                                  
                                  
                               
                          Device, /Close
                          Set_Plot, 'x'
                          
                         
  ; Now do Energy Calibration         
                      ;Jump1:
               EndFor ;p
               ; Creating a Text file which needs to be changed to a executable file to change the ps to pdf file.
                openw, Lunger, OutputFileFolderName+'/'+'convert_to_pdf' , /GET_LUN
                    printf, Lunger, '# CONVERTS THE FILES TO PDF'
                    printf, Lunger, '# Sambid Wasti'
                    printf, Lunger, 'for f in Quick*'
                    printf, Lunger, 'do ps2pdf $f $f.pdf'
                    printf, Lunger, 'rm $f'
                    printf, Lunger, 'done'
                free_lun, LUnger  
  
End
