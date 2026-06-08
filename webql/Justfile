default:
    @just --list --unsorted

deps:
    gleam deps download
    mix deps.get

test:
    gleam test
    just compile
    mix test

check: format-check compile test

compile:
    gleam build --target erlang
    rm -f build/dev/erlang/*/_gleam_artefacts/gleam@@compile.erl
    mix compile --warnings-as-errors

format:
    gleam format
    mix format

format-check:
    gleam format --check
    mix format --check-formatted

artifacts:
    rm -rf build/prod/erlang
    rm -rf build/erlang-shipment
    gleam export erlang-shipment
    rm -f build/prod/erlang/*/_gleam_artefacts/gleam@@compile.erl

clean:
    gleam clean
    mix clean

docs: artifacts
    mix docs
