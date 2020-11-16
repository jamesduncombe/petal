defmodule Petal.MixProject do
  use Mix.Project

  @version "0.2.1"

  def project do
    [
      app: :petal,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
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

  defp docs() do
    [
      name: "Petal",
      source_ref: "v#{@version}",
      main: "readme",
      extras: ["README.md"],
      source_url: "https://github.com/jamesduncombe/petal",
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
