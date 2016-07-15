defmodule Vaultex.Read do
  # Is there a better way to get the default HTTPoison value? When this library is consumed by a Client
  # the config files in Vaultex appear to be ignored.
  @httpoison Application.get_env(:vaultex, :httpoison) || HTTPoison

  def handle(key, state = %{token: token}) do
    request(:get, "#{state.url}#{key}", %{}, [{"X-Vault-Token", token}])
    |> handle_response(state)
  end

  def handle(_key, state = %{}) do
    {:reply, {:error, ["Not Authenticated"]}, state}
  end

  defp handle_response({:ok, response}, state) do
    case response.body |> Poison.Parser.parse! do
      %{"data" => data} -> {:reply, {:ok, data["value"]}, state}
      %{"errors" => []} -> {:reply, {:error, ["Key not found"]}, state}
      %{"errors" => messages} -> {:reply, {:error, messages}, state}
    end
  end

  defp handle_response({_, %HTTPoison.Error{reason: reason}}, state) do
      {:reply, {:error, ["Bad response from vault", "#{reason}"]}, state}
  end

  defp request(method, url, params = %{}, headers) do
    @httpoison.request(method, url, Poison.Encoder.encode(params, []), headers)
  end
end
