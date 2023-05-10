Pro Grp_xspec_add_backsub, filesearch
; This is to add the background subtracted sweep files

filename = file_search(filesearch)
nfiles = n_elements(filename)
NBIns= 6
Main_Cnt = Dblarr(Nbins)
help, Main_Cnt
Main_Err = DblArr(nbins)
For p = 0, Nfiles-1 do begin
	file = filename[p]
	readcol, file, Chan, count, err, format='D,D,D'

	Main_Cnt = Main_Cnt + count
	Main_Err = Main_Err + ERr*Err
		print, count
		Print, Main_Cnt, Main_Err
		
endfor

Main_ERr = Sqrt(Main_ERr)

Print, Main_Cnt, Main_Err

;=== Open and write the file
Openw, Lun, 'Grp_Summed_Bgd_Sub.txt',/Get_Lun
	For i = 0, Nbins-1 do begin
		data_count = String(Format='( E14.7 ,X)', Main_Cnt[i])
		data_error = String(Format='( E14.7 ,X)', Main_ERr[i])

		printf, lun, '          '+Strn(Chan[i]),'   ',data_Count,'   ', Data_error
	EndFor

Free_Lun, Lun


End