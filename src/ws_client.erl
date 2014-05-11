-module(ws_client).

-behaviour(websocket_client_handler).

-export([
         start_link/0,
         init/2,
         websocket_handle/3,
         websocket_info/3,
         websocket_terminate/3
        ]).

start_link() ->
    crypto:start(),
    ssl:start(),
    Name = re:replace(os:cmd("whoami"), "\\s+", "", [{return, list}]),
    websocket_client:start_link("ws://192.168.1.36:8080/?name="++Name, ?MODULE, []).

init([], _ConnState) ->
    websocket_client:cast(self(), {text, <<"message 1">>}),
    register(ws_client, self()),
    {ok, undefined}.

websocket_handle({pong, _}, _ConnState, State) ->
    {ok, State};

websocket_handle({text, Msg}, _ConnState, State) ->
    io:format("Received msg ~p~n", [Msg]),
    {ok, State}.

websocket_info(start, _ConnState, State) ->    
    {ok, State};

websocket_info({text, Msg}, _ConnState, State) -> 
    {reply, {text, Msg}, State}.

websocket_terminate(Reason, _ConnState, State) ->
    io:format("Websocket closed in state ~p wih reason ~p~n",
              [State, Reason]),
    ok.
