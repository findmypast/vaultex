import Config

config :vaultex, httpoison: Vaultex.Test.TestDoubles.MockHTTPoison
config :vaultex, app_id: "foo"
config :vaultex, user_id: "bar"
config :vaultex, vault_addr: "http://localhost:8200"

config :ex_aws,
  access_key_id: "",
  secret_access_key: ""
