defmodule Vaultex.Auth.AWSInstanceRole do
  @moduledoc """
  Helper functions for AWS IAM instance metadata role authentication
  """

  @url "http://169.254.169.254/latest/dynamic/instance-identity/pkcs7/"

  def credentials(role, _server) do

    {:ok, %{body: body}} = HTTPoison.post(@url, "")
    %{
      role: role,
      pkcs7: body,
      nonce: "a22ba225-f59b-88a7-33e1-c98402739aa4"
    }
  end

end
