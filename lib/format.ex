defmodule Cldr.Print.Format do
  @moduledoc false

  import Cldr.Print.Transform
  alias Cldr.Number.Format.Meta

  def format("d" = type, format, options) do
    backend = Keyword.get(options, :backend, Cldr.Print.Backend)
    formatter = Module.concat(backend, Number.Formatter.Decimal)
    meta = meta_from_format(type, format, backend, options)
    value = format[:value]
    options = maybe_set_number_system(format, backend, options)

    case formatter.to_string(value, meta, options) do
      {:error, {exception, reason}} -> raise exception, reason
      string -> maybe_add_padding(string, format[:width], format[:left_justify])
    end
  end

  def format("i", format, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn value ->
      {value, truncate(value)}
    end)
    format = Keyword.put(format, :precision, 0)
    format("d", format, options)
  end

  def format("f", format, options) do
    format = maybe_add_precision(format, format[:precision])
    format("d", format, options)
  end

  def format("u", format, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn value ->
      {value, absolute(value)}
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
    format_e = format("e", format, options)
    if choose_f_or_e(format_e, format, "e") == :e do
      maybe_remove_zero_fraction(format_e)
    else
      format("f", format, options)
    end
  end

  def format("G", format, options) do
    format_e = format("E", format, options)
    if choose_f_or_e(format_e, format, "E") == :e do
      maybe_remove_zero_fraction(format_e)
    else
      format("F", format, options)
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
      {value, Integer.to_string(truncate(value), 8) |> String.downcase}
    end)

    format =
      format
      |> maybe_add_zero_x("0", format[:leading_zero_x], options)
      |> maybe_add_plus(format[:with_plus], options)

    format("s", format, options)
  end

  def format("x", format, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn value ->
      {value, Integer.to_string(truncate(value), 16) |> String.downcase}
    end)

    format =
      format
      |> maybe_add_zero_x("0x", format[:leading_zero_x], options)
      |> maybe_add_plus(format[:with_plus], options)

    format("s", format, options)
  end

  def format("X", format, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn value ->
      {value, Integer.to_string(truncate(value), 16)}
    end)

    format =
      format
      |> maybe_add_zero_x("0X", format[:leading_zero_x], options)
      |> maybe_add_plus(format[:with_plus], options)

    format("s", format, options)
  end

  def meta_from_format("d", format, backend, options) do
    Meta.new
    |> maybe_add_plus(format[:with_plus])
    |> maybe_add_fraction_digits(format[:precision])
    |> maybe_add_zero_fill(format, format[:left_justify], format[:zero_fill], format[:width])
    |> maybe_add_group(format[:group], backend, options)
    |> maybe_add_exponent(format[:exponent], format[:precision])
  end

  defp truncate(number) when is_integer(number) do
    number
  end

  defp truncate(number) when is_float(number) do
    trunc(number)
  end

  defp truncate(%Decimal{} = number) do
    Decimal.round(number, 0)
  end

  def absolute(number) when is_number(number) do
    abs(number)
  end

  def absolute(%Decimal{} = number) do
    Decimal.abs(number)
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

  defp choose_f_or_e(string, format, type) do
    [_, exponent] = String.split(string, type)
    exponent = String.to_integer(exponent)
    if (exponent < -4) || (exponent > format[:precision]), do: :e, else: :f
  end
end