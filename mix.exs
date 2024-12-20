defmodule Dicex.MixProject do
  use Mix.Project

  @github_url "https://github.com/bernardd/dicex"
  def project do
    [
      app: :dicex,
      version: "0.2.0",
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
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
    ]
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
