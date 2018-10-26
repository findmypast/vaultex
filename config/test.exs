use Mix.Config

config :vaultix, httpoison: Vaultix.Test.TestDoubles.MockHTTPoison
config :vaultix, app_id: "foo"
config :vaultix, user_id: "bar"
config :vaultix, vault_addr: "http://localhost:8200"
