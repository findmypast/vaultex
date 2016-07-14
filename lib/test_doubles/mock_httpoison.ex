defmodule Vaultex.Test.TestDoubles.MockHTTPoison do

  def request(:post, _url, params, _) do
    cond do
      List.to_string(params) |> String.contains?("good") -> {:ok, %{body: Poison.Encoder.encode(%{"auth" => %{"client_token" => "mytoken"}}, [])}}
      List.to_string(params) |> String.contains?("boom") -> {:error, %{ }}
      :else -> {:ok, %{body: Poison.Encoder.encode(%{errors: ["Not Authenticated"] }, [])}}
    end
  end

  def request(:get, url, _params, _) do
    cond do
      url |> String.contains?("secret/foo") -> {:ok, %{body: Poison.Encoder.encode(%{"data" => %{"value" => "bar"}},[])}}
      url |> String.contains?("secret/baz") -> {:ok, %{body: Poison.Encoder.encode(%{"errors" => []},[])}}
      url |> String.contains?("secret/faz") -> {:ok, %{body: Poison.Encoder.encode(%{"errors" => ["Not Authenticated"]},[])}}
      url |> String.contains?("secret/boom") -> {:error, %{ }}
      :else -> {:ok, %{} }
    end
  end
end
