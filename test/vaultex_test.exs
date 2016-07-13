defmodule VaultexTest do
  use ExUnit.Case
  doctest Vaultex

  test "Authentication of app_id and user_id is successful" do
    assert Vaultex.Client.auth == {:ok, :authenticated}
  end
end
