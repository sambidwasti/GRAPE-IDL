Pro Gsim_Spec_Gen_Flux, file1, file2
;
; This started for  a random file format and then expanded for few of the components.
;

ReadCol, file1,Ener,flux1, format='D,D'; This is the input flux file

ReadCol, file2,Ener2,format='D' ; this is the output energy file

bsize = 1E-4
flux2 = CgHistogram(Ener2,locations=Xarr,binsize=bsize, /NAN)
flux2 = flux2/bsize


window, 2
CgPlot, Ener, Flux1, /Xlog, /ylog, Xtitle='Energy (MEV)' $
      , Yrange=[ 1E-3, 1E9 ]
Cgoplot,Xarr, flux2, /Xlog, /ylog , Color='red', PSYM=10

;Print, Ener, Flux1


End