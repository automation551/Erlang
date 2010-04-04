-module(zad1).
-export([zaprzyjaznione/1,dzielniki/1]).

% generowanie listy dzielnikow liczy
dzielniki(Liczba) when is_integer(Liczba) ->
    dzielniki(Liczba, 1, [],math:sqrt(Liczba)).
dzielniki(Liczba,Aktualny,Acc,Guard) when Aktualny =< Guard ->
    if
        (Liczba rem Aktualny) == 0 ->
            dzielniki(Liczba,Aktualny+1,[Aktualny|Acc],Guard);
        true ->
            dzielniki(Liczba,Aktualny+1,Acc,Guard)
    end;
dzielniki(Liczba,_,Acc,_) ->
    lists:reverse(Acc) ++ lists:map(fun (X) -> round(Liczba/X) end,Acc).


zaprzyjaznione(X,Y) ->
    (lists:sum(dzielniki(X))-X == Y) and (lists:sum(dzielniki(Y))-Y == X).

zaprzyjaznione(N) ->
    [ {X,Y} || X <- lists:seq(1,N),
               Y <- lists:seq(X+1,N),
               zaprzyjaznione(X,Y) ].
