defmodule Cldr.Print.Parser.Core do
  @moduledoc false

  import NimbleParsec

  def percent do
    ascii_string([?%], 2) |> replace("%")
  end

  def start_format do
    ascii_string([?%], 1)
  end

  def with_plus do
    ascii_string([?+], 1)
  end

  def left_justify do
    ascii_string([?-], 1)
  end

  def zero_fill do
    ascii_string([?0], 1)
  end

  def group do
    utf8_string([?,], min: 1)
  end

  def digit do
    ascii_string([?0..?9], 1)
  end

  def digits do
    ascii_string([?0..?9], min: 1)
  end

  def point do
    ascii_string([?.], 1)
  end

  def leading_zero_x do
    ascii_string([?#], 1)
  end

  def format_type do
    ascii_string([?d, ?o, ?f, ?x, ?X, ?s, ?e, ?E, ?g, ?G, ?u], 1)
  end

  def literal do
    utf8_string([{:not, ?%}], min: 1)
  end

  def flags do
    repeat(
      choice([
        left_justify() |> replace(true) |> unwrap_and_tag(:left_justify),
        with_plus() |> replace(true) |> unwrap_and_tag(:with_plus),
        zero_fill() |> replace(true) |> unwrap_and_tag(:zero_fill),
        group()|> replace(true) |> unwrap_and_tag(:group),
        leading_zero_x()|> replace(true) |> unwrap_and_tag(:leading_zero_x)
      ])
    )
  end

  def width_and_precision do
    choice([
      integer(min: 1) |> unwrap_and_tag(:width)
      |> optional(ignore(point()) |> concat(integer(min: 1) |> unwrap_and_tag(:precision))),

      optional(integer(min: 1) |> unwrap_and_tag(:width))
      |> ignore(point()) |> concat(integer(min: 1) |> unwrap_and_tag(:precision))
    ]) |> label("a format of the form 'digits', 'digits.digits' or '.digits'")
  end

  # %[flags][width][.precision][length]specifier
  def format do
    ignore(start_format())
    |> optional(flags())
    |> optional(width_and_precision())
    |> concat(format_type() |> unwrap_and_tag(:format_type))
    |> wrap
  end
end
