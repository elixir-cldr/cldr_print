defmodule Cldr.Print.Parser do
  @moduledoc false

  import NimbleParsec
  import Cldr.Print.Parser.Core

  def parse(format) do
    format
    |> parse_format_string
    |> unwrap
  end

  defparsecp :parse_format_string,
    repeat(
      choice([
        literal(),
        percent(),
        format()
      ])
    )

  defp unwrap({:ok, acc, "", _, _, _}) when is_list(acc) do
    {:ok, acc}
  end

  defp unwrap({:error, <<first::binary-size(1), reason::binary>>, rest, _, _, offset}) do
    {:error,
      {LanguageTag.ParseError,
        "#{String.capitalize(first)}#{reason}. Could not parse the remaining #{inspect(rest)} " <>
        "starting at position #{offset + 1}"}}
  end
end