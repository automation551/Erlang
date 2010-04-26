-module(msort).
-export([msort/3,msort/4,parallel_merge_sort/3,split/2]).
-import(mergesort).

%% msort mergesortuje podana liste przy uzyciu StopN procesow
%% jako wynik wysyla do swojego rodzica {ok,Sorted}
msort(StopN,Input,ParentPid) ->
    msort(StopN,0,Input,ParentPid),
    receive
        {ok,Sorted} -> Sorted
    end.

msort(StopN,N,Input,ParentPid) ->
    %io:format("~p: ~n",[N]),
    if
        2*N+1 >= StopN ->
            %io:format("tutaj: ~p, sortuje recznie, wysylam do ~p~n",[self(),ParentPid]),
            Sorted = mergesort:sort(Input),
            ParentPid ! {ok,Sorted};
        true ->
            %io:format("rozpraszam~n"),
            {Left,Right} = mergesort:split(Input),
            _L = spawn(?MODULE,msort,[StopN,N*2+1,Left,self()]),
            _R = spawn(?MODULE,msort,[StopN,N*2+2,Right,self()]),
            loop(ParentPid)
    end.

loop(ParentPid) ->
    %io:format("1. tutaj: ~p, czekam na prawe skrzydlo do ~p~n",[self(),ParentPid]),
    receive
        {ok,Sorted} ->
            loop(ParentPid,Sorted)
    end.

loop(ParentPid,Sorted1) ->
    %io:format("2. tutaj: ~p, wysylam do ~p~n",[self(),ParentPid]),
    receive
        {ok,Sorted2} ->
            X = mergesort:merge(Sorted1,Sorted2),
            ParentPid ! {ok,X}
    end.

%% parallel_merge_sort mergesortuje z wykorzystaniem tego wyzej
%% na wezlach, kolejne wyniki odbiera w readall() i merguje je po kolei
parallel_merge_sort(Nodes,ProcPerNode,ListToSort) ->
    parallel_merge_sort(Nodes,ProcPerNode,ListToSort,0).

parallel_merge_sort([],_Y,_X,N) ->
    readall(N,[]);
parallel_merge_sort(Nodes,ProcPerNode,ListToSort,N) ->
    LSublist = trunc(length(ListToSort)/length(Nodes)),
    Splitted = split(ListToSort,LSublist),
    spawn(hd(Nodes),?MODULE,msort,[ProcPerNode,hd(Splitted),self()]),
    parallel_merge_sort(tl(Nodes),ProcPerNode,tl(Splitted),N+1).

%% zczytywanie kolejnych wynikow od wezlow,
%% i mergowanie jej z juz posortowana lista
readall(0,Sorted) ->
    Sorted;
readall(N,Sorted1) ->
    receive
        {ok,Sorted2} ->
            X = mergesort:merge(Sorted1,Sorted2),
            readall(N-1,X)
    end.

%% podzielenie listy na kawalki podanej dlugosci
%% split([1,2,3,4,5],2) -> [[1,2],[3,4],[5]].
split(Input,Len) ->
    split(Input,Len,[]).
split(F,Len,Acc) when length(F) < Len ->
    [lists:append(F,hd(Acc))|tl(Acc)];
split(Input,Len,Acc) ->
    {X,Rest} = lists:split(Len,Input),
    NewAcc = lists:append([X],Acc),
    split(Rest,Len,NewAcc).
