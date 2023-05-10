Pro XSpec_Rsp_mod, infile, respfile, debug=debug, title=title

;
;The purpose of this is to read in the pha file, and edit the rsp file which is a matrix atm.
;Doing this with step wise with most needed output to have a clarity.
;   Note: the Pha file takes in only the spectrum
;   the rsp file takes in the ebounds and the rsp.
;   So the approach is to read in the pha, and generate a new file with proper extensions.
;Step1 : Read for basic info.
;Step2 : Figure out respective extensions.
;        We want Spectrum Ext 1, Ebounds 2 and Response(rsp) 3
;      
;This is paused because found a different way to do this.

Inst = 'GRAPE 2014'
cd, cur=cur

close, /all
 
  Print, 'Step 1:   ===== File Info   ===='
 ;   fits_info,infile,TextOut = txtout, N_Ext = next, ExtName = ExtName
 
  a = mrdfits(infile,1,header) ; 1 is spectrum
  for i = 0, n_elements(a)-1 do begin
  ;    print, a[i]
  endfor
  Print, Header


  PRINT, 'STEP 2: Search header for Response file name'
  print, Xspec_tool_headsrch(header,'RESPFILE')

    response_rsp = cur+'/'+Xspec_tool_headsrch(header,'RESPFILE')
    fits_info, response_rsp, textout= txtout, N_ext=Next2, Extname=Extname2


  Print, 'Step3:   ======= Get the Extention name and Extention number of Ebounds and Ext ====
  ;Help, Extname2
    ExtName2 = StrCompress(ExtName2,/REMOVE_ALL)
  
    Ebount_ext = 0
    Matrix_ext = 0
    Spectrum_ext = 0
    For i = 0,Next2 Do begin
      If ExtName2[i] eq 'EBOUNDS' Then Ebound_Ext = i
      If ExtName2[i] eq 'MATRIX'  Then Matrix_Ext = i
    Endfor

  
    im = Readfits(infile,h,/noscale)
    
     htab =''
  ;  tab = READFITS(infile,htab,Exten_no = 1)
  ;  mwrfits,tab,newfile,htab ; adding in the spectrum.
 
   FXHMODIFY,  infile,'RESPFILE', 'Co57_r121.pha', EXTENSION=1
   
 ;  fits_info,infile,TextOut = txtout, N_Ext = next, ExtName = ExtName


    a = mrdfits(infile,1,header) ; 1 is spectrum
    print, '******** HEADER *********'
    print, header
    
   ; Ext2. EBOUNDS
   tab = READFITS(response_rsp,htab,Exten_no = Ebound_Ext)

      mwrfits,tab,infile,htab ; adding in the Ebounds
      fits_info,infile,TextOut = txtout, N_Ext = next, ExtName = ExtName

 
    print, Matrix_ext,'**'
    tab2 = READFITS(response_rsp,htab,Exten_no = Matrix_Ext)
    print, htab
    Print, '--------'
    mwrfits,tab,infile,htab ; adding in the Ebounds
    fits_info,infile,TextOut = txtout, N_Ext = next, ExtName = ExtName
print, htab
    ; read in ebounds and write in the extensions.
    stop

    
   
    ; We have teh respective extension values
;      Print, 'Spec ext = ',Spectrum_ext
;     Print, 'Ebound Ext= ',Ebound_Ext
;    Print,  ' Matrix ext = ',Matrix_Ext
;stop

  Print, ' Step3:  ========  HEader for Spectrum and edit ========='
  PRINT, 'NOTE: some instrument info is not included here'
  


  Print, ' STEP4: Read and Manipulate the response matrix file'
  ;Read in the Response file
  ;The response matrix is a square matrix BUT 
  ; The first line in the file  is just info. not data
  ; first two columns are elo and ehi
  ; Define the structures.
  
  
  
  file_len = file_lines(respfile)-1
  Matrix_array = Fltarr(file_len, File_len)
  
  RespStruc ={ $
    Elo : 0.0, $
    Ehi : 0.0, $
    Nchan : 0, $  ; No. Channel
    Fchan : 0, $  ; First Channel no. This starts at 1.
    Echan : INTARR(File_len), $; Array of Energy channel location defined in Ebounds
    MatRow: FltARR(File_len) $; Matrix Row. (This is normalized row values for each of the EChan loc
}
  RespStruc = Replicate(RespStruc, File_Len)

  
  Openr, lun, respfile, /Get_Lun
  data=''
  readf, lun, data   ; Skip first line


  for i = 0,File_len-1 do begin

      readf, lun, data   ; Skip first line
    ;  print, data
      ;Now we manipulate the line to extract the values.
      ; first two are the energy. 
      Pos1 = 0
      Pos2 = StrPos(data, ' ', Pos1+1)  
      T_elo = Float(Strmid(data,Pos1, Pos2-Pos1))
      RespStruc[i].Elo = T_Elo
    ;  Print, 'Telo:', T_Elo
      
      Pos1 = Pos2+1
      Pos2 = StrPos(data, ' ', Pos1+1)
      T_ehi = Float(Strmid(data,Pos1, Pos2-Pos1))
      RespStruc[i].Ehi = T_Ehi
      ;Print, 'Tehi:', T_Ehi

      for j = 0, file_len-1 do begin
        Pos1 = Pos2+1
        Pos2 = StrPos(data, ' ', Pos1+1)
            ;    Temp_Str = String(Format='(D6.2,X)', B)
                
        
        T_val = Float(Strmid(data,Pos1, Pos2-Pos1))

        ;Print, Strmid(data,Pos1, Pos2-Pos1)
       ; Print, T_Val
        Matrix_array[i,j] = T_Val
        Pos1 = Pos2+1

        ; We Use the T_Val to fill in rest of the structure. 
      endfor
      ; Read the whole row
      T_array = Matrix_array[i,*]
      index = WHERE(T_array NE 0.0, count)
      
      
      RespStruc[i].Nchan = count
      RespStruc[i].fchan = index[0]+1
      RespStruc[i].Echan = index+1
      RespStruc[i].MatRow = T_Array[index]

    ;print, data
  EndFor
  Free_lun, lun
  mwrfits,RepStruc,infile,htab ; adding in the spectrum.
  fits_info,infile,TextOut = txtout, N_Ext = next, ExtName = ExtName


;  Print, RespStruc[0]
 ; Print, RespStruc[1]



  
;  for i= 0, 10 do begin
;    temp = Matrix_array[i, *]
;    Print, temp[0:10]
;  endfor



End


