defmodule Vaultex.Leases do
  def handle(:renew, lease, increment, state = %{token: token}) do
    body = %{"lease_id" => lease, "increment" => increment}

    request(:put, "#{state.url}sys/leases/renew", body, [{"x-vault-token", token}])
    |> handle_response(state)
  end

  def handle(:renew, _lease, _increment, state = %{}) do
    {:reply, {:error, ["Not Authenticated"]}, state}
  end

  defp handle_response({:ok, response}, state) do
    case response.body do
      %{"errors" => messages} -> {:reply, {:error, messages}, state}
      parsed_resp -> {:reply, {:ok, parsed_resp}, state}
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

  defp request(method, url, body, headers) do
    Vaultex.RedirectableRequests.request(method, url, body, headers)
  end
end
