defmodule Cldr.Print.Macro.Test do
  use ExUnit.Case

  defmodule TestModule do
    require Cldr.Print

    def test1 do
      Cldr.Print.msprintf("this is %d and %.1f", [10, 11.5])
    end

    def test2 do
      Cldr.Print.msprintf!("this is %d and %.1f", [10, 11.5])
    end
  end

  test "We can execute a macro" do
    assert TestModule.test1() == {:ok, "this is 10 and 11.5"}
    assert TestModule.test2() == "this is 10 and 11.5"
  end
end