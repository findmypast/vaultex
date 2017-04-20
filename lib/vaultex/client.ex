defmodule Vaultex.Client do
  @moduledoc """
  Provides a functionality to authenticate and read from a vault endpoint.
  """

  use GenServer
  alias Vaultex.Auth, as: Auth
  alias Vaultex.Read, as: Read
  alias Vaultex.RedirectableRequests, as: HTTPClient
  @version "v1"

  def start_link() do
    GenServer.start_link(__MODULE__, %{progress: "starting"}, name: :vaultex)
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
    retry_with_auth auth_method, credentials, fn ->
      GenServer.call(:vaultex, {:read, key})
    end
  end

  @doc """
  Writes a secret to Vault given a path.

  ## Parameters

  - key: A String path where the secret will be written.
  - value: A String => String map that will be stored in Vault
  - auth_method and credentials: See Vaultex.Client.auth

  ## Examples

  ```
  iex> Vaultex.Client.write "secret/foo", %{"value" => "bar"}, :app_id, {app_id, user_id}
  :ok
  ```

  """
  def write(key, value, auth_method, credentials) do
    retry_with_auth auth_method, credentials, fn ->
      GenServer.call(:vaultex, {:write, key, value})
    end
  end

  defp retry_with_auth(auth_method, credentials, fun) do
    case fun.() do
      {:error, _} ->
        with {:ok, _} <- auth(auth_method, credentials),
          do: fun.()
      response -> response
    end
  end

  # GenServer callbacks

  def init(state) do
    {:ok, Map.merge(state, %{url: url()})}
  end

  def handle_call({:auth, method, credentials}, _from, state) do
    {auth_path, credentials} = build_auth_params(method, credentials)

    with {:ok, response} <- HTTPClient.request(:post, state.url <> auth_path, credentials, [{"Content-Type", "application/json"}]) do
      case response.body |> Poison.Parser.parse! do
        %{"auth" => properties} -> {:reply, {:ok, :authenticated}, Map.merge(state, %{token: properties["client_token"]})}
        %{"errors" => messages} -> {:reply, {:error, messages}, state}
      end
    else
      {_, %HTTPoison.Error{reason: reason}} -> 
        {:reply, {:error, ["Bad response from vault [#{state.url}]", "#{reason}"]}, state}
    end
  end

  defp build_auth_params(:app_id, {app_id, user_id}) do
    {"auth/app-id/login", %{app_id: app_id, user_id: user_id}}
  end
  defp build_auth_params(:userpass, {username, password}) do
    {"auth/userpass/login/#{username}", %{password: password}}
  end
  defp build_auth_params(:github, {token}) do
    {"auth/github/login", %{token: token}}
  end

  def handle_call({:read, key}, _from, state = %{token: token}) do
    with {:ok, response} <- HTTPClient.request(:get, "#{state.url}#{key}", %{}, [{"X-Vault-Token", token}]) do
      case response.body |> Poison.Parser.parse! do
        %{"data" => data} -> {:reply, {:ok, data}, state}
        %{"errors" => []} -> {:reply, {:error, ["Key not found"]}, state}
        %{"errors" => messages} -> {:reply, {:error, messages}, state}
      end
    else
      {_, %HTTPoison.Error{reason: reason}} -> 
        {:reply, {:error, ["Bad response from vault [#{state.url}]", "#{reason}"]}, state}
    end
  end
  def handle_call({:read, _}, _, state), do: {:reply, {:error, ["Not Authenticated"]}, state}

  def handle_call({:write, key, value}, _from, state = %{token: token}) do
    with {:ok, response} <- HTTPClient.request(:put, "#{state.url}#{key}", value, [{"X-Vault-Token", token}]) do
      case response.status_code do
        204 -> {:reply, :ok, state}
        error_code -> {:reply, {:error, error_code}, state}
      end
    else
      {_, %HTTPoison.Error{reason: reason}} -> 
        {:reply, {:error, ["Bad response from vault [#{state.url}]", "#{reason}"]}, state}
    end
  end
  def handle_call({:write, _, _}, _, state), do: {:reply, {:error, ["Not Authenticated"]}, state}
  # Util functions

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
    get_env(:vault_addr) |> to_string |> URI.parse
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
    System.get_env("VAULT_ADDR") || Application.get_env(:vaultex, :vault_addr)
  end
end
