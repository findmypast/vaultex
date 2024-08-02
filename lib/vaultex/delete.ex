defmodule Vaultex.Delete do
  def handle(key, state = %{token: token}) do
    request(:delete, "#{state.url}#{key}", %{}, [{"x-vault-token", token}])
    |> handle_response(state)
  end

  def handle(_key, state = %{}) do
    {:reply, {:error, ["Not Authenticated"]}, state}
  end

  defp handle_response({:ok, response}, state) do
    case response.status do
      204 -> {:reply, :ok, state}
      error_code -> {:reply, {:error, error_code}, state}
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
