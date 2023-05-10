Pro Gsim_Spec_Gen_Flux_Neutron, file1, file2

  N = 100000
  ReadCol, file1,Ener,flux1, format='D,D'; This is the input flux file

  ReadCol, file2,Ener2,format='D' ; this is the output energy file

  bsize = 1E-5
  flux2 = CgHistogram(Ener2,locations=Xarr,binsize=bsize, /NAN)
  flux2 = flux2/bsize
  ; The neutron normalization constants
  scale_str = !PI*4     ; Isotropic so 4pi (sr)s
  scale_cons= [3.9402, 682.67, 102.87]   ; (MeV)
  Scl_val = scale_str*scale_cons
  Scl_Factor = scl_val * !PI* 1.20*1.20/N ;(m^2)

  ; for neutron 2
  Scale_Value = Scl_Factor[1]
  flux2_scaled =  Flux2* Scale_Value

 flux1_scaled = flux1*scale_str*!PI* 1.20*1.20
  window, 2
  CgPlot, Ener, Flux1, /Xlog, /ylog, Xtitle='Energy (MEV)' $
    , Yrange=[ 1E-3, 1E10 ], Xrange =[1E-8,1E2], $
    Title ='Neutrons Input Spec (Black) vs Sim Out (Red)', Ytitle='Counts / s / MeV'
  Cgoplot,Xarr, flux2, /Xlog, /ylog , Color='red', PSYM=10

  CgOplot, Xarr, flux2_scaled, /Xlog, /ylog , Color='green', PSYM=10
  
  CgOplot, Ener, flux1_scaled, /Xlog, /ylog , Color='navy'
  ;Print, Ener, Flux1


End