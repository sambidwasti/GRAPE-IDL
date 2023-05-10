Pro Extra_Stuff1

Seed = 1232141234


a = 0L
X = 0L
Y = 0L
XArr = X
YArr = Y
back = 5

while a LT 100000 Do Begin
      d = Fix(randomu(seed)*4)
      
      ; Preventing backspace.
      If d NE back then begin
  ;      print, d
              Case d of
              0 : Begin 
                XArr = [XArr,X+1]
                YArr = [YArr,Y]
                X = X+1
                back = 1
              End
              1 : Begin
                XArr = [XArr,X-1]
                YArr = [YArr,Y]
                X = X-1
                back = 0
              End  
              2 : Begin
                XArr = [XArr,X]
                YArr = [YArr,Y+1]
                Y = Y+1
                back = 3
              End
              3 : Begin
                XArr = [XArr,X]
                YArr = [YArr,Y-1]
                Y = Y-1
                back = 2
              End
              Else: print, 'INVALID'
              Endcase
     
              Plot, XArr, YArr
             
              
              a++
              if a mod 1000 Eq 0 then print,a
    ;          Print, X, Y
  ;            Cursor, X1, Y1, /DOWN, /DEVICE
      EndIF
endwhile

Stop

ENd