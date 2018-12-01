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
      assert record.standard_number == "1758-6798"
    end

    test "can handle files with \\n line endings" do
      {:ok, [%Scholarly.Record{} = record]} =
        ["TY  - JOUR", "SN  - 1758-6798", "ER  - "]
        |> Enum.join("\n")
        |> Scholarly.ResearchInfoSystems.parse()

      refute nil == record
      assert record.standard_number == "1758-6798"
    end

    test "can find multiple records from one file" do
      {:ok, [%Scholarly.Record{} = r1, %Scholarly.Record{} = r2]} =
        ["TY  - JOUR", "SN  - 1758-6798", "ER  - ",
         "TY  - JOUR", "SN  - 1758-6799", "ER  - ",]
        |> Enum.join("\r\n")
        |> Scholarly.ResearchInfoSystems.parse()

      refute nil == r1
      assert r1.standard_number == "1758-6798"

      refute nil == r2
      assert r2.standard_number == "1758-6799"
    end

    test "can load multiple authors" do
      {:ok, [r1]} =
        ["TY  - JOUR", "AU  - Halper, Santos L.", "AU  - Halper, Satchmo", "ER  - "]
        |> Enum.join("\r\n")
        |> Scholarly.ResearchInfoSystems.parse()
      
      assert %Scholarly.Record{authors: ["Halper, Santos L.", "Halper, Satchmo"]} = r1
    end

    test "parses sample file" do
      {:ok, f} = File.open("test/data/ris-test-0.ris", [:read])

      {:ok, [got]} =
        f
        |> IO.read(:all)
        |> Scholarly.ResearchInfoSystems.parse()

      assert %Scholarly.Record{
        type: "JOUR",
        title: "Antarctic surface hydrology and impacts on ice-sheet mass balance",

        abstract: "Melting is pervasive.",
        authors: ["Bell, Robin E.", "Banwell, Alison F.", "Trusel, Luke D.", "Kingslake, Jonathan"],

        journal: "Nature Climate Change",
        journal_assigned_id: "Bell2018",

        published_day: "19",
        published_month: "11",
        published_year: "2018",

        standard_number: "1758-6798",
        url: "https://doi.org/10.1038/s41558-018-0326-3",
        doi: "10.1038/s41558-018-0326-3"
      } == got
        
    end
  end
end
