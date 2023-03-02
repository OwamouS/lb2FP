Машковцев А. Л. Р34102
Функциональное программирование. Лабораторная работа №2 - prefix tree(trie). Erlang
=====
Базовые функции префиксного дерева:
-----
Добавление листа дерева:
```
-spec add(nonempty_string(), [leaf()]) -> [leaf()].
add(Str, Leaves) ->
  add(Str, [], Leaves).

-spec add(nonempty_string(), [leaf()], [leaf()]) -> [leaf()].
add(Str, LeftLeaves, []) ->
  lists:reverse([{Str, [?END]} | LeftLeaves]);

add(Str, LeftLeaves, [{Key, _} | _] = RightLeaves) when Str == Key ->
  lists:flatten([lists:reverse(LeftLeaves), RightLeaves]);

add(Str, LeftLeaves, [{Key, Leaves} = Leaf | TailLeaves] = RightLeaves) ->
  case compare(Str, Key) of
    eq ->
      case factorize(Str, Key) of
        [CommonPrefix, RPrefix] when CommonPrefix == Str ->
          lists:flatten([lists:reverse(LeftLeaves), {CommonPrefix, [?END, {RPrefix, Leaves}]} | TailLeaves]);
        [CommonPrefix, RPrefix] when CommonPrefix == Key ->
          lists:flatten([lists:reverse(LeftLeaves), {CommonPrefix, add(RPrefix, Leaves)} | TailLeaves]);
        [CommonPrefix, LPrefix, RPrefix] ->
          LeftLeaf = lists:flatten(CommonPrefix, LPrefix),
          RightLeaf = lists:flatten(CommonPrefix, RPrefix),
          case Key of
            LeftLeaf ->
              lists:flatten([lists:reverse(LeftLeaves), {CommonPrefix, [{LPrefix, Leaves}, {RPrefix, [?END]}]} | TailLeaves]);
            RightLeaf ->
              lists:flatten([lists:reverse(LeftLeaves), {CommonPrefix, [{LPrefix, [?END]}, {RPrefix, Leaves}]} | TailLeaves])
          end
      end;
    lt ->
      lists:flatten([lists:reverse(LeftLeaves), {Str, [?END]} | RightLeaves]);
    gt ->
      add(Str, [Leaf | LeftLeaves], TailLeaves)
  end.
```
Поиск по префиксу(вернет элемент, если есть совпадение и 'undefined' если не найдено)
-----
```
-spec search(nonempty_string(), [leaf()]) -> 'undefined' | nonempty_string().
search(Str, Leaves) ->
  search(Str, Leaves, _SearchPrefix = false).

-spec search_prefix(nonempty_string(), [leaf()]) -> 'undefined' | nonempty_string().
search_prefix([], _) ->
  undefined;

search_prefix([_ | Tail] = Str, Leaves) ->
  case search(Str, Leaves, _SearchPrefix = true) of
    undefined ->
      search_prefix(Tail, Leaves);
    Prefix ->
      Prefix
  end.

-spec search(nonempty_string(), [leaf()], boolean()) -> 'undefined' | nonempty_string().
search(Str, Leaves, SearchPrefix) ->
  search(Str, Leaves, SearchPrefix, []).

-spec search(nonempty_string(), [leaf()], boolean(), []) -> 'undefined' | nonempty_string().
search(Str, [{Key, [?END | _]} | _], _, Acc) when Str == Key ->
  lists:flatten(lists:reverse([Str | Acc]));

search(Str, [{Key, _} | _], false, _) when Str == Key ->
  undefined;

search(_, [?END | _], true, Acc) ->
  lists:flatten(lists:reverse(Acc));

search(Str, [?END | TailLeaves], false, Acc) ->
  search(Str, TailLeaves, false, Acc);

search(_, Leaves, _, _) when Leaves == [] orelse Leaves == [?END] ->
  undefined;

search(Str, [{Key, ChildLeaves} | TailLeaves], SearchPrefix, Acc) ->
  case compare(Str, Key) of
    eq ->
      case factorize(Str, Key) of
        [Key, RPrefix] ->
          search(RPrefix, ChildLeaves, SearchPrefix, [Key | Acc]);
        _ ->
          undefined
      end;
    lt ->
      undefined;
    gt ->
      search(Str, TailLeaves, SearchPrefix, Acc)
  end.
```
Создать ноды из двух строк(Вспомогательная функция - принимает две строки; на выходе - ноды. Пример factorize("cars","cats")==["ca", "r", "ts"])
-----
```
-spec factorize(nonempty_string(), nonempty_string()) -> list().
factorize(Xs, Ys) ->
  lists:reverse(factorize(Xs, Ys, [])).

factorize([], [], Acc) ->
  Acc;

factorize([], Ys, Acc) ->
  [Ys, lists:reverse(Acc)];

factorize(Xs, [], Acc) ->
  [Xs, lists:reverse(Acc)];

factorize([X | _] = Xs, [Y | _] = Ys, []) when X < Y ->
  [Ys, Xs];

factorize([X | _] = Xs, [Y | _] = Ys, []) when X > Y ->
  [Xs, Ys];

factorize([X | _] = Xs, [Y | _] = Ys, Acc) when X < Y ->
  [Ys, Xs, lists:reverse(Acc)];

factorize([X | _] = Xs, [Y | _] = Ys, Acc) when X > Y ->
  [Xs, Ys, lists:reverse(Acc)];

factorize([X | Xs1], [Y | Ys1], Acc) when X == Y ->
  factorize(Xs1, Ys1, [X | Acc]).

```
