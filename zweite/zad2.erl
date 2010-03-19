-module(zad2).
-export([test/0,usunBialeZnaki/1,split/1, podziel/3, do/2]).

test() ->
    "to jest s  ai    to inny tekst ab to sa przypadkowe literki, literki ktore sa w pelni przypadkowe i w ogole nie skladaja sie na zaden istniejacy wyraz. mozliwe ze za pare lat ktos mymysli taki wyraz, narazie taki wyraz nie istnieje  sobie jakis \n\nktory jest, iiiiiii              iiiiiiiiiii yyyyyyyyyy          yyyyyyyy     iiiiiii              iiiiiiiiiii yyyyyyyyyy          yyyyyyyy costam    \t i tez\n\n a to costam innego\n      \n hehehe".

% rozdziela liste na bloczki wzgledem nowej linii (znaczka \n)
% przy okazji olewa bloczki, ktore sa puste
split(List) ->
    split(List,$\n).
split(List,Char) ->
    split(List,Char,[],[]).
split([],_,MiniAcc,Acc) ->
    X = lists:reverse([lists:reverse(MiniAcc)|Acc]),
    lists:filter(fun (A) -> A =/= [] end,X);
split([H|T],Char,MiniAcc,Acc) when H==Char ->
    split(T,Char,[],[lists:reverse(MiniAcc)|Acc]);
split([H|T],Char,MiniAcc,Acc) ->
    split(T,Char,[H|MiniAcc],Acc).


% wyciaga wyrazy z kazdego z bloczka, tzn ignoruje kazde wystapienie
% \t i spacji, tworzy liste wyrazow (["to","jest","costam"])
usunBialeZnaki(Bloczki) ->
    X = lists:map(fun (X) ->
                          string:tokens(X," \t") end,Bloczki),
    lists:filter(fun (Z) ->
                         Z =/= [] end,X).

% straszna funkcja. dostaje jakas liste wyrazow oraz jakas okreslona szerokosc,
% funkcja rozdziela tak wyrazy do kolejnych list, aby dlugosci poszczegolnych
% linii nie byly dluzsze niz zadana Szerokosc
podziel([H|Wyrazy],Szerokosc,Wciecie) ->
    X = podziel([[string:copies(" ",Wciecie)|H]|Wyrazy],[],Szerokosc,[]),
    lists:map(fun (Y) ->
                          string:strip(Y,both,$ ) end,X).
podziel([],Linia,_,LinieAcc) ->
    lists:reverse([""++lists:flatten(Linia)] ++ LinieAcc);
podziel([H|T],Linia,Szerokosc,LinieAcc) when length(H) < Szerokosc ->
    F = string:len(lists:flatten(H)),
    case string:len(lists:flatten(Linia)) < Szerokosc-F of
        true ->
            podziel(T,Linia++" "++H,Szerokosc,LinieAcc);
        false ->
            podziel(T,H,Szerokosc,[lists:flatten(Linia)|LinieAcc])
    end.

% dostajac liste wszystkich juz "oczyszczonych" bloczkow dzielimy je
% na liste linii, dodajac ewentualnie wciecie z przodu
podzielBloczki(Bloczki,Szerokosc,Wciecie) ->
    Z = lists:map(fun (X) ->
                       podziel(X,Szerokosc,Wciecie) end,Bloczki),
    lists:map(fun ([H|Y]) ->
                     [string:copies(" ",Wciecie)++H]++Y end,Z).


do(S,Wciecie) ->
    X = usunBialeZnaki(split(test())),
    podzielBloczki(X,S,Wciecie).
