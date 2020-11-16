defmodule Petal.MixProject do
  use Mix.Project

  def project do
    [
      app: :petal,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: [
        groups_for_modules: [
          Behaviours: [
            Petal.Hasher
          ],
          "Hash Functions": [
            Petal.Hasher.CRC32,
            Petal.Hasher.Adler32
          ]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Petal.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp description() do
    "Petal is a Bloom filter"
  end

  defp package() do
    [
      maintainers: ["James Duncombe"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jamesduncombe/petal"}
    ]
  end
end
