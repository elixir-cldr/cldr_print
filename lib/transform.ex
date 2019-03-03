defmodule Cldr.Print.Transform do
  @moduledoc false

  alias Cldr.Number.Format.Meta

  # TODO needs to be localised
  @default_grouping 3

  def maybe_add_fraction_digits(meta, nil) do
    meta
  end

  def maybe_add_fraction_digits(meta, digits) do
    Meta.put_fraction_digits(meta, 0, digits)
  end

  def maybe_add_padding(string, nil, _) do
    string
  end

  def maybe_add_padding(string, padding, nil) when is_integer(padding) do
    String.pad_leading(string, padding)
  end

  def maybe_add_padding(string, padding, true) when is_integer(padding) do
    String.pad_trailing(string, padding)
  end

  def maybe_add_plus(meta, nil) do
    meta
  end

  def maybe_add_plus(meta, true) do
    positive_format = [{:plus, nil} | meta.format[:positive]]
    negative_format = meta.format[:negative]
    Meta.put_format(meta, positive_format, negative_format)
  end

  def maybe_add_zero_fill(meta, _, _, nil) do
    meta
  end

  def maybe_add_zero_fill(meta, _, nil, _) do
    meta
  end

  def maybe_add_zero_fill(meta, format, true, width) when is_integer(width) do
    precision = format[:precision] || 0
    precision = if is_float(format[:value]), do: precision, else: 0
    adjust_for_sign = if format[:with_plus] || format[:value] < 0, do: -1, else: 0
    adjust_for_float = if format[:format_type] == "f" and is_float(format[:value]), do: -1, else: 0
    # IO.puts "Width: #{width}; Precision: #{precision}; Sign: #{adjust_for_sign}; Float: #{adjust_for_float}"
    padding = width - precision + adjust_for_sign + adjust_for_float
    Meta.put_integer_digits(meta, padding)
  end

  def maybe_add_group(meta, nil) do
    meta
  end

  def maybe_add_group(meta, true) do
    Meta.put_integer_grouping(meta, @default_grouping)
  end

  def maybe_add_zero_x(format, _string, nil) do
    format
  end

  def maybe_add_zero_x(format, string, true) do
    {_, format} = Keyword.get_and_update(format, :value, fn
      value when is_number(value) and value > 0 ->
        {value, string <> value}
      value ->
        {value, value}
    end)

    format
  end

  @max_precision 6
  def maybe_add_precision(format, nil) do
    Keyword.put(format, :precision, @max_precision)
  end

  def maybe_add_precision(format, _) do
    format
  end

  def maybe_add_exponent(meta, nil) do
    meta
  end

  def maybe_add_exponent(meta, true) do
    meta
    |> Meta.put_exponent_digits(1)
    |> Meta.put_exponent_sign(true)
  end

  def maybe_set_number_system(format, backend, options) do
    if !options[:number_sytem] && format[:native_number_system] do
      system_module = Module.concat(backend, Number.System)
      locale = Keyword.get(options, :locale, backend.get_locale())
      {:ok, systems} = system_module.number_systems_for(locale)
      Keyword.put(options, :number_system, systems[:native])
    else
      options
    end
  end

end