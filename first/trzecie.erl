-module(trzecie).
-export([ljust/2,rjust/2,centre/2]).

ljust(String,Width) when length(String) >= Width andalso is_integer(Width) ->
    String;
ljust(String,Width) when is_integer(Width) ->
    ljust([" "|String],Width).


rjust(String,Width) when length(String) >= Width andalso is_integer(Width) ->
    String;
rjust(String,Width) when is_integer(Width) ->
    rjust(String++" ",Width).

centre(String,Width) when length(String) >= Width andalso is_integer(Width) ->
    String;
centre(String,Width) when is_integer(Width) ->
    centre([" "|String]++" ",Width).
