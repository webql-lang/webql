default:
    @just --list --unsorted

[working-directory("system")]
system +args:
    gleam {{ args }}

[working-directory("platform/elixir")]
platform-elixir +args:
    mix {{ args }}
