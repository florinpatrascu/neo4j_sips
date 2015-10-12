defmodule Neo4j.Sips.Response do
  @moduledoc ~S"""
  Defines the structure for a raw REST response received from a Neo4j server.
  """

  # @derive Access
  defstruct [:results, :transaction, :commit, :errors]

  def to_rows(sip) do
    errors = sip.errors
    if (length(errors) > 0) do
      {:error, errors}
    else
      {:ok, sip.results |> Enum.map(&format_response(&1))}
    end
  end

  defp format_response(response) do
    columns = response["columns"]
    response["data"]
    |> Enum.map(fn data -> Map.get(data, "row") end)
    |> Enum.map(fn data -> Enum.zip(columns, data) end)
    |> Enum.map(fn data -> Enum.into(data, %{}) end)
  end
end
