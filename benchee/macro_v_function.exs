defmodule MacroBench do
  require Cldr.Print

  def macro_version do
    Cldr.Print.mlprintf("this is a decimal %05d with a float %8.2f", [10, 11.5])
  end

  def function_version do
    Cldr.Print.lprintf("this is a decimal %05d with a float %8.2f", [10, 11.5])
  end
end

Benchee.run(%{
  "macro"    => fn -> MacroBench.macro_version end,
  "function" => fn -> MacroBench.function_version end
})