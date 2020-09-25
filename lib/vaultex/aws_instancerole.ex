defmodule Vaultex.Auth.AWSInstanceRole do
  @moduledoc """
  Helper functions for AWS IAM instance metadata role authentication
  """

  @url "http://169.254.169.254/latest/dynamic/instance-identity/pkcs7/"

  def credentials(role, nonce) do
    {:ok, %{body: body}} = HTTPoison.post(@url, "")

    %{
      role: role,
      pkcs7: body,
      nonce: nonce
    }
  end
end
