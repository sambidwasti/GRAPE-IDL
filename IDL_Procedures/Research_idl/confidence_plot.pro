Pro Confidence_Plot, File, title=title
; This is created to take in the StepPar data from XSPEC and plot a contour plot. 
; Note: We get the Chisquare array which is a 2D array. 
; The array size is 1 + no of steps as it counts 0,0 as well.
; So we need to read one line at a time. 
; Always double check steppar val. Currently set for 1-2.5 500 alpha vs 0-18 500

N= 500 ; Dimension of the chi-fit. Assumed square points.
;== Read the file ==
;Read one line at a time.
Openr, lun, file, /get_lun
 data = ''
 ;== 2 Skipped line
 readf, lun, data
 readf, lun, data
 
 temp_array = FltArr(N+1)
 readf, lun, temp_array
 MainArray = transpose(Temp_array)
 help, mainarray
 
 While NOT EOF(lun) DO BEGIN
 temp_array = FltArr(N+1)
 readf, lun, temp_array
 MainArray = [MainArray,transpose(Temp_array)]
 ;help, mainarray
 ENDWHILE 
 
Free_lun, lun      
XArray = FINDGEN(N+1)*0.003 +1
YArray = FINDGEN(N+1)*0.036
Mainarray1=transpose(Mainarray)
LevelsArray = [30.443,32.753,37.353]
levelsStyle = [0,1, 3]
;color= cgPickColorName()
;print, color
;LevelColor = ['Red','Slate Blue','Dodger Blue'];,'Lawn Green',]
CgContour, MainArray , Xarray, YArray, Levels=LevelsArray, Label=0;, C_Colors=LevelColor
CgOplot,1.70480, 1.01537,PSYM=1, charsize=10

CGPS_open, 'Confidence_Plot.ps',/Landscape
CgContour, MainArray , Xarray, YArray, Levels=LevelsArray, Label=0, XRange=[1,2.5],yrange=[0,18],xstyle=1,ystyle=1;, C_Colors=LevelColor
;CgOplot,1.70480, 1.01537,PSYM=1, charsize=2, color='CYAN'

CGPS_Close
CgPS2Pdf, 'Confidence_Plot'+'.ps', delete_ps=1, UNIX_CONVERT_CMD='pstopdf'

End