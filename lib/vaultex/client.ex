defmodule Vaultex.Client do
  @moduledoc """
  Provides a functionality to authenticate and read from a vault endpoint.
  The communication relies on :app_id and :user_id variables being set.
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
  Authenticates with vault using an {app_id, user_id} tuple. This must be executed before attempting to read secrets from vault.

  ## Parameters
  
    - credentials: An {app_id, user_id} tuple used for authentication

  ## Examples

    iex> Vaultex.Client.auth({app_id, user_id})
    {:ok, :authenticated}

    iex> Vaultex.Client.auth({app_id, user_id})
    {:error, ["Something didn't work"]}
  """
  def auth(credentials = {app_id, user_id}) do
    GenServer.call(:vaultex, {:auth, credentials})
  end

  @doc """
  Reads a secret from vault given a path.

  ## Parameters

    - key: A String path to be used for querying vault.
    - credentials: An {app_id, user_id} tuple used for authentication

  ## Examples

    iex> Vaultex.Client.read "secret/foo", {app_id, user_id}
    {:ok, "bar"}

    iex> Vaultex.Client.read "secret/baz", {app_id, user_id}
    {:error, ["Key not found"]}
  """
  def read(key, credentials) do
    response = read(key)
    case response do
      {:ok, _} -> response
      {:error, _} ->
        auth(credentials)
        read(key)
    end
  end

  defp read(key) do
    GenServer.call(:vaultex, {:read, key})
  end

  def handle_call({:read, key}, _from, state) do
    Read.handle(key, state)
  end

  def handle_call({:auth, credentials}, _from, state) do
    Auth.handle(credentials, state)
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
