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

An expression is worked out strictly left to right. There's no precedence and no grouping with parentheses, so `2 + 3 * 4` is `20` (`2 + 3` first, then `* 4`), not `14`. To work out one part first, put it into an object on its own line, then use that object: `put 3 * 4 into x`, then `eval 2 + x`.

## Joining Values

`+` also joins strings: `"hello" + " world"` is `hello world`. When two values sit side by side with no operator between them, gloo joins them with `+` too.

`and` is another way to write `+`. It reads better when building a string out of several pieces:

```
> put first_name and ' ' and last_name into full_name
> put VPM_ROOT and 'Tasks/' and file_name into path
```

`and` always joins; it is not a logical (boolean) and. Because it's an operator, `and` is never looked up as an object, even if one by that name exists.

## Comparison Operators

Strings, integers, and decimal numbers can be compared.

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
