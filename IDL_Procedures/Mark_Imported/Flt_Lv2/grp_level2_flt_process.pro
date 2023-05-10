
pro grp_level2_flt_process, fsearch_string, auxpath, nfiles=nfiles, iverbose=iverbose 

;****************************************************************************************
; Name:
;		NAME
;
; Purpose:
;		Brief Description
;
; Calling Sequence:
;
;
; Inputs:
;		arg1 - Description of argument 1 
;
;		arg2 - Description of argument 2 
;
;		data1 - Description of datafile 1 
;
;
; Outputs:
;
;
; Uses:
;
;		GRP_AUXDATA    	- Reads in auxiliary data files.
;		GRP_ECALDATA   	- Reads in anode energy calibration files.
;		GRP_RTDATA		- Reads in Rotation Table data
;		GRP_GETAUX     	- Handles lookup of auxiliary data value for a given time.
;
;		
;
; Author and History:
;		M. McConnell - Initial Version - July, 2013
;
;
;****************************************************************************************



    if (n_params() ne 2) then begin
      print, 'USAGE: Program_Name, <FileSearchString>, <auxpath>, nfiles=<nfiles>, iverbose=<iverbose>'
      return
    endif
    
    if keyword_set(iverbose) ne 1 then iverbose = 1
    
    ;if n_params() ne 1 then fsearch_string = 'Lv1*.dat'
    
    lv1files = FILE_SEARCH(fsearch_string)   				; get list of level 1 input files
    
    if keyword_set(nfiles) ne 1 then nfiles = n_elements(lv1files)
    
    ;
    ;=========================================================================================
    ;  Get the data that holds the hardware upper limits for each anode.
    ;
    
    hdw_uplims = fltarr(32,64)
    rowdat = intarr(32)
    line1 = ' '
    
    openr, inunit, strjoin([auxpath, 'hdw_upper_limits.dat']), /GET_LUN
    				
    readf, inunit, line1
    readf, inunit, hdw_uplims
    
    free_lun, inunit
    
    ;
    ;=========================================================================================
    ;  Get the data that holds the hardware lower limits for each anode.
    ;
    
    hdw_lolims = fltarr(32,64)
    rowdat = intarr(32)
    line1 = ' '
    
    openr, inunit, strjoin([auxpath, 'hdw_lower_limits.dat']), /GET_LUN
    				
    readf, inunit, line1
    readf, inunit, hdw_lolims
    
    free_lun, inunit
    
    
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
    		 TOTSIG:0.0, $				; Error on total energy (sum of ALL triggered anodes)
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
    ;
    ;  Here we define the structure to hold the output L2 event data.
    ;
    	l2event = {     $
    		 VERNO:0B, $				; Data format version number
    		 QFLAG:0, $					; Event quality flag
    		 SWEEPNO:0, $				; Sweep Number
    		 SWSTART:0.0D, $			; Start time of sweep 
    		 SWTIME:0.0D, $				; Time since start of sweep (secs)
    		 EVTIME:0.0D, $            	; Event Time (secs in gps time - from 0h UT Sunday)
             TJD:0.0D, $		 		; Truncated Julian Date
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
    		 PA_ID:0, $					; Primary Anode No.
    		 PA_NRG:0.0, $				; Primary Anode Energy (keV)
    		 PA_SIG:0.0, $				; Primary Anode Energy Uncertainty (keV)
    		 SA_MOD:0, $				; Secondary Anode Module Position No.
    		 SA_SER:0, $				; Secondary Anode Module Serial No.
    		 SA_ID:0, $					; Secondary Anode No.
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
    ;	Quality Flag Definitions
    ;		0 - no processing (level 1 equivalent)
    ;		1 - one or more anodes has an energy less than zero.
    ;		2 - one or more anodes has an energy above defined hardware range.
    ;		3 - 
    ;		4 - 
    ;		5 - 
    ;		6 -
    ;		7 -
    ;		8 - 
    ;		9 - 
    ;		10 - Fully processed event
    ;
    
     c_events = lonarr(20)								; define C event counters
    cc_events = lonarr(20)								; define CC event counters
    pc_events = lonarr(20)								; define PC event counters
    
    ;
    ;  Start loop that processes each input file.
    ;
    for ifile = 0, nfiles-1 do begin
    		infile = lv1files[ifile]
    		openr, inunit, infile, /GET_LUN
    		
    		 c_events[*] = 0L							; zero C event counters
    		cc_events[*] = 0L							; zero CC event counters
    		pc_events[*] = 0L							; zero PC event counters
    
    ;
    ;  		Get sweep number from filename.  
    ;  		Here we assume that the filename is of the form 'Lv1*_Sweep_NN.dat', where 'NN' is
    ;  		the sweep number.  We use the location of the period in the filename to find the
    ;  		location of the sweep number.
    ;
    		sweep = fix(strmid(infile,strpos(infile,'.')-2, 2))
    
    ;
    ;  		Get number of events in the input file.
    ;  		Each level 1 event has a size of 177 bytes.
    ;		
    		l1msize = 241.0								; level 1 event message size
        	f = file_info(infile)						; get inout file info
        	nevents = long(f.size / l1msize)            ; get number of events in input file
    		
    ;
    ;  		Define the data arrays to hold the events, both input (l1) and output (l2).
    ; 		These arrays should be the same size so as to conserve the total number of
    ;		events in the processed data.
    ; 
    		l1data = replicate(l1event, nevents)		; initialize input data array
    		l2data = replicate(l2event, nevents)		; initialize output data array
    
    ;
    ;  		Read in all level 1 events (one event at a time) to populate the l1data array.
    ;
    		for i = 0L, nevents-1 do begin
        			readu, inunit, l1event				; read one event
    				l1data[i] = l1event					; add it to input array
    		endfor	
    ;
    ;   	End of this file.  All events have been read in.  
    ;		Close this file (calling free_lun closes the file and frees up 
    ;   	the file unit number).
    ;		
    		free_lun, inunit							; close input data file
    
    ;
    ;   	Print out summary data for the input file.
    ;
    		print
    		print
    		print, "Input File Summary                 "
    		print, "------------------"
    		print
    		print, "Input Filename      = ", infile
    		print, "Total no. of events = ", nevents
    		print, "Time of first event = ", l1data[0].evtime
    		print, "Time of last event  = ", l1data[nevents-1].evtime
    		print, "Total elapsed time  = ", l1data[nevents-1].evtime - l1data[0].evtime
    		print
    		print, "Sweep time of first event = ", l1data[0].swtime
    		print, "Sweep time of last event  = ", l1data[nevents-1].swtime
    		print, "Total elapsed time        = ", l1data[nevents-1].swtime - l1data[0].swtime
    		print 
    		print, "Events with intermodule flag  = ", n_elements(where(l1data.imflag eq 1))
    		print, "Number of C Events            = ", n_elements(where(l1data.evclass eq 1))
    		print, "Number of CC Events           = ", n_elements(where(l1data.evclass eq 2))
    		print, "Number of PC Events           = ", n_elements(where(l1data.evclass eq 3))
    		print
    		print, "Number of Events with 0 anode = ", n_elements(where(l1data.nanodes eq 0))
    		print, "Number of Events with 1 anode = ", n_elements(where(l1data.nanodes eq 1))
    		print, "Number of Events with 2 anode = ", n_elements(where(l1data.nanodes eq 2))
    		print, "Number of Events with 3 anode = ", n_elements(where(l1data.nanodes eq 3))
    		print, "Number of Events with 4 anode = ", n_elements(where(l1data.nanodes eq 4))
    		print, "Number of Events with 5 anode = ", n_elements(where(l1data.nanodes eq 5))
    		print, "Number of Events with 6 anode = ", n_elements(where(l1data.nanodes eq 6))
    		print, "Number of Events with 7 anode = ", n_elements(where(l1data.nanodes eq 7))
    		print, "Number of Events with 8 anode = ", n_elements(where(l1data.nanodes eq 8))
    		print, "Number of Events with >8 anodes = ", n_elements(where(l1data.nanodes gt 8))
    		print
    		print, "Number of Events with zero lt = ", n_elements(where(l1data.livetime eq 0.0))
    		print
    		print
    		print
    
    
    ;
    ;  		Define output filename.
    ;  		The filename format follows that of the level 1 data exept that 'Level1' is replaced
    ;  		by 'Level2'.
    ;
    		outfile = infile							; output filename same as input
    		strput, outfile, '2', 5						; except change 'Level1' to 'Level2'
    		strput, outfile, '8', 9						; except change 'V06' to 'V08'
    		openw, outunit, outfile, /GET_LUN			; open output file for writing
    		print, "Creating output Level 2 datafile : ", outfile
    
    ;
    ;  		Start loop that processes each input event.
    ;
    		for ievt = 0L, nevents-1 do begin
    
    ;
    ;
    ;*****************************************************************************************
    ;			For clarity, we pull out the components of the event message that are 
    ;    		used during the subsequent processing.  This is to make the coding a bit 
    ;			easier and the final product more readable.
    ;		
    			evtime   = l1data[ievt].evtime
    			modpos   = l1data[ievt].modpos
    			modser   = l1data[ievt].modser
    			evclass  = l1data[ievt].evclass
    			imflag   = l1data[ievt].imflag
    			nanodes  = l1data[ievt].nanodes
    			npls	 = l1data[ievt].npls
    			ncal	 = l1data[ievt].ncal
    			anodeid  = l1data[ievt].anodeid
    			anodetyp = l1data[ievt].anodetyp
    			anodepha = l1data[ievt].anodepha
    			anodenrg = l1data[ievt].anodenrg
    			anodesig = l1data[ievt].anodesig
    			lat      = l1data[ievt].lat
    			lon      = l1data[ievt].lon
    			depth    = l1data[ievt].depth
    			pntazi   = l1data[ievt].pntazi
    			pntzen   = l1data[ievt].pntzen
    			rtang    = l1data[ievt].rtang
    ;
    ;*****************************************************************************************
    ;			Initialize processed event parameters.
    ;			These values will remain until (and of) they are processed.
    ;			Incompletely processed (bad) events will retain these values.
    ;	
    			verno      = 8
    			qflag      = 0
    	  	    pa_mod     = -1
    	  	    pa_ser     = -1
      			pa_id      = -1
    			pa_nrg     = -999.0
    			pa_nrgsig  = -999.0
    	  	    sa_mod     = -1
    	  	    sa_ser     = -1
        		sa_id      = -1
      			sa_nrg     = -999.0
      			sa_nrgsig  = -999.0
    			totnrg     = -999.0 
    			totnrgsig  = -999.0                  
    			compang    = -999.0
    			compangsig = -999.0
       			evtype     = -1
    			sctang     = -999.0
    			pvang      = -999.0
    			ppvang     = -999.0
    			hrang      = -999.0
    			parang     = -999.0
    			posang     = -999.0
    			
    ;
    ;*****************************************************************************************
    ;			Increment event counters for each event class based on number of anodes
    ;
    			if (evclass eq 1) then c_events[nanodes]  = c_events[nanodes]  + 1
    			if (evclass eq 2) then cc_events[nanodes] = cc_events[nanodes] + 1
    			if (evclass eq 3) then pc_events[nanodes] = pc_events[nanodes] + 1
    ;
    ;*****************************************************************************************
    ;			This section performs various checks on the event, rejecting those events
    ;			that don't pass certain criteria.
    ;
    ;			Here we need to handle the case where the number of anodes is recorded as 
    ;			something greater than 8 or something less than or equal to zero. Such 
    ;			events shouldn't exist, so we will assume that such events are bad.
    ;
    			if (nanodes gt 8) then goto, finish_event
    			if (nanodes le 0) then goto, finish_event
    ;
    ;			The number of anodes should be consistent with the number of non-zero
    ;			anode energies.	
    ;
      			if (n_elements(where(anodenrg ne 0.0)) ne nanodes) then goto, finish_event
    ;
    ;			For C events, there should only be one anode.
    ;
      			if ((evclass eq 1) and (nanodes ne 1)) then goto, finish_event
    ;
    ;			For CC events there should be at least two anodes and none of them 
    ;			should be plastics.
    ;
      			if ((evclass eq 2) and (nanodes lt 2)) then goto, finish_event
      			if ((evclass eq 2) and (npls ne 0))    then goto, finish_event
    ;
    ;			For PC events, there should be at least two anodes and there should be 
    ;			at least one plastic and one calorimeter.
    ;
      			if ((evclass eq 3) and (nanodes lt 2)) 	then goto, finish_event
      			if ((evclass eq 3) and ((npls eq 0) or (ncal eq 0))) then goto, finish_event
      			
    ;
    ;*****************************************************************************************
    ;			Check to see if any of the triggered anodes has an energy that is below the
    ;			hardware lower limits. (Bad anodes have a lower limit set to 9999.)
    ;			If that is the case, then set the quality flag value to 1 and finish the 
    ;  			processing of this event.
    ;
    			for ia = 0,nanodes-1 do begin
    				if anodenrg[ia] lt hdw_lolims[modpos,anodeid[ia]] then begin
    					qflag = 1
    					goto, finish_event
    				endif
    			endfor
    ;
    ;*****************************************************************************************
    ;			Check to see if any of the triggered anodes has an energy that is above the 
    ;			established hardware upper limit (to stay away from overflow). If that is the
    ;			case, then set the quality flag value to 2 and finish the processing of this
    ; 			event.
    ;
    			for ia = 0,nanodes-1 do begin
    				if anodenrg[ia] ge hdw_uplims[modpos,anodeid[ia]] then begin
    					qflag = 2
    					goto, finish_event
    				endif
    			endfor
    ;
    ;*****************************************************************************************
    ;			HERE WE PROCESS INTERMODULE EVENTS.
    ;		 
    ;  			A valid inter-module (two module) event is one where there are two consecutive 
    ;			events which both have the intermodule flag set and are separated by less 
    ;           than 140 microsecs in time.
    ;
    			if (ievt eq nevents-1) then goto, finish_event
    
    			if (l1data[ievt].imflag eq 1) and (l1data[ievt+1].imflag eq 1) and $
    			   ((l1data[ievt+1].evtime - l1data[ievt].evtime) lt 0.000140D) then begin
    		
    					;  THIS IS WHERE WE PROCESS INTERMODULE EVENTS
    					;  FOR A VALID IM EVENT, WE TREAT THESE AS ONE SINGLE EVENT.
    					;  FOR EVENTS THAT HAVE THE IMFLAG SET BUT ARE ORPHANED, THESE
    					;  EVENTS ARE TREATED AS SINGLE MODULE EVENTS.
    					
    					ievt = ievt + 1        ; we have used two input events 
    
    	      			sa_mod     = -1
    	      			sa_ser     = -1
        	  			sa_id      = -1
          				sa_nrg     = -999.0
          				sa_nrgsig  = -999.0
          				totnrg     = -999.0  
          				totnrgsig  = -999.0                 
          				compang    = -999.0
          				compangsig = -999.0
    	      			evtype     = -1
    					sctang     = -999.0
    					pvang      = -999.0
    					ppvang     = -999.0
    					hrang      = -999.0
    					parang     = -999.0
    					posang     = -999.0
    
    			endif 
    
    ;
    ;*****************************************************************************************
    ;			HERE WE PROCESS C EVENTS WITH ONE ANODE.
    ;           Processing here is straightforward, since we have only one anode.
    ; 		
    			if evclass eq 1 then begin		
    				pa_mod    = modpos
    				pa_ser    = modser
    				pa_id     = anodeid(0)			; primary anode id is first in list
          			pa_nrg 	  = anodenrg(0)			; primary anode energy is first in list
          			pa_nrgsig = anodesig(0)
           			totnrg    = pa_nrg              ; 
           			totnrgsig = pa_nrgsig  		
           			qflag     = 10
           		endif
    
    ;
    ;*****************************************************************************************
    ;			HERE WE PROCESS CC EVENTS WITH TWO ANODES.
    ;           In this case, we want to determine if this event is consistent with a 
    ;           Compton scattered photon, so we must check the choice of primary and 
    ;           secondary anodes to see if the event is kinematically consistent with 
    ;           Compton scattering.  If it is consistent, then the azimuthal scatter 
    ;           angle contains useful information.  If it is not consistent, then this 
    ;           event does not contain useful information and should not be used in 
    ;           polarization analysis.
    ;
    ;	PROCESSING HERE SHOULD START WITH A CHECK TO SEE IF THE TWO ANODE SIGNALS ARE 
    ;	CONSISTENT WITH A SINGLE C EVENT AND CROSSTALK.  IN THIS CASE WE WOULD START BY 
    ;	DETERMINING THE DISTANCE BETWEEN THE TWO ANODES. IF THEY ARE ADJACENT THEN WE MUST 
    ;	CHECK FOR CROSS-TALK POSSIBILITY.  CHECKING FOR CROSSTALK STARTS WITH IDENTIFYING 
    ;	THE ANODE WITH THE LARGEST ENERGY DEPOSIT.
    ; 		
    			if evclass eq 2 and nanodes eq 2 then begin
    ;
    			anode1 = anodeid[0]
    			anode2 = anodeid[1]
    ;			
    			if grp_anodesep(anode1,anode2) lt 1.0 then begin
    			
    			
    			endif			
    ;
    ; 				First assume that the anode with the smaller energy deposit is the 
    ; 				primary anode and we check for valid Compton kinematics.
    ;						    		
    				pa_mod    = modpos	
    				pa_ser    = modser			    
    			    pa_id     = anodeid(where(anodenrg[0:nanodes-1] eq min(anodenrg[0:nanodes-1])))
          			pa_nrg    = anodenrg((anodeid[0:nanodes-1] eq pa_id))
          			pa_nrgsig = anodesig((anodeid[0:nanodes-1] eq pa_id))
          			sa_mod    = modpos
          			sa_ser    = modser
          			sa_id     = anodeid(where(anodenrg[0:nanodes-1] eq max(anodenrg[0:nanodes-1])))
          			sa_nrg    = anodenrg((anodeid[0:nanodes-1] eq sa_id))
          			sa_nrgsig = anodesig((anodeid[0:nanodes-1] eq sa_id))
          			compang   = grp_compang(pa_nrg, sa_nrg)
     ;
     ;				If the kinematics are not valid, we try it again, but now assume
     ;     			that the larger energy anode is the primary anode.
     ; 
          			if (compang eq -999.0) then begin
          				pa_mod    = modpos
          				pa_ser    = modser
          				pa_id     = anodeid(where(anodenrg[0:nanodes-1] eq max(anodenrg[0:nanodes-1])))
          				pa_nrg    = anodenrg((anodeid[0:nanodes-1] eq pa_id))
          				pa_nrgsig = anodesig((anodeid[0:nanodes-1] eq pa_id))
          				sa_mod    = modpos
          				sa_ser    = modser
          				sa_id     = anodeid(where(anodenrg[0:nanodes-1] eq min(anodenrg[0:nanodes-1])))
          				sa_nrg    = anodenrg((anodeid[0:nanodes-1] eq sa_id))
          				sa_nrgsig = anodesig((anodeid[0:nanodes-1] eq sa_id))
          				compang   = grp_compang(pa_nrg, sa_nrg)
          			endif
    ;
    ;				If we have a good check on the kinematics at this point, then we 
    ; 				finish the event processing.
    ;
           			if (compang ge 0.0) and (compang le 360.0) then begin
    	      			totnrg    = pa_nrg + sa_nrg
    	      			totnrgsig = sqrt (pa_nrgsig^2 + sa_nrgsig^2)
          				evtype    = grp_cctype(pa_id, sa_id)
    					sctang    = grp_scatang(pa_mod,pa_id,sa_mod,sa_id)
    					qflag     = 10
    				endif
    ;
    			endif
    
    ;
    ;*****************************************************************************************
    ;			HERE WE PROCESS CC EVENTS WITH THREE ANODES.
    ; 			We want to check to see if this is consistent with a C event that is 
    ; 			exhibiting crosstalk in adjacent anodes.
    ;
    			if evclass eq 2 and nanodes eq 3 then begin
    ;
    ;				start out by assuming non-adjacent anodes
    ;			
    				evclass = 1
    ;
    ;               identify the index of the anode with the max energy
    ;				
    				imax = where(anodenrg eq max(anodenrg))
    ;
    ;               for the remaining anodes, check to see where they are located wrt the 
    ;               anode with maximum emnergy deposit.
    ;				
    				for ianode = 0, nanodes-1 do begin
    					if ianode ne imax then begin
    ;					
    ;						We can use grp_cctype to determine the relative placement of two
    ;						calorimeter anodes.
    ;							relpos = 1  -  non-adjacent
    ;							relpos = 2  -  corner-adjacent
    ;							relpos = 3  -  side-adjacent
    ;
    						relpos = grp_cctype(anodeid(imax[0]), anodeid(ianode))
    						if (relpos ne 3) or (anodenrg(ianode) gt 0.25*anodenrg(imax)) then evclass = -1
    					endif
    				endfor
    				if evclass eq 1 then begin
          				pa_mod    = modpos
          				pa_ser    = modser
    					pa_id	  = anodeid(imax)			
    					pa_nrg    = anodenrg(imax)
    					pa_nrgsig = anodesig(imax)	
           				totnrg    = pa_nrg     
           				totnrgsig = pa_nrgsig  	
           			endif	
    			endif
    ;
    ;*****************************************************************************************
    ;			HERE WE PROCESS CC EVENTS WITH MORE THAN THREE ANODES.
    ;           For a CC event with more than two anodes (CCC, CCCCC, etc.), this most 
    ;           likely will not contain any useful information. 
    ;
    ; 	HERE WE MUST DETERMINE THE NUMBER OF DISTINCT GROUPS.  IF MORE THAN TWO C GROUPS, 
    ;	THEN THE EVENT IS INDETERMINANT.  IF ONLY ONE OR TWO GROUPOS, WE MUST CHECK TO SEE 
    ; 	IF THIS COULD BE A CC EVENT WITH CROSSTALK.
    ; 		
    			if evclass eq 2 and nanodes gt 3 then goto, finish_event
    
    ;
    ;*****************************************************************************************
    ;*****************************************************************************************
    ;			PC EVENTS, Nplastic = 1, Ncal = 1
    ;
    ;           In this case, we assume that the plastic is the primary anode, but we 
    ;           must check that assumption based on kinematics.  If the event is not 
    ;           consistent with Compton kinematics, then we can also check to see if 
    ;           the event is consistent with the calorimeter being the primary event.
    ; 		
    			if evclass eq 3 and nanodes eq 2 then begin
    ;
    ;				Check to be sure that we have one plastic and one calorimeter.
    ;
    				if (npls ne 1) or (ncal ne 1) then continue
    				
    ; 				First assume that the plastic anode is the primary anode and check 
    ;               for valid Compton kinematics.
    ;				
    				pa_mod    = modpos	
    				pa_ser    = modser	    
    			    pa_id     = anodeid(where(grp_anodetype(anodeid[0:nanodes-1]) eq 1))
          			pa_nrg    = anodenrg(where(anodeid[0:nanodes-1] eq pa_id[0]))
          			pa_nrgsig = anodesig(where(anodeid[0:nanodes-1] eq pa_id[0]))
          			sa_mod    = modpos
          			sa_ser    = modser
          			sa_id     = anodeid(where(grp_anodetype(anodeid[0:nanodes-1]) eq 2))
          			sa_nrg    = anodenrg(where(anodeid[0:nanodes-1] eq sa_id[0]))
          			sa_nrgsig = anodesig(where(anodeid[0:nanodes-1] eq sa_id[0]))
          			compang   = grp_compang(pa_nrg, sa_nrg)
     ;
     ;				If the kinematics are not valid, we try it again, but now assume
     ;     			that the calorimeter anode is the primary anode.
     ;
          			if (compang eq -999.0) then begin
          				pa_mod    = modpos
          				pa_ser    = modser
          				pa_id     = anodeid(where(grp_anodetype(anodeid[0:nanodes-1]) eq 2))
          				pa_nrg    = anodenrg(where(anodeid[0:nanodes-1] eq pa_id[0]))
          				ps_nrgsig = anodesig(where(anodeid[0:nanodes-1] eq pa_id[0]))
          				sa_mod    = modpos
          				sa_ser    = modser
          				sa_id     = anodeid(where(grp_anodetype(anodeid[0:nanodes-1]) eq 1))
          				sa_nrg    = anodenrg(where(anodeid[0:nanodes-1] eq sa_id[0]))
          				sa_nrgsig = anodesig(where(anodeid[0:nanodes-1] eq sa_id[0]))
          				compang   = grp_compang(pa_nrg, sa_nrg)
          			endif
          			
    ;
    ;				If we have a good check on the kinematics at this point, then we 
    ; 				finish the event processing.
    ;
           			if (compang ge 0.0) and (compang le 360.0) then begin
    	      			totnrg    = pa_nrg + sa_nrg
    	      			totnrgsig = sqrt (pa_nrgsig^2 + sa_nrgsig^2)
          				evtype    = grp_pctype(pa_id, sa_id)
    					sctang    = grp_scatang(pa_mod,pa_id,sa_mod,sa_id)
    					qf        = 10
    ;
    ;					Need to define the evtype :
    ;					(1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)
    ;					If separation is > 1.0 cm then EVTYPE = 1
    ;					If separation is < 0.7 cm then EVTYPE = 2
    ;					If separation is < 1.0 cm and > 0.7 cm then EVTYPE = 3
    ;
    ;					Side adjacent anodes have a separation of 0.608 cm.
    ;					Corner adjacent anodes have a separation of 0.859842 cm.	
    ;
    					asep = grp_anodesep(pa_id, sa_id)
    					if  asep gt 1.0 then evtype = 1
    					if  asep lt 0.7 then evtype = 2
    					if (asep ge 0.7 and asep le 1.0) then evtype = 3
    				endif
    
    			endif
    
    ;
    ;*****************************************************************************************
    ;*****************************************************************************************
    ;			PC EVENTS, Nplastic = 1, Ncal = 2
    ;
    ; 		
    			if (evclass eq 3) and (npls eq 1) and (ncal eq 2) then begin
    			
    			
    ; 				get plastic anode id
    				pid  = anodeid(where(grp_anodetype(anodeid[0:nanodes-1]) eq 1))
    				pnrg = anodenrg(where(grp_anodetype(anodeid[0:nanodes-1]) eq 1))
    				psig = anodesig(where(grp_anodetype(anodeid[0:nanodes-1]) eq 1))
    
    
    ; 				get calorimeter anode ids (two in this case)
    				cids  = anodeid(where(grp_anodetype(anodeid[0:nanodes-1]) eq 2))
    				cnrgs = anodenrg(where(grp_anodetype(anodeid[0:nanodes-1]) eq 2))
    				csigs = anodesig(where(grp_anodetype(anodeid[0:nanodes-1]) eq 2))
    
    				
    ; 				get anodeid of calriometer anodes with largest energy deposit
    				cmaxnrg = max(cnrgs)
    				cmaxid  = anodeid(where(anodenrg[0:nanodes-1] eq cmaxnrg))
    				cmaxsig = anodesig(where(anodenrg[0:nanodes-1] eq cmaxnrg))
    				
    ; 				find separation between the two calorimeter anodes
    				csep = fltarr(ncal)
    				for ia = 0, ncal-1 do begin
    					csep[ia] = grp_anodesep(cmaxid, cids[ia])
    				endfor
    
    ; 				If the two calorimeter anodes are non-adjacent (> 1.0 cm), 
    ; 				then we can't reliably determine an azimuthal scatter angle.  
    ;				So reject this event. (Leave qf = 0.)
    				if (max(csep) gt 1.0) then continue
    
    
    ; 				If the two calorimeter anodes are either side-adjacent or corner-adjacent, 
    ;				then let's assume that the anode with the largest energy deposit is the 
    ;				interaction site.
    ;
    ; 				First assume that the plastic anode is the primary anode and check 
    ;               for valid Compton kinematics.
    ;
    				pa_mod    = modpos	
    				pa_ser    = modser	    
    			    pa_id     = pid
          			pa_nrg    = pnrg
          			pa_nrgsig = psig
          			sa_mod    = modpos
          			sa_ser    = modser
          			sa_id     = cmaxid
          			sa_nrg    = cmaxnrg
          			sa_nrgsig = cmaxsig
          			compang   = grp_compang(pa_nrg, sa_nrg)
    	
     ;
     ;				If the kinematics are not valid, we try it again, but now assume
     ;     			that the calorimeter anode is the primary anode.
     ;
          			if (compang eq -999.0) then begin
          				pa_mod    = modpos
          				pa_ser    = modser
          				pa_id     = cmaxid
          				pa_nrg    = cmaxnrg
          				ps_nrgsig = cmaxsig
          				sa_mod    = modpos
          				sa_ser    = modser
          				sa_id     = pid
          				sa_nrg    = pnrg
          				sa_nrgsig = psig
          				compang   = grp_compang(pa_nrg, sa_nrg)
          			endif
          			
    ;
    ;				If we have a good check on the kinematics at this point, then we 
    ; 				finish the event processing.
    ;
           			if (compang ge 0.0) and (compang le 360.0) then begin
    	      			totnrg    = pa_nrg + sa_nrg
    	      			totnrgsig = sqrt (pa_nrgsig^2 + sa_nrgsig^2)
          				evtype    = grp_pctype(pa_id, sa_id)
    					sctang    = grp_scatang(pa_mod,pa_id,sa_mod,sa_id)
    					qf        = 10
    ;
    ;					Need to define the evtype :
    ;					(1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)
    ;					If separation is > 1.0 cm then EVTYPE = 1
    ;					If separation is < 0.7 cm then EVTYPE = 2
    ;					If separation is < 1.0 cm and > 0.7 cm then EVTYPE = 3
    ;
    ;					Side adjacent anodes have a separation of 0.608 cm.
    ;					Corner adjacent anodes have a separation of 0.859842 cm.	
    ;
    					asep = grp_anodesep(pa_id, sa_id)
    					if  asep gt 1.0 then evtype = 1
    					if  asep lt 0.7 then evtype = 2
    					if (asep ge 0.7 and asep le 1.0) then evtype = 3
    				endif
    
    			
    
    			
    			endif
    
    
    
    ;
    ;*****************************************************************************************
    ;*****************************************************************************************
    ;			PC EVENTS, Nplastic = 1, Ncal = 3
    ;
    ; 		
    			if (evclass eq 3) and (npls eq 1) and (ncal eq 3) then begin
    			
    			
    ; 				get plastic anode id
    				pid  = anodeid(where(grp_anodetype(anodeid[0:nanodes-1]) eq 1))
    				pnrg = anodenrg(where(grp_anodetype(anodeid[0:nanodes-1]) eq 1))
    				psig = anodesig(where(grp_anodetype(anodeid[0:nanodes-1]) eq 1))
    
    
    ; 				get calorimeter anode ids (three in this case)
    				cids  = anodeid(where(grp_anodetype(anodeid[0:nanodes-1]) eq 2))
    				cnrgs = anodenrg(where(grp_anodetype(anodeid[0:nanodes-1]) eq 2))
    				csigs = anodesig(where(grp_anodetype(anodeid[0:nanodes-1]) eq 2))
    
    				
    ; 				get anodeid of calorimeter anodes with largest energy deposit
    				cmaxnrg = max(cnrgs)
    				cmaxid  = anodeid(where(anodenrg[0:nanodes-1] eq cmaxnrg))
    				cmaxsig = anodesig(where(anodenrg[0:nanodes-1] eq cmaxnrg))
    				
    ; 				find separation between the three calorimeter anodes, as measured from
    ;				the anode with the highest energy.
    				csep = fltarr(ncal)
    				for ia = 0, ncal-1 do begin
    					csep[ia] = grp_anodesep(cmaxid, cids[ia])
    				endfor
    
    ; 				If at least one of the calorimeter anodes is far removed (> 1.0 cm)  
    ;				from the caloirimeter anode with the highest energy, 
    ; 				then we can't reliably determine an azimuthal scatter angle.  
    ;				So reject this event. (Leave qf = 0.)
    				if (max(csep) gt 1.0) then continue
    
    
    ; 				If the remaining calorimeter anodes are either side-adjacent or 
    ;				corner-adjacent, then let's assume that the anode with the largest 
    ;				energy deposit is the interaction site.
    ;
    ; 				First assume that the plastic anode is the primary anode and check 
    ;               for valid Compton kinematics.
    ;
    				pa_mod    = modpos	
    				pa_ser    = modser	    
    			    pa_id     = pid
          			pa_nrg    = pnrg
          			pa_nrgsig = psig
          			sa_mod    = modpos
          			sa_ser    = modser
          			sa_id     = cmaxid
          			sa_nrg    = cmaxnrg
          			sa_nrgsig = cmaxsig
          			compang   = grp_compang(pa_nrg, sa_nrg)
    	
     ;
     ;				If the kinematics are not valid, we try it again, but now assume
     ;     			that the calorimeter anode is the primary anode.
     ;
          			if (compang eq -999.0) then begin
          				pa_mod    = modpos
          				pa_ser    = modser
          				pa_id     = cmaxid
          				pa_nrg    = cmaxnrg
          				ps_nrgsig = cmaxsig
          				sa_mod    = modpos
          				sa_ser    = modser
          				sa_id     = pid
          				sa_nrg    = pnrg
          				sa_nrgsig = psig
          				compang   = grp_compang(pa_nrg, sa_nrg)
          			endif
          			
    ;
    ;				If we have a good check on the kinematics at this point, then we 
    ; 				finish the event processing.
    ;
           			if (compang ge 0.0) and (compang le 360.0) then begin
    	      			totnrg    = pa_nrg + sa_nrg
    	      			totnrgsig = sqrt (pa_nrgsig^2 + sa_nrgsig^2)
          				evtype    = grp_pctype(pa_id, sa_id)
    					sctang    = grp_scatang(pa_mod,pa_id,sa_mod,sa_id)
    					qf        = 10
    ;
    ;					Need to define the evtype :
    ;					(1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)
    ;					If separation is > 1.0 cm then EVTYPE = 1
    ;					If separation is < 0.7 cm then EVTYPE = 2
    ;					If separation is < 1.0 cm and > 0.7 cm then EVTYPE = 3
    ;
    ;					Side adjacent anodes have a separation of 0.608 cm.
    ;					Corner adjacent anodes have a separation of 0.859842 cm.	
    ;
    					asep = grp_anodesep(pa_id, sa_id)
    					if  asep gt 1.0 then evtype = 1
    					if  asep lt 0.7 then evtype = 2
    					if (asep ge 0.7 and asep le 1.0) then evtype = 3
    				endif
    
    			
    
    			
    			endif
    ;
    ;*****************************************************************************************
    
    FINISH_EVENT: 
    ;
    ;
    ;
    ;*****************************************************************************************
    ;			Get Julian Date.
    ;           The beginning of the week (Sep 18, 2011 at 0h UT) is JD 2455822.5.				
    ;
    			jd = 2455822.5D + (evtime)/(86400.0D) 
    ;
    ;			Truncated Julian Date
    ;
    			tjd = jd - double(2440000.5)
    ;
    ;*****************************************************************************************
    ;  			The following fetches the source target id for the given time, based on the 
    ;  			flight history.   
    ;					1 - Crab
    ;					2 - Sun
    ;					3 - Sun
    ;					4 - Cyg X-1
    ;					5 - not used
    ;					6 - Blank 2
    ;					7 - Blank 3
    ;					8 - transition (no specific pointing)
    ;
     			source = GRP_SourceID(evtime)  
    ;
    ;  			The RA and Dec of the target is based on the target number ('source'):
    ;
     			if source eq 1 then begin  						; CRAB
      				ra  = 83.6332083D
      				dec = 22.0144722D
     			endif   
     ;
     			if source eq 2 or source eq 3 then begin      	; SUN
    ;				This routine is from the IDL astronomy library.  The apparenet RA and DEC 
    ;               are returned in units of degrees.  The Epoch of the solar coordinates 
    ;               corresponds to the given Julian Date. 
     				SUNPOS, jd, RA, dec                        
     			endif
     ;			
     			if source eq 4 then begin 						; CYG X-1
      				ra  = 299.590316D
      				dec = 35.2016042D
     			endif
     ;
     			if source eq 6 then begin						; Blank 2
      				ra  = 265.95D
      				dec = 47.0D
     			endif
    ;
     			if source eq 7 then begin						; Blank 3
      				ra  = 54.26D
      				dec = 22.245D
     			endif
    ;
    			if (source ge 1) and (source le 7) then begin
    ;					Get azimuth and zenith of target source.
    ;					Convert from equatorial coordinates to local horizon coordinates using
    ;          			the EQ2HOR routine from the IDL astronomy library. All angles are in degs.
    ;  
      					EQ2HOR, ra, dec, jd, srcelev, srcazi, LAT=lat , LON=lon
      					srczen    = 90.0 - srcelev
    					airmass   = depth / cos(srczen*!dtor)
    ;				
    ;					This routine (from the astronomy IDL library) clculatres the 
    ;                   angular separation between two points on the sky. The value
    ;                   of the separation is returned in units of arcseconds.
    ;	
    					pntelev  = 90.0 - pntzen
    					gcirc, 2, srcazi, srcelev, pntazi, pntelev, srcoff
    					srcoff = srcoff / 3600.0       ; convert to degrees
    			endif
    ;
     			if source eq 8 then begin						; Miscellaneous
     				srcazi  = -999.0
     				srczen  = -999.0
     				airmass = -999.0
     				srcoff  = -999.0
     			endif 
    ;
    ;*****************************************************************************************
    ;	If the scatter angle is greater -999.0 then calculate the corresponding position
    ;   angle for the scatter vector.
    ;
    
    			if (sctang gt -999.0) then $
    			   grp_posang, sctang, rtang, 90.0-pntzen, pntazi, lat, pvang, ppvang, hrang, parang, posang
    
    ;
    ;*****************************************************************************************
    ;  Output event message (248 bytes) :
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
    ;			Transfer the data for this event to the output array.
    ;
    			l2data[ievt].VERNO    	= verno
    			l2data[ievt].QFLAG    	= qflag
    		 	l2data[ievt].SWEEPNO  	= l1data[ievt].sweepno
    		 	l2data[ievt].SWSTART  	= l1data[ievt].swstart
    		 	l2data[ievt].SWTIME   	= l1data[ievt].swtime
    		 	l2data[ievt].EVTIME   	= l1data[ievt].evtime
             	l2data[ievt].TJD      	= tjd		 
             	l2data[ievt].EVCLASS  	= evclass
    		 	l2data[ievt].IMFLAG   	= l1data[ievt].imflag
    		 	l2data[ievt].ACFLAG   	= 0
    		 	l2data[ievt].NANODES  	= l1data[ievt].nanodes
    		 	l2data[ievt].NPLS	  	= npls				
    		 	l2data[ievt].NCAL	 	= ncal				
             	l2data[ievt].EVTYPE   	= evtype	  
    		 	l2data[ievt].ANODEID  	= l1data[ievt].anodeid
    		 	l2data[ievt].ANODETYP 	= l1data[ievt].anodetyp
    		 	l2data[ievt].ANODENRG   = l1data[ievt].anodenrg
    		 	l2data[ievt].ANODESIG   = l1data[ievt].anodesig
    		 	l2data[ievt].PA_MOD     = pa_mod
    		 	l2data[ievt].PA_SER     = pa_ser
    		 	l2data[ievt].PA_ID      = pa_id
    		 	l2data[ievt].PA_NRG     = pa_nrg
    		 	l2data[ievt].PA_SIG  	= pa_nrgsig
    		 	l2data[ievt].SA_MOD     = sa_mod
    		 	l2data[ievt].SA_SER     = sa_ser
    		 	l2data[ievt].SA_ID      = sa_id	
    		 	l2data[ievt].SA_NRG     = sa_nrg
    		 	l2data[ievt].SA_SIG  	= sa_nrgsig
    		 	l2data[ievt].TOTNRG     = totnrg
    		 	l2data[ievt].TOTSIG  	= totnrgsig
    		 	l2data[ievt].COMPANG    = compang
    		 	l2data[ievt].COMPSIG 	= compangsig
    		 	l2data[ievt].LAT        = l1data[ievt].lat
    		 	l2data[ievt].LON        = l1data[ievt].lon
    		 	l2data[ievt].ALT        = l1data[ievt].alt	
    		 	l2data[ievt].DEPTH      = l1data[ievt].depth
    			l2data[ievt].SOURCE     = source
    		 	l2data[ievt].AIRMASS    = airmass
    		 	l2data[ievt].PNTAZI     = l1data[ievt].pntazi
    		 	l2data[ievt].PNTZEN     = l1data[ievt].pntzen
    		 	l2data[ievt].SRCAZI     = srcazi
    		 	l2data[ievt].SRCZEN     = srczen
    		 	l2data[ievt].SRCOFF     = srcoff
    		 	l2data[ievt].RTANG      = l1data[ievt].rtang
             	l2data[ievt].RTSTAT     = l1data[ievt].rtstat
             	l2data[ievt].SCTANG     = sctang
             	l2data[ievt].PVANG      = pvang
             	l2data[ievt].PPVANG     = ppvang
             	l2data[ievt].HRANG     	= hrang
             	l2data[ievt].PARANG     = parang
             	l2data[ievt].POSANG     = posang	 
    			l2data[ievt].LIVETIME   = l1data[ievt].livetime
    			l2data[ievt].CORRECTLT  = l1data[ievt].correctlt
    
    ;
    ;       END OF LOOP THAT PROCESSES EACH EVENT
    ; 
    		endfor
    ;
    ;*****************************************************************************************
    ;
    ;  		Write out all level 2 events
    ;
    		writeu, outunit, l2data
    ;
    ;  End of this file.  Close this file (calling free_lun closes the file and frees up 
    ;  the file unit number).
    ;		
    		free_lun, outunit
    ;
    ;  END OF LOOP THAT PROCESSES EACH LEVEL 1 DATA FILE
    ; 
    		
    endfor
    
    ;
    ;*****************************************************************************************
    print
    print
    print, "Output File Summary                 "
    print, "------------------"
    print 
    print, "Output Filename      = ", outfile
    print
    print, "Number of C Events            = ", long(total(c_events))
    print, "             with 0 anodes    = ", c_events(0)
    print, "             with 1 anodes    = ", c_events(1)
    print, "             with 2 anodes    = ", c_events(2)
    print, "             with 3 anodes    = ", c_events(3)
    print, "             with 4 anodes    = ", c_events(4)
    print, "             with 5 anodes    = ", c_events(5)
    print, "             with 6 anodes    = ", c_events(6)
    print, "             with 7 anodes    = ", c_events(7)
    print, "             with 8 anodes    = ", c_events(8)
    print, "             with >8 anodes   = ", long(total(c_events(9:*)))
    print
    print, "Number of CC Events           = ", long(total(cc_events))
    print, "             with 0 anodes    = ", cc_events(0)
    print, "             with 1 anodes    = ", cc_events(1)
    print, "             with 2 anodes    = ", cc_events(2)
    print, "             with 3 anodes    = ", cc_events(3)
    print, "             with 4 anodes    = ", cc_events(4)
    print, "             with 5 anodes    = ", cc_events(5)
    print, "             with 6 anodes    = ", cc_events(6)
    print, "             with 7 anodes    = ", cc_events(7)
    print, "             with 8 anodes    = ", cc_events(8)
    print, "             with >8 anodes   = ", long(total(cc_events(9:*)))
    print
    print, "Number of PC Events           = ", long(total(pc_events))
    print, "             with 0 anodes    = ", pc_events(0)
    print, "             with 1 anodes    = ", pc_events(1)
    print, "             with 2 anodes    = ", pc_events(2)
    print, "             with 3 anodes    = ", pc_events(3)
    print, "             with 4 anodes    = ", pc_events(4)
    print, "             with 5 anodes    = ", pc_events(5)
    print, "             with 6 anodes    = ", pc_events(6)
    print, "             with 7 anodes    = ", pc_events(7)
    print, "             with 8 anodes    = ", pc_events(8)
    print, "             with >8 anodes   = ", long(total(pc_events(9:*)))
    print
    
    
    
    Stop
end 