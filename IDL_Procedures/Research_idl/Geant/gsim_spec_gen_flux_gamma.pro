Pro Gsim_Spec_Gen_Flux_Gamma, file1, file2

  N = 100000
  ReadCol, file1,Ener,flux1, format='D,D'; This is the input flux file
  Print, flux1
; Col 1: MeV
; Flux photons/s/m^2/sr/MeV
;
  
  ReadCol, file2,Ener2,format='D' ; this is the output energy file

  bsize = 1E-2
  flux2 = CgHistogram(Ener2,locations=Xarr,binsize=bsize, Missing=0)
  flux2 = flux2/bsize
  ; this keeps the simulated as Counts/keV
  
  
  ; The Gamma normalization constants
  scale_str = [3.627,3.203,3.491,2.244] ; sr
  scale_cons= [15200,16800,18900,5710] ; photons / s/ m^2 / sr (After integrating the energy range)
  Scl_val = scale_str*scale_cons  ; 
  Scl_Factor = scl_val * !PI* 1.20*1.20 ; m^2
  
  ; Scl_factor: Photons /sec which is same as Photons in real world
  
  flux1_scaled = flux1*scale_str[0]*!PI* 1.20*1.20
  ; for Gamma1
  Scale_Value = Scl_Factor[0]/N  ; Ratio of Real World vs Simulated

  flux2_scaled =  Flux2* Scale_Value ; Real Output

  window, 2
  CgPlot, Ener, Flux1, /Xlog, /ylog, Xtitle='Energy (MEV)' $
    , Yrange=[ 1E-3, 1E9 ],XRange =[1E-2,1E3],$
     Title = 'Gamma Input Spectrum (Black) vs Geant generated(Red)',  YTitle='Counts / s/MeV'
  Cgoplot,Xarr, flux2, /Xlog, /ylog , Color='red', PSYM=10

  CgOplot, Xarr, flux2_scaled, /Xlog, /ylog , Color='green', PSYM=10
  
   CgOplot, Ener, flux1_scaled, /Xlog, /ylog , Color='navy'
  ;Print, Ener, Flux1


End