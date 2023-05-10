; HISTOGRAM EXAMPLE AND RELATED FUNCTIONS AND FEATURES
; Interesting Issue with Colors.
; Use of User Defined Rectangle Function.
; PROBLEM with customizing the histogram. Understand the Bin and NBIN here to some extent.
; Using OPLOTERROR or oploterror which is a modified oploterr function to add color. Modify as needed.
; Adding text to the graph for future legends.
; Sambid Wasti 5/21/13
; Sambid Wasti 5/22/13    Updated
; Sambid Wasti 5/24/13    Updated
; Careful about REBIN and CONGRID.. THE WAY YOU BIN 
PRO histogramm

            ;---** Defining Colors ** ---- 24 Bit
    red     = '0000FF'x
    green   = '00FF00'x
    blue    = 'FF0000'x
    yellow  = '00FFFF'x
    purple  = 'FF00FF'x
    black   = '000000'x
    white   = 'FFFFFF'x
            ;---**-----------------** ----for more colors: http://www.yellowpipe.com/yis/tools/hex-to-rgb/color-converter.php
            ; Remember that the colors are more so defined in hexa decimal of 2values. _ _ Blue  _ _ Green  _ _ red
            ; Some places those are switched.
            
    data = [5.2,5.1,5.4, 4.2,4.2,4.3,1.1,4.7,4.8, 2, 8, 1,7,7, 5, 3, 2.2, 17.5,18.4,19.1,10.2,10.2 , 10, 15, 2, 5, 7, 6, 20, 13, 12]   ; Generating a random Data
        
    hist = HISTOGRAM(data,NBINS=20)                                             ; Using a Histogram Function to see what happens.
                                                                                ; Can specify the NBINS= No. of bins or Binsize here.
                                                                                
    Print, N_ELEMENTS(data)                                                     ; The data has 20 Elements
    ;Print, data[INDGEN(19)]                                                    ; The data 
    Print, MIN(data)
    
    Print, ' --**HIST**---'
    Print, N_ELEMENTS(hist)                                                     ; The Histogram has 36 elements.. 
                                                                                ; This No. of elements are total numbers in the Histogram function from 1 to 21 in our case. 
    Print, MAX(data)- MIN(data) +1                                              ; So N_Elements = Max - Min from the data and the bins are each 1 unit apart.
    Print, MIN(hist)                                                            ; Minimum occurance or Min Frequency
    Print, MAX(hist)                                                            ; Maximum Frequency
   
    ; ------------------**-------------------**------------------
    ; **-- Creating windows help get two different Histograms.
    ; **-- Carefull Tricky Stuffs.
   
    ;window,2                                                                     ; Creating a window. Usually you do it for different data on different window.
    
    plot,hist,XTITLE = 'Bin number',YTITLE = 'Density',  title=' HISTOGRAM OF THE DATA',/NODATA; PSYM=10,background = white, col = black, /NODATA 
            
                                                                                                          ; For help look at plot procedure by going to index and typing plot
                                                                                                          ; New use of plot and the FLAG NODATA, Useful to plot different plots
                                                                                                          ; Usually you want to plot everything so that you have the range you need. You can also fix the X SCale and Y Scale
                                                                                                          ; But you need to plot something (hist) to make the syntax right.
 ;                                                                                                         ; PSYM refers to Histogram. Look for other reference of PSYM in the help command.
    oplot,hist, PSYM=10, col= cgColor('RED')                                                                        ; OverPlot in this plot command.
   
    ; ------------------** Lets Try plotting errors **
    Err = Fltarr(20)
    For i = 0, 19 Do Err[i] = 0.1
 ;  oploterr, X, Y, Yerr, PSYM ( 1~6 ) 
 ;                       1 = Creates a Gap around the value
 ;                       2 = - " -
 ;                       3 = It overlaps removing the gap
 ;                       4 = a dash and the error bar on it
 ;                       5 = - " -
 ;                       6 = Cant Tell  
 ;                       7 = Cant Tell                                 
 ;  
    oploterr, hist, Err[INDGEN(20)],4                    ; We have x and y 
   printanode = 'Anode ='
;   xyouts, 10, 2.5, printanode , Charsize = 3,color= red;,/DEVICE                           ;LEgends. or adding text to the graph.
;   rectangle,10,2,5,1,red 
print, hist
print, n_elements(hist) 
 
 
   stop
END