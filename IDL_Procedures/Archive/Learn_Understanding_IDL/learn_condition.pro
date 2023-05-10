
pro learn_condition, ID = ID
;-- Need revision--
;



   A = 4                                      ; Define the Variable
   B = 1      
   
   IF (A LT 3) AND (A GT 6) THEN BEGIN                     ; Starting IF Statement, Condition of Less than applied.
      PRINT, 'IF RAN'
;      GOTO, JUMP2                            ; GOTO Statement that makes a jump to JUMP2
   ENDIF ELSE BEGIN                           ; Else Statement Executed.
      PRINT, 'ELSE RAN' 
   ENDELSE
          ; ** Now Trying Else If Statement With the Value of B**
   IF B LT 4 Then Print, '1' ELSE $            ; Observe the Syntax. The $ puts the statement  in the same line. But its a if else if statement
   IF B LT 6 Then Print, '2' ELSE $            ; This has 3 choices to make from. 
   Print, '3'                                  ; So the One of these is initialized depending on value of B. 
  ;                                             ; *NOTICE* :Also if B satisfies condition first, It just executes that and comes out of the IFs.
  ; JUMP2: Print,'4'\  
  
  CASE B OF
   1:BEGIN
        Print, 'One'
        PRINT, 'one'
     END   
   2: PRINT, 'two'
   3: PRINT, 'three'
   4: PRINT, 'four'
   ELSE: PRINT, 'Not one through four'
ENDCASE

X=201
CASE 1 OF
   (X GT 0) AND (X LE 50): Print, '1st'
   (X GT 50) AND (X LE 100): Print, '2nd'
   (X LE 200): BEGIN
     Print, 'Third'
     END
ELSE: PRINT, 'Else'
ENDCASE

end