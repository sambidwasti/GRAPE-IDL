pro GRP_lrs_onboard_quicklook, fsearch_string, nfiles=nfiles, iverbose=iverbose, title=title

;

;
; This routine currently requires SSWIDL (addtime routine)

;filename = 'lrs-20130121025705.dat'
;filename = 'lrs-20110918171150.dat'
;filename = 'lrs-20130121025705.dat'
;filename = 'lrs-20110923223640.dat'      			; flight data

; It looks like a science data packet in the file should look like:
; 0x10, 0x53, <len>, data ... , 0x03
; The len seems to always be 255 (0xFF).  
; The internal structure  of the data block should be the same as in the GSE files. 


if keyword_set(iverbose) ne 1 then iverbose = 0


if n_params() ne 1 then fsearch_string = 'LRS-*.dat'

lrs_packet = {	JD:0.0D, $
				CSBF_LON:0.0, $
				CSBF_LAT:0.0, $
         		CSBF_ALT:0.0, $
         		CSBF_SAT_STAT1:0B, $
         		CSBF_SAT_STAT2:0B, $
         		CSBF_GPS_TOW:0.0, $
         		CSBF_GPS_WKN:0, $
         		CSBF_GPS_TIMOFS:0.0, $
         		CSBF_GPS_CPUTIM:0.0, $
         		CSBF_MKS_HI:0, $
         		CSBF_MKS_MD:0, $
         		CSBF_MKS_LO:0, $
         		ADU5_PSA_TOW:0.0, $
         		ADU5_PSA_XPOS:0.0D, $
         		ADU5_PSA_YPOS:0.0D, $
         		ADU5_PSA_ZPOS:0.0D, $
         		ADU5_PSA_XVEL:0.0, $
         		ADU5_PSA_YVEL:0.0, $
         		ADU5_PSA_ZVEL:0.0, $
         		ADU5_PSA_CLKOFF:0.0, $
         		ADU5_PSA_FRQOFF:0.0, $
         		ADU5_PSA_POSDIL:0, $
         		ADU5_PSA_NUMSAT:0B, $
         		ADU5_PSA_POSMODE:0B, $
         		ADU5_PSA_YAW:0.0, $
         		ADU5_PSA_HEADING:0.0, $
         		ADU5_PSA_PITCH:0.0, $
         		ADU5_PSA_ROLL:0.0, $
         		ADU5_PSA_ATTSTATE:0B, $
         		ADU5_PSA_POSSTATE:0B, $
         		ADU5_PSA_CHKSUM:0U, $
         		ADU5_ATT_HEADING:0.0D, $
         		ADU5_ATT_PITCH:0.0D, $
         		ADU5_ATT_ROLL:0.0D, $
         		ADU5_ATT_MRMS:0.0D, $
         		ADU5_ATT_BRMS:0.0D, $
         		ADU5_ATT_TOW:0.0, $
         		ADU5_ATT_RESET:0B, $
         		ADU5_ATT_SPARE:0B, $
         		ADU5_ATT_CHKSUM:0U, $
         		INCLINOMETER:0.0, $
         		AC_TOTAL_RATE:0U, $
         		AC1_RATE:0U, $
         		AC2_RATE:0U, $
         		AC3_RATE:0U, $
         		AC4_RATE:0U, $
         		AC5_RATE:0U, $
         		AC6_RATE:0U, $
         		MIB_TEMP0:0.0, $
         		MIB_TEMP1:0.0, $
         		MIB_TEMP2:0.0, $
         		MIB_TEMP3:0.0, $
         		MIB_TEMP4:0.0, $
         		MIB_TEMP5:0.0, $
         		MIB_TEMP6:0.0, $
         		MIB_TEMP7:0.0, $
         		MIB_TEMP_MIB0:0.0, $
         		MIB_TEMP_MIB1:0.0, $
         		MIB_PRESS0:0.0, $
         		MIB_PRESS1:0.0, $
         		GPS_POWER:0.0, $
         		MIB_VOLTAGE_3:0.0, $
         		MIB_VOLTAGE_5:0.0, $
         		MIB_VOLTAGE_28:0.0, $
         		PC_COUNTS:0L, $
         		PC_FILTERED:0L, $
         		PC_OVERFLOW:0L, $
         		CC_COUNTS:0L, $
         		CC_FILTERED:0L, $
         		CC_OVERFLOW:0L, $
         		C_COUNTS:0L, $
         		C_FILTERED:0L, $
         		C_OVERFLOW:0L, $
         		OTHER:0L, $
         		ELEV_STATUS:0B }


				

lrsfiles = FILE_SEARCH(fsearch_string)   ; get list of lrs files in current directory


if keyword_set(nfiles) ne 1 then nfiles = n_elements(lrsfiles)
 ; number of gps files in current directory

;
;	Extract file start time from filename, which has the form:
;         LRS0-20140714_173628.dat
;         LRS0-yyyymmdd_hhmmss.dat
;
file_year  = long(strmid(lrsfiles[0:nfiles-1],5,4))
file_month = long(strmid(lrsfiles[0:nfiles-1],9,2))
file_day   = long(strmid(lrsfiles[0:nfiles-1],11,2))
file_hrs   = long(strmid(lrsfiles[0:nfiles-1],14,2))
file_mins  = long(strmid(lrsfiles[0:nfiles-1],16,2))
file_secs  = long(strmid(lrsfiles[0:nfiles-1],18,2))
;
file_jd    = julday(file_month, file_day, file_year, file_hrs, file_mins, file_secs)

;  Sunday, January 5, 2004 is start of GPS week 1774.
;
file_gpswk = fix((file_jd - julday(1,5,2014)) / 7) + 1774
;
jdmin       = file_jd[0]
jdmax       = julday(file_month[nfiles-1], file_day[nfiles-1], file_year[nfiles-1], file_hrs[nfiles-1], file_mins[nfiles-1]+20, file_secs[nfiles-1])
;
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
;
;*****************************************************************************************
; LOOP OVER INPUT FILES
;

for ifile = 0, nfiles-1 do begin
	filename = lrsfiles[ifile]
	print
	print, '=================================================================='
	print, '=================================================================='
	print, ifile+1, format = '("File no. ",I3)'
	print, filename, format = '("Filename = ",A23)'
;
;
	openr, unit, filename, /GET_LUN          	; open input data file
	data = READ_BINARY(unit)                  	; read in all of the data at once
	totpkt = n_elements(data) / 259            	; total number of packets in file

	lrsdata = replicate(lrs_packet, totpkt)
	ilrs = 0L

;
;   LOOP OVER ALL PACKETS IN THE FILE
;
	for i = 1L, totpkt do begin
		ifirst = (i-1)*259L   				    ; first byte for this packet
		ilast  = ifirst+258L      				; last byte for this packet
		pkt = data[ifirst:ilast]				; this packet
;
			lrs = pkt[3:257]
			lrs_packet.csbf_lon 		= float(lrs, 0)
			lrs_packet.csbf_lat 		= float(lrs, 4)
			lrs_packet.csbf_alt 		= float(lrs, 8)
			lrs_packet.csbf_sat_stat1	= lrs[12]
			lrs_packet.csbf_sat_stat2	= lrs[13]
			lrs_packet.csbf_gps_tow     = float(lrs,14)
			lrs_packet.csbf_gps_wkn		= fix(lrs,18, type=12)
			lrs_packet.csbf_gps_timofs  = float(lrs,20)
			lrs_packet.csbf_gps_cputim  = float(lrs,24)
			lrs_packet.adu5_psa_tow     = float(lrs,34)
			lrs_packet.adu5_psa_xpos    = double(lrs,38)
			lrs_packet.adu5_psa_ypos    = double(lrs,46)
			lrs_packet.adu5_psa_zpos    = double(lrs,54)
			lrs_packet.adu5_psa_heading = float(lrs,90)
			lrs_packet.adu5_psa_pitch   = float(lrs,94)
			lrs_packet.adu5_psa_roll    = float(lrs,98)
			lrs_packet.adu5_att_heading = double(lrs,106)
			lrs_packet.adu5_att_pitch   = double(lrs,114)
			lrs_packet.adu5_att_roll    = double(lrs,122)
			lrs_packet.inclinometer     = float(lrs,154)

			lrs_packet.ac_total_rate 	= fix(lrs,160,type=12)
			lrs_packet.ac1_rate 		= fix(lrs,162,type=12)
			lrs_packet.ac2_rate 		= fix(lrs,164,type=12)
			lrs_packet.ac3_rate 		= fix(lrs,166,type=12)
			lrs_packet.ac4_rate 		= fix(lrs,168,type=12)
			lrs_packet.ac5_rate 		= fix(lrs,170,type=12)
			lrs_packet.ac6_rate 		= fix(lrs,172,type=12)
			lrs_packet.mib_temp0 		= (float(fix(lrs,174,type=2)) / 204.6) * 200.4 -273.2
			lrs_packet.mib_temp1 		= (float(fix(lrs,176,type=2)) / 204.6) * 200.4 -273.2
			lrs_packet.mib_temp2 		= (float(fix(lrs,178,type=2)) / 204.6) * 200.4 -273.2
			lrs_packet.mib_temp3 		= (float(fix(lrs,180,type=2)) / 204.6) * 200.4 -273.2
			lrs_packet.mib_temp4 		= (float(fix(lrs,182,type=2)) / 204.6) * 200.4 -273.2
			lrs_packet.mib_temp5 		= (float(fix(lrs,184,type=2)) / 204.6) * 200.4 -273.2
			lrs_packet.mib_temp6 		= (float(fix(lrs,186,type=2)) / 204.6) * 200.4 -273.2
			lrs_packet.mib_temp7 		= (float(fix(lrs,188,type=2)) / 204.6) * 200.4 -273.2
			lrs_packet.mib_temp_mib0 	= (fix(lrs,190,type=12) / 204.6) * 200.4 -273.2
			lrs_packet.mib_temp_mib1 	= (fix(lrs,192,type=12) / 204.6) * 200.4 -273.2
			lrs_packet.mib_press0 		= (fix(lrs,194,type=12) / 204.6) * 15.0 -3.75
			lrs_packet.mib_press1 		= (fix(lrs,196,type=12) / 204.6) * 15.0 -3.75
			lrs_packet.gps_power 		= (fix(lrs,198,type=12) / 204.6) * 2.0 
			lrs_packet.mib_voltage_3 	= (fix(lrs,200,type=12) / 204.6) * 2.0 
			lrs_packet.mib_voltage_5 	= (fix(lrs,202,type=12) / 204.6) * 2.0 
			lrs_packet.mib_voltage_28 	= (fix(lrs,204,type=12) / 204.6) * 11.0 
;

			lrs_packet.pc_counts		= ulong(lrs, 206)			
			lrs_packet.pc_filtered		= ulong(lrs, 210)			
			lrs_packet.pc_overflow		= ulong(lrs, 214)			
;
			lrs_packet.cc_counts		= ulong(lrs, 218)			
			lrs_packet.cc_filtered		= ulong(lrs, 222)			
			lrs_packet.cc_overflow		= ulong(lrs, 226)			
;
			lrs_packet.c_counts			= ulong(lrs, 230)			
			lrs_packet.c_filtered		= ulong(lrs, 234)			
			lrs_packet.c_overflow		= ulong(lrs, 238)	
;
;			Julian day number for start of current gps week.
;  			Sunday, January 5, 2004 is start of GPS week 1774.
;
			jd_wkn = ((file_gpswk[ifile] - 1774.0) * 7.0) + julday(1,5,2014,0,0,0)	
;
			pkt_hrs  = fix(lrs_packet.csbf_gps_cputim/3600.0)
			pkt_mins = fix((lrs_packet.csbf_gps_cputim/3600.0 - pkt_hrs) * 60.0)
			pkt_secs = fix(lrs_packet.csbf_gps_cputim - pkt_hrs*3600.0 - pkt_mins*60.0)
			lrs_packet.jd = jd_wkn + (lrs_packet.csbf_gps_tow / 86400.0)
;			print, lrs_packet.jd, file_month[ifile], file_day[ifile], file_year[ifile], pkt_hrs, pkt_mins, pkt_secs
;
			if ((pkt_hrs eq 0.0) and (pkt_mins eq 0.0) and (pkt_secs eq 0.0)) then continue

			lrsdata[ilrs] = lrs_packet
			ilrs = ilrs + 1
;
;*****************************************************************************************
;
		
			print
			print, '=================================================================='
			print, data[ifirst:ifirst+5], format='(6(Z2.2,1X))'
			print, ilrs, format = '("Low Rate Science Packet No. = ",I6)'
			print, file_month[ifile], file_day[ifile], file_year[ifile], format = '("File Date  = ", I2,"/",I2,"/",I4)'
			print, file_hrs[ifile], file_mins[ifile], file_secs[ifile],  format = '("File Time  = ", I2,":",I2,":",I2)'
			print, pkt_hrs, pkt_mins, pkt_secs,     format = '("CPU Time   = ", I2,":",I2,":",I2)'
			print, lrs_packet.csbf_gps_cputim,      format = '("CPU Time   = ", F12.2)'
			print
			if iverbose eq 1 then begin 
				print, lrs_packet.csbf_lon, 		format = '("CSBF Longitude (degs) = ",F10.2)'
				print, lrs_packet.csbf_lat, 		format = '("CSBF Latitude (degs) = ",F10.2)'
				print, lrs_packet.csbf_alt, 		format = '("CSBF Altitude (m) = ",F10.2)'
				print, lrs_packet.csbf_sat_stat1,   format = '("Satellite Status 1 = ", Z2.2, " (hex)")'
				print, lrs_packet.csbf_sat_stat2,   format = '("Satellite Status 2 = ", Z2.2, " (hex)")'
				print, lrs_packet.csbf_gps_wkn, 	format = '("GPS Week Number = ",I4)'
				print, lrs_packet.csbf_gps_tow, 	format = '("GPS Time-of-Week = ",F10.2)'
				print, lrs_packet.csbf_gps_timofs, 	format = '("GPS Time Offset = ",F10.2)'
				print, lrs_packet.csbf_gps_cputim, 	format = '("CPU Time  = ",F10.2)'
				print, lrs_packet.adu5_psa_tow, 	format = '("PSA Time-of-Week = ",F10.2)'
				print
				print, lrs_packet.ac_total_rate, 	format = '("AC Total Rate = ",I8)'		
				print, lrs_packet.ac1_rate,  		format = '("AC1 Rate   = ",I8)'
				print, lrs_packet.ac2_rate,  		format = '("AC2 Rate   = ",I8)'
				print, lrs_packet.ac3_rate,  		format = '("AC3 Rate   = ",I8)'
				print, lrs_packet.ac4_rate,  		format = '("AC4 Rate   = ",I8)'
				print, lrs_packet.ac5_rate,  		format = '("AC5 Rate   = ",I8)'
				print, lrs_packet.ac6_rate,  		format = '("AC6 Rate   = ",I8)'
				print, lrs_packet.mib_temp0, 		format = '("MIB Temp 0 = ",F10.2)'
				print, lrs_packet.mib_temp1, 		format = '("MIB Temp 1 = ",F10.2)'
				print, lrs_packet.mib_temp2, 		format = '("MIB Temp 2 = ",F10.2)'
				print, lrs_packet.mib_temp3, 		format = '("MIB Temp 3 = ",F10.2)'
				print, lrs_packet.mib_temp4, 		format = '("MIB Temp 4 = ",F10.2)'
				print, lrs_packet.mib_temp5, 		format = '("MIB Temp 5 = ",F10.2)'
				print, lrs_packet.mib_temp6, 		format = '("MIB Temp 6 = ",F10.2)'
				print, lrs_packet.mib_temp7, 		format = '("MIB Temp 7 = ",F10.2)'
				print, lrs_packet.mib_temp_mib0, 	format = '("MIB Temp MIB0 = ",F10.2)'
				print, lrs_packet.mib_temp_mib1, 	format = '("MIB Temp MIB1 = ",F10.2)'
				print, lrs_packet.mib_press0, 		format = '("MIB Press 0 = ",F10.2)'
				print, lrs_packet.mib_press1, 		format = '("MIB Press 1 = ",F10.2)'
				print, lrs_packet.gps_power, 		format = '("GPS power = ",F10.2)'
				print, lrs_packet.mib_voltage_3, 	format = '("MIB Voltage (+3.3V) = ",F10.2)'
				print, lrs_packet.mib_voltage_5, 	format = '("MIB Voltage (+5V) = ",F10.2)'
				print, lrs_packet.mib_voltage_28, 	format = '("MIB Voltage (+28V) = ",F10.2)'
				print, lrs_packet.pc_counts, 		format = '("PC Counts 	= ",I6)'
				print, lrs_packet.pc_filtered, 		format = '("PC Filtered = ",I6)'
				print, lrs_packet.pc_overflow, 		format = '("PC Overflow = ",I6)'
				print, lrs_packet.cc_counts, 		format = '("CC Counts 	= ",I6)'
				print, lrs_packet.cc_filtered, 		format = '("CC Filtered = ",I6)'
				print, lrs_packet.cc_overflow, 		format = '("CC Overflow = ",I6)'
				print, lrs_packet.c_counts, 		format = '("C Counts 	= ",I6)'
				print, lrs_packet.c_filtered, 		format = '("C Filtered  = ",I6)'
				print, lrs_packet.c_overflow, 		format = '("C Overflow  = ",I6)'
			endif
			
	
	
;
;

	
	
	
endfor ; packet ended

lrsdata = lrsdata[0:ilrs-1]

if ifile eq 0 then begin
	lrsall = lrsdata
endif
;
if ifile ne 0 then begin 
	lrsall = [lrsall, lrsdata]
endif

;
;   End of this file.  Close this file (calling free_lun closes the file and frees up 
;   the file unit number) and go get next one.
;
		free_lun, unit
;		
	endfor              ; end of file.     	


;
;*****************************************************************************************
; Open a postscript file for plotting.
;
if keyword_set(title) ne 1 then title = 'QL'
cgPS_Open, title + '_lrs_onboard_quicklook.ps'
cgDisplay, 550, 800
cgLoadCT, 13
;
A = FINDGEN(17) * (!PI*2/16.)
USERSYM, COS(A), SIN(A), /FILL
   			
;
;*****************************************************************************************
; Plot MIB voltages vs. time for each event type and the total.
; 
date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I', '%M %D, %Y'])
;
cgplot, lrsall.jd, lrsall.mib_voltage_3, psym=8, xstyle = 3, $
			charsize = 1.0, ytickformat='(F6.1)', $
			yrange = [0.0, 40.0], symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Voltage (V)', title = 'Voltages (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

 
   			
oplot, lrsall.jd, lrsall.mib_voltage_5,  psym=8, color = cgColor('Red'), symsize = 0.5
oplot, lrsall.jd, lrsall.mib_voltage_28, psym=8, color = cgColor('Blue'), symsize = 0.5
;
al_legend, ['+3.3V MIB','+5V MIB','+28V MIB'], psym=[8,8,8],colors=['black','red','blue'], charsize = 0.8
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - Pressures
;
ymin = -10.0
ymax = max([lrsall.mib_press0,lrsall.mib_press1]) * 1.20
;;
cgplot, lrsall.jd, lrsall.mib_press0, psym=8, xstyle = 3, $
			charsize = 1.0, ytickformat='(F6.1)', $
			yrange = [0.0,20.0], symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Pressure (psi)', title = 'Pressures (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
			

oplot, lrsall.jd, lrsall.mib_press1, psym=8, color = cgColor('Red'), symsize = 0.5
;
al_legend, ['MIB Pressure 0','MIB Pressure 1'], psym=[8,8],colors=['black','red'], /bottom, charsize = 0.8
			
;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE Onboard LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - Temperatures
;
ymin = -10.0
ymax = max([lrsall.mib_temp0,lrsall.mib_temp1,lrsall.mib_temp2,lrsall.mib_temp3])
;;
cgplot, lrsall.jd, lrsall.mib_temp0, psym=8, xstyle = 3, $
			charsize = 1.0, ytickformat='(F6.1)', $
			yrange = [0.0,50.0], symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Temperature', title = 'Temperatures (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   						

oplot, lrsall.jd, lrsall.mib_temp1, psym=8, color = cgColor('Red'), symsize = 0.5
oplot, lrsall.jd, lrsall.mib_temp2, psym=8, color = cgColor('Blue'), symsize = 0.5
oplot, lrsall.jd, lrsall.mib_temp3, psym=8, color = cgColor('Green'), symsize = 0.5
;
al_legend, ['mid-module air','scintillator air','top of collimator air','vessel top air'], $
			psym=[8,8,8,8],colors=['black','red','blue','green'], /bottom, charsize = 0.8
			
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - Temperatures
;
ymin = -10.0
ymax = max([lrsall.mib_temp4,lrsall.mib_temp5,lrsall.mib_temp6,lrsall.mib_temp7])
;;
cgplot, lrsall.jd, lrsall.mib_temp4, psym=8, xstyle = 3, $
			charsize = 1.0, ytickformat='(F6.1)', $
			yrange = [0.0,50.0], symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Temperature', title = 'Temperatures (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
			



oplot, lrsall.jd, lrsall.mib_temp5, psym=8, color = cgColor('Red'), symsize = 0.5
oplot, lrsall.jd, lrsall.mib_temp6, psym=8, color = cgColor('Blue'), symsize = 0.5
oplot, lrsall.jd, lrsall.mib_temp7, psym=8, color = cgColor('Green'), symsize = 0.5
;
al_legend, ['baseplate air','regulator air','baseplate feedthru','elec plate'], $
			psym=[8,8,8,8],colors=['black','red','blue','green'], /bottom, charsize = 0.8
			
;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE Onboard LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - Temperatures
;
ymin = -10.0
ymax = max([lrsall.mib_temp_mib0,lrsall.mib_temp_mib1])
;;
cgplot, lrsall.jd, lrsall.mib_temp_mib0, psym=8, xstyle = 3, $
			charsize = 1.0, ytickformat='(F6.1)', $
			yrange = [0.0,50.0], symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Temperature', title = 'Temperatures (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
			



oplot, lrsall.jd, lrsall.mib_temp_mib1, psym=8, color = cgColor('Red'), symsize = 0.5
;
al_legend, ['temp_mib0','temp_mib1'], $
			psym=[8,8],colors=['black','red'], /bottom, charsize = 0.8
			
;
;*********************************************************************
; Output LRS temperature data to a text file.  
;
OPENW,  lrs_unit, title + '_lrs_onboard_temp_data.txt', width = 120, /GET_LUN
printf, lrs_unit, format='(C())', systime(/julian)
printf, lrs_unit, 'LRS TEMP DATA'
printf, lrs_unit, ' '
printf, lrs_unit, 'TEMP1 - mid-module air'
printf, lrs_unit, 'TEMP2 - scintillator air'
printf, lrs_unit, 'TEMP3 - top of collimator air'
printf, lrs_unit, 'TEMP4 - vessel top air'
printf, lrs_unit, 'TEMP5 - baseplate air'
printf, lrs_unit, 'TEMP6 - regulator air'
printf, lrs_unit, 'TEMP7 - baseplate feedthru'
printf, lrs_unit, 'TEMP8 - elec plate'
printf, lrs_unit, ' '
printf, lrs_unit, 'GPS_TIME(s), MIB_TEMP1, MIB_TEMP2, MIB_TEMP3, MIB_TEMP4, MIB_TEMP5, MIB_TEMP6, MIB_TEMP7, MIB_TEMP8'
for i = 0, n_elements(lrsall)-1 do begin          ; Added the temperature output of Mib_temp 0 : SW 6/15/15
	printf, lrs_unit, $
			lrsall[i].csbf_gps_tow, lrsall[i].mib_temp0, lrsall[i].mib_temp1, lrsall[i].mib_temp2, lrsall[i].mib_temp3, $
			lrsall[i].mib_temp4, lrsall[i].mib_temp5, lrsall[i].mib_temp6, lrsall[i].mib_temp7
	        format = '(F12.4,8(1X,F8.2))'
endfor
close, /all
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - Total AC Rate
;
;
cgplot, lrsall.jd, lrsall.ac_total_rate, psym=8, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			symsize = 0.5, $
			yrange = [0.0,8000.0], $
			xtitle = 'Time (hh:mm)', ytitle = 'Count Rate', title = 'Total Shield Rate (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			
   			
;
; xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
; xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE Onboard LRS Quicklook Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

;
al_legend, ['Total Shield Rate'], psym=[8],colors=['black'], /bottom, charsize = 0.8
;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE Onboard LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - AC Rates
;
ymin = min([lrsall.ac2_rate,lrsall.ac3_rate,lrsall.ac4_rate,lrsall.ac6_rate])
ymax = max([lrsall.ac2_rate,lrsall.ac3_rate,lrsall.ac4_rate,lrsall.ac6_rate])
;
;
cgplot, lrsall.jd, lrsall.ac2_rate, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			yrange = [0.0,2000.0], symsize = 0.5, color = cgColor('Red'), $
			xtitle = 'Time (hh:mm)', ytitle = 'Count Rate', title = 'Shield Rates (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			
;

oplot, lrsall.jd, lrsall.ac3_rate, color = cgColor('Blue'), symsize = 0.5
oplot, lrsall.jd, lrsall.ac4_rate, color = cgColor('Green'), symsize = 0.5
oplot, lrsall.jd, lrsall.ac6_rate, color = cgColor('Orange'), symsize = 0.5
;
al_legend, ['AC Panel 2','AC Panel 3','AC Panel 4','AC Panel 6'], $
			psym=[8,8,8,8],colors=['black','red','blue','green'], /bottom, charsize = 0.8
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - AC Rates
;
ymin = min([lrsall.ac1_rate,lrsall.ac5_rate])
ymax = max([lrsall.ac1_rate,lrsall.ac5_rate])
;
;
cgplot, lrsall.jd, lrsall.ac1_rate, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			yrange = [0.0,2000.0], symsize = 0.5, color = cgColor('Dark Gray'), $
			xtitle = 'Time (hh:mm)', ytitle = 'Count Rate', title = 'Shield Rates (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			
;

oplot, lrsall.jd, lrsall.ac5_rate, color = cgColor('Purple'), symsize = 0.5
;
al_legend, ['AC Panel 1','AC Panel 5'], $
			psym=[8,8],colors=['Dark Gray','purple'], /bottom, charsize = 0.8
;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE Onboard LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - AC Rates
;
ymin = min(lrsall.ac1_rate)
ymax = max(lrsall.ac1_rate)
;
;
cgplot, lrsall.jd, lrsall.ac1_rate, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			yrange = [0.0,2000.0], symsize = 0.5, color = cgColor('Dark Gray'), $
			xtitle = 'Time (hh:mm)', ytitle = 'Count Rate', title = 'Shield Rates (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,3,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			;
al_legend, ['AC Panel 1'], psym=[8],colors=['Dark Gray'], /bottom, charsize = 0.8
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - AC Rates
;
ymin = min(lrsall.ac2_rate)
ymax = max(lrsall.ac2_rate)
;
;
cgplot, lrsall.jd, lrsall.ac2_rate, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			yrange = [0.0,2000.0], symsize = 0.5, color = cgColor('Red'), $
			xtitle = 'Time (hh:mm)', ytitle = 'Count Rate', title = 'Shield Rates (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,3,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			;
al_legend, ['AC Panel 2'], psym=[8],colors=['Red'], /bottom, charsize = 0.8
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - AC Rates
;
ymin = min(lrsall.ac3_rate)
ymax = max(lrsall.ac3_rate)
;
;
cgplot, lrsall.jd, lrsall.ac3_rate, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			yrange = [0.0,2000.0], symsize = 0.5, color = cgColor('blue'), $
			xtitle = 'Time (hh:mm)', ytitle = 'Count Rate', title = 'Shield Rates (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,3,3], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			;
al_legend, ['AC Panel 3'], psym=[8],colors=['Blue'], /bottom, charsize = 0.8
;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE Onboard LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - AC Rates
;
ymin = min(lrsall.ac4_rate)
ymax = max(lrsall.ac4_rate)
;
;
cgplot, lrsall.jd, lrsall.ac4_rate, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			yrange = [0.0,2000.0], symsize = 0.5, color = cgColor('Green'), $
			xtitle = 'Time (hh:mm)', ytitle = 'Count Rate', title = 'Shield Rates (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,3,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			;
al_legend, ['AC Panel 4'], psym=[8],colors=['Green'], /bottom, charsize = 0.8
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - AC Rates
;
ymin = min(lrsall.ac5_rate)
ymax = max(lrsall.ac5_rate)
;
;
cgplot, lrsall.jd, lrsall.ac5_rate, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			yrange = [0.0,2000.0], symsize = 0.5, color = cgColor('Orange'), $
			xtitle = 'Time (hh:mm)', ytitle = 'Count Rate', title = 'Shield Rates (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,3,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			;
al_legend, ['AC Panel 5'], psym=[8],colors=['Orange'], /bottom, charsize = 0.8
;
;*****************************************************************************************
; LOW RATE SCIENCE DATA - AC Rates
;
ymin = min(lrsall.ac6_rate)
ymax = max(lrsall.ac6_rate)
;
;
cgplot, lrsall.jd, lrsall.ac6_rate, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			yrange = [0.0,2000.0], symsize = 0.5, color = cgColor('Purple'), $
			xtitle = 'Time (hh:mm)', ytitle = 'Count Rate', title = 'Shield Rates (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,3,3], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			;
al_legend, ['AC Panel 6'], psym=[8],colors=['Purple'], /bottom, charsize = 0.8
;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE Onboard LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase
;
;*****************************************************************************************
; Plot PC Count Data
; 
date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I', '%M %D, %Y'])
;
cgplot, lrsall.jd, lrsall.pc_counts, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Counts', title = 'PC Events (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			
   			
oplot, lrsall.jd, lrsall.pc_filtered,  color = cgColor('Red'), symsize = 0.5
oplot, lrsall.jd, lrsall.pc_overflow, color = cgColor('Blue'), symsize = 0.5
;
al_legend, ['PC Counts','PC Filtered','PC Overflow'], $
			psym=[8,8,8],colors=['black','red','blue'], charsize = 0.8
;
;*****************************************************************************************
; Plot CC Count Data
; 
date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I', '%M %D, %Y'])
;
cgplot, lrsall.jd, lrsall.cc_counts, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
			symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Counts', title = 'CC Events (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			
   			
   			
oplot, lrsall.jd, lrsall.cc_filtered,  color = cgColor('Red'), symsize = 0.5
oplot, lrsall.jd, lrsall.cc_overflow, color = cgColor('Blue'), symsize = 0.5
;
al_legend, ['CC Counts','CC Filtered','CC Overflow'], $
			psym=[8,8,8],colors=['black','red','blue'], charsize = 0.8
;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE Onboard LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase
;
;
;*****************************************************************************************
; Plot C Count Data
; 
date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I', '%M %D, %Y'])
;
cgplot, lrsall.jd, lrsall.c_counts, xstyle = 3, $
			charsize = 1.0, ytickformat='(F8.1)', $
;			yrange = [0.0, 40.0], 
			symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Counts', title = 'C Events (Low Rate Science Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
   			
   			
   			
oplot, lrsall.jd, lrsall.c_filtered,  color = cgColor('Red'), symsize = 0.5
oplot, lrsall.jd, lrsall.c_overflow, color = cgColor('Blue'), symsize = 0.5
;
al_legend, ['C Counts','C Filtered','C Overflow'], $
			psym=[8,8,8],colors=['black','red','blue'], charsize = 0.8


close, /all

cgPS_Close, /delete_ps, /pdf


;
;*********************************************************************
; Output ADU data to a text file.  
;
OPENW,  lrs_unit, title + '_lrs_onboard_position_data.txt', width = 120, /GET_LUN
printf, lrs_unit, format='(C())', systime(/julian)
printf, lrs_unit, 'LRS POSITION DATA'
printf, lrs_unit, ' '
printf, lrs_unit, 'GPS_TIME(s), LONGITUDE(deg), LATITUDE(deg), ALTITUDE(m)'
for i = 0, n_elements(lrsall)-1 do begin
	printf, lrs_unit, $
			lrsall[i].csbf_gps_tow, lrsall[i].csbf_lon, lrsall[i].csbf_lat, $
			lrsall[i].csbf_alt, $
	        format = '(F12.4,1X,F8.2,1X,F8.2,1X,F8.2)'
endfor
close, /all

;

Openw, lun_lrs , title+'_lrs_onboard_ACrates.txt', /Get_Lun

Printf, lun_lrs, '  GPS_TIME(s),  Altitude(m), AC1_rates, AC2_Rates, AC3_Rates, AC4_Rates, AC5_Rates, AC6_Rates, AC_Total_Rates, PC_Cnts, PC_Cnts_Fil, PC_Cnts_Ovr'

for i = 0, n_elements(lrsall)-1 do begin
  
  printf, lun_lrs, $
    lrsall[i].csbf_gps_tow, lrsall[i].csbf_alt,  lrsall[i].ac1_rate, lrsall[i].ac2_rate,lrsall[i].ac3_rate,$
    lrsall[i].ac4_rate,lrsall[i].ac5_rate, lrsall[i].ac6_rate, lrsall[i].AC_total_rate , lrsall[i].PC_Counts , lrsall[i].PC_Filtered , lrsall[i].PC_Overflow ,$
    format = '(F12.4,1X,F8.2,1X, I8,1X, I8,1X, I8,1X, I8,1X, I8,1X, I8,1X, I8,1X, I8,1X, I8,1X, I8)'
endfor

Free_lun, lun_lrs


stop



end
		

		

