Function Grp_GetID, Cord
  ;
  ; Created to get the Anode ID in a module from the co-ordinates
  ; This is for the simulation file but not limited to it.
  ;
  ; The Anode name in Mega Lib is not necessary important as that is just
  ; to add an anode element rather than naming them correct. However,
  ; We need to correct it here.
  ;
  ; Want to Return a value from 0~63
  ; Return -1 for invalid
  ; Return -2 for off-center event.. ?
  ;

  ;
  ;-- Description of the geometry of the modules --
  ; - there are 64 anodes.
  ; - 8 X 8 matrix
  ; - Each is 5mm X 5mm X 5cm in volume
  ; - We are only interested in XY ( 5mm X 5mm ).
  ; - The separation is 1.08mm
  ; - With 0,0 being the origin, these are the location in XY,
  ; - 2.128, 1.520, 0.912, 0.304 and the symmetric negative of these
  ; - These were retrieved from Mark's program to get co-ordinates form Anode via AnodeXY
  ; - xa|ya =( 3.5 - ia|ja) * 0.608
  ; - For anode 0, this results in 2.128 and -2.128
  xa = Cord[0]
  ya = Cord[1]

  ia = 3.5 - (xa /0.608)
  ja = 3.5 - (ya /0.608)

  ; the ia and ja are the no. for X x Y array in the 8 X 8 array.
  ; We need to set up so that 2.128, -2.128 is 0

  Y = FIX((7 - ja) * 8)
  X = FIX(ia)

  Anode = Y + X
  Return, Anode

End