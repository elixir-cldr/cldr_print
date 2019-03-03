defmodule Cldr.Print.Format do
  @moduledoc false

  import Cldr.Print.Transform
  alias Cldr.Number.Format.Meta

  def format("d" = type, format, options) do
    backend = Keyword.get(options, :backend, Cldr.Print.Backend)
    formatter = Module.concat(backend, Number.Formatter.Decimal)
    meta = meta_from_format(type, format)
    value = format[:value]
    options = maybe_set_number_system(format, backend, options)

    case formatter.to_string(value, meta, options) do
      {:error, {exception, reason}} -> raise exception, reason
      string -> maybe_add_padding(string, format[:width], format[:left_justify])
    end
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
    |> maybe_add_zero_fill(format, format[:zero_fill], format[:width])
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