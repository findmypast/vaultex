defmodule Vaultex.RedirectableRequests do
  # Is there a better way to get the default HTTPoison value? When this library is consumed by a Client
  # the config files in Vaultex appear to be ignored.
  @httpoison Application.get_env(:vaultex, :httpoison) || HTTPoison

  def request(method, url, params = %{}, headers) do
    @httpoison.request(method, url, Poison.Encoder.encode(params, []), headers)
    |> follow_redirect(method, params, headers)
  end

  defp header_location(headers) do
    {_field, redirect_to} = headers
      |> Enum.find( fn({name, _value}) -> "Location" == name  end )
    redirect_to
  end

  defp follow_redirect({:error, response}, _method, _params, _headers) do
    {:error, response}
  end

  defp follow_redirect({:ok, response}, method, params, headers) do
    if Map.has_key?(response, :status_code) do
      follow_redirect {:ok, response}, method, params, headers, response.status_code
    else
      {:ok, response}
    end
  end

  defp follow_redirect({:ok, response}, method, params, headers, 307) do
    request method, header_location(response.headers), params, headers
  end

  defp follow_redirect({:ok, response}, _method, _params, _headers, _status_code) do
    {:ok, response}
  end
end
