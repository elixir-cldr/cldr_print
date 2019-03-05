defmodule Cldr.Print.Transform do
  @moduledoc false

  alias Cldr.Number.Format.Meta

  def maybe_add_fraction_digits(meta, nil) do
    meta
  end

  def maybe_add_fraction_digits(meta, digits) do
    Meta.put_fraction_digits(meta, digits, digits)
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

  # Called for format "d"
  def maybe_add_plus(meta, nil) do
    meta
  end

  def maybe_add_plus(meta, true) do
    positive_format = [{:plus, nil} | meta.format[:positive]]
    negative_format = meta.format[:negative]
    Meta.put_format(meta, positive_format, negative_format)
  end

  # meta, format, left_justify?, zero_fill?, width
  def maybe_add_zero_fill(meta, _format, true, _, _) do
    meta
  end

  def maybe_add_zero_fill(meta, _format, _, nil, _) do
    meta
  end

  def maybe_add_zero_fill(meta, _format, _, _, nil) do
    meta
  end

  def maybe_add_zero_fill(meta, format, nil, true, width) when is_integer(width) do
    precision = format[:precision] || 0
    adjust_for_sign = if format[:with_plus] || less_than_zero(format[:value]) < 0, do: -1, else: 0
    adjust_for_float = if format[:format_type] == "f", do: -1, else: 0
    # IO.puts "Width: #{width}; Precision: #{precision}; Sign: #{adjust_for_sign}; Float: #{adjust_for_float}"
    padding = width - precision + adjust_for_sign + adjust_for_float
    Meta.put_integer_digits(meta, padding)
  end

  defp less_than_zero(number) when is_number(number) and number < 0 do
    -1
  end

  defp less_than_zero(number) when is_number(number) do
    0
  end

  @zero Decimal.new(0)
  defp less_than_zero(%Decimal{} = number) do
    if Decimal.cmp(number, @zero) == :lt do
      -1
    else
      0
    end
  end

  def maybe_add_group(meta, nil, _backend, _options) do
    meta
  end

  def maybe_add_group(meta, true, backend, options) do
    locale = Keyword.get(options, :locale, backend.get_locale())
    format_module = Module.concat(backend, Number.Format)
    %{integer: %{first: first, rest: rest}} = format_module.default_grouping_for!(locale)
    Meta.put_integer_grouping(meta, first, rest)
  end

  # In this case we're not adding the prefix but
  # we are localising the minus sign if it exists
  def maybe_add_zero_x(format, _string, nil, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn
      << "-", value :: binary >> ->
        localised_minus = localised_minus(format, options)
        {value, localised_minus <> value}
      value ->
        {value, value}
    end)
    format
  end

  def maybe_add_zero_x(format, string, true, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn
      << "0" >> = value ->
        {value, value}
      << "-", value :: binary >> ->
        localised_minus = localised_minus(format, options)
        {value, localised_minus <> string <> value}
      value ->
        {value, string <> value}
    end)
    format
  end

  # For o, x and X formats
  def maybe_add_plus(format, nil, _options) do
    format
  end

  def maybe_add_plus(format, true, options) do
    {_, format} = Keyword.get_and_update(format, :value, fn
      << "0" >> = value ->
        {value, value}
      << "-", _ :: binary >> = value ->
        {value, value}
      value ->
        localised_plus = localised_plus(format, options)
        {value, localised_plus <> value}
    end)
    format
  end

  defp localised_minus(format, options) do
    symbols_for(format, options).minus_sign
  end

  defp localised_plus(format, options) do
    symbols_for(format, options).plus_sign
  end

  @default_precision 6
  def maybe_add_precision(format, nil) do
    Keyword.put(format, :precision, @default_precision)
  end

  def maybe_add_precision(format, _) do
    format
  end

  def maybe_add_exponent(meta, nil, _) do
    meta
  end

  @exponent_digits 2
  def maybe_add_exponent(meta, true, precision) do
    meta
    |> Meta.put_exponent_digits(@exponent_digits)
    |> Meta.put_exponent_sign(true)
    |> Meta.put_scientific_rounding_digits(precision + 1)
  end

  def maybe_set_number_system(format, backend, options) do
    if !options[:number_sytem] && format[:native_number_system] do
      systems = systems_for(backend, options)
      Keyword.put(options, :number_system, systems[:native])
    else
      options
    end
  end

  defp symbols_for(format, options) do
    system_name = if format[:native_number_system], do: :native, else: :default
    backend = Keyword.get(options, :backend, Cldr.Print.Backend)
    symbol_module = Module.concat(backend, Number.Symbol)
    system_module = Module.concat(backend, Number.System)
    locale = Keyword.get(options, :locale, backend.get_locale())
    number_system = system_module.number_systems_for!(locale)[system_name]
    {:ok, symbols} = symbol_module.number_symbols_for(locale, number_system)
    symbols
  end

  defp systems_for(backend, options) do
    system_module = Module.concat(backend, Number.System)
    locale = Keyword.get(options, :locale, backend.get_locale())
    {:ok, systems} = system_module.number_systems_for(locale)
    systems
  end
end