Pro Grp_l2v7_flt_backsub, fsearch_str, Bgdfile, Title=Title
;  This is to read the energy loss spectrum and background file and generate a 
;       Crab pha and rsp file for xspec
; Fsearch_str is going to be for the crab energy loss spec (Src + Back)
;   So it should be in the CRab folder.
;   Remember the counts per sec vs counts per sec per kev. so Counts/S/Kev
; Bgd file is the file from pca analysis that is per energy range, per sweep So counts/s
;     Need to fix this before substraction
;     
;     The Background now has to be in counts per sec and not per kev
;
; 01/22/19 Adding few extra lines to plot all.

;sIf keyword_set(Bgdfile) NE 0 then bgdflag = 1 else bgdflag = 0 ; Binsize

IF Keyword_Set(title) Eq 0 Then Title='EnergyLoss'


ReadCol, BgdFile, B_Elo, B_Ehi, Chisqr, Cnt92, Cnt92_Err, Cnt93, Cnt93_Err, Cnt94, Cnt94_Err, Cnt95, Cnt95_Err, Cnt96, Cnt96_Err, $
        Cnt97, Cnt97_Err, Cnt98, Cnt98_Err, Cnt99, Cnt99_Err, Cnt100, Cnt100_Err

NEBins = N_Elements(B_Elo)
print, nebins

MainArray = [ [B_elo],[B_Ehi], [ Cnt92],[Cnt92_Err], [Cnt93], [Cnt93_Err], [Cnt94],[Cnt94_Err], [Cnt95], [Cnt95_Err],[ Cnt96],[Cnt96_Err], [Cnt97], [Cnt97_Err], [Cnt98],[Cnt98_Err], [Cnt99], [Cnt99_Err], [Cnt100],[Cnt100_Err] ]
help, MainArray

Print, Total(MainArray[*,18]), total(Cnt100)

; Create a huge 2D array with these values. 
;?_?
cd, cur=cur
TotEner = Dblarr(NEbins)
print, 'NEBins', NeBins
TotErr2 = Dblarr(NEbins)

;print, where(B_Elo eq 80)

;
; Now read in the energy loss spec.
; 
;===========
Crbfiles = FILE_SEARCH(fsearch_str)          ; get list of EVT input files
if keyword_set(nfiles) ne 1 then nfiles = n_elements(Crbfiles)
print, nfiles, '******'


Crab_Tot =  Dblarr(NEbins)
Crab_Err = Dblarr(NEbins)


Back_Tot =  Dblarr(NEbins)
Back_Err = Dblarr(NEbins)

for p = 0, nfiles -1 do begin
   Curfile = CrbFiles[p]
   print,'File:', curfile
   ; We need sweep no. 
   a0= strpos(Curfile,'_Swp',0) + 4
   a1= strpos(Curfile,'_FltHist1',0)
   Swp = strmid(Curfile, a0,a1-a0)
   Sweep = FIx(Swp)
   
   ; Get the counts and error location depending on the sweep. 
   
   
   
   Case sweep of
     92 :Begin
         C_pos=2
         E_pos=3
         End
     93 :BEgin
         C_pos=4
         E_pos=5
         End
     94 :Begin
         C_pos=6
         E_pos=7
         End
     95 :Begin
         C_pos=8
         E_pos=9
         End
     96 :Begin
         C_pos=10
         E_pos=11
         End
     97 :Begin
         C_pos=12
         E_pos=13
         End
     98 :Begin
         C_pos=14
         E_pos=15
         End
     99 :Begin
         C_pos=16
         E_pos=17
         End
     100:Begin
         C_pos=18
         E_pos=19
         End
     Else: PRint, ' WRong SWEEP Number'    
       
   Endcase
   ;Print, E_Pos, C_Pos

   ; Read the current Energy loss file 
   print, curfile
   ReadCol, Curfile, Cur_lo, Cur_hi, Cur_Cnt, Cur_err
   
   PRint, Total(Cur_Cnt)
  
   
   ; Get the current energy range, count and error
   Nbins = N_elements(Cur_lo)
   print, 'Nbins', Nbins
   For i = 0, Nbins-1 do begin

    
        Emin_loc = Where(B_Elo eq Cur_lo[i])
        Emax_loc = Where(B_EHi eq Cur_hi[i])
        
        If Emin_loc Ne Emax_loc Then begin
          PRINT, 'Array location not matching for energy ranges'
          Stop
          
        Endif
        
        CurCnt  = Cur_Cnt[i]
        Curerr = Cur_err[i]
        
        BCnt = Mainarray[Emin_loc,C_pos]
        Berr = MainArray[Emin_loc,E_pos]
        
        Diff_Cnt = CurCnt - BCnt
        DIff_err2 = CurErr*CurErr + BErr*BErr
        
        TotEner[Emin_loc] = TotEner[Emin_loc]+Diff_Cnt
        TotErr2[Emin_loc] = TotErr2[Emin_loc]+Diff_Err2

        ;Subtract the background
        ; calculate the error
        ; Create an array
        
       ; Print, CurCnt, Bcnt
       
       
       Crab_Tot[i] =  Crab_tot[i]+CurCnt
       Crab_Err[i] = Crab_Err[i]+CurErr*CurErr
       
       Back_Tot[i] = Back_Tot[i]+BCnt
       Back_Err[i] =  Back_Err[i]+Berr*Berr
   
   Endfor  
    

   Print, TotEner
   Print, Total(TotEner)
  ; stop
endfor
Crab_Err = Sqrt(Crab_err)
CRAB_ERR = Crab_Err/nfiles
Crab_Tot = Crab_Tot/nfiles
Print, Crab_Err

TotErr = (Sqrt(TotErr2))/nfiles
TotEner = TotEner/nfiles
Print, '****'
;Print, TotEner
Print, 'Errors'
;Print, TotErr

Back_Err = Sqrt(Back_err)
Back_ERR = Back_Err/nfiles
Back_Tot = Back_Tot/nfiles


;
;Need to redefine the X Axis so the data points are centered.
;
Print, B_Elo
Print, B_Ehi

Print, (B_Ehi+B_Elo)/2
PRint, Crab_Tot

C_Xval = (B_Ehi+B_Elo)/2
xval_err = (B_Ehi-B_Elo)/2
; Plot
; ===
;  ---- Opening the Device for further plots and various things -----
CgPs_Open, 'BackSub.ps', Font =1, /LandScape
cgLoadCT, 13
!P.Font=1
    CgPlot,C_Xval, Crab_Tot,$
        Ytitle = 'Counts/S', Xtitle ='Energy(keV)',Title=Title,$
        Err_Ylow = Crab_Err, Err_YHigh=Crab_Err, /Ylog, /xlog,$;, Yrange=[0.001,0.2]
        Err_Xlow = Xval_err, Err_XHigh = xval_err, psym=3, /Err_Clip, Err_Width=0.001

    CgoPlot,C_Xval,  TotEner, color='Dark Green',Err_Ylow = TotErr, Err_YHigh = TotErr,$
            Err_Xlow = Xval_err, Err_XHigh = xval_err, psym=3, /Err_Clip, Err_Width=0.001
    
    CgOPlot, C_Xval, Back_Tot, color='Red',Err_Ylow = Back_Err, Err_YHigh=Back_Err,$;,Err_Ylow = TotErr, Err_YHigh = TotErr, Color='Green'
          Err_Xlow = Xval_err, Err_XHigh = xval_err, psym=3, /Err_Clip, Err_Width=0.001
CgErase

CgPlot,C_Xval, Crab_Tot,$
  Ytitle = 'Counts/S', Xtitle ='Energy(keV)',Title=Title,$
  Err_Ylow = Crab_Err, Err_YHigh=Crab_Err, /Ylog, /xlog,XRange=[50,400],$;, Yrange=[0.001,0.2]
  Err_Xlow = Xval_err, Err_XHigh = xval_err, psym=3, /Err_Clip, Err_Width=0.001

CgoPlot,C_Xval,  TotEner, color='Dark Green',Err_Ylow = TotErr, Err_YHigh = TotErr,$
  Err_Xlow = Xval_err, Err_XHigh = xval_err, psym=3, /Err_Clip, Err_Width=0.001

CgOPlot, C_Xval, Back_Tot, color='Red',Err_Ylow = Back_Err, Err_YHigh=Back_Err,$;,Err_Ylow = TotErr, Err_YHigh = TotErr, Color='Green'
  Err_Xlow = Xval_err, Err_XHigh = xval_err, psym=3, /Err_Clip, Err_Width=0.001
CgErase


    CgPlot,C_Xval, Crab_Tot,$
  Ytitle = 'Counts/keV', Xtitle ='Energy(keV)',Title=Title,$
  Err_Ylow = Crab_Err, Err_YHigh=Crab_Err,$;,Yrange=[-0.1,0.2]
  Err_Xlow = Xval_err, Err_XHigh = xval_err, psym=3, /Err_Clip, Err_Width=0.01
  

    CgoPlot,C_Xval,  TotEner, color='Dark Green',Err_Ylow = TotErr, Err_YHigh = TotErr,$
            Err_Xlow = Xval_err, Err_XHigh = xval_err, psym=3, /Err_Clip, Err_Width=0.001
    
    CgOPlot, C_Xval, Back_Tot, color='Red',Err_Ylow = Back_Err, Err_YHigh=Back_Err,$;,Err_Ylow = TotErr, Err_YHigh = TotErr, Color='Green'
          Err_Xlow = Xval_err, Err_XHigh = xval_err, psym=3, /Err_Clip, Err_Width=0.001

;CgText, !D.X_Size*0.85,!D.Y_Size*0.93,'Swp='+STRN(Swp),/DEVICE, CHarSize=1.7,Color=CgColor('Black')


CgPs_Close

;-- Create the PDF File
Temp_Str = Cur+'/'+'BackSub.ps'
CGPS2PDF, Temp_Str,delete_ps=1


Openw,lun, title+'Verify.txt',/Get_lun
printf, lun, 'COunts'
PRintf, lun, ' CRab    Back    Diff'
For i = 0, Nbins-1 do begin
  Printf, lun, Crab_tot[i], Back_tot[i], TotEner[i]
Endfor

Printf, lun, 'ERRORS'
Printf, Lun, 'CrbErr, CrbErr2, BackErr, BackErr2, TotErr, TotErrAdded2
For i = 0, Nbins-1 do begin
  Tot_Err_Calc = Crab_Err[i]*Crab_Err[i]+ Back_Err[i]*Back_Err[i]
  
  Printf, lun, Crab_Err[i],Crab_Err[i]*Crab_ERr[i], Back_Err[i], Back_Err[i]*Back_Err[i], TotErr[i], Sqrt(Tot_Err_Calc),$
    format='( F10.6,1X,F10.6,1X,F10.6,1X,F10.6,1X,F10.6,1X,F10.6)'
Endfor


PRintf, lun, 'Significance of Bins'
For i = 0, Nbins-1 do begin
  Printf, lun,  TotEner[i],TotErr[i], (TotEner[i]/TotErr[i]),$
    format='( F10.6,1X,F10.6,1X,F10.6)'
Endfor
  
Free_lun, lun


Openw, Lun101, 'Crab_Eloss.txt', /Get_Lun
  For i = 0, Nbins-1 do begin
      Printf, lun101, B_Elo[i], B_Ehi[i], TotEner[i], TotErr[i]
    
    
  Endfor
  
Free_Lun, lun101

End

