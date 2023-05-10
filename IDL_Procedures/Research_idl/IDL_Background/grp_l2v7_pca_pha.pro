Pro Grp_l2v7_pca_pha, file
; This is designed to read the column background file and generate various data files with sweep names. 
; The readcol might change if the no. of sweeps change.
ReadCol, File, Elo, Ehi, Chi, Cnt92, Err92, Cnt93, Err93, Cnt94, Err94,Cnt95, Err95, Cnt96, Err96, Cnt97, Err97, Cnt98, Err98, Cnt99, Err99, Cnt100, Err100,$
    Format='D,D,D, D,D,D,D,D,D, D,D,D,D,D,D, D,D,D,D,D,D'
    
  ;    data_count = String(Format='( E13.7 ,X)', Flight2[i])
len = N_elements(Elo)
; We manually generate background files. 
; Swp 92
Openw, lun, 'Swp92_bgd.txt',/Get_Lun
    For i = 0,len-1 do begin
      data_count = String(Format='( E13.7 ,X)', Cnt92[i])
      data_Err = String(Format='( E13.7 ,X)', Err92[i])
       printf, lun, '          '+Strn(i),'   ',data_Count,'   ', Data_err
      
    Endfor
Free_lun, lun

; Swp 93
Openw, lun, 'Swp93_bgd.txt',/Get_Lun
For i = 0,len-1 do begin
  data_count = String(Format='( E13.7 ,X)', Cnt93[i])
  data_Err = String(Format='( E13.7 ,X)', Err93[i])
  printf, lun, '          '+Strn(i),'   ',data_Count,'   ', Data_err

Endfor
Free_lun, lun

; Swp 94
Openw, lun, 'Swp94_bgd.txt',/Get_Lun
For i = 0,len-1 do begin
  data_count = String(Format='( E13.7 ,X)', Cnt94[i])
  data_Err = String(Format='( E13.7 ,X)', Err94[i])
  printf, lun, '          '+Strn(i),'   ',data_Count,'   ', Data_err

Endfor
Free_lun, lun

; Swp 95
Openw, lun, 'Swp95_bgd.txt',/Get_Lun
For i = 0,len-1 do begin
  data_count = String(Format='( E13.7 ,X)', Cnt95[i])
  data_Err = String(Format='( E13.7 ,X)', Err95[i])
  printf, lun, '          '+Strn(i),'   ',data_Count,'   ', Data_err

Endfor
Free_lun, lun

; Swp 96
Openw, lun, 'Swp96_bgd.txt',/Get_Lun
For i = 0,len-1 do begin
  data_count = String(Format='( E13.7 ,X)', Cnt96[i])
  data_Err = String(Format='( E13.7 ,X)', Err96[i])
  printf, lun, '          '+Strn(i),'   ',data_Count,'   ', Data_err

Endfor
Free_lun, lun

; Swp 97
Openw, lun, 'Swp97_bgd.txt',/Get_Lun
For i = 0,len-1 do begin
  data_count = String(Format='( E13.7 ,X)', Cnt97[i])
  data_Err = String(Format='( E13.7 ,X)', Err97[i])
  printf, lun, '          '+Strn(i),'   ',data_Count,'   ', Data_err

Endfor
Free_lun, lun

; Swp 98
Openw, lun, 'Swp98_bgd.txt',/Get_Lun
For i = 0,len-1 do begin
  data_count = String(Format='( E13.7 ,X)', Cnt98[i])
  data_Err = String(Format='( E13.7 ,X)', Err98[i])
  printf, lun, '          '+Strn(i),'   ',data_Count,'   ', Data_err

Endfor
Free_lun, lun

; Swp 99
Openw, lun, 'Swp99_bgd.txt',/Get_Lun
For i = 0,len-1 do begin
  data_count = String(Format='( E13.7 ,X)', Cnt99[i])
  data_Err = String(Format='( E13.7 ,X)', Err99[i])
  printf, lun, '          '+Strn(i),'   ',data_Count,'   ', Data_err

Endfor
Free_lun, lun

; Swp 99
Openw, lun, 'Swp100_bgd.txt',/Get_Lun
For i = 0,len-1 do begin
  data_count = String(Format='( E13.7 ,X)', Cnt100[i])
  data_Err = String(Format='( E13.7 ,X)', Err100[i])
  printf, lun, '          '+Strn(i),'   ',data_Count,'   ', Data_err

Endfor
Free_lun, lun
End