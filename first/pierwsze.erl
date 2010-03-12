-module(pierwsze).
-export([main/1]).

main(List) ->
    case List of
        [A,B,C|[]] ->
            X = to_integer(A),
            Y = to_integer(B),
            Z = to_integer(C),
            Wynik = seq(X,Y,Z);
        [A,B|[]] ->
            X = to_integer(A),
            Y = to_integer(B),
            Wynik = seq(X,Y);
        [A|[]] ->
            X = to_integer(A),
            Wynik = seq(X)
    end,
    io:format("~w",[Wynik]).

seq(Start,End,Step) ->
    seq(Start,Step,End,[]).
seq(N,Step,End,Acc) when End >= N ->
    seq(N+Step,Step,End,[N|Acc]);
seq(_,_,_,Acc) ->
    reverse(Acc,[]).

seq(Start,End) ->
    seq(Start,End,1).

seq(End) ->
    seq(1,End,1).

reverse([],Acc) ->
    Acc;
reverse([H|T],Acc) ->
    reverse(T,[H|Acc]).

to_integer(X) ->
    to_integer(X,0).
to_integer([],Acc) ->
    Acc;
to_integer([H|T],Acc) ->
    X=10*Acc + (H-$0),
    to_integer(T,X).
