-module(zad3).
-export([search/2,t/0,insert/3,new/1,delete/2,
        findMax/1, zig/2,zig_zig/2,zig_zag/2]).

-record(node, {key,val,left=nil,right=nil}).

%% new({Key,Value}) -> {ok,new Tree}
new({K,V}) ->
    {ok,#node{key=K,val=V}}.

%% search/2 (Tree,Key) -> {ok,Wartosc}
search(Node,Key) when Key == Node#node.key ->
    {ok,Node,Node#node.val};
search(nil,_) ->
    {error,not_found};
search(Node,Key) when Key<Node#node.key ->
    search(Node#node.left,Key);
search(Node,Key) ->
    search(Node#node.right,Key).

%% insert/3 (Tree,Key,Value) -> {ok,NewTree,OldValue/new}
insert(nil,Key,Value) ->
    {ok,Nowe} = new({Key,Value}),
    {ok,Nowe,new};
insert(Node,Key,Value) when Key==Node#node.key ->
    Nowe = #node{right=Node#node.right,
              left=Node#node.left,
              key=Key,
              val=Value},
    {ok,Nowe,Node#node.val};
insert(Node,Key,Value) when Key<Node#node.key ->
    case insert(Node#node.left,Key,Value) of
        {ok,T,S} ->
            {ok,Node#node{left=T},S}
    end;
insert(Node,Key,Value) ->
    case insert(Node#node.right,Key,Value) of
        {ok,T,S} ->
            {ok,Node#node{right=T},S}
    end.

%% finMax (Tree) -> {max,MaxValue}
findMax(nil) ->
    {error,not_found};
findMax(Node) when Node#node.right==nil ->
    {max,Node};
findMax(Node) ->
    findMax(Node#node.right).

%% delete/2 ? -> (Tree,Key) -> {ok,NewTree,Value}/{error_not_found}
delete(nil,_) ->
    {error,not_found};
delete(Node,Key) when Key==Node#node.key,
                      Node#node.left==nil,
                      Node#node.right==nil ->
    {ok,nil,Node#node.val};
delete(Node,Key) when Key==Node#node.key,
                      Node#node.left==nil ->
    {ok,Node#node.right,Node#node.val};
delete(Node,Key) when Key==Node#node.key,
                      Node#node.right==nil ->
    {ok,Node#node.left,Node#node.val };
delete(Node,Key) when Key==Node#node.key ->
    {max,MaxNode} = findMax(Node#node.left),
    {ok,Lewo,_} = delete(Node#node.left,MaxNode#node.key),
    {ok,Node#node{key=MaxNode#node.key,
                  val=MaxNode#node.val,
                  left=Lewo},Key};
delete(Node,Key) when Key<Node#node.key ->
    case delete(Node#node.left,Key) of
        {ok,T,S} ->
            {ok,Node#node{left=T},S};
        Err -> Err
    end;
delete(Node,Key) ->
    case delete(Node#node.right,Key) of
        {ok,T,S} ->
            {ok,Node#node{right=T},S};
        Err -> Err
    end.

zig(N,K) ->
    zig(N,N#node.left,K).
zig(nil,_,_) ->
    {error,zig};
zig(P,LeftP,Key) when LeftP#node.key==Key ->
    NewP = P#node{left = LeftP#node.right},
    NewX = LeftP#node{right = NewP},
    {ok,zig,NewX}.

zig_zig(nil,_) ->
    {error,not_found};
%% zig_zig(#node{ left=#node{left=X} = P} = G, Key) when Key<X#node.key ->
%%     {ok,zig_zig,R} = zig_zig(P,Key),
%%     {ok,zig_zig,G#node{left=R}};
zig_zig(#node{ left=#node{left=X} = P} = G, Key) when Key==X#node.key ->
    NewG = G#node{left=P#node.right},
    NewP = P#node{right=NewG},
    %% step2
    SuperNewP = NewP#node{left=X#node.right},
    NewX = X#node{right=SuperNewP},
    {ok,zig_zig,NewX};
%% zig_zig(#node{ right=#node{right=X} = P} = G, Key) when Key>X#node.key ->
%%     {ok,zig_zig,R} = zig_zig(P,Key),
%%     {ok,zig_zig,G#node{right=R}};
zig_zig(#node{ right=#node{right=X} =P} = G, Key) when Key==X#node.key ->
    NewG = G#node{right=P#node.left},
    NewP = P#node{left=NewG},
    %% step2
    SuperNewP = NewP#node{right=X#node.left},
    NewX = X#node{left=SuperNewP},
    {ok,zig_zig,NewX}.


zig_zag(#node{ left=#node{right=X} =P} = G, Key) when Key==X#node.key ->
    NewP = P#node{right=X#node.right},
    NewX = X#node{left=NewP},
    %% step2
    NewG = G#node{left=NewX#node.right},
    SuperNewX = NewX#node{right=NewG},
    {ok,zig_zag,SuperNewX};
zig_zag(#node{ right=#node{left=X} =P} = G, Key) when Key==X#node.key ->
    NewP = P#node{left=X#node.right},
    NewX = X#node{right=NewP},
    %% step2
    NewG = G#node{right=NewX#node.left},
    SuperNewX = NewX#node{left=NewG},
    {ok,zig_zag,SuperNewX}.


% test tree
t() ->
    {node,25,
      25,
      {node,9,
            9,
            {node,4,4,{node,1,1,nil,nil},nil},
            {node,16,16,nil,nil}},
      {node,36,36,nil,{node,49,49,nil,nil}}}.
