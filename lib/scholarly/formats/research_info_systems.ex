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

  @field_pattern ~r/\A(?<key>[A-Z][A-Z])  - (?<value>.*)/sm

  def split_records(rows) do
    chunker = fn row, acc ->
      case row do
        {"ER", _} -> {:cont, Enum.reverse(acc), []}
        _ -> {:cont, [row | acc]}
      end
    end

    finisher = fn
      [] -> {:cont, []}
      acc -> {:cont, []}
    end

    Enum.chunk_while(rows, [], chunker, finisher)
  end

  def rows_to_record(rows) do
    Enum.reduce(rows, %Scholarly.Record{}, &add_field/2)
  end

  def split_field(input) do
    %{"key" => key, "value" => value} = Regex.named_captures(@field_pattern, input)
    {key, value}
  end

  def add_field({"TY", value}, record) do
    %{record | type: value}
  end

  def add_field({"AU", value}, record) do
    %{record | authors: record.authors ++ [value]}
  end

  def add_field({"SN", value}, record) do
    %{record | standard_number: value}
  end
end
