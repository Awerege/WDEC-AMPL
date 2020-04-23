# parametry
param Q1 >= 0;
param Q2 >= 0;
# zmienne
var X1 >= 0;
var X2 >= 0;
var Z;
# Funkcja celu
maximize f_celu: Z + (0,0001/2)*[( 950*X1 + 6000*X2 – ((5*X1 + 30*X2)*50) – ((10*6*52)*30) –
Q1) – (5*X1 + 30*X2) + Q2 ];
# ograniczenia
subject to ogr1: 0 <= 950*X1 + 6000*X2 – ((5*X1 + 30*X2)*50) – ((10*6*52)*30) – Q1 – Z, ;
subject to ogr2: 0 <= -(5*X1 + 30*X2) + Q2 – Z ;
subject to ogr3: 0 <= X1 + 8*X2 <= 25000 ;
subject to ogr4: 0 <= 5*X1+30*X2 <=62400;
# Wartości poczatkowe
#data;
#param Q1:= 20000000;
#param Q2:= 30000;
