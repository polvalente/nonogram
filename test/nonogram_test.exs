defmodule NonogramTest do
  use ExUnit.Case
  doctest Nonogram

  describe "solve/4" do
    row_definitions = [[5], [2], [4], [3], [1]]
    col_definitions = [[1], [1, 3], [1, 2], [4], [3]]

    assert Nonogram.solve(5, 5, row_definitions, col_definitions) == %Nonogram.Table{
             contents: [
               [true, true, true, true, true],
               [nil, false, nil, true, nil],
               [nil, true, true, true, true],
               [nil, true, true, true, nil],
               [nil, true, nil, nil, nil]
             ],
             height: 5,
             width: 5
           }

    row_definitions = [[2, 1], [2], [4], [1, 1], []]
    col_definitions = [[1, 1], [1, 1], [2], [3], [2]]

    assert Nonogram.solve(5, 5, row_definitions, col_definitions) == %Nonogram.Table{
             contents: [
               [nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil],
               [nil, true, true, true, nil],
               [nil, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil]
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
               [true, true, true, true, nil],
               [true, nil, nil, nil, nil],
               [true, nil, true, nil, true]
             ],
             height: 5,
             width: 5
           }
  end
end
