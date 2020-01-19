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
        ) :: list(list(boolean()))
  def solve(height, width, rows, cols) do
    table =
      height
      |> Table.new(width)
      |> Table.mark_defined(rows: rows)
      |> Table.mark_defined(cols: cols)
  end
end
