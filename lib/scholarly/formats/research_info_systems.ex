defmodule Scholarly.ResearchInfoSystems do
  # https://en.wikipedia.org/wiki/RIS_(file_format)

  @split_pattern ~r/(?<linebreak>\r?\n)[A-Z][A-Z0-9]  -/sm
  @field_pattern ~r/\A(?<key>[A-Z][A-Z0-9])  - (?<value>.*)/sm

  def parse(input) when is_binary(input) do
    records = Regex.split(@split_pattern, input, on: [:linebreak])
      |> Enum.map(&split_field/1)
      |> split_records()
      |> Enum.map(&rows_to_record/1)

    {:ok, records}
  end

  defp split_records(rows) do
    # chunk until an ER row, then reverse the order of the rows to get
    # them back into file order
    chunker = fn row, acc ->
      case row do
        {"ER", _} -> {:cont, Enum.reverse(acc), []}
        _ -> {:cont, [row | acc]}
      end
    end

    finisher = fn _ -> {:cont, []} end

    Enum.chunk_while(rows, [], chunker, finisher)
  end

  defp rows_to_record(rows) do
    starter = %{
      record: %Scholarly.Record{},
      authors: %{"1": nil, "2": nil, "3": nil, "4": nil, from: [] }
    }
    filled = Enum.reduce(rows, starter, &add_field/2)

    authors = ~w(4 3 2 1)a
              |> Enum.reduce(Enum.reverse(filled[:authors][:from]),
                    fn k, acc -> [filled[:authors][k] | acc] end)
              |> Enum.reject(&is_nil/1)

    record = filled[:record]
    %{record | authors: authors}
  end

  defp split_field(input) do
    %{"key" => key, "value" => value} = Regex.named_captures(@field_pattern, input)
    {key, value}
  end

  defp add_field({"TY", value}, record) do
    update_simple record, :type, value
  end

  defp add_field({"TI", value}, record) do
    update_simple record, :title, value
  end

  defp add_field({"AB", value}, record) do
    update_simple record, :abstract, value
  end

  defp add_field({"JO", value}, record) do
    update_simple record, :journal, value
  end

  defp add_field({"ID", value}, record) do
    update_simple record, :journal_assigned_id, value
  end

  defp add_field({"AU", value}, record) do
    update_in record, [:authors, :from], &([value | &1])
  end

  defp add_field({"A1", value}, record) do
    put_in record, [:authors, :"1"], value
  end

  defp add_field({"A2", value}, record) do
    put_in record, [:authors, :"2"], value
  end

  defp add_field({"A3", value}, record) do
    put_in record, [:authors, :"3"], value
  end

  defp add_field({"A4", value}, record) do
    put_in record, [:authors, :"4"], value
  end

  defp add_field({"PY", value}, record) do
    update_simple record, :published_year, value
  end

  defp add_field({"DA", value}, record) do
    [y, m, d] = String.split(value, "/")
    record
    |> update_simple(:published_year, y)
    |> update_simple(:published_month, m)
    |> update_simple(:published_day, d)
  end

  defp add_field({"SN", value}, record) do
    update_simple record, :standard_number, value
  end

  defp add_field({"UR", value}, record) do
    update_simple record, :url, value
  end

  defp add_field({"DO", value}, record) do
    update_simple record, :doi, value
  end

  defp update_simple(record, field, value) do
    %{record | record: %{record.record | field => value}}
  end
end
