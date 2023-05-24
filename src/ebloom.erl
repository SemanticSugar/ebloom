%% -------------------------------------------------------------------
%%
%% Copyright (c) 2010 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

-module(ebloom).

-export([new/3, insert/2, contains/2, clear/1, compatible/2, predicted_elements/1,
         desired_fpp/1, random_seed/1, size/1, elements/1, effective_fpp/1, intersect/2, union/2,
         difference/2, serialize/1, deserialize/1]).

-on_load init/0.

-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").

-endif.

-opaque t() :: reference().

-export_type([t/0]).

-spec init() -> ok | {error, any()}.
init() ->
    SoName =
        case code:priv_dir(ebloom) of
            {error, bad_name} ->
                case code:which(?MODULE) of
                    Filename when is_list(Filename) ->
                        filename:join([filename:dirname(Filename), "../priv", "ebloom_nifs"]);
                    _ ->
                        filename:join("../priv", "ebloom_nifs")
                end;
            Dir ->
                filename:join(Dir, "ebloom_nifs")
        end,
    erlang:load_nif(SoName, 0).

-spec new(integer(), float(), integer()) -> {ok, t()}.
new(_Count, _FalseProb, _Seed) ->
    erlang:nif_error({error, not_loaded}).

-spec insert(t(), binary()) -> ok.
insert(_Ref, _Bin) ->
    erlang:nif_error({error, not_loaded}).

-spec contains(t(), binary()) -> true | false.
contains(_Ref, _Bin) ->
    erlang:nif_error({error, not_loaded}).

-spec clear(t()) -> ok.
clear(_Ref) ->
    erlang:nif_error({error, not_loaded}).

-spec compatible(t(), t()) -> boolean().
compatible(_Ref1, _Ref2) ->
    erlang:nif_error({error, not_loaded}).

-spec predicted_elements(t()) -> integer().
predicted_elements(_Ref) ->
    erlang:nif_error({error, not_loaded}).

-spec desired_fpp(t()) -> float().
desired_fpp(_Ref) ->
    erlang:nif_error({error, not_loaded}).

-spec random_seed(t()) -> integer().
random_seed(_Ref) ->
    erlang:nif_error({error, not_loaded}).

-spec size(t()) -> integer().
size(_Ref) ->
    erlang:nif_error({error, not_loaded}).

-spec elements(t()) -> integer().
elements(_Ref) ->
    erlang:nif_error({error, not_loaded}).

-spec effective_fpp(t()) -> float().
effective_fpp(_Ref) ->
    erlang:nif_error({error, not_loaded}).

-spec intersect(t(), t()) -> ok.
intersect(_Ref, _OtherRef) ->
    erlang:nif_error({error, not_loaded}).

-spec union(t(), t()) -> ok.
union(_Ref, _OtherRef) ->
    erlang:nif_error({error, not_loaded}).

-spec difference(t(), t()) -> ok.
difference(_Ref, _OtherRef) ->
    erlang:nif_error({error, not_loaded}).

-spec serialize(t()) -> binary().
serialize(_Ref) ->
    erlang:nif_error({error, not_loaded}).

-spec deserialize(binary()) -> {ok, t()}.
deserialize(_Bin) ->
    erlang:nif_error({error, not_loaded}).

%% ===================================================================
%% EUnit tests
%% ===================================================================
-ifdef(TEST).

basic_test() ->
    {ok, Ref} = new(5, 0.01, 123),
    0 = elements(Ref),
    insert(Ref, <<"abcdef">>),
    true = contains(Ref, <<"abcdef">>),
    false = contains(Ref, <<"zzzzzz">>).

union_test() ->
    {ok, Ref} = new(5, 0.01, 123),
    {ok, Ref2} = new(5, 0.01, 123),
    insert(Ref, <<"abcdef">>),
    false = contains(Ref2, <<"abcdef">>),
    union(Ref2, Ref),
    true = contains(Ref2, <<"abcdef">>).

serialize_test() ->
    {ok, Ref} = new(5, 0.01, 123),
    {ok, Ref2} = new(5, 0.01, 123),
    Bin = serialize(Ref),
    Bin2 = serialize(Ref2),
    true = Bin =:= Bin2,
    insert(Ref, <<"abcdef">>),
    Bin3 = serialize(Ref),
    {ok, Ref3} = deserialize(Bin3),
    true = contains(Ref3, <<"abcdef">>),
    false = contains(Ref3, <<"rstuvw">>).

clear_test() ->
    {ok, Ref} = new(5, 0.01, 123),
    0 = elements(Ref),
    insert(Ref, <<"1">>),
    insert(Ref, <<"2">>),
    insert(Ref, <<"3">>),
    3 = elements(Ref),
    clear(Ref),
    0 = elements(Ref),
    false = contains(Ref, <<"1">>).

compatibility_test() ->
    {ok, Ref1} = new(5, 0.01, 123),
    {ok, Ref2} = new(5, 0.01, 123),
    {ok, Ref3} = new(6, 0.01, 123),
    {ok, Ref4} = new(5, 0.02, 123),
    {ok, Ref5} = new(5, 0.01, 124),
    true = compatible(Ref1, Ref2),
    false = compatible(Ref1, Ref3),
    false = compatible(Ref1, Ref4),
    false = compatible(Ref1, Ref5).

parameter_test() ->
    {ok, Ref1} = new(5, 0.01, 123),
    5 = predicted_elements(Ref1),
    0.01 = desired_fpp(Ref1),
    123 = random_seed(Ref1).

union_increments_elements_counter_test() ->
    {ok, Ref1} = new(5, 0.01, 123),
    {ok, Ref2} = new(5, 0.01, 123),
    0 = elements(Ref1),
    insert(Ref1, <<"1">>),
    1 = elements(Ref1),
    insert(Ref2, <<"2">>),
    insert(Ref2, <<"3">>),
    2 = elements(Ref2),
    union(Ref1, Ref2),
    3 = elements(Ref1).

-endif.
