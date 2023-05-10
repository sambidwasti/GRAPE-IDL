Pro Learn_Plot
; Learn an Understand plotting and creating post-script files. 
; Also the usage of device procedure.
;--------------------** Plot parameters **--------------------------
A=INDGEN(20)
       Set_Plot, 'PS'
        loadct, 13                           ; load color
        Device, File = '/Users/sam/Desktop/Test.ps', /COLOR,/Portrait
        Device, /inches, xsize = 6.5, ysize = 9.0, xoffset = 1, yoffset = 1, scale_factor = 1.0;, font_size = 9;
        !P.MULTI = [0,1,2]
               Plot, A, A*2, XMARGIN=[1,1], YMARGIN=[20,1]
               Plot, A, A*3
               Plot, A, A*4
        Device,/Close
        CGPS2PDF, '/Users/sam/Desktop/Test.ps',delete_ps=1
       Set_Plot , 'X'
End