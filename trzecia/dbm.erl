-module(dbm).
-export([create/1,insert/2,select/2]).

-record(db, {name,id,fields,content}).


create({Name,Fields}) ->
    {ok,#db{name=Name,id=1,fields=Fields,content=[]}};
create(_) ->
    {error,description}.

insert(Db,Data) ->
    Id=Db#db.id,
    {Id,Db#db{id=Id+1,content=[{Id,Data}|Db#db.content]}}.

%% select(Baza,(fun(Rekord) -> Rekord#nazwa.pole==costam end)).
select(Db,Pred) ->
    try
        Results = lists:filter(fun ({_,Rekord}) ->
                        Pred(Rekord) end,Db#db.content),
        {ok,Results}
    catch
        _:_ -> {error,wrong_query}
    end.
