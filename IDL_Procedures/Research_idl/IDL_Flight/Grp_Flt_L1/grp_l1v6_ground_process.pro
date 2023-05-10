pro grp_l1v6_Ground_process, fsearch_string, auxpath, nfiles=nfiles, iverbose=iverbose

  ;****************************************************************************************
  ; Name:
  ;   GRP_L1PROCESS
  ;
  ; Purpose:
  ;   Processes GRAPE flight data (2011) from raw (gps) data to level 1 data.
  ;   (This is mostly for Ground Process)
  ;
  ;   For now the following parameters are not processed here and are therefore
  ;   assigned a value of -1.0 in the final event message:
  ;       latitude    from gps
  ;       longitude   from gps
  ;       altitude    from gps
  ;       depth     from csbf
  ;       azimuth     from gps
  ;       zenith      from hrs adu block      SW: We get it now
  ;       rtang     from hrs adu block        SW: We get it now
  ;       rtstat      from hrs adu block      SW: We get it now
  ;       sweepno                             SW: We get it now
  ;
  ; Calling Sequence:
  ;
  ;
  ; Input Parameters:
  ;
  ;   fsearch_string - Provides a list of input EVT datafiles. This uses wildcard
  ;            expressions to provide a list of files to be processed.
  ;
  ;   auxpath - The full directory path for the auxiliary data files (which
  ;               includes the energy calibration files, the balloon position data,
  ;             the instrument pointing data, and table angle data).
  ;           - Now this only includes the Energy Calibration file. SW
  ;           - The HRS data is in the folder its opened for ease.  SW
  ;           - Havent touched LRS DATA YET                         SW
  ;
  ;   nfiles  - The number of files to process from the inpout filelist.
  ;
  ;   iverbose - If set to 1, this will print out detailed information for the
  ;           first 100 events that are processed.
  ;
  ; Input Data Files:
  ;
  ;     FM101_Energy_Calibration.txt
  ;     FM102_Energy_Calibration.txt
  ;     FM103_Energy_Calibration.txt
  ;     FM104_Energy_Calibration.txt
  ;     FM105_Energy_Calibration.txt
  ;     FM106_Energy_Calibration.txt
  ;     FM107_Energy_Calibration.txt
  ;     FM108_Energy_Calibration.txt
  ;     FM109_Energy_Calibration.txt
  ;     FM110_Energy_Calibration.txt
  ;     FM111_Energy_Calibration.txt
  ;     FM112_Energy_Calibration.txt
  ;     FM113_Energy_Calibration.txt
  ;     FM115_Energy_Calibration.txt
  ;     FM116_Energy_Calibration.txt
  ;     FM118_Energy_Calibration.txt
  ;     FM119_Energy_Calibration.txt
  ;     FM120_Energy_Calibration.txt
  ;     FM121_Energy_Calibration.txt
  ;     FM123_Energy_Calibration.txt
  ;     FM125_Energy_Calibration.txt
  ;     FM126_Energy_Calibration.txt
  ;     FM127_Energy_Calibration.txt
  ;
  ;     hrs_ac_data.txt for table angle, stepsize and status information. ;SW
  ;
  ; Outputs:
  ;
  ;
  ; Uses:
  ;
  ;   INTERPOL
  ;   READCOL (astro IDL library)
  ;
  ;
  ; Author and History:
  ;   July, 2013        - M. McConnell - Initial Version -
  ;   July 17, 2014     - S. Wasti :
  ;                     - Adding the table angle, status data from hrs_ac_data.txt
  ;                     - Works with 1 or 2 parameters.
  ;                     - If 1 parameters (if Aux path not provided), Auxpath defaults to
  ;                       the current directory or folder and Energy files. HRS data is looked
  ;                       into the same directory.
  ;   July 18, 2014     - S.Wasti  :
  ;                     - Now the processed files are in a folder in the current path.
  ;   August 8, 2014    - S.Wasti  :
  ;                     - Added a print statement that prints no. of files left and packet number
  ;                       after each  10000th packet to make sure its working for huge files.
  ;   August 27,2014    - S.Wasti  :
  ;                     - Fixed the bug with Mod_Pos and Mod_Serial no. were not matching
  ;   September 4,2014  - S.Wasti  :
  ;                     - Adding the Zenith Angle data from hrs_ac_data.0txt
  ;****************************************************************************************
  ;


  CD, Cur = Cur        ; Grabbing the current folder SW
  Output_Path = Cur+'/L1_Processed_Files/'
  If Dir_Exist(Output_Path) EQ 0 Then File_MKdir, Output_Path ; making a directory

  if (n_params() NE 2)  And  (n_params() NE 1)then begin
    print, 'USAGE1: grp_l1process, Input File Search String, Path to Auxilliary Data, Number of files to process"
    print, '      -----  OR ----- '                                                      ; SW
    print, 'USAGE2: grp_l1process, Input File Search String, Number of files to process' ; SW
    print, 'Makes a File With Processed data"
    Return
  endif



  if (n_params() ne 2) then auxpath=cur+'/' Else auxpath=auxpath+'/'                ;SW the Auxilary path to current directory if Not Defined.

  ;=======================================================================================
  ;========================= HRS Data grabbed and stored =================================; SW
  ; Reading the HRS file to grab the data about the table rotation and various other things SW
  hrs_fname =cur+'/' +'hrs_ac_data.txt'
  openr, hrs_lun, hrs_fname, /Get_Lun
  data=''

  Total_Rows = FIle_Lines(hrs_fname)-4      ; Total length of the array.

  ; Code before zenith.
  ;        Hrs_Array = LonArr(Total_Rows,4)          ; 2D array of total length X 4. Could change to diffenent when put in frame
  ;        Hrs_time_Array = LonArr(Total_Rows)       ; 1D Array of just time for the Value_Locate function.


  Hrs_Array = DblArr(Total_Rows,5)          ; 2D array of total length X 4. Could change to diffenent when put in frame
  Hrs_time_Array = DblArr(Total_Rows)       ; 1D Array of just time for the Value_Locate function.


  readf, hrs_lun, data        ;Skip
  readf, hrs_lun, data        ;Skip
  readf, hrs_lun, data        ;Skip
  readf, hrs_lun, data        ;Skip

  Temp_count =0L
  While Not EOF(hrs_Lun) Do Begin          ; We Read and collect the data.
    readf, hrs_lun, data
    Len= StrLen(Data)

    ; Read Values     ; Previous code before zenith
    ;              Temp_time   = Long(Strmid( data, 0,17))/1000
    ;              Temp_Angle  = Long(Strmid( data, 17, 7))
    ;              Temp_Step   = Long(Strmid( data, 24, 5))
    ;              Temp_Status = Long(Strmid( data, 29, 3))

    Temp_time   = Double(Strmid( data, 0,17))/1000
    Temp_Angle  = Double(Strmid( data, 17, 7))
    Temp_Step   = Double(Strmid( data, 24, 5))
    Temp_Status = Double(Strmid( data, 29, 3))

    Temp_Zenith =Double( Strmid(data,50,StrLen(data)-50) )

    ; Store Values
    Hrs_Array[Temp_Count,0] = Temp_time
    Hrs_Array[Temp_Count,1] = Temp_Angle
    Hrs_Array[Temp_Count,2] = Temp_Step
    Hrs_Array[Temp_Count,3] = Temp_Status

    Hrs_Array[Temp_Count,4] = Temp_Zenith

    Temp_Count++
  EndWhile

  Hrs_Array = Hrs_Array[ sort(Hrs_Array[*,0]),* ]
  Hrs_Time_Array = Hrs_Array[*,0]

  Free_Lun,Hrs_lun
  ;====================== HRS DATA STORED ===========================================  ;SW
  ;==================================================================================



  if keyword_set(iverbose) ne 1 then iverbose = 0

  if n_params() ne 2 then fsearch_string = 'EVT*.dat'

  evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  if keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)

  ;=========================================================================================
  ;
  ;  Event format version number
  ;
  verno = 6

  ;
  ;=========================================================================================
  ;
  print
  print, "****************************************"
  print, "GRAPE LEVEL 1 PRE-FLIGHT DATA PROCESSING "
  print, "****************************************"
  print, "GRP_L1PROCESS.PRO
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
  ;  Module position numbers for the 24 flight detectors (0..31)
  ;  These position numbers correspond to one of the 32 positions on the MIB.
  ;
  module_pos = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]

  ;
  ;
  ;=========================================================================================
  ;
  ;  Module serial number for each of the 24 flight detectors
  ;  The serial number identifiers the specific piece of hardware
  ;
  module_serno = [20,0,22,4,2,0,3,18,0,21,5,6,23,7,8,0,0,9,10,1,11,12,26,0,13,15,0,16,19,25,0,27]


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

  nmodules   = n_elements(module_serno)
  ;
  ;  Read in energy calibration data.
  ;  In this case, there is one file for each module.
  ;  Each file contains energy calibration parameters for each of 64 anodes.
  ;  The numbers in each file / variable name are the module serial numbers.
  ;
  for i = 0,31 do begin
    if (module_serno[i] eq 0) then continue
    filename = strjoin([auxpath, 'FM1', strn(module_serno[i], format='(I02)', padch='0'), '_Energy_Calibration.txt'])
    readcol, filename, Anodes, Slopes, SlopeErr, Offsets, OffsetErr, skipline=10, /silent
    Ecal_m[i,*]     = Slopes
    Ecal_b[i,*]     = Offsets
    Ecal_m_err[i,*] = SlopeErr
    Ecal_b_err[i,*] = OffsetErr
  endfor

  ;
  ;=========================================================================================
  ;
  ;  Here we define the structure to hold the output L1 event data.
  ;  Currently the event size is 177 bytes.
  ;
  l1event = {     $
    VERNO:0B, $        ; Data format version number
    SWEEPNO:0, $       ; Sweep Number
    SWSTART:0.0D, $      ; Start time of sweep
    SWTIME:0.0D, $       ; Time since start of sweep (secs)
    EVTIME:0.0D, $             ; Event Time (secs in gps time - from 0h UT Sunday)
    MODPOS:0B, $       ; Module Position Number
    MODSER:0B, $       ; Module Serial Number
    EVCLASS:0B, $              ; Event Class (1=C, 2=CC, 3=PC, 4= intermdule)
    IMFLAG:0B, $       ; = 1 for intermodule (2 module) event
    ACFLAG:0B, $       ; = 1 for anticoincidence
    NANODES:0B, $        ; Number of triggered anodes (1-8)
    NPLS:0B, $         ; Number of triggered plastic anodes
    NCAL:0B, $         ; Number of triggered calorimeter anodes
    ANODEID:BYTARR(8), $   ; Array of triggered anode numbers
    ANODETYP:BYTARR(8), $    ; Array of triggered anode types
    ANODEPHA:INTARR(8), $    ; Array of triggered anode pulse heights
    ANODENRG:FLTARR(8), $    ; Array of triggered anode energies
    ANODESIG:FLTARR(8), $    ; Array of triggered anode energy errors
    TOTNRG:0.0, $        ; Total energy (sum of ALL triggered anodes)
    TOTESIG:0.0, $       ; Error on total energy (sum of ALL triggered anodes)
    LAT:0.0, $         ; Latitude (degs)
    LON:0.0, $         ; Longitude (degs)
    ALT:0.0, $         ; Altitude (feet)
    DEPTH:0.0, $       ; Atm Depth (g cm^-2)
    PNTAZI:0.0, $        ; Pointing Azimuth (degs)
    PNTZEN:0.0, $        ; Pointing Zenith (degs)
    RTANG:0.0, $       ; Rotation Table Angle (degs)
    RTSTAT:0, $        ; Rotation Table Status
    LIVETIME:0.0, $
    CORRECTLT:0.0  $
  }

  ;
  ;=========================================================================================
  ;
  for ifile = 0, nfiles-1 do begin
    infile = evtfiles[ifile]
    ;
    ;     Open input data file, read in all of the data (into array 'data'), and then
    ;     close the input data file.
    ;
    openr, inunit, infile, /GET_LUN
    data = READ_BINARY(inunit)
    free_lun, inunit
    ;
    ;     Each data packet is 32 bytes. Not all packets contain event info.
    ;
    totpkt = n_elements(data) / 32            ; total number of packets in file
    ;
    ;     There are 8 different types of data packets.  This array keeps track of the
    ;     total number of packets of each type for this file.
    ;
    npackets = lonarr(8)     ; array to keep track of packet type totals
    ;
    ipkt  = 0L            ; initialize packet counter for this file
    nevts = 0L            ; initialize event counter for this file
    ;
    ;     Define the data array to hold the output events.
    ;
    l1data = replicate(l1event, totpkt)   ; initialize output data array

    ;
    ;     Typical data file name is 'EVT20140714_135607-136569c0010.dat'
    ;
    ;   Get start time of sweep from the filename.  This value is included as a 6-digit
    ;       number in the filename.
    ;   It is measured in time since the beginning of the week (0h UT on Sunday)
    ;
    swstart = long(strmid(infile,19,6))
    ;
    ;   Get sweep number from input filename.
    ;
    sweep = fix(strmid(infile,26,4))
    ;
    ;   Get date info from filename
    ;
    file_year  = fix(strmid(infile,3,4))
    file_month = fix(strmid(infile,7,2))
    file_day   = fix(strmid(infile,9,2))
    ;
    ;   Get time info from filename
    ;
    file_hrs  = fix(strmid(infile,12,2))
    file_mins = fix(strmid(infile,14,2))
    file_secs = fix(strmid(infile,16,2))
    ;
    ;     Output file name.
    ;
    outfile = strjoin(['L1_',strmid(infile,3,33)])

    ;
    ;     Open output data file.
    ;     Added Output_path for a new folder  SW
    ;
    openw, outunit, Output_Path+outfile, /GET_LUN

    print
    print, "************************************************************************"
    print, "Input File No.      = ", ifile+1
    print, "Sweep Number        = ", sweep
    print, "Input EVT File      = ", infile
    print, "Output Level 1 File = ", outfile
    print
    print
    ;
    ;       ==================================================================================
    ;

    for i = 0L, totpkt-1 do begin
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

      ; This is an error.       modser = module_serno(where(modpos eq module_pos))  ; SW
      ; Fixing it
      modser = module_serno[modpos]         ; SW Fixed the above error..


      ;
      ;     acflag is anti-coincidence flag ('1' = coincident event)
      ;
      acflag = ishft(pkt(6),-7)              ; byte 6, bit 7
      ;
      ;     module livetime (0-255)
      ;     Convert integer value (0-255) to fractional value (0.0-1.0)
      ;
      livetime = pkt(7) / 255.0

      ;             if (iverbose eq 1 and i lt 100) then print, 'Pkt No. ',i, '     Pkt Type = ', ptype
      ;
      ;           =============================================================================
      ;         We are only interested in event data.  So only C, CC, and PC event data
      ;         are processed further.
      ;
      if (ptype ge 1 and ptype le 3) then begin
        ;
        ;           nanodes is the number of non-zero PHA values    ; byte 6, bits 0-3
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
        ;             extract anode number and PHA value from each of eight 16-bit words
        ;
        for j = 0,7 do begin
          datawd[j] = swap_endian(fix(pkt,8+j*2,type=12))
          anode[j]  = ishft(datawd[j] and '1111110000000000'B, -10)   ; 0-63
          pha[j]    = datawd[j] and '0000001111111111'B
          type[j]   = 0
        endfor

        ;
        ;       For each anode, find out whether it is a plastic or calorimeter.
        ;       Anodes are numbered from 0-63.
        ;
        for j = 0, min([nanodes,8])-1 do begin
          if (where ((anode[j]) eq pls_anodes) ge 0) then type[j] = 1 ; plastic
          if (where ((anode[j]) eq cal_anodes) ge 0) then type[j] = 2 ; calorimeter
        endfor

        ;
        ;       Extract number of plastic and calorimeter elements.
        ;
        npls = n_elements(where(type eq 1, /null))
        ncal = n_elements(where(type eq 2, /null))

        ;
        ;       Convert PHA values to energy (keV)
        ;
        for j = 0, min([nanodes,8])-1  do begin
          nrg[j]    = Ecal_m[modpos,anode[j]]*pha[j] + Ecal_b[modpos,anode[j]]
          nrgsig[j] = sqrt(float(pha[j])^2*Ecal_m_err[modpos,anode[j]]^2 $
            + Ecal_b_err[modpos,anode[j]]^2)
        endfor

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
        ;         No position data for pre-flight data.
        ;       Values of -1.0 are provided.
        ;
        latitude  = -1.0
        longitude = -1.0
        altitude  = -1.0
        ;
        ;         No atmopsheric depth data for pre-flight data.
        ;       Values of -1.0 are provided.
        ;
        depth  = -1.0
        ;
        ;         No pointing data for pre-flight data.
        ;       Values of -1.0 are provided.
        ;
        azimuth  = -1.0


        ;       zenith   = -1.0  grabbing zenith along with the rtang below::


        ;       The table angle values are retrieved using the value_locate function.
        ;         The times provided in these data refer to the time at which the table
        ;       completing moving to the corresponding table angle value. Unlike the
        ;       interpolations above, we want to take into account the fact that the
        ;         table stays at that position until the next entry.
        ;         No pointing data for pre-flight data.




        ; ====================================================================================
        ;***;------------------- Grabbing the rtang and rtstat from the HRS file (SW)------------------
        ;
        Hrs_Time_Index = Value_Locate(HRS_Time_Array, Long(evtime))

        If Hrs_Time_Index EQ -1 then Begin
          rtang  = -1.0
          rtstat = -1.0
          zenith = -1.0
          Print, ' ERROR: HRS FILE MISSING FOR THIS TIME ',EVTIME
        EndIf Else Begin
          rtang = Long(Hrs_Array[Hrs_Time_Index,1])
          rtstat= Long(Hrs_Array[Hrs_Time_Index,3])
          zenith = Hrs_Array[Hrs_time_Index,4]      ; SW september 4
        EndElse

        If (rtang eq 172) Then print, evtime


        ;--- Debugging print statement.
        ;             if (rtstat Eq 5) and (i gt 100000) then  Print, evtime, rtang,rtstat, Zenith
        ;             If i gt 1000000 then stop

        ;       sweepno = -1   ; Dont need this as sweep no already retrieved and stored in variable 'sweep'
        ;-----------------------------------------------------------------------------------------






        ;           >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        if iverbose eq 1 and i lt 100 then begin
          typedef = ['unused','C type', 'CC type', 'PC Type', 'unused', 'Threshold', 'Housekeeping', 'Rates']  ;
          print, pkt, format = '(32(Z2.2,x))'
          print
          print, pcktid,    format =      '("Packet Id = ",I6)'
          print, sweep,     format =      '("Sweep No. = ",I6)'
          print, swstart,   format =      '("Sweep Start Time (s)    =  ",I16)'
          print, swtime,    format =      '("Sweep Time (s)          =  ",F16.4)'
          print, evtime,    format =      '("Event Time (s)          =  ",F16.4)'
          print, latitude,    format =      '("Latitude        =   ",F8.2)'
          print, longitude,   format =      '("Longitude       =   ",F8.2)'
          print, altitude,  format =      '("Altitude        =   ",F8.0)'
          print, depth,     format =      '("Depth           =   ",F8.2)'
          print, azimuth,   format =      '("Pnt Azi         =   ",F8.2)'
          print, zenith,    format =      '("Pnt Zen         =   ",F8.2)'
          print, rtang,     format =      '("Table Angle     =   ",F8.2)'
          print, rtstat,    format =      '("Table Status    =   ",I1)'
          print, livetime,  format =      '("Livetime        =   ",F8.3)'
          print, imflag,      format =          '("Mod Coinc Flag  =   ",I1)'
          print, acflag,      format =          '("Anti Coinc Flag =   ",I1)'
          print, modpos,      format =          '("Modpos(0-31)    =  ",I2)'
          print, modser,      format =          '("Mod Serial No.  =  ",I2)'
          print, livetime,    format =          '("Livetime        = ",F6.3)'
          print, ptype, typedef[ptype],format = '("Data Type       =   ",I1," (",A8,")")'
          print, nanodes,     format =        '("No. of  Anodes  =   ",I1)'
          print, npls,        format =      '("No. of plastics =   ",I1)'
          print, ncal,        format =      '("No. of cals     =   ",I1)'
          print, totnrg,    format =      '("Total Energy    =   ",F8.3)'
          print, totesig,   format =      '("Total Energy Err=   ",F6.3)'


          for j = 0,nanodes-1 do print, j+1, type[j], anode[j], pha[j], nrg[j], nrgsig[j], $
            format =  '(I1,"- Type, Anode(0-63), PHA, Energy, Energy Err    =  ", I1,"  ",I2,"  ",I4,"  ",F8.3,"  ",F7.3)

        endif


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
        ;       anodeid     BYTE(8)   List of triggered anode ids
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
        L1EVENT.LON     = float(longitude)  ; convert from DOUBLE to FLOAT
        L1EVENT.ALT     = float(altitude)   ; convert from DOUBLE to FLOAT
        L1EVENT.DEPTH   = float(depth)    ; convert from DOUBLE to FLOAT
        L1EVENT.PNTAZI    = float(azimuth)    ; convert from DOUBLE to FLOAT
        L1EVENT.PNTZEN    = float(zenith)   ; convert from DOUBLE to FLOAT
        L1EVENT.RTANG     = float(rtang)    ; convert from INT to FLOAT
        L1EVENT.RTSTAT    = rtstat
        L1EVENT.LIVETIME  = livetime
        L1EVENT.CORRECTLT = -1.0
        ;
        ;       Add event to the event array
        ;
        l1data[nevts] = l1event
        nevts = nevts + 1

      endif
      ;           =============================================================================
      If i mod 100000 EQ 0 Then print, i ;SW
      ;
      ;   Get next packet in this file...
      ;
    endfor
    ;
    ;       ==================================================================================
    ;
    ;     End of this file...
    ;
    ;   Trim the unused space allocated to the l1data structure.  This is done by
    ;   resizing the structure based on the number of events.
    ;
    l1data = l1data[0:nevts-1]
    ;
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
    ;   livetime associated with a given comes from livetimne values that are
    ;       measured 1.0 seconds later.  In most cases, this is of little consequence,
    ;   but for rapid transients (flares or GRBs), this could be important.
    ;
    ;   At the end of the file, the last 1 seconds of data takes on the livetime of the
    ;   last event.
    ;
    for i = 0, nevts-1 do begin
      im = where(module_pos eq l1data[i].modpos)
      l1data[i].correctlt = interpol( *ltable_ltime[im[0]], *ltable_evtime[im[0]],  $
        l1data[i].evtime+1.0)
    endfor

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
    print, "No. of files left   = ", Strn(nfiles-ifile-1)       ;SW
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
