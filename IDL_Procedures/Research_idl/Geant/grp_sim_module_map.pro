Function Grp_Sim_Module_Map, Module
; Reads in simulated Module no and outputs ins_module no. 
; SIm modules 0-23
; out is from 0-31 with few gaps

; There is no way other than multiple case statement.

Case module of
    0: ins_module = 19
    1: ins_module = 2
    
    2: ins_module = 22
    3: ins_module = 20
    4: ins_module = 17
    5: ins_module = 6
    6: ins_module = 3
    7: ins_module = 0
    
    8: ins_module = 21
    9: ins_module = 18
    10:ins_module = 7
    11:ins_module = 4
    
    12:ins_module = 27
    13:ins_module = 24
    14:ins_module = 13
    15:ins_module = 10
    
    16:ins_module = 31
    17:ins_module = 28
    18:ins_module = 25
    19:ins_module = 14
    20:ins_module = 11
    21:ins_module = 9
    
    22:ins_module = 29
    23:ins_module = 12
    else: ins_module = -1
Endcase
return, ins_module
End