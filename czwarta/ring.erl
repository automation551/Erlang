-module(ring).
-export([start/4,process/4,loop/4]).

start(Pnadzorca,Pstats,Pdlugosc,RingId) ->
    %Pstats ! {ring,start,RingId,Pdlugosc,now()},

    Ring = pierwszy(10,Pnadzorca,Pstats),

    %Pnadzorca ! {ring,created,RingId},
    %Pstats ! {ring,stop,RingId,now()},
    Ring.




pierwszy(N,Pnadzorca,Pstats) ->
    Sasiad = spawn(ring,process,[N-1,Pnadzorca,Pstats,self()]).

process(0,Pnadzorca,Pstats,PFirst) ->
    loop(Pnadzorca,Pstats,PFirst,0);
process(N,Pnadzorca,Pstats,PFirst) ->
    Sasiad = spawn(ring,process,[N-1,Pnadzorca,Pstats,PFirst]),
    loop(Pnadzorca,Pstats,Sasiad,N).


loop(Nadzorca,Stats,Sasiad,Id) ->
    io:format("slucham: ~p~n",[Id]),
   receive
        {TokenId,0,_} ->
           io:format("mam wiadomosc ~p~n",[Id]),
            Stats ! {token,stop,TokenId,0,Id,now()} ;
        {TokenId,Steps,StopTime} ->
            Now = now(),
            if
                StopTime < Now ->
                    Stats ! {token,stop,TokenId,Steps,Id,now()};
               true ->
                    Sasiad ! {TokenId,Steps-1,StopTime},
                    io:format("przesylam dalej: ~p~n",[Id]),
                    loop(Nadzorca,Stats,Sasiad,Id)
            end;
        stop ->
            Sasiad ! stop,
            true
    end.
