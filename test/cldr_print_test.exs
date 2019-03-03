defmodule Cldr.Print.Test do
  use ExUnit.Case
  doctest Cldr.Print

  test "decimal printf with field width" do
    assert Cldr.Print.printf("%3d", [0]) ==	"  0"
    assert Cldr.Print.printf("%3d", [123456789]) ==	"123456789"
    assert Cldr.Print.printf("%3d", [-10]) ==	"-10"
    assert Cldr.Print.printf("%3d", [-123456789]) ==	"-123456789"
  end

  test "decimal printf with negative field width" do
    assert Cldr.Print.printf("%-3d", [0]) ==	"0  "
    assert Cldr.Print.printf("%-3d", [123456789]) == "123456789"
    assert Cldr.Print.printf("%-3d", [-10]) ==	"-10"
    assert Cldr.Print.printf("%-3d", [-123456789]) == "-123456789"
  end

  test "decimal printf with zero fill width" do
    assert Cldr.Print.printf("%03d", [0]) ==	"000"
    assert Cldr.Print.printf("%03d", [1]) ==	"001"
    assert Cldr.Print.printf("%03d", [123456789]) ==	"123456789"
    assert Cldr.Print.printf("%03d", [-10]) ==	"-10"
    assert Cldr.Print.printf("%03d", [-123456789]) ==	"-123456789"
  end

  test "decimal printf additional examples" do
    assert Cldr.Print.printf("'%5d'", [10]) ==	"'   10'"
    assert Cldr.Print.printf("'%-5d'", [10]) ==	"'10   '"
    assert Cldr.Print.printf("'%05d'", [10]) ==	"'00010'"
    assert Cldr.Print.printf("'%+5d'", [10]) ==	"'  +10'"
    assert Cldr.Print.printf("'%-+5d'", [10]) ==	"'+10  '"
    assert Cldr.Print.printf("'%+05d'", [10]) ==	"'+0010'"
  end

  test "formatting floating point numbers" do
    assert Cldr.Print.printf("'%.1f'", 10.3456) ==	"'10.3'"
    assert Cldr.Print.printf("'%.2f'", 10.3456) ==	"'10.35'"
    assert Cldr.Print.printf("'%8.2f'", 10.3456) ==	"'   10.35'"
    assert Cldr.Print.printf("'%8.4f'", 10.3456) ==	"' 10.3456'"
    assert Cldr.Print.printf("'%08.2f'", 10.3456) ==	"'00010.35'"
    assert Cldr.Print.printf("'%-8.2f'", 10.3456) ==	"'10.35   '"
    assert Cldr.Print.printf("'%-8.2f'", 101234567.3456) ==	"'101234567.35'"
  end

  test "string formatting" do
    assert Cldr.Print.printf("'%s'", "Hello") ==	"'Hello'"
    assert Cldr.Print.printf("'%10s'", "Hello") ==	"'     Hello'"
    assert Cldr.Print.printf("'%-10s'", "Hello") ==	"'Hello     '"

    assert Cldr.Print.printf("'%s'", "Hello, world!") == "'Hello, world!'"
    assert Cldr.Print.printf("'%15s'", "Hello, world!") == "'  Hello, world!'"
    assert Cldr.Print.printf("'%.10s'", "Hello, world!") == "'Hello, wor'"
    assert Cldr.Print.printf("'%-10s'", "Hello, world!") == "'Hello, world!'"
    assert Cldr.Print.printf("'%-15s'", "Hello, world!") == "'Hello, world!  '"
    assert Cldr.Print.printf("'%.15s'", "Hello, world!") == "'Hello, world!'"
    assert Cldr.Print.printf("'%15.10s'", "Hello, world!") == "'     Hello, wor'"
    assert Cldr.Print.printf("'%-15.10s'", "Hello, world!") == "'Hello, wor     '"
  end
end
