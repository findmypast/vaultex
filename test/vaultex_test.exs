defmodule VaultexTest do
  use ExUnit.Case
  doctest Vaultex

  test "Authentication of app_id and user_id is successful" do
    assert Vaultex.Client.auth({"good", "whatever"}) == {:ok, :authenticated}
  end

  test "Authentication of app_id and user_id is unsuccessful" do
    assert Vaultex.Client.auth({"bad", "whatever"}) == {:error, ["Not Authenticated"]}
  end

  test "Authentication of app_id and user_id causes an exception" do
    assert Vaultex.Client.auth({"boom", "whatever"}) == {:error, ["Bad response from vault", "econnrefused"]}
  end

  test "Read of valid secret key returns the correct value" do
    assert Vaultex.Client.read("secret/foo", {"good", "whatever"}) == {:ok, "bar"}
  end

  test "Read of non existing secret key returns error" do
    assert Vaultex.Client.read("secret/baz", {"good", "whatever"}) == {:error, ["Key not found"]}
  end

  test "Read of a secret key when not authenticated returns error" do
    assert Vaultex.Client.read("secret/faz", {"bad", "whatever"}) == {:error, ["Not Authenticated"]}
  end

  test "Read of a secret key causes and exception" do
    assert Vaultex.Client.read("secret/boom", {"good", "whatever"}) == {:error, ["Bad response from vault", "econnrefused"]}
  end

end
