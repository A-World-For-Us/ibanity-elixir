defmodule Ibanity.MixProject do
  use Mix.Project

  def project do
    [
      app: :ibanity,
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [espec: :test],
      deps: deps(),
      docs: [
        extras: ["README.md"],
        main: "readme",
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Ibanity.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:recase, "~> 0.3"},
      {:ex_crypto, "~> 0.9.0"},
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false},
      {:credo, "~> 1.0.0-rc1", only: [:dev, :test], runtime: false}
    ]
  end
end
