defmodule Vaultex.Auth do
  def handle(:app_id, {app_id, [user_id_path: user_id_path]}, state) do
    handle :app_id, {app_id, read_path(user_id_path)}, state
  end

  def handle(:app_id, {app_id, user_id}, state) do
    request(:post, "#{state.url}auth/app-id/login", %{app_id: app_id, user_id: user_id}, [{"Content-Type", "application/json"}])
    |> handle_response(state)
  end

  def handle(:userpass, {username, [password_path: password_path]}, state) do
    handle :userpass, {username, read_path(password_path)}, state
  end

  def handle(:userpass, {username, password}, state) do
    request(:post, "#{state.url}auth/userpass/login/#{username}", %{password: password}, [{"Content-Type", "application/json"}])
    |> handle_response(state)
  end

  def handle(:github, [github_token_path: token_path], state) do
    handle :github, {read_path(token_path)}, state
  end

  def handle(:github, {token}, state) do
    request(:post, "#{state.url}auth/github/login", %{token: token}, [{"Content-Type", "application/json"}])
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
    Vaultex.RedirectableRequests.request(method, url, params, headers)
  end

  def read_path(path) do
    File.open!(path, [:read, :utf8])
    |> IO.read(:all)
    |> String.strip
  end
end
