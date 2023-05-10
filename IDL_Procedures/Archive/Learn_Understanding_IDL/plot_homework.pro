; Procedure to Plot for Class Homeworks..
; Create a plot in the Desktop.
Pro Plot_Homework
;        Output_File = '/Users/sam/Desktop/Homework_Plot.ps'
;        X= FindGEN(100)
;        T = 5
;        a = 1
;        Y= T/(X-a) - a/x^2 
;        C=['Red','Blue','Green','Black']
        
;        Set_Plot, 'PS'
;        loadct, 13                           ; load color
;        Device, File = Output_File, /COLOR,/Portrait
;        Device, /inches, xsize = 7.0, ysize = 9.0, xoffset = 0.75, yoffset = 1.0, font_size = 9, scale_factor = 1.0
;                Plot, X, Y, XRANGE=[0,100], XSTYLE=1, XTitle='Rate', YTitle ='S/N', Title='S/N vs Rate';, PSYM=2;, YRANGE=[0,0.3]
;        Device,/Close
;        Set_Plot, 'X

A=0.01217
B=0.955
x1=6*2*!Pi
x2=5*2*!PI
Y11= (x1-A)*Sqrt((x1-A)*(x1-A)+1)/2
Y12= (x2-A)*Sqrt((x2-A)*(x2-A)+1)/2
y21= (x1-A)+Sqrt((x1-A)*(x1-A)+1)
Y22= (x2-A)+Sqrt((x2-A)*(x2-A)+1)
print, Y11,Y12, Y11-Y12
Print, Y21/Y22

End