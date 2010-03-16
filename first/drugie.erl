-module(drugie).
-export([isum/1,imax/1]).

isum(Lista) ->
    isum(Lista,0).
isum([],Acc) ->
    Acc;
isum([H|T],Acc) when is_integer(H) ->
    isum(T,H+Acc).

imax([]) ->
    [];
imax([H|T]) when is_integer(H) ->
    imax([H|T],H).
imax([],Acc) ->
    Acc;
imax([H|T],Acc) when is_integer(H), H=< Acc ->
    imax(T,Acc);
imax([H|T],_) when is_integer(H) ->
    imax(T,H).
