-module(zad2).
-export([test/0,usunBialeZnaki/1,split/1, podziel/3, do/2, do/1,init/1]).



test() ->
	"The argument is a float which          is written as ddd, where       the precision is the number of digits written. The default precision is 6 and it cannot be less than 2.

The argument is a float which is written as f, if it is >= 0.1 and < 10000.0. Otherwise, it is written in the e f           ormat. The precision is the number of significant digits. It          defaults              to 6 and            should not b             e less than 2. If the absolute value of the float does not allow it to be written in the f format with the desired number of significant       digits, it is also written in the e format.

Prints the argument with the string        syntax.     The argument is, if no Unicode translation modifier is present, an I/O list, a binary, or an a       tom. If the Unicod    e translation modifier \t is in effect, the argument i       s chardata(), meaning that binaries are        in UTF-8. The characters are printed without quotes. In this format, the prin        ted argument is trunc         ated to the given precision and field width.".

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
    case string:len(lists:flatten(Linia)) =< Szerokosc-F of
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


wrzucSpacje(Tekst,Szerokosc) ->
	wrzucSpacje(Tekst,Szerokosc,[]).

wrzucSpacje([],_,Acc) -> lists:reverse(Acc) ;
wrzucSpacje([H|T],Szerokosc,Acc) ->
	wrzucSpacje(T,Szerokosc, [rozszez( H, Szerokosc-length(H)+1)|Acc]).

tail([]) -> [];
tail([_|T]) -> T.
head([]) -> [];
head([H|_]) -> H.

init(T) -> lists:reverse(tail(lists:reverse(T))).

last(T) -> head(lists:reverse(T)).

rozszez(Lista,IleSpacji) ->
	[H|T] = string:tokens(Lista," "),
	H ++ string:copies(" ",IleSpacji) ++ string:join(T," ").




do(Szerokosc,Wciecie) ->
    X = usunBialeZnaki(split(test())),
    A = podzielBloczki(X,Szerokosc,Wciecie),
    B = lists:map( fun(P) -> wrzucSpacje(init(P),Szerokosc)++[last(P)] end,A),
    Akap = lists:map( fun([P|T]) -> [string:copies(" ",Wciecie)++ P] ++ T++"" end, B ),
    lists:foreach( fun(P) -> lists:foreach( fun(Pp) -> io:format("~s~n", [Pp]) end ,P),io:format("~n") end,Akap).


do(Szerokosc) ->
	do(Szerokosc,0).



