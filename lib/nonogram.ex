defmodule Nonogram do
  @moduledoc """
  Documentation for Nonogram.
  """

  alias Nonogram.Table

  @spec solve(
          height :: non_neg_integer,
          width :: non_neg_integer,
          rows :: Table.definitions(),
          columns :: Table.definitions()
        ) :: Table.t()
  def solve(height, width, rows, cols) do
    height
    |> Table.new(width)
    |> Table.mark_defined(rows: rows, cols: cols)
  end
end
