defmodule Nonogram.TableTest do
  use ExUnit.Case, async: true

  setup do
    %{
      first: %Nonogram.Table{
        contents: [
          [nil, true, nil, true, nil],
          [true, nil, true, nil, true],
          [nil, nil, nil, nil, nil],
          [nil, nil, true, nil, nil],
          [false, false, true, false, false]
        ],
        height: 5,
        width: 5
      },
      second: %Nonogram.Table{
        contents: [
          [true, nil, true, nil, true],
          [nil, true, nil, true, nil],
          [nil, nil, nil, false, false],
          [false, false, true, false, false],
          [nil, nil, true, nil, nil]
        ],
        height: 5,
        width: 5
      }
    }
  end

  describe "String.Chars" do
    test "Should render as a string when IO.puts is used", %{first: first, second: second} do
      assert String.trim_trailing("""
             _*_*_
             *_*_*
             .....
             __*__
             __*__
             """) == String.Chars.to_string(first)

      assert String.trim_trailing("""
             *_*_*
             _*_*_
             ...__
             __*__
             __*__
             """) == String.Chars.to_string(second)
    end
  end

  describe "combine/2" do
    test "should combine contents", %{first: first, second: second} do
      expected = %Nonogram.Table{
        contents: [
          [true, true, true, true, true],
          [true, true, true, true, true],
          [nil, nil, nil, false, false],
          [false, false, true, false, false],
          [false, false, true, false, false]
        ],
        height: 5,
        width: 5
      }

      assert expected == Nonogram.Table.combine(first, second)
    end
  end
end
