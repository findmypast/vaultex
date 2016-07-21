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

To read a secret you must provide both an app id and a user id with the read calls

```elixir
...
Vault.read("secret/foo", {app_id, user_id}) #returns {:ok, "bar"}
```
