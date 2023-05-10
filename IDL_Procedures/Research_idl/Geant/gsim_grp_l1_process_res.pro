Pro Gsim_Grp_l1_process_res,input, title=title
;
; This is basically the grp l1_process with additional information to automate the multiple response file all at once.
; One of the bigger issue is the renaming of the output file. 
;

PSD = 100
Cor = 0
Side = 0

if keyword_set(Title) EQ 0 then title='test' ; 


Gsim_Grp_l1_Process2, input, title=title,Psd=Psd , Per = Side, Cor= Cor

End