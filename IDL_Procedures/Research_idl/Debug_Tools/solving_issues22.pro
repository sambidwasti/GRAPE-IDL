pro Solving_ISsues22

psd=[91]
side =  [1,2,3,4,6,8,10,12,14]
cor  = [11,13,15]

For i = 0,N_elements(side)-1 do begin
   For j=0, N_Elements(Cor)-1 do begin
     temp_str = 'Side_'+Strn(side[i])+'Cor_'+Strn(cor[j])+'*'
     temp_title='PSD91_Side'+Strn(side[i])+'_Cor'+Strn(Cor[j])
     
     gsim_grp_l1_com_gamma1, temp_str, Title=temp_title
 temp_title='PSD91_Side'+Strn(side[i])+'_Cor'+Strn(Cor[j])
     gsim_grp_l1_com_gamma1, temp_str,Title=temp_title,Type=1

 temp_title='PSD91_Side'+Strn(side[i])+'_Cor'+Strn(Cor[j])
     gsim_grp_l1_com_gamma1, temp_str, Title=temp_title,Type=2
 
 temp_title='PSD91_Side'+Strn(side[i])+'_Cor'+Strn(Cor[j])
     gsim_grp_l1_com_gamma1, temp_str,Title=temp_title,Type=3
     
   Endfor
Endfor


End