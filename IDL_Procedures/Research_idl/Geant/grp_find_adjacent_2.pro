function Grp_find_Adjacent_2, Anode
  ;
  ;-- Creating a function to get the adjacent andoes.
  ; Updated Version.
  ; This one does find adjacent anodes P to C.
  ; 
  ;

  ;NOTE: CUrrently only C-C and P-P P-C

  ;-- Returns 2 arrays. one with the adjacent anodes and the other
  ;   whether it is the side-adjacent or the corner-adjacent
  ;   Types = 2 for side adjacent, 3 for corner adjacent of the same type
  ;   For different type we are goign to define 4,5
  ;         4 side from P to C
  ;         5 corner from P to C
  ;   and 6,7
  ;
  Anode_Array=[0]
  Anode_Type_Array=[0]

  ; -- Work on this case wise --
  ;For calorimeter

  If Anode_Type(Anode) Eq 1 THen Begin

    Case Anode Of
      0: Begin    ;Corner1.
        Anode_Array       = [1,8]
        Anode_Type_Array  = [2,2]
      End
      7: Begin    ;Corner2
        Anode_Array       = [6,15]
        Anode_Type_Array  = [2,2]
      End
      56: Begin    ;Corner3
        Anode_Array       = [48,57]
        Anode_Type_Array  = [2,2]
      End
      63: Begin    ;Corner 4
        Anode_Array       = [55,62]
        Anode_Type_Array  = [2,2]
      End
      1: Begin ; Next to corners, 3 adjacent.
        Anode_Array       = [0,2,8]
        Anode_Type_Array  = [2,2,3]
      End
      8: Begin ; Next to corners, 3 adjacent.
        Anode_Array       = [0,16,1]
        Anode_Type_Array  = [2,2,3]
      End
      6: Begin ; Next to corners, 3 adjacent.
        Anode_Array       = [5,7,15]
        Anode_Type_Array  = [2,2,3]
      End
      15: Begin ; Next to corners, 3 adjacent.
        Anode_Array       = [7,23,6]
        Anode_Type_Array  = [2,2,3]
      End
      48: Begin ; Next to corners, 3 adjacent.
        Anode_Array       = [40,56,57]
        Anode_Type_Array  = [2,2,3]
      End
      57: Begin ; Next to corners, 3 adjacent.
        Anode_Array       = [56,58,48]
        Anode_Type_Array  = [2,2,3]
      End
      55: Begin ; Next to corners, 3 adjacent.
        Anode_Array       = [47,63,62]
        Anode_Type_Array  = [2,2,3]
      End
      62: Begin ; Next to corners, 3 adjacent.
        Anode_Array       = [61,63,55]
        Anode_Type_Array  = [2,2,3]
      End
      16: Begin ; +/-8
        Anode_Array = [Anode-8,Anode+8]
        Anode_Type_Array  = [2,2]
      End
      24: Begin ; +/-8
        Anode_Array = [Anode-8,Anode+8]
        Anode_Type_Array  = [2,2]
      End
      32: Begin ; +/-8
        Anode_Array = [Anode-8,Anode+8]
        Anode_Type_Array  = [2,2]
      End
      40: Begin ; +/-8
        Anode_Array = [Anode-8,Anode+8]
        Anode_Type_Array  = [2,2]
      End
      23: Begin ; +/-8
        Anode_Array = [Anode-8,Anode+8]
        Anode_Type_Array  = [2,2]
      End
      31: Begin ; +/-8
        Anode_Array = [Anode-8,Anode+8]
        Anode_Type_Array  = [2,2]
      End
      39: Begin ; +/-8
        Anode_Array = [Anode-8,Anode+8]
        Anode_Type_Array  = [2,2]
      End
      47: Begin ; +/-8
        Anode_Array = [Anode-8,Anode+8]
        Anode_Type_Array  = [2,2]
      End
      Else: Begin
        Anode_Array       = [Anode-1, ANode+1]
        Anode_Type_Array  = [2,2]

      End
    Endcase

  EndIF Else If Anode_Type(Anode) Eq 2 Then Begin   ; Now for the Plastics.

    Case Anode Of
      9: Begin    ;Corner1.
        Anode_Array       = [10,17,18,16,8,0,1,2]
        Anode_Type_Array  = [ 2, 2, 3, 5,4,5,4,5]
      End
      14: Begin    ;Corner2
        Anode_Array       = [13,22,21,23,15,7,6,5]
        Anode_Type_Array  = [ 2, 2, 3, 5, 4,5,4,5]
      End
      49: Begin    ;Corner2
        Anode_Array       = [41,50,42,40,48,56,57,58]
        Anode_Type_Array  = [ 2, 2, 3, 5, 4, 5, 4, 5]
      End
      54: Begin    ;Corner2
        Anode_Array       = [53,46,45,47,55,63,62,61]
        Anode_Type_Array  = [ 2, 2, 3, 5, 4, 5, 4, 5]
      End
      10: Begin ; Next to corners, 5 adjacent.
        Anode_Array       = [Anode-1,ANode+1,ANode+8,ANode+7,ANode+9,Anode-9,Anode-8,Anode-7]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      11: Begin ; Next 5 adjacent.
        Anode_Array       =[Anode-1,ANode+1,ANode+8,ANode+7,ANode+9,Anode-9,Anode-8,Anode-7]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      12: Begin ; Next 5 adjacent.
        Anode_Array       =[Anode-1,ANode+1,ANode+8,ANode+7,ANode+9,Anode-9,Anode-8,Anode-7]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      13: Begin ; Next 5 adjacent.
        Anode_Array       =[Anode-1,ANode+1,ANode+8,ANode+7,ANode+9,Anode-9,Anode-8,Anode-7]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      17: Begin ; Next to corners, 5 adjacent.
        Anode_Array       =[Anode-8,ANode+8,ANode+1,ANode-7,ANode+9,Anode-9,Anode-1,Anode+7]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      25: Begin ; 5 adjacent.
        Anode_Array       =[Anode-8,ANode+8,ANode+1,ANode-7,ANode+9,Anode-9,Anode-1,Anode+7]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      33: Begin ; 5 adjacent.
        Anode_Array       =[Anode-8,ANode+8,ANode+1,ANode-7,ANode+9,Anode-9,Anode-1,Anode+7]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      41: Begin ; 5 adjacent.
        Anode_Array       =[Anode-8,ANode+8,ANode+1,ANode-7,ANode+9,Anode-9,Anode-1,Anode+7]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      22: Begin ; Corner 5 adjacent.
        Anode_Array       =[Anode-1,ANode+8,ANode-8,ANode-9,ANode+7,Anode-7,Anode+1,Anode+9]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      30: Begin ; Corner 5 adjacent.
        Anode_Array       =[Anode-1,ANode+8,ANode-8,ANode-9,ANode+7,Anode-7,Anode+1,Anode+9]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      38: Begin ; Corner 5 adjacent.
        Anode_Array       =[Anode-1,ANode+8,ANode-8,ANode-9,ANode+7,Anode-7,Anode+1,Anode+9]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      46: Begin ; Corner 5 adjacent.
        Anode_Array       =[Anode-1,ANode+8,ANode-8,ANode-9,ANode+7,Anode-7,Anode+1,Anode+9]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      50: Begin ; Corner 5 adjacent.
        Anode_Array       =[Anode-1,ANode+1,ANode-8,ANode-9,ANode-7,Anode+7,Anode+8,Anode+9]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      51: Begin ; Corner 5 adjacent.
        Anode_Array       =[Anode-1,ANode+1,ANode-8,ANode-9,ANode-7,Anode+7,Anode+8,Anode+9]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      52: Begin ; Corner 5 adjacent.
        Anode_Array       =[Anode-1,ANode+1,ANode-8,ANode-9,ANode-7,Anode+7,Anode+8,Anode+9]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      53: Begin ; Corner 5 adjacent.
        Anode_Array       =[Anode-1,ANode+1,ANode-8,ANode-9,ANode-7,Anode+7,Anode+8,Anode+9]
        Anode_Type_Array  = [2,2,2,3,3,5,4,5]
      End
      Else: Begin
        Anode_Array       = [Anode-1, ANode+1,Anode+8,Anode-8,Anode+7,Anode-7,ANode+9,ANode-9]
        Anode_Type_Array  = [2,2,2,2,3,3,3,3]

      End
    Endcase



  Endif

  Return_Array = [ANode_Array,Anode_Type_Array]

  Return,Return_Array
End