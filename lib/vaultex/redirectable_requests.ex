defmodule Vaultex.RedirectableRequests do
  @doc """
  Make an HTTP request using Req

  Req by default encodes the body data as JSON, follows redirects, and uses
  secure SSL defaults.
  """
  def request(method, url, body, headers, _opts \\ []) do
    Req.Request.new()

    [
      method: method,
      url: url,
      json: body,
      headers: default_headers() ++ headers
    ]
    |> Keyword.merge(ssl_skip_verify?())
    |> Keyword.merge(Application.get_env(:vaultex, :req_opts, []))
    |> Req.request()
  end

  defp default_headers() do
    [
      {"content-type", "application/json"},
      {"accept", "application/json"}
    ]
  end

  # whether we should skip verifying the Vault server's TLS certificate
  def ssl_skip_verify?() do
    skip_verify =
      System.get_env("VAULT_SSL_VERIFY") ||
        System.get_env("SSL_SKIP_VERIFY") ||
        Application.get_env(:vaultex, :vault_ssl_verify) ||
        false

    if skip_verify do
      [connect_options: [transport_opts: [verify: :verify_none]]]
    else
      []
    end
  end
end
