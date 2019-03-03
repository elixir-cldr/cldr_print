defmodule Cldr.Print do
  @moduledoc """
  Implements `printf/3`, `sprintf/3` and `lprintf/3` in a manner
  largely compatible with the standard `C` language implementations.
  """

  alias Cldr.Print.Parser
  alias Cldr.Print.Format

  @doc """
  Formats and prints its arguments under control of a format.

  The format is a character string which contains two types of objects:
  plain characters, which are simply copied to standard output and format
  specifications, each of which causes printing of the next successive argument.

  ## Arguments

  * `format` is a format string. Information on the definition of a
    format string is below.

  * `args` is a list of arguments that are formatted according to
    the directives in the format string. The number of `args` in the list
    must be at least equal to the number of format specifiers in the format
    string.

  * `options` is a keyword list defining how the number is to be formatted. The
    valid options are:

  ## Options

  * `backend` is any `Cldr` backend. That is, any module that
    contains `use Cldr`. The default is the included `Cldr.Print.Backend`
    which is configured with only the locale `en`.

  * `:rounding_mode`: determines how a number is rounded to meet the precision
    of the format requested. The available rounding modes are `:down`,
    :half_up, :half_even, :ceiling, :floor, :half_down, :up. The default is
    `:half_even`.

  * `:number_system`: determines which of the number systems for a locale
    should be used to define the separators and digits for the formatted
    number. If `number_system` is an `atom` then `number_system` is
    interpreted as a number system. See
    `Cldr.Number.System.number_systems_for/2`. If the `:number_system` is
    `binary` then it is interpreted as a number system name. See
    `Cldr.Number.System.number_system_names_for/2`. The default is `:default`.

  * `:locale`: determines the locale in which the number is formatted. See
    `Cldr.known_locale_names/0`. The default is`Cldr.get_locale/0` which is the
    locale currently in affect for this `Process` and which is set by
    `Cldr.put_locale/1`.

   * `:device` which is used to define the output device for `printf/3`.  The default is
     `:stdout`.

  ## Returns

  * `:ok` on success

  * `{:error, {exception, reason}}` if an error is detected

  ## Format definition

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
  | '     | Formats a number with digit grouping applied. The group size and grouping character are determined based upon the current processes locale or the `:locale` option to `printf/3` if provided. |
  | I     | Formats a number using the native number system digits of the current processes locale or the `:locale` option to `printf/3` if provided. The option `:number_system` if provided takes precedence over this flag. |

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

  * `printf/3` calls `IO.write/2` and therefore there are no control characters emitted
    unless provided in the format string. This is consisten with the `C` implementation
    but different from `IO.puts/2`.

  """
  def printf(format, args, options \\ []) do
    {device, options} = Keyword.pop(options, :device, :stdio)
    with {:ok, io_list} <- lprintf(format, args, options) do
      IO.write(device, io_list)
    end
  end

  @doc """
  Prints a `string` or raises after applying a format to
  a list of arguments.

  The arguments and options are the same as those for `printf/3`

  """
  def printf!(format, args, options \\ []) do
    case printf(format, args, options) do
      {:ok, string} -> string
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  @doc """
  Returns a `{:ok, string}` after applying a format to a list of arguments.

  The arguments and options are the same as those for `printf/3`

  """
  def sprintf(format, args, options \\ []) do
    with {:ok, io_list} <- lprintf(format, args, options) do
      {:ok, IO.iodata_to_binary(io_list)}
    end
  end

  @doc """
  Returns a `string` or raises after applying a format to
  a list of arguments.

  The arguments and options are the same as those for `printf/3`

  """
  def sprintf!(format, args, options \\ []) do
    case sprintf(format, args, options) do
      {:ok, string} -> string
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  @doc """
  Returns an `{:ok, io_list}` after applying a format to a list of arguments.

  The arguments and options are the same as those for `printf/3`

  """
  def lprintf(format, args, options \\ [])

  def lprintf(format, args, options) when is_list(args) do
    with {:ok, tokens} <- Parser.parse(format),
         {:ok, io_list} <- splice_arguments(tokens, args, options, &format/2) do
      {:ok, Enum.reverse(io_list)}
    end
  end

  def lprintf(format, arg, options) do
    lprintf(format, [arg], options)
  end

  @doc """
  Returns an `io_list` or raises after applying a format to
  a list of arguments.

  The arguments and options are the same as those for `printf/3`

  """
  def lprintf!(format, args, options \\ []) do
    case lprintf(format, args, options) do
      {:ok, string} -> string
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  #
  # Helpers
  #

  defp splice_arguments(tokens, args, options, fun) do
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
    {:ok, acc}
  rescue
    e in ArgumentError -> {:error, {ArgumentError, e.message}}
    e in Cldr.UnknownLocaleError -> {:error, {Cldr.UnknownLocaleError, e.message}}
  end

  defp format(token, options) do
    Format.format(token[:format_type], token, options)
  end
end
