defmodule Vaultex.Auth do
  def handle(:approle, {role_id, secret_id}, state) do
    handle(:approle, %{role_id: role_id, secret_id: secret_id}, state)
  end

  def handle(:app_id, {app_id, user_id}, state) do
    handle(:app_id, %{app_id: app_id, user_id: user_id}, state)
  end

  def handle(:aws_iam, {role, server}, state) do
    handle(:aws, Vaultex.Auth.AWSIAM.credentials(role, server), state)
  end

  def handle(:userpass, {username, password}, state) do
    handle(:userpass, %{username: username, password: password}, state)
  end

  def handle(:ldap, {username, password}, state) do
    handle(:ldap, %{username: username, password: password}, state)
  end

  def handle(:github, {token}, state) do
    handle(:github, %{token: token}, state)
  end

  def handle(:token, {token}, state) do
    request(:get, "#{state.url}auth/token/lookup-self", %{}, [
      {"X-Vault-Token", token},
      {"Content-Type", "application/json"}
    ])
    |> handle_response(state)
  end

  # auth method with usernames are expected to call `POST auth/:method/login/:username`
  def handle(method, %{username: username} = credentials, state) do
    request(:post, "#{state.url}auth/#{method}/login/#{username}", credentials, [
      {"Content-Type", "application/json"}
    ])
    |> handle_response(state)
  end

  # Generic login behavior for most methods
  def handle(method, credentials, state) when is_map(credentials) do
    request(:post, "#{state.url}auth/#{method}/login", credentials, [
      {"Content-Type", "application/json"}
    ])
    |> handle_response(state)
  end

  defp handle_response({:ok, response}, state) do
    case response.body |> Poison.decode!() do
      %{"errors" => messages} ->
        {:reply, {:error, messages}, state}

      %{"auth" => nil, "data" => data} ->
        {:reply, {:ok, :authenticated}, Map.merge(state, %{token: data["id"]})}

      %{"auth" => properties} ->
        {:reply, {:ok, :authenticated}, Map.merge(state, %{token: properties["client_token"]})}
    end
  end

  defp handle_response({_, %HTTPoison.Error{reason: reason}}, state) do
    {:reply, {:error, ["Bad response from vault [#{state.url}]", reason]}, state}
  end

  defp request(method, url, params = %{}, headers) do
    Vaultex.RedirectableRequests.request(method, url, params, headers)
  end
end
