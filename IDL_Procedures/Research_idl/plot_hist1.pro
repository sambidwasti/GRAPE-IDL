Pro Plot_Hist1, File1, Title=Title, Log=Log
  ;
  ;--- Purpose is to quicklook plot a histogram from a one column  file.
  ;-- Log = Log function. Not Set yet.
  ;-- Title for the output.
  ;-- Need a fitting function too
  ;-- Bin system.
  ;
  True = 1
  False = 0
  LogFlag = 0
  IF Keyword_Set(Log) NE 0 Then LogFlag=1
  IF Keyword_Set(Title) eq 0 Then Title= 'Try'
  CD, Cur = Cur

  ; Might change the file type keyword to make this dynamic
  ;ReadCol, File1, Xmin, Xmax, Y, YErr
  ; Right nwo we need to read a file with 1 column

  R = [0.0D]
  T = [0.0D]
  P = [0.0D]

  Mo1 = [0.0D]
  Mo2 = [0.0D]
  Mo3 = [0.0D]
  
  Mc1 = [0.0D]
  Mc2 = [0.0D]
  Mc3 = [0.0D]
  
  X1 = [0.0D]
  Y1 = [0.0D]
  Z1 = [0.0D]

  c =0L
  openr, lun1, file1, /Get_lun
    While Not EOF(lun1) do begin
    data =''
    readf, lun1, data

          Pos0 = strpos(data,',',0)
          data1 = strmid(data,1,pos0-1)
          X = Double(data1)
          
          Pos1 = strpos(data,',',Pos0+1)
          data1 = strmid(data,Pos0+1,pos1-Pos0-1)
          Y = Double(data1)
          
          Pos2 = strpos(data,')',Pos1+1)
          data1 = strmid(data,Pos1+1,pos2-Pos1-1)
          Z = Double(data1)          
          
          Pos3 = StrPos(data,',',Pos2)
          data1 = strmid(data,Pos2+2,pos3-Pos2-2)
          M1 = Double(data1)
      
          Pos4 = strpos(data,',',Pos3+1)
          data1 = strmid(data,Pos3+1,pos4-Pos3-1)
          M2 = Double(data1)

          Pos5 = strpos(data,')',Pos4+1)
          data1 = strmid(data,Pos4+1,pos5-Pos4-1)
          M3 = Double(data1)

      ;    Mc1 = [Mc1, M1]
      ;    Mc2 = [Mc2, M2]
       ;   Mc3 = [Mc3, M3]          

          X1 = [X1, X]
          Y1 = [Y1, Y]
          Z1 = [Z1, Z]
                    
          rect_cord=[X,Y,Z]
          pol_cord = CV_COORD(FROM_RECT=rect_cord, /TO_SPHERE, /Degrees, /Double)
          
        ;  rect_cord1 = [M1,M2,M3]
        ;  pol_cord1= CV_COORD(FROM_RECT=rect_cord1, /TO_SPHERE, /Degrees, /Double)
          

         ; r1 = Sqrt(x*X+ y*y+Z*Z) 
          R = [R,pol_cord[2]]
          T = [T, pol_cord[1]]
          P = [P, pol_cord[0]]
          
          

          
     ;     Mo1 = [Mo1, pol_cord1[2]]
      ;     Mo2 = [Mo2, pol_cord1[1]]
         ;   Mo3 = [Mo3, pol_cord1[0]]
            


    EndWhile
      Free_lun, lun1
  R = R[1:N_Elements(R)-1]
 
    T = T[1:N_Elements(T)-1]
       P = P[1:N_Elements(P)-1]

;Mo1 = Mo1[1:N_Elements(Mo1)-1]
 ; Mo2 = Mo2[1:N_Elements(Mo2)-1]
   ; Mo3 = Mo3[1:N_Elements(Mo3)-1]
    T2 = 90-T
   Window,0
   CGScatter2D,P, T2 , Fit=0, XRange=[-180,180],YRANGE=[0,180], Ytitle='Theta', XTitle='Phi',YTickInterval=20
  
    T1 = Double(T2*!CONST.DToR)
    T3 = Cos(T1)
    window,2
    CgScatter2D, P, T3, Fit=0, XRange=[-180,180],YRANGE=[-1,1], Ytitle='Cos (Theta)', XTitle='Phi'
  ;  window, 3
  ;  CgScatter2D, X1, Y1, Fit=0, Title='XY'
  ; Window, 4
   ; CgScatter2D, Y1, Z1, Fit=0, Title='YZ'
    ;Window, 5
   ; CgScatter2D, X1, Z1, Fit=0, Title='ZX'
    
;Window,1
;Result = hist_2d(P,T3,bin1=45,bin2=0.5,MAX1=180,MIN1=-180,MAX2=1.0,MIN2=-1.0)

;help, result
;cgplot, Result, PSYM=10

;c=0
;for i = 0,n_elements(T)-1 Do begin
;      if (T[i] GE -1.0) and (T[i] LE -0.5 ) Then begin
;            If (P[i] GE -180.0) and (P[i] LE -160.0 ) Then begin
;               C++
;            Endif
;      endif
;endfor
rect_cord2 = [10.0,00.0,0.0]
pol_cord2 = CV_COORD(FROM_RECT=rect_cord2, /TO_SPHERE, /Degrees, /Double)
print, pol_cord2
;Print, C
Stop


End