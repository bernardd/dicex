defmodule Dicex.MixProject do
  use Mix.Project

  def project do
    [
      app: :dicex,
      version: "0.1.0",
      elixir: "~> 1.16",
      compilers: [:leex, :yecc] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      name: "Dicex",
      description: "A dice roller supporting common dice notation.",
      source_url: "https://github.com/bernardd/dicex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    []
  end
end
