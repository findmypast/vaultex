defmodule Vaultex.Auth.AWSIAM do
  @moduledoc """
  Helper functions for AWS IAM instance metadata role authentication
  """

  @url "https://sts.amazonaws.com/"
  @body "Action=GetCallerIdentity&Version=2011-06-15"

  def credentials(role, server) do
    %{
      iam_http_request_method: "POST",
      iam_request_url: Base.encode64(@url),
      iam_request_body: Base.encode64(@body),
      iam_request_headers: Base.encode64(request_headers(server))
    }
    |> maybe_add_role(role)
  end

  defp request_headers(server) do
    base_headers =
      [
        {"User-Agent", "ExAws"},
        {"Content-Type", "application/x-www-form-urlencoded"}
      ]
      |> maybe_add_server(server)

    config = ExAws.Config.new(:sts)

    {:ok, headers} = ExAws.Auth.headers(:post, @url, :sts, config, base_headers, @body)

    headers
    |> Enum.into(%{})
    |> Poison.encode!()
  end

  defp maybe_add_role(credentials, nil), do: credentials

  defp maybe_add_role(credentials, role),
    do: Map.put(credentials, :role, role)

  defp maybe_add_server(headers, nil), do: headers

  defp maybe_add_server(headers, server),
    do: [{"X-Vault-AWS-IAM-Server-Id", server} | headers]
end
