#! /usr/bin/env elixir

Mix.install([:jason])

[input_file] = argv()
{:ok, contents} = File.read(input_file)
