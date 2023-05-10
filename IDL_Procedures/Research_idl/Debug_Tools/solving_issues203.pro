Pro SOlving_ISsues203
; Checking few angles

; Scat Angles

;vec1= [50,60,70,80]
;vec = [2,5,8,10]
;; Compute location of other values within
;; that vector.
;loc = VALUE_LOCATE(vec, [0,3,5,6,12])
;print, loc
;print, vec[-1]
; print, vec[loc]
;
;for i = 0, 32 do begin
;  Print, 'Mod=',i,'--', Grp_moduleXy(i)
;  
;endfor
;
;for i = 0, 63 do begin
;   Print, 'An=',i,':::', Grp_anodeXy(i)
; 
;  
;endfor
;for i = 0,64 do print, grp_anodexy(i)
;print
;
;for i = 0,64 do begin
;print, 'sim:', i, 'ins:',grp_sim_anode_map(i), 'cord:',grp_anodexy(grp_sim_anode_map(i))
;endfor

an1 = 27
an2 = 0
print, an1, an2
print, grp_scatang(0,an1,0,an2)

an1a = grp_sim_anode_map(an1)
an2a = grp_sim_anode_map(an2)

print, an1a, an2a
print, grp_scatang(0,an1a,0,an2a)

End