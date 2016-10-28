-module(encode_decode_handler).
-behaviour(sheep_http).

-export([init/3, read/2, sheep_init/2 ]).

-include("sheep.hrl").

init(_Transport, Req, _Opts) ->
    {upgrade, protocol, sheep_http, Req, []}.


-spec sheep_init(sheep_request(), term()) -> {map(), term()}.
sheep_init(_Request, _Opts) ->
    Options =
        #{
            decode_spec =>
            #{
                <<"application/json">> =>
                fun(Data) ->
                    M = jiffy:decode(Data, [return_maps]),
                    M#{custom_encoder => ok}
                end
            },
            encode_spec =>
            #{
                <<"application/json">> =>
                fun(Data) ->
                    jiffy:encode(Data#{custom_decoder => ok})
                end
            }
        },
    State = [],
    {Options, State}.


-spec read(sheep_request(), term()) -> sheep_response().
read(#{bindings := #{<<"kind">> := <<"empty">>}} = _Request, _State) ->
    sheep_http:response(#{status_code => 204});

read(#{bindings := #{<<"kind">> := <<"empty_404">>}} = _Request, _State) ->
    sheep_http:response(#{status_code => 404});

read(#{bindings := #{<<"kind">> := <<"undefined">>}} = _Request, _State) ->
    sheep_http:response(#{status_code => 204});

read(#{body := Body}, _State)->
    Body2 = Body#{readed => true},
    sheep_http:response(#{status_code => 200, body => Body2}).
