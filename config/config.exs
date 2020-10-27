import Config

config :petal,
  hashers: [
    Petal.Hasher.Adler32,
    Petal.Hasher.CRC32
  ]

import_config "#{Mix.env()}.exs"
