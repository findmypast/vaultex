use Mix.Config

config :vaultex, httpoison: Vaultex.Test.TestDoubles.MockHTTPoison
config :vaultex, app_id: "foo"
config :vaultex, user_id: "bar"
config :vaultex, vault_addr: "http://localhost:8200"
