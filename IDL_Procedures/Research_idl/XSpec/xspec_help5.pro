Pro XSpec_Help5, infile, matrix_File
  ; basically trying to add in to xspec help 4. 
  ; here trying to format a matrix file into relevant data structure.

  clear
  newfile = 'test1.rsp'
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
  Print, Ebound_Ext, '***********EBOUND EXT*************'
  a = mrdfits(infile, Ebound_ext,header)
  for i = 0, n_elements(a)-1 do begin
    print, a[i]
  endfor
  Print, Matrix_Ext , '*********MATRIX************'
  a = mrdfits(infile, Matrix_ext,header)
  for i = 0, n_elements(a)-1 do begin
    print, a[i]
  endfor

 
 
  ;Step 3
  Print, '========== STEP 3 ============='
  Print, 'Matrix '
  htab = ''

  tab = READFITS(infile,htab,Exten_no = Matrix_Ext)
  print,'Matrix Header:'
  print,htab
  print
  print,'Matrix Data:'
 ; print, tab
  print, '================'

print
print, '&&&&&&&&&&&&&&'
 a = mrdfits(infile, 2,header)
;for i = 0,n_elements(a)-1 do print, a[i]

;Defining a structure:
Struc = { Elow: 0.0, Ehigh:0.0, Ngrp:0, Fchan:0L, NChan:LonArr(4), Matrix:FltArr(4)}
ReadCol, Matrix_File, format='F,F,F,F,F,F',E_lo,E_hi,Mat1,Mat2,Mat3,Mat4,count=ngood
print, ngood
  newarr = replicate(Struc,ngood)
  for i = 0, ngood-1 do begin
      newarr[i].Elow = E_lo[i]
      newarr[i].Ehigh = E_hi[i]
      
      EArr = [Mat1[i],Mat2[i],Mat3[i],Mat4[i]]
      
      Matrix_loc = where(Earr NE 0.0, count)
      Matrix_Val = Earr[Matrix_Loc]
      fchan = Matrix_loc[0]


     newarr[i].ngrp = count
     newarr[i].fchan = fchan
     newarr[i].nchan = Matrix_loc
     newarr[i].Matrix = Matrix_val

    
  endfor
print, newarr[0]
print, newarr[1]
print, newarr[2]


;Step 3
;Read EBOUNDS and PRINT EBOUNDS EXTENSION
Print, '========== STEP 4 ============='
Print, 'We Have Matrix. Now read the header and write this data '
mat_head = ''

mat_dat = READFITS(infile,mat_head,Exten_no = Matrix_Ext)
print,'Mat head:'
print,mat_head
print
print,'Mat Data:'
print, mat_dat
print, '================'

 mwrfits,newarr,newfile,mat_head

;  openr, lun1, Matrix_file, /Get_Lun
;  data = ''
;    Readf, Lun1, data
;    print, data
;    While Not Eof(lun1) do begin
;      readf, lun1, data
;      print,data
;      
;    EndWhile
;  free_Lun, Lun1
  
  
  ;
  ;== First Read in the Matrix file
  ;

;  b =a
;  vararr1 = [0.0]
;  for i = 0, row-1 do begin
;    c = replicate(a,1)
;    c.character = 'row'+Strn(i)
;    help, c
;    c.vararray = vararr
;
;
;    b = [b,c]
;
;  endfor
;  b=b[1:n_elements(b)-1]
;  help, b
;  mwrfits,b,'test.fits'
;  ;NOTE : This  5.. is the size of the a.
;
;  print,'----'
;
;  fits_info,'test.fits',TextOut = txtout, N_Ext = next, ExtName = Name
;
;  Print,'-------'
;  Print, Txtout
;  print, next
;  print, name
;
;
;
;  ;  FITS_INFO, Filename, [ /SILENT , TEXTOUT = , N_ext =, EXTNAME= ]
;
;
;  h=''
;  im = Readfits('test.fits',h,/noscale)
;  print
;  print, 'im = Readfits(infile,h,/noscale)'
;  print,'h(header): ', h
;  print
;  print
;  print, 'im:'
;  print, im
;  print
;  print
;  print, '=================='
;  htab = ''
;  tab = READFITS('test.fits',htab,/EXTEN)
;  print, 'tab = Readfits(infile,htab,/EXTEN)'
;
;
;
;
;  print,'htab:'
;  print,htab
;  print
;  print, '{Character:'+'GRAPE23'+',NegInt:-7,PosInt:7,  FloatPos:1.9,FloatNeg:-1.9,DoublePos:1.5D,DoubleNeg:-1.5D ,INtARr:[4,5,6] }'
;  print,'tab:'
;  print, tab
;
;
;
End