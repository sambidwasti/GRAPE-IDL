function Grp_CT_Al_5, Anode, Energy, Flag=Flag,  Per=Per, CorPer=CorPer
  ;
  ;-- Version 2.0 --
  ;-- This is a procedure/Algorithm/Technique to include the Crosstalk.
  ;

  ;
  ;-- Notes --
  ;
  ;- Should Return the array with at most 9 (adjacent) anodes  and 9 ids and 9 id type
  ;- So one array which is devided in 3 as the return only can does 1 variable.
  ;Also with the efficiency, returning the anode type is crucial too.

  ;
  ; Does P-P, P-C and C-C, C-P Cross-talk
  ; the adjacent returns 2,3 4,5
  ;

  ;
  ;   The Flag contains the P-C events to be ignored or not.
  ;
  ;   Assumptions:
  ;   1) The light is isotropically cross-talked to adjacent anodes.
  ;   2) The isotropic % is the same.
  ;   3) The P-C cross-talk is feasible in this model.
  ;   4) Light ratio is 104P = 540C (photons)
  ;


  ;
  ;== Function Parameters==
  ;Cross-talk percent ~ light output ~ energy
  ;
  if keyword_set(Per) ne 1 then per = 0
    if keyword_set(CorPer) ne 1 then Corper = 0
    
  side_adj = double(per)/100.00; Side Adjacent %
  corn_adj = double(CorPer)/100.00  ; Corner Adjacent %

  ;
  ;== Light Ratio ==
  ;
  LR_PtoC = 104.0/540.0
  LR_CtoP = 540.0/104.0

  ;
  ;-- Get the type of anode. 1=C, 2=P, -1=Invalid.
  ;
  AnType = Anode_Type(Anode)
  If AnType EQ -1 THen Begin
    Print, Anode, '**'
    PRINT, 'INVALID ANode NO.'

    Stop
  Endif

  ;
  ;-- This has both the adjacent and types. (type 2 =side , type 3 = corner)
  ;
  temp_ar = Grp_Find_Adjacent_4(Anode)

  ;
  ;-- Separate these into two arrays
  ;
  Len = N_Elements(temp_ar)/2
  Adj_anodes = temp_ar[0:Len-1]
  Adj_types  = temp_ar[len:N_elements(Temp_ar)-1]


  ;
  ; -- Distribute the energy
  ;
  Energy_Array = FltARr(Len)

  For i =0,Len-1 Do Begin
    Type = Adj_types[i]

    Case Type of
      2: Energy_Array[i] = side_adj*Energy              ; Side of Same Scintillator type.
      3: Energy_Array[i] = corn_adj*Energy              ; Corner of Same Scintillator type.
      4: Energy_Array[i] = LR_PtoC*side_adj*Energy      ; side of pla to C Scintillator type.
      5: Energy_Array[i] = LR_PtoC*corn_adj*Energy      ; Corner of pla to C Scintillator type.
      6: Energy_Array[i] = LR_CtoP*side_adj*Energy      ; side of C to P Scintillator type.
      7: Energy_Array[i] = LR_CtoP*corn_adj*Energy      ; Corner of C to P Scintillator type.
      Else: Energy_Array[i] =0.0                        ; Corner of Same Scintillator type.
    Endcase
  Endfor

  ;
  ;-- Combine the energy and anodes to 1 array.
  ;
  Final_array = [Double(Adj_Anodes),Energy_Array,Double(Adj_Types)]

  return, Final_Array
End