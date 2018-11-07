defmodule Ibanity.Client do
  @moduledoc """
  Wrapper for Ibanity API
  """

  alias Ibanity.Configuration, as: Config
  alias Ibanity.Request

  defmodule Request do
    @moduledoc """
    Parameters that will be passed as-is to the HTTP client
    """
    defstruct [
      headers: [],
      data: nil,
      query_params: [],
      uri: nil,
      method: nil
    ]

    def build(%Ibanity.Request{} = request, http_method, uri_path, resource_type \\ nil) do
      uri = get_in(Config.api_schema(), uri_path)
      request = %Ibanity.Request{request | uri: uri}
      request = Ibanity.ResourceIdentifier.substitute_in_uri(request)

      %Ibanity.Client.Request{
        headers: create_headers(request),
        data:    create_data(request)
      }
      |> uri(request.uri)
      |> resource_type(resource_type)
      |> add_signature(http_method, uri, Config.signature_options())
    end

    defp add_signature(request, _method, _uri, nil), do: request
    defp add_signature(request, method, uri, signature_options) do
      private_key = Keyword.get(signature_options, :signature_key)
      certificate_id = Keyword.get(signature_options, :certificate_id)
      signature_headers = Ibanity.Signature.signature_headers(request, method, uri, private_key, certificate_id)

      %Ibanity.Client.Request{request | headers: Keyword.merge(request.headers, signature_headers)}
    end

    defp uri(%__MODULE__{} = request, uri), do: %__MODULE__{request | uri: uri}

    defp resource_type(%__MODULE__{} = request, nil), do: request
    defp resource_type(%__MODULE__{} = request, type) do
      if Map.has_key?(request.data, :type) do
        request
      else
        %__MODULE__{request | data: Map.put(request.data, :type, type)}
      end
    end

    defp create_headers(request) do
      request.headers
      |> add_idempotency_key(request)
      |> add_customer_access_token(request)
    end

    defp add_idempotency_key(headers, request) do
      if request.idempotency_key do
        Keyword.put(headers, :"Ibanity-Idempotency-Key", request.idempotency_key)
      else
        headers
      end
    end

    defp add_customer_access_token(headers, request) do
      if request.customer_access_token do
        Keyword.put(headers, :Authorization, "Bearer #{request.customer_access_token}")
      else
        headers
      end
    end

    defp create_data(request) do
      %{}
      |> add_attributes(request)
      |> add_type(request)
    end

    defp add_attributes(data, request) do
      if Enum.empty?(request.attributes) do
        data
      else
        Map.put(data, :attributes, request.attributes)
      end
    end

    defp add_type(data, request) do
      if request.resource_type do
        Map.put(data, :type, request.resource_type)
      else
        data
      end
    end
  end

  def get(%Request{} = request) do
    res = HTTPoison.get!(
      request.uri,
      request.headers,
      ssl: Config.ssl_options()
    )
    process_response(res)
  end

  def post(%Request{} = request) do
    res = HTTPoison.post!(
      request.uri,
      Jason.encode!(%{data: request.data}),
      request.headers,
      ssl: Config.ssl_options()
    )

    process_response(res)
  end

  def patch(%Request{} = request) do
    res = HTTPoison.patch!(
      request.uri,
      Jason.encode!(%{data: request.data}),
      request.headers,
      ssl: Config.ssl_options()
    )

    process_response(res)
  end

  def delete(%Request{} = request) do
    res = HTTPoison.delete!(
      request.uri,
      request.headers,
      ssl: Config.ssl_options()
    )

    process_response(res)
  end

  defp process_response(response) do
    code = response.status_code
    body = Jason.decode!(response.body)

    cond do
      code >= 200 and code <= 299 ->
        {:ok, Map.fetch!(body, "data")}
      code >= 400 and code <= 599 ->
        {:error, Map.fetch!(body, "errors")}
      true ->
        raise "Unknown return code: #{code}"
    end
  end
end
