; Open and Read the Data File ( ASCII )
; Select the specific anode and its energy and work with it.
; Refer to readtextfile.pro and stringcheck.pro for assistance along with histogramm.pro
; Created a Pro called Rectangle that prints a rectangle where we want with given dimensions. 
; Also Created a Legend for labelling. 
; User Define or varying at the begining pointed out. 
; Sambid Wasti 5/23/13
; Sambid Wasti 5/24/13 Updated

pro readDataFiles

;   USER DEFINED VARIABLES                            ( Mostly changes done here )

    Anode = '03'                                              ; Anode no.
    
;   HISTOGRAM
    bins = 600                                                ; No. Of Bins

;   PLOT                                                      ; User Defined Plot Variables.
    YMIN = 0
    YMAX = 300
    XMIN = 0
    XMAX = 400
    H_Title = 'HISTOGRAM DATA'
    
;   File/ File Location    
    pathToFile="/Users/sam/IDLWorkspace80/Sam-Learning/"      ; PATH: Location of the Folder and Name in next line
    filename = String('0deg_Ba133.txt')                       ; Need to follow this route as in " the 0 has some function and it doesnt take it like a text.    
 
    imagename= String('Image.ps')
    
;   Legend Location
    XLegend = XMAX-100
    YLegend = YMAX-50
    SLegend = 1                                              ; Size of Text
       
       
; -------------**--------------**--------------------**----------------**-------------

;         --------** OPEN A FILE **-----------

    file = pathToFile+filename                                ; Location of the File. Useful for multiple.
    OPENR, logicUnit, file, /GET_LUN                          ; Open the file. A logicUnit assigned. GOt that from Get_Lun.
                                                              ; We could assign a value ourself and remove the /Get_lun
                                                              
;         --------** READ THE FILE **-----------                                                              
    rowsFile = FILE_LINES(file)                               ; We get the no. of rows from here.
    data = strarr(rowsFile)                                   ; data = Array of string with values for each line.
    READF, logicUnit, data                                    ; Read the file and dump everything in the String Array.
    
    SLen = 0                                                  ; Each String Length
    Ener = lonarr(rowsFile)
    c = 0
    For i = 0, rowsFile-1 Do Begin                            ; For loop to run for each of the Line/ String.
        SLen = strlen(data[i])                      
        
        For j = 9,SLen-4 Do Begin                             ; SLen-4 just to optimize it quicker as we are incrementing with the value of j=j+6, it doesnt matter either way.
            If Anode Eq strmid(data[i],j,2) Then Begin
                Ener[c] = long(strmid(data[i],j+2,3))
                c++
            EndIf 
           j = j+5                                            ; We are only doing j = j+5 instead of j + 6 because for loop increments 1 for us.                                           
        EndFor    
    EndFor

;         ------** CLOSING THE FILE **--------------
    FREE_LUN, logicUnit                                       ; Closing the file equivalent to freeing the long number( logic unit )
    
    
        
;       -------------** As our File length is huge and our array size is big but our actual array of Energy is small we want to move it to a shorter array and plot a histogram of it.
;       -------------** If we could create an array without defining it and which could change the size then it would not be necessary. Need to check whether we can do that or not.
    Energy = lonarr(c)
    For i = 0, c-1 Do Energy[i] = Ener[i]                     ; Moved all the energy to a small array.



;       -------------** BUILD THE HISTOGRAM  and Errors**-----------


    hist = Histogram(Energy, NBINS =bins)
    N = N_Elements(hist)
        help, Energy, Ener, Hist
    histerr = fltarr(N)                        ; Collection of errors.
    For i = 0, N-1 Do histerr[i]= SQRT(hist[i])
    
 ;/*** For Saving the color thing is giving trouble so removed it for now. Need to fix it. Even for Rectangle function    
    SET_Plot, 'ps'
    Device, File = pathToFile+imagename, /COLOR
    loadct, 13                                                ; Loading a color table 13 ( Rainbow Colors )
;       -------------** Plot the Histogram  **-----------    

    plot,INDGEN(bins) +1,hist,XTITLE = 'Bin number',YTITLE = 'Density',yrange =[YMIN,YMAX], xrange =[XMIN,XMAX],  title=H_Title, PSYM=10,/NODATA;background = white, col = black, /NODATA 
    oplot,hist, PSYM=10, color= cgColor('blue')
    oploterr,INDGEN(bins)-1, hist[INDGEN(N) -1], histerr[INDGEN(N) -1],3
 
;       ------------** LEGEND **----------------------
;    Rectangle, XLegend,YLegend,SLegend*35,SLegend*10, cgColor('black') 
    xyouts, XLegend+5, YLegend+5, 'Anode = '+Anode, color = cgColor('red'), Charsize =SLegend   

    Device, /CLOSE
    SET_PLOT, 'x'

print, cgColor('red')
                                    
       
 end