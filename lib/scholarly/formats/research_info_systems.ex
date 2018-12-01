defmodule Scholarly.ResearchInfoSystems do
  # https://en.wikipedia.org/wiki/RIS_(file_format)

  @split_pattern ~r/(?<linebreak>\r?\n)[A-Z][A-Z]  -/sm
  @field_pattern ~r/\A(?<key>[A-Z][A-Z])  - (?<value>.*)/sm

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
    Enum.reduce(rows, %Scholarly.Record{}, &add_field/2)
  end

  defp split_field(input) do
    %{"key" => key, "value" => value} = Regex.named_captures(@field_pattern, input)
    {key, value}
  end

  defp add_field({"TY", value}, record) do
    %{record | type: value}
  end

  defp add_field({"TI", value}, record) do
    %{record | title: value}
  end

  defp add_field({"AB", value}, record) do
    %{record | abstract: value}
  end

  defp add_field({"JO", value}, record) do
    %{record | journal: value}
  end

  defp add_field({"ID", value}, record) do
    %{record | journal_assigned_id: value}
  end

  defp add_field({"AU", value}, record) do
    %{record | authors: record.authors ++ [value]}
  end

  defp add_field({"PY", value}, record) do
    %{record | published_year: value}
  end

  defp add_field({"DA", value}, record) do
    [y, m, d] = String.split(value, "/")
    %{record | published_year: y, published_month: m, published_day: d}
  end

  defp add_field({"SN", value}, record) do
    %{record | standard_number: value}
  end

  defp add_field({"UR", value}, record) do
    %{record | url: value}
  end

  defp add_field({"DO", value}, record) do
    %{record | doi: value}
  end
end
