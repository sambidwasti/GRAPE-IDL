Function Grp_Sim_Anode_Map, Sim_Anode
;
; This procedure is created to map the simulated anode with the flight anodes. 
;
Case sim_anode of
  0: ins_anode = 7
  1: ins_anode = 15
  2: ins_anode = 23
  3: ins_anode = 31
  4: ins_anode = 39
  5: ins_anode = 47
  6: ins_anode = 55
  7: ins_anode = 63
  
  8: ins_anode = 6
  9: ins_anode = 14
  10: ins_anode = 22
  11: ins_anode = 30
  12: ins_anode = 38
  13: ins_anode = 46
  14: ins_anode = 54
  15: ins_anode = 62
  
  16: ins_anode = 5
  17: ins_anode = 13
  18: ins_anode = 21
  19: ins_anode = 29
  20: ins_anode = 37
  21: ins_anode = 45
  22: ins_anode = 53
  23: ins_anode = 61
  
  24: ins_anode = 4
  25: ins_anode = 12
  26: ins_anode = 20
  27: ins_anode = 28
  28: ins_anode = 36
  29: ins_anode = 44
  30: ins_anode = 52
  31: ins_anode = 60
  
  32: ins_anode = 3
  33: ins_anode = 11
  34: ins_anode = 19
  35: ins_anode = 27
  36: ins_anode = 35
  37: ins_anode = 43
  38: ins_anode = 51
  39: ins_anode = 59
  
  40: ins_anode = 2
  41: ins_anode = 10
  42: ins_anode = 18
  43: ins_anode = 26
  44: ins_anode = 34
  45: ins_anode = 42
  46: ins_anode = 50
  47: ins_anode = 58
  
  48: ins_anode = 1
  49: ins_anode = 9
  50: ins_anode = 17
  51: ins_anode = 25
  52: ins_anode = 33
  53: ins_anode = 41
  54: ins_anode = 49
  55: ins_anode = 57

  56: ins_anode = 0
  57: ins_anode = 8
  58: ins_anode = 16
  59: ins_anode = 24
  60: ins_anode = 32
  61: ins_anode = 40
  62: ins_anode = 48
  63: ins_anode = 56
  else: ins_anode = -1
Endcase
return, ins_anode
End