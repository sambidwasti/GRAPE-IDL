Pro Grp_l1v7_ground_quicklook, fsearch_String, nfiles=nfiles, title= title
  ;
  ; Reading in Level 1 version 7 data.
  ; Do some energy selection and some calculation to do per sweep stuff.
  ; Creating hardware upper and lower limit files.
  ;
  ; Feb 21, Wastisk: Statistics file.
  ; some output format needs updated.
  ;

  ;-- Get the array of event files.
  Evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files

  ;-- Total no. of files --
  If keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)

  ;-- Title --
  IF Keyword_Set(title) Eq 0 Then Title='Test'

  ;-- Current Directory --
  CD, Cur = Cur
  
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
    
    QUALITY:0,            $     ; Quality Flag
      
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
Packet_Len = 179

  ;
  ;--- Average out every minute.
  ;
    window,0

  For p = 0, nfiles-1 Do Begin
    ;
    ;---- Each file
    ;
    fname = evtfiles[p]
    print, fname

    ;
    ;--- Grab some file info
    ;
    f = file_info(fname)

    ;
    ;--- Open the binary file and dump it in Data and Close the file.
    ;
    Openr, lun, fname, /GET_Lun

    ;--- Grab total no. of packets
    TotPkt = long(f.size/Packet_Len)

    ;--- Replicate the structure for each packets.
    Event_data = replicate(l1event, TotPkt)

    ;---- Grab all the event data all at once.----
    For i = 0, TotPkt-1 Do Begin
      readu, lun, l1event        ; read one event
      Event_data[i] =l1event        ; add it to input array
    EndFor

    ;
    ;--- Free Lun ----
    ;
    Free_Lun, lun


    For i = 0, TotPkt-1 Do Begin
      Skip_Packet:
    EndFor
    nvali=0000
nvalm=10000
  CgPlot, Event_data[nvali:nvalm].rtang
  CgOPlot, Event_data[nvali:nvalm].rtstat
    Window,2
  CGplot, Event_Data[nvali:nvalm].swtime
  Help, Event_data.EvTime
  
  Print, Min(Event_Data.Evtime)
  Print, MAx(Event_Data.evtime)
  PRint,  MAx(Event_Data.evtime)-Min(Event_Data.Evtime)


  Print, min(Event_Data.Swtime)
  PRint, Max(Event_data.swtime)
  PRint, Max(Event_data.swtime)-min(Event_Data.Swtime)
  
  PRint, event_data[0].swtime
  Print, event_data[0].rtang
 
  ;CgPlot, Event_data.Evtime , yrange=[Min(Event_Data.Evtime)*0.9999,MAx(Event_Data.evtime)*1.0001],ystyle=1
  EndFor ; p



  Stop
End