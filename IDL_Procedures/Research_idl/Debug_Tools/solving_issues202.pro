Pro solving_issues202
a = INdgen(20)

b = a[where( (a lt 10) and (a gt 5) , Count, /NULL)] 


print,count
print, a
print, b
End