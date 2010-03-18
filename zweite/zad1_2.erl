-module(zad1_2).
-export([rozklad/1]).

% sprawdzanie czy liczba jest pierwsza
isPrime(N) ->
    Sqrt = round(math:sqrt(N)),
    lists:foldr(fun (X,Acc) ->
                        case N rem X == 0 of
                            true ->
                                false ;
                            false ->
                                Acc
                        end end,true,lists:seq(2,Sqrt)).

% generator liczb pierwszych od 1 do N
primeGenerator(N) ->
    [ X || X<-lists:seq(2,N),
           isPrime(X) == true ].

% generator wszystkich czynnikow pierwszych dla danej liczby
czynniki(Liczba) ->
    Sqrt = round(math:sqrt(Liczba)),
    lists:filter( fun(X) -> Liczba rem X == 0 end , primeGenerator(Sqrt)).

% "prawdziwy" rozklad na czynniki pierwsze
rozkladprim(Liczba) ->
    Sqrt = round(math:sqrt(Liczba)),
    [{X,Y} || X<-czynniki(Liczba),
              Y<-lists:seq(1,Sqrt),
              Liczba rem round(math:pow(X,Y)) == 0 ].

% usuwanie elementow, ktore pojawily sie wczesniej na liscie i
% zwrocenie najwiekszego dzielnika, tzn dla listy
% [{2,1},{2,2}] -> [{2,2}]
usunDuplikat(List) ->
    usunDuplikat(lists:reverse(List),[]).
usunDuplikat([],Acc) ->
    Acc;
usunDuplikat([{A,B}|T],Acc) ->
    case lists:keymember(A,1,Acc) of true ->
            usunDuplikat(T,Acc);
        false ->
            usunDuplikat(T,[{A,B}|Acc])
    end.

rozklad(Liczba) ->
    X = rozkladprim(Liczba),
    usunDuplikat(X).
