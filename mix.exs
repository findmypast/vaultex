defmodule Vaultex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :vaultex,
      version: "0.12.6",
      elixir: "~> 1.5",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison, :uuid], mod: {Vaultex, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:jason, ">= 1.0.0"},
      {:uuid, "~> 1.1"},
      {:eliver, "~> 2.0"},
      {:ex_aws, "~> 2.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test]},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    A very simple read only client that authenticates and reads secrets from HashiCorp's Vault.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README*", "CHANGELOG.md"],
      maintainers: ["opensource@findmypast.com"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/findmypast/vaultex"}
    ]
  end
end
