defmodule Vaultex.Test.TestDoubles.MockHTTPoison do

  def request(:post, _, _, _) do
    {:ok, %{body: Poison.Encoder.encode(%{auth: %{client_token: "mytoken"}}, [])}}
  end
end
