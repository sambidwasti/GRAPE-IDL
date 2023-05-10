pro GRP_hrs_onboard_quicklook, fsearch_string, nfiles=nfiles, iverbose=iverbose, title=title, Skip = SKip

; Program to read in the onboard SCC HRS files. 
; It reads in and outputs these files. 
;  1. hrs_ac_data
;  2. RotaionTableData
;

;;-- Updated S. Wasti
  ;   Updated to generate one extra text file.
  ;   Added a keyword to skip the plots .
  
;
;August 20, 2018  Sambid Wasti
;   - Adding comments to make the program more understandable.
;   


True = 1
False = 0

iverbose = 0
if keyword_set(iverbose) eq 1 then print, 'iverbose set'
if keyword_set(iverbose) ne 1 then print, 'iverbose not set'

If Keyword_Set(Skip) NE 0 Then SKip_flag = True else Skip_Flag = False

if n_params() ne 1 then fsearch_string = 'HRS-*.dat'  ; Naming of the file.
hrsfiles = FILE_SEARCH(fsearch_string)   ; get list of hrs files in current directory


if keyword_set(nfiles) ne 1 then nfiles = n_elements(hrsfiles)
 ; number of hrs files in current directory



adu = 		{	fpktno:0L, $
				ppscnt:0B, $
				status:0B, $
				rs_enabled:0, $
				rs_homed:0, $
				rs_inpos:0, $
				rs_active:0, $
				rs_poserr:0, $
				rs_ovrcur:0, $
				ovrflw:0U, $
				azimin:0U, $
				azimax:0U, $
				elev:0U, $
				time:0U }
				
				
cycle =    {	fpktno:0L, $
				time:0L, $
				pos:0, $
				step:0, $
				state:0B  }
				

fpktno = 0L


;
;*********************************************************************
; Open text file to output AC data.  
;
if keyword_set(title) ne 1 then begin
		title = ''
		OPENW,  ac_unit, 'hrs_ac_data.txt', width = 120, /GET_LUN
		openw, ac_unit2, 'RotationTableData.txt', /Get_lun
	endif else begin
		OPENW,  ac_unit, title + '_hrs_ac_data.txt', width = 120, /GET_LUN
		openw, ac_unit2, title+'_RotationTableData', /Get_lun
endelse
;
;Header of the files.
;
printf, ac_unit, format='(C())', systime(/julian)
printf, ac_unit, 'HRS DATA FILE - AC DATA'
printf, ac_unit, ' '
printf, ac_unit, 'GPS_TIME, RT_ANGLE, RT_STEP, RT_STATUS, AZIMIN, AZIMAX, ELEV'

printf, ac_unit2, 'Rotation Table Data for the auxpath.'
printf, ac_unit2, ' '
printf, ac_unit2, 'rt_time gps_time rt_swtime rt_stat rt_Step rt_angle'

first_flag = True
for ifile = 0, nfiles-1 do begin
	filename = hrsfiles[ifile]
	print
	print, '=================================================================='
	print, '=================================================================='
	print, ifile+1, format = '("File no. ",I3)'
	print, filename, format = '("Filename = ",A23)'
;
;	Extract file start time from filename, which has the form:
;         lrs-YYYYMMDDHHMMSS.dat
;
	file_year 	= fix(strmid(filename,4,4))
	file_month 	= fix(strmid(filename,8,2))
	file_day 	= fix(strmid(filename,10,2))
	file_hrs 	= fix(strmid(filename,13,2))
	file_mins 	= fix(strmid(filename,15,2))
	file_secs 	= fix(strmid(filename,17,2))
	file_jd     = julday(file_month, file_day, file_year, file_hrs, file_mins, file_secs)
; 
; Day of week specified as one of the following:
;			0 = Sunday
;			1 = Monday
;			2 = Tuesday
; 			3 = Wednesday
; 			4 = Thursday
;			5 = Friday
;			6 = Saturday
;
	file_dow    = fix(string(file_jd, format = '(C(CDWA))', DAYS_OF_WEEK=['0','1','2','3','4','5','6']))
;

	adudata = replicate(adu, 36000)
	cycdata = replicate(cycle, 3600)

	openr, unit, filename, /GET_LUN          	; open input data file
	data = READ_BINARY(unit)                  	; read in all of the data at once
	free_lun, unit
	nbytes = n_elements(data)           	; total number of bytes in file

	ifirst = 0L
	

	n_bd = 0L			; Number of BD packets
	n_ad = 0L			; Number of AD packets
	n_bc = 0L			; Number of BC packets
	n_ac = 0L			; Number of AC packets
	n_cd = 0L			; Number of CD packets
	
	nadu = 0L			; Number of ADU blocks
	ncyc = 0L			; Number of cycle blocks
;
;	Try to prevent overflow on this array...
;
	while ifirst lt nbytes-100 do begin 
;	while ifirst lt nbytes-1 do begin 
	
	; data[ifirst] must be 0xBB for high rate science data
;
;*****************************************************************************************
; DATA BLOCK TYPE 'BD'
; One or more Detector Module Data Blocks
;
	if data[ifirst+1] eq 'BD'x then begin
;		print, '*****************'
;		print, data[ifirst:ifirst+39], format='(40(Z2.2,1X))'
		pkt_type   = data[ifirst+1]
		pkt_seqno  = data[ifirst+2]
		ndata 	   = data[ifirst+3]
		pkt_length = 6 + ndata*4
	endif

	
	n_bd = n_bd + 1
;
;*****************************************************************************************
; DATA BLOCK TYPE 'AD'
; ADU Data Block plus zero or more Detector Module Data Blocks
;
	if data[ifirst+1] eq 'AD'x then begin 
;		print, '*****************'
;		print, data[ifirst:ifirst+39], format='(40(Z2.2,1X))'
		pkt_type   = data[ifirst+1]
		pkt_seqno  = data[ifirst+2]
		ndata 	   = data[ifirst+3]
		pkt_length = 6 + ndata*4
;>>>>>>>	
	    adu.fpktno = fpktno
	    adu.ppscnt = fix(data,ifirst+4,type=1)
	    adu.status = fix(data,ifirst+5,type=1)
	    adu.rs_enabled = ishft(adu.status and '00000001'B,  0)
	    adu.rs_homed   = ishft(adu.status and '00000010'B, -1)
	    adu.rs_inpos   = ishft(adu.status and '00000100'B, -2)
	    adu.rs_active  = ishft(adu.status and '00001000'B, -3)
	    adu.rs_poserr  = ishft(adu.status and '00010000'B, -4)
	    adu.rs_ovrcur  = ishft(adu.status and '00100000'B, -5)
	    adu.ovrflw = swap_endian(fix(data,ifirst+6,type=12))
	    adu.azimin = fix(data,ifirst+8,type=12)
	    adu.azimax = fix(data,ifirst+10,type=12)
	    adu.elev   = fix(data,ifirst+12,type=12)
	    adu.time   = fix(data,ifirst+14,type=12)
;>>>>>>>		    
		if iverbose eq 1 then begin 
			print, fpktno,          format = '("File Packet No. = ",I12)'
			print, pkt_type, 		format = '("Packet Type     = ",Z2.2)'
			print, pkt_seqno, 		format = '("Sequence Number = ",I12)'
			print, ndata,	 		format = '("No. Data Words  = ",I12)'
			print, pkt_length, 		format = '("Packet Length   = ",I12)'			
			print, adu.ppscnt, 		format = '("ADU PPS Count   = ",I12)'
			print, adu.status, 		format = '("ADU Status      = ",I12)'
			print, adu.ovrflw, 		format = '("ADU Overflow    = ",I12)'
			print, adu.azimin, 		format = '("ADU Azim Min    = ",I12)'
			print, adu.azimax, 		format = '("ADU Azim Max    = ",I12)'
			print, adu.elev, 		format = '("Incl Elevation  = ",I12)'
			print, adu.time, 		format = '("Incl Time       = ",I12)'
		endif
;>>>>>>>
		adudata[nadu] = adu
;>>>>>>>
		n_ad = n_ad + 1
		nadu = nadu + 1
	endif
;
;*****************************************************************************************
; DATA BLOCK TYPE 'BC'
; Cycle Data Block plus zero or more Detector Module Data Blocks
;
	if data[ifirst+1] eq 'BC'x then begin
		n_bc = n_bc + 1
		pkt_type   = data[ifirst+1]
		pkt_seqno  = data[ifirst+2]
		ndata 	   = data[ifirst+3]
		pkt_length = 6 + ndata*4
;		
		if iverbose eq 1 then begin 
			print, '*****************'
			print, data[ifirst:ifirst+39], format='(40(Z2.2,1X))'
			print, fpktno,          format = '("File Packet No. = ",I12)'
			print, pkt_type, 		format = '("Packet Type     = ",Z2.2)'
			print, pkt_seqno, 		format = '("Sequence Number = ",I12)'
			print, ndata,	 		format = '("No. Data Words  = ",I12)'
			print, pkt_length, 		format = '("Packet Length   = ",I12)'			
		endif
	endif
;
;*****************************************************************************************
; DATA BLOCK TYPE 'AC'
; One cycle packet, one ADU packet, plus zero or more Detector Module Data blocks.
;
;>>> 
	if data[ifirst+1] eq 'AC'x then begin
;		print, '*****************'
;		print, data[ifirst:ifirst+39], format='(40(Z2.2,1X))'
		pkt_type   = data[ifirst+1]
		pkt_seqno  = data[ifirst+2]
		ndata 	   = data[ifirst+3]
		pkt_length = 6 + ndata*4
;>>>>>>>
		cycle.fpktno = fpktno
		cycle.time   = fix(data,ifirst+8,type=13)

		cycle.pos    = fix(data,ifirst+12,type=12)
		cstep        = fix(data,ifirst+14,type=1)
		aa = ishft(cstep, -7)
		if aa eq 1 then begin
			cycle.step = -1 * (not(cstep)+1) 
			endif else begin
			cycle.step = cstep
		endelse
		
		;
		;-- SW added
		;
		If first_flag Eq true  then begin
		  
		  first_time = cycle.time
		  print, first_Time
		  Firstsw_time = cycle.time
		  first_flag = false
		Endif
		
		If Cycle.state eq 4 Then FirstSw_Time = cycle.time 
		
		
		
		cycle.state  = fix(data,ifirst+15,type=1)
;>>>>>>>	
	    adu.fpktno = fpktno
	    adu.ppscnt = fix(data,ifirst+16,type=1)
	    adu.status = fix(data,ifirst+17,type=1)
	    adu.rs_enabled = ishft(adu.status and '00000001'B,  0)
	    adu.rs_homed   = ishft(adu.status and '00000010'B, -1)
	    adu.rs_inpos   = ishft(adu.status and '00000100'B, -2)
	    adu.rs_active  = ishft(adu.status and '00001000'B, -3)
	    adu.rs_poserr  = ishft(adu.status and '00010000'B, -4)
	    adu.rs_ovrcur  = ishft(adu.status and '00100000'B, -5)
	    adu.ovrflw = swap_endian(fix(data,ifirst+18,type=12))
	    adu.azimin = fix(data,ifirst+20,type=12)
	    adu.azimax = fix(data,ifirst+22,type=12)
	    adu.elev   = fix(data,ifirst+24,type=12)
	    adu.time   = fix(data,ifirst+26,type=12)
;>>>>>>>		    
		if iverbose eq 1 then begin 
			print, fpktno,          format = '("File Packet No. = ",I12)'
			print, pkt_type, 		format = '("Packet Type     = ",Z2.2)'
			print, pkt_seqno, 		format = '("Sequence Number = ",I12)'
			print, ndata,	 		format = '("No. Data Words  = ",I12)'
			print, pkt_length, 		format = '("Packet Length   = ",I12)'			
			print, cycle.time, 		format = '("Cycle Time      = ",I12)'
			print, cycle.pos, 		format = '("Cycle Position  = ",I12)'
			print, cycle.step, 		format = '("Cycle Step Size = ",I12)'
			print, cycle.state, 	format = '("Cycle State     = ",I12)'
			print, adu.azimin,		format = '("Azimuth Min     = ",F8.2)'
			print, adu.azimax,		format = '("Azimuth Max     = ",F8.2)'
			print, adu.elev,		format = '("Elevation       = ",F8.2)'
		endif
;		print, adu.ppscnt, 		format = '("ADU PPS Count   = ",I12)'
;		print, adu.status, 		format = '("ADU Status      = ",I12)'
;		print, adu.ovrflw, 		format = '("ADU Overflow    = ",I12)'
;		print, adu.azimin, 		format = '("ADU Azim Min    = ",I12)'
;		print, adu.azimax, 		format = '("ADU Azim Max    = ",I12)'
;		print, adu.elev, 		format = '("Incl Elevation  = ",I12)'
;		print, adu.time, 		format = '("Incl Time       = ",I12)'

		cycdata[ncyc] = cycle
		adudata[nadu] = adu

		n_ac = n_ac + 1
		ncyc = ncyc + 1
		nadu = nadu + 1
;
		printf, ac_unit, cycle.time, cycle.pos,  cycle.step, cycle.state,   $
						 adu.azimin/100.0, adu.azimax/100.0, adu.elev/10.0, $	
	           			 format = '(1X,I12, 2X, I8, 1X, I4, 1X, I2, 3(1X,F8.2))'

    ;
    ;-- SW Added
    ;
    rttime = Long( (cycle.time-First_time)/1000)
    EvtTime = Fix( Abs(cycle.time - Firstsw_time) /1000)
   
    ;
    ;-- SW added this to fix the rttime going lt 0
    ;
    if rttime lt 0 Then rttime = rttime+ 604800

    ;
    ; '1' is the sweep no. just for the calibration file for which this is not that important.
    ; This file for the flight was generated via Excel sheet. so the sweep no. was there.
    ;
    printf, ac_unit2,  rttime, cycle.time/1000,EvtTime, ' 1 ' , cycle.state, cycle.step, cycle.pos
	endif
;>>>
;
;*****************************************************************************************
; DATA BLOCK TYPE 'CD'
; C Event Histogram Data
;
	if data[ifirst+1] eq 'CD'x then begin
;		print, '*****************'
;		print, data[ifirst:ifirst+39], format='(40(Z2.2,1X))'
		pkt_type   = data[ifirst+1]
		pkt_seqno  = data[ifirst+2]
		ndata 	   = data[ifirst+3]
		pkt_length = 6 + ndata*4
	endif
	
	n_cd = n_cd + 1
;
;*****************************************************************************************
	
	ifirst = ifirst + pkt_length 
	
	fpktno = fpktno + 1L


endwhile

	           			 
	

adudata = adudata[0:nadu-1]
cycdata = cycdata[0:ncyc-1]


if iverbose eq 1 then begin 
	
	print, n_bd, format = '("No. of Detector Module Data Blocks        = ", I6)'
	print, n_ad, format = '("No. of ADU / Detector Data Blocks         = ", I6)'
	print, n_bc, format = '("No. of Cycle / Detector Data Blocks       = ", I6)'
	print, n_ac, format = '("No. of ADU / Cycle / Detector Data Blocks = ", I6)'
	print, n_cd, format = '("No. of C Event Histograms                 = ", I6)'
endif 

if ifile eq 0 then begin
	aduall = adudata
	cycall = cycdata
	totcyc = ncyc
	totadu = nadu
endif
;
if ifile ne 0 then begin 
	aduall = [aduall, adudata]
	cycall = [cycall, cycdata]
	totcyc = totcyc + ncyc
	totadu = totadu + nadu
endif

;
;   End of this file.  Close this file (calling free_lun closes the file and frees up 
;   the file unit number) and go get next one.
;
free_lun, unit

endfor 


close, ac_unit


If Skip_Flag EQ False Then Begin
;
;*****************************************************************************************
; Open a postscript file for plotting.
;

if keyword_set(title) ne 1 then begin
			title = ''
			cgPS_Open, 'hrs_onboard_quicklook.ps'
			cgDisplay, 550, 800
			cgLoadCT, 13
	endif else begin
			cgPS_Open, file=title+'_hrs_onboard_quicklook.ps'	
			cgDisplay, 550, 800
			cgLoadCT, 13
endelse

;
A = FINDGEN(17) * (!PI*2/16.)
USERSYM, COS(A), SIN(A), /FILL
;
;*****************************************************************************************
;  congrid
;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_enabled,512), yrange = [0,2], title = 'Rotary Stage Enabled', $
			xtickformat = '(I5)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_homed,512),   yrange = [0,2], title = 'Rotary Stage Homed', $
			xtickformat = '(I5)', xtitle = 'File Packet Number',  psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_inpos,512),   yrange = [0,2], title = 'Rotary Stage In-Position', $
			xtickformat = '(I5)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,3], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'Onboard HRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase


;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_active,512),  yrange = [0,2], title = 'Rotary Stage Move Active', $
			xtickformat = '(I5)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_poserr,512),  yrange = [0,2], title = 'Rotary Stage Position Error', $
			xtickformat = '(I5)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase


;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_ovrcur,512),  yrange = [0,2], title = 'Rotary Stage Over Current', $
			xtickformat = '(I5)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,3], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'Onboard HRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase


;*****************************************************************************************
;
;
cgPlot, congrid(cycall.fpktno,512), congrid(cycall.pos,512), title = 'Rotary Stage Position', ytitle = 'Table Angle (degs)', $
			xtickformat = '(I5)', xtitle = 'File Packet Number', $
			psym=8, color = cgColor('Red'), symsize = 0.25, charsize = 1.5, $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
;
cgPlot, congrid(cycall.fpktno,512), congrid(cycall.step,512), yrange = [-5.0, 5.0], title = 'Rotary Stage Step Size', $
            ytitle = 'Step Size (degs)', xtickformat = '(I5)', xtitle = 'File Packet Number', $
            psym=8, color = cgColor('Red'), symsize = 0.25, charsize = 1.5, $
			Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'Onboard HRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase



;*****************************************************************************************
;
;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.azimin / 100.0,512), yrange = [0.0, 360.0], $
		title = 'ADU Azimuth', ytitle = 'Azimuth(degs)', xtickformat = '(I5)', xtitle = 'File Packet Number', $
		psym=8, color = cgColor('Red'), symsize = 0.25, charsize = 1.5, $
		Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;cgoplot, congrid(aduall.fpktno,512), congrid(aduall.azimax / 100.0,512), psym=8, color = cgColor('Blue'), symsize = 0.25
;
;
cgPlot, congrid(cycall.fpktno,512), congrid(cycall.time,512), title = 'Packet Number vs. Time', yrange = [min(cycall.time), max(cycall.time)], $
		ytitle = 'Step Size (degs)', xtickformat = '(I5)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.25, charsize = 1.5, $
		Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase


xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'Onboard HRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase

cgPS_Close

EndIf 



fitres = linfit(cycall.fpktno, cycall.time)


;
;*********************************************************************
; Output ADU data to a text file.  
;
if keyword_set(title) ne 1 then begin
		title = ''
		OPENW,  adu_unit, 'hrs_adu_data.txt', width = 120, /GET_LUN
	endif else begin
		OPENW,  adu_unit, title + '_hrs_adu_data.txt', width = 120, /GET_LUN
endelse
printf, adu_unit, format='(C())', systime(/julian)
printf, adu_unit, 'HRS DATA FILE - ADU DATA'
printf, adu_unit, ' '
printf, adu_unit, 'Need to put headers here.'
for i = 0, totadu-1 do begin
	printf, adu_unit, aduall[i].ppscnt,     aduall[i].rs_enabled, aduall[i].rs_homed,  $
	           aduall[i].rs_inpos,   aduall[i].rs_active, aduall[i].rs_poserr,  $
	           aduall[i].rs_ovrcur,  aduall[i].ovrflw, aduall[i].azimin,  $
	           aduall[i].azimax,     aduall[i].elev,  aduall[i].time, $
	           format = '(I3,6(1X,I1), I6,1X,I6,1X,I6, 1X,I6,1X,I6)'
endfor
close, /all
;

;
;*********************************************************************
; Output cycle data to a text file.  
;
if keyword_set(title) ne 1 then begin
		title = ''
		OPENW,  cyc_unit, 'hrs_cycle_data.txt', width = 120, /GET_LUN
	endif else begin
		OPENW,  cyc_unit, title + '_hrs_cycle_data.txt', width = 120, /GET_LUN
endelse
printf, cyc_unit, format='(C())', systime(/julian)
printf, cyc_unit, 'HRS DATA FILE - CYCLE DATA'
printf, cyc_unit, ' '
printf, cyc_unit, 'GPS_Time         RT_Position    RT_StepSize     RT_State'
for i = 0, totcyc-1 do begin
	printf, cyc_unit, 	cycall[i].time,     cycall[i].pos,   $
	           			cycall[i].step,     cycall[i].state, $
	           			format = '(1X,I12, 2X, I8, 1X, I4, 1X, I2)'
endfor
close, /all
;

;

stop

end
		

		

