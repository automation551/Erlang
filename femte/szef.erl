%%%-------------------------------------------------------------------
%%% @author  <Kamil@ELEANOR>
%%% @copyright (C) 2010,
%%% @doc
%%%
%%% @end
%%% Created : 18 Apr 2010 by  <Kamil@ELEANOR>
%%%-------------------------------------------------------------------
-module(szef).
-import(robol).
-behaviour(gen_server).

%% API
-export([start_link/0,dodaj/0,ubij/1,start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE).


%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
start_link(monitor) ->
    gen_server:start({local,?SERVER},?MODULE,[self()],[]).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    process_flag(trap_exit,true),
    {ok, []};
init(X) ->
    process_flag(trap_exit,true),
    erlang:monitor(process,hd(X)),
    {ok,[]}.
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    io:format("stan szefa: ~p~n",[State]),
    case _Request of
        dodaj ->
            io:format("dodaje~n"),
            if
                length(State) == 0 ->
                    H = 0 ;
                true ->
                    H = hd(State)
            end,
            Pid = spawn(robol,start_link,[list_to_atom([H])]),
            Reply = {dodany,Pid},
            NewState = [H+1,State];
        {ubij,N} ->
            io:format("ubijam~n"),
            if
                length(State) == 0 ->
                    %%NewState = [],
                    Reply = {bylopusto_nicnieubite,[]},
                    io:format("stan pusty, nie ma kogo ubic~n") ;
                true ->
                    H = lists:nth(N,State),
                    try
                        robol:zabij(H),
                        {reply,{niezlapalem},State}
                    catch
                        throw:X ->
                            io:format("Throw: ~p~n",[X]),
                            {reply, {throw,caught,X}, State};
                        exit:X ->
                            io:format("exit: ~p~n",[X]),
                            {reply,{exit,caught,X}, State};
                        error:X ->
                            io:format("error: ~p~n",[X]),
                            {reply,{error,caught,X}, State}
                    end,
                    Reply = {ubity_i_wznowiony,H}
            end,
            NewState = State;
        X ->
            io:format("Lista exitow: ~p~n",[X]),
            Reply = ok,
            NewState = State
    end,
    {reply, Reply, NewState}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(Info, State) ->
    io:format("JESTEM W INFO: ~p~n",[Info]),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    %list:map(fun(X) -> robol:quit(X) end,_State),
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
dodaj() ->
    gen_server:call(?SERVER,dodaj).
ubij(N) ->
    gen_server:call(?SERVER,{ubij,N}).
