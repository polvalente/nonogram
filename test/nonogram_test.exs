defmodule NonogramTest do
  use ExUnit.Case
  doctest Nonogram

  describe "solve/4" do
    row_definitions = [[5], [2], [4], [3], [1]]
    col_definitions = [[1], [1, 3], [1, 2], [4], [3]]

    assert Nonogram.solve(5, 5, row_definitions, col_definitions) == %Nonogram.Table{
             contents: [
               [true, true, true, true, true],
               [false, false, false, true, false],
               [false, true, true, true, true],
               [false, true, true, true, false],
               [false, true, false, false, false]
             ],
             height: 5,
             width: 5
           }

    row_definitions = [[2, 1], [2], [4], [1, 1], []]
    col_definitions = [[1, 1], [1, 1], [2], [3], [2]]

    assert Nonogram.solve(5, 5, row_definitions, col_definitions) == %Nonogram.Table{
             contents: [
               [false, false, false, false, false],
               [false, false, false, false, false],
               [false, true, true, true, false],
               [false, false, false, false, false],
               [false, false, false, false, false]
             ],
             height: 5,
             width: 5
           }

    row_definitions = [[2, 2], [1, 3], [4], [2], [1, 1, 1]]
    col_definitions = [[5], [1, 2], [2, 1], [3], [2, 1]]

    assert Nonogram.solve(5, 5, row_definitions, col_definitions) == %Nonogram.Table{
             contents: [
               [true, true, false, true, true],
               [true, false, true, true, true],
               [true, true, true, true, false],
               [true, false, false, false, false],
               [true, false, true, false, true]
             ],
             height: 5,
             width: 5
           }
  end
end
