defmodule Nonogram.TableTest do
  use ExUnit.Case, async: true

  setup do
    %{
      first: %Nonogram.Table{
        contents: [
          [false, true, false, true, false],
          [true, false, true, false, true],
          [false, false, false, false, false],
          [false, false, true, false, false],
          [false, false, true, false, false]
        ],
        height: 5,
        width: 5
      },
      second: %Nonogram.Table{
        contents: [
          [true, false, true, false, true],
          [false, true, false, true, false],
          [false, false, false, false, false],
          [false, false, true, false, false],
          [false, false, true, false, false]
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
             _____
             __*__
             __*__
             """) == String.Chars.to_string(first)

      assert String.trim_trailing("""
             *_*_*
             _*_*_
             _____
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
          [false, false, false, false, false],
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
