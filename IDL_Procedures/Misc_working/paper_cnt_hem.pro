pro paper_cnt_Hem
; hemereuy Et al Counts.

Xlow=99.00
Xhi = 101.00
result = Double(Qromb('hem_equation_neb',Xlow,Xhi))
print, result
result1 = Double(Qromb('hem_equation_pul',Xlow,Xhi))
print, result1

print, result+result1
end