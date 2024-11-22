Definitions.

Rules.

[0-9]+ : {token, {integer, TokenLine, list_to_integer(TokenChars)}}.
\% : {token, {integer, TokenLine, 100}}.
[dD] : {token, {d, TokenLine}}.
\+ : {token, {'+', TokenLine}}.
\- : {token, {'-', TokenLine}}.
[\*x] : {token, {'*', TokenLine}}.
\/ : {token, {'/', TokenLine}}.
\( : {token, {'(', TokenLine}}.
\) : {token, {')', TokenLine}}.
[\s\t\n] : skip_token.

Erlang code.
