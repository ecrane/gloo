# Operators

Gloo operators can be used to do basic math and to compare values.

**Contents**

- Math Operators
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

Integers and decimal numbers mix as numbers. An integer with an integer gives an integer; a decimal on either side gives a decimal, so `1 + 2.5` is `3.5` and `3 * 1.5` is `4.5`.

`-`, `*` and `/` use text as a number: `10 - '4'` is `6` and `'7.0' / 2` is `3.5`. Text that isn't a number is used as 0, with a warning (`'a' is not a number; using 0.`); blank text is 0 without one. `+` is different: with text it joins (see Joining Values).

An expression is worked out strictly left to right. There's no precedence and no grouping with parentheses, so `2 + 3 * 4` is `20` (`2 + 3` first, then `* 4`), not `14`. To work out one part first, put it into an object on its own line, then use that object: `put 3 * 4 into x`, then `eval 2 + x`.

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
