defmodule Nonogram.Table do
  @moduledoc """
  A `%Table{}` struct contains the `:contents` key.
  `:contents` is a bi-dimensional matrix, in which:
    - `true` indicates there IS an element
    - `false` indicates there IS NOT an element
    - `nil` indicates no assertion has been made for the cell
  """
  @derive [Inspect]
  defstruct [:contents, :height, :width]

  @type t :: %__MODULE__{
          contents: list(list(non_neg_integer)),
          height: non_neg_integer,
          width: non_neg_integer
        }

  @type definitions :: list(list(non_neg_integer))

  @spec new(height :: non_neg_integer, width :: non_neg_integer) :: t()
  def new(height, width) do
    contents =
      Enum.reduce(1..height, [], fn _, acc ->
        row = [nil] |> Stream.cycle() |> Enum.take(width)

        [row | acc]
      end)

    %__MODULE__{contents: contents, height: height, width: width}
  end

  @spec combine(first :: t(), second :: Nonogram.Table.t()) :: t()
  def combine(
        %__MODULE__{height: height, width: width, contents: first} = original,
        %__MODULE__{height: height, width: width, contents: second}
      ) do
    flat_first = List.flatten(first)
    flat_second = List.flatten(second)

    contents =
      flat_first
      |> combine_row(flat_second)
      |> Enum.chunk_every(width)

    %{original | contents: contents}
  end

  @spec mark_defined(table :: t(), rows: definitions, cols: definitions) :: t()
  def mark_defined(table, rows: rows, cols: cols) do
    table
    |> mark_defined_rows(rows)
    |> mark_defined_cols(cols)
    |> post_check(rows: rows, cols: cols)
  end

  defp mark_defined_rows(%{width: width} = table, row_definitions) do
    indexed_rows = row_definitions |> Enum.with_index() |> Enum.map(fn {x, y} -> {y, x} end)

    {fully_defined_rows, remaining_rows} = get_fully_defined(indexed_rows, width)
    fully_defined_rows = Map.new(fully_defined_rows)

    semi_defined_rows =
      remaining_rows
      |> get_semi_defined(width)
      |> Map.new()

    table
    |> set_defined_row_elements(fully_defined_rows)
    |> set_semi_defined_row_elements(semi_defined_rows)
  end

  defp mark_defined_cols(%{contents: contents} = table, col_definitions) do
    updated =
      table
      |> Map.put(:contents, transpose(contents))
      |> mark_defined_rows(col_definitions)
      |> Map.get(:contents)
      |> transpose()

    %{table | contents: updated}
  end

  defp post_check(%__MODULE__{contents: contents} = table,
         rows: row_definitions,
         cols: col_definitions
       ) do
    updated =
      contents
      |> post_check_rows(row_definitions)
      |> post_check_cols(col_definitions)

    %{table | contents: updated}
  end

  defp post_check_cols(contents, definitions) do
    contents
    |> transpose()
    |> post_check_rows(definitions)
    |> transpose()
  end

  defp post_check_rows(contents, definitions) do
    # checks if there are any remaining rows that are now solved, and marks them as such
    contents
    |> Enum.with_index()
    |> Enum.map(fn {row, idx} ->
      case Enum.at(definitions, idx) do
        [] ->
          row

        values ->
          expected = Enum.sum(values)
          current = Enum.count(row, & &1)

          if current == expected do
            Enum.map(row, fn x -> x == true end)
          else
            row
          end
      end
    end)
  end

  defp transpose(matrix) do
    matrix
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp get_fully_defined(indexed_definitions, dimension) do
    Enum.split_with(indexed_definitions, fn {_, item} ->
      Enum.sum(item) + length(item) - 1 == dimension
    end)
  end

  defp get_semi_defined(indexed_definitions, dimension) do
    Enum.filter(indexed_definitions, fn {_, item} ->
      Enum.any?(item, &(&1 > div(dimension, 2)))
    end)
  end

  defp set_defined_row_elements(%{contents: contents} = table, indexed_definitions) do
    updated =
      contents
      |> Enum.with_index()
      |> Enum.map(fn {row, index} ->
        case Map.get(indexed_definitions, index) do
          nil ->
            row

          definition ->
            definition
            |> gen_defined()
            |> combine_row(row)
        end
      end)

    %{table | contents: updated}
  end

  defp set_semi_defined_row_elements(
         %{contents: contents, width: width} = table,
         indexed_definitions
       ) do
    updated =
      contents
      |> Enum.with_index()
      |> Enum.map(fn {row, index} ->
        case Map.get(indexed_definitions, index) do
          nil ->
            row

          definition ->
            definition
            |> gen_semi_defined(width)
            |> combine_row(row)
        end
      end)

    %{table | contents: updated}
  end

  defp gen_defined(definition) do
    definition
    |> Enum.map(fn x ->
      [true] |> Stream.cycle() |> Enum.take(x)
    end)
    |> Enum.intersperse(false)
    |> List.flatten()
  end

  defp gen_semi_defined(definition, width) do
    half = div(width, 2)

    empty = [nil] |> Stream.cycle() |> Enum.take(width)

    case Enum.find(definition, &(&1 > half)) do
      nil ->
        empty

      val ->
        range =
          if rem(width, 2) == 0 do
            elements = val - half
            # i.e width 10, val = 7
            # elements = 7 - 5 = 2
            # range = 3..6

            (half - elements)..(half + elements - 1)
          else
            # i.e width 5, val = 4
            # half = 2
            # elements = 4 - 2 = 2
            # range = (2 - 2 + 1)..(2 + 2 - 1) = 1..3

            elements = val - half
            (half - elements + 1)..(half + elements - 1)
          end

        Enum.map(0..(width - 1), fn x -> x in range || nil end)
    end
  end

  defp combine_row(this, other) do
    this
    |> Enum.zip(other)
    |> Enum.map(fn
      {x, y} when x == true or y == true -> true
      {x, y} when x == false or y == false -> false
      _ -> nil
    end)
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%Nonogram.Table{contents: contents}) when is_list(contents) do
      contents
      |> Enum.map(fn row ->
        row
        |> Enum.map(fn
          false -> "."
          true -> "*"
          nil -> "_"
        end)
        |> Enum.join()
      end)
      |> Enum.join("\n")
    end

    def to_string(table), do: inspect(table)
  end
end
