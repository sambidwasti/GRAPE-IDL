Pro gsim_arf_file, eff_file, var_file

;
; Read 2 files. 
; 1) Effective Area file 
; 2) A table file with sweep variables to get attenuation. 
; 
; Call attenuation_file 
;

ReadCol, Eff_file, Elo, Ehi, Area, $
  format='D,D,D'
  
ReadCol, var_file, Swp, Zen, Zen_err, Dep, Dep_err, Atm, Atm_err, $
   format='I,D,D,D,D,D,D'

nbins  = N_elements(Elo)
nfiles = N_elements(Swp)


for p =0, nfiles-1 do begin
  
    sweep = strn(Swp[p])
    FileName = 'Swp'+Sweep+'_at_arf.txt'
    Print, Filename
    Openw,lun1, filename, /get_lun 
    airmass = atm[p]
    New_area = DblArr(Nbins)
    Fact_arr = [0]
    for i = 0, nbins-1 do begin
        mass_atten = avg([air_attenuation(Elo[i]), air_attenuation(Ehi[i])])
        
        fact = exp(-mass_atten*airmass)
        
     ;   print,fact
     ;   Fact_Arr = [fact_arr,fact]
     
        New_area[i] = Area[i]*fact
        
        StrVal1 = Strn(Float(ELo[i])) + '  '+ Strn(Float(Ehi[i])) + '  '+Strn(New_area[i])
        Printf, Lun1, strval1

    endfor ; nbins
    Free_lun, lun1
    CgPlot,new_area
endfor

End