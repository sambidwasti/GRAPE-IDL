Pro Integration_tool
;
; This is an integration tool. 
; This uses the integration function defined in the integration function section.
; 
; temp_equation is the temporary random function.
;
result_3 = Qromb('neutron1',1E-8,1E-7)
print, ' neutron1 :',result_3



  ;result = double(QROMB('pri_proton',1000.0,1000000.0))
  ;Print, 'Pri Proton:',result
  ;
  ;result = QROMB('Pri_Electron',100.0,1000000.0)
  ;Print, 'Pri Electron:',result
  ;result = QROMB('pri_positron',100.0,1000000.0)
  ;Print, 'Pri Positron:',result
  ;
  ;result_1 = Qromb('sec_pro_Down1',10.0,4211.0)
  ;print, ' Sec Proton Down1:',result_1
  ;result_1 = Qromb('sec_pro_Down2',4211.0 ,20000.0)
  ;print, ' Sec Proton Down2:',result_1
  ;
  ;result_2 = Qromb('Sec_Pro_Up1',10.0,100.0)
  ;print, ' Sec Proton Up1:', result_2
  ;result_2 = Qromb('Sec_Pro_Up2',100.0,20000.0)
  ;print, ' Sec Proton Up2:', result_2

  ;result_3 = Qromb('Sec_pos_up1',10.0,100.0)
  ;print, ' Sec Elec/Posi Up1/down1 :',result_3
  ;result_3 = Qromb('Sec_pos_up2',100.0,4211.0)
  ;print, ' Sec Elec/Posi Up2/down2 :',result_3
  ;result_3 = Qromb('Sec_pos_up3',4211.0,20000.0)
  ;print, ' Sec Elec/Posi Up3/down3 :',result_3

;  result_3 = Qromb('neutron1',1E-8,1E-7)
;  print, ' neutron1 :',result_3
  ; note Wolfram gave 0.0039402
  ; 3.9402
;  result_4=Qromb('neutron2',1E-7,1E-2)
;  result_5=Qromb('neutron2',1E-2,60)
;  print, ' neutron2 :',result_5 + result_4
;  ; Note wolfram resulted the following: 297986
;  ; 682.67
;  
;  result_6=Qromb('neutron3',60,10000)
;  print, ' neutron3 :',result_6
;  ;Note wolfram gave: 6.7966 E7
;  ;102.87
;
;  print, result_3+result_4+Result_5+Result_6
End