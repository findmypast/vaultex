import Config

config :vaultex,
  req_opts: [
    plug: Vaultex.VaultStub,
    retry: false
  ],
  app_id: "foo",
  user_id: "bar",
  vault_addr: "http://localhost:8200"

config :ex_aws,
  access_key_id: "",
  secret_access_key: ""

# Print only warnings and errors during test
config :logger,
  level: :warning
