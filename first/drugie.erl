-module(drugie).
-export([isum/1,imax/1]).

isum(Lista) ->
    isum(Lista,0).
isum([],Acc) ->
    Acc;
isum([H|T],Acc) when is_integer(H) ->
    isum(T,H+Acc);
isum(_,_) ->
    io:format("zly format danych\n").

imax([]) ->
    [];
imax([H|T]) when is_integer(H) ->
    imax([H|T],H).
imax([],Acc) ->
    Acc;
imax([H|T],Acc) when is_integer(H) ->
    if
        H =< Acc ->
            imax(T,Acc);
        true ->
            imax(T,H)
    end;
imax(_,_) ->
    io:format("zly format danych\n").

