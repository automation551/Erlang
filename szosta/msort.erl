-module(msort).
-export([msort/3,msort/4,parallel_merge_sort/3]).
-import(mergesort).

%% msort mergesortuje podana liste przy uzyciu StopN procesow
%% jako wynik wysyla do swojego rodzica {ok,Sorted}
msort(StopN,Input,ParentPid) ->
    msort(StopN,1,Input,ParentPid).

msort(StopN,N,Input,ParentPid) ->
    %io:format("~p: ~n",[N]),
    if
        N*2 > StopN ->
            %io:format("sortuje recznie~n"),
            Sorted = mergesort:sort(Input),
            ParentPid ! {ok,Sorted};
        true ->
            %io:format("rozpraszam~n"),
            {Left,Right} = mergesort:split(Input),
            _L = spawn(?MODULE,msort,[StopN,N*2,Left,self()]),
            _R = spawn(?MODULE,msort,[StopN,N*2+1,Right,self()]),
            loop(ParentPid)
    end.

loop(ParentPid) ->
    receive
        {ok,Sorted} ->
            loop(ParentPid,Sorted)
    end.

loop(ParentPid,Sorted1) ->
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
    LSublist = trunc(length(ListToSort)/length(Nodes)),g
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
split(F,Len,Acc) when length(F) =< Len ->
    lists:append([F],Acc);
split(Input,Len,Acc) ->
    {X,Rest} = lists:split(Len,Input),
    NewAcc = lists:append([X],Acc),
    split(Rest,Len,NewAcc).
