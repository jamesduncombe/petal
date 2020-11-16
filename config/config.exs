import Config

config :petal,
  filter_size: 64,
  hashers: [
    Petal.Hasher.Adler32,
    Petal.Hasher.CRC32
  ]

import_config "#{Mix.env()}.exs"
