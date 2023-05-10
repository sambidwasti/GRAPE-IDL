Function XSPEC_tool_HeadSrch, Header, Term
;
; This is created to search the header array and extract a term.
;
val = ''

HeadLen = N_Elements(HEader)

TPos=0
For k = 0, Headlen-1 do begin
 data= HEader[k]
  TPos1=StrPos(data,'=',TPos)
  
  TStr = StrCompress(  Strmid(data, Tpos, Tpos1-Tpos))
  IF Tstr eq Term then begin
 ;   Print, data
      Tpos1 = StrPos(data,"'", Tpos)
      TPos2 = StrPos(data,"'", Tpos1+1)
     val=StrCompress(Strmid(data, Tpos1+1, Tpos2-(Tpos1+1)))
    
  ENDIF
  
  
Endfor


Return, val
End