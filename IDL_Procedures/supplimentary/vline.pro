pro vline,value,linestyle=linestyle,click=click, color=Color

  if !y.type eq 1 then ycrange=10.^!y.crange else ycrange=!y.crange

  if (keyword_set(click)) EQ 1 then Color='black'
  
  if (keyword_set(click)) then begin
    cursor,value,y
  endif

  if (keyword_set(linestyle)) then begin

    for i=0,n_elements(value)-1 do begin
      Cgplots,[value[i],value[i]],[ycrange],linestyle=linestyle,psym=0,Color=Color
    endfor

  endif else begin

    for i=0,n_elements(value)-1 do begin
      Cgplots,[value[i],value[i]],[ycrange], Color=Color
    endfor

  endelse

end