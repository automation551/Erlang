-module(mergesort).
-export([merge/2,split/1,sort/1]).

merge(X,[]) ->
    X;
merge([],Y) ->
    Y;
merge([Hx|X],[Hy|Y]) when Hy < Hx ->
    [Hy|merge([Hx|X],Y)];
merge([Hx|X],[Hy|Y]) ->
    [Hx|merge(X,[Hy|Y])].

split(X) ->
    split(X,[],[]).
split([],Acc1,Acc2) ->
    {Acc1,Acc2};
split([X],Acc1,Acc2) ->
    {[X|Acc1],Acc2};
split([X,Y|T],Acc1,Acc2) ->
    split(T,[X|Acc1],[Y|Acc2]).

sort([]) ->
    [];
sort([H]) ->
    [H];
sort(Lista) ->
    {A,B} = split(Lista),
    merge (sort(A),sort(B)).
