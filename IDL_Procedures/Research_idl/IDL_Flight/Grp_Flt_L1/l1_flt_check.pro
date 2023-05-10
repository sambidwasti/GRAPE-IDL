pro l1_flt_Check, fsearch_string, auxpath, nfiles=nfiles, iverbose=iverbose

  ;****************************************************************************************
  ; Name:
  ;   GRP_LEVEL1_FLT_PROCESS
  ;
  ; Purpose:
  ;   Processes GRAPE flight data (2011) from raw (gps) data to level 1 data.
  ;
  ; Calling Sequence:
  ;
  ;
  ; Input Parameters:
  ;
  ;   fsearch_string - Provides a list of input gps datafiles. This uses regular
  ;            expressions to provide a list of files to be processed.
  ;
  ;   auxpath - The full directory path for the auxiliary data files (which
  ;               includes the energy calibration files, the balloon position data,
  ;             the instrument pointing data, and table angle data).
  ;
  ;   nfiles
  ;
  ;   iverbose
  ;
  ; Input Data Files:
  ; All of these are in 1 folder and the path is defined by auxpath.
  ;
  ;     Ecal_ModP03.txt
  ;     Ecal_ModP04.txt
  ;     Ecal_ModP06.txt
  ;     Ecal_ModP07.txt
  ;     Ecal_ModP10.txt
  ;     Ecal_ModP11.txt
  ;     Ecal_ModP13.txt
  ;     Ecal_ModP14.txt
  ;     Ecal_ModP17.txt
  ;     Ecal_ModP18.txt
  ;     Ecal_ModP20.txt
  ;     Ecal_ModP21.txt
  ;     Ecal_ModP24.txt
  ;     Ecal_ModP25.txt
  ;     Ecal_ModP27.txt
  ;     Ecal_ModP28.txt
  ;     AtmDepthData.txt        ; Atm Depth vs. time
  ;     PositionData.txt        ; Lat, Long, Altitude vs. time
  ;     RotationTableData.txt   ; Table Angle vs. time
  ;     PointingData.txt        ; Pointing Data (azimuth, zenith vs time)
  ;
  ;
  ; Outputs:
  ;   Level 1 processed binary files in a level 1 folder.
  ;
  ; Uses:
  ;
  ;   INTERPOL
  ;   READCOL (astro IDL library)
  ;   VALUE_LOCATE
  ;   STRJOIN
  ;   CIRRANGE (astro IDL library)
  ;
  ;
  ; Author and History:
  ;   M. McConnell - Initial Version - July, 2013
  ;   S. Wasti     - Updating for Grape 2014 with some identation. Marked SW for the changes
  ;                  I have made. Oct 24, 2014
  ;
  ;
  ;****************************************************************************************
  ;


  ;======= INITIAL DEFINATION and VERIFICATION ================

  ;
  ;--- Parameter Verification.
  ;
  If (n_params() NE 2) Then Begin
    Print, 'USAGE: grp_level1_process, Input File Search String, Path to Auxilliary Data, Number of files to process"
    Print, 'Makes a File With Processed data"
    Return
  Endif

  ; Notes we might want a folder with Level 1 processed. Not sure yet.
  CD, Cur = Cur ; Current Folder   SW

  ;
  ;-- Add the / for the aux-path
  ;
  Auxpath = AuxPath+'/'   ; Added this correction

  ;
  ;--- Iverbose.
  ;
  If keyword_set(iverbose) ne 1 then iverbose = 0

  ;
  ;--- defining fsearch_String
  ;
  If n_params() NE 2 Then fsearch_string = 'EVT*.dat' ; Changed from gps SW

  ;
  ;--- Event Files
  ;
  Evtfiles = FILE_SEARCH(fsearch_string)          ; get list of Event input files; Changed from GPS.. SW

  ;
  ;--- Nfiles.
  ;
  If keyword_set(nfiles) NE 1 Then nfiles = n_elements(Evtfiles)

  ;=========================================================================================
  ;
  ;  Event format version number
  ;
  Verno = 6

  ;
  ;- Output folder and create directory if not present.
  ;
  OutFolder = Cur+'/Check/'
  If Dir_Exist(OutFolder) EQ 0 Then File_MKdir, OutFolder ; making a directory


  ;
  ;  Calorimeter element anode ids (0..63)
  ;
  Cal_anodes = [0,1,2,3,4,5,6,7,8,15,16,23,24,31,32,39,40,47,48,55,56,57,58,59,60,61,62,63]

  ;
  ;=========================================================================================
  ;
  ;  Plastic element anode Ids (0..63)
  ;
  Pls_anodes = [9,10,11,12,13,14,17,18,19,20,21,22,25,26,27,28,29,30,33,34,35,36,37,38,41, $
    42,43,44,45,46,49,50,51,52,53,54]

  ;
  ;
  ;=========================================================================================
  ;
  ;
  ;  Module position numbers for the 24 flight detectors (0..31)    Edited from 16 to 24: SW
  ;  These position numbers correspond to one of the 32 positions on the MIB.
  ;
  Module_Pos = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]

  ;
  ;
  ;=========================================================================================
  ;
  ;  Module serial number for each of the 24 flight detectors ;     Edited from 16 to 24: SW
  ;  The serial number identifiers the specific piece of hardware
  ;
  Module_Serno = [20,0,22,4,2,0,3,18,0,21,5,6,23,7,8,0,0,9,10,1,11,12,26,0,13,15,0,16,19,25,0,27]

  ;
  ;=========================================================================================
  ;
  ;  PointingData.txt   - pnt_times, azi_values, zen_values
  ;             These data come HRS data recorded on the GSE. (They are not
  ;             recorded on board!)  Times are in gps time.  Time range is
  ;             from 477464 to 552909                               Updated the range: SW
  ;
  Readcol, strjoin([auxpath, 'PointingData.txt']), $
    pnt_gpstimes, azi_values, zen_values, cosazi_values, sinazi_values, $
    coszen_values, sinzen_values, /silent

  ;
  ;=========================================================================================
  ;
  ;  PositionData.txt   - pos_times, lat_values, lon_values, alt_values
  ;             These data come from the rotator data provided by CSBF.
  ;             Time is in gps time. Time range is 477264 to 552919.
  ;
  readcol, strjoin([auxpath, 'PositionData.txt']), $
    pos_gpstimes, lat_values, lon_values, alt_values, /silent

  ;
  ;=========================================================================================
  ;
  ;  AtmDepthData.txt   - dep_times, dep_values
  ;             These data from CSBF CIP data.  We have converted mbars to
  ;             grammage.  Time is in gps time. Time range is 483700 to 587398.
  ;
  readcol, strjoin([auxpath, 'AtmDepthData.txt']), $
    dep_gpstimes, dep_values, /silent

  ;
  ;
  ;=========================================================================================
  ;
  ; Read in Rotation Table Data
  ;
  ; rt_time     -   time measured in secs from 0h UT on Sep 26,2014
  ; rt_gpstime  -   time measured in secs from 0h UT on previous Sunday
  ; rt_swtime   -   time (in secs) since start of sweep
  ; rt_sweep    -   sweep number (corrected)
  ; rt_status   -   status :  1=restart, 2=started, 3=initial,
  ;                   4=PPS wait, 5=Pausing, 6=Rotating, 7=Rates, 0=Stopped   ; Editt
  ; rt_step     -   indicates step size (+4 or -4)
  ; rt_angle    -   table angle value
  ;
  readcol, strjoin([auxpath, 'RotationTableData.txt']), $
    rt_time, $      ; time (secs) since 0h UT on Sep 26, 2014
    rt_gpstime, $   ; time (secs) since beginning of week (Sunday)
    rt_swtime, $    ; time (secs) since beginning of sweep
    rt_sweep, $     ; sweep number
    rt_status, $    ; rotation table status
    rt_step, $      ; rotation table step size
    rt_angle, $     ; rotation table angle
    format='F,F,F,I,I,I,I', /silent


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


  ;                                           Swapped this section from Grp_l1process to fix for new naming. SW
  ;  Read in energy calibration data.
  ;  In this case, there is one file for each module.
  ;  Each file contains energy calibration parameters for each of 64 anodes.
  ;  The numbers in each file / variable name are the module serial numbers.
  ;
  For i = 0,31 do begin
    If (module_serno[i] Eq 0) Then Continue
    filename = strjoin([auxpath, 'FM1', strn(module_serno[i], format='(I02)', padch='0'), '_Energy_Calibration.txt'])
    readcol, filename, Anodes, Slopes, SlopeErr, Offsets, OffsetErr, skipline=10, /silent
    Ecal_m[i,*]     = Slopes
    Ecal_b[i,*]     = Offsets
    Ecal_m_err[i,*] = SlopeErr
    Ecal_b_err[i,*] = OffsetErr
  Endfor

  ;
  ;=========================================================================================
  ;
  ;  Here we define the structure to hold the output L1 event data.
  ;  Currently the event size is 177 bytes.
  ;
  l1event = {                 $
    VERNO:0B,             $     ; Data format version number
    SWEEPNO:0,            $     ; Sweep Number
    SWSTART:0.0D,         $     ; Start time of sweep
    SWTIME:0.0D,          $     ; Time since start of sweep (secs)
    EVTIME:0.0D,          $     ; Event Time (secs in gps time - from 0h UT Sunday)
    MODPOS:0B,            $     ; Module Position Number
    MODSER:0B,            $     ; Module Serial Number
    EVCLASS:0B,           $     ; Event Class (1=C, 2=CC, 3=PC, 4= intermdule)
    IMFLAG:0B,            $     ; = 1 for intermodule (2 module) event
    ACFLAG:0B,            $     ; = 1 for anticoincidence
    NANODES:0B,           $     ; Number of triggered anodes (1-8)
    NPLS:0B,              $     ; Number of triggered plastic anodes
    NCAL:0B,              $     ; Number of triggered calorimeter anodes
    ANODEID:BYTARR(8),    $     ; Array of triggered anode numbers
    ANODETYP:BYTARR(8),   $     ; Array of triggered anode types
    ANODEPHA:INTARR(8),   $     ; Array of triggered anode pulse heights
    ANODENRG:FLTARR(8),   $     ; Array of triggered anode energies
    ANODESIG:FLTARR(8),   $     ; Array of triggered anode energy errors
    TOTNRG:0.0,           $     ; Total energy (sum of ALL triggered anodes)
    TOTESIG:0.0,          $     ; Error on total energy (sum of ALL triggered anodes)
    LAT:0.0,              $     ; Latitude (degs)
    LON:0.0,              $     ; Longitude (degs)
    ALT:0.0,              $     ; Altitude (feet)
    DEPTH:0.0,            $     ; Atm Depth (g cm^-2)
    PNTAZI:0.0,           $     ; Pointing Azimuth (degs)
    PNTZEN:0.0,           $     ; Pointing Zenith (degs)
    RTANG:0.0,            $     ; Rotation Table Angle (degs)
    RTSTAT:0,             $     ; Rotation Table Status
    LIVETIME:0.0,         $
    CORRECTLT:0.0         $
  }
  ;
  ;=========================================================================================
  ;
  
;
      ;====================================== SW =================================================
      ;     This is an additional stuff. These data are from manually analyzed dumped events from
      ;     the version 6.1( or the first version of level 6 data). These data are in the archive folder.
      ;
      Bad_Evt_Sweep = [13,15,16,17,18,19,20,21,22,23,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,$
        45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,$
        75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101]

      Bad_Evt_Start = [ 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 3, 0, 1, 1, 0, 1, 0,$
        1, 0, 1, 2, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 0, 2, 1, 3, 1, 1, 1, 1, 0, 2, 0,$
        0, 1, 2, 1, 1, 1, 1, 2, 1, 0, 0, 0, 1, 1, 2, 1, 4, 2, 1, 0, 2, 1, 1, 0, 0,  1,  1]

      Bad_Evt_End   = [ 1, 3, 5, 4, 7, 7, 3, 6, 2, 7, 5, 4, 1, 6, 5, 4, 2, 5, 1, 7, 2, 7, 9, 0, 5, 7, 4, 2, 5,90,$
        5, 2, 1, 5, 5,38, 3, 6, 5, 6, 4, 7, 2, 6, 4, 6, 6, 5, 3, 4, 2, 4, 3, 5, 4, 5, 7, 7, 4, 8,$
        8, 7,10, 6, 3, 4, 5, 3, 7,60, 3, 5, 3, 3, 8, 4,37, 6, 2, 8, 2, 6, 8, 5, 7,  7,  0]
      ;
      ; =============================================================================================
      ;
  


  ;
  ;======== INITIALIZATION FINISHED ===============
  ;

  ;
  ;======== READ IN FILES ========
  ;

  For ifile = 0, nfiles-1 Do Begin
    infile = Evtfiles[ifile]        ; Changed from GPS File :SW

    ;
    ;     Open input data file, read in all of the data (into array 'data'), and then
    ;     close the input data file.
    ;
    Openr, inunit, infile, /GET_LUN
    data = READ_BINARY(inunit)
    Free_lun, inunit

    ;
    ;     Each data packet is 32 bytes. Not all packets contain event info.
    ;
    totpkt = n_elements(data) / 32            ; total number of packets in file

    ;
    ;     There are 8 different types of data packets.  This array keeps track of the
    ;     total number of packets of each type for this file.
    ;
    npackets = lonarr(8)     ; array to keep track of packet type totals
    ipkt  = 0L            ; initialize packet counter for this file
    nevts = 0L            ; initialize event counter for this file


    ;
    ;     Define the data array to hold the output events.
    ;
    l1data = replicate(l1event, totpkt)   ; initialize output data array

    ;
    ;   Get start time of sweep from the filename.  This value is included as a 9-digit
    ;       number in the filename.
    ;   It is measured in msec, so we must divide by 1000 to get the time in secs.
    ;   It is measured in time since the beginning of the week (0h UT on Sunday)
    ;

    swstart = double(strmid(infile,19,6))   ; Updated from previous to get the correct time: SW

    ;
    ;     Get sweep number from input filename.
    ;     Typical flight data file name is 'EVT20140927_092917-552552c0101.dat'
    ;

    sweep = fix(strmid(infile,strpos(infile,'.')-4, 4))

    ;
    ;REMOVED a line which was here to correct the sweep number after the restart in 2011 run
    ;We did not restart the grape in 2013 flight so we did not need it. -SW.
    ;

    ;
    ;     Output file name.
    ;
    outfile = strjoin(['L1_v',strn(verno),'_Sweep_',strn(sweep, format='(I03)', padtype=1),'.dat'])

    ;
    ;     Open output data file.
    ;
    Openw, outunit, OutFolder + outfile, /GET_LUN

    Print
    Print, "************************************************************************"
    Print, "Input File No.      = ", ifile+1
    Print, "Input GPS File      = ", infile
    Print, "Output Level 1 File = ", outfile
    Print, "Sweep Number        = ", sweep
    Print
    Print

    ;
    ;       ==================================================================================
    ;
    temp_counter = 0L
    For i = 0L, totpkt-1 Do Begin

      ifirst = (i-1)*32         ; first byte for this packet
      ilast  = ifirst+31        ; last byte for this packet
      pkt = data(ifirst:ilast)  ; this packet

      ;
      ;     ptype is the packet type
      ;       ptype = 0  ==>  unused
      ;       ptype = 1  ==>  C event
      ;       ptype = 2  ==>  CC event
      ;       ptype = 3  ==>  PC event
      ;       ptype = 4  ==>  unused
      ;       ptype = 5  ==>  module threshold data
      ;       ptype = 6  ==>  module housekeeping
      ;       ptype = 7  ==>  module rates
      ;
      ptype = ishft(pkt(6) and '01110000'B, -4)

      ;
      ;     increment packet counter (based on packet type)
      ;
      npackets[ptype] = npackets[ptype]+1

      ;
      ;       tsecs1 gives time in units of seconds
      ;       tsecs2 gives time in units of 20 microsecs
      ;
      tsecs1 = swap_endian(fix(pkt,0,type=12))     ; bytes 0-1
      tsecs2 = swap_endian(fix(pkt,2,type=12))     ; bytes 2-3

      ;
      ;     Time since start of sweep
      ;
      swtime = tsecs1 + tsecs2*0.000020D

      ;
      ;     Full event time.  Time since 0h UT on Sunday.
      ;
      evtime = swstart + swtime

      ;
      ;     module coincidence flag ('1' = module coincidence)
      ;
      imflag = pkt(4)                  ; byte 4

      ;
      ;     modpos is the module position number (0-31)
      ;
      modpos = fix(pkt(5))                           ; byte 5

      ;
      ;       Extract the module serial number from the array defined above.
      ;
      modser = module_serno(where(modpos eq module_pos))

      ;
      ;     acflag is anti-coincidence flag ('1' = coincident event)
      ;
      acflag = ishft(pkt(6),-7)              ; byte 6, bit 7

      ;
      ;     module livetime (0-255)
      ;     Convert integer value (0-255) to fractional value (0.0-1.0)
      ;
      livetime = pkt(7) / 255.0

      ;
      ;           =============================================================================
      ;         We are only interested in event data.  So only C, CC, and PC event data
      ;         are processed further.
      ;
      

      If (ptype GE 1 and ptype LE 3) Then Begin

        ;
        ;           nanodes is the number of non-zero PHA values    ; byte 6, bits 0-3
        ;
        nanodes = pkt(6) And '00001111'B
        ;
        datawd = intarr(8)
        anode  = intarr(8)
        pha    = intarr(8)
        type   = intarr(8)
        nrg    = fltarr(8)
        nrgsig = fltarr(8)

        ;
        ;             extract anode number and PHA value from each of eight 16-bit words
        ;
        For j = 0,7 Do Begin
          datawd[j] = swap_endian(fix(pkt,8+j*2,type=12))
          anode[j]  = ishft(datawd[j] and '1111110000000000'B, -10)   ; 0-63
          pha[j]    = datawd[j] and '0000001111111111'B
          type[j]   = 0
        EndFor

        ;
        ;       For each anode, find out whether it is a plastic or calorimeter.
        ;       Anodes are numbered from 0-63.
        ;
        For j = 0, min([nanodes,8])-1 Do Begin
          If (where ((anode[j]) EQ pls_anodes) GE 0) Then type[j] = 1 ; plastic
          If (where ((anode[j]) EQ cal_anodes) GE 0) Then type[j] = 2 ; calorimeter
        EndFor

        ;
        ;       Extract number of plastic and calorimeter elements.
        ;
        npls = n_elements(where(type Eq 1, /null))
        ncal = n_elements(where(type Eq 2, /null))

        ;
        ;       Convert PHA values to energy (keV)
        ;
        For j = 0, min([nanodes,8])-1  Do Begin
          nrg[j]    = Ecal_m[modpos,anode[j]]*pha[j] + Ecal_b[modpos,anode[j]]
          nrgsig[j] = sqrt(float(pha[j])^2*Ecal_m_err[modpos,anode[j]]^2 $
            + Ecal_b_err[modpos,anode[j]]^2)
        EndFor

        ;
        ;       Calculate total energy and the error on total energy.
        ;       Use only those anodes that are triggered.
        ;
        totnrg  = total(nrg[0:min([nanodes,8])-1])
        totesig = sqrt(total(nrgsig[0:min([nanodes,8])-1]^2))

        ;
        ;         packet id (event number)
        ;
        pcktid = swap_endian(fix(pkt,30,type=12))

        ;
        ;       Get the position data for this event time.
        ;       Time here is in seconds from the start of the week (GPS times).
        ;       Values of -1.0 are provided if times are outside of the tabulated range.
        ;
        latitude  = interpol(lat_values,pos_gpstimes, evtime)
        longitude = interpol(lon_values,pos_gpstimes, evtime)
        altitude  = interpol(alt_values,pos_gpstimes, evtime)

        If (evtime LT min(pos_gpstimes) OR evtime GT max(pos_gpstimes) ) Then Begin
          latitude  = -1.0
          longitude = -1.0
          altitude  = -1.0
        Endif

        ;
        ;       Get the atmospheric depth data for this event time.
        ;       Time here is in seconds from the start of the week (GPS times).
        ;       Values of -1.0 are provided if times are outside of the tabulated range.
        ;
        depth     = interpol(dep_values,dep_gpstimes, evtime)
        If (evtime LT min(dep_gpstimes) OR evtime GT max(dep_gpstimes) )  Then Begin
          depth  = -1.0
        EndIf

        ;
        ;       Get the pointing data for this event time.
        ;       Time here is in seconds from the start of the week (GPS times).
        ;       Values of -1.0 are provided if times are outside of the tabulated range.
        ;       To avoid issues of interpolating angle values across range boundaries
        ;       (say, from 359 -> 1), we interpolate both the sin and cos values
        ;       and use atan to get the angles.
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

        If (evtime LT min(pnt_gpstimes) Or evtime Gt max(pnt_gpstimes) )  Then Begin
          azimuth  = -1.0
          zenith   = -1.0
        EndIf

        ;       The table angle values are retrieved using the value_locate function.
        ;         The times provided in these data refer to the time at which the table
        ;       completing moving to the corresponding table angle value. Unlike the
        ;       interpolations above, we want to take into account the fact that the
        ;         table stays at that position until the next entry.
        ;
        rtang   = rt_angle  (value_locate(rt_gpstime, evtime))
        rtstat  = rt_status (value_locate(rt_gpstime, evtime))
        sweepno = rt_sweep  (value_locate(rt_gpstime, evtime))

        ;
        ;
        ;           >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        If iverbose Eq 1 And i Lt 100 Then Begin
          typedef = ['unused','C type', 'CC type', 'PC Type', 'unused', 'Threshold', 'Housekeeping', 'Rates']  ;
          print, pkt,                   format = '(32(Z2.2,x))'
          print
          print, pcktid,                format = '("Packet Id = ",I6)'
          print, sweep,                 format = '("Sweep No. = ",I6)'
          print, swstart,               format = '("Sweep Start Time (s)    =  ",I16)'
          print, swtime,                format = '("Sweep Time (s)          =  ",F16.4)'
          print, evtime,                format = '("Event Time (s)          =  ",F16.4)'
          print, latitude,              format = '("Latitude        =   ",F8.2)'
          print, longitude,             format = '("Longitude       =   ",F8.2)'
          print, altitude,              format = '("Altitude        =   ",F8.0)'
          print, depth,                 format = '("Depth           =   ",F8.2)'
          print, azimuth,               format = '("Pnt Azi         =   ",F8.2)'
          print, zenith,                format = '("Pnt Zen         =   ",F8.2)'
          print, rtang,                 format = '("Table Angle     =   ",F8.2)'
          print, rtstat,                format = '("Table Status    =   ",I1)'
          print, livetime,              format = '("Livetime        =   ",F8.3)'
          print, imflag,                format = '("Mod Coinc Flag  =   ",I1)'
          print, acflag,                format = '("Anti Coinc Flag =   ",I1)'
          print, modpos,                format = '("Modpos(0-31)    =  ",I2)'
          print, modser,                format = '("Mod Serial No.  =  ",I2)'
          print, livetime,              format = '("Livetime        = ",F6.3)'
          print, ptype, typedef[ptype], format = '("Data Type       =   ",I1," (",A8,")")'
          print, nanodes,               format = '("No. of  Anodes  =   ",I1)'
          print, npls,                  format = '("No. of plastics =   ",I1)'
          print, ncal,                  format = '("No. of cals     =   ",I1)'
          print, totnrg,                format = '("Total Energy    =   ",F8.3)'
          print, totesig,               format = '("Total Energy Err=   ",F6.3)'


          For j = 0,nanodes-1 Do print, j+1, type[j], anode[j], pha[j], nrg[j], nrgsig[j], $
            format =  '(I1,"- Type, Anode(0-63), PHA, Energy, Energy Err    =  ", I1,"  ",I2,"  ",I4,"  ",F8.3,"  ",F7.3)
          print
        EndIf

        ;           >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ;         Output event message :
        ;
        ;       verno     BYTE    event format version number
        ;         sweepno     INT     sweep number
        ;       swstart     DOUBLE    Sweep start time
        ;         swtime      DOUBLE    Sweep time (secs since start of sweep)
        ;         evtime      DOUBLE    Event time (secs from 0h UT on Sunday)
        ;       modpos      BYTE    Module position number (0..31)
        ;       modser      BYTE    Module serial number
        ;         evclass     BYTE    Event Class (1=C,2=CC,3=PC,4=IM)
        ;       imflag      BYTE    Inter-Module Event flag (1=IM)
        ;       acflag      BYTE    Anti-Coincidence Flag
        ;       nanodes     BYTE    Number of triggered anodes
        ;       npls      BYTE    Number of plastic anodes
        ;       ncal      BYTE    Number of calorimeter anodes
        ;       anodeid     BYTE(8)   List of triggered anode ids (0..63)
        ;       anodetype   BYTE(8)   Anode Type (1=plastic, 2=calorimeter)
        ;       anodepha    INT(8)
        ;       anodenrg    FLOAT(8)  List of triggered anode energies
        ;       anodesig    FLOAT(8)  List of triggered anode energy errors
        ;         totnrg      FLOAT   Total event energy (keV)
        ;         totesig     FLOAT   Error on total event energy (keV)
        ;       lat       FLOAT   Latitude (degs)
        ;       lon       FLOAT     Longitude (degs)
        ;       alt       FLOAT   Altitude (ft)
        ;         depth     FLOAT   Atmospheric Depth (g cm^-2)
        ;         pntazi      FLOAT   Pointing Azimuth (degs)
        ;         pntzen      FLOAT   Pointing Zenith (degs)
        ;         rtang     FLOAT   Rotation Table Angle (degs)
        ;         rtstat      INT     Rotation Table Status
        ;         livetime    FLOAT   Instrument Livetime (fractional, 0-1)
        ;       correctlt   FLOAT   Corrected livetime (1 second shift)
        ;
        ;       Transfer the data for this event to the output array.
        ;
        ;
        L1EVENT.VERNO     = verno
        L1EVENT.SWEEPNO   = sweep
        L1EVENT.SWSTART   = swstart
        L1EVENT.SWTIME    = swtime
        L1EVENT.EVTIME    = evtime
        L1EVENT.MODPOS    = byte(modpos)    ; convert from INT to BYTE
        L1EVENT.MODSER    = byte(modser)    ; convert from INT to BYTE
        L1EVENT.EVCLASS   = byte(ptype)     ; convert from INT to BYTE
        L1EVENT.IMFLAG    = imflag
        L1EVENT.ACFLAG    = acflag
        L1EVENT.NANODES   = byte(nanodes)   ; convert from INT to BYTE
        L1EVENT.NPLS    = byte(npls)      ; convert from LONG to BYTE
        L1EVENT.NCAL    = byte(ncal)      ; convert from LONG to BYTE
        L1EVENT.ANODEID   = byte(anode)     ; convert from INT to BYTE
        L1EVENT.ANODETYP  = byte(type)      ; convert from INT to BYTE
        L1EVENT.ANODEPHA  = pha
        L1EVENT.ANODENRG  = nrg
        L1EVENT.ANODESIG  = nrgsig
        L1EVENT.TOTNRG    = totnrg
        L1EVENT.TOTESIG   = totesig
        L1EVENT.LAT       = float(latitude)   ; convert from DOUBLE to FLOAT
        L1EVENT.LON     = float(longitude)    ; convert from DOUBLE to FLOAT
        L1EVENT.ALT     = float(altitude)   ; convert from DOUBLE to FLOAT
        L1EVENT.DEPTH   = float(depth)      ; convert from DOUBLE to FLOAT
        L1EVENT.PNTAZI    = float(azimuth)    ; convert from DOUBLE to FLOAT
        L1EVENT.PNTZEN    = float(zenith)   ; convert from DOUBLE to FLOAT
        L1EVENT.RTANG     = float(rtang)      ; convert from INT to FLOAT
        L1EVENT.RTSTAT    = rtstat
        L1EVENT.LIVETIME  = livetime
        L1EVENT.CORRECTLT = -1.0D


        ;
        ;       Add event to the event array
        ;

        l1data[nevts] = l1event
        nevts = nevts + 1

      Endif
      ;           =============================================================================
      ;
      ;   Get next packet in this file...
      ;
    Endfor


    ;
    ;   ==================================================================================
    ;
    ;   End of this file...
    ;
    ;   Trim the unused space allocated to the l1data structure.  This is done by
    ;   resizing the structure based on the number of events.
    ;
    
    ;
    ;===== SW
    ;
    IF  (Where(sweep EQ Bad_Evt_Sweep) Ne -1) NE 0 Then begin      ; Skipping module Then Begin
      Array_Position = Where(sweep EQ Bad_Evt_Sweep)
      Skip_Start = Bad_Evt_Start[Array_Position[0]]
      Skip_End   = Bad_Evt_End[Array_Position[0]]
      l1data = l1data[skip_start: nevts-skip_end-1]
      nevts= nevts- (skip_start+skip_end)

    EndIF Else Begin
      l1data = l1data[0:nevts-1]

    Endelse

   




    ;
    ;                              **** ADDED 8 more modules to these*** SW
    ;   For correcting the livetime, we need to isolate the data from each module,
    ;   since livetime is module-dependent.  So we start by setting up arrays of
    ;   event time and livetime, from which we will correct the livetimes.
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
      ptr_new(l1data[where (l1data.modpos eq module_pos[15])].evtime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[16])].evtime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[17])].evtime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[18])].evtime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[19])].evtime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[20])].evtime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[21])].evtime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[22])].evtime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[23])].evtime, /no_copy)]

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
      ptr_new(l1data[where (l1data.modpos eq module_pos[15])].livetime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[16])].livetime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[17])].livetime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[18])].livetime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[19])].livetime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[20])].livetime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[21])].livetime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[22])].livetime, /no_copy), $
      ptr_new(l1data[where (l1data.modpos eq module_pos[23])].livetime, /no_copy)]

    ;
    ;   Correct livetime to account for the the fact that the livetime for a given
    ;   event is averaged over the previous one-second time interval.  So the true
    ;   livetime associated with a given comes from livetime values that are
    ;       measured 1.0 second later.  In most cases, this is of little consequence,
    ;   but for rapid transients (flares or GRBs), this could be important.
    ;
    ;   At the end of the file, the last 1 seconds of data takes on the livetime of the
    ;   last event.
    ;

    
    For i = 0, nevts-1 Do Begin
      im = where(module_pos Eq l1data[i].modpos)
      
    ;  if l1data[i].correctlt lt 0.0 then print, i
      
      ;  if l1data[i].correctlt LT 0.00 Then begin
;      a =  *ltable_ltime[im[0]]
;      b =  *ltable_evtime[im[0]]

;      c = value_locate(b, l1data[i].evtime+1.0)
;      print, b[c-1], b[c], b[c+1]
;      print, a [c-1], a[c], a[c+1]
;      print
      print, im
print,'********'
a = *ltable_evtime[im[0]]
b =  a[10070:10100]
print, b
window, 0
  plot, sort(b)
c = b[sort(b)]
 window, 2
  plot, sort(c)
      ; format slightly different from interpol().
      ; Yinter = Interpol(Ytable, Xtable, Xinter) 
      ; linterp, Xtable, Ytable, Xinter, Yinter
      Linterp, *ltable_evtime[im[0]], *ltable_ltime[im[0]], (l1data[i].evtime+1.0),  f
      l1data[i].correctlt = f
      
;      l1data[i].correctlt = Interpol(  *ltable_ltime[im[0]], *ltable_evtime[im[0]],  $
;        l1data[i].evtime+1.0)
;         
         if f lt 0.0 then begin
         print, f
         print, i
         print, Strn( l1data[i].evtime+1.0),' ', strn(l1data[i].correctlt)
         print, max(b)
         print, min(b)
         Stop
         Endif
    EndFor


    ;
    ;   Write entire structure to the output file in one statement.
    ;
    writeu, outunit, l1data


    ;
    ;   Close this file.  Calling free_lun closes the file and frees up the unit
    ;     number.
    ;


    free_lun, outunit

    ;
    ;   Print out packet statistics for this file.
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
    ;   Print out total counts and elasped time info.
    ;   It has been noted that there were many files in which the first one or two events
    ;   had bad times, which led to elapsed times of less than zero.  It was found that
    ;   these events with bad times also had a rotation table status of 7 (RATES), which
    ;   also didn't seem to make sense, as there should be no events during the RATES
    ;   period.  So here we determine elapsed time based on events that do not have a RT
    ;   status of 7.
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

  EndFor
  ;
  ;=========================================================================================
  ;

  print
  print, "***************************"
  print, "LEVEL 1 PROCESSING COMPLETE"
  print, "***************************"
  print

  Stop


end