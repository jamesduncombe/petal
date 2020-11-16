# Petal 🌺

![tests](https://github.com/jamesduncombe/petal/workflows/tests/badge.svg)

Petal is a [Bloom filter](https://en.wikipedia.org/wiki/Bloom_filter) in Elixir.

## Usage

You can use Petal by adding it to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:petal, "~> 0.1.0"}
  ]
end
```

Then within your config file you'll need to specify the hashing implementations to use:

```elixir
config :petal,
  hashers: [
    Petal.Hasher.Adler32,
    Petal.Hasher.CRC32
  ]
```

The ones above are included with Petal. You are free to add your own though, just check [the
 documentation](https://hexdocs.pm/petal/Petal.Hasher.html) for how to implement your own.

You can set the size of the filter with the config setting `filter_size`:

```elixir
config :petal,
  filter_size: 64
```

To calculate what size filter you will need, you can use a handy calculator such as the one here: https://hur.st/bloomfilter.

By default this is set to 64 bits.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc). The docs can also be found at [https://hexdocs.pm/petal](https://hexdocs.pm/petal).

