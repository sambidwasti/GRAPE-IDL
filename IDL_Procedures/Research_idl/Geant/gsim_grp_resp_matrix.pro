Pro Gsim_Grp_Resp_Matrix, fsearch_String, title=title
    ;
    ; This is for the square matrix.
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
    ;
    ;
    ;=== Get single or multiple files ====
    ;
  ;  title = 'Try'
    close, /all
 ;   Elo = [65,70,90, 120,160,200]
 ;  Ehi = [70,90,120,160,200,300]
    cd, cur=cur
    Elo = [50,55,60,65,70,75,80,85,90,95,100,105,110,115,120,125,130,135,140,145,150,155,160,165,170,175,180,185,190,195,200,205,210,215,220,225,230,235,240,245,250,255,260,265,270,275,280,285,290,295]
    Ehi = [55,60,65,70,75,80,85,90,95,100,105,110,115,120,125,130,135,140,145,150,155,160,165,170,175,180,185,190,195,200,205,210,215,220,225,230,235,240,245,250,255,260,265,270,275,280,285,290,295,300]
    

    l1respfiles = file_search(fsearch_String)
    n_l1respfiles = n_elements(l1respfiles)
    
    
    ;
    ; Effective area
    ;
    N = 1000000   
    Area = 65 * !pi * 65    ; Simulated input area ; mainly for effective area

    
    ;
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
      ;---
      
      MainResp[Ener,*] = B
      
      Print, 'InputEner:', Ener
    endfor
    Temp_Str = Cur+'/response.ps'
    CGPS_Close
    CGPS2PDF, Temp_Str,delete_ps=1

    
    ;
    ;-- Now Rebinning --   
    ;
     N_ele = n_elements(ELO)
     MainRebinx = FltArr(N_ele, 1001)

     MainRebin = FltArr(N_ele, N_ele)

    For i = 0, N_ele-1 do begin
      
      lowj = Fix(Elo[i])        ; arr loc
      hij  = Fix(Ehi[i])      ; arr loc
      
      tempval = fltarr(1001)
      for j = lowj, hij-1 do begin
              
              tempval = tempval + MainResp[j,*]
        
      endfor
      
     ; print, tempval
      Mainrebinx[i,*] = tempval
      
      help, mainrebinx
      help, tempval
    Endfor
    
    For i = 0, N_ele-1 do begin
      lowj = Fix(Elo[i])        ; arr loc
      hij  = Fix(Ehi[i])      ; arr loc

      tempval1 = fltarr(N_Ele)
; diagonal values
        
   
      for j = lowj, hij-1 do begin

        tempval1 = tempval1 + MainRebinx[*,j]

      endfor

      Mainrebin[*,i] = tempval1
        
    
  

     ;   Endfor \\
    ; Print, tempval1
    Endfor
  
  Help, MainRebin
  ; Need to normalize
  ReNorm = DblArr(N_Ele,N_Ele)
  StrVal = '#Elo  Ehi  '

  For i =0, N_Ele-1 do begin
     Tot = Total(MainRebin[i,*])
     ReNorm[i,*]= MAinRebin[i,*]/Tot
    StrVal = StrVal+'  '+Strn(Elo[i])
  Endfor
  Help, ReNorm
  
Openw, Lun, title+'TextResponseRaw.txt', /Get_lun
   Printf,LUn, StrVal
    For i = 0, N_ele-1 do begin
      StrVal1 = Strn(ELo[i]) + '  '+ Strn(Ehi[i])
      tempval = ReNorm[i,*]
      For j = 0, N_elements(tempval)-1 Do StrVal1 = StrVal1+ '  '+Strn(tempVal[j])
      
      Printf, Lun, strval1
     ; Printf,lun, Elo[i], Ehi[i],ReNorm[i,*], format = '( F5.2, 1X, F5.2, 1X, 6( F8.4, 1X))'

    Endfor
 
Free_lun, Lun



Openw, Lun1, title+'RSP_data.txt', /Get_lun
Printf,LUn1, StrVal
For i = 0, N_ele-1 do begin
  ; Format is Elo, Ehi, det (1), fchan (0), nchan(N_ele), Ener
  StrVal1 = Strn(ELo[i]) + '  '+ Strn(Ehi[i])
  
  Strval1 = StrVal1+'   1    0    '+Strn(N_Ele)
  
  tempval = ReNorm[i,*]
  For j = 0, N_elements(tempval)-1 Do StrVal1 = StrVal1+ '  '+Strn(tempVal[j])

  Printf, Lun1, strval1
Endfor

Free_lun, Lun1

Print, Ehi-Elo
Print, N_ele

;ArfNorm = Area* MainResp/N ; Effective Area


End
