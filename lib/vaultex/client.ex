defmodule Vaultex.Client do
  @moduledoc """
  Provides a functionality to authenticate and read from a vault endpoint.
  """

  use GenServer
  alias Vaultex.Auth, as: Auth
  alias Vaultex.Read, as: Read
  alias Vaultex.Write, as: Write
  alias Vaultex.Delete, as: Delete
  alias Vaultex.Leases, as: Leases
  @version "v1"

  def start_link() do
    GenServer.start_link(__MODULE__, %{progress: "starting"}, name: :vaultex)
  end

  def init(state) do
    {:ok, Map.merge(state, %{url: url()})}
  end

  @doc """
  Authenticates with vault using a tuple. This can be executed before attempting to read secrets from vault.

  ## Parameters

    - method: Auth backend to use for authenticating, can be one of `:approle, :app_id, :userpass, :github, :token`
    - credentials: A tuple or map used for authentication depending on the method, `{role_id, secret_id}` for `:approle`, `{app_id, user_id}` for `:app_id`, `{username, password}` for `:userpass`, `{github_token}` for `:github`, `{token}` for `:token`, or json-encodable map for unhandled methods, i.e. `%{jwt: "jwt", role: "role"}` for `:kubernetes`
    - timeout: A integer greater than zero which specifies how many milliseconds to wait for a reply

  ## Examples

      iex> Vaultex.Client.auth(:approle, {role_id, secret_id}, 5000)
      {:ok, :authenticated}

      iex> Vaultex.Client.auth(:app_id, {app_id, user_id})
      {:ok, :authenticated}

      iex> Vaultex.Client.auth(:userpass, {username, password})
      {:error, ["Something didn't work"]}

      iex> Vaultex.Client.auth(:github, {github_token})
      {:ok, :authenticated}

      iex> Vaultex.Client.auth(:jwt, %{jwt: jwt, role: role})
      {:ok, :authenticated}
  """
  @spec auth(
          method :: :approle,
          credentials :: {role_id :: String.t(), secret_id :: String.t()},
          timeout :: String.t() | nil
        ) :: {:ok | :error, any}
  @spec auth(
          method :: :app_id,
          credentials :: {app_id :: String.t(), user_id :: String.t()},
          timeout :: String.t() | nil
        ) :: {:ok | :error, any}
  @spec auth(
          method :: :userpass,
          credentials :: {username :: String.t(), password :: String.t()},
          timeout :: String.t() | nil
        ) :: {:ok | :error, any}
  @spec auth(
          method :: :github,
          credentials :: {github_token :: String.t()},
          timeout :: String.t() | nil
        ) :: {:ok | :error, any}
  @spec auth(method :: :token, credentials :: {token :: String.t()}, timeout :: String.t() | nil) ::
          {:ok, :authenticated}
  @spec auth(method :: atom, credentials :: map, timeout :: String.t() | nil) ::
          {:ok | :error, any}
  def auth(method, credentials, timeout \\ 5000) do
    GenServer.call(:vaultex, {:auth, method, credentials}, timeout)
  end

  @doc """
  Reads a secret from vault given a path.

  ## Parameters

    - key: A String path to be used for querying vault.
    - auth_method and credentials: See Vaultex.Client.auth
    - timeout: A integer greater than zero which specifies how many milliseconds to wait for a reply

  ## Examples

      iex> Vaultex.Client.read("secret/foobar", :approle, {role_id, secret_id}, 5000)
      {:ok, %{"value" => "bar"}}

      iex> Vaultex.Client.read("secret/foo", :app_id, {app_id, user_id})
      {:ok, %{"value" => "bar"}}

      iex> Vaultex.Client.read("secret/baz", :userpass, {username, password})
      {:error, ["Key not found"]}

      iex> Vaultex.Client.read("secret/bar", :github, {github_token})
      {:ok, %{"value" => "bar"}}

      iex> Vaultex.Client.read("secret/bar", :plugin_defined_auth, credentials)
      {:ok, %{"value" => "bar"}}
  """
  def read(key, auth_method, credentials, timeout \\ 5000) do
    case read_resp(key, auth_method, credentials, timeout) do
      {:ok, %{"data" => data}} -> {:ok, data}
      not_okay -> not_okay
    end
  end

  @doc """
  Reads a dynamic secret from vault given a path and returns the secret along with lease information.

  ## Parameters

    - key: A String path to be used for querying vault.
    - auth_method and credentials: See Vaultex.Client.auth
    - timeout: A integer greater than zero which specifies how many milliseconds to wait for a reply

  ## Examples

      iex> Vaultex.Client.read_dynamic("secret/dynamic/foobar", :approle, {role_id, secret_id}, 5000)
      {:ok, %{"data" => %{"value" => "bar"}, "lease_duration" => 60, "lease_id" => "secret/dynamic/foo/b4z", "renewable" => true}}

      iex> Vaultex.Client.read_dynamic("secret/dynamic/foo", :app_id, {app_id, user_id})
      {:ok, %{"data" => %{"value" => "bar"}, "lease_duration" => 60, "lease_id" => "secret/dynamic/foo/b4z", "renewable" => true}}

      iex> Vaultex.Client.read_dynamic("secret/dynamic/baz", :userpass, {username, password})
      {:error, ["Key not found"]}

      iex> Vaultex.Client.read_dynamic("secret/dynamic/bar", :github, {github_token})
      {:ok, %{"data" => %{"value" => "bar"}, "lease_duration" => 60, "lease_id" => "secret/dynamic/foo/b4z", "renewable" => true}}

      iex> Vaultex.Client.read_dynamic("secret/dynamic/bar", :plugin_defined_auth, credentials)
      {:ok, %{"data" => %{"value" => "bar"}, "lease_duration" => 60, "lease_id" => "secret/dynamic/foo/b4z", "renewable" => true}}
  """
  def read_dynamic(key, auth_method, credentials, timeout \\ 5000) do
    read_resp(key, auth_method, credentials, timeout)
  end

  defp read_resp(key, auth_method, credentials, timeout) do
    response = read(key, timeout)

    case response do
      {:ok, _} ->
        response

      {:error, _} ->
        with {:ok, _} <- auth(auth_method, credentials, timeout),
             do: read(key, timeout)
    end
  end

  defp read(key, timeout) do
    GenServer.call(:vaultex, {:read, key}, timeout)
  end

  @doc """
  Renews a lease for a dynamic secret

  ## Parameters

    - lease_id: A String that is the lease ID returned when reading a dynamic secret
    - increment: An Integer that represents the time in seconds to extend the lease by
    - auth_method and credentials: See Vaultex.Client.auth
    - timeout: A integer greater than zero which specifies how many milliseconds to wait for a reply

  ## Examples

      iex> Vaultex.Client.renew_lease("secret/dynamic/foo/b4z", 100, :app_role, {role_id, secret_id}, 5000)
      {:ok, %{"lease_id" => "secret/dynamic/foo/b4z", "lease_duration" => 160, "renewable" => true}}
  """

  def renew_lease(lease_id, increment, auth_method, credentials, timeout \\ 5000) do
    response = renew_lease(lease_id, increment, timeout)

    case response do
      {:ok, _} ->
        response

      {:error, _} ->
        with {:ok, _} <- auth(auth_method, credentials, timeout),
             do: renew_lease(lease_id, increment, timeout)
    end
  end

  defp renew_lease(lease_id, increment, timeout) do
    GenServer.call(:vaultex, {:renew, lease_id, increment}, timeout)
  end

  @doc """
  Writes a secret to Vault given a path.

  ## Parameters

    - key: A String path where the secret will be written.
    - value: A String => String map that will be stored in Vault
    - auth_method and credentials: See Vaultex.Client.auth
    - timeout: A integer greater than zero which specifies how many milliseconds to wait for a reply

  ## Examples

      iex> Vaultex.Client.write("secret/foo", %{"value" => "bar"}, :app_role, {role_id, secret_id}, 5000)
      :ok

      iex> Vaultex.Client.write("secret/foo", %{"value" => "bar"}, :app_id, {app_id, user_id})
      :ok
  """
  def write(key, value, auth_method, credentials, timeout \\ 5000) do
    response = write(key, value, timeout)

    case response do
      :ok ->
        response

      {:ok, response} ->
        {:ok, response}

      {:error, _} ->
        with {:ok, _} <- auth(auth_method, credentials, timeout),
             do: write(key, value, timeout)
    end
  end

  defp write(key, value, timeout) do
    GenServer.call(:vaultex, {:write, key, value}, timeout)
  end

  @doc """
  Deletes a secret in Vault given a path.

  ## Parameters

    - key: A String path where the secret will be deleted.
    - auth_method and credentials: See Vaultex.Client.auth
    - timeout: A integer greater than zero which specifies how many milliseconds to wait for a reply

  ## Examples

      iex> Vaultex.Client.delete("secret/foo", :app_role, {role_id, secret_id}, 5000)
      :ok

      iex> Vaultex.Client.delete("secret/foo", :app_id, {app_id, user_id})
      :ok
  """
  def delete(key, auth_method, credentials, timeout \\ 5000) do
    response = delete(key, timeout)

    case response do
      :ok ->
        response

      {:error, _} ->
        with {:ok, _} <- auth(auth_method, credentials, timeout),
             do: delete(key, timeout)
    end
  end

  defp delete(key, timeout) do
    GenServer.call(:vaultex, {:delete, key}, timeout)
  end

  def handle_call({:read, key}, _from, state) do
    Read.handle(key, state)
  end

  def handle_call({:renew, lease_id, increment}, _from, state) do
    Leases.handle(:renew, lease_id, increment, state)
  end

  def handle_call({:write, key, value}, _from, state) do
    Write.handle(key, value, state)
  end

  def handle_call({:auth, method, credentials}, _from, state) do
    Auth.handle(method, credentials, state)
  end

  def handle_call({:delete, key}, _from, state) do
    Delete.handle(key, state)
  end

  defp url do
    "#{scheme()}://#{host()}:#{port()}/#{@version}/"
  end

  defp host do
    parsed_vault_addr().host || get_env(:host)
  end

  defp port do
    parsed_vault_addr().port || get_env(:port)
  end

  defp scheme do
    parsed_vault_addr().scheme || get_env(:scheme)
  end

  defp parsed_vault_addr do
    get_env(:vault_addr) |> to_string |> URI.parse()
  end

  defp get_env(:host) do
    System.get_env("VAULT_HOST") || Application.get_env(:vaultex, :host) || "localhost"
  end

  defp get_env(:port) do
    System.get_env("VAULT_PORT") || Application.get_env(:vaultex, :port) || 8200
  end

  defp get_env(:scheme) do
    System.get_env("VAULT_SCHEME") || Application.get_env(:vaultex, :scheme) || "http"
  end

  defp get_env(:vault_addr) do
    Application.get_env(:vaultex, :vault_addr) || System.get_env("VAULT_ADDR")
  end
end
