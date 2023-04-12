-module(tcp_echo).
-export([start_link/1]).

start_link(Port) ->
  {ok, spawn(fun() -> init(Port) end)}.

init(Port) ->
  {ok, Socket} = gen_tcp:listen(Port, [binary, {reuseaddr, false}, {active, false}]),
  io:format("Listening on port ~p~n", [Port]),
  server_loop(Socket).


server_loop(Socket) ->
  {ok, Connection} = gen_tcp:accept(Socket),
  Handler = spawn(fun() -> do_recv(Connection, []) end),
  gen_tcp:controlling_process(Connection, Handler),
  io:format("Connection from ~p~n", [Connection]),
  server_loop(Socket).

do_recv(Connection, Bs) ->
  case gen_tcp:recv(Connection, 0) of
    {ok, Data} ->
      io:format("Received: ~p~n", [Data]),
      gen_tcp:send(Connection, Data),
      do_recv(Connection, [Bs, Data]);
    {error, closed} ->
      io:format("Connection closed~p~n", [Connection]),
      {ok, list_to_binary(Bs)}
  end.
