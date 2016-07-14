defmodule Vaultex.Test.TestDoubles.MockHTTPoison do

  def request(method, url, params, _) do
    cond do
      List.to_string(params) |> String.contains?("good") -> {:ok, %{body: Poison.Encoder.encode(%{auth: %{client_token: "mytoken"}}, [])}}
      List.to_string(params) |> String.contains?("boom") -> {:error, %{ }}
      :else -> {:ok, %{body: Poison.Encoder.encode(%{errors: ["not_authenticated"] }, [])}}
    end
  end

end
