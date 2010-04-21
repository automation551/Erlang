%% prawie jak w Pragmatic Programing Erlang (strona 311)
-module(my_bank).
-export([start/0,stop/0]).
-export([init/1,handle_call/3,
         handle_cast/2,handle_info/2,
         terminate/2]).
-import(genServ).
-compile(export_all).
start() ->
    genServ:start(super_bank,?MODULE,[]).
stop() ->
    genServ:call(super_bank,stop).

new_account(Who) ->
    genServ:call(super_bank,{new,Who}).
deposit(Who,Amount) ->
    genServ:call(super_bank,{add,Who,Amount}).
withdraw(Who,Amount) ->
    genServ:call(super_bank,{remove,Who,Amount}).
escape_to_mexico() ->
    genServ:cast(super_bank,{mexico}).

init([]) ->
    {ok,ets:new(?MODULE,[])}.

handle_call({new,Who},_From,Tab) ->
    Reply = case ets:lookup(Tab,Who) of
                [] ->
                    ets:insert(Tab,{Who,0}),
                    {welcome,Who};
                [_] -> {Who, you_already_are_a_customer}
            end,
    {reply,Reply,Tab};
handle_call({add,Who,X},_From,Tab) ->
    Reply = case ets:lookup(Tab,Who) of
                [] ->
                     not_a_customer;
                [{Who,Balance}] ->
                    NewBalance = Balance+X,
                    ets:insert(Tab,{Who,NewBalance}),
                    {thanks,Who,your_balance_is,NewBalance}
            end,
    {reply,Reply,Tab};
handle_call({remove,Who,X},_From,Tab) ->
    Reply = case ets:lookup(Tab,Who) of
                [] ->
                    not_a_customer;
                [{Who,Balance}] when X =< Balance ->
                    NewBalance = Balance-X,
                    ets:insert(Tab,{Who,NewBalance}),
                    {thanks,Who,your_balance_is,NewBalance};
                [{Who,Balance}] ->
                    {sorry,Who,you_only_have,Balance,in_the_bank}
            end,
    {reply,Reply,Tab};
handle_call(stop,_From,Tab) ->
    {stop,normal,stopped,Tab}.
handle_cast({mexico},Tab) ->
    ets:delete_all_objects(Tab),
    {noreply,Tab};
handle_cast(_Msg,State) ->
    {noreply,State}.
handle_info(timeout,State) ->
    io:format("handle_info: timeout, State-> ~p~n",[State]),
    {noreply,State};
handle_info(_Info,State) ->
    {noreply,State}.
terminate(_Reason,_State) ->
    ok.

