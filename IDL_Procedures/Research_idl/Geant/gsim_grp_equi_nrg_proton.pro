Function Gsim_Grp_Equi_Nrg_Proton, Ener
  ;
  ; This is for Electron Equivalent of the Proton energy
  ; Note that the plot is in MeV but the input Energy(Ener) is in kEV.
  ; Can either change the input or the plot.
  ; For the Plastic Scintillator
  ; Ej204 ~ NE404 ~ BC404

  ;
  ;Proton Plot
  ;
  Proton_Light_Yield = [0,0.09,0.21,0.33,0.46,0.60,0.74,0.87]
  Proton_Energy_MEV  = [0.0D,20.0D  ,40.0D  ,60.0D  ,  80.0D,100.0D ,120.0D ,140.0D ]
  Proton_Energy_KEV  =  Proton_Energy_MEV*1000.0D

  ;
  ; Electron Plot
  ;
  Electron_Light_Yield = [0,0.15,0.30,0.44,0.59,0.73,0.88]
  Electron_Energy_MEV  = [0.0D, 20.0D , 40.0D , 60.0D , 80.0D , 100.0D, 120.0D]
  Electron_Energy_KEV  =   Electron_Energy_MEV* 1000.0D

  ; So for a given proton energy x, we find the relevant light output.
  ; The energy is given from Ener
  ; And y is the equivalent light output

  Y = Interpol(Proton_Light_Yield, Proton_Energy_KEV, Ener,/Quadratic)

  ;
  ;Now this Y is light yield for proton
  ;For this light yield, we want the equivalent electron energy.
  ;Let that be X
  ;

  Electron_Equiv_Energy = Interpol( Electron_Energy_KEV, Electron_Light_Yield, Y,/Quadratic)

  Return,Electron_Equiv_Energy ; Outputting in KeV.

  ;Now for this Y is the proton light output.
  ; Now find the equivalent electron energy.

end