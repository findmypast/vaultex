defmodule Vaultex.Write do
  def handle(key, value, state = %{token: token}) do
    request(:put, "#{state.url}#{key}", value, [
      {"Content-Type", "application/json"},
      {"X-Vault-Token", token}
    ])
    |> handle_response(state)
  end

  def handle(_key, _value, state = %{}) do
    {:reply, {:error, ["Not Authenticated"]}, state}
  end

  defp handle_response({:ok, response}, state) do
    case response.status_code do
      200 ->
        case response.body |> Poison.decode!() do
          %{"data" => data} -> {:reply, {:ok, data}, state}
          %{"errors" => []} -> {:reply, {:error, ["Key not found"]}, state}
          %{"errors" => messages} -> {:reply, {:error, messages}, state}
        end

      204 ->
        {:reply, :ok, state}

      error_code ->
        {:reply, {:error, error_code}, state}
    end
  end

  defp handle_response({_, %HTTPoison.Error{reason: reason}}, state) do
    {:reply, {:error, ["Bad response from vault [#{state.url}]", reason]}, state}
  end

  defp request(method, url, body, headers) do
    Vaultex.RedirectableRequests.request(method, url, body, headers)
  end
end
