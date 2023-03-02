%%%-------------------------------------------------------------------
%%% @author SMash
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. март 2023 12:58
%%%-------------------------------------------------------------------
-module(trie_tests).

-include_lib("eunit/include/eunit.hrl").

-import(
trie,
[
new/0,
add/2,
add_leaf/2,
search/2,
search_leaf/2,
search_prefix/2,
search_prefix_leaf/2,
factorize/2,
compare/2
]
).

compare_eq_test() ->
  ?assertEqual(eq, trie:compare("a",      "a")),
  ?assertEqual(eq, trie:compare("a",      "abc")),
  ?assertEqual(eq, trie:compare("a",      "abcdef")),
  ok.

compare_lt_test() ->
  ?assertEqual(lt, trie:compare("a",      "b")),
  ?assertEqual(lt, trie:compare("a",      "bcd")),
  ?assertEqual(lt, trie:compare("abcdef", "bcd")),
  ok.

compare_gt_test() ->
  ?assertEqual(gt, trie:compare("a",      leaf)),
  ?assertEqual(gt, trie:compare("abc",    leaf)),

  ?assertEqual(gt, trie:compare("b",      "a")),
  ?assertEqual(gt, trie:compare("bcd",    "abc")),
  ?assertEqual(gt, trie:compare("bcd",    "abcdef")),
  ok.

factorize_test() ->
  ?assertEqual("a",     trie:factorize("a", "a")),
  ?assertEqual("hello", trie:factorize("hello", "hello")),

  ?assertEqual(["hel", "lo", "p"], trie:factorize("hello", "help")),
  ?assertEqual(["hel", "lo", "p"], trie:factorize("help", "hello")),

  ?assertEqual(["a", "b"], trie:factorize("a", "b")),
  ?assertEqual(["a", "b"], trie:factorize("b", "a")),

  ?assertEqual(["ca", "r", "ts"], trie:factorize("cats", "car")),
  ok.

add_simple_test() ->
  ?assertEqual([{"hello", [{leaf, []}]}], trie:add("hello", [])),
  ?assertEqual([{"hello", [{leaf, []}]}], trie:add("hello", [{"hello", [{leaf, []}]}])),

  ?assertEqual([{"hello", [{leaf, []}]},
    {"world", [{leaf, []}]}], trie:add("world", [{"hello", [{leaf, []}]}])),

  ?assertEqual([{"hello", [{leaf, []}, {"ween", [{leaf, []}]}]},
    {"world", [{leaf, []}]}], trie:add("helloween", [{"hello", [{leaf, []}]},
    {"world", [{leaf, []}]}])),

  ?assertEqual([{"hello", [{leaf, []}, {"ween", [{leaf, []}]}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}], trie:add("work", [{"hello", [{leaf, []}, {"ween", [{leaf, []}]}]},
    {"world", [{leaf, []}]}])),

  ?assertEqual([{"hello", [{leaf, []}, {"ween", [{leaf, []}]}]},
    {"lovely", [{leaf, []}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}], trie:add("lovely", [{"hello", [{leaf, []}, {"ween", [{leaf, []}]}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}])),

  ?assertEqual([{"hell", [{leaf, []}, {"o", [{leaf, []}, {"ween", [{leaf, []}]}]}]},
    {"lovely", [{leaf, []}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}], trie:add("hell", [{"hello", [{leaf, []}, {"ween", [{leaf, []}]}]},
    {"lovely", [{leaf, []}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}])),

  ?assertEqual([{"hell", [{leaf, []}, {"o", [{leaf,[]}, {"w", [{leaf, []}, {"een", [{leaf, []}]}]}]}]},
    {"lovely", [{leaf, []}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}], trie:add("hellow", [{"hell", [{leaf, []}, {"o", [{leaf, []}, {"ween", [{leaf, []}]}]}]},
    {"lovely", [{leaf, []}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}])),
  ok.

search_test() ->
  Leaves = [{"hell", [{leaf, []}, {"o", [{leaf, []}, {"w", [{leaf, []}, {"een", [{leaf, []}]}]}]}]},
    {"lovely", [{leaf, []}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}],

  ?assertEqual("hell",        trie:search("hell",      Leaves)),
  ?assertEqual("hello",       trie:search("hello",     Leaves)),
  ?assertEqual("hellow",      trie:search("hellow",    Leaves)),
  ?assertEqual("helloween",   trie:search("helloween", Leaves)),


  ?assertEqual("work",        trie:search("work",      Leaves)),
  ?assertEqual("world",       trie:search("world",     Leaves)),

  ?assertEqual("lovely",      trie:search("lovely",    Leaves)),

  ?assertEqual(undefined,     trie:search("hellween",  Leaves)),
  ?assertEqual(undefined,     trie:search("love",      Leaves)),
  ?assertEqual(undefined,     trie:search("wor",       Leaves)),
  ok.

search_prefix_test() ->
  Leaves = [{"hell", [{leaf, []}, {"o", [{leaf, []}, {"w", [{leaf, []}, {"een", [{leaf, []}]}]}]}]},
    {"lovely", [{leaf, []}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}],

  ?assertEqual("hell",        trie:search_prefix("hell",      Leaves)),
  ?assertEqual("hell",        trie:search_prefix("hello",     Leaves)),
  ?assertEqual("hell",        trie:search_prefix("helloween", Leaves)),

  ?assertEqual("work",        trie:search_prefix("work",      Leaves)),
  ?assertEqual("world",       trie:search_prefix("world",     Leaves)),

  ?assertEqual("lovely",      trie:search_prefix("lovely",    Leaves)),

  ?assertEqual(undefined,     trie:search_prefix("h",         Leaves)),
  ?assertEqual(undefined,     trie:search_prefix("lov",       Leaves)),
  ?assertEqual(undefined,     trie:search_prefix("wo",        Leaves)),
  ok.

new_test() ->
  ?assertEqual({root, []}, trie:new()),
  ok.

add_leaf_test() ->
  ?assertEqual({root, [{"hello", [{leaf, []}]}]}, trie:add_leaf("hello", trie:new())),

  ?assertEqual({root, [{"hello", [{leaf, []}, {"ween", [{leaf, []}]}]}]}, trie:add_leaf("helloween",
    trie:add_leaf("hello", trie:new()))),

  ?assertEqual({root, [{"hell", [{leaf, []}, {"o", [{leaf, []}, {"ween", [{leaf, []}]}]}]}]}, trie:add_leaf("hell",
    trie:add_leaf("helloween",
      trie:add_leaf("hello", trie:new())))),
  ok.

search_leaf_test() ->
  Tree = {root, [{"hell", [{leaf, []}, {"o", [{leaf,[]}, {"w", [{leaf, []}, {"een", [{leaf, []}]}]}]}]},
    {"lovely", [{leaf, []}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}]},

  ?assertEqual("hell",        trie:search_leaf("hell",      Tree)),
  ?assertEqual("hello",       trie:search_leaf("hello",     Tree)),
  ?assertEqual("hellow",      trie:search_leaf("hellow",    Tree)),
  ?assertEqual("helloween",   trie:search_leaf("helloween", Tree)),
  ?assertEqual(undefined,   trie:search_leaf("hellowen", Tree)),
  ok.

search_prefix_leaf_test() ->
  Tree = {root, [{"hell", [{leaf, []}, {"o", [{leaf,[]}, {"w", [{leaf, []}, {"een", [{leaf, []}]}]}]}]},
    {"lovely", [{leaf, []}]},
    {"wor", [{"k", [{leaf, []}]}, {"ld", [{leaf, []}]}]}]},

  ?assertEqual("hell",        trie:search_prefix_leaf("hell",         Tree)),
  ?assertEqual("hell",        trie:search_prefix_leaf("hello",        Tree)),
  ?assertEqual("hell",        trie:search_prefix_leaf("helloween",    Tree)),
  ok.
