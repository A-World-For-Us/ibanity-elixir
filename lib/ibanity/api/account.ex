defmodule Ibanity.Account do
  alias Ibanity.{Account, Client, CustomerAccessToken, ResourceOperations, Request}
  alias Ibanity.Client.Request, as: ClientRequest
  import Ibanity.Request

  defstruct [
    id: nil,
    subtype: nil,
    reference_type: nil,
    reference: nil,
    descrition: nil,
    current_balance: nil,
    currency: nil,
    available_balance: nil,
    financial_institution: nil,
    transactions: nil
  ]

  def key_mapping do
    [
      id: ~w(id),
      subtype: ~w(attributes subtype),
      reference_type: ~w(attributes referenceType),
      reference: ~w(attributes reference),
      description: ~w(attributes description),
      current_balance: ~w(attributes currentBalance),
      currency: ~w(attributes currency),
      available_balance: ~w(attributes availableBalance),
      transactions: ~w(relationships transactions links related),
      financial_institution: ~w(relationships financialInstitution links)
    ]
  end

  def list, do: list(%Request{})
  def list(financial_institution_id) when is_binary(financial_institution_id) do
    %Request{}
    |> Request.id(:financialInstitutionId, financial_institution_id)
    |> list
  end
  def list(%Request{} = request), do: list(request, Request.get_id(request, :financialInstitutionId))
  def list(%Request{} = request, nil) do
    request
    |> id(:accountId, "")
    |> ClientRequest.build(["customer", "accounts"], "account")
    |> ResourceOperations.list(__MODULE__)
  end
  def list(%Request{} = request, financial_institution_id) do
    request
    |> id(:accountId, "")
    |> id(:financialInstitutionId, financial_institution_id)
    |> ClientRequest.build(["customer", "financialInstitution", "accounts"], "account")
    |> ResourceOperations.list(__MODULE__)
  end

  def find(%Request{} = request) do
    request
    |> ClientRequest.build(["customer", "financialInstitution", "accounts"], "account")
    |> ResourceOperations.find(__MODULE__)
  end
  def find(%Request{} = request, account_id, financial_institution_id) do
    request
    |> id(:accountId, account_id)
    |> id(:financialInstitutionId, financial_institution_id)
    |> find
  end

  def delete(account_id, financial_institution_id) do
    delete(%Request{}, account_id, financial_institution_id)
  end
  def delete(%Request{} = request, account_id, financial_institution_id) do
    request
    |> id(:accountId, account_id)
    |> id(:financialInstitutionId, financial_institution_id)
    |> delete
  end
  def delete(%Request{} = request) do
    request
    |> ClientRequest.build(["customer", "financialInstitution", "accounts"], "account")
    |> ResourceOperations.destroy(__MODULE__)
  end
end