pro GRP_evt_quicklook, fsearch_string, nfiles=nfiles, iverbose=iverbose, title=title

;****************************************************************************************
; Name:
;		GRP_EVT_QUICKLOOK 
;
; Purpose:
; The purpose of this routine is read a specified 'evt' file, generate some basic 
; diagnostic plots.
;
; Calling Sequence:
;
;
; Input Parameters:
;
;		fsearch_string - Provides a list of input gps datafiles. This uses regular 
;						 expressions to provide a list of files to be processed.
;
;		nfiles
;
;		iverbose
;
;		titke - a string that can be used foe defining output filenames.
;
; Input Data Files:
;
;		GPS files (format 'gps-*.dat') - onboard datafiles
;
;
; Outputs:
;
;		<title>_gps_quicklook.ps   			- plot file
;		<title>_gps_quicklook_hkd.txt		- housekeeping data file (space-del text)		
;		<title>_gps_quicklook_thr.txt		- threshold data file (space-del text)
;		<title>_gps_quicklook_pktstats.txt  - gps packet statistics (space-del text)
;
; Uses:
;
;		SWAP_ENDIAN
;		CGCOLOR 			(coyote library)
;		DECOMPOSEDCOLOR 	(coyote library)
;		AL_LEGEND			(astro library)
;		SETDEFAULTVALUE
;		CGPLOTS 			(coyote library)
;		SETDECOMPOSEDSTATE
;		SYMCAT 				(coyote library)
;		CGTEXT
;		CGDEFCHARSIZE 		(coyote library)
;		Runs under standard IDL
;
; Author and History:
;		M. McConnell - Initial Version - July, 2013
;		
;		S. Wasti     - June 16, 2015
;		             - Modified for newer flight, modules added.
;		             - Added few more comments and identation
;		             
;
;
;****************************************************************************************
   close, /all
  If keyword_set(iverbose) ne 1 then iverbose = 0

  If n_params() ne 1 then fsearch_string = 'EVT*.dat'

  Evtfiles = FILE_SEARCH(fsearch_string)  

  If keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)
  
  ;
  ;-Extract few info based on file name.
  ;
  file_year  = long(strmid(evtfiles[0:nfiles-1],3,4))
  file_month = long(strmid(evtfiles[0:nfiles-1],7,2))
  file_day   = long(strmid(evtfiles[0:nfiles-1],9,2))
  file_hrs   = long(strmid(evtfiles[0:nfiles-1],12,2))
  file_mins  = long(strmid(evtfiles[0:nfiles-1],14,2))
  file_secs  = long(strmid(evtfiles[0:nfiles-1],16,2))
  file_gps   = long(strmid(evtfiles[0:nfiles-1],19,6))

  file_jd    = julday(file_month, file_day, file_year, file_hrs, file_mins, file_secs)
  file_gpswk = fix((file_jd - julday(1,5,2014)) / 7) + 1774

  jdmin       = file_jd[0]
  jdmax       = julday(file_month[nfiles-1], file_day[nfiles-1], file_year[nfiles-1], file_hrs[nfiles-1], file_mins[nfiles-1]+20, file_secs[nfiles-1])
  
  gpsmin 		= file_gps[0]

  Nevts  = lonarr(nfiles)               ; array that tracks no. of events in each evt file
  Nhkd   = lonarr(nfiles)               ; array that tracks no. of hkd packets in each evt file

  fevtime = lonarr(nfiles)
  levtime = lonarr(nfiles)

  ;
  ; The module position numbers (module ids) for the modules installed for the 2014 flight. SW
  ;
  dmid = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]
  
  ; 
  ; List of anode ids (0-63) corresponding to CsI elements
  ; 
  csi_anodes = [0,1,2,3,4,5,6,7,8,15,16,23,24,31,32,39,40,47,48,55,56,57,58,59,60,61,62,63]
  
  ;
  ; List of anode ids (0-63) corresponding to plastic elements
  ;
  pls_anodes = [9,10,11,12,13,14,17,18,19,20,21,22,25,26,27,28,29,30,31, $
                34,35,36,37,38,41,42,43,44,45,46,49,50,51,52,53,54]
                
  ;
  ; An array that gives the scintillator type corresponding to a given anode id (0-63)
  ;
  anode_type = [2,2,2,2,2,2,2,2,  $
              2,1,1,1,1,1,1,2,  $
              2,1,1,1,1,1,1,2,  $
              2,1,1,1,1,1,1,2,  $
              2,1,1,1,1,1,1,2,  $
              2,1,1,1,1,1,1,2,  $
              2,1,1,1,1,1,1,2,  $
              2,2,2,2,2,2,2,2]

  
  thrdata   = bytarr(32,64)


  ;
  ;*****************************************************************************************
  ; Open output files and print the headlines
  ;
  
  ; Files opened are : Evt_Quicklook.ps
  ;                    Evt_Quicklook_pktstats
  ;                    Evt_Quicklook_hkd.txt
  ;                    Evt_Quicklook_thr.txt
  ;                    Evt_Quicklook_AnodeCts.txt
  
  If keyword_set(title) ne 1 then begin
  		  title=''
  			title1 = title+'evt_quicklook'
  			
  			cgPS_Open, title1+'.ps'

  			cgDisplay, 550, 800
  			cgLoadCT, 13
  			openw, 1, 'evt_quicklook_pktstats.txt'
  			printf, 1, 'File_No          Filename           Total_Pkts    Unused  C_Evts    CC_Evts   PC_Evts    Unused     Thrsh      HKD     Rates   Tot_Evts   Start_Time     Stop_Time    Delta_Time'
  			openw, 2, 'evt_quicklook_hkd.txt'
  			printf, 2, '    evt_Time      Mod_Id       HV      Temp     Trigs        PC        CC         C      PC_w/AC   CC_w/AC'
  			openw, 3, 'evt_quicklook_thr.txt'
  			printf, 3, ' Each line contains evt Time, Mod Pos No., Packet Seq No., followed by 64 thresholds values'
  			openw, 4, 'evt_quicklook_anodects.txt'
  			printf, 4, ' Matrix of total anode counts per module and anode.'
  			printf, 4, ' ANODE MOD00  MOD01  MOD02  MOD03  MOD04  MOD05  MOD06  MOD07  MOD08  MOD09  MOD10  MOD11  MOD12  MOD13  MOD14  MOD15  MOD16  MOD17  MOD18  MOD19  MOD 20  MOD21  MOD22 MOD23  MOD24  MOD25  MOD26  MOPD27  MOD28  MOD29  MOD30  MOD31'
  
  	Endif Else Begin
  			 title1=title+'_evt_quicklook'
        cgPS_Open, title1+'.ps'	
  			cgDisplay, 550, 800
  			cgLoadCT, 13
  			openw, 1, title+'_evt_quicklook_pktstats.txt'
  			printf, 1, 'File_No          Filename           Total_Pkts    Unused  C_Evts    CC_Evts   PC_Evts    Unused     Thrsh      HKD     Rates   Tot_Evts   Start_Time     Stop_Time    Delta_Time'
  			openw, 2, title+'_evt_quicklook_hkd.txt'
  			printf, 2, '    evt_Time      Mod_Id       HV      Temp     Trigs        PC        CC         C      PC_w/AC   CC_w/AC'
  			openw, 3, title+'_evt_quicklook_thr.txt'
  			printf, 3, ' Each line contains evt Time, Mod Pos No., Packet Seq No., followed by 64 thresholds values'
  			openw, 4, title+'_evt_quicklook_anodects.txt'
  			printf, 4, ' Matrix of total anode counts per module and anode.'
  			printf, 4, ' ANODE MOD00  MOD01  MOD02  MOD03  MOD04  MOD05  MOD06  MOD07  MOD08  MOD09  MOD10  MOD11  MOD12  MOD13  MOD14  MOD15  MOD16  MOD17  MOD18  MOD19  MOD 20  MOD21  MOD22 MOD23  MOD24  MOD25  MOD26  MOPD27  MOD28  MOD29  MOD30  MOD31'
  Endelse
  
  ;
  ; Deininig a symbol 
  ;
  A = FINDGEN(17) * (!PI*2/16.)
  USERSYM, COS(A), SIN(A), /FILL
  
  ;*****************************************************************************************
  ; Begin loop that goes through each evt file in the input list
  ;
  ;nfiles=1      ; temporary edit to limit processing to one file
  time_offset = 0.0
  hkdstart = 0

  ;
  ;-- For each file.
  ;
  For ifile = 0, nfiles-1 do begin
  	
  	filename = evtfiles[ifile]
  	
  	print
  	print, "=============================================="
  	print, ifile+1, format = '("File no. ",I3)'
  	print, filename, format = '("Filename = ",A34)'
   
  	openr, unit, filename, /GET_LUN           ; open input data file
  	data = READ_BINARY(unit)                  ; read in all of the data at once
 
    ;---- 
    ;-------- SAM EDIT ---------
    ;--- Addition ------
;    Temp_1 = StrPos(filename,'.dat',0) 
;    Temp_2 = StrPos(filename,'c',Temp_1-6)
;    Temp_3 = StrMid(filename,Temp_2+1,Temp_1-Temp_2-1)
;    If Temp_3 EQ '0091' Then File_flag = 1 Else File_flag = 0
;    If File_flag EQ 1 Then File_Flag_no = ifile
;    ;----
    ;---------
    ;---- 
     
     
    ;
    ; Each data packet is 32 bytes. Not all packets contain event info.
    ;
  	totpkt = n_elements(data) / 32            ; total number of packets in file
  
    ;
    ; The start time of the sweep is measured in secs from the start of the 
    ; current week.  This value is included as a 6-digit number in the filename.
    ;
  	If (ifile ge 1) then begin
  		  if (long(strmid(evtfiles[ifile],19,6)) - long(strmid(evtfiles[ifile-1],19,6))) lt 0.0 then time_offset = 604800.0
  	EndIf
  
  	swpt0 = long(strmid(evtfiles[ifile],19,6)) + time_offset ; sweep start time (secs)	
  
    ;
    ; There are 8 different types of data packets.  This array keeps track of the 
    ; total number of packets of each type for this file.
    ;
  	npackets = lonarr(8)     ; array to keep track of packet type totals
  	
  	
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
             
    ;
    ;  Define the data array to hold the events.
    ; 
    evdata = replicate(event, totpkt)
    	
    ;
    ;  Here we define the structure to hold the final housekeeping data.
    ;
    hkd = {  $
    	     TSEC1:0.0D, $
             TSEC2:0.0D, $
             TIME:0.0D, $
             GPSTIM:0.0D, $
             MCFLG:0, $
             MODID:0, $
             LIVTIM:0.0, $
             ACFLG:0, $
             HV:0U, $
             TEMP:0U, $
             TRIGGERS_TOTAL: 0U, $
             EVENTS_PC: 0U, $
             EVENTS_CC: 0U, $
             EVENTS_C: 0U, $
             EVENTS_PC_AC: 0U, $
             EVENTS_CC_AC: 0U $
             }
             
    ;
    ;  Define the data array to hold the events.
    ; 
   	hkdata = replicate(hkd, totpkt)
   	
    
  	nevts[ifile] = 0L				; initialize event counter for this file
  	ipkt  = 0L						  ; initialize packet counter for this file
  	nhkd[ifile] = 0L				; initialize khd packet counter for this file
  
  
  	For i = 1L, totpkt-1 do begin
    		ifirst = (i-1)*32      		; first byte for this packet
    		ilast  = ifirst+31      	; last byte for this packet
    		pkt = data(ifirst:ilast)	; this packet
        
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
        ptype = ishft(pkt(6) and '01110000'B, -4)
        
        nanode = pkt(6) and '00001111'B 	    
        
        ;
        ;		increment packet counter (based on packet type)
        ;
        npackets[ptype] = npackets[ptype]+1
    
        ;
        ;  		tsecs1 gives time in units of seconds
        ;  		tsecs2 gives time in units of 20 microsecs
        ; 
        tsecs1 = swap_endian(fix(pkt,0,1,type=12))     ; bytes 0-1
        tsecs2 = swap_endian(fix(pkt,2,1,type=12))     ; bytes 2-3
        
        ;
        ;		module coincidence flag ('1' = module coincidence)
        ;
        mcflag = pkt(4)								   ; byte 4
        
        ;
        ;		modnum is the module number (0-31)
        ;
        modnum = fix(pkt(5))                           ; byte 5
        
        ;
        ;		acflag is anti-coincidence flag ('1' = coincident event)
        ;
        acflag = ishft(pkt(6),-7) 					   ; byte 6, bit 7
        
        ;
        ;		module livetime (0-255)
        ;
        ltime = pkt(7)
        
        ;        
        ;       >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ;       Process event data.  (Only C, CC, and PC event data.)
        ;
        If (ptype ge 1 and ptype le 3) then begin
        
            ;
            ;  	nanode is the number of non-zero PHA values    ; byte 6, bits 0-3
            ;
            nanode = pkt(6) and '00001111'B
            datawd = intarr(8)
            anode  = intarr(8)
            pha    = intarr(8)
            
            ;
            ;           extract anode number and PHA value from each of eight 16-bit words
            ;		
            For j = 0,7 do begin
            				datawd[j] = swap_endian(fix(pkt,8+j*2,1,type=12))
            				anode[j]  = ishft(datawd[j] and '1111110000000000'B, -10)
            				pha[j]    = datawd[j] and '0000001111111111'B
            Endfor	
            
            ;
            ; 			packet id (event number)
            ;
            pcktid = swap_endian(fix(pkt,30,1,type=12))  
            
            ;
            ;           >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 	        
            If iverbose eq 1 then begin
                  typedef = ['unused','C type', 'CC type', 'PC Type', 'unused', 'Threshold', 'Housekeeping', 'Rates']  ;
          				print, pkt, format = '(32(Z2.2,x))'
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
          	EndIf
          
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
            
            For j = 0,min([nanode,8])-1 do 	EVENT.ATYPE[j] = anode_type[anode[j]]
            ;
            ;			Add event to the event array
            ;	
          			evdata[nevts[ifile]] = event
          			nevts[ifile] = nevts[ifile] + 1
          
       	Endif
       	
        ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ;
        ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ;	ptype = 5  -  Module Threshold Data
        ;
  	  	If (ptype eq 5) then begin
  	  	  
            ;
            ;  Sequence Number (0..3)    ; byte 6, bits 0-3
            ;
            seqno = pkt(6) and '00001111'B
            If (seqno eq 0) then thrdata[modnum,*] = 0
            If (seqno gt 3) then continue
            
            ;
            ;           extract threshold data from this packet (16 threshold values per packet)
            ;		
            For j = 8,23 do begin
                thrdata (modnum,(seqno*16)+(j-8))= pkt(j)
            Endfor	
  			
  			    printf, 3, swpt0 + tsecs1 + tsecs2*0.000020D, modnum, seqno, thrdata[modnum,*], $
                format = '(F16.6,"  ",I2,"  ",I1,64(" ",I2))'
  	  			  		
  	  	Endif
  	  	
        ;       >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ;
        ;
        ;       >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ;		ptype = 6  -  Module Housekeeping Data
        ;
  	  	If (ptype eq 6 and nanode eq 0) then begin
  
      			HKD.TSEC1 = tsecs1
      			HKD.TSEC2 = tsecs2
      			HKD.TIME = tsecs1 + tsecs2*0.000020D
      			HKD.GPSTIM = swpt0 + tsecs1 + tsecs2*0.000020D
      			HKD.MCFLG = mcflag
      			HKD.MODID = modnum
      			HKD.LIVTIM = ltime
      			HKD.ACFLG = acflag
      			HKD.HV 					      = swap_endian(uint(pkt,8,1))      ; bytes 8-9
      	  	;HKD.TEMP				      = (swap_endian(uint(pkt,10,1)) - 10000.0) / 100.0  ; bytes 10-11
      	  	;HKD.TEMP              = -(swap_endian(uint(pkt,10,1)) - 14038.0) / 101.78  ; bytes 10-11
      	  	HKD.TEMP              = (swap_endian(uint(pkt,10,1)) - 9983.4) / 100.68
      	  	HKD.TRIGGERS_TOTAL 		= swap_endian(uint(pkt,12,1))     ; bytes 12-13
      	  	HKD.EVENTS_PC   		  = swap_endian(uint(pkt,14,1))     ; bytes 14-15
      	  	HKD.EVENTS_CC   		  = swap_endian(uint(pkt,16,1))     ; bytes 16-17
      	  	HKD.EVENTS_C    		  = swap_endian(uint(pkt,18,1))     ; bytes 18-19
      	  	HKD.EVENTS_PC_AC   		= swap_endian(uint(pkt,20,1))     ; bytes 20-21
      	  	HKD.EVENTS_CC_AC    	= swap_endian(uint(pkt,22,1))     ; bytes 22-23
      
      			hkdata[nhkd[ifile]] = hkd
      			nhkd[ifile] = nhkd[ifile] + 1
            
      			printf, 2, format = '(1X,F12.4,9(2X,I8) )', $
      			hkd.gpstim, hkd.modid, hkd.hv, hkd.temp, hkd.triggers_total, hkd.events_pc, $
      			hkd.events_cc, hkd.events_c, hkd.events_pc_ac, hkd.events_cc_ac
  
  	  	EndIf
  
        ;   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ;
        ;
        ;   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ;		ptype = 7  -  Module Rates Data
        ;
  	  	If (ptype eq 7) then begin
  	  	Endif
  	  	
        ;       >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ;
        
        
        ;		Increment packet counter and exit loop if this is the last packet.
        ;
        ipkt = ipkt + 1
        If ipkt eq totpkt then break
        
        ;
        ;   End of this file.  Close this file (calling free_lun closes the file and frees up 
        ;   the file unit number) and go get next one.
        ;
        ;		
  	Endfor     ;i
  	free_lun, unit
              	
    ;
    ;
    print
    print
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
    print, "File Summary                 "
    print, "------------"
    print
    print, "Total no. of events = ", nevts[ifile]
    print, "Time of first event = ", evdata[0].gpstim
    print, "Time of last event  = ", evdata[nevts[ifile]-1].gpstim
    print, "Total elapsed time  = ", evdata[nevts[ifile]-1].gpstim - evdata[0].gpstim
    print
    print
    ;
    printf, 1, format = '(1X,I3,1X,A30,10(2X,I8),3(2X,F12.4) )', $
    	ifile+1, filename, totpkt, npackets[0], npackets[1], npackets[2], npackets[3], $
    	npackets[4], npackets[5], npackets[6], npackets[7], nevts[ifile], $
    	evdata[0].gpstim, evdata[nevts[ifile]-1].gpstim, evdata[nevts[ifile]-1].gpstim - evdata[0].gpstim

    ; 
    ; Combine event data from this gps file with accumulated event data
    ; 
    evdata = evdata[0:nevts[ifile]-1]
    fevtime[ifile] = evdata[0].gpstim
    levtime[ifile] = evdata[nevts[ifile]-1].gpstim

    If ifile eq 0 then evtall = evdata
    If ifile ne 0 then evtall = [evtall, evdata]

    ; 
    ; Combine hkd data from this gps file with accumulated hkd data
    ; (but only if threre is hkd data in this gps file)
    ; 
    If nhkd[ifile] gt 0 then begin
    	hkdata = hkdata[0:nhkd[ifile]-1]
    	If hkdstart eq 0 then hkdall = hkdata
    	If hkdstart ne 0 then hkdall = [hkdall, hkdata]
    	hkdstart = 1
    Endif

  Endfor ;ifile

  Totevts = n_elements(evtall)     ; total number of events
  print
  print, "==============================================="
  print
  print, "Accumulated Events                 "
  print, "------------------"
  print
  print, "Time of first event = ", evtall[0].gpstim
  print, "Time of last event  = ", evtall[totevts-1].gpstim
  print, "Total elapsed time  = ", evtall[totevts-1].gpstim - evtall[0].gpstim

  ;
  ;
  ;*****************************************************************************************
  ; Set up event filters. The filters are arrays that give a '1' for those elements that 
  ; correspond to the required condition.
  ;
  print
  print
  print, 'Generating event filters...'

  c_filter = evtall.evtype  eq 1							; C events
  cc_filter = evtall.evtype eq 2					      	; CC events
  pc_filter = evtall.evtype eq 3					        ; PC events

  mod_filter = ptrarr(32, /allocate_heap)
  
  For i = 0,31 do *mod_filter[i] = evtall.modid eq i

  time_filter = ptrarr(nfiles, /allocate_heap)

  For i = 0,nfiles-1 do *time_filter[i] = evtall.gpstim ge fevtime[i] and evtall.gpstim le levtime[i]
  
  ;
  ;
  ;*****************************************************************************************
  ; Accumulate total counts per module and anode.
  ;
  print, 'Accumulating module anode counts...'

  anode_cts = lonarr(32,64)

  For ievt = 0L,totevts-1 do begin
    	For ianode = 0,evtall[ievt].nanodes-1 do begin
    		If (ianode gt 7) then continue
    		anode_cts[evtall[ievt].modid,evtall[ievt].anode[ianode]] = anode_cts[evtall[ievt].modid,evtall[ievt].anode[ianode]] + 1
    	Endfor
  Endfor


  For ianode = 0,63 do begin
	    printf, 4, format = '(1X,I2,5X,32(2X,I7))', ianode, anode_cts[*,ianode]
  Endfor

  ;
  ;*****************************************************************************************
  ;
  print, 'Accumulating module anode counts per time...'

  t1 = evtall[0].gpstim
  t2 = evtall[totevts-1].gpstim
  nbin = 20
  deltat = (t2 - t1) / nbin

  tlower = fltarr(nbin)
  tupper = fltarr(nbin)

  For i = 0,nbin-1 do tlower(i) = t1 + deltat*i
  For i = 0,nbin-1 do tupper(i) = tlower(i) + deltat

  anode_cts_time = lonarr(nbin,32,64)
  
  For i = 0,nbin-1 do begin 
  ;
  	For ievt = 0L,totevts-1 do begin
  		  If (evtall[ievt].gpstim le tlower(i)) or (evtall[ievt].gpstim ge tupper(i)) then continue
        
        For ianode = 0,evtall[ievt].nanodes-1 do begin
  			       If (ianode gt 7) then continue
               anode_cts_time[i,evtall[ievt].modid,evtall[ievt].anode[ianode]] = anode_cts_time[i,evtall[ievt].modid,evtall[ievt].anode[ianode]] + 1
        Endfor
    Endfor
  Endfor

  ;
  ;=========================================================================================
  ;=========================================================================================
  ;=========================================================================================
  ; PAGE 1
  ;
  ; 
  ;*****************************************************************************************
  ; Plot count rate vs. time for each event type and the total.
  ; 
  print, 'Generating total event time history...'
 

  bps = 10    ; bins per sweep
  ;
  h_tot   = fltarr(bps, nfiles)
  h_pc    = fltarr(bps, nfiles)
  h_cc    = fltarr(bps, nfiles)
  h_c     = fltarr(bps, nfiles)
  h_times = fltarr(bps, nfiles)
  h_jd    = dblarr(bps, nfiles)

  ;nbin = 1024
  ;tbin   = (jdmax - jdmin) / nbin
  ;xtimes = jdmin + (findgen(nbin)+0.5)*tbin
  ;
  fdeltat = levtime - fevtime
  
  For ifile  = 0, nfiles-1 Do Begin
    	  
    	  
    	tbin   = fdeltat[ifile] / bps
    	tlower = fevtime[ifile] + findgen(bps)*tbin
    
      index = where(*time_filter[ifile], cts)
            If (N_elements(index) gt 0) then Temp_Var1 = value_locate(tlower, evtall[index].gpstim)
            If N_Elements(Temp_Var1) GT 1 Then Temp_Var = float(histogram(Temp_Var1)) / float(tbin)
            
            
            If (cts ne 0) and (N_Elements(Temp_Var1) GT 1)  then Begin
              For temp_ival=0, N_elements(Temp_Var)-1 Do begin
                h_tot[Temp_ival,ifile]   = Temp_Var[Temp_ival]
              Endfor
            Endif
       
      

      index = where(*time_filter[ifile]and pc_filter, cts)
              If (N_elements(index) gt 0) then Temp_Var1 = value_locate(tlower, evtall[index].gpstim)
              If N_Elements(Temp_Var1) GT 1 Then Temp_Var = float(histogram(Temp_Var1)) / float(tbin)
              If (cts ne 0) and (N_Elements(Temp_Var1) GT 1)  then Begin
                      For temp_ival=0, N_elements(Temp_Var)-1 Do begin
                              h_pc[Temp_ival,ifile]   = Temp_Var[Temp_ival]
                      Endfor
              Endif


      index = where(*time_filter[ifile]and cc_filter, cts) 
            If (N_elements(index) gt 0) then Temp_Var1 = value_locate(tlower, evtall[index].gpstim)
            If N_Elements(Temp_Var1) GT 1 Then Temp_Var = float(histogram(Temp_Var1)) / float(tbin)
            If (cts ne 0) and (N_Elements(Temp_Var1) GT 1)  then Begin
                For temp_ival=0, N_elements(Temp_Var)-1 Do begin
                h_cc[Temp_ival,ifile]   = Temp_Var[Temp_ival]
                Endfor
            Endif
        
      
      index = where(*time_filter[ifile]and c_filter, cts) 
            If (N_elements(index) gt 0) then Temp_Var1 = value_locate(tlower, evtall[index].gpstim)
            If N_Elements(Temp_Var1) GT 1 Then Temp_Var = float(histogram(Temp_Var1)) / float(tbin)
            If (cts ne 0) and (N_Elements(Temp_Var1) GT 1)  then Begin
              For temp_ival=0, N_elements(Temp_Var)-1 Do begin
                h_c[Temp_ival,ifile]   = Temp_Var[Temp_ival]
              Endfor
            Endif

    
    	h_times[*,ifile] = fevtime[ifile] + (findgen(bps)+0.5)*tbin
    	h_jd[*,ifile]    = jdmin + (h_times[*,ifile] - gpsmin) / 86400.0

  Endfor

  Date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I', '%M %D, %Y'])
  
  CgPlot, h_jd, h_tot, symsize = 0.5, $
			charsize = 1.0, $
			ytickformat='(I6)', $
      XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
      XTICKUNITS = ['Time', 'Day'], $
			xtitle = 'Time (hh:mm)', ytitle = 'Counts per sec', title = 'Total Count Rate', $
			XMINOR = 6, YMARGIN = [5,5], $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

  Oplot, h_jd, h_pc, color = cgColor('Red'), symsize = 0.5
  Oplot, h_jd, h_cc, color = cgColor('Blue'), symsize = 0.5
  Oplot, h_jd, h_c, color = cgColor('Green'), symsize = 0.5

  al_legend, ['All Events','PC Events','CC Events','C Events'], $
			psym=[8,8,8,8],colors=['black','red','blue','green'], charsize = 0.8 


  ;
  ;*****************************************************************************************
  ; Plot livetime vs. time
  ; 
  ;nbin = 1024
  ;deltat = evtall[totevts-1].gpstim - evtall[0].gpstim
  ;tbin   = deltat / nbin
  ;times = (findgen(nbin)+0.5)*tbin + evtall[0].gpstim
  
  xjd = jdmin + (evtall.gpstim - gpsmin) / 86400.0
  ;
  cgPlot, congrid(xjd,512), congrid(evtall.livtim, 512)/255.0, $
  			charsize = 1.0, $
  			ytickformat='(F3.1)', $
    			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   			XTICKUNITS = ['Time', 'Day'], $
  			xtitle = 'Time (hh:mm)', ytitle = 'Livetime (0-1)', title = 'Module Livetime (all modules)', $
  			yrange = [0.0, 1.1], $
     			XMINOR = 6, YMARGIN = [5,5], $
  			Position= cgLayout([1,2,2], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase
  
  xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
  xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'EVT Event Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE
  
  cgErase

  ;
  ;*****************************************************************************************
  ; Plot livetime vs time for each module values
  ;

  mcounts = fltarr(32)
  
  nplots = 1
  
  For igrp = 0, 3 do begin

    	Print, 'Generating livetime plots for module group ', igrp
    
    
    	firstpltflg = 0					; flag to indicate whether first module has plotted
    	fmod  = igrp * 8				; first module in group
    	
    	;
    	;
    	;
    	For imod = fmod, fmod+7 do begin
	
      	 mfilter = evtall.modid eq imod
      	 filter  = where (mfilter eq 1, count) 
      	 mcounts[imod] = count
          
	       If (mcounts[imod] ge 1) and (firstpltflg eq 0) then begin
            
            xtimes = jdmin + (evtall[where(evtall.modid eq imod)].gpstim - gpsmin) / 86400.0
            pcolors=['black','red','green','blue','orange','violet','magenta','cyan']
            
            Plot, congrid(xtimes,512), congrid(evtall[where(evtall.modid eq imod)].livtim, 512)/255.0, $
            color = cgColor(pcolors[0]), symsize = 1.0, $
            charsize = 1.0, yrange = [0.0,1.1], $
            ytickformat='(F3.1)', $
            XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
            XTICKUNITS = ['Time', 'Day'], $
            xtitle = 'Time (hh:mm)', ytitle = 'Module Livetime', $
            title = 'Module Group ' + strtrim(string(igrp),1) + ' - Livetime', $
            Position= cgLayout([1,2,nplots], xgap=0, ygap=12, oxmargin = [2,2], oymargin = [6,5]), /noerase
            
			      firstpltflg = 1
         Endif
	
		     If (mcounts[imod] ge 1) and (firstpltflg eq 1) then begin	
            oplot, congrid(xtimes,512), congrid(evtall[where(evtall.modid eq imod)].livtim, 512)/255.0, color = cgColor(pcolors[imod-fmod]), symsize = 1.0
         Endif

	     Endfor

	     al_legend, ['Mod '+ strtrim(string(fmod),1), $
      			'Mod '+ strtrim(string(fmod+1),1), $
      			'Mod '+ strtrim(string(fmod+2),1), $
      			'Mod '+ strtrim(string(fmod+3),1), $
      			'Mod '+ strtrim(string(fmod+4),1), $
      			'Mod '+ strtrim(string(fmod+5),1), $
      			'Mod '+ strtrim(string(fmod+6),1), $
      			'Mod '+ strtrim(string(fmod+7),1)], $
      			psym=[8,8,8,8,8,8,8,8], $
      			colors=['black','red','green','blue','orange','violet','magenta','cyan'], charsize = 0.6
      			
       nplots = nplots + 1 
       
       If nplots eq 3 then begin
				  xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
          xyouts, !D.X_SIZE/2, !D.Y_SIZE-2, 'EVT Module Livetime Data : '+title, alignment = 0.5, charsize = 1.6, charthick=5.0, /DEVICE
          cgErase
          nplots = 1
       Endif			
			
	Endfor

  ;=========================================================================================
  ;=========================================================================================
  ;=========================================================================================
  ; PAGE 2
  ;
  ;*****************************************************************************************
  ;
  Print, 'Generating triggered anode stats...'
  cgPlot, histogram(evtall.nanodes), psym=10, xrange=[0,10], $
			charsize = 1.0, $
			xtickformat='(I2)', ytickformat='(E9.2)', $
			xtitle = 'Number of Triggered Anodes', ytitle = 'Number of Events', $
			title = 'Triggered Anodes per Event', $
			Position= cgLayout([1,2,1], xgap=0, ygap=12, oxmargin = [5,5], oymargin = [10,5]), /noerase

      xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
      xyouts, !D.X_SIZE/2, !D.Y_SIZE-1, 'EVT Event Data : '+title, alignment = 0.5, charsize = 1.8, charthick=5.0, /DEVICE

  cgErase
  
  ;
  ;=========================================================================================
  ;=========================================================================================
  ;=========================================================================================
  ; PAGE 3
  ;
  ;
  ;*****************************************************************************************
  ; For each module, plot count rate vs. time for each event type and the total.
  ; 
  ;pos = cgLayout([2,4], xgap = 0, ygap = 0)
  ;
  nbin = 1024
  deltat = evtall[totevts-1].gpstim - evtall[0].gpstim
  tbin   = deltat / nbin
  times = (findgen(nbin)+0.5)*tbin + evtall[0].gpstim
  nm = n_elements(dmid)									; number of modules
  
  nplots = 1				; counts number of plots on each page
  
  For i = 0, 31 do begin
    	print, 'Generating time history for Module ', i
    	count = total(*mod_filter[i])
      ;
      ;	If no events in this module, go to next module
      ;
     	If count eq 0 then continue				
	
	    For ifile  = 0, nfiles-1 do begin
          
          
          tbin   = fdeltat[ifile] / bps
          tlower = fevtime[ifile] + findgen(bps)*tbin
		
		      
;	        If (file_flag Eq 1) then begin
;               	         
;	        EndIf Else Begin
	        index = where(*time_filter[ifile] and *mod_filter[i], cts)
              If (N_elements(index) gt 0) then Temp_Var1 = value_locate(tlower, evtall[index].gpstim)
              If N_Elements(Temp_Var1) GT 1 Then Temp_Var = float(histogram(Temp_Var1, min=0, max=9, NBins= 10)) / float(tbin)
          If (cts ne 0) and (N_Elements(Temp_Var1) GT 1)  then h_tot[*,ifile]   = Temp_Var

	        index = where(*time_filter[ifile] and *mod_filter[i] and pc_filter, cts)
	            If (N_elements(index) gt 0) then Temp_Var1 = value_locate(tlower, evtall[index].gpstim)
              If N_Elements(Temp_Var1) GT 1 Then Temp_Var = float(histogram(Temp_Var1, min=0, max=9, NBins= 10)) / float(tbin)
          If (cts ne 0) and (N_Elements(Temp_Var1) GT 1)  then h_pc[*,ifile]    = Temp_Var
          
          index = where(*time_filter[ifile] and *mod_filter[i] and cc_filter, cts)
              If (N_elements(index) gt 0) then Temp_Var1 = value_locate(tlower, evtall[index].gpstim)
              If N_Elements(Temp_Var1) GT 1 Then Temp_Var = float(histogram(Temp_Var1, min=0, max=9)) / float(tbin)
	        If (cts ne 0) and (N_Elements(Temp_Var1) GT 1) then h_cc[*,ifile]    = Temp_Var
         
          index = where(*time_filter[ifile] and *mod_filter[i] and c_filter, cts)
              If (N_elements(index) gt 0) then Temp_Var1 = value_locate(tlower, evtall[index].gpstim)
              If N_Elements(Temp_Var1) GT 1 Then Temp_Var = float(histogram(Temp_Var1, min=0, max=9)) / float(tbin)
	        If (cts ne 0) and (N_Elements(Temp_Var1) GT 1) then h_c[*,ifile]     = Temp_Var

;          EndElse
          
		     
	
		      
		      h_times[*,ifile] = fevtime[ifile] + (findgen(bps)+0.5)*tbin
          h_jd[*,ifile]    = jdmin + (h_times[*,ifile] - gpsmin) / 86400.0
      Endfor
	
      ;	print, nplots
      cgPlot, h_jd, h_tot, symsize = 0.5, $
			charsize = 0.7, $ 
			ytickformat='(I6)', $
			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
      XTICKUNITS = ['Time', 'Day'], $
			xtitle = 'Time (hh:mm)', ytitle = 'Counts per sec',  $
			title = 'Count Rates - Module ' + strtrim(string(i),1), $
			Position= cgLayout([2,4,nplots], xgap=6, ygap=6, oxmargin = [1,1], oymargin = [10,5]), /noerase

	    cgoplot, h_jd, h_pc, color = cgColor('Red'), symsize = 0.5
      cgoplot, h_jd, h_cc, color = cgColor('Blue'), symsize = 0.5
      cgoplot, h_jd, h_c, color = cgColor('Green'), symsize = 0.5

	    al_legend, ['All Events','PC Events','CC Events','C Events'], $
			psym=[8,8,8,8],colors=['black','red','blue','green'], charsize = 0.6 

	    nplots = nplots + 1 
      If nplots eq 9 then begin
          xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
          xyouts, !D.X_SIZE/2, !D.Y_SIZE-2, 'EVT Event Data : '+title, alignment = 0.5, charsize = 1.6, charthick=5.0, /DEVICE
          cgErase
          nplots = 1
      Endif			

  EndFor
  CgErase

  ;
  ;=========================================================================================
  ;=========================================================================================
  ;=========================================================================================
  ;*****************************************************************************************
  ; 
  ;
  
  ;for i = 0, 31 do begin
  ;	mfilter = evtall.modid eq i
  ;	filter = where (mfilter eq 1, count)
  ;	if count eq 0 then continue
  ;	plot, histogram(evtall[filter].pha, min=1), psym=10, xrange = [0,256], $
  ;			charsize = 1.3, $
  ;			xtickformat='(I4)', ytickformat='(I6)', $
  ;			xtitle = 'Pulseheight Channel', ytitle = 'Counts', $
  ;			title = 'Pulseheight Spectrum : Module ' + strtrim(string(i),1)
  ;endfor
  
  
  ;
  ;
  ;=========================================================================================
  ;=========================================================================================
  ;=========================================================================================
  ; 
  ;

  pos = cgLayout([3,3], Aspect = 1.0, oxmargin = [1,1], oymargin = [0,0], xgap = 3, ygap = 0)
  nplots = 0
  
  For i = 0,31 do begin 
    	
    	Print, 'Generating anode map for module ', i
    	m = congrid(reform(anode_cts[i,*],8,8), 360, 360)
    	
    	if total(m) eq 0.0 then continue
    	
    	ptitle = 'Anode Counts - Module P1' + string(i, format='(I02)')
    	p = pos[*,nplots]
    
    	cgImage, reverse(m,2), NoErase=i NE 0, Position = p, Title = ptitle, /Axes, /Keep_Aspect, xrange = [-0.5,7.5], $
    				yrange = [-0.5,7.5], charsize = 0.5, /Scale
    
    	cgColorbar, minrange = 0.0, maxrange = max(m), Position = [p[0],p[1]-0.03,p[2],p[1]-0.02], charsize = 0.5, format = '(I6)'
    	
    	nplots = nplots + 1
    	If (nplots eq 9) then begin
      		xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
      		xyouts, !D.X_SIZE/2, !D.Y_SIZE-2, 'EVT Event Data : '+title, alignment = 0.5, charsize = 1.6, charthick=5.0, /DEVICE
      		nplots = 0
      		erase
    	EndIf

  EndFor					

  xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
  xyouts, !D.X_SIZE/2, !D.Y_SIZE-2, 'EVT Event Data : '+title, alignment = 0.5, charsize = 1.6, charthick=5.0, /DEVICE
  
  cgErase

  ;
  ;
  ;=========================================================================================
  ;=========================================================================================
  ;=========================================================================================
  ; 
  ;
  
  pos = cgLayout([3,3], Aspect = 1.0, oxmargin = [0,0], oymargin = [0,0], xgap = 0, ygap = 0)
  nplots = 0

  For i = 0,31 do begin 
    	
    	print, 'Generating anode cts vs time for module ', i
    	m = congrid(reform(anode_cts_time[*,i,*],20,64), 400, 640)
    	
    	If total(m) eq 0.0 then continue
    	
    	ptitle = 'Anode Cnts vs Time Mod P1' + string(i, format='(I02)')
    	p = pos[*,nplots]
    
    	cgImage, m, NoErase=i NE 0, Position = p, Title = ptitle, /Axes, /Keep_Aspect,  $
    				yrange = [-0.5,63.5], charsize = 0.5, /Scale
    
    	cgColorbar, minrange = 0.0, maxrange = max(m), Position = [p[0],p[1]-0.03,p[2],p[1]-0.02], charsize = 0.5, format = '(I6)'
    	
    	nplots = nplots + 1
    	If (nplots eq 9) then begin
      		xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
      		xyouts, !D.X_SIZE/2, !D.Y_SIZE-2, 'EVT Event Data : '+title, alignment = 0.5, charsize = 1.6, charthick=5.0, /DEVICE
      		nplots = 0
      		erase
    	Endif

  Endfor					

  CgErase

  ;
  ;*****************************************************************************************
  ; Plot HKD data rates
  ;
  ;
  modules = dmid
  nmodules = n_elements(modules)                                       ; number of unique module ids

  nplots = 1

  For i = 0, 31 do begin

    	Print, 'Generating housekeeping data for Module ', i
    	mfilter = hkdall.modid eq i
    	filter  = where (mfilter eq 1, count)
    	
    	If count le 1 then continue
    	
    	xtimes = ((hkdall[filter].gpstim - gpsmin) / 86400.0) + jdmin
    
    	CgPlot, xtimes, hkdall[filter].triggers_total, $
    			psym=8, color = cgColor('Black'), symsize = 0.5, $
    			charsize = 0.7, yrange = [0,max(hkdall[filter].triggers_total)], $
    			ytickformat='(I6)', $
       			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
       			XTICKUNITS = ['Time', 'Day'], $
    			xtitle = 'Time (secs)', ytitle = 'Counts per sec', $
    			title = 'Count Rates - Module ' + strtrim(string(i),1), $
    			Position= cgLayout([2,4,nplots], xgap=6, ygap=6, oxmargin = [2,2], oymargin = [6,5]), /noerase
    
    	 oplot, xtimes, hkdall[filter].events_pc, psym=8, color = cgColor('Red'), symsize = 0.5
       oplot, xtimes, hkdall[filter].events_cc, psym=8, color = cgColor('Blue'), symsize = 0.5
       oplot, xtimes, hkdall[filter].events_c, psym=8, color = cgColor('Green'), symsize = 0.5
       oplot, xtimes, hkdall[filter].events_pc_ac, psym=8, color = cgColor('Orange'), symsize = 0.5
       oplot, xtimes, hkdall[filter].events_cc_ac, psym=8, color = cgColor('Violet'), symsize = 0.5
    
    	 al_legend, ['Total Triggers','PC Events','CC Events','C Events','PC Events - Vetoed','CC Events - Vetoed'], $
    			psym=[8,8,8,8,8,8],colors=['black','red','blue','green','orange','violet'], charsize = 0.6
          
    	 nplots = nplots + 1 
       If nplots eq 9 then begin
      		xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
      		xyouts, !D.X_SIZE/2, !D.Y_SIZE-2, 'EVT Module HKD Data : '+title, alignment = 0.5, charsize = 1.6, charthick=5.0, /DEVICE
      		cgErase
      		nplots = 1
    	 Endif			
       
  Endfor

  ;
  ;*****************************************************************************************
  ; Plot HKD HV values
  ;

  mcounts = fltarr(32)

	nplots = 1

  For igrp = 0, 3 do begin

	   print, 'Generating HV plot for module group ', igrp

  	 firstpltflg = 0					; flag to indicate whether first module has plotted
     fmod  = igrp * 8				; first module in group
  	
	   For imod = fmod, fmod+7 do begin
      
      		mfilter = hkdall.modid eq imod                
      		filter  = where (mfilter eq 1, count) 
      		mcounts[imod] = count
      	
      		If (mcounts[imod] gt 1) and (firstpltflg eq 0) then begin
      
        			xtimes = ((hkdall[where(hkdall.modid eq imod)].gpstim - gpsmin) / 86400.0) + jdmin
        
        			pcolors=['black','red','green','blue','orange','violet','magenta','cyan']
        
        			cgPlot, xtimes, hkdall[where(hkdall.modid eq imod)].hv, $
        			psym=8, color = cgColor(pcolors[0]), symsize = 1.0, $
        			charsize = 0.7, yrange = [min(hkdall.hv),max(hkdall.hv)], $
        			ytickformat='(I6)', $
           			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
           			XTICKUNITS = ['Time', 'Day'], $
        			xtitle = 'Time (secs)', ytitle = 'Module High Voltage (V)', $
        			title = 'Module Group ' + strtrim(string(igrp),1) + ' - High Voltages', $
        			Position= cgLayout([1,2,nplots], xgap=0, ygap=12, oxmargin = [2,2], oymargin = [6,5]), /noerase
        		
        			firstpltflg = 1
      		Endif
      	
      		If (mcounts[imod] ne 0) and (firstpltflg eq 1) then begin	
      			cgoplot, xtimes, hkdall[where(hkdall.modid eq imod)].hv, psym=8, color = cgColor(pcolors[imod-fmod]), symsize = 1.0
      		Endif

	    Endfor

      	al_legend, ['Mod '+ strtrim(string(fmod),1), $
      			'Mod '+ strtrim(string(fmod+1),1), $
      			'Mod '+ strtrim(string(fmod+2),1), $
      			'Mod '+ strtrim(string(fmod+3),1), $
      			'Mod '+ strtrim(string(fmod+4),1), $
      			'Mod '+ strtrim(string(fmod+5),1), $
      			'Mod '+ strtrim(string(fmod+6),1), $
      			'Mod '+ strtrim(string(fmod+7),1)], $
      			psym=[8,8,8,8,8,8,8,8], $
      			colors=['black','red','green','blue','orange','violet','magenta','cyan'], charsize = 0.6
      
      			nplots = nplots + 1 
			If nplots eq 3 then begin
				xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
				xyouts, !D.X_SIZE/2, !D.Y_SIZE-2, 'EVT Module HKD Data : '+title, alignment = 0.5, charsize = 1.6, charthick=5.0, /DEVICE
				cgErase
				nplots = 1
			Endif			
  Endfor

  ;
  ;*****************************************************************************************
  ; Plot HKD temperature values
  ;

  mcounts = fltarr(32)

  nplots = 1

  For igrp = 0, 3 do begin

    	print, 'Generating temp plot for module group ', igrp
    
    
    	firstpltflg = 0					; flag to indicate whether first module has plotted
    	fmod  = igrp * 8				; first module in group
    	
    
    	For imod = fmod, fmod+7 do begin
    
    		mfilter = hkdall.modid eq imod      
    	  filter  = where (mfilter eq 1, count) 
    	
    		mcounts[imod] = count
    	
    		If (mcounts[imod] ge 1) and (firstpltflg eq 0) then begin
    			
      			xtimes = ((hkdall[where(hkdall.modid eq imod)].gpstim - gpsmin) / 86400.0) + jdmin
            
      			pcolors=['black','red','green','blue','orange','violet','magenta','cyan']
            if n_elements(xtimes) LE 1 then continue
      			plot, xtimes, hkdall[where(hkdall.modid eq imod)].hv, $
      			psym=8, color = cgColor(pcolors[0]), symsize = 1.0, $
      			charsize = 0.7, yrange= [0,50],$;yrange = [min(hkdall.temp),max(hkdall.temp)], $
      			ytickformat='(I6)', $ 
      			XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
      			XTICKUNITS = ['Time', 'Day'], $
         		xtitle = 'Time (secs)', ytitle = 'Module Temperature', $
      			title = 'Module Group ' + strtrim(string(igrp),1) + ' - Temperatures', $
      			Position= cgLayout([1,2,nplots], xgap=0, ygap=12, oxmargin = [2,2], oymargin = [6,5]), /noerase
      		
      			firstpltflg = 1
    		Endif
    	
    		If (mcounts[imod] ge 1) and (firstpltflg eq 1) then begin	
    		  if n_elements(xtimes) LE 1 then continue
    		  ytimes = hkdall[where(hkdall.modid eq imod)].temp
    		   if n_elements(ytimes) LE 1 then continue
    			oplot, xtimes, ytimes, psym=8, color = cgColor(pcolors[imod-fmod]), symsize = 1.0
    		
    		Endif
    
    	Endfor

    	al_legend, ['Mod '+ strtrim(string(fmod),1), $
    			'Mod '+ strtrim(string(fmod+1),1), $
    			'Mod '+ strtrim(string(fmod+2),1), $
    			'Mod '+ strtrim(string(fmod+3),1), $
    			'Mod '+ strtrim(string(fmod+4),1), $
    			'Mod '+ strtrim(string(fmod+5),1), $
    			'Mod '+ strtrim(string(fmod+6),1), $
    			'Mod '+ strtrim(string(fmod+7),1)], $
    			psym=[8,8,8,8,8,8,8,8], $
    			colors=['black','red','green','blue','orange','violet','magenta','cyan'], charsize = 0.6
    			
    			nplots = nplots + 1 
    	If nplots Eq 3 then Begin
    				xyouts, 1.0, 0.0, systime(), alignment = 1.0, charsize = 0.7, /NORMAL  			
    				xyouts, !D.X_SIZE/2, !D.Y_SIZE-2, 'EVT Module HKD Data : '+title, alignment = 0.5, charsize = 1.6, charthick=5.0, /DEVICE
    				cgErase
    				nplots = 1
    	Endif			
			
  Endfor
  
  close, /all

  cgPS_Close
    CGPS2PDF, Title1+'.ps', Title1+'.pdf', /delete_ps


stop
End 