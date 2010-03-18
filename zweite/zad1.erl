-module(zad1).
-export([zaprzyjaznione/1]).

% generowanie listy dzielników liczy
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

% suma elementow na liscie
sum([])->
    0;
sum([H|T]) ->
    H+sum(T).

% lista bez ostatniego elementu
init([]) ->
    [];
init(List) ->
    [_|T] = lists:reverse(List),
    lists:reverse(T).

% wygenerowanie wszystkich par {liczba,suma dzielnikow liczby}
sumaDzielnikow(Liczba) ->
    lists:map(fun(X) ->
                      {X,sum(init(dzielniki(X)))} end,lists:seq(1,Liczba)).

% generator liczb zaprzyjaznionych
zaprzyjaznioneprim(N) ->
    [ {X,Y} || {X,Y} <- sumaDzielnikow(N),
               {A,B} <- sumaDzielnikow(N),A==Y,X==B,A=/=X].

% usuwaczka jednej z par ( [{A,B},{B,A}] -> [{A,B}] )
usunDuplikat(List) ->
    usunDuplikat(List,[]).
usunDuplikat([],Acc) ->
    Acc;
usunDuplikat([{A,B}|T],Acc) ->
    case lists:member({B,A},Acc) of true ->
            usunDuplikat(T,Acc);
        false ->
            usunDuplikat(T,[{A,B}|Acc])
    end.

% ostateczna funkcja
zaprzyjaznione(N) ->
    X = zaprzyjaznioneprim(N),
    lists:reverse(usunDuplikat(X)).
