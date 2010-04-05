-module(statistics).
-export([start/0,collect/4]).

-record(token,{startTime,stopTime,steps,stepsLeft,processNum}).
-record(ring,{startTime,stopTime,length}).
-record(info,{content=[]}).


start() ->
    Pid=spawn(statistics,collect,[dict:new(),dict:new(),dict:new(),dict:new()]),
    Pid.



collect(RingStart,RingStop,TokenStart,TokenStop) ->
    io:format("Collect!~n"),
    receive
        {ring,start,RingId,Length,CurrentTime} ->
            collect(RingStart,RingStop,TokenStart,TokenStop);
        {ring,stop,RingId,CurrentTime} ->
            collect(RingStart,RingStop,TokenStart,TokenStop);
        {token,start,TokenId,Steps,CurrentTime} ->
            D = dict:store(TokenId,{Steps,CurrentTime},TokenStart),
            collect(RingStart,RingStop,D,TokenStop);

        {token,stop,TokenId,StepsLeft,ProcessNum,CurrentTime} ->
            {Steps,StartTime} = dict:fetch(TokenId,TokenStart),
            %TimeDiff = timer:now_diff(now(),StartTime),
            New = #token{startTime=StartTime,stopTime=CurrentTime,
                         steps=Steps,stepsLeft=StepsLeft,processNum=ProcessNum},
            NT = dict:store(TokenId,New,TokenStop),
            collect(RingStart,RingStop,TokenStart,NT) ;

        {_Atom,report} ->
            case _Atom of
                ring ->
                    io:format("ring: ~p~n",[RingStop]);
                token ->
                    io:format("token: ~p~n",[TokenStop])
            end,
            collect(RingStart,RingStop,TokenStart,TokenStop);

        {_Atom,reset} ->
            case _Atom of
                ring ->
                    collect(dict:new(),dict:new(),TokenStart,TokenStop);
                token ->
                    collect(RingStart,RingStop,dict:new(),dict:new())
            end,
        {ring,destroyed,Ring_id} ->
            collect(RingStart,RingStop,TokenStart,TokenStop);

        stop ->
            true ;
        X ->
            io:format(X),
            collect(RingStart,RingStop,TokenStart,TokenStop)

   end.
