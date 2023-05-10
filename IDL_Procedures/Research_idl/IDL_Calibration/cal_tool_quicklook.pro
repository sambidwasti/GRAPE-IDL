Pro Cal_tool_Quicklook, File, BaCkground, title=Title, Bin=Bin, XMin=Xmin, Xmax=Xmax, Counts=Counts, Scale=Scale


;Scale is the ratio of Src Time / Back Time



;
;---- This is to Background subtract the calibration files and plot them -------
;

True =1
False = 0
  
  If Keyword_Set(Scale) Eq 0 Then Scale =1.0
  
  If Keyword_Set(title) Eq 0 Then Title='Test'
  
  If Keyword_Set(Bin) Eq 0 Then Bin = 5   ;Kev
  
   If Keyword_Set(Xmax) Eq 0 Then Xmax= 500   ;Kev
   
  ;Steps
  
  ;
  ;Define the structure to read in
  ;
  Cal_Event_struc = {$
    
    Live_time       :0.0,           $
      
    NAnodes         :0B,            $   ; Number of triggered anodes (1-8)
    NPls            :0B,            $   ; Number of triggered plastic anodes
    NCal            :0B,            $   ; Number of triggered calorimeter anodes

    EvType          :0B,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)
    EvClass         :0B,            $   ; C = 1, CC =2, PC =3, PP =4, PPC =6 more than 2 events 7 for now. P =5

    ; Storing upto 8 anodes triggered in an event.
    AnodeID         :BYTARR(8),     $   ; Array of triggered anode numbers
    ANODETYP        :BYTARR(8),     $   ; Array of triggered anode types

    AnodeNrg        :FltArr(8),     $   ; Array of triggered anode energies Corrected

    TotEnrg         :0.0            $
  }
  l1msize = 61
  
  ;
  ;------ Source --------
  ;
  F = File_Info(file)           ; get inout file info
  Nevents = Long(f.size / l1msize)            ; get number of events in input file
  Src_Data = replicate(Cal_event_Struc, nevents)    ; initialize input data array
;  Temp_Src_Data = replicate(Cal_event_Struc, 1)
  
  openr, Lun, file , /Get_Lun
  For i = 0L, nevents-1 do Begin

    readu, Lun, Cal_event_Struc        ; read one event
    Src_Data[i] = Cal_event_Struc         ; add it to input array
  Endfor
  Free_lun, Lun
  Print, 'Check0'
  ;
  ;------- Background --------
  ;
  F1 = File_Info(Background)           ; get inout file info
  Nevents1 = Long(f1.size / l1msize)            ; get number of events in input file
  Back_Data = replicate(Cal_Event_Struc, nevents1)    ; initialize input data array
 ; Temp_Bgd_Data = replicate(Cal_event_Struc, 1)
  openr, Lun2, background , /Get_Lun
  For i = 0L, nevents1-1 do Begin

    readu, Lun2, Cal_event_Struc        ; read one event
    Back_Data[i] = Cal_event_Struc         ; add it to input array
  Endfor
  Free_lun, Lun2
  Print, 'Check1'
  ;
  ;Building Energy Histograms
  ;-- Define Source as Src, Bgd for Background. Main as bgd sub,.
  ;
  Avg_Lt_Src = Avg(Src_Data.Live_time)
  Avg_Lt_Back = Avg(Back_Data.Live_time)
  Scl_factor = Avg_lt_Src*Scale/(Avg_lt_back)

  ; 
  ; == Need Statistics and Plots ==
  ;
  ;NOTE: There is a Source and background
  ;
  
  
  ;
  ;-- PC --
  ;
  Temp_SrcPC = CgHistogram(Src_Data[where((Src_Data.EvClass  EQ 3) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, MAX = 1000)
  Temp_BgdPC = Scl_factor*CgHistogram(Back_Data[where ((Back_Data.EvClass EQ 3) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, Max = 1000)
  PC_Hist = Temp_SrcPC - Temp_BgdPC 
  
  ;
  ;-- C --
  ;
  Temp_SrcC = CgHistogram(Src_Data[where((Src_Data.EvClass  EQ 1) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, MAX = 1000)
  Temp_BgdC = Scl_factor*CgHistogram(Back_Data[where ((Back_Data.EvClass EQ 1) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, Max = 1000)
  C_Hist = Temp_SrcC - Temp_BgdC
  
  ;
  ;-- CC --
  ;
  Temp_SrcCC = CgHistogram(Src_Data[where((Src_Data.EvClass  EQ 2) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, MAX = 1000)
  Temp_BgdCC = Scl_factor*CgHistogram(Back_Data[where ((Back_Data.EvClass EQ 2) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, Max = 1000)
  CC_Hist = Temp_SrcCC - Temp_BgdCC
  
  ;
  ; -- PP --
  ;
  Temp_SrcPP = CgHistogram(Src_Data[where((Src_Data.EvClass  EQ 4) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, MAX = 1000)
  Temp_BgdPP = Scl_factor*CgHistogram(Back_Data[where ((Back_Data.EvClass EQ 4) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, Max = 1000)
  PP_Hist = Temp_SrcPP - Temp_BgdPP
  
  ;
  ; -- P --
  ;
  Temp_SrcP = CgHistogram(Src_Data[where((Src_Data.EvClass  EQ 5) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, MAX = 1000)
  Temp_BgdP = Scl_factor*CgHistogram(Back_Data[where ((Back_Data.EvClass EQ 5) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, Max = 1000)
  P_Hist = Temp_SrcP - Temp_BgdP
  
  ;
  ; -- PPC --
  ;
  Temp_SrcPPC = CgHistogram(Src_Data[where((Src_Data.EvClass  EQ 6) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, MAX = 1000)
  Temp_BgdPPC = Scl_factor*CgHistogram(Back_Data[where ((Back_Data.EvClass EQ 6) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, Max = 1000)
  PPC_Hist = Temp_SrcPPC - Temp_BgdPPC
  
  ;
  ; -- Rest --
  ;
  Temp_SrcOther = CgHistogram(Src_Data[where((Src_Data.EvClass  EQ 7) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, MAX = 1000)
  Temp_BgdOther = Scl_factor*CgHistogram(Back_Data[where ((Back_Data.EvClass EQ 7) )].TotEnrg, Binsize=Bin,Locations=XArray, MIN=0, Max = 1000)
  Other_Hist = Temp_SrcOther - Temp_BgdOther
  
  ;
  ; -- Invalid --
  ;


  Sts_total = NEvents-Scl_factor*NEvents1
  Sts_C     = Total(C_Hist)
  Sts_CC    = Total(CC_Hist)
  Sts_PC    = Total(PC_Hist)
  Sts_PP    = Total(PP_Hist)
  Sts_P     = Total(P_Hist)
  Sts_PPC   = Total(PPC_Hist)
  Sts_Other = Total(Other_Hist)
  
  Sts_Sum = Sts_C+ Sts_Cc+ Sts_Pc+ Sts_PP + Sts_P+ Sts_PPC+Sts_Other
  Sts_Array=[Sts_C,Sts_Cc,Sts_Pc,Sts_PP,Sts_P,Sts_PPC,Sts_Other]
  Sts_txt_Array = [ 'C', 'CC', 'PC', 'PP', 'P', 'PPC', 'Other']
  Sts_Color =[ 'Sea Green', 'Green', 'Sky Blue', 'Royal Blue', 'Blue Violet', 'Blue','Orange Red']
  Sts_Txt1_Array =String(format='(D5.1,X)',(100*Sts_Array/Total(Sts_Array)))+'% ('+Strn(Sts_Array)+')'
  
  Print,(Sts_Array*100/TOtal(Sts_Array))
  
  cgPS_Open, Title+'_Msim_l1_quicklook.ps', XSize=5, YSize=6,/NoMatch, Landscape=0,/Inch, Font=1

  cgDisplay, 512, 640
  cgLoadCT, 13
          
          CgText, !D.X_Size*0.25,!D.Y_Size*1.01, Title,/Device,Charsize=3.0
        
          CgText,!D.X_Size*0.05,!D.Y_Size*0.88, 'Source File      : '+file,/Device,Charsize=1.0
          CgText,!D.X_Size*0.05,!D.Y_Size*0.85, 'Background File  : '+background,/Device,Charsize=1.0
         ; CgText,!D.X_Size*0.05,!D.Y_Size*0.82, 'Source Position : '+STRN(Data.In_XPos)+'  '+STRN(Data.In_YPos)+'  '+STRN(Data.In_ZPos),/Device,Charsize=1.3
          CgText,!D.X_Size*0.05,!D.Y_Size*0.79, 'Date and Time   : '+Systime(),/Device,Charsize=1.3
        
        
          ;
          ;--- Statistics ---
          ;
          Pie, Sts_Array, Colors=CgColor([sts_Color]),  /Device,Radius = !D.X_Size*0.25 , Xpos = !D.X_Size*0.3, YPos=!D.Y_Size*0.4
        
          CgLegend, Titles=Sts_Txt1_Array , Location=[0.73,0.55],/Box,   Length=0.04,PSYM=0,Alignment=0, VSpace=3.0, Bx_Color=CgColor('WHite'),Colors=CgColor([Sts_Color]),Charsize=1.5
        
          CgLegend, Titles=Sts_txt_Array, Location=[0.63,0.55],/Box, PSYMS=15, Length=0.0, SymColors=CgColor([Sts_Color]),$
            VSpace=3.0, SymSize=3.0
        
          Temp_CgText = ' Statistics of Various Events'
          CgText,!D.X_Size*0.17,!D.Y_Size*0.63, Temp_CgText,/Device,Charsize=2.0
        
          CgText,!D.X_Size*0.75,!D.Y_Size*0.63, 'Total Events:'+STRN(Sts_Sum),/Device,Charsize=1.5
          
          Xval = XArray+Bin/2.0
         
  CgErase

          ;-------------------- 1 -----------------
          lay_n =1
          X_Title = 'Energy (keV)'
          Y_Title = 'Counts'
          P_Title = 'C Events (Total Energy)'

          Temp_hist = C_Hist
         
          Cgplot,XVal, Temp_Hist, PSYM=10, XTitle = X_Title, Title=P_Title, YTitle=Y_Title,Charsize=1.5,$
            XRange =[0,XMax], XStyle=1, $
            Position =CgLayout([2,2,1], xgap=0, ygap=0, oxmargin=[6,10], oymargin =[20,5]),/noerase,$
           Yrange=[1,Max(Temp_hist)*2],Ystyle=1,/Ylog

          lay_n=2
          X_Title = 'Energy (keV)'
          Y_Title = 'Counts'
          P_Title = 'CC Events (Total Energy)'

          Temp_hist = CC_Hist
          
          Txt_Bin = String(Format='(D5.1,X)', Bin)

          CgText, !D.X_Size*0.25,!D.Y_Size*1.01, Title,/Device,Charsize=3.0
          CgText, !D.X_Size*0.75,!D.Y_Size*0.97, 'BinSize ='+ Txt_Bin,/Device,Charsize=1.5



          Cgplot,XVal, Temp_Hist, PSYM=10, XTitle = X_Title, Title=P_Title, YTitle=Y_Title,Charsize=1.5,$
            XRange =[0,XMax], XStyle=1, $
            Position =CgLayout([2,2,2], xgap=0, ygap=0, oxmargin=[13,5], oymargin =[20,5]),/noerase,$
            Yrange=[1,Max(Temp_hist)*2],Ystyle=1,/Ylog
   
            
          lay_n=3
          X_Title = 'Energy (keV)'
          Y_Title = 'Counts'
          P_Title = 'P Events (Total Energy)'

          Temp_hist = P_Hist

          Cgplot,XVal, Temp_Hist, PSYM=10, XTitle = X_Title, Title=P_Title, YTitle=Y_Title,Charsize=1.5,$
            XRange =[0,XMax], XStyle=1, $
            Position =CgLayout([2,2,3], xgap=0, ygap=0, oxmargin=[6,10], oymargin =[5,15]),/noerase,$
            Yrange=[1,Max(Temp_hist)*2],Ystyle=1,/Ylog


          lay_n=4
          X_Title = 'Energy (keV)'
          Y_Title = 'Counts'
          P_Title = 'PP Events (Total Energy)'

          Temp_hist = PP_Hist

          Cgplot,XVal, Temp_Hist, PSYM=10, XTitle = X_Title, Title=P_Title, YTitle=Y_Title,Charsize=1.5,$
            XRange =[0,XMax], XStyle=1, $
            Position =CgLayout([2,2,4], xgap=0, ygap=0, oxmargin=[13,5], oymargin =[5,15]),/noerase,$
            Yrange=[1,Max(Temp_hist)*2],Ystyle=1,/Ylog

  cgErase
          Txt_Bin = String(Format='(D5.1,X)', Bin)

          CgText, !D.X_Size*0.25,!D.Y_Size*1.01, Title,/Device,Charsize=3.0
          CgText, !D.X_Size*0.75,!D.Y_Size*0.97, 'BinSize ='+ Txt_Bin,/Device,Charsize=1.5

          ;--------------- 2 --------------
          lay_n =1
          X_Title = 'Energy (keV)'
          Y_Title = 'Counts'
          P_Title = 'PC Events (Total Energy)'

          Temp_hist = PC_Hist

          Cgplot,XVal, Temp_Hist, PSYM=10, XTitle = X_Title, Title=P_Title, YTitle=Y_Title,Charsize=1.5,$
            XRange =[0,XMax], XStyle=1, $
            Position =CgLayout([2,2,1], xgap=0, ygap=0, oxmargin=[6,10], oymargin =[20,5]),/noerase,$
            Yrange=[1,Max(Temp_hist)*2],Ystyle=1,/Ylog

          lay_n=2
          X_Title = 'Energy (keV)'
          Y_Title = 'Counts'
          P_Title = 'PPC Events (Total Energy)'

          Temp_hist = PPC_Hist

          Cgplot,XVal, Temp_Hist, PSYM=10, XTitle = X_Title, Title=P_Title, YTitle=Y_Title,Charsize=1.5,$
            XRange =[0,XMax], XStyle=1, $
            Position =CgLayout([2,2,2], xgap=0, ygap=0, oxmargin=[13,5], oymargin =[20,5]),/noerase,$
            Yrange=[1,Max(Temp_hist)*2],Ystyle=1,/Ylog

          ;
          ;-- Special plot.            ;
          ;


          X_Title = 'Energy (keV)'
          Y_Title = 'Counts'
          P_Title = 'PC Events'

          Temp_hist = PC_Hist

          Cgplot,XVal, Temp_Hist, PSYM=10, XTitle = X_Title, Title=P_Title, YTitle=Y_Title,Charsize=1.5,$
            XRange =[0,XMax], XStyle=1, $
            Position =CgLayout([2,2,3], xgap=0, ygap=0, oxmargin=[6,-42.5], oymargin =[5,10]),/noerase

         
  cgPS_Close
  Temp_Str = Title+'_Msim_l1_quicklook.ps'
  CGPS2PDF, Temp_Str,delete_ps=1

  Stop
End