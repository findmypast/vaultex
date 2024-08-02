defmodule Vaultex.Mixfile do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))
  @source_url "https://github.com/Semsee/vaultex"

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
    [extra_applications: [:logger], mod: {Vaultex, []}]
  end

  defp deps do
    [
      {:ex_aws, "~> 2.5", optional: true},
      {:ex_doc, ">= 0.22.0", only: :dev},
      {:excoveralls, "~> 0.10", only: :test},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.0", only: :test},
      {:req, "~> 0.5.0"}
    ]
  end

  defp description do
    """
    Fork of vaultex - a read-only client for HashiCorp's Vault.

    Updated to fix bugs with IAM and requires Elixir >= 1.14.
    Relies on Req and Jason instead of HTTPoison and Poison.
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
      maintainers: ["opensource@semsee.com"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
