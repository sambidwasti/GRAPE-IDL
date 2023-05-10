pro Grp_l2v7_flt_GenVar, fsearch_String, title=title
;
; We want to calculate the rate and live time. 
;

;
;-- Energy Selection
;
Pla_EMin = 10.0
Pla_EMax = 200.00

Cal_EMin = 40.0
Cal_EMax = 400.00

Tot_EMin = 70.00
Tot_EMax = 200.00

c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]    ; 2014 configuration

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



  ;===========
  evtfiles = FILE_SEARCH(fsearch_string)          ; get list of EVT input files
  if keyword_set(nfiles) ne 1 then nfiles = n_elements(evtfiles)

  If Keyword_Set(title) Eq 0 Then Title='Test'



;
;
;  Here we define the structure to hold the output L2 event data.
;
Struc = {                $
  VERNO:0B,            $   ; Data format version number
  QFLAG:0,             $   ; Event quality flag
  SWEEPNO:0,           $   ; Sweep Number
  SWSTART:0.0D,        $   ; Start time of sweep
  SWTIME:0.0D,         $   ; Time since start of sweep (secs)
  EVTIME:0.0D,         $   ; Event Time (secs in gps time - from 0h UT Sunday)
  TJD:0.0D,            $   ; Truncated Julian Date

  EVCLASS:0,           $   ; Event Class (1=C, 2=CC, 3=PC, 4= intermdule)
  IMFLAG:0B,           $   ; = 1 for intermodule (2 module) event
  ACFLAG:0B,           $   ; = 1 for anticoincidence

  NANODES:0B,          $   ; Number of triggered anodes (1-8)
  NPLS:0B,             $   ; Number of triggered plastic anodes
  NCAL:0B,             $   ; Number of triggered calorimeter anodes
  EVTYPE:0,            $   ; Event type (1=non-adjacent; 2=side-adjacent; 3=corner-adjacent)

  ANODEID:BYTARR(8),   $   ; Array of triggered anode numbers
  ANODETYP:BYTARR(8),  $   ; Array of triggered anode types
  ANODENRG:FLTARR(8),  $   ; Array of triggered anode energies
  ANODESIG:FLTARR(8),  $   ; Array of triggered anode energy errors


  PA_MOD:0,            $   ; Primary Anode Module Position No.
  PA_SER:0,            $   ; Primary Anode Module Serial No.
  PA_ID:0,             $   ; Primary Anode No.
  PA_NRG:0.0,          $   ; Primary Anode Energy (keV)
  PA_SIG:0.0,          $   ; Primary Anode Energy Uncertainty (keV)

  SA_MOD:0,            $   ; Secondary Anode Module Position No.
  SA_SER:0,            $   ; Secondary Anode Module Serial No.
  SA_ID:0,             $   ; Secondary Anode No.
  SA_NRG:0.0,          $   ; Secondary Anode Energy (keV)
  SA_SIG:0.0,          $   ; Secondary Anode Energy Uncertainty (keV)

  TOTNRG:0.0,          $   ; Total Event Energy (keV)
  TOTSIG:0.0,          $   ; Total Event Energy Uncertainty (keV)

  COMPANG:0.0,         $   ; Caluculated Compton Scatter Angle (deg)
  COMPSIG:0.0,         $   ; Compton Scatter Angle Uncertainty (deg)

  LAT:0.0,             $   ; Latitude (degs)
  LON:0.0,             $   ; Longitude (degs)
  ALT:0.0,             $   ; Altitude (feet)
  DEPTH:0.0,           $   ; Atm Depth (g cm^-2)
  SOURCE:0B,           $
  AIRMASS:0.0,         $
  PNTAZI:0.0,          $   ; Pointing Azimuth (degs)
  PNTZEN:0.0,          $   ; Pointing Zenith (degs)
  SRCAZI:0.0,          $
  SRCZEN:0.0,          $
  SRCOFF:0.0,          $

  RTANG:0.0,           $   ; Rotation Table Angle (degs)
  RTSTAT:0B,           $   ; Rotation Table Status
  SCTANG:0.0,          $   ; Scatter Angle in instrument coords (degs)
  PVANG:0.0,           $   ; Scatter Angle in pressure vessel coords (degs)
  PPVANG:0.0,          $   ; Scatter Angle in projected PV coords (degs)
  HRANG:0.0,           $   ; Hour Angle (degs)
  PARANG:0.0,          $   ; Paralactic Angle (degs)
  POSANG:0.0,          $   ; Position angle of the scatter vector (deg)

  LIVETIME:0.0,        $
  CORRECTLT:0.0        $
}
;Total 248 Bytes
Packet_Len = 248 ; In Bytes


Counting_Array = DblArr(nfiles)
LTArray        = DblArr(nfiles)
Sweep_array    = LonArr(nfiles)
Altitude        = dblArr(nfiles)

For p = 0, nfiles-1 Do Begin ; open each file
  ;-- No. of Events Counter --
  ;
  No_Events = 0L

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

  ;
  ;--- Grab total no. of packets
  ;
  TotPkt = long(f.size/Packet_Len)

  ;
  ;--- Replicate the structure for each packets.
  ;
  Event_data = replicate(Struc, TotPkt)
  ;
  ;---- Grab all the event data all at once.----
  ;
  For i = 0, TotPkt-1 Do Begin
    readu, lun, Struc        ; read one event
    Event_data[i] =Struc        ; add it to input array
  EndFor
  
  ;
  ;--- Free Lun ----
  ;
  Free_Lun, lun
  
Counting_Array[p] = TotPkt
LTArray[p]      = Avg(Event_data.CorrectLt)
Sweep_array[p]    = Fix(Avg(Event_data.sweepno))
Altitude[p]            = Avg(Event_data.alt)
  
  
EndFor

Openw, Lun1, title+'Grpl2v7_GenVar.txt' , /Get_lun

for i = 0,nfiles-1 do begin
printf, lun1, Sweep_array[i], LTArray[i], Counting_array[i], Altitude[i]
endfor

free_lun, lun1
window,1
CgPlot, Sweep_array, LTArray
Window,2
Cgplot, sweep_array, Counting_Array

End