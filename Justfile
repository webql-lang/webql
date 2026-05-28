mod webql 'packages/webql'
mod webql-elixir 'packages/webql-elixir'

default:
    @just --list --unsorted

test:
    just webql test
    just webql compile
    just webql-elixir test

check: format-check compile test

compile:
    just webql compile
    just webql-elixir compile

format:
    just webql format
    just webql-elixir format

format-check:
    just webql format-check
    just webql-elixir format-check
