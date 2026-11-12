# Operators

Gloo operators can be used to do basic math and to compare values.

**Contents**

- Math Operators
- Grouping
- Joining Values
- Comparison Operators
- Example

## Math Operators

These are the gloo math operators:

```
+   addition
-   subtraction
*   multiplication
/   division
```

How to write numbers (`5`, `-5`, `2.50`, `.5`, `1.0e3`) is in Language, Objects, Literals.

Integers and decimal numbers mix as numbers. An integer with an integer gives an integer; a decimal on either side gives a decimal, so `1 + 2.5` is `3.5` and `3 * 1.5` is `4.5`.

Dividing an integer by an integer gives an integer, rounded down: `7 / 2` is `3`, and `-7 / 2` is `-4`. For the fraction, make either side a decimal: `7.0 / 2` is `3.5`. Dividing by zero is an error.

Integers can be as large as needed: `123456789012345678901234567890 * 10` is exact. Decimals are binary floating point, so a result can be a tiny bit off (`0.1 + 0.2` shows `0.30000000000000004`); use `round` or `format` on a decimal to show it to a fixed number of places. Very large and very small decimals show in exponent form (`2.0e+20`, `1.0e-07`), a whole-number decimal keeps its `.0` (`1.5 * 2` is `3.0`), and a negative zero shows as `-0.0`.

`-`, `*` and `/` use text as a number: `10 - '4'` is `6` and `'7.0' / 2` is `3.5`. Text that isn't a number is used as 0, with a warning (`'a' is not a number; using 0.`); blank text is 0 without one. `+` is different: with text it joins (see Joining Values).

An expression is worked out strictly left to right. There's no precedence, so `2 + 3 * 4` is `20` (`2 + 3` first, then `* 4`), not `14`. To work out one part first, put it in parentheses (see Grouping).

## Grouping

A group in parentheses is worked out first, and its value is used in its place: `2 + ( 3 * 4 )` is `14`, and `( 1 + 2 ) * 3` is `9`. Groups nest to any depth, `2 * ( 3 * ( 1 + 1 ) )` is `12`, and the parentheses can touch what's inside them: `((1 + 2) * (3 + 4))` is `21`. Outside a group, everything is still worked out left to right.

```
> show 2 * ( 3 + 4 )
> put ( price + tax ) * qty into total
> if ( a = b ) then show 'same'
> tell d to round ( 1 + 1 )
```

A group works anywhere gloo expects a value: `eval`, `show`, `put`, the condition and commands of `if` and `unless`, and a message's parameters: a group is one parameter, so `tell s to sub ( ( 'a' + 'b' ) 'x' )` replaces `ab` with `x`. Where a verb expects an object path instead, parentheses build the path (see Language, Syntax, Computed Object Paths): `put 2 * ( 3 + 4 ) into ( 'list.' n )` uses both.

At the end of a line, a group that comes after a value is the verb's extra part, such as a message's parameters or `show`'s colour, as it always has been: `show 'done' (green)`. So `show a ( b + c )` shows `a` in the colour `b + c` works out to. To join a group onto a value, write the operator: `show a + ( b + c )`.

Parentheses inside quotes are text: `show 'a (b)'` shows `a (b)`. A parenthesis without its partner, or an empty `( )`, is a syntax error.

## Joining Values

`+` also joins strings: `"hello" + " world"` is `hello world`. When two values sit side by side with no operator between them, gloo joins them with `+` too.

`+` joins whenever there's text on either side, so a number and text join as text: if `count` is 3, `show count ' items'` shows `3 items`, and `5 + '5'` is `55`. To add text that holds a number, put it into an integer or decimal first.

`and` is another way to write `+`. It reads better when building a string out of several pieces:

```
> put first_name and ' ' and last_name into full_name
> put VPM_ROOT and 'Tasks/' and file_name into path
```

`and` always joins; it is not a logical (boolean) and. Because it's an operator, `and` is never looked up as an object, even if one by that name exists.

## Comparison Operators

Strings, integers, and decimal numbers can be compared. An integer and a decimal are compared as numbers, so `1 = 1.9` is false and `1 < 1.5` is true.

A number and text that holds a number are compared as numbers: `'5' < 10` and `3 = '3'` are both true. A number and other text are compared as text, so `3 = 'abc'` is false.

`<`, `>`, `<=` and `>=` put strings in dictionary order. Case is ignored first, and only when two strings have the same letters does a capital come first: `'apple' < 'Banana'` and `'Banana' < 'banana'` are both true. `=` and `!=` still tell capitals apart (`'x' = 'X'` is false), so for any two strings exactly one of `<`, `=` and `>` is true.

These are the gloo comparison operators:

```
=   equal (== also works, as an alternate spelling — not a separate identity check)
!=  not equal
>   greater than
<   less than
>=  greater than or equal to
<=  less than or equal to
```

## Example

Here are some examples of math operator usage:

```
> show 2 + 5
> put 12 / 3 into x
> show 23 * 3 - 6
```

And some examples of comparison operator usage:

```
> show 2 = 2
> show 2 != 2
> show 2 > 2
> show 2 < 2
> show 2 >= 2
> show 2 <= 2

> if a = b then show "the strings are equal"
> if x > y then run my_script
> put x != y into my_bool
```

See also: Put, Show.
