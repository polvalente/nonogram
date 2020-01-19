defmodule Nonogram.Table do
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
        row = [false] |> Stream.cycle() |> Enum.take(width)

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
      |> Enum.zip(flat_second)
      |> Enum.map(fn {x, y} -> x || y end)
      |> Enum.chunk_every(width)

    %{original | contents: contents}
  end

  @spec mark_defined(table :: t(), [{:rows | :cols, list(list(non_neg_integer))}]) :: t()
  def mark_defined(%{width: width} = table, rows: row_definitions) do
    indexed_rows = row_definitions |> Enum.with_index() |> Enum.map(fn {x, y} -> {y, x} end)

    {fully_defined_rows, remaining_rows} = get_fully_defined(indexed_rows, width)

    semi_defined_rows = get_semi_defined(remaining_rows, width)

    val =
      table
      |> set_defined_row_elements(Map.new(fully_defined_rows))

    IO.inspect(val, label: "defined")

    val
    |> set_semi_defined_row_elements(Map.new(semi_defined_rows))
    |> IO.inspect(label: "semi_defined")
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
            |> Enum.zip(row)
            |> Enum.map(fn {x, y} -> x || y end)
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
            |> Enum.zip(row)
            |> Enum.map(fn {x, y} -> x || y end)
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

    empty = [false] |> Stream.cycle() |> Enum.take(width)

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
            range = (half - elements)..(half + elements - 1)
            IO.inspect(val, label: "val")
            IO.inspect(half, label: "half")
            IO.inspect(elements, label: "elements")
            IO.inspect(range, label: "range")
          else
            elements = val - half
            range = (half - elements + 1)..(half + elements - 1)

            IO.inspect(val, label: "val")
            IO.inspect(half, label: "half")
            IO.inspect(elements, label: "elements")
            IO.inspect(range, label: "range")
          end

        Enum.map(0..(width - 1), fn x -> x in range end)
    end
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%Nonogram.Table{contents: contents}) when is_list(contents) do
      contents
      |> Enum.map(fn row ->
        row
        |> Enum.map(fn
          false -> "_"
          true -> "*"
        end)
        |> Enum.join()
      end)
      |> Enum.join("\n")
    end

    def to_string(table), do: inspect(table)
  end
end
