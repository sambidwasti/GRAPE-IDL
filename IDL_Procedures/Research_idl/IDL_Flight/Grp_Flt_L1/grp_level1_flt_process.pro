pro grp_level1_flt_process, fsearch_string, auxpath, nfiles=nfiles, iverbose=iverbose

;****************************************************************************************
; Name:
;		GRP_LEVEL1_FLT_PROCESS
;
; Purpose:
;		Processes GRAPE flight data (2011) from raw (gps) data to level 1 data.
;
; Calling Sequence:
;
;
; Input Parameters:
;
;		fsearch_string - Provides a list of input gps datafiles. This uses regular 
;						 expressions to provide a list of files to be processed.
;
;		auxpath - The full directory path for the auxiliary data files (which 
; 		          includes the energy calibration files, the balloon position data,
;		          the instrument pointing data, and table angle data).
;
;		nfiles
;
;		iverbose
;
; Input Data Files:
;
;  		Ecal_ModP03.txt
;  		Ecal_ModP04.txt
;  		Ecal_ModP06.txt
;  		Ecal_ModP07.txt
;  		Ecal_ModP10.txt
;  		Ecal_ModP11.txt
;  		Ecal_ModP13.txt
;  		Ecal_ModP14.txt
;  		Ecal_ModP17.txt
;  		Ecal_ModP18.txt
;  		Ecal_ModP20.txt
;  		Ecal_ModP21.txt
;  		Ecal_ModP24.txt
;  		Ecal_ModP25.txt
;  		Ecal_ModP27.txt
;  		Ecal_ModP28.txt
;  		AtmDepthData.txt        ; Atm Depth vs. time 
;  		PositionData.txt      	; Lat, Long, Altitude vs. time 
;  		RotationTableData.txt 	; Table Angle vs. time 
;		PointingData.txt		; Pointing Data (azimuth, zenith vs time)
;
;
; Outputs:
;
;
; Uses:
;
;		INTERPOL
;		READCOL (astro IDL library)
;		VALUE_LOCATE
;		STRJOIN
;		CIRRANGE (astro IDL library)
;		
;
; Author and History:
;		M. McConnell - Initial Version - July, 2013
;
;
;****************************************************************************************
;

if (n_params() ne 2) then begin
  print, 'USAGE: grp_level1_process, Input File Search String, Path to Auxilliary Data, Number of files to process"
  print, 'Makes a File With Processed data"
  return
endif


if keyword_set(iverbose) ne 1 then iverbose = 0

if n_params() ne 2 then fsearch_string = 'gps*.dat'

gpsfiles = FILE_SEARCH(fsearch_string)   				; get list of gps input files

if keyword_set(nfiles) ne 1 then nfiles = n_elements(gpsfiles)

;=========================================================================================
;
;  Event format version number
;
verno = 6B

;
;=========================================================================================
;
print
print, "*******************************"
print, "LEVEL 1 FLIGHT DATA PROCESSING "
print, "*******************************"
print, "GRP_LEVEL1_FLT_PROCESS.PRO
print, "Data Format version number ", verno
print
print
print
;
;
;=========================================================================================
;
;  Calorimeter element anode ids (0..63)
;
cal_anodes = [0,1,2,3,4,5,6,7,8,15,16,23,24,31,32,39,40,47,48,55,56,57,58,59,60,61,62,63]

; 
;=========================================================================================
;
;  Plastic element anode Ids (0..63)
;
pls_anodes = [9,10,11,12,13,14,17,18,19,20,21,22,25,26,27,28,29,30,33,34,35,36,37,38,41, $
		42,43,44,45,46,49,50,51,52,53,54]

;
;
;=========================================================================================
;
;  Module position numbers for the 16 flight detectors (0..31)
;  These position numbers correspond to one of the 32 positions on the MIB.
;
module_pos = [3,4,6,7,10,11,13,14,17,18,20,21,24,25,27,28]   

;
;
;=========================================================================================
;
;  Module serial number for each of the 16 flight detectors
;  The serial number identifiers the specific piece of hardware
;
module_ser = [1,2,3,18,5,6,7,8,9,10,11,12,13,15,16,19]       

;
;=========================================================================================
;
;  PointingData.txt 	- pnt_times, azi_values, zen_values
;						  These data come HRS data recorded on the GSE. (They are not
;						  recorded on board!)  Times are in gps time.  Time range is 
;						  from 434016 to 585561.
;
readcol, strjoin([auxpath, 'PointingData.txt']), $
			pnt_gpstimes, azi_values, zen_values, cosazi_values, sinazi_values, $
							coszen_values, sinzen_values, /silent

;
;=========================================================================================
;
;  PositionData.txt 	- pos_times, lat_values, lon_values, alt_values
;						  These data come from the rotator data provided by CSBF.
;						  Time is in gps time. Time range is 471599 to 601243.
;
readcol, strjoin([auxpath, 'PositionData.txt']), $
			pos_gpstimes, lat_values, lon_values, alt_values, /silent
			
;
;=========================================================================================
;
;  AtmDepthData.txt  	- dep_times, dep_values
;						  These data from CSBF CIP data.  We have converted mbars to
;						  grammage.  Time is in gps time. Time range is 483700 to 587398.
;
readcol, strjoin([auxpath, 'AtmDepthData.txt']), $
			dep_gpstimes, dep_values, /silent

;
;
;=========================================================================================
;
; Read in Rotation Table Data
;
;	rt_time -		time measured in secs from 0h UT on Sep 23
;	rt_gpstime - 	time measured in secs from 0h UT on previous Sunday
;	rt_swtime	- 	time (in secs) since start of sweep
;	rt_sweep -		sweep number (corrected)
;   rt_status -		status : 	1=restart, 2=started, 3=initial, 
;								4=PPS wait, 5=Pausing, 6=Rotating, 7=Rates
;	rt_step -		indicates step size (+4 or -4)
;	rt_angle -		table angle value
;
readcol, strjoin([auxpath, 'RotationTableData.txt']), $
				rt_time, $			; time (secs) since 0h UT on Sep 23
				rt_gpstime, $		; time (secs) since beginning of week
				rt_swtime, $		; time (secs) since beginning of sweep
				rt_sweep, $			; sweep number
				rt_status, $		; rotation table status
				rt_step, $			; rotation table step size
				rt_angle, $			; rotation table angle
				format='F,F,F,I,I,I,I', /silent

;
;=========================================================================================
;
;  Read in energy calibration data. 
;
Ecal_m     = fltarr(32,64)
Ecal_b     = fltarr(32,64)
Ecal_m_err = fltarr(32,64)
Ecal_b_err = fltarr(32,64)

Slopes    = fltarr(64)
Offsets   = fltarr(64)
SlopeErr  = fltarr(64)
OffsetErr = fltarr(64)

nmodules   = n_elements(module_pos)
;
;  Read in energy calibration data. 
;  In this case, there is one file for each module.
;  Each file contains energy calibration parameters for each of 64 anodes.
;  The numbers in each file / variable name are the module position numbers.
;  Ecal_ModP03.txt - EcalAnodeP03, EcalSlopeP03, EcalOffsetP03
;  Ecal_ModP04.txt - EcalAnodeP04, EcalSlopeP04, EcalOffsetP04
;  Ecal_ModP06.txt - EcalAnodeP06, EcalSlopeP06, EcalOffsetP06
;  Ecal_ModP07.txt - EcalAnodeP07, EcalSlopeP07, EcalOffsetP07
;  Ecal_ModP10.txt - EcalAnodeP10, EcalSlopeP10, EcalOffsetP10
;  Ecal_ModP11.txt - EcalAnodeP11, EcalSlopeP11, EcalOffsetP11
;  Ecal_ModP13.txt - EcalAnodeP13, EcalSlopeP13, EcalOffsetP13
;  Ecal_ModP14.txt - EcalAnodeP14, EcalSlopeP14, EcalOffsetP14
;  Ecal_ModP17.txt - EcalAnodeP17, EcalSlopeP17, EcalOffsetP17
;  Ecal_ModP18.txt - EcalAnodeP18, EcalSlopeP18, EcalOffsetP18
;  Ecal_ModP20.txt - EcalAnodeP20, EcalSlopeP20, EcalOffsetP20
;  Ecal_ModP21.txt - EcalAnodeP21, EcalSlopeP21, EcalOffsetP21
;  Ecal_ModP24.txt - EcalAnodeP24, EcalSlopeP24, EcalOffsetP24
;  Ecal_ModP25.txt - EcalAnodeP25, EcalSlopeP25, EcalOffsetP25
;  Ecal_ModP27.txt - EcalAnodeP27, EcalSlopeP27, EcalOffsetP27
;  Ecal_ModP28.txt - EcalAnodeP28, EcalSlopeP28, EcalOffsetP28
;
for i = 0,nmodules-1 do begin
	filename = strjoin([auxpath, 'Ecal_ModP', strn(module_pos[i], format='(I02)', padch='0'), '.txt'])
	readcol, filename, Anodes, Slopes, Offsets, SlopeErr, OffsetErr, /silent
	Ecal_m[module_pos[i],*]     = Slopes
	Ecal_b[module_pos[i],*]     = Offsets
	Ecal_m_err[module_pos[i],*] = SlopeErr
	Ecal_b_err[module_pos[i],*] = OffsetErr
endfor



;
;=========================================================================================
;
;  Here we define the structure to hold the output L1 event data.
;  Currently the event size is 177 bytes.
;
l1event = {     $
		 VERNO:0B, $				; Data format version number
		 SWEEPNO:0, $				; Sweep Number
		 SWSTART:0.0D, $			; Start time of sweep 
		 SWTIME:0.0D, $				; Time since start of sweep (secs)
		 EVTIME:0.0D, $            	; Event Time (secs in gps time - from 0h UT Sunday)
		 MODPOS:0B, $				; Module Position Number
		 MODSER:0B, $				; Module Serial Number
		 EVCLASS:0B, $             	; Event Class (1=C, 2=CC, 3=PC, 4= intermdule)
		 IMFLAG:0B, $				; = 1 for intermodule (2 module) event
		 ACFLAG:0B, $				; = 1 for anticoincidence
		 NANODES:0B, $				; Number of triggered anodes (1-8)
		 NPLS:0B, $					; Number of triggered plastic anodes
		 NCAL:0B, $					; Number of triggered calorimeter anodes
		 ANODEID:BYTARR(8), $		; Array of triggered anode numbers
		 ANODETYP:BYTARR(8), $		; Array of triggered anode types
		 ANODEPHA:INTARR(8), $		; Array of triggered anode pulse heights
		 ANODENRG:FLTARR(8), $		; Array of triggered anode energies
		 ANODESIG:FLTARR(8), $		; Array of triggered anode energy errors
		 TOTNRG:0.0, $				; Total energy (sum of ALL triggered anodes)
		 TOTESIG:0.0, $				; Error on total energy (sum of ALL triggered anodes)
		 LAT:0.0, $					; Latitude (degs)
		 LON:0.0, $					; Longitude (degs)
		 ALT:0.0, $					; Altitude (feet)
		 DEPTH:0.0, $				; Atm Depth (g cm^-2)
		 PNTAZI:0.0, $				; Pointing Azimuth (degs)
		 PNTZEN:0.0, $				; Pointing Zenith (degs)
		 RTANG:0.0, $				; Rotation Table Angle (degs) 
		 RTSTAT:0, $				; Rotation Table Status 
		 LIVETIME:0.0, $
		 CORRECTLT:0.0  $
		 }

;
;=========================================================================================
;
for ifile = 0, nfiles-1 do begin
		infile = gpsfiles[ifile]

;
;  		Open input data file, read in all of the data (into array 'data'), and then 
;  		close the input data file.
;
		openr, inunit, infile, /GET_LUN
 		data = READ_BINARY(inunit)  
 		free_lun, inunit

;
; 		Each data packet is 32 bytes. Not all packets contain event info.
;
		totpkt = n_elements(data) / 32            ; total number of packets in file
		
;
; 		There are 8 different types of data packets.  This array keeps track of the 
; 		total number of packets of each type for this file.
;
		npackets = lonarr(8)     ; array to keep track of packet type totals
;
		ipkt  = 0L						; initialize packet counter for this file
		nevts = 0L						; initialize event counter for this file
;
;  		Define the data array to hold the output events.
; 
		l1data = replicate(l1event, totpkt)		; initialize output data array
		
;
;		Get start time of sweep from the filename.  This value is included as a 9-digit 
;       number in the filename.
;		It is measured in msec, so we must divide by 1000 to get the time in secs.
;		It is measured in time since the beginning of the week (0h UT on Sunday)
;
		swstart = double(strmid(infile,4,9)) / 1000.0
;
;		Get sweep number from input filename.
; 		Typical flight data file name is 'gps-544691000-c0020.dat'
; 
		sweep = fix(strmid(infile,strpos(infile,'.')-4, 4))
;
;  		During the 2011 balloon flight, we had to power cycle the computer, which 
;  		effectively reset the sweep counter (as recorded in the GPS data files).
;  		This makes the adjustment for the sweep number for all GPS data files
;  		generated after the reboot.
; 
 		if swstart gt 520631 then sweep = sweep + 43  ;when the computers were reset
;
;  		Output file name.  
;
 		outfile = strjoin(['Level1_v06_Sweep_',strn(sweep, format='(I03)', padtype=1),'.dat'])

;
;  		Open output data file.
;
 		openw, outunit, outfile, /GET_LUN
;
		print
		print, "************************************************************************"
		print, "Input File No.      = ", ifile+1
		print, "Input GPS File      = ", infile
		print, "Output Level 1 File = ", outfile
		print, "Sweep Number        = ", sweep
		print
		print
;
;       ==================================================================================
;
		for i = 0L, totpkt-1 do begin
			ifirst = (i-1)*32      		; first byte for this packet
			ilast  = ifirst+31      	; last byte for this packet
			pkt = data(ifirst:ilast)	; this packet
;
;			ptype is the packet type
;				ptype = 0  ==>  unused
;				ptype = 1  ==>  C event
;				ptype = 2  ==>  CC event
;				ptype = 3  ==>  PC event
;				ptype = 4  ==>  unused
;				ptype = 5  ==>  module threshold data
;				ptype = 6  ==>  module housekeeping
;				ptype = 7  ==>  module rates
;
 	    	ptype = ishft(pkt(6) and '01110000'B, -4)
;
;			increment packet counter (based on packet type)
;
 	    	npackets[ptype] = npackets[ptype]+1
;
;  			tsecs1 gives time in units of seconds
;  			tsecs2 gives time in units of 20 microsecs
; 
	   		tsecs1 = swap_endian(fix(pkt,0,type=12))     ; bytes 0-1
	    	tsecs2 = swap_endian(fix(pkt,2,type=12))     ; bytes 2-3
;
;			Time since start of sweep
;
	    	swtime = tsecs1 + tsecs2*0.000020D
;
;			Full event time.  Time since 0h UT on Sunday.
;
	    	evtime = swstart + swtime 
;
;			module coincidence flag ('1' = module coincidence)
;
	    	imflag = pkt(4)								   ; byte 4
;
;			modpos is the module position number (0-31)
;
 	    	modpos = fix(pkt(5))                           ; byte 5
;
;  			Extract the module serial number from the array defined above.
;  
  			modser = module_ser(where(modpos eq module_pos))
;
;			acflag is anti-coincidence flag ('1' = coincident event)
;
    		acflag = ishft(pkt(6),-7) 					   ; byte 6, bit 7
;
;			module livetime (0-255)
;			Convert integer value (0-255) to fractional value (0.0-1.0)
;
 	    	livetime = pkt(7) / 255.0
;        
;           =============================================================================
;       	We are only interested in event data.  So only C, CC, and PC event data
;       	are processed further.
;
	  		if (ptype ge 1 and ptype le 3) then begin
;
;       		nanodes is the number of non-zero PHA values    ; byte 6, bits 0-3
;
   				nanodes = pkt(6) and '00001111'B
;    
				datawd = intarr(8)
				anode  = intarr(8)
				pha    = intarr(8)
				type   = intarr(8)
				nrg    = fltarr(8)
				nrgsig = fltarr(8)
;
;           	extract anode number and PHA value from each of eight 16-bit words
;		
				for j = 0,7 do begin
					datawd[j] = swap_endian(fix(pkt,8+j*2,type=12))
					anode[j]  = ishft(datawd[j] and '1111110000000000'B, -10)   ; 0-63
					pha[j]    = datawd[j] and '0000001111111111'B
					type[j]   = 0
				endfor	

;
;				For each anode, find out whether it is a plastic or calorimeter. 
;				Anodes are numbered from 0-63.
;
				for j = 0, min([nanodes,8])-1 do begin
					if (where ((anode[j]) eq pls_anodes) ge 0) then type[j] = 1	; plastic
					if (where ((anode[j]) eq cal_anodes) ge 0) then type[j] = 2	; calorimeter
				endfor

;
;				Extract number of plastic and calorimeter elements.
;
				npls = n_elements(where(type eq 1, /null))
				ncal = n_elements(where(type eq 2, /null))
								
;
;				Convert PHA values to energy (keV)
;				
				for j = 0, min([nanodes,8])-1  do begin
					nrg[j]    = Ecal_m[modpos,anode[j]]*pha[j] + Ecal_b[modpos,anode[j]]
					nrgsig[j] = sqrt(float(pha[j])^2*Ecal_m_err[modpos,anode[j]]^2 $
													+ Ecal_b_err[modpos,anode[j]]^2)
				endfor

;
;				Calculate total energy and the error on total energy.
;				Use only those anodes that are triggered.
;
				totnrg  = total(nrg[0:min([nanodes,8])-1])
				totesig = sqrt(total(nrgsig[0:min([nanodes,8])-1]^2))
				
;
; 				packet id (event number)
;
 	        	pcktid = swap_endian(fix(pkt,30,type=12))  
;
;  				Get the position data for this event time.  
;				Time here is in seconds from the start of the week (GPS times).
;				Values of -1.0 are provided if times are outside of the tabulated range.
;  
				latitude  = interpol(lat_values,pos_gpstimes, evtime)
				longitude = interpol(lon_values,pos_gpstimes, evtime)
				altitude  = interpol(alt_values,pos_gpstimes, evtime)
				if (evtime lt min(pos_gpstimes) or evtime gt max(pos_gpstimes) ) then begin
					latitude  = -1.0
					longitude = -1.0
					altitude  = -1.0
				endif
;				
;  				Get the atmospheric depth data for this event time.  
;				Time here is in seconds from the start of the week (GPS times).
;				Values of -1.0 are provided if times are outside of the tabulated range.
;  
				depth     = interpol(dep_values,dep_gpstimes, evtime)
				if (evtime lt min(dep_gpstimes) or evtime gt max(dep_gpstimes) )  then begin
					depth  = -1.0
				endif
;
;  				Get the pointing data for this event time.  
;				Time here is in seconds from the start of the week (GPS times).
;				Values of -1.0 are provided if times are outside of the tabulated range.
;				To avoid issues of interpolating angle values across range boundaries 
;				(say, from 359 -> 1), we interpolate both the sin and cos values
;				and use atan to get the angles.
;  
				cosazi   = interpol(cosazi_values,pnt_gpstimes, evtime)
				sinazi   = interpol(sinazi_values,pnt_gpstimes, evtime)
				azimuth  = atan(sinazi, cosazi) * !radeg
				cirrange, azimuth
;
				coszen   = interpol(coszen_values,pnt_gpstimes, evtime)
				sinzen   = interpol(sinzen_values,pnt_gpstimes, evtime)
				zenith   = atan(sinzen, coszen) * !radeg
				cirrange, zenith

				if (evtime lt min(pnt_gpstimes) or evtime gt max(pnt_gpstimes) )  then begin
					azimuth  = -1.0
					zenith   = -1.0
				endif
		
;				The table angle values are retrieved using the value_locate function.
; 				The times provided in these data refer to the time at which the table 
;				completing moving to the corresponding table angle value. Unlike the 
;				interpolations above, we want to take into account the fact that the 
; 				table stays at that position until the next entry.
;				
				rtang   = rt_angle  (value_locate(rt_gpstime, evtime))
				rtstat	= rt_status (value_locate(rt_gpstime, evtime))
				sweepno = rt_sweep  (value_locate(rt_gpstime, evtime))
;
;
;           >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 	        
 	        	if iverbose eq 1 and i lt 100 then begin
					typedef = ['unused','C type', 'CC type', 'PC Type', 'unused', 'Threshold', 'Housekeeping', 'Rates']  ;
					print, pkt, format = '(32(Z2.2,x))'
					print
					print, pcktid, 		format = 		  '("Packet Id = ",I6)'
					print, sweep,  		format = 		  '("Sweep No. = ",I6)'					
					print, swstart,		format = 		  '("Sweep Start Time (s)    =  ",I16)'
					print, swtime, 		format = 		  '("Sweep Time (s)          =  ",F16.4)'
					print, evtime, 		format = 		  '("Event Time (s)          =  ",F16.4)'
					print, latitude,    format =		  '("Latitude        =	 ",F8.2)'
					print, longitude, 	format =		  '("Longitude       =	 ",F8.2)'
					print, altitude, 	format =		  '("Altitude        =	 ",F8.0)'
					print, depth, 		format =		  '("Depth           =	 ",F8.2)'
					print, azimuth, 	format =		  '("Pnt Azi         =	 ",F8.2)'
					print, zenith, 		format =		  '("Pnt Zen         =	 ",F8.2)'
					print, rtang, 		format =		  '("Table Angle     =	 ",F8.2)'
					print, rtstat, 		format = 		  '("Table Status    =   ",I1)'
					print, livetime, 	format =		  '("Livetime        =	 ",F8.3)'
					print, imflag,      format =          '("Mod Coinc Flag  =   ",I1)'
					print, acflag,      format =          '("Anti Coinc Flag =   ",I1)'
					print, modpos,      format =          '("Modpos(0-31)    =  ",I2)'
					print, modser,      format =          '("Mod Serial No.  =  ",I2)'
					print, livetime,    format =          '("Livetime 	     = ",F6.3)'
					print, ptype, typedef[ptype],format = '("Data Type       =   ",I1," (",A8,")")'
					print, nanodes,     format =	      '("No. of  Anodes  =	 ",I1)'
					print, npls,        format =		  '("No. of plastics =	 ",I1)'
					print, ncal,        format =		  '("No. of cals     =	 ",I1)'
					print, totnrg,		format =		  '("Total Energy    =	 ",F8.3)'
					print, totesig,		format =		  '("Total Energy Err=	 ",F6.3)'
					
					
					for j = 0,nanodes-1	do print, j+1, type[j], anode[j], pha[j], nrg[j], nrgsig[j], $
								format =  '(I1,"- Type, Anode(0-63), PHA, Energy, Energy Err    =  ", I1,"  ",I2,"  ",I4,"  ",F8.3,"  ",F7.3)
					print
				endif
				
;           >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 	        
;  				Output event message :
;
;				verno			BYTE		event format version number		
;    			sweepno			INT			sweep number
;				swstart			DOUBLE		Sweep start time
;    			swtime			DOUBLE		Sweep time (secs since start of sweep)
;    			evtime			DOUBLE		Event time (secs from 0h UT on Sunday)
;				modpos			BYTE		Module position number (0..31)
;				modser			BYTE		Module serial number
;    			evclass			BYTE		Event Class (1=C,2=CC,3=PC,4=IM)
;				imflag			BYTE		Inter-Module Event flag (1=IM)
;				acflag			BYTE		Anti-Coincidence Flag
;				nanodes			BYTE		Number of triggered anodes
;				npls			BYTE		Number of plastic anodes
;				ncal			BYTE		Number of calorimeter anodes
;				anodeid			BYTE(8)		List of triggered anode ids (0..63)
;				anodetype		BYTE(8)		Anode Type (1=plastic, 2=calorimeter)
;				anodepha		INT(8)
;				anodenrg		FLOAT(8)	List of triggered anode energies
;				anodesig		FLOAT(8)	List of triggered anode energy errors
;    			totnrg			FLOAT		Total event energy (keV)
;    			totesig			FLOAT		Error on total event energy (keV)
;				lat				FLOAT		Latitude (degs)
;				lon				FLOAT 		Longitude (degs)
;				alt				FLOAT		Altitude (ft)
;    			depth			FLOAT		Atmospheric Depth (g cm^-2)
;    			pntazi			FLOAT		Pointing Azimuth (degs)
;    			pntzen			FLOAT		Pointing Zenith (degs)
;    			rtang			FLOAT		Rotation Table Angle (degs)
;    			rtstat			INT			Rotation Table Status
;    			livetime		FLOAT		Instrument Livetime (fractional, 0-1)
;				correctlt		FLOAT		Corrected livetime (1 second shift)
;  
;				Transfer the data for this event to the output array.
;
;
				L1EVENT.VERNO 	  = verno
				L1EVENT.SWEEPNO   = sweep
				L1EVENT.SWSTART   = swstart
				L1EVENT.SWTIME 	  = swtime
				L1EVENT.EVTIME    = evtime
				L1EVENT.MODPOS    = byte(modpos)		; convert from INT to BYTE
				L1EVENT.MODSER    = byte(modser)		; convert from INT to BYTE
				L1EVENT.EVCLASS   = byte(ptype)			; convert from INT to BYTE
				L1EVENT.IMFLAG    = imflag
				L1EVENT.ACFLAG    = acflag
				L1EVENT.NANODES   = byte(nanodes)		; convert from INT to BYTE
				L1EVENT.NPLS	  = byte(npls)			; convert from LONG to BYTE
				L1EVENT.NCAL	  = byte(ncal)			; convert from LONG to BYTE
				L1EVENT.ANODEID   = byte(anode)			; convert from INT to BYTE
				L1EVENT.ANODETYP  = byte(type)			; convert from INT to BYTE
				L1EVENT.ANODEPHA  = pha
				L1EVENT.ANODENRG  = nrg
				L1EVENT.ANODESIG  = nrgsig
				L1EVENT.TOTNRG    = totnrg
				L1EVENT.TOTESIG   = totesig
				L1EVENT.LAT       = float(latitude)		; convert from DOUBLE to FLOAT
				L1EVENT.LON		  = float(longitude)		; convert from DOUBLE to FLOAT
				L1EVENT.ALT 	  = float(altitude)		; convert from DOUBLE to FLOAT
				L1EVENT.DEPTH	  = float(depth)			; convert from DOUBLE to FLOAT
				L1EVENT.PNTAZI    = float(azimuth)		; convert from DOUBLE to FLOAT
				L1EVENT.PNTZEN 	  = float(zenith)		; convert from DOUBLE to FLOAT
				L1EVENT.RTANG     = float(rtang)			; convert from INT to FLOAT
				L1EVENT.RTSTAT    = rtstat
				L1EVENT.LIVETIME  = livetime
				L1EVENT.CORRECTLT = -1.0
;
;				Add event to the event array
;		
				l1data[nevts] = l1event
				nevts = nevts + 1

			endif
;           =============================================================================
;
;		Get next packet in this file...
;
		endfor     
;
;       ==================================================================================
;
;   	End of this file...
;  
;		Trim the unused space allocated to the l1data structure.  This is done by 
;		resizing the structure based on the number of events. 
;         
        l1data = l1data[0:nevts-1]
;
;		For correcting the livetime, we need to isolate the data from each module, 
;		since livetime is module-dependent.  So we start by setting up arrays of 
;		event time and livetime, from which we will correct the livetimes.
;
		ltable_evtime = [ $
			ptr_new(l1data[where (l1data.modpos eq module_pos[0])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[1])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[2])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[3])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[4])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[5])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[6])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[7])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[8])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[9])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[10])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[11])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[12])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[13])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[14])].evtime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[15])].evtime, /no_copy)]
					
		ltable_ltime = [ $
			ptr_new(l1data[where (l1data.modpos eq module_pos[0])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[1])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[2])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[3])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[4])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[5])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[6])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[7])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[8])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[9])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[10])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[11])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[12])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[13])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[14])].livetime, /no_copy), $
			ptr_new(l1data[where (l1data.modpos eq module_pos[15])].livetime, /no_copy)]
					
;
;		Correct livetime to account for the the fact that the livetime for a given 
;		event is averaged over the previous one-second time interval.  So the true
;		livetime associated with a given comes from livetime values that are 
;       measured 1.0 second later.  In most cases, this is of little consequence,
;		but for rapid transients (flares or GRBs), this could be important.
;
;		At the end of the file, the last 1 seconds of data takes on the livetime of the 
;		last event.
;
        for i = 0, nevts-1 do begin
        	im = where(module_pos eq l1data[i].modpos)
			l1data[i].correctlt = interpol(	*ltable_ltime[im[0]], *ltable_evtime[im[0]],  $
											l1data[i].evtime+1.0)
		endfor
		        
;
;		Write entire structure to the output file in one statement.
;     
      	writeu, outunit, l1data
;
;		Close this file.  Calling free_lun closes the file and frees up the unit 
;   	number.
; 
		free_lun, outunit
;
;		Print out packet statistics for this file.
;
		print, "Packet Statistics                 "
		print, "-----------------"
		print
		print, "TOTAL No. OF PACKETS         = ",totpkt
		print, "Type 0 - unused              = ",npackets[0] 
		print, "Type 1 -  C Type Events      = ",npackets[1]
		print, "Type 2 - CC Type Events      = ",npackets[2]
		print, "Type 3 - PC Type Events      = ",npackets[3]
		print, "Type 4 - unused              = ",npackets[4]
		print, "Type 5 - Threshold Data      = ",npackets[5]
		print, "Type 6 - Housekeeping Data   = ",npackets[6]
		print, "Type 7 - Rates Data          = ",npackets[7]
		print
		print
;
;		Print out total counts and elasped time info.
;		It has been noted that there were many files in which the first one or two events
;		had bad times, which led to elapsed times of less than zero.  It was found that 
;		these events with bad times also had a rotation table status of 7 (RATES), which
;		also didn't seem to make sense, as there should be no events during the RATES 
;		period.  So here we determine elapsed time based on events that do not have a RT 
;		status of 7.
;		
		print, "File Summary                 "
		print, "------------"
		print
		print, "Total no. of events = ", nevts
		print, "Time of first event = ", l1data[min(where(l1data.rtstat ne 7))].evtime
		print, "Time of last event  = ", l1data[nevts-1].evtime
		print, "Total elapsed time  = ", l1data[nevts-1].evtime - l1data[min(where(l1data.rtstat ne 7))].evtime
		print
		print

;
; Go get next file...
; 
endfor
;
;=========================================================================================
;

print
print, "***************************"
print, "LEVEL 1 PROCESSING COMPLETE"
print, "***************************"
print

stop


end 