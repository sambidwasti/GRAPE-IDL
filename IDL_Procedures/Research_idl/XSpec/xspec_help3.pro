Pro XSpec_Help3, infile
 ; Applying the fits_info to extract the Extension info.
  ; Protocol is create something, Write it and read and see how its written.
  ; == Read fits file.
  ; = Read, modify and rewrite headers.
  ; 
  ; fits_info
  ; readfits
  ; headfits
  ; xsaddpar
  ; modfits
  ;
  ;

  fits_info,infile,TextOut = txtout, N_Ext = next, ExtName = Name

  Print,'-------'
  Print, Txtout
  print, next
  print, name


  h=''
  im = Readfits(infile,h,/noscale)
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
  tab = READFITS(infile,htab,Exten_no = 1)
  print, 'tab = Readfits(infile,htab,/EXTEN)'
  print

  print,'htab:'
  print,htab
  print
  print, 'Struc :'
  print,'tab:'
  print
  print
  print, '================'
 ; print, tab


  fitheads = headfits(infile,Exten=1)
  sxaddpar, fitheads, 'RESPFILE','testspec1.rsp'
  modfits,infile,0,fitheads,Exten_no=1
  help, fitheads
  print
  print
  print, fitheads

End