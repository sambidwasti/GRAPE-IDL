pro GRP_hrs_quicklook, fsearch_string, nfiles=nfiles, iverbose=iverbose, title = title




if keyword_set(iverbose) eq 1 then begin
	print, 'iverbose set'
	iverbose = 1
endif 
if keyword_set(iverbose) ne 1 then begin
	print, 'iverbose not set'
	iverbose = 0
endif

if n_params() ne 1 then fsearch_string = 'hrs-*.dat'
hrsfiles = FILE_SEARCH(fsearch_string)   ; get list of hrs files in current directory


if keyword_set(nfiles) ne 1 then nfiles = n_elements(hrsfiles)
 ; number of hrs files in current directory


;
;  Here we define the structure to hold the final (appropriately
;  scaled) event data.
;
	event = {EVNO:0L, $
         TSEC1:0.0D, $
         TSEC2:0.0D, $
         TIME:0.0D, $
         GPSTIM:0.0D, $
         MCFLG:0, $
         MODID:0, $
         LIVTIM:0.0, $
         ACFLG:0, $
         EVTYPE:0, $
         NANODES:0, $
         ANODE:INTARR(8), $
         PHA: INTARR(8),  $
         ATYPE: INTARR(8) $
         }



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
				tabang:0U }
				
				
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
	endif else begin
		OPENW,  ac_unit, title + '_hrs_ac_data.txt', width = 120, /GET_LUN
endelse

printf, ac_unit, format='(C())', systime(/julian)
printf, ac_unit, 'HRS DATA FILE - AC DATA'
printf, ac_unit, ' '
printf, ac_unit, 'GPS_TIME, RT_ANGLE, RT_STEP, RT_STATUS, AZIMIN, AZIMAX, ELEV'



for ifile = 0, nfiles-1 do begin
	filename = hrsfiles[ifile]
	print
	print, '=================================================================='
	print, '=================================================================='
	print, ifile+1, format = '("File no. ",I3)'
	print, filename, format = '("Filename = ",A23)'
;
;	Extract file start time from filename, which has the form:
;         hrs-YYYYMMDDHHMMSS.dat
;
	file_year 	= fix(strmid(filename,4,4))
	file_month 	= fix(strmid(filename,8,2))
	file_day 	= fix(strmid(filename,10,2))
	file_hrs 	= fix(strmid(filename,12,2))
	file_mins 	= fix(strmid(filename,14,2))
	file_secs 	= fix(strmid(filename,16,2))
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

;
; Initialize Counters

	ifirst = 0L
	
	nhkd = 0L
	nlrs = 0L
	nhrs = 0L

	n_bd = 0L			; Number of BD packets
	n_ad = 0L			; Number of AD packets
	n_bc = 0L			; Number of BC packets
	n_ac = 0L			; Number of AC packets
	n_cd = 0L			; Number of CD packets
	
	nadu = 0L			; Number of ADU blocks
	ncyc = 0L			; Number of cycle blocks
;
;	Try to prevent overflow on this array...
;	nbytes is the total number of bytes in the file.
;
	while ifirst lt nbytes-100 do begin 
;
	pkt_origin  = data[ifirst+2]
	pkt_length 	= swap_endian(fix(data,ifirst+4,type=12))
	pkt_type   	= data[ifirst+7]
	pkt_seqno  	= data[ifirst+8]
	pkt_nwords 	= data[ifirst+9]                  ; number of 32-bit words
;
	if pkt_origin eq 0 then nhkd = nhkd+1         ; Science Stack Data
	if pkt_origin eq 1 then nlrs = nlrs+1         ; Low Rate Science Data
	if pkt_origin eq 2 then nhrs = nhrs+1         ; High Rate Science Data
	
; data[ifirst+6] must be 0xBB for high rate science data
;
;*****************************************************************************************
; DATA BLOCK TYPE 'BD'
; One or more Detector Module Data Blocks
;
	if pkt_type eq 'BD'x then begin
		n_bd = n_bd + 1
		
		if iverbose eq 1 then begin
			print, '******************'
			print, 'DATA BLOCK TYPE BD'
			print, data[ifirst:ifirst+39], format='(40(Z2.2,1X))'
			print, pkt_origin,  format = '("Packet Origin = ",I1)'
			print, pkt_length,  format = '("Packet Length = ",I5)'
			print, pkt_type,	format = '("Packet Type  = ",Z2.2)'
			print, pkt_seqno,   format = '("Packet SeqNo = ",I3)'
			print, pkt_nwords,  format = '("Packet Words = ",I3)'
		endif


		
		ebytes = pkt_nwords * 4				; number of bytes worth of event data
		evtcnt = 0							; event counter
		bytcnt = 0							; byte counter
		ib     = 0							; first byte of this Event
		
			
		evdata = data[ifirst+10:ifirst+10+ebytes-1]
;
;
;		
;
;  		tsecs1 gives time in units of seconds
;  		tsecs2 gives time in units of 20 microsecs
; 
	   	tsecs1 = swap_endian(fix(evdata,ib+1,type=12))     ; byte 1
	    tsecs2 = swap_endian(fix(evdata,ib+2,1,type=12))     ; bytes 2-3
	    
	    mcflag = ishft(evdata(ib+5), -7)
	    
	    modnum = evdata[ib+5] and '00011111'B
	    
;
;		acflag is anti-coincidence flag ('1' = coincident event)
;
		acflag = ishft(evdata(ib+6),-7)
	    
;
;		ptype is the packet type
;				ptype = 0  ==>  unused
;				ptype = 1  ==>  C event
;				ptype = 2  ==>  CC event
;				ptype = 3  ==>  PC event
;				ptype = 4  ==>  unused
;				ptype = 5  ==>  module threshold data
;				ptype = 6  ==>  module housekeeping
;				ptype = 7  ==>  module rates
;
		ptype = ishft(evdata[ib+6] and '01110000'B, -4)


		nanode = evdata(ib+6) and '00001111'B 
		
		
		ltime = evdata(ib+7)
		
	  	if (ptype ge 1 and ptype le 3) then begin
;
;       	nanode is the number of non-zero PHA values    ; byte 6, bits 0-3
;
			datawd = intarr(8)
			anode  = intarr(8)
			pha    = intarr(8)
;
;           extract anode number and PHA value from each of eight 16-bit words
;		
			for j = 0,nanode-1 do begin
				datawd[j] = swap_endian(fix(evdata,8+j*2,1,type=12))
				anode[j]  = ishft(datawd[j] and '1111110000000000'B, -10)
				pha[j]    = datawd[j] and '0000001111111111'B
			endfor	
;
;           >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 	        
 	        if iverbose eq 1 then begin
				typedef = ['unused','C type', 'CC type', 'PC Type', 'unused', 'Threshold', 'Housekeeping', 'Rates']  ;
				print, evdata, format = '(32(Z2.2,x))'
				print
				print, pcktid, format = '("Packet Id = ",I6)'
				print, tsecs1, format = '("Even Time1 (secs)       =  ",I5)'
				print, tsecs2, format = '("Even Time2 (20 mu-secs) =  ",I5)'
				print, tsecs1+tsecs2*0.000020, format = '("Even Time (secs)        =  ",F12.6)'
				print, mcflag, format = '("Module Coincidence Flag =   ",I1)'
				print, modnum, format = '("Module Id (0..31)       =  ",I2)'
				print, ltime,  format = '("Livetime (0..255)       = ",I3)'
				print, acflag, format = '("Module Coincidence Flag =   ",I1)'
				print, ptype, typedef[ptype],  format = '("Data Type               =   ",I1," (",A8,")")'
				print, nanode, format =       '("No. of Triggered Anodes =   ",I1)'
				for j = 0,nanode-1  do print, j+1, anode[j], pha[j], format =  '(I1,"-  Anode, PHA          =  ",I2,"  ",I8)
				print
			endif


stop

;           >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 	        
;
;			Fill event structure
;
			EVENT.EVNO = nevts[ifile]+1
			EVENT.TSEC1 = tsecs1
			EVENT.TSEC2 = tsecs2
			EVENT.TIME = tsecs1 + tsecs2*0.000020D
			EVENT.GPSTIM = swpt0 + tsecs1 + tsecs2*0.000020D
			EVENT.MCFLG = mcflag
			EVENT.MODID = modnum
			EVENT.LIVTIM = ltime
			EVENT.ACFLG = acflag
			EVENT.EVTYPE = ptype
			EVENT.NANODES = nanode
			EVENT.ANODE = anode
			EVENT.PHA = pha
			EVENT.ATYPE[*] = 0
			for j = 0,min([nanode,8])-1 do 	EVENT.ATYPE[j] = anode_type[anode[j]]
;
;			Add event to the event array
;	
			evdata[nevts[ifile]] = event
			nevts[ifile] = nevts[ifile] + 1

		endif
		
		


;		evdata[ib] - EVENT_ID0
;		evdata[ib+1] - TIME2
;		evdata[ib+2] - TIME1
;		evdata[ib+3] - TIME0
;		evdata[ib+4] - CHECK byte
;		evdata[ib+5] - ID_FIELD0
;		evdata[ib+6] - HEADER1
;		evdata[ib+7] - HEADER0
	
				
		
		
		
		
		
		
		
	endif

;
;*****************************************************************************************
; DATA BLOCK TYPE 'AD'
; ADU Data Block plus zero or more Detector Module Data Blocks
;
	if pkt_type eq 'AD'x then begin 
		n_ad = n_ad + 1
;
; Extract ADU data packet
;
	    adu.fpktno 		= fpktno
	    adu.ppscnt 		= fix(data,ifirst+10,type=1)
	    adu.status 		= fix(data,ifirst+11,type=1)
	    adu.rs_enabled  = ishft(adu.status and '00000001'B,  0)
	    adu.rs_homed   	= ishft(adu.status and '00000010'B, -1)
	    adu.rs_inpos   	= ishft(adu.status and '00000100'B, -2)
	    adu.rs_active  	= ishft(adu.status and '00001000'B, -3)
	    adu.rs_poserr  	= ishft(adu.status and '00010000'B, -4)
	    adu.rs_ovrcur  	= ishft(adu.status and '00100000'B, -5)
	    adu.ovrflw 		= swap_endian(fix(data,ifirst+12,type=12))
	    adu.azimin 		= fix(data,ifirst+14,type=12)
	    adu.azimax 		= fix(data,ifirst+16,type=12)
	    adu.elev   		= fix(data,ifirst+18,type=12)
	    adu.tabang   	= fix(data,ifirst+20,type=12)
;
		if iverbose eq 1 then begin
			print, '******************'
			print, 'DATA BLOCK TYPE AD'
			print, data[ifirst:ifirst+39], format='(40(Z2.2,1X))'
			print, pkt_origin,  format = '("Packet Origin = ",I1)'
			print, pkt_length,  format = '("Packet Length = ",I5)'
			print, pkt_type,	format = '("Packet Type  = ",Z2.2)'
			print, pkt_seqno,   format = '("Packet SeqNo = ",I3)'
			print, pkt_nwords,  format = '("Packet Words = ",I3)'
			print, fpktno,      format = '("File Packet No. = ",I12)'
			print, adu.ppscnt,  format = '("ADU PPS Count   = ",I12)'
			print, adu.status, 	format = '("ADU Status      = ",I12)'
			print, adu.ovrflw, 	format = '("ADU Overflow    = ",I12)'
			print, adu.azimin, 	format = '("ADU Azim Min    = ",I12)'
			print, adu.azimax, 	format = '("ADU Azim Max    = ",I12)'
			print, adu.elev, 	format = '("Incl Elevation  = ",I12)'
			print, adu.tabang, 	format = '("Incl Time       = ",I12)'
		endif
;>>>>>>>
		adudata[nadu] = adu
;>>>>>>>
		nadu = nadu + 1
	endif
;
;*****************************************************************************************
; DATA BLOCK TYPE 'BC'
; Cycle Data Block plus zero or more Detector Module Data Blocks
;
	if pkt_type eq 'BC'x then begin
		n_bc = n_bc + 1
		
		if iverbose eq 1 then begin 
			print, '******************'
			print, 'DATA BLOCK TYPE BC'
			print, data[ifirst:ifirst+39], format='(40(Z2.2,1X))'
			print, pkt_origin,  format = '("Packet Origin = ",I1)'
			print, pkt_length,  format = '("Packet Length = ",I5)'
			print, pkt_type,	format = '("Packet Type  = ",Z2.2)'
			print, pkt_seqno,   format = '("Packet SeqNo = ",I3)'
			print, pkt_nwords,  format = '("Packet Words = ",I3)'
		endif
	endif
;
;*****************************************************************************************
; DATA BLOCK TYPE 'AC'
; One cycle packet, one ADU packet, plus zero or more Detector Module Data blocks.
;
	if pkt_type eq 'AC'x then begin
		n_ac = n_ac + 1
;
		print, '******************'
		print, 'DATA BLOCK TYPE AC
		print, data[ifirst:ifirst+39], format='(40(Z2.2,1X))'
		print, pkt_origin,  format = '("Packet Origin = ",I1)'
		print, pkt_length,  format = '("Packet Length = ",I5)'
		print, pkt_type,	format = '("Packet Type  = ",Z2.2)'
		print, pkt_seqno,   format = '("Packet SeqNo = ",I3)'
		print, pkt_nwords,  format = '("Packet Words = ",I3)'
;
; Extract Cycle Data Packet
;
		cycle.fpktno = fpktno
		cycle.time   = fix(data,ifirst+14,type=13)
		cycle.pos    = fix(data,ifirst+18,type=12)
		cstep        = fix(data,ifirst+20,type=1)
		aa = ishft(cstep, -7)
		if aa eq 1 then begin
			cycle.step = -1 * (not(cstep)+1) 
			endif else begin
			cycle.step = cstep
		endelse
		cycle.state  = fix(data,ifirst+21,type=1)
;
; Extract ADU Data Packet
;
	    adu.fpktno 		= fpktno
	    adu.ppscnt 		= fix(data,ifirst+22,type=1)
	    adu.status 		= fix(data,ifirst+23,type=1)
	    adu.rs_enabled 	= ishft(adu.status and '00000001'B,  0)
	    adu.rs_homed   	= ishft(adu.status and '00000010'B, -1)
	    adu.rs_inpos   	= ishft(adu.status and '00000100'B, -2)
	    adu.rs_active  	= ishft(adu.status and '00001000'B, -3)
	    adu.rs_poserr  	= ishft(adu.status and '00010000'B, -4)
	    adu.rs_ovrcur  	= ishft(adu.status and '00100000'B, -5)
	    adu.ovrflw 		= swap_endian(fix(data,ifirst+24,type=12))
	    adu.azimin 		= fix(data,ifirst+26,type=12)
	    adu.azimax 		= fix(data,ifirst+28,type=12)
	    adu.elev   		= fix(data,ifirst+30,type=12)
	    adu.time   		= fix(data,ifirst+32,type=12)
;>>>>>>>		    
		if iverbose eq 1 then begin 
			print, fpktno,      format = '("File Packet No. = ",I12)'
			print, pkt_origin,  format = '("Packet Origin = ",I1)'
			print, pkt_length,  format = '("Packet Length = ",I5)'
			print, pkt_type,	format = '("Packet Type  = ",Z2.2)'
			print, pkt_seqno,   format = '("Packet SeqNo = ",I3)'
			print, pkt_nwords,  format = '("Packet Words = ",I3)'
			print, cycle.time, 		format = '("Cycle Time      = ",I12)'
			print, cycle.pos, 		format = '("Cycle Position  = ",I12)'
			print, cycle.step, 		format = '("Cycle Step Size = ",I12)'
			print, cycle.state, 	format = '("Cycle State     = ",I12)'
			print, adu.ppscnt,  format = '("ADU PPS Count   = ",I12)'
			print, adu.status, 	format = '("ADU Status      = ",I12)'
			print, adu.ovrflw, 	format = '("ADU Overflow    = ",I12)'
			print, adu.azimin, 	format = '("ADU Azim Min    = ",I12)'
			print, adu.azimax, 	format = '("ADU Azim Max    = ",I12)'
			print, adu.elev, 	format = '("Incl Elevation  = ",I12)'
			print, adu.time, 	format = '("Incl Time       = ",I12)'
		endif

		cycdata[ncyc] = cycle
		adudata[nadu] = adu

		ncyc = ncyc + 1
		nadu = nadu + 1
;
		printf, ac_unit, cycle.time, cycle.pos,  cycle.step, cycle.state,   $
						 adu.azimin/100.0, adu.azimax/100.0, adu.elev/10.0, $	
	           			 format = '(1X,I12, 2X, I8, 1X, I4, 1X, I2, 3(1X,F8.2))'

	endif
;>>>
;
;*****************************************************************************************
; DATA BLOCK TYPE 'CD'
; C Event Histogram Data
;
	if pkt_type eq 'CD'x then n_cd = n_cd + 1
;
;*****************************************************************************************
	
	ifirst = ifirst + pkt_length + 7 
	
	fpktno = fpktno + 1L


endwhile

	           			 
	

adudata = adudata[0:nadu-1]
cycdata = cycdata[0:ncyc-1]


if iverbose eq 1 then begin 
	print, nhkd
	print, nlrs
	print, nhrs
	
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



;
;*****************************************************************************************
; Open a postscript file for plotting.
;

if keyword_set(title) ne 1 then begin
			title = ''
			cgPS_Open, 'hrs_quicklook.ps'
			cgDisplay, 550, 800
			cgLoadCT, 13
	endif else begin
			cgPS_Open, file=title+'_hrs_quicklook.ps'	
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
			xtickformat = '(I7)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_homed,512),   yrange = [0,2], title = 'Rotary Stage Homed', $
			xtickformat = '(I7)', xtitle = 'File Packet Number',  psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_inpos,512),   yrange = [0,2], title = 'Rotary Stage In-Position', $
			xtickformat = '(I7)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,3], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'Onboard HRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase


;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_active,512),  yrange = [0,2], title = 'Rotary Stage Move Active', $
			xtickformat = '(I7)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_poserr,512),  yrange = [0,2], title = 'Rotary Stage Position Error', $
			xtickformat = '(I7)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase


;
cgPlot, congrid(aduall.fpktno,512), congrid(aduall.rs_ovrcur,512),  yrange = [0,2], title = 'Rotary Stage Over Current', $
			xtickformat = '(I7)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.15, charsize = 1.5, $
			Position= cgLayout([1,3,3], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'Onboard HRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase


;*****************************************************************************************
;
;
cgPlot, congrid(cycall.fpktno,512), congrid(cycall.pos,512), title = 'Rotary Stage Position', ytitle = 'Table Angle (degs)', $
			xtickformat = '(I7)', xtitle = 'File Packet Number', $
			psym=8, color = cgColor('Red'), symsize = 0.25, charsize = 1.5, $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;
;
cgPlot, congrid(cycall.fpktno,512), congrid(cycall.step,512), yrange = [-5.0, 5.0], title = 'Rotary Stage Step Size', $
            ytitle = 'Step Size (degs)', xtickformat = '(I7)', xtitle = 'File Packet Number', $
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
		title = 'ADU Azimuth', ytitle = 'Azimuth(degs)', xtickformat = '(I7)', xtitle = 'File Packet Number', $
		psym=8, color = cgColor('Red'), symsize = 0.25, charsize = 1.5, $
		Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

;cgoplot, congrid(aduall.fpktno,512), congrid(aduall.azimax / 100.0,512), psym=8, color = cgColor('Blue'), symsize = 0.25
;
;
cgPlot, congrid(cycall.fpktno,512), congrid(cycall.time,512), title = 'Packet Number vs. Time', $
		yrange = [min(cycall.time), max(cycall.time)], ytickformat = '(G10.4)', $
		ytitle = 'Step Size (degs)', xtickformat = '(I7)', xtitle = 'File Packet Number', psym=8, color = cgColor('Red'), symsize = 0.25, charsize = 1.5, $
		Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase


xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'Onboard HRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase

cgPS_Close, /pdf


;fitres = linfit(cycall.fpktno, cycall.time)


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
for i = 0, nadu-1 do begin
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
		

		

