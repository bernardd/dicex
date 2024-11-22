defmodule Dicex.MixProject do
  use Mix.Project

  @github_url "https://github.com/bernardd/dicex"
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
      source_url: @github_url,
      package: package()
    ]
  end

  defp deps do
    []
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["Bernard Duggan"],
      links: %{
        "GitHub" => @github_url
      },
      exclude_patterns: [~r/.*~/, ~r/src\/.*\.erl/]
    ]
  end
end
