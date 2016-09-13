defmodule Vaultex.Client do
  @moduledoc """
  Provides a functionality to authenticate and read from a vault endpoint.
  """

  use GenServer
  alias Vaultex.Auth, as: Auth
  alias Vaultex.Read, as: Read
  @version "v1"

  def start_link() do
    GenServer.start_link(__MODULE__, %{progress: "starting"}, name: :vaultex)
  end

  def init(state) do
    url = "#{get_env(:scheme)}://#{get_env(:host)}:#{get_env(:port)}/#{@version}/"
    {:ok, Map.merge(state, %{url: url})}
  end

  @doc """
  Authenticates with vault using a tuple. This can be executed before attempting to read secrets from vault.

  ## Parameters

    - method: Auth backend to use for authenticating, can be one of `:app_id, :userpass, :github`
    - credentials: A tuple used for authentication depending on the method, `{app_id, user_id}` for `:app_id`, `{username, password}` for `:userpass`, `{github_token}` for `:github`

  ## Examples

    ```
    iex> Vaultex.Client.auth(:app_id, {app_id, user_id})
    {:ok, :authenticated}

    iex> Vaultex.Client.auth(:userpass, {username, password})
    {:error, ["Something didn't work"]}

    iex> Vaultex.Client.auth(:github, {github_token})
    {:ok, :authenticated}
    ```
  """
  def auth(method, credentials) do
    GenServer.call(:vaultex, {:auth, method, credentials})
  end

  @doc """
  Reads a secret from vault given a path.

  ## Parameters

    - key: A String path to be used for querying vault.
    - auth_method and credentials: See Vaultex.Client.auth

  ## Examples

    ```
    iex> Vaultex.Client.read "secret/foo", :app_id, {app_id, user_id}
    {:ok, %{"value" => "bar"}}

    iex> Vaultex.Client.read "secret/baz", :userpass, {username, password}
    {:error, ["Key not found"]}

    iex> Vaultex.Client.read "secret/bar", :github, {github_token}
    {:ok, %{"value" => "bar"}}
    ```

  """
  def read(key, auth_method, credentials) do
    response = read(key)
    case response do
      {:ok, _} -> response
      {:error, _} ->
        with {:ok, _} <- auth(auth_method, credentials),
          do: read(key)
    end
  end

  defp read(key) do
    GenServer.call(:vaultex, {:read, key})
  end

  def handle_call({:read, key}, _from, state) do
    Read.handle(key, state)
  end

  def handle_call({:auth, method, credentials}, _from, state) do
    Auth.handle(method, credentials, state)
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
end
