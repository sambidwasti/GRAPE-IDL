pro Cal_Anode_Count, InputFileFolderPath, OutputFileFolderPath, Anode = Anode, Number = Number, Type = Type, Class = Class, Shield = Shield, Scale = Scale
; *************************************************************************
; *     Plot The(LEGO PLOT) Counts in each anode(Variation of Color)      *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read the Ascii File of Calibration File which has the       *
; *           value of Anode Number and the respective counts. We try     *
; *           to get a form of Graphical Density Plot                     *
; *                                                                       *
; * References: readDataFiles.pro                                         *
; *            [ Reads in Ascii files for Calibration ]                   *
; *             Dir_Exist.pro                                             *
; *            [ Checks the Existence of Directory]                       *
; *                                                                       *
; * Usage:                                                                *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *           Anode = Anode No. If not defined, runs for all Anodes       *
; *                             and gives a Total Count                   *
; *                             Can only range from 1~64                  *
; *                   Note: If invalid Entry. IT stops the program and    *
; *                         Prints an Error                               *
; *           Number = Total Number of Anodes in an Event to be considered*
; *                    If Not entered, Then Runs for everything.          *
; *                    If Invalid, Prints out Error and Ends the Program  *
; *                                                                       *
; *           Type = 1,2,3   Event Type                                   *
; *                  Type 3: Adjacent Anodes                              *
; *                  Type 2: Corner(Adjacent) Anodes                      *
; *                  Type 1: The Rest                                     *                                                                
; *                  Note: If Not Defined then runs for all               *
; *                                                                       *
; *           Class= 1,2,3   Event Class                                  *
; *                  1 = PC                                               *
; *                  2 = CC                                               *
; *                  3 = PP                                               *
; *                  Invalid if Class <1, Class>3                         *
; *                  NOTE: If Not Defined then runs for all               *
; *                                                                       *
; *           Shield= Non-Zero for Shielding.Default UnShielded           *
; *                                                                       *
; *           Scale = Non-Zero for Scaling. Scaling is a Log Scaling      *
; *                   NOTE: Log Scaling is just for the Colors            * 
; *                                                                       *
; *     Inputs::                                                          *
; *           InputFileFolderPath: Path of the Folder that contains the   *
; *                   The Input files. Need this parameter to run the     *
; *                   The Program.                                        *
; *           OutputFilFolderPath:  This parameter is the the path of the *
; *                   The output files/folders. If Not defined, the       *
; *                   Default path is chosen. The Defalut path is as      *
; *                   Folder of the current path running IDL (Terminal)   *
; *                                                                       *
; * Involved Non-Library Procedures:                                      *
; *           -Dir_Exist.pro                                              *
; *           -EventClass.pro                                             *
; *           -EventType.pro                                              *
; *           -AnodeType.pro                                              *
; *                                                                       *
; * Libraries Imported:                                                   *  
; *           -Coyote Full Library                                        *
; *           -Astronomy Full Library                                     *
; *                                                                       *
; * File Formats:   ASCII TEXT FILES                                      *
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
; *            Unexpected error occurs so we try to exclude those within  *
; *            program and exclude them from calculations.                *
; *            - I Have ##### in the comments for specific errors         *
; *                                                                       *
; *            Another Error could be entering the parameters which       *
; *            could be easily figured out by carefully examining the     *
; *            Documentation above in the USAGE part.                     *
; *                                                                       *
; * Author: 7/10/13   Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; *         7/15/13 SW: Fixed Format of the input file.                   *
; *                     Finished the program. Verified with a Mock data   *
; *                     Input file.                                       *
; *                                                                       *
; * NOTE: Need to spend some time to fix the Log Scale or to check the log*
; *       Scale working Properly.                                         *
; *                                                                       *
; *************************************************************************
; *************************************************************************

    True  = 1
    False = 0

              ; ===== INITIALIZATIONS ======
              If (n_params()) LT 1 OR (n_params() GT 2) Then Begin
                    PRINT, 'ERROR: NO. OF PARAMETER SHOULD BE AT LEAST 1 or AT MOST 2 which is the INPUT FILE FOLDER  and OUTPUT FILE FOLDER'
                    Return
              EndIF
          
                    ;==** Flags
                    ;Anode Keywords and Flags along with error.
                    If Keyword_Set(Anode) EQ 0 Then AllAnode= True Else Begin
                                             AllAnode = False    ; Sets All Anode Depending on Anode Entered.
                                             PAnode = Anode
                                             If (Anode LT 1) Or (Anode GT 64) Then Begin
                                                  Print, 'ERROR: INVALID ANODE Number'
                                                  Return
                                             EndIf
                    EndElse                          
                    
                    Num_Event = 64
                    ;No. of Anodes fired in an Event with Flags and Errors
                    If Keyword_Set(Number) EQ 0 Then AllEvent= True Else Begin
                                             AllEvent = False    ; Sets All Anode Event Depending on Number Entered.
                                             Num_Event = Number
                                             If (Number LT 1) Then Begin
                                                  Print, 'ERROR: INVALID Number of Anodes. Must be Greater Than 1'
                                                  Return
                                             EndIf
                    EndElse
                    
                    Event_Type = 1
                    ;Event Type with Flags and Errors
                    If Keyword_Set(Type) EQ 0 Then AllType= True Else Begin
                                             AllType = False    ; Sets All Type depending on Type Entered
                                             Event_Type = Type
                                             If (Type LT 1) and (Type GT 3) Then Begin
                                                  Print, 'ERROR: INVALID Type Number. Must be 1,2,3'
                                                  Return
                                             EndIf
                    EndElse
                  
                    ;Event Class with Flags and Errors
                    Event_Class = 1
                    If Keyword_Set(Class) EQ 0 Then AllClass= True Else Begin
                                             AllClass = False    ; Sets AllClass depending on Event Class Entered
                                             Event_Class = Class
                                             If (Class LT 1) and (Class GT 3) Then Begin
                                                  Print, 'ERROR: INVALID Event Class. Enter 1 For PC    2 For CC    3 For PP'
                                                  Return
                                             EndIf
                    EndElse
                    
                    ;Scaling True or False
                    If Keyword_Set(Scale) EQ 0 Then Scaling = False Else Scaling = True
                    
                    ; Shield Flag
                    Flag_Shield = Keyword_Set(Shield)
                    
                    ;==** Inputs/Outputs File Names and Paths ( Folder Directories )
                    
                    CD, Current = theDirectory                  ; This inputs the current Directory to theDirectory
                    If N_params() EQ 1 Then OutPutFolder =theDirectory ELSE OutPutFolder = String(OutputFileFolderPath)
                    pathToFile = Rmv_bk_Slash(InputFileFolderPath)            ; Just so that the writing this is Easier
          ; Needs to go  
;***********          ;         
                    file = String('Sample_Data_2013_July_10')                       ; Need to follow this route as in " the 0 has some function and it doesnt take it like a text.    
                    filename = file+'.txt'
          ; NEED TO SPECIFY THE FILE NAME.. SO HAVE TO THINK WHETHER TO CHOOSE ALL 0 DEGREES or 1 FILE INPUTTED>>> ETC>........ Even have to input a Loop of Files..
;*******                    
                    ; Checking Folder Existence and Creating if it doesnt exist.
                    OutputFolderName = OutputFolder+'/Modules'                 ; Checks For Folder Module
                    FolderName = OutputFolderName+'/'+file                    ; Checks For Module/Source
                    
                    ; Now We need to Define a Folder Within depending on what kind of Event type and Number to be selected. A variable SName contains the subfolder name
                    SName = ''
                    If AllEvent EQ True Then SName = SName+'All_Event' Else SName = SName+Strn(Number)+'Event'
                    If AllType  EQ False Then SName = SName+'_Type'+Strn(Event_Type)
                    If AllClass EQ False Then SName = SName+'_Class'+Strn(Event_Class)
                    SubFolderName = FolderName+'/'+SName
                
                    ; Check for Directory and Make one if it DOES NOT EXIST  
                    If Dir_Exist(OutputFolderName) EQ False Then File_MKdir, OutputFolderName
                    If Dir_Exist(Foldername) EQ False Then File_MKdir, FolderName          
                    If Dir_Exist(SubFoldername) EQ False Then File_MKdir, SubFolderName          
            
              ;==========FINISH INITIALIZATION==========
              ;==========Now Reading in Data============
                     
                  
                    IF AllAnode EQ False Then GOTO, JUMP1       ; If We only want one anode we Skip the For Loop.
                    For p = 1, 64 Do Begin        
                          PAnode = p
                    JUMP1:
                  
                      ;== Definitions in the Loop/ Initialization within a loop

                      ImageName = SName+'_' + Strn(PAnode)
 ; ImageName = "File_'+ImageName                      
                    
                      ; ===========**Open File**=============
                      file = pathToFile+'/'+filename                                ; Location of the File. Useful for multiple.
                      OPENR, logicUnit, file, /GET_LUN                          ; Open the file. A logicUnit assigned. 
                      
                      ; --------** READ THE FILE **-----------                                                              
                      rowsFile = FILE_LINES(file)                               ; We get the no. of rows from here.
                      data = strarr(rowsFile)                                   ; data = Array of string with values for each line.
                      READF, logicUnit, data                                    ; Read the file and dump everything in the String Array.
                      
                      ; ===========**Close File**=============
                      FREE_LUN, logicUnit                                       ; Closing the file equivalent to freeing the long number( logic unit )
                      
                      SLen = 0L                                                 ; Each String Length ( Each Line )
                      AnodeCount = lonarr(64)                                   ; An Array for counter for each anode
                      Errorcount = 0L                                           ; Total No. Of Error lines encountered.
                      
                      For i = 0, rowsFile-1 Do Begin                            ; For loop to run for each of the Line/ String.
                        
                             SLen  = strlen(data[i])                            ; Length of the Line (String)   
                             Flag  = False                                      ; Flag For Error    
                             AFlAG = False                                      ; Flag to Check whether the intrested Anode is in the Event
                             TFlAG = False                                      ; Flag for Type of Event
                             CFlag = False                                      ; Flag for Class of Event
                             NFlag = False                                      ; Flag for No. of Events
                             
                             ;******************************************************************************************************* 
                             ;* NOTE: As we look at Each Event( Each Line). Then each individual Anode, We might count an event and *
                             ;* find another anode had an error within in the same line.                                            *
                             ;* This is a problem. I try to get rid of the whole Line and not take data of that value.              *
                             ;* I tried to check before accounting for it and Flags help to verify the validity of the data.        *
                             ;*******************************************************************************************************
                             
                             AnodeCounter= 0L                                             ; Counter For No. Of Events.
                             
                                    jstart= strpos(data[i], " ", 0) +1                    ; The Live time is of only 3 Digit. Fixed in the code. It should give 2 as jstart.
                                    Live_Time = Strn(Strmid(data[i], jstart,3))                   ; Get the Live_Time
                                    
                                    If strmid(data[i],0,1) NE '#' Then Flag = True        ; Check for good data.
                                    
                                    ;============== **ERROR CHECKING** =================
                                    jstart= strpos(data[i], " ",4) +1                     ; Next Space + 1 location is the starting of the values. 
                                    For j = jstart,SLen-5 Do Begin                                    ; SLen-4 just to optimize it quicker as we are incrementing with the value of j=j+6, it doesnt matter either way.
                                              If ( strmid(data[i],j-1,1) NE " ") OR ( strmid(data[i],j+5,1) NE " ")  Then  Flag = True     ;####  If the format is invalid then this Condition triggers.
                                              j = j+5                                                  ; We are only doing j = j+5 instead of j + 6 because for loop increments 1 for us.     
                                    EndFor  ;j 
                                    If strmid(data[i],jstart,1)EQ " " Then Flag =True                ; ####Error For Two Spaces.. 
                                    If jstart GT 6 Then Flag = True                                  ; ####IF there is no space in the start. The position goes around to next which might be valid so this check needs to be done.
                                    ;===================================================
                                    
                                    
                                    ;=========== ** Valid Event Checking **================= { Valid If No Error/ Selected Anode,Class, No. of Events Matched..etc)
                                    ;Now if No Error We need Flags to specify what data to select.( That is decided by the parameters and type of Data )
                                    ;=========== ** Data Selection  **======================
                                    IF Flag EQ False Then Begin
                                           For j = jstart,SLen-4 Do Begin 
                                                  Anode = Fix(strmid(data[i],j,2))       ; Extract Anode No.

                                                  If Anode EQ PAnode Then AFLAG = True    ; Set Up one Flag    
                                                  AnodeCounter++                          ; Increment the counter for No. of Events.
                                                      
                                                  ; Check for Type
                                                  For k = jstart,SLen-4 Do Begin
                                                          Anode1 = Fix(strmid(data[i],k,2))      ; Extract Anode No.
                                                          If (EventType(Anode, Anode1)  EQ Event_Type)  And (AllType   EQ False)Then TFlag = True  ; So False if AllType true or AllType = True and Event_Tye NE..
                                                          If (EventClass(Anode, Anode1) EQ Event_Class) And (AllClass  EQ False)Then CFlag = True  ; Similar As above. Only 4 options.and 1 True..
                                                          k = k+5
                                                  EndFor; k
                                                  j=j+5
                                           EndFor; j
  
                                    EndIf Else Begin
                                            ErrorCount++
                                    EndElse
                                    
                                    If (AnodeCounter EQ Num_Event) And ( AllEvent EQ False) Then NFlag = True    ; Checks for Flag for No. of Events.
                                    ;=========================================================
                                  
                                    ;==================DATA COLLECTION========================We need bunch of If and Else Ifs..
                                    If Flag EQ False  Then Begin            ; If No Error..
                                           If (Aflag EQ True) Then Begin
                                                  If (NFlag EQ True) OR (ALLEvent EQ True) Then Begin
                                                        IF (CFlag EQ True) OR (AllClass EQ True) Then Begin  
                                                              If (TFlag EQ True) OR ( AllType EQ True) Then Begin
                                                                    For j = jstart,SLen-4 Do Begin                             
                                                                        anode= Fix(strmid(data[i],j,2))
                                                                        AnodeCount[anode-1]++
                                                                        j = j+5  
                                                                    EndFor ; j
                                                              EndIf; TFlag
                                                         EndIf; CFlag        
                                                 EndIf ; NFlag
                                          EndIf ;Aflag  
                                    EndIf ;Flag
                         EndFor ; i

                    Z = LonARR(8,8)
                    zcount = 0L
                    ;===** Resetting the value of the respective Anode so that it is not scaled w.r.t it.
                    ;AnodeCount[Panode-1]= 0.0
                 
                    ;**   We are trying to create a 8 X 8 Array for AnodeCount
                    For i = 0, 7 DO BEGIN
                            FOR j=0, 7 DO BEGIN
                                    Z[j,i] = Long(255*(Float(AnodeCount[zcount])/Float(Max(AnodeCount)) )  ) ; This will put the values into percentage/ratio of 1000.
                                    zcount++
                            ENDFOR
                    ENDFOR
                    
                    ; Scale if The keyword Scale set
                    If Scaling EQ True Then Begin
                          For i = 0, 7 DO BEGIN
                                FOR j=0, 7 DO BEGIN
                                    If Z[j,i] NE 0 Then Z[j,i] = ALog(Abs(Z[j,i])) ; Changing to Logs except 0. No decimals as everything is a Number.
                                ENDFOR
                          ENDFOR
                          Z = Long(255*( Float(Z)/Float(Max(Z)) ))
                    EndIf
                    
                    ;/*** For Saving the color thing is giving trouble so removed it for now. Need to fix it. Even for Rectangle function    
                    Z_New = CONGRID(Z, 1024,1024)                ; Also could be seen as a Zoom in Image or various other things. Care of using ReBIn to Congrid.
                    
                    ;=== Plotting the Lego Plot..
                      SET_Plot, 'ps'                        ; plot a ps file.
                      loadct, 13                           ; load color
                      Device, File = SubFolderName+'/'+imagename, /COLOR
                             Tv, Z_New      ; Plots the array function.
                             Xs = !D.X_Size*0.09
                             Ys = !D.Y_Size*0.12
                             zcount = 1L
                             
                             For i = 0, 7 Do Begin ; Printing the Anode Number on the plot to identify the anode
                                  For j = 0, 7 Do Begin
                                        If Zcount EQ Panode Then XYOUTS, (Xs/3)+Xs*(j), (Ys/2)+ Ys*(i), charsize = 1.5, Strn(zcount), /DEVICE , Charthick = 7, Color=cgColor('White') Else $
                                        XYOUTS, (Xs/3)+Xs*(j), (Ys/2)+ Ys*(i), charsize = 1.5, Strn(zcount), /DEVICE , Charthick = 2
                                        zcount++;          
                                  Endfor
                             EndFor
                             
                             XYOUTS, !D.X_Size*0.01, -!D.Y_Size*0.05, charsize = 1.4, filename, /DEVICE
                             XYOUTS, !D.X_Size*0.13, !D.Y_Size*1.08, charsize = 2, 'Counts for Each Anode', /DEVICE
                             XYOUTS, !D.X_Size*0.13, !D.Y_Size*1.02, charsize = 2, SName, /DEVICE
                             XYOUTS, !D.X_Size*0.775, !D.Y_Size*0.95, charsize = 0.8, 'Color Scale for No. of Counts',/DEVICE
                             If Scaling EQ True Then Begin
                                    XYOUTS, !D.X_Size*0.775, !D.Y_Size*0.925, charsize = 0.8,'(Rescaled Logarithmic Values)',/DEVICE
                                    cgCOLORBAR, NCOLORS=255, POSITION=[0.88, 0.10, 0.95, 0.90], /VERTICAL , Range=[0,Max(AnodeCount)], DIVISIONS= 8, /YLOG, YTICKS=0
                             EndIf Else Begin 
                             cgCOLORBAR, NCOLORS=255, POSITION=[0.88, 0.10, 0.95, 0.90], /VERTICAL , Range=[0,Max(AnodeCount)], DIVISIONS= 8
                             EndElse
                        Device, /CLOSE
                     SET_PLOT, 'x'
            
                  If AllAnode EQ 0 Then GOTO, Jump2                                        ; Skip the looping things if Flag is set for 1 anode
                          print, p
                  EndFor ; p      
              Jump2:
              Print, ' ==== Program Ended =====' 
End


