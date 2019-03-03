defmodule CldrPrint.MixProject do
  use Mix.Project

  def project do
    [
      app: :cldr_print,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_parsec, "~> 0.5"},
      {:ex_cldr_numbers, "~> 2.0"},
      {:jason, "~> 1.0"}
    ]
  end
end
