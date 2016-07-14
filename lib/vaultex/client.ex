defmodule Vaultex.Client do
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

  def auth() do
    GenServer.call(:vaultex, {:auth})
  end

  def read(key) do
    GenServer.call(:vaultex, {:read, key})
  end

  def handle_call({:read, key}, _from, state) do
    Read.handle(key, state)
  end

  def handle_call({:auth}, _from, state) do
    Auth.handle(state)
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
