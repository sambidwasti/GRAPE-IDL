
; Creating a Simple program to understand Structures and Reading and writing binary files.
; The replicate function changes the regular structure into an array.
; 
; CAREFUL:
; NOTICE:
;               The Type of the variable in structure defines the type to be read. 
;               Also the Data_type helps to read that structure. 
;               If not correct the data type goes haywire.
;               
;               Also the use of C++ in the array position.
; 5/ 30/ 13

pro simplebinary

      ; Create some data to store in a file:
      L= DIst(5)
      D= BYtSCl(Dist(5))

      ; Open a new file for writing as IDL file unit number 1:
      OPENW, 1, '/Users/sam/Sam_research/newfile'
      WRITEU, 1, L
      CLOSE, 1
      
      ; Create a Structure
      Struc = { A: 0.0, $
                B: 0.0, $
                C: 0.0, $
                D: 0.0, $
                E: 0.0 }
                
sdata = replicate(struc, 5)


      openr, lun, '/Users/sam/Sam_research/newfile', /Get_Lun
      i=0
      Lines = File_Lines('/Users/sam/Sam_research/newfile')
      print, Lines
;      numbers = read_binary(lun, data_type =4)
;      print, numbers
      for i =0, 3 Do begin
           sdata[i].A = read_binary(lun, data_type=4,data_dims =1)
            sdata[i].B = read_binary(lun,data_type=4, data_dims =1)
            sdata[i].C = read_binary(lun, data_type=4,data_dims =1)
            sdata[i].D = read_binary(lun, data_type=4,data_dims =1)
           sdata[i].E = read_binary(lun, data_type=4,data_dims =1)
      endfor
 ;          numbers=read_binary(lun, data_type=1, data_dims = 2)
 ;          points = read_binary(lun, data_type=1, data_dims = 4)
;           print, numbers
  ;         print, points
       free_lun, lun
OPENW, 2, '/Users/sam/Sam_research/newTextfile'
    for i = 0, 4 do begin
    printf, 2, sdata[i].A, sdata[i].B
    endfor
Free_Lun, 2
           print, sdata.A
 
           c = 0
 for i = 0,4 do begin
           print, Sdata[c++].A
  endfor         
      ; endfor 

      
      
      ;print, f 
      ;print, g
      help, Struc

End