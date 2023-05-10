Pro Gsim_Grp_Para_Space


;Change Logs
;September 25
;     - Changing few loops order so that processing happens first.
;     - then Combined, etc.
;
;

;
;================ INITIAL PARAMETER/VARIABLE DEFINITIONS ==================
;
;

; -----Energy Selection-----
  Min_Ener = 70
  Max_Ener = 300
  
  
; ------Flight Files------
; Bins of 10
flt_all = '/Users/Sam/Work/Sam_programming/GEANT4_Stuffs/GRAPEv8_2014-build/Grp8_Cur_work/Flight_Bin_10/10_40_l2v7_inv3_rebin.txt'
flt_typ1= '/Users/Sam/Work/Sam_programming/GEANT4_Stuffs/GRAPEv8_2014-build/Grp8_Cur_work/Flight_Bin_10/10_40_Type1_l2v7_inv3_rebin.txt'
flt_typ2= '/Users/Sam/Work/Sam_programming/GEANT4_Stuffs/GRAPEv8_2014-build/Grp8_Cur_work/Flight_Bin_10/10_40_Type2_l2v7_inv3_rebin.txt'
flt_typ3= '/Users/Sam/Work/Sam_programming/GEANT4_Stuffs/GRAPEv8_2014-build/Grp8_Cur_work/Flight_Bin_10/10_40_Type3_l2v7_inv3_rebin.txt'
  
; ----- Parameters --------  
  PSDArr = [91]
;  CorArr = [4,8,12,16,20]
;  SideArr   = [4,8,12,16,20]
CorArr = [5]
SideArr=[10]
  CD, Cur = Cur
;  Gsim_Grp_Para_Space_a, PSDARr, CorArr, SideArr
For temp_i =0,n_elements(PSDArr)-1 Do Begin
  For temp_j=0,n_elements(CorArr)-1 Do Begin
    For temp_k=0,n_elements(SideArr)-1 Do Begin
      PSD = PSDArr[temp_i]
      Cor = CorArr[temp_j]
      Side= SideArr[temp_k]
      
      Temp_Title =    'PSD_'+Strn(PSD)+'_Side_'+Strn(Side)+'_Cor_'+Strn(Cor)
      
      ;GAMMAS
      Gamma_com_all = cur+'/gammas/TypeAll/'+Temp_Title+'_l1_gamma_com.txt'
      Gamma_com_T1 = cur+'/gammas/Type1/'+Temp_Title+'_Type_1_l1_gamma_com.txt'
      Gamma_com_T2 = cur+'/gammas/Type2/'+Temp_Title+'_Type_2_l1_gamma_com.txt'
      Gamma_com_T3 = cur+'/gammas/Type3/'+Temp_Title+'_Type_3_l1_gamma_com.txt'

      ;Secondary Electrons Up
      Sec_Elec_Up_all = cur+'/SecElec/data_files_up/TypeAll/'+Temp_Title+'_l1_SecUpElec_com.txt'
      Sec_Elec_Up_T1  = cur+'/SecElec/data_files_up/Type1/'+Temp_Title+'_Type_1_l1_SecUpElec_com.txt'
      Sec_Elec_Up_T2  = cur+'/SecElec/data_files_up/Type2/'+Temp_Title+'_Type_2_l1_SecUpElec_com.txt'
      Sec_Elec_Up_T3  = cur+'/SecElec/data_files_up/Type3/'+Temp_Title+'_Type_3_l1_SecUpElec_com.txt'
      
      ;Secondary Electrons Down
      Sec_Elec_Down_all = cur+'/SecElec/data_files_down/TypeAll/'+Temp_Title+'_l1_SecDownElec_com.txt'
      Sec_Elec_Down_T1  = cur+'/SecElec/data_files_down/Type1/'+Temp_Title+'_Type_1_l1_SecDownElec_com.txt'
      Sec_Elec_Down_T2  = cur+'/SecElec/data_files_down/Type2/'+Temp_Title+'_Type_2_l1_SecDownElec_com.txt'
      Sec_Elec_Down_T3  = cur+'/SecElec/data_files_down/Type3/'+Temp_Title+'_Type_3_l1_SecDownElec_com.txt'
      
      ;Secondary Positrons Up
      Sec_Posi_Up_all = cur+'/SecPosi/data_files_up/TypeAll/'+Temp_Title+'_l1_SecUpPosi_com.txt'
      Sec_Posi_Up_T1  = cur+'/SecPosi/data_files_up/Type1/'+Temp_Title+'_Type_1_l1_SecUpPosi_com.txt'
      Sec_Posi_Up_T2  = cur+'/SecPosi/data_files_up/Type2/'+Temp_Title+'_Type_2_l1_SecUpPosi_com.txt'
      Sec_Posi_Up_T3  = cur+'/SecPosi/data_files_up/Type3/'+Temp_Title+'_Type_3_l1_SecUpPosi_com.txt'
      
      ;Secondary Positrons Down
      Sec_Posi_Down_all = cur+'/SecPosi/data_files_down/TypeAll/'+Temp_Title+'_l1_SecDownPosi_com.txt'
      Sec_Posi_Down_T1  = cur+'/SecPosi/data_files_down/Type1/'+Temp_Title+'_Type_1_l1_SecDownPosi_com.txt'
      Sec_Posi_Down_T2  = cur+'/SecPosi/data_files_down/Type2/'+Temp_Title+'_Type_2_l1_SecDownPosi_com.txt'
      Sec_Posi_Down_T3  = cur+'/SecPosi/data_files_down/Type3/'+Temp_Title+'_Type_3_l1_SecDownPosi_com.txt'
      
      ;Primary Electrons
      Pri_Elec_all = cur+'/PriElec/TypeAll/'+Temp_Title+'_l1_PriElec_com.txt'
      Pri_Elec_T1  = cur+'/PriElec/Type1/'+Temp_Title+'_Type_1_l1_PriElec_com.txt'
      Pri_Elec_T2  = cur+'/PriElec/Type2/'+Temp_Title+'_Type_2_l1_PriElec_com.txt'
      Pri_Elec_T3  = cur+'/PriElec/Type3/'+Temp_Title+'_Type_3_l1_PriElec_com.txt'
      
      ;Primary Electrons
      Pri_Posi_all = cur+'/PriPosi/TypeAll/'+Temp_Title+'_l1_PriPosi_com.txt'
      Pri_Posi_T1  = cur+'/PriPosi/Type1/'+Temp_Title+'_Type_1_l1_PriPosi_com.txt'
      Pri_Posi_T2  = cur+'/PriPosi/Type2/'+Temp_Title+'_Type_2_l1_PriPosi_com.txt'
      Pri_Posi_T3  = cur+'/PriPosi/Type3/'+Temp_Title+'_Type_3_l1_PriPosi_com.txt'
;
;----- Combining -------------------
;
  Com=5
;  ;Combining files  
  SimFiles_all = [Gamma_com_all, Sec_Elec_Up_all, Sec_Elec_Down_all,SEc_Posi_Up_all, Sec_Posi_Down_all, Pri_Elec_all, Pri_Posi_all]
  SimFiles_T1  = [Gamma_com_T1,  Sec_Elec_Up_T1,  Sec_Elec_Down_T1, Sec_Posi_Up_T1,  Sec_Posi_Down_T1,  Pri_Elec_T1,  Pri_Posi_T1]
  SimFiles_T2  = [Gamma_com_T2,  Sec_Elec_Up_T2,  Sec_Elec_Down_T2, Sec_Posi_Up_T2,  Sec_Posi_Down_T2,  Pri_Elec_T2,  Pri_Posi_T2]
  SimFiles_T3  = [Gamma_com_T3,  Sec_Elec_Up_T3,  Sec_Elec_Down_T3, Sec_Posi_Up_T3,  Sec_Posi_Down_T3,  Pri_Elec_T3,  Pri_Posi_T3]

  foldername22 = cur+'/com'+Strn(Com)+'/'
  gsim_Grp_Com_sim, SimFiles_all, Title=Temp_Title, Com=Com, foldername=foldername22
  gsim_Grp_Com_sim, SimFiles_T1, Title=Temp_Title, Com=Com, foldername=foldername22, Type=1
  gsim_Grp_Com_sim, SimFiles_T2, Title=Temp_Title, Com=Com, foldername=foldername22, Type=2
  gsim_Grp_Com_sim, SimFiles_T3, Title=Temp_Title, Com=Com, foldername=foldername22, Type=3


 ; Gsim_Grp_Plot_Com,SimFiles_All, Title=Temp_Title, Com=Com, foldername=foldername22 


 ;--- Smoothing ---  

    combined_file_all = foldername22+'TypeAll/'+Temp_Title+'_ComMod_'+Str(Com)+'.txt'
    combined_file_T1 = foldername22+'Type1/'+Temp_Title+'_Type_1_ComMod_'+Str(Com)+'.txt'
    combined_file_T2 = foldername22+'Type2/'+Temp_Title+'_Type_2_ComMod_'+Str(Com)+'.txt'
    combined_file_T3 = foldername22+'Type3/'+Temp_Title+'_Type_3_ComMod_'+Str(Com)+'.txt'

  
  
  Param_Array = [Strn(PSD), Strn(Side), Strn(Cor), Strn(Min_Ener), Strn(Max_Ener)]
  
  gsim_grp_smoothfit,combined_file_all;,Title=Temp_Title+'_MCom_'
  gsim_grp_smoothfit,combined_file_T1;,Title=Temp_Title+'_MCom_'
  gsim_grp_smoothfit,combined_file_T2;,Title=Temp_Title+'_MCom_'  
  gsim_grp_smoothfit,combined_file_T3;,Title=Temp_Title+'_MCom_'
 

;
;-- Compare  With Flight and get a Chi and Red Chi
;using gamma_compare3
  model_file_all = foldername22+'TypeAll/'+Temp_Title+'_ComMod_'+Strn(Com)+'_modfit.txt'
  model_file_T1 = foldername22+'Type1/'+Temp_Title+'_Type_1_ComMod_'+Strn(Com)+'_modfit.txt'
  model_file_T2 = foldername22+'Type2/'+Temp_Title+'_Type_2_ComMod_'+Strn(Com)+'_modfit.txt'
  model_file_T3 = foldername22+'Type3/'+Temp_Title+'_Type_3_ComMod_'+Strn(Com)+'_modfit.txt'

  gsim_grp_compare_gamma3, flt_all, model_file_all,param_array=Param_array,com=com, folder=foldername22
    gsim_grp_compare_gamma3, flt_typ1, model_file_T1,param_array=Param_array,com=com,TYpe=1, folder=foldername22
        gsim_grp_compare_gamma3, flt_typ2, model_file_T2,param_array=Param_array,com=com,TYpe=2, folder=foldername22
            gsim_grp_compare_gamma3, flt_typ3, model_file_T3,param_array=Param_array,com=com,TYpe=3, folder=foldername22
            
        Endfor ; temp_i
    Endfor ; temp_j
Endfor  ; temp_k
End