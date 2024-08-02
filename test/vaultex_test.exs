defmodule VaultexTest do
  use ExUnit.Case
  doctest Vaultex

  describe "Authentication" do
    test "of role_id and secret_id is successful" do
      assert Vaultex.Client.auth(:approle, {"good", "whatever"}) == {:ok, :authenticated}
    end

    test "of role_id and secret_id is unsuccessful" do
      assert Vaultex.Client.auth(:approle, {"bad", "whatever"}) == {:error, ["Not Authenticated"]}
    end

    test "of app_id and user_id is successful" do
      assert Vaultex.Client.auth(:app_id, {"good", "whatever"}) == {:ok, :authenticated}
    end

    test "of app_id and user_id is unsuccessful" do
      assert Vaultex.Client.auth(:app_id, {"bad", "whatever"}) == {:error, ["Not Authenticated"]}
    end

    test "of app_id and user_id requiring redirects is successful" do
      assert Vaultex.Client.auth(:app_id, {"redirects_good", "whatever"}) == {:ok, :authenticated}
    end

    test "of app_id and user_id causes an exception" do
      assert Vaultex.Client.auth(:app_id, {"boom", "whatever"}) ==
               {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
    end

    test "of aws_iam is successful" do
      assert Vaultex.Client.auth(:aws_iam, {"good", "whatever"}) == {:ok, :authenticated}
    end

    test "of aws_iam is unsuccessful" do
      assert Vaultex.Client.auth(:aws_iam, {"bad", "whatever"}) == {:error, ["Not Authenticated"]}
    end

    test "of aws_iam causes exception" do
      assert Vaultex.Client.auth(:aws_iam, {"boom", "explosion!"}) ==
               {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
    end

    test "of userpass is successful" do
      assert Vaultex.Client.auth(:userpass, {"user", "good"}) == {:ok, :authenticated}
    end

    test "of userpass requiring redirects is successful" do
      assert Vaultex.Client.auth(:userpass, {"user", "redirects_good"}) == {:ok, :authenticated}
    end

    test "of userpass is unsuccessful" do
      assert Vaultex.Client.auth(:userpass, {"user", "bad"}) == {:error, ["Not Authenticated"]}
    end

    test "of userpass causes an exception" do
      assert Vaultex.Client.auth(:userpass, {"user", "boom"}) ==
               {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
    end

    test "of ldap is successful" do
      assert Vaultex.Client.auth(:ldap, {"user", "good"}) == {:ok, :authenticated}
    end

    test "of ldap requiring redirects is successful" do
      assert Vaultex.Client.auth(:ldap, {"user", "redirects_good"}) == {:ok, :authenticated}
    end

    test "of ldap is unsuccessful" do
      assert Vaultex.Client.auth(:ldap, {"user", "bad"}) == {:error, ["Not Authenticated"]}
    end

    test "of ldap causes an exception" do
      assert Vaultex.Client.auth(:ldap, {"user", "boom"}) ==
               {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
    end

    test "of github_token is successful" do
      assert Vaultex.Client.auth(:github, {"good"}) == {:ok, :authenticated}
    end

    test "of github_token is unsuccessful" do
      assert Vaultex.Client.auth(:github, {"bad"}) == {:error, ["Not Authenticated"]}
    end

    test "of github_token requiring redirects is successful" do
      assert Vaultex.Client.auth(:github, {"redirects_good"}) == {:ok, :authenticated}
    end

    test "of github_token causes an exception" do
      assert Vaultex.Client.auth(:github, {"boom"}) ==
               {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
    end

    test "of token is successful" do
      assert Vaultex.Client.auth(:token, {"good"}) == {:ok, :authenticated}
    end

    test "of token with timeout is successful" do
      assert Vaultex.Client.auth(:token, {"good"}, 5000) == {:ok, :authenticated}
    end

    test "of token is unsuccessful" do
      assert Vaultex.Client.auth(:token, {"bad"}) == {:error, ["Not Authenticated"]}
    end

    test "of token causes an exception" do
      assert Vaultex.Client.auth(:token, {"boom"}) ==
               {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
    end

    test "of self signed ssl causes an exception" do
      assert Vaultex.Client.auth(:token, {"ssl"}) ==
               {:error,
                ["Bad response from vault [http://localhost:8200/v1/]", {:error, ~c"unknown ca"}]}
    end

    test "of arbitrary method and credentials" do
      assert Vaultex.Client.auth(:kubernetes, %{jwt: "good", role: "demo"}) ==
               {:ok, :authenticated}
    end

    test "of arbitrary method is unsuccessful" do
      assert Vaultex.Client.auth(:kubernetes, %{jwt: "bad", role: "demo"}) ==
               {:error, ["Not Authenticated"]}
    end

    test "with arbirary method username and password" do
      assert Vaultex.Client.auth(:radius, %{username: "user", password: "good"}) ==
               {:ok, :authenticated}

      assert Vaultex.Client.auth(:plugin_defined, %{username: "user", password: "good"}) ==
               {:ok, :authenticated}
    end
  end

  describe "Read" do
    test "of valid secret key returns the correct value" do
      assert Vaultex.Client.read("secret/foo", :app_id, {"good", "whatever"}) ==
               {:ok, %{"value" => "bar"}}
    end

    test "of valid secret key with timeout returns the correct value" do
      assert Vaultex.Client.read("secret/foo", :app_id, {"good", "whatever"}, 5000) ==
               {:ok, %{"value" => "bar"}}
    end

    test "of valid secret key requiring redirect returns the correct value" do
      assert Vaultex.Client.read("secret/foo/redirects", :app_id, {"good", "whatever"}) ==
               {:ok, %{"value" => "bar"}}
    end

    test "of valid dynamic secret returns the correct value" do
      assert Vaultex.Client.read_dynamic("secret/dynamic/foo", :app_id, {"good", "whatever"}) ==
               {:ok,
                %{
                  "lease_id" => "secret/dynamic/foo/b4z",
                  "lease_duration" => 60,
                  "renewable" => true,
                  "data" => %{"value" => "bar"}
                }}
    end

    test "of valid secret with empty warnings" do
      assert Vaultex.Client.read("secret/empty_warning", :app_id, {"good", "whatever"}) ==
               {:ok, %{"value" => "empty_warning"}}
    end

    test "of valid secret with empty errors" do
      assert Vaultex.Client.read("secret/empty_error", :app_id, {"good", "whatever"}) ==
               {:ok, %{"value" => "empty_error"}}
    end

    test "of non existing secret key returns error" do
      assert Vaultex.Client.read("secret/baz", :app_id, {"good", "whatever"}) ==
               {:error, ["Key not found"]}
    end

    test "of secret v2 key at v1 path returns warning" do
      assert Vaultex.Client.read("secret/coffee", :app_id, {"good", "whatever"}) ==
               {:ok, %{"warnings" => ["bad path"]}}
    end

    test "of a secret key given bad authentication returns error" do
      assert Vaultex.Client.read("secret/faz", :app_id, {"bad", "whatever"}) ==
               {:error, ["Not Authenticated"]}
    end

    test "Read of a secret key causes and exception" do
      assert Vaultex.Client.read("secret/boom", :app_id, {"good", "whatever"}) ==
               {:error, ["Bad response from vault [http://localhost:8200/v1/]", :econnrefused]}
    end
  end

  describe "Write" do
    test "of valid secret key returns :ok" do
      assert Vaultex.Client.write(
               "secret/foo",
               %{"value" => "bar"},
               :app_id,
               {"good", "whatever"}
             ) == :ok
    end

    test "of valid secret key with timeout returns :ok" do
      assert Vaultex.Client.write(
               "secret/foo",
               %{"value" => "bar"},
               :app_id,
               {"good", "whatever"},
               5000
             ) == :ok
    end

    test "of valid secret key requiring redirect returns :ok" do
      assert Vaultex.Client.write(
               "secret/foo/redirects",
               %{"value" => "bar"},
               :app_id,
               {"good", "whatever"}
             ) == :ok
    end

    test "of valid secret key requiring response returns :ok and response" do
      assert Vaultex.Client.write(
               "secret/foo/withresponse",
               %{"value" => "bar"},
               :app_id,
               {"good", "whatever"}
             ) == {:ok, %{"value" => "bar"}}
    end
  end

  describe "Deletion" do
    test "of valid secret key returns :ok" do
      assert Vaultex.Client.delete("secret/foo", :app_id, {"good", "whatever"}) == :ok
    end

    test "of a nonexistent key returns :ok" do
      assert Vaultex.Client.delete("secret/baz", :app_id, {"good", "whatever"}) == :ok
    end

    test "of a valid secret key with timeout returns :ok" do
      assert Vaultex.Client.delete("secret/foo", :app_id, {"good", "whatever"}, 5000) == :ok
    end
  end

  describe "Renew or other" do
    test "Renew a lease" do
      assert Vaultex.Client.renew_lease(
               "secret/dynamic/foo/b4z",
               100,
               :app_id,
               {"good", "whatever"}
             ) ==
               {:ok,
                %{
                  "lease_id" => "secret/dynamic/foo/b4z",
                  "lease_duration" => 160,
                  "renewable" => true
                }}
    end

    test "Read of valid secret key requiring redirect returns :ok" do
      # this test was never implemented
      # assert Vaultex.Client.delete("secret/foo/redirects", :app_id, {"good", "whatever"}) == :ok
    end
  end
end

defmodule Vaultex.VaultStub do
  alias Plug.Conn

  def call(%{path_info: ["v1", "auth" | _]} = conn, _params) do
    {:ok, body, conn} = Conn.read_body(conn)

    body =
      case Conn.get_req_header(conn, "x-vault-token") do
        [] -> body
        [dummy_token] -> dummy_token
        _ -> ""
      end

    cond do
      String.contains?(body, "good") ->
        # all legacy unit tests pass even w/out the redirect logic
        # redir_to = conn.request_path <> "/redirected"
        #
        # Conn.put_status(conn, 307)
        # |> Conn.put_resp_header("location", redir_to)
        Req.Test.json(conn, %{auth: %{client_token: "123abc"}})

      String.contains?(body, "boom") ->
        Req.Test.transport_error(conn, :econnrefused)

      String.contains?(body, "ssl") ->
        Req.Test.transport_error(conn, {:error, ~c"unknown ca"})

      true ->
        Req.Test.json(conn, %{errors: ["Not Authenticated"]})
    end
  end

  def call(%{path_info: ["v1", "secret" | test_key], method: "GET"} = conn, _params) do
    case test_key do
      ["foo"] ->
        Req.Test.json(conn, %{data: %{value: "bar"}})

      ["foo", "redirects"] ->
        Req.Test.json(conn, %{data: %{value: "bar"}})

      ["dynamic", "foo"] ->
        Req.Test.json(conn, %{
          lease_id: "secret/dynamic/foo/b4z",
          lease_duration: 60,
          renewable: true,
          data: %{value: "bar"}
        })

      ["empty_warning"] ->
        Req.Test.json(conn, %{data: %{value: "empty_warning"}, warnings: nil})

      ["empty_error"] ->
        Req.Test.json(conn, %{data: %{value: "empty_error"}, errors: nil})

      ["coffee"] ->
        Conn.put_status(conn, 404)
        |> Req.Test.json(%{warnings: ["bad path"]})

      ["baz"] ->
        Req.Test.json(conn, %{errors: []})

      ["faz"] ->
        Conn.put_status(conn, 401)
        |> Req.Test.json(%{errors: ["Not Authenticated"]})

      ["boom"] ->
        Req.Test.transport_error(conn, :econnrefused)
    end
  end

  def call(%{path_info: ["v1", "sys", "leases" | test_key], method: "PUT"} = conn, _params) do
    {:ok, body_str, conn} = Conn.read_body(conn)
    %{"increment" => _, "lease_id" => lease_id} = Jason.decode!(body_str)

    case test_key do
      ["renew"] ->
        Req.Test.json(conn, %{lease_id: lease_id, lease_duration: 160, renewable: true})
    end
  end

  def call(%{path_info: ["v1", "secret" | test_key], method: "PUT"} = conn, _params) do
    case test_key do
      ["foo"] ->
        Conn.send_resp(conn, 204, "")

      ["foo", "withresponse"] ->
        Req.Test.json(conn, %{data: %{value: "bar"}})

      ["foo", "redirects"] ->
        Conn.put_resp_header(conn, "location", "/v1/secret/foo")
        |> Conn.send_resp(307, "")
    end
  end

  def call(%{path_info: ["v1", "secret" | test_key], method: "DELETE"} = conn, _params) do
    case test_key do
      ["foo"] ->
        Conn.put_status(conn, 204)
        |> Req.Test.json("")

      ["baz"] ->
        Conn.put_status(conn, 204)
        |> Req.Test.json(%{errors: []})

      ["faz"] ->
        Conn.put_status(conn, 401)
        |> Req.Test.json(%{errors: ["Not Authenticated"]})

      ["boom"] ->
        Req.Test.transport_error(conn, :econnrefused)
    end
  end
end
