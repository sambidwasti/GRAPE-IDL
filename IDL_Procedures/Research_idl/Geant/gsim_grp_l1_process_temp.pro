Pro Gsim_Grp_l1_process_temp, fsearch_String, title=title

; Current optimized values
PSD = 95
Side = 6
Cor =2
if keyword_set(Title) Eq 0 then Title = '' ; this is 0 but we have set the ct to be 15%

GSim_GRP_l1_process2a, fsearch_String, title=title, PSDeff=PSD, Per=Side , Cor = Cor

end