Pro Grp_Flt_Pol_bgdSub, fsearch_str, bgdfile

;This is to do a background subtraction of the polarization files for the crab. 
; We get teh file from grp_l2v7_flt_polarization. 
; The background is the PCA file

infile = File_SEarch(fsearch_str)
nfiles = N_elements(infile)
help, infile

;---------BGd file---------- One line
openr,lun, bgdfile,/get_lun
data=''
    readf, lun, data
     readf, lun, data
      readf, lun, data
       readf, lun, data 
       print, data
       
       allarr = [0.0]
          str_len = strlen(data)
           
     
          j = 0
          
           while (j lt str_len) and (j gE 0) do begin
            
             pos0 = strpos(data, ' ', j+1)
             pos1 = strpos(data, '.', pos0)
             pos2 = strpos(data, ' ', pos1)
             data1= strmid(data, pos0, pos2-pos0)
             allarr = [allarr, double(data1)]
             j = pos2
           endwhile
           ; it exits before taking into last data
          ; print, pos0, pos1, pos2
           allarr=[allarr,double(strmid(data, pos0, strlen(data)-pos0))]
            allarr1 = allarr[4:n_elements(allarr)-1]

           bgdarr = [0.0]
           bgderr = [0.0]
           for i = 0, n_elements(allarr1)-2 do begin

              bgdarr= [bgdarr,allarr1[i]]
              bgderr= [bgderr, allarr1[i+1]]
              i++
           endfor
            bgdarr = bgdarr[1:n_elements(bgdarr)-1]
            bgderr = bgderr[1:n_elements(bgderr)-1]
            free_lun, lun
;-------------------

readcol, infile[0], x, y
xsize = n_elements(x)

main_arr = dblarr(nfiles)


for i = 0, nfiles-1 do begin
  file = infile[i]
  print, file
  
  readcol, file, Bin, count
  print, count
print, '--'
 print, total(Count)
  
  print, bgdarr[i], '**'
  print, bgdarr[i]*720*0.94
  
  
  stop
endfor

End