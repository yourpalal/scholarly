defmodule ScholarlyTest do
  use ExUnit.Case
  doctest Scholarly

  describe "ris parser" do
    test "parses a very simple example" do
      {:ok, [%Scholarly.Record{} = record]} =
        ["TY  - JOUR", "SN  - 1758-6798", "ER  - "]
        |> Enum.join("\r\n")
        |> Scholarly.ResearchInfoSystems.parse()

      refute nil == record
      assert %Scholarly.Record{} = record
      assert record.standard_number == "1758-6798"
    end

    test "parses sample file" do
      {:ok, f} = File.open("test/data/ris-test-0.ris", [:read])

      {:ok, _} =
        f
        |> IO.read(:all)
        |> Scholarly.ResearchInfoSystems.parse()
    end
  end
end
