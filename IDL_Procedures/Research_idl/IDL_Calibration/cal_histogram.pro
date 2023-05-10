   
; Finally gotta create plots of Time vs LT and Time vs counts/event.
; Was going to use array to plot.. but might need another way.. keep thinking..

pro Cal_Histogram, InputFileFolderPath, OutputFileFolderPath, Type=Type, Class = Class
; *************************************************************************
; *     Creating a Spectrum(Histogram) File from an Event(Raw) File.      *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read in the raw data file and look at single anode fired    *
; *           and then create the histogram of pulsehieghts for each      *
; *           anode with 1024 number of bins and create a text file of it.*
; *                                                                       *
; * References: readDataFiles.pro                                         *
; *            [ Reads in Ascii files ]                                   *
; *             Dir_Exist.pro                                             *
; *            [ Checks the Existence of Directory]                       *
; *                                                                       *
; * Usage:                                                                *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *     Type = This selects the type of the Anode. We can only get P or C *
; *            Events selected. We use AnodeType function so look at the  *
; *            specific procedure for the output and input information.   *
; *                                                                       *
; *     Class= It is the Class of the Event which are PC, CC and PP events*
; *            we use the EventClass procedure so look at that procedure  *
; *            for more details about the function input and output       *           
; *                                                                       *
; *     Inputs::                                                          *
; *           InputFileFolderPath: Path of the Folder that contains the   *
; *                   The Input files. Need this parameter to run the     *
; *                   The Program.                                        *
; *                                                                       *
; *           OutputFileFolderPath: Path where there is a new folder. If  *
; *                   not specified then the file is created in the same  *
; *                   folder of the input folder .                        *
; *                                                                       *
; *     Outputs::                                                         *
; *           Creates a spectrum file for each Event file in the Current  *
; *           Folder.                                                     *
; *                                                                       *
; * Involved Non-Library Procedures:                                      *
; *           -Dir_Exist.pro                                              *
; *           -AnodeType.pro                                              *
; *           -Rmv_Bk_Slash.pro                                           *
; *                                                                       *
; * Libraries Imported:                                                   *  
; *           -Coyote Full Library                                        *
; *           -Astronomy Full Library                                     *
; *           -MPFit Full Library. For fitting functions.                 *
; *                                                                       *
; * File Formats:   ASCII TEXT FILES                                      *
; *           We get the format of the files from the Calibration Mode 'C'*
; *           From the Hyperterminal using the Grape 2013 for the current *
; *           date.                                                       *
; *           For the current date it spits out the following format      *
; *           # LT TM AnPuls AnPuls AnPuls ...                            *
; *           # = Good or bad ( SHield )                                  *
; *           LT = Live time                                              *
; *           Current microsecond time( or ms )                           *
; *           An = Anode Number(2 digit)                                  *
; *           Puls = Pulse Height ( 4 Digit)                              *
; *           Also the File name consist of various information so be     *
; *           Careful of modifying it if changed from current standard    *
; *           ( More detail in the Calibration Doccument )                *
; *                                                                       *
; * Author: 10/16/13  Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; *         10/31/13  Sambid Wasti                                        *
; *                   Changed the output file name in the textfile        *
; *                   Now we just get the file name excluding the path    *
; *                                                                       *
; * NOTE:                                                                 *
; *                                                                       *
; *************************************************************************
; *************************************************************************

      True  = 1         ; Define True     ( Easier to identify the Flags and Number this way )        
      False = 0         ; Define False

              ;==== INPUT VALIDATION AND DEFINING FEW PARAMETERS (INITIALIZATION IN IDL)
              
              ; Since we are only interested where there are 1 anodes fired in an event. 
              Event = 1
                        
              ;Keyword Check for Type
              If Keyword_Set(Type) EQ 0 Then AllType=True Else Begin
                        AllType = False
                        If ( Type NE 'P') And ( Type NE 'C') Then Begin
                                Print, 'ERROR: Non-Valid Entry for TYPE'
                                Print, 'VALUE CAN ONLY BE EITHER "P" or "C" or None '
                                Return
                        EndIf
                        If Type EQ 'P' Then Anode_Type = 1 Else If Type EQ 'C' Then Anode_Type = 0
              EndElse

              ; Input File or Files Existence and Validity
              InputFileFolderPath = Rmv_Bk_Slash(InputFileFolderPath)     ; Removes the Back Slash if there are any.
             
              ; Grab the list of files.
              Search_KeyWord = 'FM*deg*Event.txt'         ; For Flood File Selection
              InputFileFolderPath = InputFileFolderPath+'/'
              FileNames = File_Search( InputFileFolderPath, Search_KeyWord) 
              If( N_elements(FileNames)) EQ 0 Then Begin
                         Print, 'ERROR: NO FILE EXISTS WITH *000Deg..*'
                         Return
              EndIf
              
              NSrc = N_Elements(FileNames) ; Gives no. of Sources or Event Files.
              Anode_Histogram = LONArr(NSrc,64,1024)
          
              ;CD, Current = theDirectory                  ; This inputs the current Directory to theDirectory
              
              F_Name        = StrArr(NSrc)
              Module        = StrArr(NSrc)
              Angle         = StrArr(NSrc)
              Src           = StrArr(NSrc) 
              Avg_Live_Time = FLTARR(NSrc)
              Str_Mins      = StrArr(NSrc)
              T_Mins        = LonArr(NSrc)
              Temp_Type     = StrArr(NSrc)
              Out_File      = StrArr(NSrc)
             ; ===== Initial INitialization Ended====
             
             ; ======== Now For Each Event File =========
             For q = 0, NSrc-1 Do Begin            ; For Different Event Files.
                    Fname = Filenames[q]           ; Name of the File for Each Event Files.
                    Print, Fname
                    
                    T_num = 0 ; Temporary Number Variable
                    For k = 0, StrLen(Fname)-5 Do Begin ; For Multiple FM included with different folders.
                          T_num = StrPos(Fname, 'FM',k)
                          If T_num NE -1 Then Pos = T_num
                    EndFor              
                    
                    F_Name[q] = StrMid(Fname, Pos, StrLen(Fname)-Pos)
                    ;==== Information from each File Name Extracted and Put into respecive Variables.
                    Pos1 = StrPos(Fname,'_',Pos+14)
                    Pos2 = StrPos(Fname,'_',Pos1+11)+1
                    Pos5 = StrPos(Fname,'_',Pos1+3)+1
                    Pos4 = StrPos(Fname,'_',Pos2+2)+1
                    Pos3 = StrPos(Fname,'_',Pos4+2)
                    
                    Pos6 = StrPos(Fname,'Event.txt',Pos1)
                    
                    Out_File[q]= Strmid(Fname,Pos,Pos6-Pos)
                    Module[q]  = StrMid(Fname, Pos, 5)
                    Angle[q]   = StrMid(Fname, Pos+6, 3)
                    Src[q]     = StrMid(Fname, Pos+13,Pos1-Pos-13)
                    Str_Mins[q]= StrMid(Fname, Pos4, Pos3-Pos4)
                    
                    T_Mins[q]   = Long(STRN(Str_Mins[q]))
                    Temp_CValue =      STRN(StrMId(Fname, Pos2+1, 3))
                    Temp_PValue =      STRN(StrMid(Fname, Pos5+1, 3))

                    ; ===========**Open File**=============
                    OPENR, logicUnit, fname, /GET_LUN                          ; Open the file. 
                    data =''                                                       
                    Rows_File = File_Lines(fname)
                    Pulse_vs_Event = LonArr(Rows_File)
                    ;========== Work With The Data =============    
                    Pulse = lonarr(64,1024)                                   ; At first we create an array of file length to store the Pulse Heights
                    SLen = 0L                                                 ; Each String Length ( Each Line )
                    Errorcount = 0L                                           ; Total No. Of Error lines encountered.

                    Tot_Live_Time = 0L                                        ; We need total live time to get the average.
                    Cnt_Live_Time = 0L                                        ; Which gives total Number of Valid Events
                    Temp_Count = 0L
; Live Time and Time and Count Rate..                    
                    Live_Time_Array  = FltArr(Rows_File/2)
                    Count_Rate_Array = FltArr(Rows_File/2)
                    Main_Time_Array  = LonArr(Rows_File/2)
                    New_Time         = 0L
                    Avg_L_Time       = 0L
                    Count_Rate       = 0L
                    Average_Counter  = 0L
                    mSecond_Counter   = 0L
                    Event_Number = 0L
                    ; Operating on Each line of the File         
                    While not EOF(logicunit) DO Begin
                              Temp_Count++
                              READF, logicUnit, data                             ; Read File Line by Line
                              SLen = strlen(data)                                ; Length of the Line    
                              Flag = False                                       ; Error Flag ( Checking Errors..) [ True for Error ]
                              N_Counter = 0                                      ; Counter for No. Of Events
                              
                              ;==** Standard: # 12 123 123456 123456 123456.. : 123 LT, 12 T, # good
                              
                                    If strmid(data,0,1) NE '#' Then Flag = True        ; Check for good data.
                                    
                                    Time = StrMid(data,2,2)                            ; Extract the Time
                                    
                                    jstart= strpos(data, " ", 3) +1                    ; The Live time is of only 3 Digit. 
                                    L_Time = Strn(Strmid(data, jstart,3))              ; Get the Live_Time
                                                                        
                                    ;============== **ERROR CHECKING** =================
                                    jstart= strpos(data, " ",6) +1                     ; Next Space + 1 location is the starting of the values. 
                                    For j = jstart,SLen-5 Do Begin                                    ; SLen-4 just operate it quicker
                                              If ( strmid(data,j-1,1) NE " ") OR ( strmid(data,j+6,1) NE " ")  Then  Flag = True     ;####  If the format is invalid 
                                              N_Counter++
                                              j = j+6                                                  ; We are only doing j = j+5 instead of j + 6 because for loop increments 1 for us.     
                                    EndFor  ;j 
                                    If strmid(data,jstart,1)EQ " " Then  Flag =True                     ; ####Error For Two Spaces.. 
                                    If jstart GT 9 Then Flag = True                                    ; ####IF there is no space in the start. The position goes around to next which might be valid so this check needs to be done.
                                    If N_Counter NE Event Then Flag = True                             ; Selects only 1 Anode Event
                                    ;===================================================
                            
                                    ;=========Data Collection===========================
                                     
                                    ; For the collection of Time and Lt and CR.
;                                    If New_Time EQ Time Then Begin
;                                              Avg_L_Time = Avg_L_Time+ L_Time
;                                              Count_Rate = Count_Rate+ N_Counter
;                                              Average_Counter++
;                                    EndIF Else Begin
;                                              New_Time = Time
;                                              
;                                              Temp_Avg_L_Time = Float(Float(Avg_L_Time)/Float(Average_Counter))
;                                              Temp_Count_Rate = Float(Float(Count_Rate)/Float(Average_Counter))
;                                              
;                                              Live_Time_Array[mSecond_Counter]= Temp_Avg_L_Time
;                                              Count_Rate_Array[mSecond_Counter]= Temp_Count_Rate
;                                              Main_Time_Array[mSecond_Counter]= mSecond_Counter+1 
;                                             
;                                              mSecond_Counter++
;                                              Average_Counter=0           
;                                   EndElse   
                                    
                                    ; The Actual data
                                    If Flag EQ False Then Begin ; If No Errors.
                                          ;Live Time Variables.
                                          Live_Time = FIX(L_Time)
                                          Tot_Live_Time= Tot_Live_Time + Live_Time
                                          Cnt_Live_Time++
                                          
                                          For j = jstart,SLen-4 Do Begin     
 
                                                  panode= FIX(strmid(data,j,2))                 ; Grab the Anode No.
                                                  p=panode-1
                                                  Temp_Pulse = FIX(strmid(data,j+2,4))
                                                  Pulse[p,Temp_pulse]++
                                                  j = j+6
                                          EndFor
; Counting the Pulse vs event..
                                          If p EQ 10 Then Begin
                                            Event_Number++
                                            Pulse_Vs_Event[Event_Number] = Temp_Pulse
                                          EndIf
                                          
                                          
                                    EndIf  Else Begin
                                            Errorcount++
                                            IF (StrTrim(Data,2) NE '') And (N_Counter LE 1) then Print, Data
                                    EndElse
                                    ;====================================================
                    If (Temp_Count mod 1000000) EQ 0 Then Print, Temp_Count
                    EndWHile
                    
                    Avg_Live_Time[q] = Float(Tot_Live_Time)/Float(Cnt_Live_Time)                    ; Live Time for Each Source.
                    
                    ;Now Build the Histogram and Input into the Anode_Histogram ( 3D Array)
                    For p = 0, 63 Do Begin
                              ;===== Work With the Pulse Height ( Select the right Row/column from 3-D
                    
                              Pulse_height = lonarr(1024)
                              For i = 0, 1023 Do Pulse_Height[i] = Pulse[p,i]                      
                              Hist = Pulse_Height
                              For j = 0, 1023 DO Begin
                                        Anode_Histogram(q, p, j) = Hist(j)
                              EndFor
                    EndFor
                    ; ===========**Close File**=============
                    FREE_LUN, logicUnit                                       ; Closing the file 

              EndFor ; q ( Each Source)
              ;============== Reading from the file done and made the Histogram in the 3D Array ==========
;              Plot, Main_Time_Array,Live_Time_Array
;              Cursor, X9,Y9
              ; Just Making sure if the files are for the same Module.     
              M_Module = Module[0]
   
              CGPlot,Pulse_Vs_Event, PSYM=3 , XRANGE=[0,Event_Number]
              
              ;================    OUTPUT Begins ==============
              OutputFolder = Inputfilefolderpath
           
              ; Create a text file for each of the sources. 
               For i = 0, NSrc-1 Do Begin
                        O_File = OutputFolder+Out_File[i]+'Spect.txt'
                        file = O_File
                        Openw, Lun, file, /Get_Lun 
                              Printf, Lun, 'File            :'+ F_Name[i]
                              Printf, Lun, 'Source          :'+ Src[i]
                              Printf, Lun, 'Module          :'+ Module[i]
                              Printf, Lun, 'Line 4 : Empty for now'
                              Printf, Lun, 'LiveTime        :'+ Strn(Avg_Live_Time[i])
                              Printf, Lun, 'Time_Ran        :'+ Strn(T_mins[i])     
                              Printf, Lun, 'Line 7'
                              Printf, Lun, 'Line 8'
                              Printf, Lun, 'Line 9'
                              Printf, Lun, 'Line 10'
                              For p = 0,63 Do begin
                                        Temp_String = ''
                                        For j= 0,1023 Do begin
                                                Temp_String = Temp_String+' '+ Strn(Anode_Histogram[i,p,j])
                                        EndFor
                                                                         Printf, Lun, Strn(p)+ Temp_String
                              EndFor
                        Free_Lun, Lun
              EndFor
             
End
