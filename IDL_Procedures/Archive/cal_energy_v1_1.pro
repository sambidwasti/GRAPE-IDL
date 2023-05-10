pro Cal_Energy_V1_1, InputFileFolderPath, OutputFileFolderPath, File = File, Anode = Anode, Type = Type, Thresh=Thresh, Log=Log , BINS = BINS

; *************************************************************************
; *   Does a Gaussian Fit and Energy Calibration for different sources    *
; *************************************************************************
; * Version: 1.01                                                         *
; *                                                                       *
; * Purpose:  Read the Ascii File of Calibration File which has the       *
; *           Anode No. and Pulse Height. And get a Pulse height          *
; *           distribution for different anodes and does a fit and        *
; *           Energy Calibration for it                                   *
; *                                                                       *
; * References: readDataFiles.pro                                         *
; *            [ Reads in Ascii files for Calibration ]                   *
; *             Dir_Exist.pro                                             *
; *            [ Checks the Existence of Directory]                       *
; *                                                                       *
; * Usage: Cal_Energy, FolderPath                                         *
; *        Cal_Energy, FilePath, File=1                                   *
; *                     ******KEYWORDS*******                             *
; *     Keyword Parameters::                                              *
; *           Anode = Anode No. If not defined, runs for all Anodes       *
; *                             one at a time.                            *
; *                             Can only range from 1~64                  *
; *                   Note: If invalid Entry. IT stops the program and    *
; *                         Prints an Error                               *
; *                                                                       *
; *           File = This a tricky one. We just say File =1 if 1 file or  *
; *                  else we dont specify at all. Invalid if not 1        *
; *                  or Non-Empty                                         *
; *                                                                       *
; *           Type = C or P anodes to be calibrated. If not Defined we go *
; *                 for all. We do this as some sources are used for      *
; *                 calibrating both or just one.                         *
; *                                                                       *
; *           Thresh= Software Threshhold Energy.                         *
; *                                                                       *
; *     Inputs::                                                          *
; *           InputFileFolderPath: Path of the Folder that contains the   *
; *                   The Input files. Need this parameter to run the     *
; *                   The Program.                                        *
; *                   If Keyword File = 1 then we should directly drag    *
; *                   the location of the File not the Folder.            *
; *                                                                       *
; *           OutputFilFolderPath:  This parameter is the the path of the *
; *                   The output files/folders. If Not defined, the       *
; *                   Default path is chosen. The Defalut path is as      *
; *                   Current Directory that IDL is running from.         *
; *                                                                       *
; * Involved Non-Library Procedures/functions:                            *
; *           -Dir_Exist.pro                                              *
; *           -Rmv_Bk_Slash.pro                                           *
; *                                                                       *
; * Libraries Imported:                                                   *  
; *           -Coyote Full Library                                        *
; *           -Astronomy Full Library                                     *
; *                                                                       *
; * File Formats:   ASCII TEXT FILES                                      *
; *             : File Name                                               *
; *             FM###_***Deg_Source_MMDDYY_***.txt                        *
; *             FM### = FM Module No.                                     *
; *             ***DEG= 3 Digit Angle Degree.  (000Deg for Flood)         *
; *                    ( We only need Flood Run for Calibrating Energy)   *
; *             Source= Soure Info(NOTE: this could be 4~6 Digit          *
; *             MMDDYY= Month, Day, Year Format of the Date               *
; *             ***   = More Infor yet to be determined                   *
; *                                                                       *  
; *             :File Contains                                            *
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
; * Author: 7/15/13   Sambid Wasti                                        *
; *                   Email: Sambid.Wasti@wildcats.unh.edu                *
; *                                                                       *
; * Revision History:                                                     *
; *         7/22/13   Updated FIle formats and cleaning up the code       *
; *                   Specially on the selection of File name and other   *
; *                   Info Extracted from the name of the File.           *
; *                                                                       *
; *         7/31/13   Added Few KeyWOrds and also changed the program so  *
; *                   that we read each event at a time rather than the   *
; *                   whole file in a array to prevent freezing up of idl *
; *                   or prevent some memory Issue. Specially in the 2-D  *
; *                   LonArr(64, RowsFile) where RowsFile is greater than *
; *                   6M or so.                                           *
; *                                                                       *
; * NOTE: We create a pseudo histogram by adding counts in each channel   *
; *       between 0~1024 and then scale the histogram to Bins specified.  * 
; *                                                                       *
; *************************************************************************
; *************************************************************************

      True  = 1         ; Define True             
      False = 0         ; Define False

              ;==== INPUT VALIDATION AND DEFINING FEW PARAMETERS (INITIALIZATION IN IDL)
              
              ;--** Flags **--
              ;Anode Keywords and Flags along with error.
              If Keyword_Set(Anode) EQ 0 Then AllAnode= True Else Begin
                        AllAnode = False    ; Sets All Anode Depending on Anode Entered.
                        If (Anode LT 1) Or (Anode GT 64) Then Begin
                                Print, 'ERROR: INVALID ANODE Number'
                                Return
                        EndIf
              EndElse

              ; Input File or Files Existence and Validity
              If Keyword_Set(File) EQ 0 Then AllFiles=True Else Begin
                        AllFiles = False
                        If ( File NE 1) Then Begin
                                Print, 'ERROR: Non-Valid Entry for File'
                                Print, ' VALUE CAN ONLY BE EITHER 1 or None '
                                Return
                        EndIf
              EndElse
              InputFileFolderPath = Rmv_Bk_Slash(InputFileFolderPath)     ; Removes the Back Slash if there are any.
              
              ; Keyword, Whether you want to do a Log Fit or not.
              If Keyword_Set(log) EQ 0 Then A_log=False Else Begin
                        A_log = True
                        If ( log NE 1) Then Begin
                                Print, 'ERROR: INVALID Flag for LOG'
                                Print, 'SET THE VALUE TO 1 to ENABLE LOG PLOT '
                                Return
                        EndIf
              EndElse
              
              ;Histogram Parameters
              If Keyword_Set(BINS) EQ 0 Then N_BINS = 1024 Else Begin
                        N_Bins = FIX(BINS)
                        If ( N_Bins GT 1024) or ( N_BINS LT 128 )Then Begin
                                Print, 'ERROR: INVALID BINSIZE'
                                Print, 'SET THE VALUE BETWEEN 128 and 1024 '
                                Return
                        EndIf
              EndElse
              Low_Limit= 0


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
              
              ; Since we are only interested where there are 1 anodes fired in an event. 
              Event = 1
              
              ; Software Threshold Set up 
              If Keyword_Set(Thresh) EQ 0 Then TFlag=False Else Begin
                        TFlag = True
                        If ( Thresh LT 0) OR ( Thresh GT 1024) Then Begin
                                Print, 'ERROR: Non-Valid Entry for Pulse Threshold'
                                Print, 'VALUE CAN ONLY BE BETWEEN 0 and 1024 or None '
                                Return
                        EndIf
             EndElse
             
             ; If running for 1 File or All files in the folder. 
             If AllFiles EQ True Then Begin
                          Search_KeyWord = '*000deg*'         ; For Flood File Selection
                          InputFileFolderPath = InputFileFolderPath+'/'
                          FileNames = File_Search( InputFileFolderPath, Search_KeyWord) 
                          If( N_elements(FileNames)) EQ 0 Then Begin
                                        Print, 'ERROR: NO FILE EXISTS WITH *000Deg..*'
                                        Return
                          EndIf
             EndIf Else Begin
                          FileNames = InputFileFolderPath
                          If (FileNames) EQ '' Then Begin
                                        Print, 'ERROR: File Doesnt Exist'
                                        Return
                          EndIf
             EndElse
             
             NSrc = N_Elements(FileNames) ; Gives no. of Sources.
             Anode_Histogram = LONArr(NSrc,64,1024)
          
             ; Few Initialization of the Output File and Folder Path
             CD, Current = theDirectory                  ; This inputs the current Directory to theDirectory
              
             If N_params() EQ 1 Then OutPutFolder =theDirectory ELSE OutPutFolder = String(OutputFileFolderPath)
             OutputFolderName = OutputFolder+'/Calibrated_Files/'                        ; Checks For Folder Module
             If Dir_Exist(OutputFolderName) EQ False Then File_MKdir, OutputFolderName   ; Create Folder if it Does Not Exist.
              
             Module  = StrArr(NSrc)
             Angle   = StrArr(NSrc)
             Src     = StrArr(NSrc) 
             Avg_Live_Time = FLTARR(NSrc)
             Str_Mins= StrArr(NSrc)
             T_Mins = LonArr(NSrc)
             ; ===== Initial INitialization Ended====
               
             ; ======== Now For Each Source =========
             For q = 0, NSrc-1 Do Begin            ; For Sources.
                    Fname = Filenames[q]           ; Name of the File for Each Source.
print, FName
                    ; Information from each File Name Extracted and Put into respecive Variables.
                    T_num = 0 ; Temporary Number Variable
                    For k = 0, StrLen(Fname)-5 Do Begin
                          T_num = StrPos(Fname, 'FM',k)
                          If T_num NE -1 Then Pos = T_num

                    EndFor              
                   
                    Module[q]  = StrMid(Fname, Pos, 5)
                    Angle[q]   = StrMid(Fname, Pos+6, 3)
                    Pos1       = StrPos(Fname,'_',Pos+14)
                    Src[q]     = StrMid(Fname, Pos+13,Pos1-Pos-13)
                    
                    Pos2 = StrPos(Fname,'_',Pos1+11)+1
                    Pos3 = StrPos(Fname,'.txt',Pos1+11)
                    Pos5 = StrPos(Fname,'_',Pos1+3)+1
                   
                    DFlag = False
                    If StrMid(Fname, Pos5, 1) EQ 'T' Then Str_Mins[q] = StrMid(Fname, Pos2, Pos3-Pos2) Else Begin
                                                        Pos4 = StrPos(Fname, '_', Pos2+2)+1
                                                        Str_Mins[q] = StrMid(Fname, Pos4, Pos3-Pos4)
                                                        DFlag = True
                    EndElse
                          
                    T_Mins[q] = Long(STRN(Str_Mins[q]))
 
                    ; ===========**Open File**=============
                    If AllFiles EQ TRUE Then file = Fname Else file = InputFileFolderPath
                    OPENR, logicUnit, file, /GET_LUN                          ; Open the file. 
                    data =''                                                       
 
 
                    ;========== Work With The Data =============    
                    Pulse = lonarr(64,1024)                                   ; At first we create an array of file length to store the Pulse Heights
  
                    SLen = 0L                                                 ; Each String Length ( Each Line )
                    Errorcount = 0L                                           ; Total No. Of Error lines encountered.
                    
                    Tot_Live_Time = 0L                                        ; We need total live time to get the average.
                    Cnt_Live_Time = 0L                                        ; Which gives total Number of Valid Events
                    
                    Temp_Count = 0L
                    ; Operating on Each line of the File         
                    While not EOF(logicunit) DO Begin
                              Temp_Count++
                              READF, logicUnit, data                                    ; Read the file and dump everything in the String Array.
                              
                              SLen = strlen(data)                                ; Length of the Line    
                              Flag = False                                       ; A flag to check the validity of Data or Substring( Checking Errors..)
                              N_Counter = 0                                      ; Event to check no. of anodes fired
                              
                                    If strmid(data,0,1) NE '#' Then Flag = True        ; Check for good data.
                                    
                                    jstart= strpos(data, " ", 0) +1                    ; The Live time is of only 3 Digit. 
                                    L_Time = Strn(Strmid(data, jstart,3))           ; Get the Live_Time
                                                                        
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
                                          
                                          ;Live Time Variables.
                                          Live_Time = FIX(L_Time)
                                          Tot_Live_Time= Tot_Live_Time + Live_Time
                                          Cnt_Live_Time++
                                        
                                          For j = jstart,SLen-4 Do Begin     
                                          
                                                  panode= FIX(strmid(data,j,2))                 ; Grab the Anode No.
                                                  p=panode-1
                                                  Temp_Pulse = FIX(strmid(data,j+2,4))-1
                                                  IF TFlag EQ True Then BEgin
                                                        If Temp_Pulse GT Thresh Then Begin
                                                                Pulse[p,Temp_pulse]++      ; Grab the Respective Pulse Height and store in respective, channel(count)
                                                        EndIF
                                                  EndIF Else Begin
                                                              Pulse[p,Temp_pulse]++
                                                  EndElse
                                                                                             ; increment the counter.
                                                  j = j+6
                                          EndFor
                                       
                                    EndIf  Else Begin
                                            Errorcount++
                                    EndElse
                                    ;====================================================
;                    EndFor ; End i ( Each Line )
                    If (Temp_Count mod 100000) EQ 0 Then Print, Temp_Count
                    EndWHile
                    
                    Avg_Live_Time[q] = Float(Tot_Live_Time)/Float(Cnt_Live_Time)                    ; Live Time for Each Source.
                    ;Now Build the Histogram and Input into the Anode_Histogram ( 3D Array)
                    For p = 0, 63 Do Begin
                              ;===== Work With the Pulse Height ( Select the right Row/column from 3-D
                              Pulse_height = lonarr(1024)
                              For i = 0, 1023 Do Pulse_Height[i] = Pulse[p,i]                     ; Moved all the Pulse Height to a smaller array. 
                              Hist = Pulse_Height
                              For j = 0, 1023 DO Begin
                                        Anode_Histogram(q, p, j) = Hist(j)
                              EndFor
                    EndFor
                    
                    ; ===========**Close File**=============
                    FREE_LUN, logicUnit                                       ; Closing the file 
              EndFor ; q ( Each Source)
              
             XFit = INDGEN(N_BINS)*(1024/N_BINS)
             
             ;======== = =========== *********DATA SELECTION AND PROCESSING******** ================== = =
                    ;****************************************************************
                    ;*  We have the 3-D Array with Sources, Anode and Pulse Counts  *
                    ;*  So, we extract those cleverly for plotting multiple Pages   *
                    ;****************************************************************
                    
               ; Just Making sure if the files are for the same Module.     
               M_Module = Module[0]
               For s = 0, NSrc-1 Do Begin
                        If M_Module NE Module[s] Then Begin
                              Print, 'ERROR :: SOURCES ACTING ON DIFFERENT MODULES'
                              RETURN
                        EndIf
                        If Src[s] EQ 'Back' then Back_Index = s       ; Get the Index of the Background Data.
               EndFor ;/s
               
               ;================    OUTPUT Begins ==============
               OutPutFolderName = OutPutFolderName + M_Module+'/'
               If Dir_Exist(OutputFolderName) EQ False Then File_MKdir, OutputFolderName   ; Create Folder if it Does Not Exist.
               
               For p = 0, 63 Do Begin                          ; Now we have extracted all the anode pulse heights. Now we process for Each Anode.
                        Anode = p+1

                        If (AllType EQ False) Then Begin      ; Triggers and check if we only look at one specific anode.
                                  If (Anode_Type NE AnodeType(Anode)) Then GOTO, JUMP1       
                        EndIf
                        
                        IF A_Log EQ True Then BEgin
                              Output_Image = M_Module+'_'+'Anode_'+Strn(Anode)+'_Energy_Cal_Plots_Log.ps'
                              Output_Text =  M_Module+'_'+'Anode_'+Strn(Anode)+'Energy_Cal_Values_Log.txt'
                        EndIf Else BEgin
                              Output_Image = M_Module+'_'+'Anode_'+Strn(Anode)+'_Energy_Cal_Plots.ps'
                              Output_Text =  M_Module+'_'+'Anode_'+Strn(Anode)+'Energy_Cal_Values.txt' 
                        EndElse
                         
              
                        ; GET THE BACKGROUND DATA TO SUBTRACT.
                        Back_Hist = LonArr(1024)
                        q = Back_Index
                        
                        For i=0,1023 Do Back_Hist[i] = Anode_Histogram[q,p,i]
                        Back_Scale = Float(Float(T_Mins[Back_Index])*Float(Avg_Live_Time[Back_Index])/Float(255))
                        
                        Set_Plot, 'ps'
                        LoadCt, 13
                        Device, File = OutPutFolderName + Output_Image 
                        For q = 0, NSrc-1 Do Begin

                                If AnodeType(Anode) EQ 0 Then X_MAX = 200 Else X_MAX = 200
                                
                                ;Create a Histogram and Store the X-Locations in XFIT                 
                                For i=0,1023 Do Hist[i] = Anode_Histogram[q,p,i]
                                Main_Hist = REBIN(Hist,N_Bins)
                                N_Scale = Float(Float(T_Mins[q])*Float(Avg_Live_Time[q])/Float(255))
                                N_Back = Float( Float(Back_Hist)*Float(N_Scale)/Float(Back_Scale))
                                
                                Hist1 = Main_Hist[2:N_Bins-1]
                                Xfit1 = Xfit[2:N_Bins-1]
                                
                                Back_Hist2 = N_Back[2:N_Bins-1]
                                ;Plot, XFIT1,Hist1, PSYM=10, Title = Src[q] + Strn(N_Bins), XRANGE=[0,1024], XStyle = 1
                                ;Subtract the Background
                                TitleName=''
                                If DFlag EQ TRUE Then TitleName ='C~P'
                                
                                
;                                
                                ;Plot, XFit1, Hist2, PSYM=10, Title='UNSCALED'+Src[q],XRANGE=[0,X_MAX],XSTYLE=1
                                
                                If( q NE Back_Index) Then Begin
                                               Hist1 = Hist1 - Back_Hist2
                                               ; Taking care of Logarithmic Scaling.
                                               If A_Log EQ True THen BEgin
                                                          For i =0, N_Elements(Hist1)-1 Do Begin
                                                                      IF Hist1[i] NE 0 Then Hist1[i] = ALog(Hist1[i])
                                                          EndFor
                                               EndIF           
                                               Plot, XFIT1,Hist1, PSYM=10, Title = Src[q]+'Scaled'+Strn(N_Bins)+TitleName,  XRANGE=[0,X_MAX],XSTYLE=1
                                               oplot, [0,1024],[0,0], Color=cgcolor('red')
                                EndIf
                                
                                
                               ; XYOUTS, 0, 0, 'Rates = '+Strn( Float(N_Elements(Hist2))/Float(T_Mins[q]*60) )
;                              Upp_Limit = N_Bins-1
;                              ; A Scale to connect the BIN Number to Channel No. That is seen and correct it for selection of data.
;                              B_SIZE = XFIT[2]-XFIT[1]  ; ( The Real Bin Size )
;                  
;                              ;==== Gaussian Fitting the Pulse Height==============
;                              D= Max(Hist[Low_Limit:Upp_Limit])      ; This selects the Max Height After the Low Limit.(Excluding Noise)
;                              B= Xfit[where(hist eq (Max(hist)))]   ; Get the Max Height ( XFit Location ).. 
;                              B_Index = (B-XFit[0])/B_Size          ; Getting the curent B's Array Index No.
;                              
;;                              If (B_Index-25) LE Low_Limit Then Min_Val = Low_Limit Else Min_Val = B_Index-30
;                              If (B_Index+25) GE Upp_Limit Then Max_Val = Upp_Limit Else Max_Val = B_Index+60
;                              
;                              ; Extract the Range of Data Interested In.
;                              Hist1 = Hist[Min_Val:Max_Val]
;                              Xfit1 = XFit[Min_Val:Max_Val]
;                              
;                              ;************************************************
;                              ;* Equation W.R.T to the Co-Efficients          * 
;                              ;* z = (x- A1)/A2                               * 
;                              ;* f(x) = A0*e^(-z*z/2) + A3 + A4*x + A5*x*x    * 
;                              ;* FWHM = 2* SQRT(2* ALOG(2))*A2                *
;                              ;************************************************ 
;
;                              ; Coefficients and initial estimates.
;                              a3= Hist1[Min_Val]
;                              a0= D-a3
;                              a1= B
;                              a2= FIX(B/2)
;                              a4= 0
;                              a5= 0
;                              
;                              For t=0,5 Do Begin         ; ( To get a better approx)
;                                    yfit = GAUSSFIT(XFIT1, hist1, coeff, NTERMS=6, ESTIMATES=[a0,a1,a2,a3,a4,a5], sigma=SIGMA)
;                                    a0= Coeff[0]
;                                    a1= Coeff[1]
;                                    a2= Coeff[2]
;                                    a3= Coeff[3]
;                                    a4= Coeff[4]
;                                    a5= Coeff[5]
;                              EndFor  
;                              
;                              ;==== PLOTTING======
;                          
;                              YMAX= MAX(hist)*1.15              ; Max size of the YRANGE
;                              
;                              N = N_Elements(hist)
;                              histerr = fltarr(N)                        ; Collection of errors.
;                              For i = 0, N-1 Do histerr[i]= SQRT(hist[i])
;                          
;                              plot,XFIT,hist,XTITLE = 'Channel No.',YTITLE = 'No. of Counts',Title = ' Anode = ' + Strn(p+1) ,$
;                                             yrange =[0,YMAX],PSYM=10,/NODATA, XSTYLE=1;, Charsize = 1.2, xrange =[0,1024]
;                              oplot,XFIT,hist, PSYM=10
                          ;oploterr,XFIT, hist, histerr,3
                 ;             oplot, XFIT1, YFIT, color=cgColor('blue')
;      
;                           Labelling: Graph OutPut.
;                          fwhm = StrN(2 * SQRT(2 * ALOG(2)) * coeff[2], FORMAT='(F0.2)')
;                          TotEvents = StrN(FIX(Total(Hist)))
;                          XYOUTS, 0,0, 'FWHM='+fwhm,charsize= 0.6, /DEVICE
;                          XYOUTS, 0, -20, 'Total Events='+TotEvents,charsize= 0.6, /DEVICE
;                          XYOUTS, 0, 20, 'Centroid ='+String(coeff[1], FORMAT='(F0.2)')+'+/-'+String(Sigma[1], FORMAT='(F0.2)'),charsize= 0.6, /DEVICE
                  EndFor ; q
;                  
                  Device, /Close
                  Set_Plot, 'x'
                  Print, Anode
;  ; Now do Energy Calibration         
;  ; Needs to get the parametric values and Calculate the Error.
                  Jump1:
;                
;                  
;                  
              EndFor ;p
; 
               ; Creating a Text file which needs to be changed to a executable file to change the ps to pdf file.
;                openw, Lunger, OutputFolderName+'/'+'convert_to_pdf' , /GET_LUN
;                    printf, Lunger, '# CONVERTS THE FILES TO PDF'
;                    printf, Lunger, '# Sambid Wasti'
;                    printf, Lunger, 'for f in FM*.ps'
;                    printf, Lunger, 'do'
;                    printf, Lunger, 'g=${f%.ps*}
;                    printf, Lunger, 'ps2pdf $f $g.pdf'
;                    printf, Lunger, 'done'
;                free_lun, LUnger   
 
End
