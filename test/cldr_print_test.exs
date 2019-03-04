defmodule Cldr.Print.Test do
  use ExUnit.Case
  doctest Cldr.Print

  test "decimal sprintf! with field width" do
    assert Cldr.Print.sprintf!("%3d", [0]) ==	"  0"
    assert Cldr.Print.sprintf!("%3d", [123456789]) ==	"123456789"
    assert Cldr.Print.sprintf!("%3d", [-10]) ==	"-10"
    assert Cldr.Print.sprintf!("%3d", [-123456789]) ==	"-123456789"
  end

  test "decimal sprintf! with field width for Decimals" do
    assert Cldr.Print.sprintf!("%3d", Decimal.new(0)) ==	"  0"
    assert Cldr.Print.sprintf!("%3d", Decimal.new(123456789)) ==	"123456789"
    assert Cldr.Print.sprintf!("%3d", Decimal.new(-10)) ==	"-10"
    assert Cldr.Print.sprintf!("%3d", Decimal.new(-123456789)) ==	"-123456789"
  end

  test "decimal sprintf! with negative field width" do
    assert Cldr.Print.sprintf!("%-3d", [0]) ==	"0  "
    assert Cldr.Print.sprintf!("%-3d", [123456789]) == "123456789"
    assert Cldr.Print.sprintf!("%-3d", [-10]) ==	"-10"
    assert Cldr.Print.sprintf!("%-3d", [-123456789]) == "-123456789"
  end

  test "decimal sprintf! with negative field width for Decimals" do
    assert Cldr.Print.sprintf!("%-3d", Decimal.new(0)) ==	"0  "
    assert Cldr.Print.sprintf!("%-3d", Decimal.new(123456789)) == "123456789"
    assert Cldr.Print.sprintf!("%-3d", Decimal.new(-10)) ==	"-10"
    assert Cldr.Print.sprintf!("%-3d", Decimal.new(-123456789)) == "-123456789"
  end

  test "decimal sprintf! with zero fill width" do
    assert Cldr.Print.sprintf!("%03d", [0]) ==	"000"
    assert Cldr.Print.sprintf!("%03d", [1]) ==	"001"
    assert Cldr.Print.sprintf!("%03d", [123456789]) ==	"123456789"
    assert Cldr.Print.sprintf!("%03d", [-10]) ==	"-10"
    assert Cldr.Print.sprintf!("%03d", [-123456789]) ==	"-123456789"
  end

  test "decimal sprintf! with zero fill width with Decimals" do
    assert Cldr.Print.sprintf!("%03d", Decimal.new(0)) ==	"000"
    assert Cldr.Print.sprintf!("%03d", Decimal.new(1)) ==	"001"
    assert Cldr.Print.sprintf!("%03d", Decimal.new(123456789)) ==	"123456789"
    assert Cldr.Print.sprintf!("%03d", Decimal.new(-10)) ==	"-10"
    assert Cldr.Print.sprintf!("%03d", Decimal.new(-123456789)) ==	"-123456789"
  end

  test "decimal sprintf! additional examples" do
    assert Cldr.Print.sprintf!("'%5d'", [10]) ==	"'   10'"
    assert Cldr.Print.sprintf!("'%-5d'", [10]) ==	"'10   '"
    assert Cldr.Print.sprintf!("'%05d'", [10]) ==	"'00010'"
    assert Cldr.Print.sprintf!("'%+5d'", [10]) ==	"'  +10'"
    assert Cldr.Print.sprintf!("'%-+5d'", [10]) ==	"'+10  '"
    assert Cldr.Print.sprintf!("'%+05d'", [10]) ==	"'+0010'"
  end

  test "decimal sprintf! additional examples with i format" do
    assert Cldr.Print.sprintf!("'%5i'", [10]) ==	"'   10'"
    assert Cldr.Print.sprintf!("'%-5i'", [10]) ==	"'10   '"
    assert Cldr.Print.sprintf!("'%05i'", [10]) ==	"'00010'"
    assert Cldr.Print.sprintf!("'%+5i'", [10]) ==	"'  +10'"
    assert Cldr.Print.sprintf!("'%-+5i'", [10]) ==	"'+10  '"
    assert Cldr.Print.sprintf!("'%+05i'", [10]) ==	"'+0010'"
  end

  test "decimal sprintf! additional examples with o format" do
    assert Cldr.Print.sprintf!("'%5o'", [10]) ==	  "'   12'"
    assert Cldr.Print.sprintf!("'%-5o'", [10]) ==	  "'12   '"
    assert Cldr.Print.sprintf!("'%05o'", [10]) ==	  "'   12'"
    assert Cldr.Print.sprintf!("'%+5o'", [10]) ==	  "'  +12'"
    assert Cldr.Print.sprintf!("'%-+5o'", [10]) ==	"'+12  '"
    assert Cldr.Print.sprintf!("'%+05o'", [10]) ==	"'  +12'"
  end

  test "decimal sprintf! additional examples with o format and # flag" do
    assert Cldr.Print.sprintf!("'%#5o'", [10]) ==	  "'  012'"
    assert Cldr.Print.sprintf!("'%-#5o'", [10]) ==	"'012  '"
    assert Cldr.Print.sprintf!("'%#05o'", [10]) ==	"'  012'"
    assert Cldr.Print.sprintf!("'%#+5o'", [10]) ==	"' +012'"
    assert Cldr.Print.sprintf!("'%#-+5o'", [10]) ==	"'+012 '"
    assert Cldr.Print.sprintf!("'%#+05o'", [10]) ==	"' +012'"
  end

  test "decimal sprintf! additional examples with x format" do
    assert Cldr.Print.sprintf!("'%5x'", [10]) ==	  "'    a'"
    assert Cldr.Print.sprintf!("'%-5x'", [10]) ==	  "'a    '"
    assert Cldr.Print.sprintf!("'%05x'", [10]) ==	  "'    a'"
    assert Cldr.Print.sprintf!("'%+5x'", [10]) ==	  "'   +a'"
    assert Cldr.Print.sprintf!("'%-+5x'", [10]) ==	"'+a   '"
    assert Cldr.Print.sprintf!("'%+05x'", [10]) ==	"'   +a'"
  end

  test "decimal sprintf! additional examples with x format and # flag" do
    assert Cldr.Print.sprintf!("'%#5x'", [10]) ==	  "'  0xa'"
    assert Cldr.Print.sprintf!("'%-#5x'", [10]) ==	"'0xa  '"
    assert Cldr.Print.sprintf!("'%#05x'", [10]) ==	"'  0xa'"
    assert Cldr.Print.sprintf!("'%#+5x'", [10]) ==	"' +0xa'"
    assert Cldr.Print.sprintf!("'%#-+5x'", [10]) ==	"'+0xa '"
    assert Cldr.Print.sprintf!("'%#+05x'", [10]) ==	"' +0xa'"
  end

  test "decimal sprintf! additional examples with Decimals" do
    assert Cldr.Print.sprintf!("'%5d'", Decimal.new(10)) ==	"'   10'"
    assert Cldr.Print.sprintf!("'%-5d'", Decimal.new(10)) ==	"'10   '"
    assert Cldr.Print.sprintf!("'%05d'", Decimal.new(10)) ==	"'00010'"
    assert Cldr.Print.sprintf!("'%+5d'", Decimal.new(10)) ==	"'  +10'"
    assert Cldr.Print.sprintf!("'%-+5d'", Decimal.new(10)) ==	"'+10  '"
    assert Cldr.Print.sprintf!("'%+05d'", Decimal.new(10)) ==	"'+0010'"
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

  test "formatting floating point numbers with i format" do
    assert Cldr.Print.sprintf!("'%.1i'", 10.3456) ==	"'10'"
    assert Cldr.Print.sprintf!("'%.2i'", 10.3456) ==	"'10'"
    assert Cldr.Print.sprintf!("'%8.2i'", 10.3456) ==	"'      10'"
    assert Cldr.Print.sprintf!("'%8.4i'", 10.3456) ==	"'      10'"
    assert Cldr.Print.sprintf!("'%08.2i'", 10.3456) ==	"'00000010'"
    assert Cldr.Print.sprintf!("'%-8.2i'", 10.3456) ==	"'10      '"
    assert Cldr.Print.sprintf!("'%-8.2i'", 101234567.3456) ==	"'101234567'"
  end

  test "formatting floating point numbers with Decimals" do
    assert Cldr.Print.sprintf!("'%.1f'", Decimal.new("10.3456")) ==	"'10.3'"
    assert Cldr.Print.sprintf!("'%.2f'", Decimal.new("10.3456")) ==	"'10.35'"
    assert Cldr.Print.sprintf!("'%8.2f'", Decimal.new("10.3456")) ==	"'   10.35'"
    assert Cldr.Print.sprintf!("'%8.4f'", Decimal.new("10.3456")) ==	"' 10.3456'"
    assert Cldr.Print.sprintf!("'%08.2f'", Decimal.new("10.3456")) ==	"'00010.35'"
    assert Cldr.Print.sprintf!("'%-8.2f'", Decimal.new("10.3456")) ==	"'10.35   '"
    assert Cldr.Print.sprintf!("'%-8.2f'", Decimal.new("101234567.3456")) ==	"'101234567.35'"
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

  test "grouping" do
    assert Cldr.Print.sprintf!("'%'5.1f'", 34510.3456) == "'34,510.3'"
    assert Cldr.Print.sprintf!("'%'5.1f'", Decimal.new("34510.3456")) == "'34,510.3'"
  end

  test "localised symbols in the format" do
    assert Cldr.Print.sprintf!("'%'5.1f'", 34510.3456, locale: "de", backend: Cldr.Print.TestBackend)
      == "'34.510,3'"
  end

  test "that integers print with precision when format is 'f'" do
    assert Cldr.Print.sprintf!("%.2f", 34510) == "34510.00"
    assert Cldr.Print.sprintf!("%.2f", Decimal.new(34510)) == "34510.00"
  end

  test "that left jutify takes precedence over zero-fill" do
    assert Cldr.Print.sprintf!("%-07d", 34510) == "34510  "
    assert Cldr.Print.sprintf!("%-7d", 34510) == "34510  "
  end
end
