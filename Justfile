default:
    @just --list --unsorted

[working-directory("packages/webql")]
system +args:
    gleam {{ args }}

[working-directory("packages/webql_elixir")]
platform-elixir +args:
    mix {{ args }}
