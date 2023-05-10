pro GRP_lrs_quicklook, fsearch_string, nfiles=nfiles, iverbose=iverbose, isim=isim, title=title

; This routine currently requires SSWIDL (addtime routine)

;filename = 'lrs-20130121025705.dat'
;filename = 'lrs-20110918171150.dat'
;filename = 'lrs-20130121025705.dat'
;filename = 'lrs-20110923223640.dat'      			; flight data

if keyword_set(iverbose) ne 1 then iverbose = 1

if keyword_set(isim) ne 1 then isim = 0				; flag to indicate use of CSBF simulator

if n_params() ne 1 then fsearch_string = 'lrs-*.dat'

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


ss_packet = {	HRS:0, $
				MINS:0, $
				SECS:0, $
				DAY:0, $
				MONTH:0, $
				YEAR:0, $
				JD:0.0D, $
				RELAY01:0.0, $
				RELAY02:0.0, $
				RELAY03:0.0, $
				RELAY04:0.0, $
				RELAY05:0.0, $
				RELAY06:0.0, $
				RELAY07:0.0, $
				RELAY08:0.0, $
				RELAY09:0.0, $
				RELAY10:0.0, $
				VMON01:0.0, $
				VMON02:0.0, $
				VMON03:0.0, $
				VMON04:0.0, $
				VMON05:0.0, $
				VMON06:0.0, $
				RELAY_VOLTAGE_5:0.0, $
				BATT_VOLTAGE_28:0.0, $
				VMON07:0.0, $
				RELAY_TEMP1:0.0, $
				RELAY_TEMP2:0.0, $
				ACCEL_X:0.0, $
				ACCEL_Y:0.0, $
				RELAY_PRESS:0.0, $
				ELEV_TEMP1:0.0, $
				ELEV_TEMP2:0.0 }
				
				

lrsfiles = FILE_SEARCH(fsearch_string)   ; get list of lrs files in current directory


if keyword_set(nfiles) ne 1 then nfiles = n_elements(lrsfiles)
 ; number of gps files in current directory


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
;	Extract file start time from filename, which has the form:
;         lrs-YYYYMMDDHHMMSS.dat
;      -or-
;         LRS0-20140514142005.dat
;      -or-
;         LRS1-20140514142005.dat
;
;   First, we find the start of the date/time string by locating the first dash ('-')
;
	stpos		= strpos(filename,'-')
;
	file_year 	= fix(strmid(filename,stpos+1,4))
	file_month 	= fix(strmid(filename,stpos+5,2))
	file_day 	= fix(strmid(filename,stpos+7,2))
	file_hrs 	= fix(strmid(filename,stpos+9,2))
	file_mins 	= fix(strmid(filename,stpos+11,2))
	file_secs 	= fix(strmid(filename,stpos+13,2))
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
	openr, unit, filename, /GET_LUN          	; open input data file
	data = READ_BINARY(unit)                  	; read in all of the data at once

	totpkt = n_elements(data) / 262            	; total number of packets in file

	lrsdata = replicate(lrs_packet, totpkt)
	ilrs = 0L

	ssdata = replicate(ss_packet, totpkt)
	iss = 0L
;
;   LOOP OVER ALL PACKETS IN THE FILE
;
	for i = 1L, totpkt do begin
		ifirst = (i-1)*262L   				    ; first byte for this packet
		ilast  = ifirst+261L      				; last byte for this packet
		pkt = data[ifirst:ilast]				; this packet
;
		if pkt[2] eq 1 then begin
			lrs = pkt[6:260]
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
			pkt_hrs  = fix(lrs_packet.csbf_gps_cputim/3600.0)
			pkt_mins = fix((lrs_packet.csbf_gps_cputim/3600.0 - pkt_hrs) * 60.0)
			pkt_secs = fix(lrs_packet.csbf_gps_cputim - pkt_hrs*3600.0 - pkt_mins*60.0)
			lrs_packet.jd = julday(file_month, file_day, file_year, pkt_hrs, pkt_mins, pkt_secs)
;


			lrsdata[ilrs] = lrs_packet
			ilrs = ilrs + 1
;
;*****************************************************************************************
;
		
			print
			print, '=================================================================='
			print, data[ifirst:ifirst+5], format='(6(Z2.2,1X))'
			print, ilrs, format = '("Low Rate Science Packet No. = ",I6)'
			print, file_month, file_day, file_year, format = '("File Date  = ", I2,"/",I2,"/",I4)'
			print, file_hrs, file_mins, file_secs,  format = '("File Time  = ", I2,":",I2,":",I2)'
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
			
			
		endif	
		
		
	
;
;
	if pkt[2] eq 0  then begin
		ss = pkt[8:260]
;
; 		Define science stack packet time based on assumed 30 second interval since the 
;       start time of the data file.
;		
		dmin = (float(iss) * 30.0) / 60.0
		ss_time  = addtime([file_hrs, file_mins, file_secs, 0, file_day, file_month, file_year], delta_min=dmin)
		ss_packet.hrs   = ss_time[0]
		ss_packet.mins  = ss_time[1]
		ss_packet.secs  = ss_time[2]
		ss_packet.day   = ss_time[4]
		ss_packet.month = ss_time[5]
		ss_packet.year  = ss_time[6]
		ss_packet.jd 	= julday(ss_packet.month, ss_packet.day, ss_packet.year, ss_packet.hrs, ss_packet.mins, ss_packet.secs)
;		
; 		Data collected through the CSBF simulator
;
		if isim eq 1 then begin 
			ss_packet.relay01 			= (ishft(fix(ss, 0, 1, type=12)  and '0000011111111111'B, 1) / 819.0 ) * 0.4167
			ss_packet.relay02 			= (ishft(fix(ss, 1, 1, type=12)  and '0111111111110000'B, -3)    / 819.0 ) * 0.8333
			ss_packet.relay03 			= (ishft(fix(ss, 3, 1, type=12)  and '0000011111111111'B, 1) / 819.0 ) * 0.1667
			ss_packet.relay04 			= (ishft(fix(ss, 4, 1, type=12)  and '0111111111110000'B, -3)      / 819.0 ) * 0.4167
			ss_packet.relay05 			= (ishft(fix(ss, 6, 1, type=12)  and '0000011111111111'B, 1) / 819.0 ) * 0.1667
			ss_packet.relay06 			= (ishft(fix(ss, 7, 1, type=12)  and '0111111111110000'B, -3)      / 819.0 ) * 1.6667
			ss_packet.relay07 			= (ishft(fix(ss, 9, 1, type=12)  and '0000011111111111'B, 1) / 819.0 ) * 1.6667
			ss_packet.relay08 			= (ishft(fix(ss, 10, 1, type=12) and '0111111111110000'B, -3)      / 819.0 ) * 1.6667
			ss_packet.relay09 			= (ishft(fix(ss, 12, 1, type=12) and '0000011111111111'B, 1) / 819.0 ) * 0.8333
			ss_packet.relay10 			= (ishft(fix(ss, 13, 1, type=12) and '0111111111110000'B, -3)      / 819.0 ) * 0.8333
			ss_packet.vmon01  			= (ishft(fix(ss, 15, 1, type=12) and '0000011111111111'B, 1)  / 819.0 ) * 2.0
			ss_packet.vmon02  			= (ishft(fix(ss, 16, 1, type=12) and '0111111111110000'B, -3)       / 819.0 ) * 2.0
			ss_packet.vmon03  			= (ishft(fix(ss, 18, 1, type=12) and '0000011111111111'B, 1)  / 819.0 ) * 2.0
			ss_packet.vmon04  			= (ishft(fix(ss, 19, 1, type=12) and '0111111111110000'B, -3)       / 819.0 ) * 3.0
			ss_packet.vmon05  			= (ishft(fix(ss, 21, 1, type=12) and '0000011111111111'B, 1)  / 819.0 ) * 2.0				; spare
			ss_packet.vmon06  			= (ishft(fix(ss, 22, 1, type=12) and '0111111111110000'B, -3)      / 819.0 ) * 2.0				; spare
			ss_packet.relay_voltage_5 	= (ishft(fix(ss, 24, 1, type=12) and '0000011111111111'B, 1) / 819.0 ) * 2.0
			ss_packet.batt_voltage_28 	= (ishft(fix(ss, 25, 1, type=12) and '0111111111110000'B, -3) / 819.0 ) * 11.0
			ss_packet.vmon07 			= (ishft(fix(ss, 27, 1, type=12) and '0000011111111111'B, 1) / 819.0 ) * (-2.0)
;
			adc					 		= (ishft(fix(ss, 28, 1, type=12) and '0111111111110000'B, -3))     ; ADC value
			lambda				        = (5.0 / (adc / 819.0)) - 1.00 
			ohms                        = (100.0 / lambda) * 1000.0        
			ss_packet.relay_temp1       = (1.0 / (9.376e-04 + 2.208e-04 * alog(ohms) + 1.276e-07*alog(ohms)^3.0)) -273.15
;
			adc				     		= (ishft(fix(ss, 30, 1, type=12) and '0000011111111111'B, 1))      ; ADC value
			lambda				        = (5.0 / (adc / 819.0)) - 1.00 
			ohms                        = (100.0 / lambda) * 1000.0        
			ss_packet.relay_temp2       = (1.0 / (9.376e-04 + 2.208e-04 * alog(ohms) + 1.276e-07*alog(ohms)^3.0)) -273.15
;
			ss_packet.accel_x 			= (ishft(fix(ss, 31, 1, type=12) and '0111111111110000'B, -3) / 819.0 ) - 2.5
			ss_packet.accel_y 			= (ishft(fix(ss, 33, 1, type=12) and '0000011111111111'B, 1) / 819.0 ) - 2.5
			ss_packet.relay_press		= (ishft(fix(ss, 34, 1, type=12) and '0111111111110000'B, -3) / 819.0 ) * 7.5  - 3.75
;
			adc 						= (ishft(fix(ss, 36, 1, type=12) and '0000011111111111'B, 1))     ; ADC value
			lambda				        = (5.0 / (adc / 819.0)) - 1.00 
			ohms                        = (100.0 / lambda) * 1000.0        
			ss_packet.elev_temp1        = (1.0 / (9.376e-04 + 2.208e-04 * alog(ohms) + 1.276e-07*alog(ohms)^3.0)) -273.15
;
			adc 						= (ishft(fix(ss, 37, 1, type=12) and '0111111111110000'B, -3))      ; ADC value
			lambda				        = (5.0 / (adc / 819.0)) - 1.00 
			ohms                        = (100.0 / lambda) * 1000.0        
			ss_packet.elev_temp2        = (1.0 / (9.376e-04 + 2.208e-04 * alog(ohms) + 1.276e-07*alog(ohms)^3.0)) -273.15
		endif
;
		if isim eq 0 then begin
			ss_packet.relay01 = 		((fix(ss, 0, 1, type=12)  and '0000111111111111'B) / 819.0 ) * 0.4167
			ss_packet.relay02 = 		(ishft(fix(ss, 1, 1, type=12)  and '1111111111110000'B, -4) / 819.0 ) * 0.8333
			ss_packet.relay03 = 		((fix(ss, 3, 1, type=12)  and '0000111111111111'B) / 819.0 ) * 0.1667
			ss_packet.relay04 = 		(ishft(fix(ss, 4, 1, type=12)  and '1111111111110000'B, -4) / 819.0 ) * 0.4167
			ss_packet.relay05 = 		((fix(ss, 6, 1, type=12)  and '0000111111111111'B) / 819.0 ) * 0.1667
			ss_packet.relay06 = 		(ishft(fix(ss, 7, 1, type=12)  and '1111111111110000'B, -4) / 819.0 ) * 1.6667
			ss_packet.relay07 = 		((fix(ss, 9, 1, type=12)  and '0000111111111111'B) / 819.0 ) * 1.6667
			ss_packet.relay08 = 		(ishft(fix(ss, 10, 1, type=12) and '1111111111110000'B, -4) / 819.0 ) * 1.6667
			ss_packet.relay09 = 		((fix(ss, 12, 1, type=12) and '0000111111111111'B) / 819.0 ) * 0.8333
			ss_packet.relay10 = 		(ishft(fix(ss, 13, 1, type=12) and '1111111111110000'B, -4) / 819.0 ) * 0.8333
			ss_packet.vmon01  = 		((fix(ss, 15, 1, type=12) and '0000111111111111'B) / 819.0 ) * 2.0
			ss_packet.vmon02  = 		(ishft(fix(ss, 16, 1, type=12) and '1111111111110000'B, -4) / 819.0 ) * 2.0
			ss_packet.vmon03  = 		((fix(ss, 18, 1, type=12) and '0000111111111111'B) / 819.0 ) * 2.0
			ss_packet.vmon04  = 		(ishft(fix(ss, 19, 1, type=12) and '1111111111110000'B, -4) / 819.0 ) * 3.0
			ss_packet.vmon05  = 		((fix(ss, 21, 1, type=12) and '0000111111111111'B) / 819.0 ) * 2.0				; spare
			ss_packet.vmon06  = 		(ishft(fix(ss, 22, 1, type=12) and '1111111111110000'B, -4) / 819.0 ) * 2.0				; spare
			ss_packet.relay_voltage_5 = ((fix(ss, 24, 1, type=12) and '0000111111111111'B) / 819.0 ) * 2.0
			ss_packet.batt_voltage_28 = (ishft(fix(ss, 25, 1, type=12) and '1111111111110000'B, -4) / 819.0 ) * 11.0
			ss_packet.vmon07 = 			((fix(ss, 27, 1, type=12) and '0000111111111111'B) / 819.0 ) * (-2.0)
;
			adc					 		= ishft(fix(ss, 28, 1, type=12) and '1111111111110000'B, -4)     ; ADC value
			lambda				        = (5.0 / (adc / 819.0)) - 1.00 
			ohms                        = (100.0 / lambda) * 1000.0        
			ss_packet.relay_temp1       = (1.0 / (9.376e-04 + 2.208e-04 * alog(ohms) + 1.276e-07*alog(ohms)^3.0)) -273.15
;
			adc				     		= (fix(ss, 30, 1, type=12) and '0000111111111111'B)      ; ADC value
			lambda				        = (5.0 / (adc / 819.0)) - 1.00 
			ohms                        = (100.0 / lambda) * 1000.0        
			ss_packet.relay_temp2       = (1.0 / (9.376e-04 + 2.208e-04 * alog(ohms) + 1.276e-07*alog(ohms)^3.0)) -273.15
;
			ss_packet.accel_x = 		(ishft(fix(ss, 31, 1, type=12) and '1111111111110000'B, -4) / 819.0 ) - 2.5
			ss_packet.accel_y = 		((fix(ss, 33, 1, type=12) and '0000111111111111'B) / 819.0 ) - 2.5
			ss_packet.relay_press = 	(ishft(fix(ss, 34, 1, type=12) and '1111111111110000'B, -4) / 819.0 ) * 7.5  - 3.75
;
			adc 						= (fix(ss, 36, 1, type=12) and '0000111111111111'B)     ; ADC value
			lambda				        = (5.0 / (adc / 819.0)) - 1.00 
			ohms                        = (100.0 / lambda) * 1000.0        
			ss_packet.elev_temp1        = (1.0 / (9.376e-04 + 2.208e-04 * alog(ohms) + 1.276e-07*alog(ohms)^3.0)) -273.15
;
			adc 						= ishft(fix(ss, 37, 1, type=12) and '1111111111110000'B, -4)      ; ADC value
			lambda				        = (5.0 / (adc / 819.0)) - 1.00 
			ohms                        = (100.0 / lambda) * 1000.0        
			ss_packet.elev_temp2        = (1.0 / (9.376e-04 + 2.208e-04 * alog(ohms) + 1.276e-07*alog(ohms)^3.0)) -273.15
			
		endif
;
		ssdata[iss] = ss_packet
		iss = iss + 1

;
		print
		print, '=================================================================='
		print, data[ifirst:ifirst+5], format='(6(Z2.2,1X))'
		print, iss, format = '("Science Stack Packet No. = ",I6)'
		print, file_month, file_day, file_year, format = '("File Date = ", I2,"/",I2,"/",I4)'
		print, file_hrs, file_mins, file_secs, format = '("File Time = ", I2,":",I2,":",I2)'
		print, ymd2dn(file_year,file_month, file_day), format = '("Day of Year = ", I3)'
		
		print, ss_packet.month, ss_packet.day, ss_packet.year, format = '("Packet Date = ", I2,"/",I2,"/",I4)'
		print, ss_packet.hrs, ss_packet.mins, ss_packet.secs, format = '("Packet Time = ", I2,":",I2,":",I2)'

		
		;addtime
		; date2doy
		; julian = JULDAY(1,1,2000,12,15,0)
		; strdate
		
		print
		if iverbose eq 1 then begin 
			print, ss_packet.relay01, format = '("Relay 01 Current = ",F10.2)'
			print, ss_packet.relay02, format = '("Relay 02 Current = ",F10.2)'
			print, ss_packet.relay03, format = '("Relay 03 Current = ",F10.2)'
			print, ss_packet.relay04, format = '("Relay 04 Current = ",F10.2)'
			print, ss_packet.relay05, format = '("Relay 05 Current = ",F10.2)'
			print, ss_packet.relay06, format = '("Relay 06 Current = ",F10.2)'
			print, ss_packet.relay07, format = '("Relay 07 Current = ",F10.2)'
			print, ss_packet.relay08, format = '("Relay 08 Current = ",F10.2)'
			print, ss_packet.relay09, format = '("Relay 09 Current = ",F10.2)'
			print, ss_packet.relay10, format = '("Relay 10 Current = ",F10.2)'
			print, ss_packet.vmon01, format = '("+5V Science Data Computer = ",F10.2)'
			print, ss_packet.vmon02, format = '("+5V Science Control Computer = ",F10.2)'
			print, ss_packet.vmon03, format = '("+6V Module Supply = ",F10.2)'
			print, ss_packet.vmon04, format = '("+10V Module HV Supply = ",F10.2)'
			print, ss_packet.vmon05, format = '("Voltage Monitor Spare = ",F10.2)'
			print, ss_packet.vmon06, format = '("Voltage Monitor Spare = ",F10.2)'
			print, ss_packet.relay_voltage_5, format = '("+5V Relay = ",F10.2)'
			print, ss_packet.batt_voltage_28, format = '("+28V Battery = ",F10.2)'
		endif
		
	endif

	
	
	
endfor

lrsdata = lrsdata[0:ilrs-1]

ssdata = ssdata[0:iss-1]

if ifile eq 0 then begin
	lrsall = lrsdata
	ssall = ssdata
endif
;
if ifile ne 0 then begin 
	lrsall = [lrsall, lrsdata]
	ssall = [ssall, ssdata]
endif

;
;   End of this file.  Close this file (calling free_lun closes the file and frees up 
;   the file unit number) and go get next one.
;
		free_lun, unit
;		
	endfor                   	



;
;*****************************************************************************************
; Open a postscript file for plotting.
;
if keyword_set(title) ne 1 then title = 'QL'
cgPS_Open, title + '_lrs_quicklook.ps'
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
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

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
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

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
OPENW,  lrs_unit, title + '_lrs_temp_data.txt', width = 120, /GET_LUN
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
printf, lrs_unit, 'GPS_TIME(s), MIB_TEMP1, MIB_TEMP2, MIB_TEMP3, MIB_TEMP4, MIB_TEMP5, MIB_TEMP6, MIB_TEMP7'
for i = 0, n_elements(lrsall)-1 do begin
	printf, lrs_unit, $
			lrsall[i].csbf_gps_tow, lrsall[i].mib_temp1, lrsall[i].mib_temp2, lrsall[i].mib_temp3, $
			lrsall[i].mib_temp4, lrsall[i].mib_temp5, lrsall[i].mib_temp6, lrsall[i].mib_temp7
	        format = '(F12.4,7(1X,F8.2))'
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
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

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
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

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
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

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
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

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
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

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

;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase


;
;*********************************************************************
; Output ADU data to a text file.  
;
OPENW,  lrs_unit, title + '_lrs_position_data.txt', width = 120, /GET_LUN
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
;
;*****************************************************************************************
; SCIENCE STACK DATA - Voltages
;

cgplot, ssall.jd, ssall.vmon01, psym=8, xstyle = 3, $
			charsize = 1.0, ytickformat='(F6.1)', $
			yrange = [0.0, 20.0], symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Voltage (V)', title = 'Voltages (Science Stack Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

oplot, ssall.jd, ssall.vmon02,          psym=8, color = cgColor('Red'), symsize = 0.5
oplot, ssall.jd, ssall.vmon03,          psym=8, color = cgColor('Green'), symsize = 0.5
oplot, ssall.jd, ssall.vmon04,          psym=8, color = cgColor('Blue'), symsize = 0.5
;
al_legend, ['+5V SDC','+5V SCC','+6V Mod Supply','+10V Mod HV'], $
			psym=[8,8,8,8],colors=['black','red','green','blue'], charsize = 0.8



;
;
;*****************************************************************************************
; SCIENCE STACK DATA - Voltages
;

cgplot, ssall.jd, ssall.relay_voltage_5, psym=8, xstyle = 3, $
			charsize = 1.0, ytickformat='(F6.1)', $
			yrange = [-10.0, 40.0], symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Voltage (V)', title = 'Voltages (Science Stack Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase


oplot, ssall.jd, ssall.batt_voltage_28, psym=8, color = cgColor('Red'), symsize = 0.5
oplot, ssall.jd, ssall.vmon07,          psym=8, color = cgColor('Green'), symsize = 0.5
;
al_legend, ['+5V Relay Bd','+28V','-6V Mod Supply'], $
			psym=[8,8,8],colors=['black','red','green'], charsize = 0.8

;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase




;
;*****************************************************************************************
; SCIENCE STACK DATA - CURRENTS
; 
;
;
cgplot, ssall.jd, ssall.relay01, psym=8, xstyle = 3, $
			charsize = 1.0, ytickformat='(F6.1)', $
			yrange = [0.0, 6.0], symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Current (Amps)', title = 'Relay Currents (Science Stack Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase


oplot, ssall.jd, ssall.relay02, psym=8, color = cgColor('Red'), symsize = 0.5
oplot, ssall.jd, ssall.relay03, psym=8, color = cgColor('Green'), symsize = 0.5
oplot, ssall.jd, ssall.relay04, psym=8, color = cgColor('Blue'), symsize = 0.5
oplot, ssall.jd, ssall.relay05, psym=8, color = cgColor('Orange'), symsize = 0.5

;
al_legend, ['+5V SDC/MIB','+/-6V','+10V','+5V SCC/tilt','ADU5'], $
			psym=[8,8,8,8,8],colors=['black','red','green','blue','orange'], charsize = 0.8

;
;*****************************************************************************************
; SCIENCE STACK DATA - CURRENTS
; 
;
;
cgplot, ssall.jd, ssall.relay06, psym=8, xstyle = 3, $
			charsize = 1.0, ytickformat='(F6.1)', $
			yrange = [0.0, 6.0], symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Current (Amps)', title = 'Relay Currents (Science Stack Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase


oplot, ssall.jd, ssall.relay07, psym=8, color = cgColor('Red'), symsize = 0.5
oplot, ssall.jd, ssall.relay08, psym=8, color = cgColor('Green'), symsize = 0.5
oplot, ssall.jd, ssall.relay09, psym=8, color = cgColor('Blue'), symsize = 0.5
oplot, ssall.jd, ssall.relay10, psym=8, color = cgColor('Orange'), symsize = 0.5
;
al_legend, ['ext. heat','int. center heat','int. aux heat','elev mtr','axial mtr'], $
			psym=[8,8,8,8,8],colors=['black','red','green','blue','orange'], charsize = 0.8

;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

cgErase



;
;*****************************************************************************************
; SCIENCE STACK DATA - Temperatures
;

cgplot, ssall.jd, ssall.relay_temp1, psym=8, xstyle = 3, $
			charsize = 1.3, ytickformat='(F6.1)', $
			yrange = [0.0,50.0], symsize = 0.5, $
			xtitle = 'Time (hh:mm)', ytitle = 'Temperature (deg C)', title = 'Temperatures (Science Stack Data)', $
   			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
   			XMINOR = 6, YMARGIN = [5,5], $
   			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

   			
   			
oplot, ssall.jd, ssall.relay_temp2,          psym=8, color = cgColor('Red'), symsize = 0.5
oplot, ssall.jd, ssall.elev_temp1,          psym=8, color = cgColor('Green'), symsize = 0.5
oplot, ssall.jd, ssall.elev_temp2,          psym=8, color = cgColor('Blue'), symsize = 0.5
;
al_legend, ['Relay Temp 1','Realy Temp 2','Elev Temp 1','Elev Temp 2'], $
			psym=[8,8,8,8],colors=['black','red','green','blue'], charsize = 0.8


;
;*****************************************************************************************
; End of page.  Print out header and footer.
;
xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'GRAPE SRV LRS Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE



;
;*********************************************************************
; Output Science Stack data to a text file.  
;
OPENW,  ss_unit, title + '_ss_data.txt', width = 300, /GET_LUN
printf, ss_unit, format='(C())', systime(/julian)
printf, ss_unit, 'SCIENCE STACK DATA'
printf, ss_unit, ' '
printf, ss_unit, 'HRS MINS SECS SECSOFDAY DAY MON YEAR JD RELAY01 RELAY02 RELAY03 RELAY04 RELAY05 RELAY06 RELAY07 RELAY08 RELAY09 RELAY10 VMON01 VMON02 VMON03 VMON04 VMON05 VMON06 VMON07 VOLTAGE_5 VOLTAGE_28 RELAY_TEMP1 RELAY_TEMP2 ACCELX ACCELY RELAY_PRESS ELEV_TEMP1 ELEV_TEMP2'
for i = 0, n_elements(ssall)-1 do begin
	printf, lrs_unit, $
			ssall[i].hrs, ssall[i].mins, ssall[i].secs, $
			long(ssall[i].hrs)*3600 + long(ssall[i].mins)*60 + long(ssall[i].secs), $
			ssall[i].day, ssall[i].month, $
			ssall[i].year, ssall[i].jd, $
			ssall[i].relay01, ssall[i].relay02, ssall[i].relay03, ssall[i].relay04, $
			ssall[i].relay05, ssall[i].relay06, ssall[i].relay07, ssall[i].relay08, $
			ssall[i].relay09, ssall[i].relay10, $
			ssall[i].vmon01, ssall[i].vmon02, ssall[i].vmon03, $
			ssall[i].vmon04, ssall[i].vmon05, ssall[i].vmon06, ssall[i].vmon07, $
			ssall[i].relay_voltage_5, ssall[i].batt_voltage_28, $
			ssall[i].relay_temp1, ssall[i].relay_temp2, ssall[i].accel_x, ssall[i].accel_y, $
			ssall[i].relay_press, ssall[i].elev_temp1, ssall[i].elev_temp2, $
	        format = '(3(1X,I2),1X,I6,2(1X,I2),1X,I4,1X,F16.5,26(1X,F9.3))'
endfor
close, /all

cgPS_Close, /delete_ps, /pdf


stop

end
		

		

