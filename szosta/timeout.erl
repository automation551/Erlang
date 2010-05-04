-module(timeout).
-export([server/0,send/3,proxy/2]).

proxy(Name,{request,From,Request}) ->
    Name ! {request,self(),Request},
    receive
        X ->
            From ! X
    end.

send(Name,Request,Timeout) ->
  Pid = spawn(fun () ->
                  proxy(Name,Request) end),
  receive
    X ->
      X
  after Timeout ->
    exit(Pid,kill),
    {error,timeout}
  end.



server() ->
    receive
        {request,From,Request} ->
            spawn(fun() -> oblicz_wazne_rzeczy(From,Request) end),
            server();
        _ ->
            server()
    end.

oblicz_wazne_rzeczy(From,Request) ->
    case Request of
        10 ->
            timer:sleep(10000),
            From ! {response,12345678};
        X ->
            From ! {response,X}
    end.

%% S = spawn(timeout,server,[])
%% register(ss,S)
%% timeout:send(ss,{request,self(),10},10000).
%% flush
