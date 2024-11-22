Nonterminals roll group dice.
Terminals integer d '+' '-' '*' '/' '(' ')'.
Rootsymbol roll.

roll -> group : '$1'.
roll -> dice : '$1'.
roll -> integer : value('$1').
roll -> roll '+' roll : '$1' + '$3'.
roll -> roll '-' roll : '$1' - '$3'.
roll -> roll '*' roll : '$1' * '$3'.
roll -> roll '/' roll : '$1' div '$3'.

dice -> integer d integer : 'Elixir.Dicex':roll(value('$3'), value('$1')).
dice -> d integer : 'Elixir.Dicex':roll(value('$2')).
group -> '(' roll ')' : '$2'.

Left 100 '+'.
Left 200 '-'.
Left 300 '*'.
Left 400 '/'.

Erlang code.

value({integer, _, Value}) -> Value.
