Pro Gsim_Grp_auto_plot, class=class, type=Type, Sep=Sep, title=title
;Trying to create an automated step to read in the l1 processed files. 
; and generate the com.txt files.
if keyword_set(Type) eq 0 then Type =0
if keyword_set(Sep) eq 0 then Sep =0
if keyword_set(Class) eq 0 then class =3
if keyword_set(Title) eq 0 then title1 = 'PSD90_Side0_Cor0' Else Title1=Title
gsim_grp_com_gamma, '*gamma*lvl1.dat',class=class, title=title1,Type=Type,Sep=Sep
close,/all
gsim_Grp_Com_Neutron, '*Neutron*lvl1.dat',class=class, title=title1,Type=Type,Sep=Sep
close, /all
GSim_GRP_com_sec_electron_down, '*SecDownElec*lvl1.dat', Class=class, title=title1,Type=Type,Sep=Sep
close, /all
GSim_GRP_com_sec_electron_up, '*SecUpElec*lvl1.dat', Class=class, title=title1,Type=Type,Sep=Sep
close, /all
GSim_GRP_com_sec_positron_down, '*SecDownPosi*lvl1.dat', Class=class, title=title1,Type=Type,Sep=Sep
close,/all
GSim_GRP_com_sec_positron_up, '*SecUpPosi*lvl1.dat', Class=class, title=title1,Type=Type,Sep=Sep
close,/all
GSim_GRP_com_sec_proton_down, '*SecDownPro*lvl1.dat', Class=Class, title=title1,Type=Type,Sep=Sep
close,/all
GSim_GRP_com_sec_proton_Up, '*SecUpPro*lvl1.dat', Class=Class, title=title1,Type=Type,Sep=Sep
close,/all
GSim_GRP_norm_pri_elec, '*PriElectrons*lvl1.dat',Class=Class, title=title1,Type=Type,Sep=Sep
close,/all
GSim_GRP_norm_pri_posi, '*PriPositrons*lvl1.dat',Class=Class, title=title1,Type=Type,Sep=Sep
close,/all
Gsim_Grp_norm_pri_prot,'*PriProtons*lvl1.dat',Class=Class, title=title1,Type=Type,Sep=Sep

End