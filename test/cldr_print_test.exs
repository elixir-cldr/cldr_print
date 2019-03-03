defmodule Cldr.Print.Test do
  use ExUnit.Case
  doctest Cldr.Print

  test "decimal sprintf! with field width" do
    assert Cldr.Print.sprintf!("%3d", [0]) ==	"  0"
    assert Cldr.Print.sprintf!("%3d", [123456789]) ==	"123456789"
    assert Cldr.Print.sprintf!("%3d", [-10]) ==	"-10"
    assert Cldr.Print.sprintf!("%3d", [-123456789]) ==	"-123456789"
  end

  test "decimal sprintf! with negative field width" do
    assert Cldr.Print.sprintf!("%-3d", [0]) ==	"0  "
    assert Cldr.Print.sprintf!("%-3d", [123456789]) == "123456789"
    assert Cldr.Print.sprintf!("%-3d", [-10]) ==	"-10"
    assert Cldr.Print.sprintf!("%-3d", [-123456789]) == "-123456789"
  end

  test "decimal sprintf! with zero fill width" do
    assert Cldr.Print.sprintf!("%03d", [0]) ==	"000"
    assert Cldr.Print.sprintf!("%03d", [1]) ==	"001"
    assert Cldr.Print.sprintf!("%03d", [123456789]) ==	"123456789"
    assert Cldr.Print.sprintf!("%03d", [-10]) ==	"-10"
    assert Cldr.Print.sprintf!("%03d", [-123456789]) ==	"-123456789"
  end

  test "decimal sprintf! additional examples" do
    assert Cldr.Print.sprintf!("'%5d'", [10]) ==	"'   10'"
    assert Cldr.Print.sprintf!("'%-5d'", [10]) ==	"'10   '"
    assert Cldr.Print.sprintf!("'%05d'", [10]) ==	"'00010'"
    assert Cldr.Print.sprintf!("'%+5d'", [10]) ==	"'  +10'"
    assert Cldr.Print.sprintf!("'%-+5d'", [10]) ==	"'+10  '"
    assert Cldr.Print.sprintf!("'%+05d'", [10]) ==	"'+0010'"
  end

  test "formatting floating point numbers" do
    assert Cldr.Print.sprintf!("'%.1f'", 10.3456) ==	"'10.3'"
    assert Cldr.Print.sprintf!("'%.2f'", 10.3456) ==	"'10.35'"
    assert Cldr.Print.sprintf!("'%8.2f'", 10.3456) ==	"'   10.35'"
    assert Cldr.Print.sprintf!("'%8.4f'", 10.3456) ==	"' 10.3456'"
    assert Cldr.Print.sprintf!("'%08.2f'", 10.3456) ==	"'00010.35'"
    assert Cldr.Print.sprintf!("'%-8.2f'", 10.3456) ==	"'10.35   '"
    assert Cldr.Print.sprintf!("'%-8.2f'", 101234567.3456) ==	"'101234567.35'"
  end

  test "string formatting" do
    assert Cldr.Print.sprintf!("'%s'", "Hello") ==	"'Hello'"
    assert Cldr.Print.sprintf!("'%10s'", "Hello") ==	"'     Hello'"
    assert Cldr.Print.sprintf!("'%-10s'", "Hello") ==	"'Hello     '"

    assert Cldr.Print.sprintf!("'%s'", "Hello, world!") == "'Hello, world!'"
    assert Cldr.Print.sprintf!("'%15s'", "Hello, world!") == "'  Hello, world!'"
    assert Cldr.Print.sprintf!("'%.10s'", "Hello, world!") == "'Hello, wor'"
    assert Cldr.Print.sprintf!("'%-10s'", "Hello, world!") == "'Hello, world!'"
    assert Cldr.Print.sprintf!("'%-15s'", "Hello, world!") == "'Hello, world!  '"
    assert Cldr.Print.sprintf!("'%.15s'", "Hello, world!") == "'Hello, world!'"
    assert Cldr.Print.sprintf!("'%15.10s'", "Hello, world!") == "'     Hello, wor'"
    assert Cldr.Print.sprintf!("'%-15.10s'", "Hello, world!") == "'Hello, wor     '"
  end

  test "that we can use the I flag to generate other digit systems" do
    assert Cldr.Print.sprintf!("'%I5d'", [10], locale: "th", backend: Cldr.Print.TestBackend) ==
      "'   ๑๐'"
  end
end
