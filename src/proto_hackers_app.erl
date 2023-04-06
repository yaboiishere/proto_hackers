%%%-------------------------------------------------------------------
%% @doc proto_hackers public API
%% @end
%%%-------------------------------------------------------------------

-module(proto_hackers_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    proto_hackers_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
