pro Grp_XSpec_BackSub, Src, Bgd, title=title

; This is to check the Src Sub Bgd 
; This is designed to read in Each Sweep Src and BGd xspec data files
; and generate a bgd-subtracted file

ReadCol, Src, Chan, Src_Cnt, Src_Err, format='D,D,D'
ReadCol, Bgd, Chan1, Bgd_Cnt, Bgd_Err, format='D,D,D'

IF Keyword_Set(title) Eq 0 Then Title='Bgd_Sub'


;Subtraction
Tot = Src_Cnt-Bgd_Cnt
Err = Sqrt(Src_Err*Src_err + Bgd_Err*Bgd_Err)
openw, lun, title+'.txt', /Get_lun

	For i = 0, N_Elements(Tot)-1 do begin
		data_count = String(Format='( E14.7 ,X)', Tot[i])
		data_error = String(Format='( E14.7 ,X)', ERr[i])

		printf, lun, '          '+Strn(Chan[i]),'   ',data_Count,'   ', Data_error
	EndFor
	
FRee_Lun, Lun
End