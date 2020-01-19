defmodule Nonogram do
  @moduledoc """
  Documentation for Nonogram.
  """

  alias Nonogram.Table

  @type description :: list(non_neg_integer())

  @spec solve(
          height :: non_neg_integer,
          width :: non_neg_integer,
          rows :: list(description),
          columns :: list(description)
        ) :: Table.t()
  def solve(height, width, rows, cols) do
    height
    |> Table.new(width)
    |> Table.mark_defined(rows: rows)
    |> IO.inspect(label: "defined_rows")
    |> Table.mark_defined(cols: cols)
  end
end
