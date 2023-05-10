function Grp_Anode_Separation, Anode1, Anode2
; Function created to read in two anodes and return the separation between them.
; 0~63
; Grape module of 8 x 8 array.

; Returns -1 if same
; 0 if its the adjacent.. so forth.
; No. of anodes between = Sep + 1
; Returns -1~6 value. 
; 
Sep = -1;
If (anode1 GT 63) or (anode1 lt 0) or (anode2 gt 63) or (anode2 lt 0) Then begin
      Print, 'INVALID Anode ID (Need 0~63) '
      Stop
Endif

If anode1 eq anode2 then goto,return_Sep

an1_row = fix(anode1/8)
an1_col = anode1 mod 8
;print, an1_row, an1_col

an2_row =fix(anode2/8)
an2_col = anode2 mod 8
;print, an2_row, an2_col

diff_row = abs(an1_row-an2_Row)
diff_col = abs(an1_col-an2_Col)

if diff_row gt diff_col then sep=diff_row else sep=diff_Col
sep = sep-1

;print, 'rowsep:',diff_row,  'colsep:',diff_Col

;Anode1 mod 8 

Return_Sep:
Return, Sep



End