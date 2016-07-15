defmodule Vaultex.Auth do
  # @httpoison Application.get_env(:vaultex, :httpoison) # || HTTPoison

  def handle(state) do
    app_id = Application.get_env(:vaultex, :app_id, nil)
    user_id = Application.get_env(:vaultex, :user_id, nil)

    request(:post, "#{state.url}auth/app-id/login", %{app_id: app_id, user_id: user_id}, [{"Content-Type", "application/json"}])
    |> handle_response(state)
  end

  defp handle_response({:ok, response}, state) do
    case response.body |> Poison.Parser.parse! do
      %{"errors" => messages} -> {:reply, {:error, messages}, state}
      %{"auth" => properties} -> {:reply, {:ok, :authenticated}, Map.merge(state, %{token: properties["client_token"]})}
    end
  end

  defp handle_response({_, %HTTPoison.Error{reason: reason}}, state) do
      {:reply, {:error, ["Bad response from vault", "#{reason}"]}, state}
  end

  defp request(method, url, params = %{}, headers) do
    httpoison().request(method, url, Poison.Encoder.encode(params, []), headers)
  end

  defp httpoison(), do: Application.get_env(:vaultex, :httpoison)
end
