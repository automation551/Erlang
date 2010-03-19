-module(zad2).
-export([test/0,usunBialeZnaki/1,split/1,podzielNaLinie/2]).

test() ->
    "to jest s  hhhhhhhhhhhh jjjjjjjjjjjjjjjjjjj uuuuuuuuuuuuuuuuuuuuuuu iiiiiiiiiiiiiiiii              iiiiiiiiiii yyyyyyyyyy          yyyyyyyyyyyyyy hhhhhhhhhhhhhhhhhhhhhhh     sobie jakis tekst\n\nktory jest,iiiiiii              iiiiiiiiiii yyyyyyyyyy          yyyyyyyy     iiiiiii              iiiiiiiiiii yyyyyyyyyy          yyyyyyyy costam    \t i tez\n\n a to costam innego\n      \n hehehe".

% rozdziela liste na bloczki wzgledem nowej linii (znaczka \n)
% przy okazji olewa bloczki, ktore sa puste
split(List) ->
    split(List,$\n).
split(List,Char) ->
    split(List,Char,[],[]).
split([],_,MiniAcc,Acc) ->
    X = lists:reverse([lists:reverse(MiniAcc)|Acc]),
    lists:filter(fun (A) -> A =/= [] end,X);
split([H|T],Char,MiniAcc,Acc) ->
    case H == Char of
        true ->
            split(T,Char,[],[lists:reverse(MiniAcc)|Acc]);
        false ->
            split(T,Char,[H|MiniAcc],Acc)
    end.

% wyciaga wyrazy z kazdego z bloczka, tzn ignoruje kazde wystapienie
% \t i spacji, tworzy liste wyrazow (["to","jest","costam"])
usunBialeZnaki(Bloczki) ->
    X = lists:map(fun (X) ->
                          string:tokens(X," \t") end,Bloczki),
    lists:filter(fun (Z) ->
                         Z =/= [] end,X).

podzielNaLinie(Wyrazy,Szerokosc) ->
    podzielNaLinie(Wyrazy,[],Szerokosc,[]).
podzielNaLinie([],_,_,Z) ->
    lists:reverse(Z);
podzielNaLinie([Wh|Wt],LiniaAcc,Szerokosc,Acc) ->
    case string:len(LiniaAcc)+string:len(Wh)+1 < Szerokosc of true ->
            podzielNaLinie(Wt,[ [$ |Wh]|LiniaAcc],Szerokosc,Acc);
        false ->
           podzielNaLinie([Wh|Wt],[],Szerokosc,[LiniaAcc|Acc])
    end.

