defmodule Scholarly.Record do
  defstruct type: nil,
            authors: [],
            title: nil,
            short_title: nil,
            primary_title: nil,
            abstract: nil,

            journal: nil,
            journal_assigned_id: nil,

            # global identification
            doi: nil,
            standard_number: nil,
            url: nil,

            # publishing info
            published_year: nil,
            published_month: nil,
            published_day: nil
end
