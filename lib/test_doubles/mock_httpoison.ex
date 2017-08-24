defmodule Vaultex.Test.TestDoubles.MockHTTPoison do

  def request(:post, url, params, _, _) do
    stringified_params = List.to_string params
    cond do
      stringified_params |> String.contains?("good") -> {:ok, %{status_code: status_code(url, stringified_params),
                                                          headers: [{"Location", redirect_url(url)}],
                                                          body: Poison.Encoder.encode(%{"auth" => %{"client_token" => "mytoken"}}, [])}}
      stringified_params |> String.contains?("boom") -> {:error, %HTTPoison.Error{id: nil, reason: :econnrefused}}
      :else -> {:ok, %{body: Poison.Encoder.encode(%{errors: ["Not Authenticated"] }, [])}}
    end
  end

  def request(:get, url, _params, _, _) do
    cond do
      url |> String.contains?("secret/foo") -> {:ok, %{status_code: status_code(url, url),
                                                      headers: [{"Location", redirect_url(url)}],
                                                      body: Poison.Encoder.encode(%{"data" => %{"value" => "bar"}},[])}}
      url |> String.contains?("secret/baz") -> {:ok, %{status_code: "whatever", body: Poison.Encoder.encode(%{"errors" => []},[])}}
      url |> String.contains?("secret/faz") -> {:ok, %{status_code: "whatever", body: Poison.Encoder.encode(%{"errors" => ["Not Authenticated"]},[])}}
      url |> String.contains?("secret/boom") -> {:error, %HTTPoison.Error{id: nil, reason: :econnrefused}}
      :else -> {:ok, %{} }
    end
  end

  def request(:put, url, _params, _, _) do
    cond do
      String.ends_with?(url, "secret/foo/withresponse") -> {:ok, %{status_code: 200, body: Poison.Encoder.encode(%{"data" => %{"value" => "bar"}},[])}}
      String.ends_with?(url, "secret/foo") -> {:ok, %{status_code: 204, body: ""}}
      String.ends_with?(url, "secret/foo/redirects") -> {:ok, %{status_code: 307, body: "", headers: [{"Location", "secret/foo"}]}}
      :else -> raise "Unmatched url #{url}"
    end
  end

  defp status_code(url, stringified_params) do
    if String.contains? stringified_params, "redirect" do
      if redirected_url? url do
        200
      else
        307
      end
    else
      "whatever"
    end
  end

  defp redirect_url(url) do
    "#{url}/redirected"
  end

  defp redirected_url?(url)do
    String.ends_with? url, "redirected"
  end
end
