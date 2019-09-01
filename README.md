# Cldr Print

Provides [printf and sprintf](http://man7.org/linux/man-pages/man3/printf.3.html) functions for Elixir that are largely compatible with the `C` versions.

## Getting Started

`Cldr.Print.printf/3`, `Cldr.Print.sprintf/3` and `Cldr.Print.lprintf/3` operate on a format string and a list of arguments to produce a formatted output.  The differences are:

* `Cldr.Print.printf/3` outputs to a device specified under the option key `:device` with `:stdout` as the default
* `Cldr.Print.sprintf/3` returns an `{:ok, string}` tuple or an `{:error, {exception, reason}}` tuple.
* `Cldr.Print.lprintf/3` returns an `{:ok, io_list}` tuple or an `{:error, {exception, reason}}` tuple.

There are also `!` bang versions of these functions which will return the result unwrapped or raise an exception if there is an error.

## Examples

Here are some examples to help get started if you are unfamiliar with the `C` versions of these functions.

### Controlling Integer Width

The `%3d` specifier is used with integers where the `3` represents the width in graphemes of the final formatted string. These example define a minimum width of three spaces which, by default, will be right-justified:

| Function call                     | Result            |
| --------------------------------- | ----------------: |
| printf!("%3d", 0)                 |	0                 |
| printf!("%3d", 123456789)         |	123456789         |
| printf!("%3d", -10)	              | -10               |
| printf!("%3d", -123456789)        | -123456789        |

### Left-justifying  with the `-` flag

To left-justify an integer add a minus sign `-` after the `%` symbol:

| Function call                     | Result            |
| --------------------------------- | :---------------- |
| printf!("%-3d", 0)                | 0                 |
| printf!("%-3d", 123456789)        | 123456789         |
| printf!("%-3d", -10)              | -10               |
| printf!("%-3d", -123456789)       | -123456789        |

### Zero-fill flag

To zero-fill the result add a zero `0` after the `%` symbol:

| Function call                     | Result            |
| --------------------------------- | ----------------: |
| printf("%03d", 0)                 | 000               |
| printf("%03d", 1)                 | 001               |
| printf("%03d", 123456789)         | 123456789         |
| printf("%03d", -10)               | -10               |
| printf("%03d", -123456789)        | -123456789        |

### Integer formatting summary

Here are some further examples including a minimum width specification, left-justified, zero-filled, as well as a plus sign for positive numbers.

| Description                             | Function call                | Result            |
| --------------------------------------- | ---------------------------- | ----------------: |
| At least five wide	                    | printf("'%5d'", 10)          | '   10'           |
| At least five-wide, left-justified      |	printf("'%-5d'", 10)         | '10   '           |
| At least five-wide, zero-filled	        | printf("'%05d'", 10)         | '00010'           |
| At least five-wide, with a plus sign	  | printf("'%+5d'", 10)         | '  +10'           |
| Five-wide, plus sign, left-justified	  | printf("'%-+5d'", 10)        | '+10  '           |

### Floating Point Formatting

Here are several examples showing how to format floating-point numbers:

| Description                                 | Function call                | Result            |
| ------------------------------------------- | ---------------------------- | ----------------: |
| Print one position after the decimal	      | printf("'%.1f'", 10.3456)    | '10.3'            |
| Two positions after the decimal	            | printf("'%.2f'", 10.3456)    | '10.35'           |
| Eight-wide, two positions after the decimal	| printf("'%8.2f'", 10.3456)   | '   10.35'        |
| Eight-wide, four positions after the decimal| printf("'%8.4f'", 10.3456)   | ' 10.3456'        |
| Eight-wide, two positions after the decimal, zero-filled | printf("'%08.2f'", 10.3456) | '00010.35' |
| Eight-wide, two positions after the decimal, left-justified	| printf("'%-8.2f'", 10.3456) | '10.35   ' |
| Printing a much larger number with that same format	| printf("'%-8.2f'",101234567.3456) | '101234567.35' |

### String Formatting

Here are some examples of string formatting:

| Description                                 | Function call                | Result            |
| ------------------------------------------- | ---------------------------- | ----------------: |
| A simple string	                            | printf("'%s'", "Hello")      | 'Hello'           |
| A string with a minimum length	            | printf("'%10s'", "Hello")    | '     Hello'      |
| Minimum length, left-justified	            | printf("'%-10s'", "Hello")   | 'Hello     '      |

## Format Specification

The format is a string which contains two types of objects:
plain characters, which are simply copied to standard output and format
specifications, each of which causes printing of the next successive argument.

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

### Format flags

Zero or more of the following flags:

| Flag  | Description                                                                    |
| ----- | -------------------------------------------------------------------------------|
| #     | A `#` character specifying that the value should be printed in an alternate form. For `b`, `c`, `d`, `s` and `u` formats, this option has no effect. For the `o` formats the precision of the number is increased to force the first character of the output string to a zero. For the `x` (`X`) format, a non-zero result has the string `0x` (`0X`) prepended to it. For `a`, `A`, `e`, `E`, `f`, `F`, `g` and `G` formats, the result will always contain a decimal point, even if no digits follow the point (normally, a decimal point only appears in the results of those formats if a digit follows the decimal point). For `g` and `G` formats, trailing zeros are not removed from the result as they would otherwise be. |
| -     | A minus sign `-' which specifies left adjustment of the output in the indicated field. |
| +     | A `+` character specifying that there should always be a sign placed before the number when using signed formats. |
| space | A space character specifying that a blank should be left before a positive number for a signed format. A `+` overrides a space if both are used. |
| 0     | A zero `0` character indicating that zero-padding should be used rather than blank-padding.  A `-` overrides a `0` if both are used. Is not applied for `o`, `x`, `X` formats. |
| '     | Formats a number with digit grouping applied. The group size and grouping character are determined based upon the current processes locale or the `:locale` option to `printf/3` if provided. Is not applied for formats `o`, `x`, `X` formats. |
| I     | Formats a number using the native number system digits of the current processes locale or the `:locale` option to `printf/3` if provided. The option `:number_system` if provided takes precedence over this flag. |

### Field Width

An optional digit string specifying a field width; if the output string has fewer bytes than the field
width it will be blank-padded on the left (or right, if the left-adjustment indicator has been given)
to make up the field width (note that a leading zero is a flag, but an embedded zero is part of a
field width).

### Precision

An optional period, `.`, followed by an optional digit string giving a precision which specifies the
number of digits to appear after the decimal point, for `e` and `f` formats, or the maximum number of
graphemes to be printed from a string. If the digit string is missing, the precision is treated as zero.

### Format Type

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

### Notes

* The grouping separator, decimal point and exponent characters are defined in the current process's locale or as specified in the `:locale` option to `printf/3`.

* In no case does a non-existent or small field width cause truncation of a field; padding takes place only if the specified field width exceeds the actual width.

## Todo

* [ ] Formats `a` and `A` aren't implemented

* [ ] The `#` is not validated for a, A, e, E, f, F, g and G formats. There seems to be some inconsistent implementations around that need further investigation

* [ ] The *space* flag is not implemented

## Installation

```elixir
def deps do
  [
    {:ex_cldr_print, "~> 0.2.0"}
  ]
end
```
The documentation can be found at [https://hexdocs.pm/ex_cldr_print](https://hexdocs.pm/ex_cldr_print).

