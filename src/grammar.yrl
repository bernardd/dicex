Nonterminals rolls roll dice.
Terminals integer d '+' '-' '*' '/' '!' ','.
Rootsymbol rolls.

rolls -> roll ',' rolls : ['$1' | '$3'].
rolls -> roll : ['$1'].

roll -> dice : '$1'.
roll -> integer : value('$1').
roll -> roll '+' roll : combine_rolls('$1', '$3', fun(A, B) -> A + B end).
roll -> roll '-' roll : combine_rolls('$1', '$3', fun(A, B) -> A - B end).
roll -> roll '*' roll : combine_rolls('$1', '$3', fun(A, B) -> A * B end).
roll -> roll '/' roll : combine_rolls('$1', '$3', fun(A, B) -> A div B end).

dice -> integer d integer '!' : 'Elixir.Dicex':roll_explode_detail(value('$3'), value('$1')).
dice -> integer d integer : 'Elixir.Dicex':roll_detail(value('$3'), value('$1')).
dice -> d integer '!' : 'Elixir.Dicex':roll_explode_detail(value('$2'), 1).
dice -> d integer : 'Elixir.Dicex':roll_detail(value('$2'), 1).

Left 50 ','.
Left 100 '+'.
Left 200 '-'.
Left 300 '*'.
Left 400 '/'.

Erlang code.

combine_rolls(Rolls1, Rolls2, Operator) ->
    {add_rolls(Rolls1, Rolls2), Operator(total(Rolls1), total(Rolls2))}.

value({integer, _TokenLine, Value}) -> Value.

add_rolls(Left, Right) -> rolls(Left) ++ rolls(Right).

rolls({Rolls, _Total}) -> Rolls;
rolls(_) -> [].

total({_Rolls, Total}) -> Total;
total(Value) -> Value.
