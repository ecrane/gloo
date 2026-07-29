# Operators

Gloo operators can be used to do basic math and to compare values.

### Math Operators

These are the gloo math operators:

```
+   addition
-   subtraction
*   multiplication
/   division
```

### Comparison Operators

Strings, integers, and decimal numbers can be compared.

These are the gloo comparison operators:

```
=   equal (== is identical)
!=  not equal
>   greater than
<   less than
>=  greater than or equal to
<=  less than or equal to
```

### Example

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
