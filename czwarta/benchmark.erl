
-module(benchmark).
-export([start/0]).

start() ->
    S1 = statistics:start(),
    S2 = statistics:start(),

    {R1,_L1} = ring:start(self(),S1,10,0), %nadzorca,statystyki,dlugosc,id
    Steps1 = 1000000,
    S1 ! {token,start,0,Steps1,now()},
    R1 ! {0,Steps1,ring:now_plus(1)},
    S1 ! {token,report},
    S1 ! {ring,report},
    %
    {R2,_L2} = ring:start(self(),S1,30000,1), %nadzorca,statystyki,dlugosc,id
    Steps2 = 1000000,
    S1 ! {token,start,1,Steps2,now()},
    R2 ! {1,Steps2,ring:now_plus(20)},
    S1 ! {token,report},
    S1 ! {ring,report},
    {S1,S2}.
