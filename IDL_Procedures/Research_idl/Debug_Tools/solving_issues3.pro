Pro Solving_Issues3


;a = [5,15,25,35,45,55,85]
;b= !DtoR*a
;y = cos(b)
;x = (1-y)/2
;;print, x
;
;c = 1/cos(b)
;print, c
;
;d = [0,10,20,30,40,50,60,90]
;e= !DtoR*d
;print, e

;Scl_val = [395.50583,4.07616, 0.345251]
;Scl_Factor = scl_val * 2* !PI *!PI* 1.20*1.20     ; This is 1.2 and not 120 for the m^2 and only hemisphere steradian(6.2832 = 2 Pi) 0~90
;print, scl_factor
;
;scale_str = [3.627,3.203,3.491,2.244]
;scale_cons= [1.52,1.68,1.89,0.571]
;
;Scl_val = scale_str*scale_cons
;Scl_Factor = scl_val * !PI* 120*120
;
;Print, Scl_Factor
;
;
;Ener = 2199.0; (kev)
;Temp_Alpha = Gsim_Grp_Equi_Nrg_Alpha(Ener)
;
;Temp_Prot = Gsim_Grp_Equi_Nrg_Proton(Ener)
;
;Print, ' Ener (keV) =', Ener
;Print, ' Prot (keV) =', Temp_PRot
;PRint, ' Alph (keV) =', Temp_Alpha

;print,Gsim_Grp_Equi_Nrg_Alpha(100)

;print, grp_anode_Separation(8,9)

PSD     = [95];,95,95,95,95,95,95];,90,90,90,90,90,90,90,90,90,90]
PerSide = [6];, 6, 7, 7,  7, 7, 7];, 6, 6, 0, 2, 4, 6, 8,10,12,14]
CorSide = [2];, 1, 1, 2,  3, 4, 5];,12,14, 2, 2, 2, 2, 2, 2, 2, 2]

for q = 0, N_elements(PerSide)-1 Do begin
Gsim_Grp_l1_Process2,'*csv.dat',PSDeff=PSD[q],Per=PerSide[q],Cor=CorSide[q]

Close,/all


EndFor

End