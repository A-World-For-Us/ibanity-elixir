defmodule Ibanity.DateTimeUtil do
  def parse(string) do
    case DateTime.from_iso8601(string) do
      {:ok, datetime, 0} -> datetime
      {:error, _}        -> nil
    end
  end
end