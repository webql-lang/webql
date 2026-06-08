mod webql

default:
    @just --list --unsorted

deps:
    just webql deps

test:
    just webql test

check:
    just webql check

compile:
    just webql compile

format:
    just webql format

format-check:
    just webql format-check

artifacts:
    just webql artifacts

clean:
    just webql clean

docs:
    just webql docs
