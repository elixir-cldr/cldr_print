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

  def maybe_add_padding(string, padding, nil) do
    String.pad_leading(string, padding)
  end

  def maybe_add_padding(string, padding, true) do
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

  def maybe_add_zero_fill(meta, nil, _, _) do
    meta
  end

  def maybe_add_zero_fill(meta, _, nil, _) do
    meta
  end

  # Need to account for the + and - signs
  def maybe_add_zero_fill(meta, fill?, width, nil) do
    maybe_add_zero_fill(meta, fill?, width, -1)
  end

  def maybe_add_zero_fill(meta, true, width, precision) do
    Meta.put_integer_digits(meta, width - precision - 1)
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
    {_, format} = Keyword.get_and_update(format, :value, fn value ->
      {value, string <> value}
    end)

    format
  end

  @max_precision 15
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

end