-module(mergesort).
-export([merge/2,split/1,sort/1]).

merge(X,Y) ->
    merge(X,Y,[]).

merge(X,[],Acc) ->
    lists:append(lists:reverse(Acc),X);
merge([],Y,Acc) ->
    lists:append(lists:reverse(Acc),Y);
merge([Hx|X],[Hy|Y],Acc) when Hy < Hx ->
    merge([Hx|X],Y,[Hy|Acc]);
merge([Hx|X],[Hy|Y],Acc) ->
    merge(X,[Hy|Y],[Hx|Acc]).

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
