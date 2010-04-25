-module(superv).
-export([start/1,mknodes/1,start/2,add_host/2,remove_host/2,
	 stop/1,choose_node/1]).
-define(TIMEOUT,1000).
-define(PINGTIME,10).

start(Name) ->
    Hosts = net_adm:host_file(),
    start(Name,Hosts).

mknodes({Name,Hosts}) ->
   %io:format("name-> ~p :: hosts-> ~p~n",[Name,Hosts]),
    N = lists:map(fun (X) ->
		      slave:start_link(X,Name) end,
	      Hosts),
    Nn = lists:filter(fun ({A,_}) -> A==ok end,N),
    Nodes = lists:map(fun ({_,X}) -> X end,Nn),
   %io:format("nodes-> ~p~n",[Nodes]),
   %rpc:eval_everywhere(application,start,[sasl]),
   %rpc:eval_everywhere(application,start,[os_mon]),
    lists:map(fun (X) -> rpc:cast(X,application,start,[sasl]) end,nodes()),
    lists:map(fun (X) -> rpc:cast(X,application,start,[os_mon]) end,nodes()),
    loop(Name,Nodes).

stop(Name) ->
    Name ! stop.

start(Name,Hosts) ->
    P = spawn(?MODULE,mknodes,[{Name,Hosts}]),
    register(Name,P),
    P.

add_host(Name,NewNode) ->
    Name ! {new,NewNode}.

remove_host(Name,Node) ->
    Name ! {remove,Node}.

choose_node(Name) ->
    Name ! choose.

loop(Name,Nodes) ->
    receive
	stop ->
	    lists:map(fun (X) ->
			      slave:stop(X) end,
		      Nodes);
	    %slave:stop(node());
	{new,Host} -> 
	    slave:start_link(Host,Name),
	    loop(Name,Nodes);
	{remove,Host} ->
	    N = atom_to_list(Name),
	    H = atom_to_list(Host),
	    A = atom_to_list('@'),
	    Node = list_to_atom(N++A++H),
	    slave:stop(Node),
	    loop(Name,nodes());
	choose ->
	    lists:map(fun (X) -> rpc:cast(X,application,start,[os_mon]) end,nodes()),
	    W = lists:map(fun (X) ->
			      {X,
			       rpc:call(X,cpu_sup,util,[],?TIMEOUT)} end,
		      Nodes),
	    io:format("cpu_sup-> ~p~n",[W]),
	    loop(Name,Nodes);
	X ->
	    io:format("nieznane zachowanie: ~p~n",[X])
    after ?PINGTIME ->
	    PongPang = lists:map(fun(X) -> {X,net_adm:ping(X)} end,Nodes),
	    Down = lists:filter(fun ({_,B}) -> B == pang end,PongPang),
	    lists:foreach(fun ({X,_}) -> 
				  T = string:tokens(atom_to_list(X),"@"),
				  N = hd(T),
				  H = hd(tl(T)),
				  io:format("RE: name->~p, host->~p~n",[N,H]),
				  case slave:start_link(H,N) of
				      {ok,_B} -> io:format("ok~n"),ok;
				      _ -> io:format("failed~n")
				  end
			  end,Down),
	    loop(Name,nodes())

    end.
	    
