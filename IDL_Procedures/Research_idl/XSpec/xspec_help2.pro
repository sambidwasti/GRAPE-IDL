Pro XSpec_Help2
  ; Using this to understand mWRfits
  ; Protocol is create something, Write it and read and see how its written.
  ; This is similar to Help1 but now we are setting one structure and adding in a loops

  ;
  ;
  ;PRint, 'Step 1: ===== Following Example ====='
  a = FltArr(5,5)
  a[*,*]=1
  mwrfits,a,'test.fits',/CREATE

  vararr=[0.0]
  a ={Character:'a', NegInt:-526,PosInt:526,FloatPos:0.0,FloatNeg:0.0, DoublePos:0.0D,DoubleNeg:0.0D ,INtARr:[0,0], VarArray:vararr }

  Print, 'STEP 3:
  Print, ' append a 3 column, 2row, binary table extension to file just created'
  row = 10  ; data value?
  
  ;replicate(a,row)
;help, b


  b =a
  vararr1 = [0.0]
  for i = 0, row-1 do begin
     c = replicate(a,1)
     c.character = 'row'+Strn(i)
     help, c
     c.vararray = vararr
      
 
     b = [b,c]
    
  endfor
  b=b[1:n_elements(b)-1]
  help, b
  mwrfits,b,'test.fits'
  ;NOTE : This  5.. is the size of the a.

  print,'----'

fits_info,'test.fits',TextOut = txtout, N_Ext = next, ExtName = Name

Print,'-------'
Print, Txtout
print, next
print, name



;  FITS_INFO, Filename, [ /SILENT , TEXTOUT = , N_ext =, EXTNAME= ]


  h=''
  im = Readfits('test.fits',h,/noscale)
  print
  print, 'im = Readfits(infile,h,/noscale)'
  print,'h(header): ', h
  print
  print
  print, 'im:'
  print, im
  print
  print
  print, '=================='
  htab = ''
  tab = READFITS('test.fits',htab,/EXTEN)
  print, 'tab = Readfits(infile,htab,/EXTEN)'




  print,'htab:'
  print,htab
  print
  print, '{Character:'+'GRAPE23'+',NegInt:-7,PosInt:7,  FloatPos:1.9,FloatNeg:-1.9,DoublePos:1.5D,DoubleNeg:-1.5D ,INtARr:[4,5,6] }'
  print,'tab:'
  print, tab



End