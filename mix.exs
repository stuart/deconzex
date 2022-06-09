defmodule Deconzex.MixProject do
  use Mix.Project

  def project do
    [
      app: :deconzex,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: mod(Mix.env()),
      extra_applications: [:logger],
      env: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_uart, "~> 1.3"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  # defp mod(:test) do
  #   []
  # end

  defp mod(_) do
    {Deconzex, []}
  end
end
