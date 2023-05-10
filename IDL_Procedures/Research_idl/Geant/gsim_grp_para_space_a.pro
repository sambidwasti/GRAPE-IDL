Pro Gsim_Grp_Para_Space_a, PSDArr, CorArr, SideArr

  CD, Cur = Cur
  
  ;
  ;Created this so that the processing of the CT and the rest of the files are separate.
  ;
;
;=== GAMMAS ===
;
  For temp_i =0,n_elements(PSDArr)-1 Do Begin
    For temp_j=0,n_elements(CorArr)-1 Do Begin
      For temp_k=0,n_elements(SideArr)-1 Do Begin
        PSD = PSDArr[temp_i]
        Cor = CorArr[temp_j]
        Side= SideArr[temp_k]

        ;
        ;================== MODELS =================
        ;

        ;
        ;------ GAMMAS------
        ;

        fsearch_str_gam = Cur+'/gammas/*gamma*.csv.dat'
        simfile_gamma = file_search(fsearch_Str_gam)
        foldername_gam=Cur+'/gammas/
        ; Gsim_Grp_CT_gam, simfile_gamma, PSD=PSD, Side=Side,Cor=Cor, foldername=foldername_gam


        
      EndFor
    EndFor
  EndFor
;Since Gsim para space was taking tons of time, and few issues.. dividing work this way makes it easier. 

;
;=== SEcondary ELECTRONS DOWN ====
;
For temp_i =0,n_elements(PSDArr)-1 Do Begin
  For temp_j=0,n_elements(CorArr)-1 Do Begin
    For temp_k=0,n_elements(SideArr)-1 Do Begin
      PSD = PSDArr[temp_i]
      Cor = CorArr[temp_j]
      Side= SideArr[temp_k]
      
      fsearch_str_secelecdown = Cur+'/SecElec/data_files_down/*SecDownElec*.csv.dat'
      simfile_secelecdown = file_search(fsearch_str_secelecdown)
      foldername_secelecdown = Cur+'/SecElec/data_files_down/'
      ;Gsim_Grp_CT_SecElec, simfile_secelecdown, PSD=PSD, Side=Side,Cor=Cor, foldername=foldername_secelecdown
      
    EndFor
  EndFor
EndFor


;
;=== SECONDARY ELECTRONS UP =====
;
For temp_i =0,n_elements(PSDArr)-1 Do Begin
  For temp_j=0,n_elements(CorArr)-1 Do Begin
    For temp_k=0,n_elements(SideArr)-1 Do Begin
      PSD = PSDArr[temp_i]
      Cor = CorArr[temp_j]
      Side= SideArr[temp_k]
      
      
      fsearch_str_secelecup = Cur+'/SecElec/data_files_up/*SecUpElec*.csv.dat'
      simfile_secelecup = file_search(fsearch_str_secelecup)
      foldername_seclecup = Cur+'/SecElec/data_files_up/'
      ;Gsim_Grp_CT_SecElec, simfile_secelecup, PSD=PSD, Side=Side,Cor=Cor, foldername=foldername_seclecup, Up=1

    EndFor
  EndFor
EndFor

;
;====== SECONDARY POSITRON DOWN =======
;
For temp_i =0,n_elements(PSDArr)-1 Do Begin
  For temp_j=0,n_elements(CorArr)-1 Do Begin
    For temp_k=0,n_elements(SideArr)-1 Do Begin
      PSD = PSDArr[temp_i]
      Cor = CorArr[temp_j]
      Side= SideArr[temp_k]
      
      fsearch_str_secposidown = Cur+'/SecPosi/data_files_down/*SecDownPosi*.csv.dat'
      simfile_secposidown = file_search(fsearch_str_secposidown)
      foldername_secposidown = Cur+'/SecPosi/data_files_down/'
     ; Gsim_Grp_CT_SecPosi, simfile_secposidown, PSD=PSD, Side=Side,Cor=Cor, foldername=foldername_secposidown

    EndFor
  EndFor
EndFor


;
;====== SECONDARY POSITRON UP ==========
;
For temp_i =0,n_elements(PSDArr)-1 Do Begin
  For temp_j=0,n_elements(CorArr)-1 Do Begin
    For temp_k=0,n_elements(SideArr)-1 Do Begin
      PSD = PSDArr[temp_i]
      Cor = CorArr[temp_j]
      Side= SideArr[temp_k]
      
      fsearch_str_secposiup = Cur+'/SecPosi/data_files_up/*SecUpPosi*.csv.dat'
      simfile_secposiup = file_search(fsearch_str_secposiup)
      foldername_secposiup = Cur+'/SecPosi/data_files_up/'
      Gsim_Grp_CT_SecPosi, simfile_secposiup, PSD=PSD, Side=Side,Cor=Cor, foldername=foldername_secposiup, UP=1

    EndFor
  EndFor
EndFor

;
;====== PRIMARY ELECTRONS ========
;
For temp_i =0,n_elements(PSDArr)-1 Do Begin
  For temp_j=0,n_elements(CorArr)-1 Do Begin
    For temp_k=0,n_elements(SideArr)-1 Do Begin
      PSD = PSDArr[temp_i]
      Cor = CorArr[temp_j]
      Side= SideArr[temp_k]
      
      fsearch_str_prielec = Cur+'/PriElec/*PriElectrons*.csv.dat'
      simfile_prielec = file_search(fsearch_str_prielec)
      foldername_PriElec = Cur+'/PriElec/'
      ; Gsim_Grp_CT_PriElec, simfile_prielec, PSD=PSD, Side=Side,Cor=Cor, foldername=foldername_PriElec
      
    EndFor
  EndFor
EndFor

;
;==== PRIMARY POSITRONS==-
;
For temp_i =0,n_elements(PSDArr)-1 Do Begin
  For temp_j=0,n_elements(CorArr)-1 Do Begin
    For temp_k=0,n_elements(SideArr)-1 Do Begin
      PSD = PSDArr[temp_i]
      Cor = CorArr[temp_j]
      Side= SideArr[temp_k]
      
      fsearch_str_priposi = Cur+'/PriPosi/*PriPositrons*.csv.dat'
      simfile_priposi = file_search(fsearch_str_priposi)
      foldername_PriPosi = Cur+'/PriPosi/'
     ;  Gsim_Grp_CT_PriPosi, simfile_priposi, PSD=PSD, Side=Side,Cor=Cor, foldername=foldername_PriPosi
    EndFor
  EndFor
EndFor

End