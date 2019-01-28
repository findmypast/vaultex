# :lock: Vaultex

[![Hex.pm](https://img.shields.io/hexpm/v/vaultex.svg)](https://hex.pm/packages/vaultex)
[![Hex.pm](https://img.shields.io/hexpm/dt/vaultex.svg)](https://hex.pm/packages/vaultex)

A very simple elixir client that authenticates, reads, writes and deletes secrets from HashiCorp's Vault. As listed on [Vault Libraries](https://www.vaultproject.io/api/libraries.html#elixir).

## Installation

The package can be installed as:

  1. Add vaultex to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:vaultex, "~> 0.8"}]
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

You can skip SSL certificate verification with `:vaultex, vault_ssl_verify: true` option
or `VAULT_SSL_VERIFY=true` environment variable.  

If you do want to use SSL verification, set the `VAULT_CACERT` environment variable to the SSL certificate location.  (See the [Vault documentaion](https://www.vaultproject.io/docs/commands/#vault_cacert) for more details.)

## Usage

To read a secret you must provide the path to the secret and the authentication backend and credentials you will use to login. See the [Vaultex.Client.auth/2](https://hexdocs.pm/vaultex/Vaultex.Client.html#auth/2) docs for supported auth backends.

```elixir
...
iex> Vaultex.Client.auth(:app_id, {app_id, user_id})

iex> Vaultex.Client.auth(:userpass, {username, password})

iex> Vaultex.Client.auth(:ldap, {username, password})

iex> Vaultex.Client.auth(:github, {github_token})

iex> Vaultex.Client.auth(:approle, {role_id, secret_id})

iex> Vaultex.Client.auth(:token, {token})

iex> Vaultex.Client.auth(:kubernetes, %{jwt: "jwt", role: "role"})

iex> Vaultex.Client.auth(:radius, %{username: "user", password: "password"})

...
iex> Vaultex.Client.read "secret/bar", :github, {github_token} #returns {:ok, %{"value" => bar"}}

...
iex> Vaultex.Client.read_dynamic "secret/dynamic/bar", :github, {github_token} #returns {:ok, %{"data" => %{"value" => "bar"}, "lease_duration" => 60, "lease_id" => "secret/dynamic/foo/b4z", "renewable" => true}}

...
iex> Vaultex.Client.renew_lease("secret/dynamic/foo/b4z", 100, :github, {github_token}) #returns {:ok, %{"lease_id" => "secret/dynamic/foo/b4z", "lease_duration" => 160, "renewable" => true}}

...
iex> Vaultex.Client.write "secret/foo", %{"value" => "bar"}, :app_id, {app_id, user_id}

...
iex> Vaultex.Client.delete "secret/foo", :app_id, {app_id, user_id}

```

## Releasing

To release you need to bump the version and add some changes to the change log, you can do this with:

```
mix eliver.bump
```
