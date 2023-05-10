Pro Solving_Issues121, infile

newfile= 'what.fits'
fits_info,infile,TextOut = txtout, N_Ext = next, ExtName = ExtName
htab =''
tab = READFITS(infile,htab,Exten_no = 1)
mwrfits,tab,infile,htab ; adding in the spectrum.

 ; tab = READFITS( infile, htab, /EXTEN )
  ;
  fits_info,infile,TextOut = txtout, N_Ext = next, ExtName = ExtName

 ; mwrfits,im,newfile,h,/CREATE   ; Create an image


Stop
End