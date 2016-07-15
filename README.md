# Vaultex

A very simple read only client that authenticates and reads secrets from HashiCorop's Vault.

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

In your `config.exs` file add:

```elixir
config :vaultex, app_id: System.get_env("VAULT_APP_ID")
config :vaultex, user_id: System.get_env("VAULT_USER_ID")
```

## Usage

The library requires to authenticate first with:

```elixir
alias Vaultex.Client, as: Vault
...

Vault.auth #returns {:ok, :authenticated}
```

After successful authentication, you can read a secret with:

```elixir
...
Vault.read("secret/foo") #returns {:ok, "bar"}
```
