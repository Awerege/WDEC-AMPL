# parametry
param N{1..5} >= 0; # liczba pracowników na danym stanowisku
param P{1..5} >= 0; # płaca referencyjna na i-tym stanowisku
param M{1..5} >= 0; # płaca na zewnątrz firmy na podobnym stanowisku do i-tego
param S{1..5-1} >= 0; # minimalna różnica płac między stanowiskami i oraz i+1
param Q{1..5}; # aspiracje dla poszczególnych kryteriów
# zmienne
var X{1..5} >= 0; # płaca na poszczególnych stanowiskach
var G{1..4, 1..5} >= 0; # macierz z wartościami Opi+, Opi-, Omi+ oraz Omivar
Z{1..2}; # zmienne do skalaryzacji kryteriów
var A; # zmienna pomocnicza przy skalaryzacji metodą punktu odniesienia
var Y{1..5}; # zmienne pomocnicze do kryteriów
# ograniczenia
subject to placa_minimalna: X[5] >= 1;
subject to placa_referencyjna {i in 1..5}: X[i] = P[i] + G[1,i] - G[2,i];
subject to placa_zewnetrzna {i in 1..5}: X[i] = M[i] + G[3,i] - G[4,i];
subject to roznica_plac {i in 1..4}: X[i] - S[i] >= X[i+1];
subject to Z1_1 {i in 1..5}: Z[1] >= G[1,i];
subject to Z1_2 {i in 1..5}: Z[1] >= G[2,i];
subject to Z2_1 {i in 1..5}: Z[2] >= G[3,i];
subject to Z2_2 {i in 1..5}: Z[2] >= G[4,i];
subject to Y1: Y[1] = sum{i in 1..5} X[i]*N[i];
subject to Y2: Y[2] = Z[1];
subject to Y3: Y[3] = sum{i in 1..5} (G[1,i] + G[2,i]);
subject to Y4: Y[4] = Z[2];
subject to Y5: Y[5] = sum{i in 1..5} (G[3,i] + G[4,i]);
subject to skalaryzacja {i in 1..5}: (Q[i] - Y[i]) >= A;
# funkcja celu
maximize f_celu: Z + (0.0001/5)*(sum{i in 1..5} (Q[i] - Y[i]));