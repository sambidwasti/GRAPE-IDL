Function Correct_Energy, AnodeNo, AnodeEnergy
;
;-- This is the correction or the energy Broadening code.
;  Mark emailed me this code on 3/7/2016
;  This is what Camden used to process the data
;  This code has been translated from C language.
;

; Returns the corrected energy. 
Cor_Energy = 0.0

;
;-- Get the anode Type
;
Type = Anode_Type(AnodeNo)

Seed = !Null

If Type EQ 1 Then Begin ; Calorimeter
    Sig = (0.1/2.35) * Sqrt(662.0 * AnodeEnergy)  ; Taken as 10% at 662Kev
    random_number = Randomn(Seed,1)
    Cor_Energy = random_number*Sig+AnodeEnergy
Endif else Begin
  If Type EQ 2 Then Begin
      Sig = Sqrt(0.5692+ 2.837* AnodeEnergy)  ; Taken as 10% at 662Kev
      random_number = Randomn(Seed,1)
      Cor_Energy = random_number*Sig+AnodeEnergy
  Endif Else Begin
    Print, ' ERROR : Unknown Type. it has to be plastic or calorimeter' 
    Stop
  Endelse
  
Endelse

Return, Cor_Energy

ENd