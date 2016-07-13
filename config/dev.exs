use Mix.Config

# config :vaultex, httpoison: HTTPoison
config :vaultex, httpoison: Vaultex.Test.TestDoubles.MockHTTPoison
