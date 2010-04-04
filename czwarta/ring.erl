-module(ring).
-export([start/4,process/5,first/4,now_plus/1]).

start(Pid_super,Pid_stats,Len,Ring_id) ->
    Pid_stats ! {ring,start,Ring_id,Len,now()},

    Ring = spawn(ring,first,[Len,Pid_super,Pid_stats,Ring_id]),
    {Ring,Len}.

first(N,Pid_super,Pid_stats,Ring_id) ->
    Next = spawn(ring,process,[N-1,Pid_super,Pid_stats,self(),Ring_id]),
    loop(Pid_super,Pid_stats,Next,N,Ring_id).

process(0,Pid_super,Pid_stats,Pid_first,Ring_id) ->
    Pid_super ! {ring,created,Ring_id},
    Pid_stats ! {ring,stop,Ring_id,now()},
    loop(Pid_super,Pid_stats,Pid_first,0,Ring_id);
process(N,Pid_super,Pid_stats,Pid_first,Ring_id) ->
    Next = spawn(ring,process,[N-1,Pid_super,Pid_stats,Pid_first,Ring_id]),
    loop(Pid_super,Pid_stats,Next,N,Ring_id).


loop(Pid_super,Pid_stats,Pid_next,Id,Ring_id) ->
    %io:format("slucham: ~p~n",[Id]),
   receive
        {TokenId,0,_} ->
    %       io:format("mam wiadomosc ~p~n",[Id]),
            Pid_stats ! {token,stop,TokenId,0,Id,now()},
            loop(Pid_super,Pid_stats,Pid_next,Id,Ring_id);
        {TokenId,Steps,StopTime} ->
            Now = now(),
            if
               StopTime < Now ->
                   Pid_stats ! {token,stop,TokenId,Steps,Id,now()},
                   loop(Pid_super,Pid_stats,Pid_next,Id,Ring_id);
              true ->
                   Pid_next ! {TokenId,Steps-1,StopTime},
     %             io:format("przesylam dalej: ~p~n",[Id]),
                   loop(Pid_super,Pid_stats,Pid_next,Id,Ring_id)
           end;
        {stop,0} ->
           Pid_stats ! {ring,destroyed,Ring_id},
           true;
        {stop,N}  ->
     %       io:format("zamykam ~p~n",[Id]),
           Pid_next ! {stop,N-1},
           true
    end.


now_plus(Seconds) ->
    {A,S,C} = now(),
    {A,S+Seconds,C}.
