Pro XSpec_Help4, infile
  ; Goal 1:
  ; We are only reading rsp file here atm.
  ; Read the Primary, Ebounds and the Matrix file fo the rsp file. 
  ; Create another rsp file with teh same primary and Ebounds.
  ;
  ; fits_info
  ; readfits
  ; headfits
  ; xsaddpar
  ; modfits
  ;
  ;
  clear
  newfile = 'test1.rsp'
  
  ; Step 1: Read in the file and get the file informations.
  ; Read in about the input file.
  fits_info,infile,TextOut = txtout, N_Ext = next, ExtName = ExtName
  Print,'------- STEP 1---------'
  Print, Txtout
  print, next, '**'
  print, Extname
  Print, '-------'
  

  ;
  ;Step 2 : Read Primary File and Replicate the Primary File
  ;
  h=''
  im = Readfits(infile,h,/noscale)
  print, '==============Step2==========='
  Print, ' Primary '
  print,'h(header): '
  print, h
  print, 'im:'
  print, im
  print, '=================='
   mwrfits,im,newfile,h,/CREATE ; Creating a new file
   a = mrdfits(infile, 1,header)
   for i = 0, n_elements(a)-1 do begin
     print, a[i]
   endfor
   

   a = mrdfits(infile, 1,header)
   for i = 0, n_elements(a)-1 do begin
   ;  print, a[i]
   endfor
   print,'Spectrum'
  print, header
   ;===Response

    ;
    ; = Need to figure out extension name to Ebounds and matrix.
    ;
    Ebound_Ext = 0
    Matrix_Ext = 0
    Help, ExtName
    Print, ExtName
    
    ExtName1 = StrCompress(ExtName,/REMOVE_ALL)
    For i = 0,Next Do begin
       If ExtName1[i] eq 'EBOUNDS' Then Ebound_Ext = i
       If ExtName1[i] eq 'MATRIX'  Then Matrix_Ext = i
    Endfor
    ; We have teh respective extension values
    Print, Ebound_Ext
    Print, Matrix_Ext


    ;Step 3
    ;Read EBOUNDS and PRINT EBOUNDS EXTENSION
    Print, '========== STEP 3 ============='
    Print, 'EBounds Extension Read and Write '
    htab = ''
    a = mrdfits(infile, Ebound_Ext,header)
    for i = 0, n_elements(a)-1 do begin
      print, a[i]
    endfor
    tab = READFITS(infile,htab,Exten_no = Ebound_Ext)

    
    mwrfits,tab,newfile,htab ; Creating a new file
 
 SampleM = FltArr(5,5)
 For i = 0,4 do begin
  For j = 0,4 do Begin
    If i lt j then SampleM[i,j] = randomu(seed,1)
  Endfor
 Endfor
 Print, SampleM
 
 
    ;Step 4
    ;Read Matrix and add the matrix to the MATRIX EXTENSION
    ; Note the header is the same as before
    ; Only the data changes. 
    ; Worry on data format.
    ; 
    Print, '========== STEP 4 ============='
    Print, 'Matrix Extension and header Read and Write '
    htab2 = ''
    tab2 = READFITS(infile,htab2,Exten_no = Matrix_Ext)
    print,'Matrix Header:'
    print,htab2
    print
    print,'Matrix Data:'
    print, tab2
    print, '======Now in Ascii=========='
    a = mrdfits(infile, Matrix_Ext,header)
    for i = 0, n_elements(a)-1 do begin
      print, a[i]
    endfor
    
    

  ;
  ;  mwrfits,tab,newfile,htab2 ; Creating a new file
 
 
   PRINT, '**********************'
   ;xspec_help0, newfile, Ext=1
  ; xspec_help0,infile,Ext=1


End