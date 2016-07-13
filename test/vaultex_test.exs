defmodule VaultexTest do
  use ExUnit.Case
  doctest Vaultex

  test "Authentication of app_id and user_id is successful" do
    Application.put_env(:vaultex, :app_id, "good")
    assert Vaultex.Client.auth == {:ok, :authenticated}
  end

  test "Authentication of app_id and user_id is unsuccessful" do
    Application.put_env(:vaultex, :app_id, "bad")
    assert Vaultex.Client.auth == {:error, ["not_authenticated"]}
  end
end
