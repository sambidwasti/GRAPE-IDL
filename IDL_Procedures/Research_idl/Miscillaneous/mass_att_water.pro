pro mass_att_water, file

; File format : Energy, Mass attenuation coeff, mass-energy attenuation coeff.
; MEV, cm^2/g
Readcol, file, Ener, mass_coef, ener_coef, format='D,D,D'

print, ener, mass_coef

cgplot, Ener*1000.0D, Mass_Coef, /xlog, /ylog, xrange=[1,20000]

end