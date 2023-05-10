Pro gsim_arf_file_one, eff_file, var_file
;
; Read 2 files. 
; 1) Effective Area file 
; 2) Files with various parameters
; This is to create one main output Grp File from average values of the parameters from second file
; Call attenuation_file 
;

ReadCol, Eff_file, Elo, Ehi, Area, $
  format='D,D,D'
  
ReadCol, var_file, Swp, Zen, Zen_err, Dep, Dep_err, Atm, Atm_err, $
   format='I,D,D,D,D,D,D'

nbins  = N_elements(Elo)

Zen = Avg(Dep)
AirMass = Avg(Atm)
  

    FileName = 'Grp_Arf_1file_at_arf.txt'
    Print, Filename
    
    Openw,lun1, filename, /get_lun 
		New_area = DblArr(Nbins)
    	for i = 0, nbins-1 do begin
        	mass_atten = avg([air_attenuation(Elo[i]), air_attenuation(Ehi[i])])
        	fact = exp(-mass_atten*airmass)
		 
        	New_area[i] = Area[i]*fact
        
            StrVal1 = Strn(Float(ELo[i])) + '  '+ Strn(Float(Ehi[i])) + '  '+Strn(New_area[i])
        	Printf, Lun1, strval1

    endfor ; nbins
    Free_lun, lun1
    
    CGPLOT, AREA
    CGOPLOT, NEW_AREA, color='blue'

End