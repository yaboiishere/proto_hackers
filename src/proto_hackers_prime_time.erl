-module(proto_hackers_prime_time).
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
      case (parse_request(Data)) of
        {malformed_request, Response} ->
          io:format("Malformed request: ~p~n", [Data]),
          gen_tcp:send(Connection, Response),
          gen_tcp:close(Connection);
        {ok, Response} ->
          io:format("Sending response: ~p~n", [iolist_to_binary([Response, <<"\n">>])]),
          gen_tcp:send(Connection, iolist_to_binary([Response, <<"\n">>])),
          io:format("Neeeext~n", []),
          do_recv(Connection, [Bs, Data])
      end;
    {error, closed} ->
      io:format("Connection closed~p~n", [Connection]),
      gen_tcp:close(Connection),
      {ok, list_to_binary(Bs)}
  end.

parse_request(Binary) ->
      Decoded = try jiffy:decode(Binary, [return_maps]) of
                  D -> D
                catch
                  _:_ -> malformed_request
                end,
      case validate_input(Decoded) of
        malformed_request ->
          {malformed_request, jiffy:encode(#{method => <<"isPrime">>, error => "Malformed request"})};
        Resp when is_boolean(Resp) ->
          {ok, jiffy:encode(#{method => <<"isPrime">>, prime => Resp})}
      end.


validate_input(#{<<"method">> := <<"isPrime">>, <<"number">> := Number}) when is_integer(Number) ->
      is_prime(Number);

validate_input(Request) ->
      io:format("Malformed request: ~p~n", [Request]),
      malformed_request.

is_prime(1) -> false;
is_prime(N) -> is_prime(N,2).
is_prime(N,N) -> true;
is_prime(N,M)->
  ChPrime = N rem M,
  if 
    ChPrime == 0 -> false;
    true -> is_prime(N,M+1)
end.
