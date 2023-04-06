-module(tcp_echo).
-export([init/1]).

init(Port) ->
  {ok, Socket} = gen_tcp:listen(Port, [binary, {reuseaddr, true}, {packet, 0}]),
  io:format("Listening on port ~p~n", [Port]),
  server_loop(Socket).


server_loop(Socket) ->
  {ok, Connection} = gen_tcp:accept(Socket),
  Handler = spawn(fun() -> do_recv(Connection) end),
  gen_tcp:controlling_process(Connection, Handler),
  io:format("Connection from ~p~n", [Connection]),
  server_loop(Socket).

do_recv(Connection) ->
  receive 
    {tcp, Connection, Data} ->
      io:format("Received: ~p~n", [Data]),
      gen_tcp:send(Connection, Data),
      do_recv(Connection);
    {tcp_closed, Connection} ->
      io:format("Connection closed~p~n", [Connection]);
  end.
