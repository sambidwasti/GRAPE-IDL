Pro Gsim_Grp_Plot_Models, fsearch_Str, title = title

; This procedure is created to compare two different model ct files. 
; The input files are generated via gsim_grp_plot_com1a.

; Read teh two model files and plot them together. 
; Also create a template for comparisions of the errors. 
; This should also read the rebinned flight files.
;

File_Search = FILE_SEARCH(fsearch_str)
nfiles = n_elements(File_Search)
print, nfiles, file_Search

Model_Name = StrArr(nfiles)

Flight_file = '/Users/sam/Dropbox/Cur_Work/Flight_Bin_10/10_40_PC_l2v7_inv3_rebin.txt'
ReadCol, flight_file, Flight1, Flight1_err, format='F,F'

;  Color=CgPickCOlorName()
 ; Print, Color
  LegenArr = [' Flight ']
  ColorArr = ['Royal Blue','FireBRick', 'Dark Green']
if nfiles gt 2 then stop

    For p = 0, nfiles-1 do begin
      
      File = File_Search[p]
      
      ReadCol, file, XVal, Temp, Temp_Err, format='D,D,D'
      
      Help, Xval, Temp, Temp_Err
      
      ;-The file name is of the format: (PSD;Side;Cor)_model.txt
      file_text = String(File)
      help, file_text
      pos = strpos(file_text,'(',0)
      help, pos
      pos1= strpos(file_text,')',pos+1)
      modelname= strmid(file_text,pos, pos1-pos+1)
      Model_name[p] = modelname
      
      If p eq 0 then begin
         Hist0 = Temp
         Hist0_err = temp_err
      Endif
      
      If p eq 1 then begin
         Hist1 = Temp
         Hist1_err = temp_err       
      Endif
   
    Endfor
    
    LegenArr = [LegenArr,Model_name]
    CgPs_Open, 'plot_models', Font =1, /LandScape


    CGPlot, Xval, Hist0, PSYM=10 , /Ylog, /Xlog, YRange=[1E-5,2], XRange=[60,500],$
        Xstyle=1,  Xtitle= 'Energy (keV)', YTitle=' Counts / s / keV ',/Err_Clip,$
        err_Yhigh = Hist0_Err, Err_YLow = Hist0_Err,Err_Color=ColorArr[1], Color=ColorArr[1],$
        Title=' Flight (PC) Vs CT algorithms  '

    CgOPlot, Xval, Hist1, PSYM=10, color=ColorArr[2],err_Yhigh = Hist1_Err, Err_YLow = Hist1_Err,Err_Color=ColorArr[2],/Err_Clip

    CgOplot, Xval, Flight1, PSYM=10, Color=ColorArr[0], err_yhigh=Flight1_Err, err_ylow=Flight1_err, Err_Color=ColorArr[0],/Err_Clip
  
    CgLegend, Location=[0.93,0.9],Titles=LegenArr , Length =0, $
      SymColors = ColorArr, TColors=ColorArr,Psyms=[1,1,1],/box, Charsize=1.2
  
    CgPS_Close
    CGPS2PDF, 'plot_models'+'.ps', 'plot_models'+'.pdf', /delete_ps


End