defmodule Vaultex.Read do
  def handle(key, state = %{token: token}) do
    request(:get, "#{state.url}#{key}", %{}, [{"x-vault-token", token}])
    |> handle_response(state)
  end

  def handle(_key, state = %{}) do
    {:reply, {:error, ["Not Authenticated"]}, state}
  end

  defp handle_response({:ok, %Req.Response{} = response}, state) do
    case response.body do
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

  defp handle_response({:error, exception}, state) do
    reason =
      case exception do
        %{reason: reason} -> reason
        _ -> Exception.message(exception)
      end

    {:reply, {:error, ["Bad response from vault [#{state.url}]", reason]}, state}
  end

  defp request(method, url, params = %{}, headers) do
    Vaultex.RedirectableRequests.request(method, url, params, headers)
  end
end
