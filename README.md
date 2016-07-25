# Vaultex

A very simple read-only elixir client that authenticates and reads secrets from HashiCorp's Vault.

## Installation

The package can be installed as:

  1. Add vaultex to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:vaultex, "~> 0.0.1"}]
end
```
  2. Ensure vaultex is started before your application:

```elixir
def application do
  [applications: [:vaultex]]
end
```
## Configuration

The vault endpoint can be specified with environment variables:

* `VAULT_HOST`
* `VAULT_PORT`
* `VAULT_SCHEME`

Or application variables:

* `:vaultex, :host`
* `:vaultex, :port`
* `:vaultex, :scheme`

These default to `localhost`, `8200`, `http` respectively.


## Usage

To read a secret you must provide the path to the secret and the authentication backend and credentials you will use to login. See the Vaultex.Client.auth/2 docs for supported auth backends.

```elixir
...
Vault.read("secret/foo", :userpass, {username, password}) #returns {:ok, %{"value" => bar"}}
```
