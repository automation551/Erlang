-module(timeout).
-export([server/0,send/3,send/4,proxy/3]).

proxy(Name,{request,_From,Request},Timeout) ->
    Name ! {request,self(),Request},
    receive
        X ->
            _From ! X
    after Timeout ->
       _From ! {error,timeout}
    end.

send(Name,Request,Timeout) ->
    spawn(fun () ->
                  proxy(Name,Request,Timeout) end).

send(Node,Name,Request,Timeout) ->
    spawn(Node,fun () ->
                       proxy(Name,Request,Timeout) end).


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
