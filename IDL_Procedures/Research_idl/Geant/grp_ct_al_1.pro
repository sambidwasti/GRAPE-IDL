function Grp_CT_Al_1, Anode, Energy, Flag=Flag, Per=Per
  ;
  ;-- Version 1.b --
  ;15% on side and 3% on corner
  ;-- This is a procedure/Algorithm/Technique to include the Crosstalk.
  ;This is temporary that does variable.
  ;

  ;
  ;-- Notes --
  ;
  ;- Should Return the array with at most 9 (adjacent) anodes and 9 ids.
  ;- So one array which is devided in half as the return only can does 1 variable.
  ;
  ;September 8, 2016 S.Wasti
  ; Added the Adj_Type to the return. WHich was included in further iteration of algorithm.
  ;   in algorithm 3/4..
  ; 
  ;

  ;
  ;== Function Parameters==
  ;
  if keyword_set(Per) ne 1 then per = 0
  side_adj = double(per)/100.00; Side Adjacent %
  corn_adj = 0.2* side_adj  ; Corner Adjacent %

  ;
  ;-- Get teh type of anode. 1=C, 2=P, -1=Invalid.
  ;
  AnType = Anode_Type(Anode)
  If AnType EQ -1 THen Begin
    PRINT, 'INVALID ANode NO.'
    Stop
  Endif

  ;-- Just focusing on the plastic cross-talk right now.

  ;-- We need to find a list of adjacent-anodes --
  ;-- Created a function that returns it. Grp_Find_Adjacent.
  ;NOTE* Currently only does a PP andjacent and CC andjaccents.

  ;
  ;-- This has both the adjacent and types. (type 2 =side , type 3 = corner)
  temp_ar = Grp_Find_Adjacent_1(Anode)

  ;
  ;-- Separate these into two arrays
  Len = N_Elements(temp_ar)/2
  Adj_anodes = temp_ar[0:Len-1]
  Adj_types  = temp_ar[len:N_elements(Temp_ar)-1]


  ;
  ; -- Distribute the energy
  Energy_Array = FltARr(Len)
  For i =0,Len-1 Do Begin
    If Adj_types(i) Eq 2 Then Energy_Array[i] = side_adj*Energy Else If Adj_types(i) Eq 3 Then Energy_Array[i] = corn_adj*Energy
  Endfor

  ;
  ;-- Combine the energy and anodes to 1 array.
  ;
  Final_array = [Double(Adj_Anodes),Energy_Array,Adj_types]
  return, Final_Array
End