defmodule VaultexTest do
  use ExUnit.Case
  doctest Vaultex

  test "Authentication of role_id and secret_id is successful" do
    assert Vaultex.Client.auth(:approle, {"good", "whatever"}) == {:ok, :authenticated}
  end

  test "Authentication of role_id and secret_id is unsuccessful" do
    assert Vaultex.Client.auth(:approle, {"bad", "whatever"}) == {:error, ["Not Authenticated"]}
  end

  test "Authentication of app_id and user_id is successful" do
    assert Vaultex.Client.auth(:app_id, {"good", "whatever"}) == {:ok, :authenticated}
  end

  test "Authentication of app_id and user_id is unsuccessful" do
    assert Vaultex.Client.auth(:app_id, {"bad", "whatever"}) == {:error, ["Not Authenticated"]}
  end

  test "Authentication of app_id and user_id requiring redirects is successful" do
    assert Vaultex.Client.auth(:app_id, {"redirects_good", "whatever"}) == {:ok, :authenticated}
  end

  test "Authentication of app_id and user_id causes an exception" do
    assert Vaultex.Client.auth(:app_id, {"boom", "whatever"}) == {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
  end

  test "Authentication of userpass is successful" do
    assert Vaultex.Client.auth(:userpass, {"user", "good"}) == {:ok, :authenticated}
  end

  test "Authentication of userpass requiring redirects is successful" do
    assert Vaultex.Client.auth(:userpass, {"user", "redirects_good"}) == {:ok, :authenticated}
  end

  test "Authentication of userpass is unsuccessful" do
    assert Vaultex.Client.auth(:userpass, {"user", "bad"}) == {:error, ["Not Authenticated"]}
  end

  test "Authentication of userpass causes an exception" do
    assert Vaultex.Client.auth(:userpass, {"user", "boom"}) == {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
  end

  test "Authentication of ldap is successful" do
    assert Vaultex.Client.auth(:ldap, {"user", "good"}) == {:ok, :authenticated}
  end

  test "Authentication of ldap requiring redirects is successful" do
    assert Vaultex.Client.auth(:ldap, {"user", "redirects_good"}) == {:ok, :authenticated}
  end

  test "Authentication of ldap is unsuccessful" do
    assert Vaultex.Client.auth(:ldap, {"user", "bad"}) == {:error, ["Not Authenticated"]}
  end

  test "Authentication of ldap causes an exception" do
    assert Vaultex.Client.auth(:ldap, {"user", "boom"}) == {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
  end

  test "Authentication of github_token is successful" do
    assert Vaultex.Client.auth(:github, {"good"}) == {:ok, :authenticated}
  end

  test "Authentication of github_token is unsuccessful" do
    assert Vaultex.Client.auth(:github, {"bad"}) == {:error, ["Not Authenticated"]}
  end

  test "Authentication of github_token requiring redirects is successful" do
    assert Vaultex.Client.auth(:github, {"redirects_good"}) == {:ok, :authenticated}
  end

  test "Authentication of github_token causes an exception" do
    assert Vaultex.Client.auth(:github, {"boom"}) == {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
  end

  test "Authentication of token is successful" do
    assert Vaultex.Client.auth(:token, {"good"}) == {:ok, :authenticated}
  end

  test "Authentication of token with timeout is successful" do
    assert Vaultex.Client.auth(:token, {"good"}, 5000) == {:ok, :authenticated}
  end

  test "Authentication of token is unsuccessful" do
    assert Vaultex.Client.auth(:token, {"bad"}) == {:error, ["Not Authenticated"]}
  end

  test "Authentication of token causes an exception" do
    assert Vaultex.Client.auth(:token, {"boom"}) == {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
  end

  test "Authentication of self signed ssl causes an exception" do
    assert Vaultex.Client.auth(:token, {"ssl"}) == {:error, ["Bad response from vault [http://localhost:8200/v1/]", {:tls_alert, 'unknown ca'}]}
  end

  test "Authentication of arbitrary method and credentials" do
    assert Vaultex.Client.auth(:kubernetes, %{jwt: "good", role: "demo"}) == {:ok, :authenticated}
  end

  test "Authentication of arbitrary method is unsuccessful" do
    assert Vaultex.Client.auth(:kubernetes, %{jwt: "bad", role: "demo"}) == {:error, ["Not Authenticated"]}
  end

  test "Authentication with arbirary method username and password" do
    assert Vaultex.Client.auth(:radius, %{username: "user", password: "good"}) == {:ok, :authenticated}

    assert Vaultex.Client.auth(:plugin_defined, %{username: "user", password: "good"}) == {:ok, :authenticated}
  end

  test "Read of valid secret key returns the correct value" do
    assert Vaultex.Client.read("secret/foo", :app_id, {"good", "whatever"}) == {:ok, %{"data" => %{"value" => "bar"}}}
  end

  test "Read of valid secret key with timeout returns the correct value" do
    assert Vaultex.Client.read("secret/foo", :app_id, {"good", "whatever"}, 5000) == {:ok, %{"data" => %{"value" => "bar"}}}
  end

  test "Read of valid secret key requiring redirect returns the correct value" do
    assert Vaultex.Client.read("secret/foo/redirects", :app_id, {"good", "whatever"}) == {:ok, %{"data" => %{"value" => "bar"}}}
  end

  test "Read of non existing secret key returns error" do
    assert Vaultex.Client.read("secret/baz", :app_id, {"good", "whatever"}) == {:error, ["Key not found"]}
  end

  test "Read of a secret key given bad authentication returns error" do
    assert Vaultex.Client.read("secret/faz", :app_id, {"bad", "whatever"}) == {:error, ["Not Authenticated"]}
  end

  test "Read of a secret key causes and exception" do
    assert Vaultex.Client.read("secret/boom", :app_id, {"good", "whatever"}) == {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
  end

  test "Write of valid secret key returns :ok" do
    assert Vaultex.Client.write("secret/foo", %{"value" => "bar"}, :app_id, {"good", "whatever"}) == :ok
  end

  test "Write of valid secret key with timeout returns :ok" do
    assert Vaultex.Client.write("secret/foo", %{"value" => "bar"}, :app_id, {"good", "whatever"}, 5000) == :ok
  end

  test "Write of valid secret key requiring redirect returns :ok" do
    assert Vaultex.Client.write("secret/foo/redirects", %{"value" => "bar"}, :app_id, {"good", "whatever"}) == :ok
  end

  test "Write of valid secret key requiring response returns :ok and response" do
    assert Vaultex.Client.write("secret/foo/withresponse", %{"value" => "bar"}, :app_id, {"good", "whatever"}) == {:ok, %{"value" => "bar"}}
  end

  test "Deletion of valid secret key returns :ok" do
    assert Vaultex.Client.delete("secret/foo", :app_id, {"good", "whatever"}) == :ok
  end

  test "Deletion of a nonexistent key returns :ok" do
    assert Vaultex.Client.delete("secret/baz", :app_id, {"good", "whatever"}) == :ok
  end

  test "Deletion of a valid secret key with timeout returns :ok" do
    assert Vaultex.Client.delete("secret/foo", :app_id, {"good", "whatever"}, 5000) == :ok
  end

  test "Read of valid secret key requiring redirect returns :ok" do
    assert Vaultex.Client.delete("secret/foo/redirects", :app_id, {"good", "whatever"}) == :ok
  end
end
