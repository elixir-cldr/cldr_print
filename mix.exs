defmodule Cldr.Print.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :ex_cldr_print,
      version: @version,
      elixir: "~> 1.5",
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore_warnings",
        plt_add_apps: ~w(gettext inets jason mix plug)a
      ],
      compilers: Mix.compilers()
    ]
  end

  def description do
    """
    Printf/sprintf functions and macros for Elixir
    """
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def aliases do
    []
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: links(),
      files: [
        "lib",
        "config",
        "mix.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*",
      ]
    ]
  end

  defp deps do
    [
      {:nimble_parsec, "~> 0.5"},
      {:ex_cldr_numbers, "~> 2.6"},
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.19"},
      {:benchee, "~> 0.14", only: [:dev, :test]}
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/kipcole9/ex_cldr_print",
      "Readme" => "https://github.com/kipcole9/ex_cldr_print/blob/v#{@version}/README.md",
      "Changelog" => "https://github.com/kipcole9/ex_cldr_print/blob/v#{@version}/CHANGELOG.md"
    }
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      logo: "logo.png",
      extras: [
        "README.md",
        "LICENSE.md",
        "CHANGELOG.md"
      ],
      groups_for_modules: [
        "Default CLDR Backend": ~r/Cldr.Print.Backend/
      ],
      skip_undefined_reference_warnings_on: ["changelog"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "mix", "src", "test"]
  defp elixirc_paths(:dev), do: ["lib", "mix", "src", "bench"]
  defp elixirc_paths(_), do: ["lib", "src"]
end
