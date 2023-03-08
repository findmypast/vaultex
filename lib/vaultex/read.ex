defmodule Vaultex.Read do
  def handle(key, state = %{token: token}) do
    request(:get, "#{state.url}#{key}", %{}, [{"X-Vault-Token", token}])
    |> handle_response(state)
  end

  def handle(_key, state = %{}) do
    {:reply, {:error, ["Not Authenticated"]}, state}
  end

  defp handle_response({:ok, response}, state) do
    case response.body |> Poison.decode!() do
      %{"errors" => []} ->
        {:reply, {:error, ["Key not found"]}, state}

      %{"errors" => messages} when not is_nil(messages) ->
        {:reply, {:error, messages}, state}

      %{"warnings" => messages} when not is_nil(messages) ->
        {:reply, {:ok, %{"warnings" => messages}}, state}

      parsed_resp ->
        {:reply, {:ok, parsed_resp}, state}
    end
  end

  defp handle_response({_, %HTTPoison.Error{reason: reason}}, state) do
    {:reply, {:error, ["Bad response from vault [#{state.url}]", reason]}, state}
  end

  defp request(method, url, params = %{}, headers) do
    Vaultex.RedirectableRequests.request(method, url, params, headers)
  end
end
