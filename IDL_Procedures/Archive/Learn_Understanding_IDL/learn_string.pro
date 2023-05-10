pro learn_String, ID = ID
; *************************************************************************
; *                 Learn Understand String Manipulation                  *
; *************************************************************************
; * Purpose:  Understand the string manipulation                          *
; *           Part of Learn/Undersand IDL Documents                       *
; *                                                                       *
; *    Usage: Learn_String                                                *
; *           Learn_String, ID=#                                          *
; *                                                                       *
; *                     ******KEYWORDS*******                             *
; *    ID = ID  ; List of ID for understanding a certain String operation *
; *                         1  -  Strlen()                                *
; *                         2  -  Strn()                                  *
; *                         3  -  StrPos()                                * 
; *                         4  -  StrMid()                                *
; *                         5  -  StrTrim()                               *
; *                         6  -  Example 1: Usage of StrPos and StrMid   *
; *                         7  -  Format 
; *                         8  -  Example 2: Printing out the odd/Even    *
; *                               numbered words. ( More complicated and  *
; *                               powerful usage of the functions )       *
; *                                                                       *
; * Author: 9/17/14  Sambid Wasti                                         *
; *                  Email: Sambid.Wasti@wildcats.unh.edu                 *
; *                                                                       *
; * Revision History:                                                     *
; *         3/01/16  Sambid Wasti                                         *
; *                  Adding format section since its a big part of String *
; *                  Operations.                                          *
; *                                                                       *
; *************************************************************************
; *************************************************************************



;--- Define the LIST ID to Execute and learn---
If Keyword_Set(ID) EQ 0 Then ID = 8
   

      ; -- Define a String --
      s = 'Once upon a time in a far far away land, there lived a king and a thief who were brothers and were enemies of the country. '
      
     
      Print, ' String :'+s
      Print, ' --- ==== ---- ==== ---- '
      
      Case ID of 
      1 : Begin  ;STRLEN()
          ;-- Getting Length --
          
          Print, ' StrLen() '
          Print, ' --- ==== ---- ==== ---- '
          
          l = StrLen(s)
          Print, 'String Length =',Strn(l)
          
      End
      2 : Begin ;Strn()
          ;
          ; This is a special function which uses strmid( which is stated later ) that gobbles up the empty space before and after the number
          ;
          
          Print, ' Strn() '
          Print, ' --- ==== ---- ==== ---- '
          
          temp_Val = Long(4)
          print, 'abcd',temp_val,'efgh'
          print, 'abcd',Strn(temp_val),'efgh'
      End
      3 : Begin ; StrPos()
          ;
          ;-- This is useful in searching characters or words or sub-text and output its location in the String. Uses string as array of Chars. 
          ;
          
          Print, ' StrPos() '
          Print, ' --- ==== ---- ==== ---- '
          
          ;looks for the first occurance of 'a' which is in 10 location (starting from 0) in the string s.
          k = strpos(s,'a')   ; STRPOS(STRING,'character/word')
          print, ' the letter "a" occurs first on the position '+Strn(k)
          
          ;looks for the first occurance of 'a' after the 13th position.
          j = strpos(s,'a',13)
          print, ' the letter "a" occurs first, after the 13th character, in the position '+Strn(j)
          
          ;-- it outputs -1 for letters/characters not in the string.
          i = strpos(s,'z',0)
          print, ' the letter "z" is not in the string, the position thats given is '+Strn(i)
          
          ;-- We can search for words too. Lets search for 'king'
          h = strpos(s,'king',0)
          print, ' The word "King" occurs at position :'+strn(h)
          
          ; -- it outputs -1 for letters/characters not in the string after the position specified.
          g = strpos(s, 'Once', 10)
          print, ' The word "Once" occurs at the begining and not after the 10th character, its outputting the position:'+Strn(g)
          
          
      End
      4 : Begin ; StrMid()
          ;
          ;---- Powerful tool to extract a substring ----
          ;
          Print, ' StrMid() '
          Print, ' --- ==== ---- ==== ---- '
          
          ;-- Extracting the substring of length 5 starting from 0
          l = Strmid(s,0,5)
          print, ' Sub-string of length 5 and starting from 0 is:',l 
          
          ;-- Extracting the substring of length 10 starting from 15
          m = Strmid(s,15,10)
          print, ' Sub-string of length 10 and starting from 15 is:',m 
      
      End
      5 : Begin ; StrTrim()
          ;
          ;-- Using StrTrim
          ;
          Print, ' StrTrim()'
          Print, ' --- ==== ---- ==== ---- '
          
          ;------------
          Print, ' ---  For a number   --- '
          a = 9
          print, ' Before StrTrim: **',a,'**'
          Print, ' After StrTrim:  **',StrTrim(a,1),'**'
          
          ; ------------
          Print, ' ---  For a string   --- '
          b =    '   String   '
          print, ' Before StrTrim          : **',b,'**'
          Print, ' After StrTrim (NoFlag)  : **',StrTrim(b),'**'
          Print, ' After StrTrim (Flag 0)  : **',StrTrim(b,0),'**'
          Print, ' After StrTrim (Flag 1)  : **',StrTrim(b,1),'**'
          Print, ' After StrTrim (Flag 2)  : **',StrTrim(b,2),'**'
      End
      6 : Begin ; Example 1
          ;
          ;---- Example 1 to show the power of StrPos and StrMid ----
          ; 
          Print, ' Example 1 : Power of StrPos() and StrMid() '
          Print, ' --- ==== ---- ==== ---- '
          
          ; Lets print the word after ','
          n = StrPos(s, ',', 0  ) + 1     ; +1 to skip the space after comma
          o = StrPos(s, ' ', n+1)         ; Getting the position of the space after the position n+1
          p = StrMid(s, n  , o-n)
          Print, ' The word after "," is :'+p
          
          ; The rest of the sentence after ','
          q = StrPos(s, ',', 0  ) + 1
          r = StrMid(s, q , StrLen(s)-q)
          Print, ' The rest of the sentence after "," is :'+r
      End    
      7 : Begin
          ;
          ;--- Format Strings ----
          ;
          Print, 'This section is on how to use the format keyword for a special format'
          Print, ' More details can be found online, going to focus on double and int '
          Print
          Print, '-- Integer -- '
          
          A = 5233
          Print, ' A = ',A
          Print, ' We want A as 5 digit no. '
          Temp_Str = String(Format='(I5,X)', A)
          Print, ' We have = ', Temp_Str
          ; Note when we write I5, if the no. is more than 5 digit it gives error. 
          ; Right now the empty space at the beginning is a gap.
          
          Print, ' to fill the empty space with 0, we have'
          Temp_Str = String(Format='(I05,X)', A)
          Print, ' We have = ', Temp_Str

          B = 123.423145
          Print, '-- Decimal--'
          Print, ' B = ',B
          Print, ' We want A as 6 digit no. as 2 decimal place '
          Temp_Str = String(Format='(D6.2,X)', B)
          ; the 2 is the decimal place. 
          ;     6 is total no. of numbers we want.
          ;     . takes 1 number slot.
          ;     Total no. should be left of decimal no. + decimal spot(+1) + no. of decimal place. 
          Print, ' We have = ', Temp_Str
        
      End  
      8 : Begin
          ;
          ;---- Example 1 to show the power of StrPos and StrMid with the While ----
          ;
          Print, ' Example 2 : The Power of Loop, incrementing the power of StrPos() and StrMid() combined. '
          Print, ' --- ==== ---- ==== ---- '
          
          Odd_Sentence = ''
          Even_Sentence =''
          counter = 0
          u = -1
          v = 0
          ;-- Run a loop --
          while (v GE 0) Do Begin
               v = StrPos(s ,' ', u+1)
               counter++
               If Counter mod 2 Eq 0 Then Even_Sentence= Even_Sentence+' '+StrMid(s, u, v-u) Else $
                                          Odd_Sentence= Odd_Sentence+' '+StrMid(s, u, v-u)            
               u = v  ; this skips the 'space'
          EndWhile
          
          ;NOTE: Careful with the last word.. It worked here because of the space bar. 
          ; When using loop the first and the last words could be tricky. 
          
          Print, 'The Odd  Sentence:'+ Odd_Sentence
          Print, 'The Even Sentence:'+ Even_Sentence
      End
      Else : Print,'Invalid ID, Enter ID from 1-8 '
     EndCase
     
           Print, ' --- ==== ---- ==== ---- '

end