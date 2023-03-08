defmodule Vaultex.Mixfile do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))
  @source_url "https://github.com/findmypast/vaultex"

  def project do
    [
      app: :vaultex,
      version: @version,
      elixir: "~> 1.14",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      docs: docs(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger, :httpoison, :poison], mod: {Vaultex, []}]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1 or ~> 4.0"},
      {:eliver, "~> 2.0", only: :dev},
      {:ex_aws, "~> 2.0", optional: true},
      {:ex_doc, ">= 0.22.0", only: :dev},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp description do
    """
    A very simple read only client that authenticates and reads secrets from
    HashiCorp's Vault.
    """
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: [
        "README.md"
      ]
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README*", "VERSION", "CHANGELOG.md"],
      maintainers: ["opensource@findmypast.com"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
