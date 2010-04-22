-module(genServ).
-export([start/2, start/3, start_link/2, start_link/3,
         call/2, call/3, cast/2, reply/2,init/1]).
%-compile(export_all).

start(Module, Args) ->
    Pid = spawn(?MODULE,init,[{Module,Args}]),
    {ok,Pid}.
start(ServerName, Module, Args) ->
    {ok,Pid} = start(Module,Args),
    register(ServerName,Pid),
    {ok,Pid}.

start_link(Module,Args) ->
    process_flag(trap_exit, true),
    Pid = spawn_link(Module,init,[Args]),
    {ok,Pid}.
start_link(ServerName, Module, Args) ->
    {ok,Pid} = start_link(Module,Args),
    register(ServerName,Pid),
    {ok,Pid}.

call(Server, Request) ->
    call(Server,Request,10000).
call(Server, Request, Timeout) ->
    Server ! {call,self(),Request},
    receive
        {reply,Reply} ->
             Reply,
            io:format("Reply: ~p~n",[Reply])
    after Timeout ->
             throw({error,timeout})
    end.

cast(Server, Request) ->
    Server ! {cast,Request},
    ok.

reply(Client,Reply) ->
    Client ! {reply,Reply}.

init({Module,Args}) ->
    case Module:init(Args) of
        {ok,NewState} ->
            loop({Module,NewState,10000});
        {ok,NewState,Timeout} ->
            loop({Module,NewState,Timeout});
        {stop,Reason} ->
            terminate(Reason,[])
    end.

loop({Module,State,Timeout}) ->
    %io:format("loop...~n"),
    receive
        {call,From,Msg} ->
            case Module:handle_call(Msg,From,State) of
                {reply,Reply,NewState} -> reply(From,Reply),
                                          loop({Module,NewState,10000});
                {reply,Reply,NewState,Timeout} -> reply(From,Reply),
                                                  loop({Module,NewState,Timeout});
                {stop,Reason,Reply,NewState} -> reply(From,Reply),
                                                Module:terminate(Reason,NewState);
                _ -> throw(unknown_response)
            end;
        {cast,Request} ->
            case Module:handle_cast(Request,State) of
                {noreply,NewState} -> loop({Module,NewState,10000});
                {noreply,NewState,Timeout} -> loop({Module,NewState,Timeout});
                {stop,Reason,NewState} -> terminate(Reason,NewState) ;
                _ -> throw(unknown_response)
            end;
        stop ->
            ok
            %%reply(From,terminate(stop,State))
    after Timeout ->
            _ = Module:handle_info(timeout,State),
            loop({Module,State,Timeout})
    end.

terminate(_Reason,_State) ->
    ok.



