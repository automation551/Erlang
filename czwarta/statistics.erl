-module(statistics).
-export([start/0]).

-record(token,{startTime,stopTime,steps,stepsDone,processNum}).
-record(ring,{startTime,stopTime,length}).
-record(info,{content=[]}).


start() ->
    Pid = spawn(statistics,collect,[]).

collect(Data) ->

    receive
        {ring,start,RingId,Length,CurrentTime} ->
            collect(newData).
            ;
        {ring,stop,RingId,CurrentTime} ->
            
            ;
        {token,start,TokenId,Steps,CurrentTime} ->
            
            ;
        {token,stop,TokenId,Steps,ProcessNum,CurrentTime} ->
            
            ;
        {Atom,report} ->
            
            ;
        {Atom,reset} ->
            
            ;
        stop ->
            true
   end.
