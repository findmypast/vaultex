# :lock: Vaultix

[![Hex.pm](https://img.shields.io/hexpm/v/vaultix.svg)](https://hex.pm/packages/vaultix)
[![Hex.pm](https://img.shields.io/hexpm/dt/vaultix.svg)](https://hex.pm/packages/vaultix)

A very simple elixir client that authenticates, reads, writes, and deletes secrets from HashiCorp's Vault. As listed on [Vault Libraries](https://www.vaultproject.io/api/libraries.html#elixir). Forked from https://github.com/findmypast/vaultex.

## Installation

The package can be installed as:

  1. Add vaultix to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:vaultix, "~> 0.8"}]
end
```
  2. Ensure vaultix is started before your application:

```elixir
def application do
  [applications: [:vaultix]]
end
```
## Configuration

You can configure your vault endpoint with a single environment variable:

* `VAULT_ADDR`

Or a single application variable:

* `:vaultix, :vault_addr`

An example value for `VAULT_ADDR` is `http://127.0.0.1:8200`.

Alternatively the vault endpoint can be specified with environment variables:

* `VAULT_HOST`
* `VAULT_PORT`
* `VAULT_SCHEME`

Or application variables:

* `:vaultix, :host`
* `:vaultix, :port`
* `:vaultix, :scheme`

These default to `localhost`, `8200`, `http` respectively.

You can skip SSL certificate verification with `:vaultix, vault_ssl_verify: true` option
or `VAULT_SSL_VERIFY=true` environment variable.  

## Usage

To read a secret you must provide the path to the secret and the authentication backend and credentials you will use to login. See the [Vaultix.Client.auth/2](https://hexdocs.pm/vaultix/Vaultix.Client.html#auth/2) docs for supported auth backends.

```elixir
...
iex> Vaultix.Client.auth(:app_id, {app_id, user_id})

iex> Vaultix.Client.auth(:userpass, {username, password})

iex> Vaultix.Client.auth(:ldap, {username, password})

iex> Vaultix.Client.auth(:github, {github_token})

iex> Vaultix.Client.auth(:approle, {role_id, secret_id})

iex> Vaultix.Client.auth(:token, {token})

iex> Vaultix.Client.auth(:kubernetes, %{jwt: "jwt", role: "role"})

iex> Vaultix.Client.auth(:radius, %{username: "user", password: "password"})

...
iex> Vaultix.Client.read "secret/bar", :github, {github_token} #returns {:ok, %{"value" => bar"}}

...
iex> Vaultix.Client.write "secret/foo", %{"value" => "bar"}, :app_id, {app_id, user_id}

```

## Releasing

To release you need to bump the version and add some changes to the change log, you can do this with:

```
mix eliver.bump
```
