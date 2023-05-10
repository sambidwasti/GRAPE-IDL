Pro XSpec_Help0, infile, Ext=Ext

if Keyword_Set(Ext) Eq 0 Then Ext=1
  ; Read in about the input file.
  fits_info,infile,TextOut = txtout, N_Ext = next, ExtName = ExtName
  Print,'-------FILE INFO---------'
  Print, Txtout
  print, 'no. of ext',next, '**'
  print, Extname
  Print, '-------'


 h=''
  im = Readfits(infile,h,/noscale)
  print, '======================'
  Print, ' Primary '
  print,'h(header): '
  print, h
  print, 'im:'
  print, im
  print, '=================='

 

  ;Step 3
  Print, '=======Extension============'
  htab = ''
  tab = READFITS(infile,htab,Exten_no = Ext)
  print,'Extension Header:'
  print,htab
  print
  print,'Data:'
  print, tab
  print, '***************************'
  print, '***************************'

 For f = 1, next do begin
  

 a = mrdfits(infile, f,header)
for i = 0, n_elements(a)-1 do begin
    print, a[i]
endfor

 Endfor ;f

End