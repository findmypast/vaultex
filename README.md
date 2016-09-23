# :lock: Vaultex

[![Hex.pm](https://img.shields.io/hexpm/v/vaultex.svg)]()
[![Hex.pm](https://img.shields.io/hexpm/dt/vaultex.svg)]()

A very simple read-only elixir client that authenticates and reads secrets from HashiCorp's Vault.

## Installation

The package can be installed as:

  1. Add vaultex to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:vaultex, "~> 0.2.1"}]
end
```
  2. Ensure vaultex is started before your application:

```elixir
def application do
  [applications: [:vaultex]]
end
```
## Configuration

You can configure your vault endpoint with a single environment variable:

* `VAULT_ADDR`

Or a single application variable:

* `:vaultex, :vault_addr`

An example value for `VAULT_ADDR` is `http://127.0.0.1:8200`.

Alternatively the vault endpoint can be specified with environment variables:

* `VAULT_HOST`
* `VAULT_PORT`
* `VAULT_SCHEME`

Or application variables:

* `:vaultex, :host`
* `:vaultex, :port`
* `:vaultex, :scheme`

These default to `localhost`, `8200`, `http` respectively.

## Usage

To read a secret you must provide the path to the secret and the authentication backend and credentials you will use to login. See the [Vaultex.Client.auth/2](https://hexdocs.pm/vaultex/Vaultex.Client.html#auth/2) docs for supported auth backends.

```elixir
...
iex> Vaultex.Client.auth(:app_id, {app_id, user_id})

iex> Vaultex.Client.auth(:userpass, {username, password})

iex> Vaultex.Client.auth(:github, {github_token}) #returns {:ok, %{"value" => bar"}}
```
