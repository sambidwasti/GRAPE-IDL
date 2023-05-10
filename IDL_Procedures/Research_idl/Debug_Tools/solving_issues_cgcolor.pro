Pro Solving_Issues_CgColor

A = Indgen(100)
B = A*0

Legend_Array1 = [ 'Almond', 'Antique White', 'AquaMarine', 'Beige', 'Bisque', 'Black', 'Blue', 'Blue Violet', 'Brown', 'Burlywood', 'Cadet Blue', 'Charcoal', 'Chartreuse', 'Chocolate','Coral','Cornflower Blue','Cornsilk','Crimson','Cyan','Dark Goldenrod']
Legend_Array2 = ['Dark Gray','Dark Green', 'Dark Khaki','Dark Orchid','Dark Red','Dark Salmon','Dark Slate Blue','Deep Pink','Dodger Blue','Firebrick','Forest Green','Gray','Green','Green Yellow','Honeydew','Hot Pink','Indian Red','Ivory','Khaki','Lavender']
Legend_Array3 = [ 'Lawn Green','Light Coral','Light Cyan','Light Gray','Light Salmon','Light Sea Green','Light Yellow','Lime Green','Linen','Magenta','Maroon','Medium Gray','Medium Orchid','Moccasin ','Navy ','Olive ','Olive Drab ','Orange ','Orange Red ','Orchid ']
Legend_Array4 = ['Pale Goldenrod ','Pale Green ','Papaya ','Peru ','Powder Blue ','Purple ',' Red ','Rose ',' Rosy Brown ',' Royal Blue','Saddle Brown','Salmon','Sandy Brown','Sea Green','Seashell','Sienna','Sky Blue','Slate Blue','Slate Gray','Snow'] 
Legend_Array5 = ['Spring Green','Steel Blue','Tan','Teal','Tomato','Turquoise','Violet','Violet Red','Yellow']
Color_Array1 = CgColor(Legend_Array1)
Color_Array2 = CgColor(Legend_Array2)
Color_Array3 = CgColor(Legend_Array3)
Color_Array4 = CgColor(Legend_Array4)
Color_Array5 = CgColor(Legend_Array5)


temp_Arr1 = [IntArr(N_Elements(Color_Array1))*0]+1
temp_Arr2 = [IntArr(N_Elements(Color_Array2))*0]+1
temp_Arr3 = [IntArr(N_Elements(Color_Array3))*0]+1
temp_Arr4 = [IntArr(N_Elements(Color_Array4))*0]+1
temp_Arr5 = [IntArr(N_Elements(Color_Array5))*0]+1
Cd, Cur=Cur
CgPs_Open, 'CgColor.ps', Font =1,/Landscape
cgLoadCT, 13
!P.Font=0.1
CgPlot, A, B
 CgLegend, Location=[0.15,0.87], Titles=Legend_array1, Length =0, $
        SymColors = Color_array1, TColors=Color_Array1,Psyms=temp_Arr1, Charsize=1.0
      CgLegend, Location=[0.3,0.87], Titles=Legend_array2, Length =0, $
        SymColors = Color_array2, TColors=Color_Array2,Psyms=temp_Arr2, Charsize=1.0        
        CgLegend, Location=[0.45,0.87], Titles=Legend_array3, Length =0, $
        SymColors = Color_array3, TColors=Color_Array3,Psyms=temp_Arr3, Charsize=1.0
          CgLegend, Location=[0.60,0.87], Titles=Legend_array4, Length =0, $
          SymColors = Color_array4, TColors=Color_Array4,Psyms=temp_Arr4, Charsize=1.0
            CgLegend, Location=[0.75,0.87], Titles=Legend_array5, Length =0, $
            SymColors = Color_array5, TColors=Color_Array5,Psyms=temp_Arr5, Charsize=1.0
CgErase
      CgPlot, A, B, Background='Black'
      CgLegend, Location=[0.15,0.87], Titles=Legend_array1, Length =0, $
        SymColors = Color_array1, TColors=Color_Array1,Psyms=temp_Arr1, Charsize=1.2
        CgLegend, Location=[0.3,0.87], Titles=Legend_array2, Length =0, $
        SymColors = Color_array2, TColors=Color_Array2,Psyms=temp_Arr2, Charsize=1.2
        CgLegend, Location=[0.45,0.87], Titles=Legend_array3, Length =0, $
        SymColors = Color_array3, TColors=Color_Array3,Psyms=temp_Arr3, Charsize=1.2
          CgLegend, Location=[0.60,0.87], Titles=Legend_array4, Length =0, $
          SymColors = Color_array4, TColors=Color_Array4,Psyms=temp_Arr4, Charsize=1.2
            CgLegend, Location=[0.75,0.87], Titles=Legend_array5, Length =0, $
            SymColors = Color_array5, TColors=Color_Array5,Psyms=temp_Arr5, Charsize=1.0
          
CgPs_Close
CGPS2PDF,Cur+'/CgColor.ps','CgColor.pdf',delete_ps=1
End