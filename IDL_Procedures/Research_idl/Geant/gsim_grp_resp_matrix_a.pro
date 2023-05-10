Pro Gsim_Grp_Resp_Matrix_a, fsearch_String, title=title
  ;
  ; This is for the non-square matrix.
  ;     a
  ; This generates a text file with the necessary binning defined for the
  ; response matrix. This additionally generates few other files to generate
  ; the rsp fits extension using fcreate in ftools.
  ;
  ; this will/might also eventually
  ; generate few more files related to the effective area or arf files.
  ;
  ; Going to create a new procedure for the effective area.
  ;
  ; Input files:
  ; These are lvl1 processed geant simulated file.
  ;
  ;
  ; Required Procedures/Functions:
  ;           gsim_grp_main_response
  ;                 this function returns an array of 1000 for each file which is
  ;                 one specific mono-energetic enerygy.
  ;
  ; Current notes:
  ;   Work on one issue at a time.
  ;    NOTES:
  ;    ELO_D = Detector bin = Channels in spectra which is connected via EBounds
  ;    EHI_D = Hi detector bin
  ;    
  ;    Elo_E/Ehi_E = Input Energy bins. 
  ;
  ;=== Get single or multiple files ====
  ;
  ;  title = 'Try'
  close, /all

  cd, cur=cur
  Elo_E = INdgen(193)*5+35
  Ehi_E = Elo_E+5
 
 Print, Ehi_E
  Elo_D = [65,70, 90,120,160,200]
  Ehi_D = [70,90,120,160,200,300]


;  Elo_D = [50,60,70,80]
;  Ehi_D = [60,70,80,90]
;  
;  Elo_E = Indgen(10)*5+55
;  Ehi_E = Elo_E+5
;  


  l1respfiles = file_search(fsearch_String)
  n_l1respfiles = n_elements(l1respfiles)

  ;
  ; Effective area
  ;
  N = 1000000
  Area = 65 * !pi * 65    ; Simulated input area ; mainly for effective area

  ; == We would want to get the input energy from the file name ==
  ;
  MainResp = LonArr(1001,1001)        ; 1001 because we are including 0 and 1000
  CGPS_open, 'response.ps'

  ; Need to filter and select energy and send one at a time
  for p = 0, n_l1respfiles-1 do begin
    Temploc = StrPos(l1respfiles[p],'ResponseRun',0)
    TempLoc1 = StrPos(l1respfiles[p], '_', TempLoc+13)
    TempLoc = TempLoc +12
    ;    Print, TempLoc, tempLoc1
    Ener = Float(StrMID(l1respfiles[p],Temploc, TempLoc1-TempLoc))

    print
    print
    print, l1respfiles[p]
    print,'-'
    B = Gsim_Grp_Main_Response(l1respfiles[p],title=title, Input_ener = Ener)


    ;
    ;-- Sanity Checks : Creating few plots
    ;
    If Ener eq 50 then begin
      CGErase
      CGPlot, Indgen(1000), B, xtitle='Ener', ytitle='Counts', title='Energy: '+Strn(Ener)
    endif

    If Ener eq 100 then begin
      CGErase
      CGPlot, Indgen(1000), B, xtitle='Ener', ytitle='Counts', title='Energy: '+Strn(Ener)
    endif

    If Ener eq 150 then begin
      CGErase
      CGPlot, Indgen(1000), B, xtitle='Ener', ytitle='Counts', title='Energy: '+Strn(Ener)
    endif

    If Ener eq 200 then begin
      CGErase
      CGPlot, Indgen(1000), B, xtitle='Ener', ytitle='Counts', title='Energy: '+Strn(Ener)
    endif

    If Ener eq 250 then begin
      CGErase
      CGPlot, Indgen(1000), B, xtitle='Ener', ytitle='Counts', title='Energy: '+Strn(Ener)
    endif

    If Ener eq 300 then begin
      CGErase
      CGPlot, Indgen(1000), B, xtitle='Ener', ytitle='Counts', title='Energy: '+Strn(Ener)
    endif
    
    If Ener eq 400 then begin
      CGErase
      CGPlot, Indgen(1000), B, xtitle='Ener', ytitle='Counts', title='Energy: '+Strn(Ener)
    endif
    
    If Ener eq 500 then begin
      CGErase
      CGPlot, Indgen(1000), B, xtitle='Ener', ytitle='Counts', title='Energy: '+Strn(Ener)
    endif
    
    If Ener eq 600 then begin
      CGErase
      CGPlot, Indgen(1000), B, xtitle='Ener', ytitle='Counts', title='Energy: '+Strn(Ener)
    endif
    ;---

    MainResp[*,Ener] = B ; this is *,ener because array is col,row which is x, y. We want all detected energy in a row

    Print, 'InputEner:', Ener
  endfor
  Temp_Str = Cur+'/response.ps'
  CGPS_Close
  CGPS2PDF, Temp_Str,delete_ps=1


  ;-- Now Rebinning --
  ;  The rebinning works with rebinning in one dimension at a time. 
  ;  Since this is non-square matrix
  ;  MainResp = [ InPut Energy, (Array of det energy)]
  ;  If we assume [ x , y] x is input and y is det energy.
  ;  Refer to Solving_issues204 for the rebinning and matrix manipulation.
  ;-------------------
  
  
  N_ele_x = n_elements(Elo_D)  ; x is col
  
  MainRebinx = FltArr(N_ele_x, 1001)

 ; MainRebin = FltArr(N_ele, N_ele)

  For i = 0, N_ele_x-1 do begin

    lowj = Fix(Elo_D[i])        ; arr loc
    hij  = Fix(Ehi_D[i])      ; arr loc

    tempval = fltarr(1,1001)
    for j = lowj, hij-1 do begin

      tempval = tempval + MainResp[j,*]

    endfor

    ; print, tempval
    Mainrebinx[i,*] = tempval

  Endfor

N_ele_y = N_Elements(Elo_E)
MainRebin = FltArr(N_ele_x, N_ele_y)

  For i = 0, N_ele_y-1 do begin
    lowj = Fix(Elo_E[i])        ; arr loc
    hij  = Fix(Ehi_E[i])      ; arr loc

    tempval1 = fltarr(N_Ele_y)
    ; diagonal values


    for j = lowj, hij-1 do begin

      tempval1 = tempval1 + MainRebinx[*,j]

    endfor

    Mainrebin[*,i] = tempval1

    ;   Endfor \\
    ; Print, tempval1
  Endfor





;-- Need to normalize -- per row.
ReNorm = DblArr(N_Ele_x,N_Ele_y)

  For i =0, N_Ele_y-1 do begin
    Tot = Total(MainRebin[*,i])
    If Tot NE 0.0 Then ReNorm[*,i]= MAinRebin[*,i]/Tot Else ReNorm[*,i]= MainREBIN[*,i]*0.0
   Endfor
;--------

;==== Text Rensponse Raw file =====
StrVal = '#Input Elo  Ehi  '
For i = 0, n_ele_x-1 do StrVal = StrVal+'  '+Strn(Elo_D[i])
StrVal = StrVal+'('+Strn(Ehi_D[n_ele_x-1])+')'

  Openw, Lun, title+'TextResponseRaw_a.txt', /Get_lun
  Printf,LUn, StrVal
  For i = 0, N_ele_y-1 do begin
    StrVal1 = Strn(ELo_E[i]) + '  '+ Strn(Ehi_E[i])
    tempval = ReNorm[*,i]
    For j = 0, N_elements(tempval)-1 Do StrVal1 = StrVal1+ '  '+Strn(tempVal[j])

    Printf, Lun, strval1
;    ; Printf,lun, Elo[i], Ehi[i],ReNorm[i,*], format = '( F5.2, 1X, F5.2, 1X, 6( F8.4, 1X))'

  Endfor

  Free_lun, Lun

  Openw, Lun1, title+'RSP_data_a.txt', /Get_lun
  Printf,LUn1, StrVal
  For i = 0, N_ele_y-1 do begin
; Format is Elo, Ehi, det (1), fchan (0), nchan(N_ele), Ener
    StrVal2= Strn(ELo_E[i]) + '  '+ Strn(Ehi_E[i])

    Strval2= StrVal2+'   1    0    '+Strn(N_Ele_X)

    tempval2 = ReNorm[*,i]
    For j = 0, N_elements(tempval2)-1 Do StrVal2 = StrVal2+ '  '+Strn(tempVal2[j])
    Printf, Lun1, strval2
  Endfor
  Free_lun, Lun1


  ;ArfNorm = Area* MainResp/N ; Effective Area


End
