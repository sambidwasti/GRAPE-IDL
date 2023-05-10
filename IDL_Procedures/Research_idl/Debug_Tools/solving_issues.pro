Pro Solving_Issues;, fsearch_String

a = [1,2,3,4,5,6,7,8,9]
b =  LonARR(9,9)
for i = 0,8 do begin
  b[i,*] = a
endfor

Print,b
;


;openw, 1, 'solving_issues.txt'
;printf, 1,b , format = '(8( I1, ";"),I1)'
;free_lun, 1
;Print, b
end
