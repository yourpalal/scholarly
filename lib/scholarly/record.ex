defmodule Scholarly.Record do
  defstruct type: nil,
            authors: [],
            title: nil,
            short_title: nil,
            primary_title: nil,
            abstract: nil,

            # global identification
            doi: nil,
            standard_number: nil,
            url: nil
end
