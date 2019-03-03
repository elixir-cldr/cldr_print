defmodule Cldr.Print do
  alias Cldr.Print.Parser
  alias Cldr.Number.Format.Meta

  import Cldr.Print.Transform

  @doc """
  Formats and prints its arguments under control of a format.

  The format is a character string which contains two types of objects:
  plain characters, which are simply copied to standard output and format
  specifications, each of which causes printing of the next successive argument.

  Each format specification is introduced by the percent character (`%`).
  The remainder of the format specification includes, in the following order:

  * Optional format flags
  * Optional field width
  * Optional precision
  * Required format type

  The can be represented as:
  ```
  %[flags][width][.precision]format_type
  ```

  ## Format flags

  Zero or more of the following flags:

  | Flag  | Description                                                                    |
  | ----- | -------------------------------------------------------------------------------|
  | #     | A `#` character specifying that the value should be printed in an alternate form. For `b`, `c`, `d`, `s` and `u` formats, this option has no effect. For the `o` formats the precision of the number is increased to force the first character of the output string to a zero. For the `x` (`X`) format, a non-zero result has the string `0x` (`0X`) prepended to it. For `a`, `A`, `e`, `E`, `f`, `F`, `g` and `G` formats, the result will always contain a decimal point, even if no digits follow the point (normally, a decimal point only appears in the results of those formats if a digit follows the decimal point). For `g` and `G` formats, trailing zeros are not removed from the result as they would otherwise be. |
  | -     | A minus sign `-' which specifies left adjustment of the output in the indicated field. |
  | +     | A `+` character specifying that there should always be a sign placed before the number when using signed formats. |
  | space | A space character specifying that a blank should be left before a positive number for a signed format. A `+` overrides a space if both are used. |
  | 0     | A zero `0` character indicating that zero-padding should be used rather than blank-padding.  A `-` overrides a `0` if both are used. |
  | '     | Formats a number with digit grouping applied. The group size and grouping character are determined based upon the current processes locale or as defined by the `:locale` option to `printf/3`. |

  ## Field Width

  An optional digit string specifying a field width; if the output string has fewer bytes than the field
  width it will be blank-padded on the left (or right, if the left-adjustment indicator has been given)
  to make up the field width (note that a leading zero is a flag, but an embedded zero is part of a
  field width).

  ## Precision

  An optional period, `.`, followed by an optional digit string giving a precision which specifies the
  number of digits to appear after the decimal point, for `e` and `f` formats, or the maximum number of
  graphemes to be printed from a string. If the digit string is missing, the precision is treated as zero.

  ## Format Type

  A character which indicates the type of format to use (one of `diouxXfFeEgGaAs`).  The uppercase
  formats differ from their lowercase counterparts only in that the output of the former is entirely in
  uppercase.

  | Format | Description                                                                    |
  | ------ | -------------------------------------------------------------------------------|
  | diouXx | The argument is printed as a signed decimal (d or i), unsigned octal, unsigned decimal, or unsigned hexadecimal (X or x), respectively. |
  | fF     | The argument is printed in the style `[-]ddd.ddd` where the number of d's after the decimal point is equal to the precision specification for the argument.  If the precision is missing, 6 digits are given; if the precision is explicitly 0, no digits and no decimal point are printed.  The values infinity and NaN are printed as `inf' and `nan', respectively. |
  | eE     | The argument is printed in the style e `[-d.ddd+-dd]` where there is one digit before the decimal point and the number after is equal to the precision specification for the argument; when the precision is missing, 6 digits are produced.  The values infinity and NaN are printed as `inf` and `nan`, respectively. |
  | gG     | The argument is printed in style f or e (or in style E for a G format code), with the precision specifying the number of significant digits. The style used depends on the value converted: style e will be used only if the exponent resulting from the conversion is less than -4 or greater than the precision. Trailing zeroes are removed from the result; a decimal point appears only if it is followed by a digit. |
  | aA     | The argument is printed in style `[-h.hhh+-pd]` where there is one digit before the hexadecimal point and the number after is equal to the precision specification for the argument; when the precision is missing, enough digits are produced to convey the argument's exact double-precision floating-point representation.  The values infinity and NaN are printed as `inf` and `nan`, respectively. |
  | s      | Graphemes from the string argument are printed until the end is reached or until the number of graphemes indicated by the precision specification is reached; however if the precision is 0 or missing, the string is printed entirely. |
  | %      | Print a `%`; no argument is used. |

  ## Notes

  * The grouping separator, decimal point and exponent characters are defined in the current
    processes locale or as specified in the `:locale` option to `printf/3`.

  * In no case does a non-existent or small field width cause truncation of a field; padding
    takes place only if the specified field width exceeds the actual width.

  """
  def printf(format, args, options \\ [])

  def printf(format, args, options) when is_list(args) do
    with {:ok, tokens} <- Parser.parse(format) do
      tokens
      |> splice_arguments(args, options, &format/2)
      |> Enum.reverse
      |> IO.iodata_to_binary
    end
  end

  def printf(format, arg, options) do
    printf(format, [arg], options)
  end

  def splice_arguments(tokens, args, options, fun \\ &(&1)) do
    {_, acc} =
      Enum.reduce(tokens, {args, []}, fn
        token, {args, acc} when is_binary(token) ->
          {args, [token | acc]}

        token, {[], _acc} when is_list(token) ->
          raise ArgumentError, "The number of arguments must be at least equal to " <>
          "to the number of format placeholders."

        token, {args, acc} when is_list(token) ->
          [arg | remaining_args] = args
          token = fun.(Keyword.put(token, :value, arg), options)
          {remaining_args, [token | acc]}
      end)
    acc
  rescue
    e in ArgumentError -> {:error, {ArgumentError, e.message}}
  end

  def format(token, options) do
    format(token[:format_type], token, options)
  end

  def format("d" = type, format, options) do
    backend = Keyword.get(options, :backend, Cldr.Print.Backend)
    formatter = Module.concat(backend, Number.Formatter.Decimal)
    meta = meta_from_format(type, format)

    formatter.to_string(format[:value], meta, options)
    |> maybe_add_padding(format[:width], format[:left_justify])
  end

  def format("f", format, options) do
    format = maybe_add_precision(format, format[:precision])
    format("d", format, options)
  end

  def format("u", format, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn value ->
      {value, abs(value)}
    end)
    format("d", format, options)
  end

  def format("e", format, options) do
    format = Keyword.put(format, :exponent, true)

    format("d", format, options)
    |> String.downcase
  end

  def format("E", format, options) do
    format = Keyword.put(format, :exponent, true)

    format("d", format, options)
    |> String.upcase
  end

  def format("g", format, options) do
    format_f = format("f", format, options)
    format_e = format("e", format, options)

    if String.length(format_f) <= String.length(format_e) do
      format_f
    else
      format_e
    end
  end

  def format("G", format, options) do
    format_f = format("F", format, options)
    format_e = format("E", format, options)

    if String.length(format_f) <= String.length(format_e) do
      format_f
    else
      format_e
    end
  end

  def format("s", format, _options) do
    padding = format[:width] || 0
    precision = format[:precision]
    left_or_right = format[:left_justify]
    value = format[:value]

    value
    |> slice(precision)
    |> justify(padding, left_or_right)
  end

  def format("o", format, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn value ->
      {value, Integer.to_string(trunc(value), 8) |> String.downcase}
    end)

    format = maybe_add_zero_x(format, "0", format[:leading_zero_x])
    format("s", format, options)
  end

  def format("x", format, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn value ->
      {value, Integer.to_string(trunc(value), 16) |> String.downcase}
    end)

    format = maybe_add_zero_x(format, "0x", format[:leading_zero_x])
    format("s", format, options)
  end

  def format("X", format, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn value ->
      {value, Integer.to_string(trunc(value), 16)}
    end)

    format = maybe_add_zero_x(format, "0X", format[:leading_zero_x])
    format("s", format, options)
  end

  def meta_from_format("d", format) do
    Meta.new
    |> maybe_add_plus(format[:with_plus])
    |> maybe_add_fraction_digits(format[:precision])
    |> maybe_add_zero_fill(format[:zero_fill], format[:width], format[:precision])
    |> maybe_add_group(format[:group])
    |> maybe_add_exponent(format[:exponent])
  end

  defp slice(string, nil) do
    string
  end

  defp slice(string, precision) do
    String.slice(string, 0, precision)
  end

  defp justify(string, padding, true) do
    String.pad_trailing(string, padding)
  end

  defp justify(string, padding, nil) do
    String.pad_leading(string, padding)
  end

end
