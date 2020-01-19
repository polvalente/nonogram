defmodule Nonogram.Table do
  @moduledoc """
  A `%Table{}` struct contains the `:contents` key.
  `:contents` is a bi-dimensional matrix, in which:
    - `true` indicates there IS an element
    - `false` indicates there IS NOT an element
    - `nil` indicates no assertion has been made for the cell
  """
  defstruct [:contents, :height, :width]

  @type t :: %__MODULE__{
          contents: list(list(non_neg_integer)),
          height: non_neg_integer,
          width: non_neg_integer
        }

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

  @spec mark_defined(table :: t(), [{:rows | :cols, list(list(non_neg_integer))}]) :: t()
  def mark_defined(%{width: width} = table, rows: row_definitions) do
    indexed_rows = row_definitions |> Enum.with_index() |> Enum.map(fn {x, y} -> {y, x} end)

    {fully_defined_rows, remaining_rows} = get_fully_defined(indexed_rows, width)

    semi_defined_rows = get_semi_defined(remaining_rows, width)

    table
    |> set_defined_row_elements(Map.new(fully_defined_rows))
    |> set_semi_defined_row_elements(Map.new(semi_defined_rows))
  end

  def mark_defined(%{contents: contents} = table, cols: col_definitions) do
    updated =
      table
      |> Map.put(:contents, transpose(contents))
      |> mark_defined(rows: col_definitions)
      |> Map.get(:contents)
      |> transpose()

    %{table | contents: updated}
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
