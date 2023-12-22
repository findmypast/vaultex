defmodule Vaultex.RedirectableRequests do
  # Is there a better way to get the default HTTPoison value? When this library is consumed by a Client
  # the config files in Vaultex appear to be ignored.
  @httpoison Application.compile_env(:vaultex, :httpoison) || HTTPoison

  def request(method, url, params = %{}, headers, options \\ []) do
    options = if ssl_skip_verify?(), do: [{:hackney, [:insecure]} | options], else: options

    options =
      if certificate_path(),
        do: [
          {:ssl,
           [
             verify: :verify_peer,
             cacertfile: certificate_path(),
             server_name_indication: :disable,
             customize_hostname_check: [
               match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
             ]
           ]}
          | options
        ],
        else: options

    @httpoison.request(method, url, Poison.encode!(params, []), headers, options)
    |> follow_redirect(method, params, headers)
  end

  defp header_location(headers) do
    {_field, redirect_to} =
      headers
      |> Enum.find(fn {name, _value} -> "Location" == name end)

    redirect_to
  end

  defp follow_redirect({:error, response}, _method, _params, _headers) do
    {:error, response}
  end

  defp follow_redirect({:ok, response}, method, params, headers) do
    if Map.has_key?(response, :status_code) do
      follow_redirect({:ok, response}, method, params, headers, response.status_code)
    else
      {:ok, response}
    end
  end

  defp follow_redirect({:ok, response}, method, params, headers, 307) do
    request(method, header_location(response.headers), params, headers)
  end

  defp follow_redirect({:ok, response}, _method, _params, _headers, _status_code) do
    {:ok, response}
  end

  defp ssl_skip_verify?() do
    System.get_env("VAULT_SSL_VERIFY") ||
      System.get_env("SSL_SKIP_VERIFY") ||
      Application.get_env(:vaultex, :vault_ssl_verify) ||
      false
  end

  defp certificate_path do
    System.get_env("VAULT_CACERT") || System.get_env("SSL_CERT_FILE")
  end
end
