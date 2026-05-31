default:
    @just --list --unsorted

deps:
    gleam deps download
    mix deps.get

test:
    gleam test
    just artifacts
    mix test

check: format-check compile test

compile:
    just artifacts
    mix compile --warnings-as-errors

format:
    gleam format src test
    mix format

format-check:
    gleam format --check src test
    mix format --check-formatted

artifacts:
    rm -rf build/prod/erlang
    gleam export erlang-shipment
    rm -f build/prod/erlang/*/_gleam_artefacts/gleam@@compile.erl

clean:
    gleam clean
    mix clean
