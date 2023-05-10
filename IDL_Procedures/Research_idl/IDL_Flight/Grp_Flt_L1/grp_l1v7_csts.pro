PRo Grp_l1v7_Csts, File1, File2, Title=Title
  ;
  ; Read two QLook.txt file and do a background subtraction and then output the stat file
  ; these files are named qlook.txt
  ; 
  ; May 19,2016
  ;   Updating to read teh updated qlook file.
  ;

  ;
  ;-- Title --
  ;
  IF Keyword_Set(title) Eq 0 Then Title='Test'

  c2014 = [0,2,3,4,6,7,9,10,11,12,13,14,17,18,19,20,21,22,24,25,27,28,29,31]

  ;
  ;===== Reading the files =======
  ;

  ;
  ;-- Read teh Source File --
  ;

  Openr, Lun1, File1, /Get_Lun
  Data =''
  Readf, lun1, Data ; Title
  Src_fname = Data
  Readf, Lun1, Data ; No. of files
  Readf, Lun1, Data ; TimeRan
  TRun_Src = STRN(StrMID(Data,9,StrLen(Data)-10))
  Readf, Lun1, Data ; Average LiveTime
  Data1 = DblArr(32)
  Readf, Lun1, Data1 ; livetime
  AvgLt_Src = Data1

  Data2 = LonARR(32)
  Readf, Lun1, Data
  Readf, Lun1, Data2
  C_Arr_Src = Data2

  Readf, Lun1, Data
  Readf, Lun1, Data2
  CC_Arr_Src = Data2

  Readf, Lun1, Data
  Readf, Lun1, Data2
  PC_Arr_Src = Data2

  Data2 = LonARR(32)
  Readf, Lun1, Data
  Readf, Lun1, Data2
  P_Arr_Src = Data2
  
  Data2 = LonARR(32)
  Readf, Lun1, Data
  Readf, Lun1, Data2
  PP_Arr_Src = Data2
  
  Data2 = LonARR(32)
  Readf, Lun1, Data
  Readf, Lun1, Data2
  PPC_Arr_Src = Data2
  
  Data2 = LonARR(32)
  Readf, Lun1, Data
  Readf, Lun1, Data2
  Other_Arr_Src = Data2
  
  Data2 = LonARR(32)
  Readf, Lun1, Data
  Readf, Lun1, Data2
  Inv_Arr_Src = Data2
  
  Free_Lun, Lun1

  ;
  ;-- Read the Background File --
  ;

  Openr, Lun2, File2, /Get_Lun
  Data =''
  Readf, Lun2, Data ; Title
  Back_fname = Data
  Readf, Lun2, Data ; No. of files
  Readf, Lun2, Data ; TimeRan
  TRun_Back = STRN(StrMID(Data,9,StrLen(Data)-10))

  Readf, Lun2, Data ; Average LiveTime
  Data1 = DblArr(32)
  Readf, Lun2, Data1 ; livetime
  AvgLt_Back = Data1

  Data2 = LonARR(32)
  Readf, Lun2, Data
  Readf, Lun2, Data2
  C_Arr_Back = Data2

  Readf, Lun2, Data
  Readf, Lun2, Data2
  CC_Arr_Back = Data2

  Readf, Lun2, Data
  Readf, Lun2, Data2
  PC_Arr_Back = Data2

  Readf, Lun2, Data
  Readf, Lun2, Data2
  P_Arr_Back = Data2
  
  
  Readf, Lun2, Data
  Readf, Lun2, Data2
  PP_Arr_Back = Data2
  
  
  Readf, Lun2, Data
  Readf, Lun2, Data2
  PPC_Arr_Back = Data2
  
  
  Readf, Lun2, Data
  Readf, Lun2, Data2
  Other_Arr_Back = Data2
  

  Readf, Lun1, Data
  Readf, Lun1, Data2
  Inv_Arr_Back = Data2
  
  Free_Lun, Lun2

  ;
  ;==================== Reading the file section done.
  ;


  ;
  ;== Background Subtractions ==
  ;

  ;
  ;-- We are scaling/normalizing the background to be subtracted.
  ;

  ;
  ;-- This is a factor by which the background has to be scaled to be normalized --
  ;
  ;Scale_factor = (Src average lt(fractional)  X total time ran)/( Back average lt(fractional)  X total time ran)
  ;
  CC_Arr = DBLArr(32)
  PC_Arr = DBLArr(32)
  C_Arr = DBLArr(32)
    P_Arr = DBLArr(32)
      PP_Arr = DBLArr(32)
        PPC_Arr = DBLArr(32)
          Other_Arr = DBLArr(32)
        
  For i = 0, 31 Do begin
    ;
    ;-- Only for the configured arrays.
    ;
    If (Where(i EQ c2014) Ne -1) NE 0 Then Begin
      Sclfactor = (AvgLt_Src[i]* TRun_Src) /( AvgLt_Back[i]* TRun_Back)

      C_Back = C_Arr_Back[i] * SclFactor
      CC_BAck= CC_Arr_Back[i] * SclFactor
      PC_Back= PC_Arr_Back[i] * SclFactor
      PP_Back= PP_Arr_Back[i] * SclFactor
      P_Back = P_Arr_Back[i]*SclFactor
      PPC_Back= PPC_Arr_Back[i]*SclFactor
      Other_back = Other_Arr_Back[i]*SclFactor
     

     
      C_Arr[i] = C_Arr_Src[i] - C_Back
      CC_Arr[i] = CC_Arr_Src[i] - CC_Back
      PC_Arr[i] = PC_Arr_Src[i] - PC_Back
      PP_Arr[i] = PP_Arr_Src[i]-PP_Back
      P_Arr[i]  = P_Arr_Src[i]-P_BAck
      PPC_Arr[i]= PPC_Arr_Src[i]-PPC_Back
      Other_Arr[i]= OTher_Arr_Src[i]-Other_Back
      
    Endif
  Endfor
  ;
  ;--
  ;
  Openw, Lun3, Title+'_CSts.txt',/Get_Lun
  Printf, Lun3, 'Src  File :'+ Src_Fname
  Printf, Lun3, 'Back File :'+ Back_Fname

  Temp_Data =''
  Temp_Data1 =''
  Temp_Data2 =''
  Temp_Data3 =''
  Temp_Data4 =''
  Temp_Data5 =''
  Temp_Data6 =''
    
  for i = 0,31 Do begin
    Temp_Data  = Temp_Data  + Strn(C_Arr[i])  + ' '
    Temp_Data1 = Temp_Data1 + Strn(CC_Arr[i]) + ' '
    Temp_Data2 = Temp_Data2 + Strn(PC_Arr[i]) + ' '
    Temp_Data3 = Temp_Data3 + Strn(P_Arr[i])  + ' '
    Temp_Data4 = Temp_Data4 + Strn(PP_Arr[i]) + ' '
    Temp_Data5 = Temp_Data5 + Strn(PPC_Arr[i]) + ' '
    Temp_Data6 = Temp_Data6 + Strn(Other_Arr[i]) + ' '
  endfor

  Printf, Lun3, 'C'
  Printf, Lun3, Temp_Data

  Printf, Lun3, 'CC'
  Printf, Lun3, Temp_Data1

  Printf, Lun3, 'PC'
  Printf, Lun3, Temp_Data2

  Printf, Lun3, 'P'
  Printf, Lun3, Temp_Data3
  
  Printf, Lun3, 'PP'
  Printf, Lun3, Temp_Data4
  
  Printf, Lun3, 'PPC'
  Printf, Lun3, Temp_Data5
  
  Printf, Lun3, 'Other'
  Printf, Lun3, Temp_Data6
  
  Printf, Lun3, 'Total C, CC, PC, P, PP, PPC, Other'
  Printf, Lun3, Strn(Total(C_Arr))+' '+ Strn(Total(CC_Arr))+' '+Strn(Total(PC_Arr))+' '+Strn(Total(P_Arr))+' '+Strn(Total(PP_Arr))+' '+Strn(Total(PPC_Arr))+' '+Strn(Total(Other_Arr))

  Printf, lun3, 'Total all'
  PRintf, lun3, Strn((Total(C_Arr))+(Total(CC_Arr))+(Total(PC_Arr))+(Total(P_Arr))+(Total(PP_Arr))+(Total(PPC_Arr))+(Total(Other_Arr)))

  Free_Lun, Lun3

  Openw, Lun4, Title+'_Ener.txt',/Get_Lun
  for i = 0,31 Do begin
   
  endfor
  free_lun, lun4
End
