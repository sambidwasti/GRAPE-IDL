Pro Gsim_Example_quicklook, infile, E=E
;
; This is to look at the output files with 2 columns. 
; 1st is the energy and 2nd is the unit. 
; E is the incident energy in MeV

ReadCol, Infile, Temp_Ener, Temp_Unit, Format='D,A', /Silent
 If Keyword_SEt(E) Eq 0 Then E =1.0D
 
n_lines = N_Elements(Temp_Ener)
Scale = 1.0D
Counter1 = 0L ; Counter of Non Zero energies.

More_Ener_Array = [0.0D]
;n_lines-1
for i = 0, n_lines-1 Do Begin
    
    if Temp_Ener[i] eq 0.0D then Goto, Skipline
    Unit = Temp_Unit[i]
    Case Unit Of
      'eV': Scale = 1.0E-6
      'keV': Scale = 1.0E-3
      'MeV': Scale = 1.0
      'GeV': Scale = 1.0E3
      Else: Print, 'eh'
    Endcase
    Ener = Temp_Ener[i] * Scale
    
    If Ener gt E then begin
      More_ener_Array=[More_ener_Array,Ener-E]
    Endif
    
    Counter1++
    Skipline:
endfor
Temp_Counter = N_Elements(More_ener_Array)
If Temp_Counter GT 1 Then begin
More_ener_Array = More_ener_Array[1:N_Elements(More_ener_Array )-1]
Print, 'Difference '
Print, 'Max:',Strn(Max(More_Ener_Array))
Print, 'Min:', Strn(Min(More_ener_Array))
Print, 'Avg:',Strn(Avg(More_Ener_Array))
Counter2 = n_elements(More_ener_Array)
Endif Else Counter2 = 0L
Print, ' Non Zero : ', Strn(Counter1)
Print, ' Energy Above ', Strn(E), 'Mev : ',Strn(Counter2)

End