defmodule Cldr.Print.Splice do
  @moduledoc false

  alias Cldr.Print.Format

  def splice_arguments(tokens, args, options, fun) do
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

  def format(token, options) do
    Format.format(token[:format_type], token, options)
  end

  def format({token, options}) do
    format(token, options)
  end

  def format(string) when is_binary(string) do
    string
  end

  def identity(token, options) do
    {token, options}
  end

  def format_list(list) do
    Enum.map(list, &format/1)
  end

end