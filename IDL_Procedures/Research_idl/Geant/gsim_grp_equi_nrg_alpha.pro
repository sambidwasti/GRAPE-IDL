Function Gsim_Grp_Equi_Nrg_Alpha, Ener
  ;
  ; This is for Electron Equivalent of the Alpha or Heavier ions.
  ; Note that the plot is in MeV but the input Energy(Ener) is in kEV.
  ; Can either change the input or the plot.
  ; For the Plastic Scintillator
  ; Ej204 ~ NE404 ~ BC404

  ;
  ;Proton Plot
  ;
  Alpha_Light_Yield = [0,0.02,0.08,0.13,0.20,0.27,0.35,0.445,0.54]
  Alpha_Energy_MEV  = [0.0D,20.0D  ,40.0D  ,60.0D  ,  80.0D,100.0D ,120.0D ,140.0D, 160.0D ]
  Alpha_Energy_KEV  =  Alpha_Energy_MEV*1000.0D

  ;
  ; Electron Plot
  ;
  Electron_Light_Yield = [0,0.15,0.30,0.44,0.59,0.73,0.88]
  Electron_Energy_MEV  = [0.0D, 20.0D , 40.0D , 60.0D , 80.0D , 100.0D, 120.0D]
  Electron_Energy_KEV  =   Electron_Energy_MEV* 1000.0D

  ; So for a given alpha energy x, we find the relevant light output.
  ; The energy is given from Ener
  ; And y is the equivalent light output

  Y = Interpol(Alpha_Light_Yield, Alpha_Energy_KEV, Ener,/Quadratic)

  ;
  ;Now this Y is light yield for proton
  ;For this light yield, we want the equivalent electron energy.
  ;Let that be X
  ;

  Electron_Equiv_Energy = Interpol( Electron_Energy_KEV, Electron_Light_Yield, Y,/Quadratic)

  Return,Electron_Equiv_Energy ; Outputting in KeV.

  ;Now for this Y is the alpha light output.
  ; Now find the equivalent electron energy.

end