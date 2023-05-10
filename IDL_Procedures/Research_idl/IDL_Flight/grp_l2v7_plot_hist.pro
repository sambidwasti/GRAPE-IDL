Pro Grp_l2v7_plot_hist, SrcFile, BackFile

;This is for plotting two files and plotting with background subtraction
; This is mainly for the calibration run and generating a textfile for a pha.
;
;The XSPEC pha file takes this as counts/s and not counts/s/kev. 
;The /kev is done automatically through the binning.
;Updating the same for the error and the error follows the constant 
;
;The FltHist1 provides c/s not c/s/kev
;

; The files are in a format of Elo Ehi Counts/S/Kev and Error
cd, Cur=Cur
ReadCol, SrcFile, Elo1, Ehi1, Cnt1, Err1
ReadCol, BackFile, Elo2, Ehi2, Cnt2, Err2


Diff_kev = Ehi1-Elo1

Cnt1_k = Cnt1;Cnt1* Diff_kev
Cnt2_k = Cnt2;Cnt2* Diff_kev
  tempcnt = Cnt1_k-Cnt2_k
  
Err1_k = Err1;Err1* Diff_kev
Err2_k = Err2;Err2* Diff_kev  
  TempErr = Sqrt(Err2_k*Err2_k + ERr1_k*Err1_k)
  
CGPS_Open,'PlotHist.ps'

CgPlot, Elo1, Cnt1_k, ytitle='c/s', XTitle='KeV'
CGoPlot, Elo2, Cnt2_k, Color='Red'

CGoPLot, Elo1, TempCnt, Color='Blue', PSYM=10
Temp_Str = Cur+'/PlotHist.ps'
CGPS_Close
CGPS2PDF, Temp_Str,delete_ps=1

openw,lun, 'pha_plot_hist.txt',/Get_Lun
    help, tempCnt, TempCnt_Cps
    For i = 0, N_Elements(Elo1)-1 Do begin
       Printf, LUn, Elo1[i], Ehi1[i], TempCnt[i], TempErr[i]
    Endfor
  
Free_lun, Lun
End