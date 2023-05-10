Pro XSpec_Help1
; Using this to understand mWRfits
; Protocol is create something, Write it and read and see how its written.


fits_info,'test.fits',TextOut = txtout, N_Ext = next, ExtName = Name

Print,'-------'
Print, Txtout
print, next
print, name

;
;
;PRint, 'Step 1: ===== Following Example ====='
a = FltArr(5,5)
a[*,*]=1
mwrfits,a,'test.fits',/CREATE

Print, 'STEP 2: 
Print, ' append a 3 column, 2row, binary table extension to file just created'
row = 10   ; data value?
a ={Character:'G',FloatNeg:34.890625, INtARr:[4,5,6] }
;NOTE : This  5.. is the size of the a.
b = replicate(a,row)
;help, b
print,'----'

mwrfits,b,'test.fits'

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
print

print,'htab:'
print,htab
print
help, a
print, 'Struc :'
print, a
print,'tab:'
print, tab



End