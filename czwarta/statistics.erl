-module(statistics).
-export([start/0,collect/4]).

-record(token,{startTime,stopTime,steps,stepsLeft,processNum}).
-record(ring,{startTime,stopTime,length}).


start() ->
    Pid=spawn(statistics,collect,[dict:new(),dict:new(),dict:new(),dict:new()]),
    Pid.



collect(RingStart,RingStop,TokenStart,TokenStop) ->
   % io:format("Collect!~n"),
    try
    receive
        {ring,start,RingId,Length,CurrentTime} ->
            D = dict:store(RingId,{CurrentTime,Length},RingStart),
            collect(D,RingStop,TokenStart,TokenStop);
        {ring,stop,RingId,CurrentTime} ->
            {StartTime,Length} = dict:fetch(RingId,RingStart),
            New = #ring{startTime=StartTime,stopTime=CurrentTime,length=Length},
            NT = dict:store(RingId,New,RingStop),
            collect(RingStart,NT,TokenStart,TokenStop);
        {token,start,TokenId,Steps,CurrentTime} ->
            D = dict:store(TokenId,{Steps,CurrentTime},TokenStart),
            collect(RingStart,RingStop,D,TokenStop);

        {token,stop,TokenId,StepsLeft,ProcessNum,CurrentTime} ->
            try
                {Steps,StartTime} = dict:fetch(TokenId,TokenStart),
                New = #token{startTime=StartTime,stopTime=CurrentTime,
                             steps=Steps,stepsLeft=StepsLeft,
                             processNum=ProcessNum},
                NT = dict:store(TokenId,New,TokenStop),
                collect(RingStart,RingStop,TokenStart,NT)
            catch
                _:_ -> io:format("Chyba nie wys³a³e¶ wiadomo¶ci {token,start..}")
            end,
            %TimeDiff = timer:now_diff(now(),StartTime),
            collect(RingStart,RingStop,TokenStart,TokenStop);
        {_Atom,report} ->
            case _Atom of
                ring ->
                    lists:foreach( fun({Key,{_,T1,T2,Len}}) ->
                                           io:format("Czas utworzenie pierscienia (~p) dlugosci: ~p, to: ~p s~n",[Key,Len,timer:now_diff(T2,T1)/10000000])
                                           end,
                                   dict:to_list(RingStop));
                token ->
                    lists:foreach( fun({Key,{_,T1,T2,Len,Left,_}}) ->
                                           io:format("Token nr: ~p, dlugosc pakietu: ~p, pozostalo: ~p, czas: ~p s~n",[Key,Len,Left,timer:now_diff(T2,T1)/1000000])
                                           end,
                                   dict:to_list(TokenStop))
            end,
            collect(RingStart,RingStop,TokenStart,TokenStop);
        {_Atom,reset} ->
            case _Atom of
                ring ->
                    collect(dict:new(),dict:new(),TokenStart,TokenStop);
                token ->
                    collect(RingStart,RingStop,dict:new(),dict:new())
            end;
        {ring,destroyed,RingId} ->
            N = dict:erase(RingId,RingStart),
            collect(N,RingStop,TokenStart,TokenStop);
        stop ->
            true ;
        X ->
            io:format("co¶ nie tego? ~p~n",[X]),
            collect(RingStart,RingStop,TokenStart,TokenStop)

   end
   catch
       _:_ -> io:format("")
   end.
