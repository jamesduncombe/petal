defmodule Petal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Petal.Bytes, only: [ceil_bits: 1]

  @impl true
  def start(_type, _args) do
    children = [
      {Petal.Worker, size: default_filter_size()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Petal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Default size of the filter to use
  defp default_filter_size() do
    size = Application.get_env(:petal, :filter_size, _bits = 64)

    # Make sure this is divisible by 8
    ceil_bits(size)
  end
end
