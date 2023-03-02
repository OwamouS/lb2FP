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
```
Поиск по префиксу(вернет элемент, если есть совпадение и 'undefined' если не найдено)
-----
```
```
