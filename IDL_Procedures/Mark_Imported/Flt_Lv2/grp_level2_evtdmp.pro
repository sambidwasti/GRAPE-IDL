pro grp_level2_evtdmp, filename, first_event, last_event

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRP_LEVEL2_EVTDMP
;
; The purpose of this routine is read a specified Level 1 datafile and perform
; a quicklook analysis.
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
;
;
; Outputs:
;
;
; Uses:
;
;		
;
; Author and History:
;		M. McConnell - Initial Version - July, 2013
;
;
;****************************************************************************************

;=========================================================================================
;

if (n_params() eq 0) then begin
  print, 'USAGE: Program_Name, <FileSearchString>, nfiles=<nfiles>, iverbose=<iverbose>'
  return
endif

;
;*****************************************************************************************
;  Here we define the structure to hold the output L2 event data.
;  Currently the event size is 247 bytes.
;
;			verno			BYTE		event format version number		
;			qflag			INT			event quality flag (0-10)
;    		sweepno			INT			sweep number
;    		swstart			DOUBLE		Sweep start time (secs from 0h UT on Sunday)
;    		swtime			DOUBLE		Sweep time (secs since start of sweep)
;    		evtime			DOUBLE		Event time (secs from 0h UT on Sunday)
;    		tjd				DOUBLE		Truncated Julian Date
;    		evclass			INT			Event Class (1=C,2=CC,3=PC,4=IM)
;			imflag			BYTE		Inter-Module Event flag (1=IM)
;			acflag			BYTE		Anti-Coincidence Flag
;			nanodes			BYTE		Number of triggered anodes
;			npls			BYTE		Number of plastic anodes
;			ncal			BYTE		Number of calorimeter anodes
;   		evtype			INT			Event Type (1=non-adj,2=corner,3=side)
;			anodeid			BYTE(8)		List of triggered anode ids
;			anodetype		BYTE(8)		List of triggered anode types
;			anodenrg		FLOAT(8)	List of triggered anode energies
;			anodesig		FLOAT(8)	List of triggered anode energy uncertainties
;    		pa_mod			INT			Primary Anode Module (position number)
;			pa_ser			INT			Primary Anode Module Serial No.
;    		pa_id			INT			Primary Anode Id
;    		pa_nrg			FLOAT		Primary Anode Energy
;			pa_sig			FLOAT		Primary Anode Energy Uncertainty
;    		sa_mod			INT			Secondary Anode Module (position number)
;			sa_ser			INT			Secondary Anode Module Serial No.
;    		sa_id			INT			Secondary Anode Id
;    		sa_nrg			FLOAT		Secondary Anode Energy
;			sa_sig			FLOAT		Secondary Anode Energy Uncertainty
;    		totnrg			FLOAT		Total event energy (keV)
;			totsig			FLOAT		Total event energy uncertainty (keV)
;    		compang			FLOAT		Compton Scatter Angle (degs)
;			compsig			FLOAT		Compton Scatter Angle Uncertainty (deg)
;			lat				FLOAT		Latitude (degs)
;			lon				FLOAT 		Longitude (degs)
;			alt				FLOAT		Altitude (feet)
;    		depth			FLOAT		Atmospheric Depth (g cm^-2)
;    		source			BYTE		source id (1-8)
;    		airmass			FLOAT		Pathlength towards source (g cm^-2)
;    		pntazi			FLOAT		Pointing Azimuth (degs)
;    		pntzen			FLOAT		Pointing Zenith (degs)
;    		srcazi			FLOAT		Source Azimuth (degs)
;    		srczen			FLOAT		Source Zenith (degs)
;    		srcoff			FLOAT		Source offset (degs)
;    		rtang			FLOAT		Rotation Table Angle (degs)
;    		rtstat			BYTE		Rotation Table Status
;    		sctang			FLOAT		Scatter Angle in instrument coords (degs)
;			pvang			FLOAT		Scatter Angle in pressure vessel coords (degs)
;			ppvang			FLOAT		Scatter Angle in projected PV coords (degs)
;			hrang			FLOAT		Hour Angle (degs)
;			parang			FLOAT		Paralactic Angle (degs)
;    		posang			FLOAT		Position angle of the scatter vector (deg)
;    		livetime		FLOAT		Instrument Livetime (fractional, 0-1)
;			correctlt		FLOAT		Corrected Instrument Livetime (fractional, 0-1)
;
;
	l2event = {     $
		 VERNO:0B, $				; Data format version number
		 QFLAG:0, $					; Event quality flag
		 SWEEPNO:0, $				; Sweep Number
		 SWSTART:0.0D, $			; Start time of sweep 
		 SWTIME:0.0D, $				; Time since start of sweep (secs)
		 EVTIME:0.0D, $            	; Event Time (secs in gps time - from 0h UT Sunday)
         TJD:0.0D, $		 		: Truncated Julian Date
		 EVCLASS:0, $             	; Event Class (1=C, 2=CC, 3=PC, 4= intermdule)
		 IMFLAG:0B, $				; = 1 for intermodule (2 module) event
		 ACFLAG:0B, $				; = 1 for anticoincidence
		 NANODES:0B, $				; Number of triggered anodes (1-8)
         NPLS:0B, $					; Number of triggered plastic anodes
         NCAL:0B, $					; Number of triggered calorimeter anodes
         EVTYPE:0, $		  		; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)
		 ANODEID:BYTARR(8), $		; Array of triggered anode numbers
		 ANODETYP:BYTARR(8), $		; Array of triggered anode types
		 ANODENRG:FLTARR(8), $		; Array of triggered anode energies
		 ANODESIG:FLTARR(8), $		; Array of triggered anode energy errors
		 PA_MOD:0, $				; Primary Anode Module Position No.
		 PA_SER:0, $				; Primary Anode Module Serial No.
		 PA_ID:0, $				; Primary Anode No.
		 PA_NRG:0.0, $				; Primary Anode Energy (keV)
		 PA_SIG:0.0, $				; Primary Anode Energy Uncertainty (keV)
		 SA_MOD:0, $				; Secondary Anode Module Position No.
		 SA_SER:0, $				; Secondary Anode Module Serial No.
		 SA_ID:0, $				; Secondary Anode No.
		 SA_NRG:0.0, $				; Secondary Anode Energy (keV)
		 SA_SIG:0.0, $				; Secondary Anode Energy Uncertainty (keV)
		 TOTNRG:0.0, $				; Total Event Energy (keV)
		 TOTSIG:0.0, $				; Total Event Energy Uncertainty (keV)
		 COMPANG:0.0, $				; Caluculated Compton Scatter Angle (deg)
		 COMPSIG:0.0, $				; Compton Scatter Angle Uncertainty (deg)
		 LAT:0.0, $					; Latitude (degs)
		 LON:0.0, $					; Longitude (degs)
		 ALT:0.0, $					; Altitude (feet)
		 DEPTH:0.0, $				; Atm Depth (g cm^-2)
		 SOURCE:0B, $
		 AIRMASS:0.0, $
		 PNTAZI:0.0, $				; Pointing Azimuth (degs)
		 PNTZEN:0.0, $				; Pointing Zenith (degs)
		 SRCAZI:0.0, $
		 SRCZEN:0.0, $
		 SRCOFF:0.0, $
		 RTANG:0.0, $				; Rotation Table Angle (degs) 
		 RTSTAT:0B, $				; Rotation Table Status 
         SCTANG:0.0, $				; Scatter Angle in instrument coords (degs)
		 PVANG:0.0, $				; Scatter Angle in pressure vessel coords (degs)
		 PPVANG:0.0, $				; Scatter Angle in projected PV coords (degs)
		 HRANG:0.0, $				; Hour Angle (degs)
		 PARANG:0.0, $				; Paralactic Angle (degs)
         POSANG:0.0, $		 		; Position angle of the scatter vector (deg)
		 LIVETIME:0.0, $
		 CORRECTLT:0.0  $
		 }

;
; Event Class (1=C, 2=CC, 3=PC, 4= intermdule)
;
classdef  = ['C type', 'CC type', 'PC Type', 'IM']  ;
;
;   rt_status -		status : 	1=restart, 2=started, 3=initial, 
;								4=PPS wait, 5=Pausing, 6=Rotating, 7=Rates
;
rtstatdef = ['restart', 'started','initial', 'PPS wait', 'Pausing','Rotating','Rates']
;
;					1 - Crab
;					2 - Sun
;					3 - Sun
;					4 - Cyg X-1
;					5 - not used
;					6 - Blank 2
;					7 - Blank 3
;					8 - transition (no specific pointing)
;
srcdef = ['Crab','Sun','Sun','Cyg X-1','unused','Blank 2','Blank 3','transition']
;
;*****************************************************************************************
; Get file size and determine the total number of events in the file.
;
f = file_info(filename)
nevents = f.size / 248.0                
;
;  Define the data array to hold the events.
; 
evdata = replicate(l2event, nevents)
;
;
openr, iunit, filename, /GET_LUN           ; open input data file
;
;   Read in next event into the 'event' structure.
;
readu, iunit, evdata
;
;   End of this file.  Close this file (calling free_lun closes the file and frees up 
;   the file unit number).
;
;		
free_lun, iunit

;
;*****************************************************************************************
;
openw,  ounit, 'level2_evtdmp.txt', width = 120, /GET_LUN
printf, ounit, format='(C())', systime(/julian)
printf, ounit, ' '
;
printf, ounit
printf, ounit
printf, ounit, "File Summary                 "
printf, ounit, "------------"
printf, ounit
printf, ounit, filename, format = '("Filename = ",A100)'
printf, ounit, f.size, format =   '("File Size (bytes) = ",I12)'
printf, ounit
printf, ounit, "Total no. of events = ", nevents
printf, ounit, "Time of first event = ", evdata[0].evtime
printf, ounit, "Time of last event  = ", evdata[nevents-1].evtime
printf, ounit, "Total elapsed time  = ", evdata[nevents-1].evtime - evdata[0].evtime
printf, ounit 
printf, ounit, "Sweep time of first event = ", evdata[0].swtime
printf, ounit, "Sweep time of last event  = ", evdata[nevents-1].swtime
printf, ounit, "Total elapsed time  = ", evdata[nevents-1].swtime - evdata[0].swtime
printf, ounit
printf, ounit, "Events with intermodule flag    = ", n_elements(where(evdata.imflag eq 1))
printf, ounit, "Number of C Events              = ", n_elements(where(evdata.evclass eq 1))
printf, ounit, "Number of CC Events             = ", n_elements(where(evdata.evclass eq 2))
printf, ounit, "Number of PC Events             = ", n_elements(where(evdata.evclass eq 3))
printf, ounit
printf, ounit, "Number of Events with 0 anode   = ", n_elements(where(evdata.nanodes eq 0))
printf, ounit, "Number of Events with 1 anode   = ", n_elements(where(evdata.nanodes eq 1))
printf, ounit, "Number of Events with 2 anode   = ", n_elements(where(evdata.nanodes eq 2))
printf, ounit, "Number of Events with 3 anode   = ", n_elements(where(evdata.nanodes eq 3))
printf, ounit, "Number of Events with 4 anode   = ", n_elements(where(evdata.nanodes eq 4))
printf, ounit, "Number of Events with 5 anode   = ", n_elements(where(evdata.nanodes eq 5))
printf, ounit, "Number of Events with 6 anode   = ", n_elements(where(evdata.nanodes eq 6))
printf, ounit, "Number of Events with 7 anode   = ", n_elements(where(evdata.nanodes eq 7))
printf, ounit, "Number of Events with 8 anode   = ", n_elements(where(evdata.nanodes eq 8))
printf, ounit, "Number of Events with >8 anodes = ", n_elements(where(evdata.nanodes gt 8))
printf, ounit
printf, ounit, "Number of Events with zero lt   = ", n_elements(where(evdata.livetime eq 0.0))
printf, ounit


;;;;;;;;;;;;;

for j = first_event, last_event do begin


	if evdata[j].npls gt 1 and evdata[j].ncal le 3 then begin

		printf, ounit,              		format = '("================================================================================")'
		printf, ounit
		printf, ounit, j,           		format = '("Event No.              =  ",I6)'
		printf, ounit, evdata[j].verno,  	format = '("Event Version No.      =  ",I3)' 
		printf, ounit, evdata[j].qflag,  	format = '("Quality Flag           =  ",I3)' 
		printf, ounit, evdata[j].sweepno,  	format = '("Sweep No.              =  ",I3)' 
		printf, ounit, evdata[j].swstart,	format = '("Sweep Start Time (s)   =  ",I12)'
		printf, ounit, evdata[j].swtime, 	format = '("Sweep Time (s)         =  ",F12.4)'
		printf, ounit, evdata[j].evtime, 	format = '("Event Time (s)         =  ",F12.4)'
		printf, ounit, evdata[j].tjd,	 	format = '("TJD				       =  ",F12.4)'
	;	printf, ounit, evdata[j].modpos,    format = '("Modpos(0-31)         =  ",I2)'
	;	printf, ounit, evdata[j].modser,    format = '("Mod Serial No.       =  ",I2)'
		printf, ounit, evdata[j].evclass, classdef[evdata[j].evclass-1], 	$
											format = '("Event Class            =  ",I2," (",A8,")")'
		printf, ounit, evdata[j].evtype,    format = '("Event Type             =  ",I2)'
		printf, ounit, evdata[j].imflag,    format = '("Mod Coinc Flag         =  ",I2)'
		printf, ounit, evdata[j].acflag,    format = '("Anti Coinc Flag        =  ",I2)'
		printf, ounit, evdata[j].nanodes,   format = '("No. of  Anodes         =  ",I2)'
		printf, ounit, evdata[j].npls,      format = '("No. of plastics        =  ",I2)'
		printf, ounit, evdata[j].ncal,      format = '("No. of cals            =  ",I2)'
		printf, ounit, evdata[j].anodeid[0:7], $
											format = '("Anode Ids (0..63)      =  ",8(I6,1X))'
		printf, ounit, evdata[j].anodetyp[0:7], $
											format = '("Anode Type             =  ",8(I6,1X))'
	;	printf, ounit, evdata[j].anodepha[0:7], $
											format = '("Anode PHA              =  ",8(I6,1X))'
		printf, ounit, evdata[j].anodenrg[0:7], $
											format = '("Anode Energies         =  ",8(F6.1,1X))'
		printf, ounit, evdata[j].anodesig[0:7], $
											format = '("Anode Energy Errs      =  ",8(F6.1,1X))'
		printf, ounit, evdata[j].pa_mod,    format = '("Primary Anode Mod      =  ",I2)'
		printf, ounit, evdata[j].pa_ser,    format = '("Primary Anode Ser      =  ",I2)'
		printf, ounit, evdata[j].pa_id,     format = '("Primary Anode Id       =  ",I2)'
		printf, ounit, evdata[j].pa_nrg,    format = '("Primary Anode Energy   =  ",F8.2)'
		printf, ounit, evdata[j].pa_sig, 	format = '("Primary Anode Sigma    =  ",F8.2)'
		printf, ounit, evdata[j].sa_mod,    format = '("Secondary Anode Mod    =  ",I2)'
		printf, ounit, evdata[j].sa_ser,    format = '("Secondary Anode Ser    =  ",I2)'
		printf, ounit, evdata[j].sa_id,     format = '("Secondary Anode Id     =  ",I2)'
		printf, ounit, evdata[j].sa_nrg,    format = '("Secondary Anode Energy =  ",F8.2)'
		printf, ounit, evdata[j].sa_sig, 	format = '("Secondary Anode Sigma  =  ",F8.2)'

		printf, ounit, evdata[j].totnrg,	format = '("Total Energy           =  ",F8.2)'
		printf, ounit, evdata[j].totsig,	format = '("Total Energy Err       =  ",F8.2)'
		printf, ounit, evdata[j].compang,   format = '("Compton Angle          =  ",F8.2)'
		printf, ounit, evdata[j].compsig,   format = '("Compton Angle Err      =  ",F8.2)'
		printf, ounit, evdata[j].lat,       format = '("Latitude               =  ",F8.2)'
		printf, ounit, evdata[j].lon,       format = '("Longitude              =  ",F8.2)'
		printf, ounit, evdata[j].alt, 	    format = '("Altitude               =  ",F8.0)'
		printf, ounit, evdata[j].depth, 	format = '("Atm Depth              =  ",F8.2)'
		printf, ounit, evdata[j].source, srcdef[evdata[j].source-1], 	$
											format = '("Source Id              =  ",I2," (",A8,")")'
		printf, ounit, evdata[j].airmass, 	format = '("Airmass	               =  ",F8.2)'
		printf, ounit, evdata[j].pntazi, 	format = '("Pnt Azimuth            =  ",F8.2)'
		printf, ounit, evdata[j].pntzen, 	format = '("Pnt Zenith             =  ",F8.2)'
		printf, ounit, evdata[j].srcazi, 	format = '("Src Azimuth            =  ",F8.2)'
		printf, ounit, evdata[j].srczen, 	format = '("Src Zenith             =  ",F8.2)'
		printf, ounit, evdata[j].srcoff, 	format = '("Src Offset             =  ",F8.2)'
		printf, ounit, evdata[j].rtang, 	format = '("Table Angle            =  ",F8.2)'
		printf, ounit, evdata[j].rtstat, rtstatdef[evdata[j].rtstat-1], 	$
											format = '("Table Status           =  ",I2," (",A8,")")'
		printf, ounit, evdata[j].sctang, 	format = '("Scatter Angle          =  ",F8.2)'
		printf, ounit, evdata[j].pvang, 	format = '("Scatter Angle (PV)     =  ",F8.2)'
		printf, ounit, evdata[j].ppvang, 	format = '("Scatter Angle (PPV)    =  ",F8.2)'
		printf, ounit, evdata[j].hrang, 	format = '("Hour Angle             =  ",F8.2)'
		printf, ounit, evdata[j].parang, 	format = '("Parallactic Angle      =  ",F8.2)'

		printf, ounit, evdata[j].posang, 	format = '("Position Angle         =  ",F8.2)'
		printf, ounit, evdata[j].livetime, 	format = '("Livetime               =  ",F8.3)'
		printf, ounit, evdata[j].correctlt, format = '("Corrected Livetime     =  ",F8.3)'
	
		energy_map = fltarr(64)
		for i = 0,evdata[j].nanodes-1 do begin
			energy_map[evdata[j].anodeid[i]] = evdata[j].anodenrg[i]
		endfor
	
		printf, ounit
		printf, ounit, format = '("Anode Energy Map (keV)  -  upper left is anode 63, lower right is anode 0")'
		printf, ounit, reverse(energy_map[56:63]), 	format = '(8(F8.2,1X))'
		printf, ounit, reverse(energy_map[48:55]), 	format = '(8(F8.2,1X))'
		printf, ounit, reverse(energy_map[40:47]), 	format = '(8(F8.2,1X))'
		printf, ounit, reverse(energy_map[32:39]), 	format = '(8(F8.2,1X))'
		printf, ounit, reverse(energy_map[24:31]), 	format = '(8(F8.2,1X))'
		printf, ounit, reverse(energy_map[16:23]), 	format = '(8(F8.2,1X))'
		printf, ounit, reverse(energy_map[8:15]),  	format = '(8(F8.2,1X))'
		printf, ounit, reverse(energy_map[0:7]),   	format = '(8(F8.2,1X))'
		printf, ounit
		printf, ounit
	endif

endfor


stop
   
end 