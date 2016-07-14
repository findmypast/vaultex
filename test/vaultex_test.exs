defmodule VaultexTest do
  use ExUnit.Case
  doctest Vaultex

  test "Authentication of app_id and user_id is successful" do
    Application.put_env(:vaultex, :app_id, "good")
    assert Vaultex.Client.auth == {:ok, :authenticated}
  end

  test "Authentication of app_id and user_id is unsuccessful" do
    Application.put_env(:vaultex, :app_id, "bad")
    assert Vaultex.Client.auth == {:error, ["Not Authenticated"]}
  end

  test "Authentication of app_id and user_id causes an exception" do
    Application.put_env(:vaultex, :app_id, "boom")
    assert Vaultex.Client.auth == {:error, ["Bad response from vault"]}
  end

  test "Read of valid secret key returns the correct value" do
    Application.put_env(:vaultex, :app_id, "good")
    Vaultex.Client.auth()
    assert Vaultex.Client.read("secret/foo") == {:ok, "bar"}
  end

  test "Read of non existing secret key returns error" do
    Application.put_env(:vaultex, :app_id, "good")
    Vaultex.Client.auth()
    assert Vaultex.Client.read("secret/baz") == {:error, ["Key not found"]}
  end

  test "Read of a secret key when not authenticated returns error" do
    assert Vaultex.Client.read("secret/faz") == {:error, ["Not Authenticated"]}
  end

  test "Read of a secret key causes and exception" do
    Application.put_env(:vaultex, :app_id, "good")
    Vaultex.Client.auth()
    assert Vaultex.Client.read("secret/boom") == {:error, ["Bad response from vault"]}
  end

end
