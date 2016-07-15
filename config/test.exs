use Mix.Config

config :vaultex, httpoison: Vaultex.Test.TestDoubles.MockHTTPoison
config :vaultex, app_id: "foo"
config :vaultex, user_id: "bar"
