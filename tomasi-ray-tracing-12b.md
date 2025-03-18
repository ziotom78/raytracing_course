# Implementing a *lexer*

# Example

```python
# Declare a floating-point variable named "clock"
float clock(150)

# Declare a few new materials. Each of them includes a BRDF and a pigment

# We can split a definition over multiple lines and indent them as we like
material sky_material(
    diffuse(image("sky-dome.pfm")),
    uniform(<0.7, 0.5, 1>)
)

material ground_material(
    diffuse(checkered(<0.3, 0.5, 0.1>,
                      <0.1, 0.2, 0.5>, 4)),
    uniform(<0, 0, 0>)
)

material sphere_material(
    specular(uniform(<0.5, 0.5, 0.5>)),
    uniform(<0, 0, 0>)
)

# Define a few shapes
sphere(sphere_material, translation([0, 0, 1]))

# The language is flexible enough to permit spaces before "("
plane (ground_material, identity)

# Here we use the "clock" variable! Note that vectors are notated using
# square brackets ([]) instead of angular brackets (<>) like colors, and
# that we can compose transformations through the "*" operator
plane(sky_material, translation([0, 0, 100]) * rotation_y(clock))

# Define a camera
camera(perspective, rotation_z(30) * translation([-4, 0, 1]), 1.0, 1.0)
```

This is the kind of file for which our *lexer* will have to produce a list of *tokens*.


# Error Handling

# Error Conditions

-   Even while writing the *lexer*, before dealing with the syntactic and semantic aspects, it is possible to encounter errors in the code.

-   For example, the presence of a character like `@` is not allowed in our language, and the *lexer* can already detect this type of error.

-   Another example is forgetting to close a double quote `"` at the end of a string.


# How to Report Errors

-   In modern compilers, the `Token` type contains information about the position of the token in the source file (see for example the [`Token`](https://github.com/llvm/llvm-project/blob/llvmorg-10.0.0/clang/include/clang/Lex/Token.h) type in version 10.0.0 of the Clang compiler: it's not a very elegant implementation, but it is optimized for efficiency!).

-   This information is used by the *lexer* and the *parser* to print error messages like the following (produced by Clang 10):

    ```text
    test.cpp:31:15: error: no viable conversion from 'int' to 'std::string'
          (aka 'basic_string<char>')
      std::string message = 127;
                  ^         ~~~
    ```

    where the file name (`test.cpp`), the line number (`31`), and the column number (`15`) where the error was found are indicated.

# Tracking Positions

-   The position of a token in a file is identified by three pieces of information:

    #.  The name of the source file (a string);
    #.  The line number (an integer, starting from 1);
    #.  The column number (same).

-   The `Token` type should therefore contain these three fields. In PyTracer I created a [`SourceLocation`](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/scene_file.py#L20-L32) type. (But it would be more efficient to keep a list of file names, and use an index to the file here!)

    ```python
    @dataclass
    class SourceLocation:
        file_name: str = ""
        line_num: int = 0
        col_num: int = 0
    ```

# Positions and Tokens

-   If you use a class hierarchy, put a field of type `SourceLocation` in the base class `Token`:

    ```python
    @dataclass
    class Token:
        """A lexical token, used when parsing a scene file"""
        location: SourceLocation
    ```

-   If you use *sum types*, remember to use *tags* if your language requires it (e.g., [Nim](https://nim-lang.org/docs/manual.html#types-object-variants)).

# Reporting Errors

-   The most practical way to report errors is to raise an exception: pytracer defines [`GrammarError`](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/scene_file.py#L149-L161).

-   The error message and a `SourceLocation` are associated with the exception: this way you can tell the user the location where the error was found.

-   Using exceptions implies that as soon as an error is found, compilation stops. This is not very *user-friendly*: if compilation is a slow process (e.g., C++, Rust), it would be better to produce a *list* of errors.

-   We will not do this: our compiler will be very fast, and it is not easy to implement a method to produce a list of errors, because of the way parsing is performed (see the next lesson).


# Definition of `InputStream`

# Use of *streams* in *lexing*

-   We saw in the theory lesson that it is necessary to read one character at a time from the source file.

-   It is therefore ideal to use a *stream* to read from a file, taking care to open the file in text mode (it is not a binary file like the PFM format!):

    ```python
    with open(file_name, "rt") as f:  # "rt" stands for "*R*ead *T*ext"
        …
    ```

-   We also need the possibility of *look ahead*, that is, to read a character and put it back, as well as the ability to keep track of the position in the *stream* where we have arrived (to produce error messages).

# Definition of `InputStream`

-   The `InputStream` type must contain these fields:

    #.  A `stream` field, whose type depends on the language you use: for example `std::istream` in C++;
    #.  A `location` field of type `SourceLocation`.

-   In addition to these fields, others are needed to implement *look-ahead*.


# Character *look ahead*

-   Recall that `InputStream` must offer the possibility of «putting back» a character through the `unread_char` function.

-   When putting back a character, you must also put back the position in the file, i.e., the `location` field.

-   This means that `InputStream` must also contain the following members:

    #.  `saved_char` (which will contain the «un-read» character, or zero if `unread_char` has not been called);
    #.  `saved_location`, which contains the value of `SourceLocation` associated with `saved_char`.

# Constructor of `InputStream`

```python
class InputStream:
    def __init__(self, stream, file_name="", tabulations=8):
        self.stream = stream

        # Note that we start counting lines/columns from 1, not from 0
        self.location = SourceLocation(file_name=file_name, line_num=1, col_num=1)

        self.saved_char = ""
        self.saved_location = self.location
        self.tabulations = tabulations
```

# Position Tracking

-   It is very important to correctly track the position in the file, i.e., to update the `location` field appropriately.

-   These are the rules to follow:

    #.  In the presence of a newline character like `\n`, increment `line_num` and reset `col_num` to 1;
    #.  In the presence of `\t` (tab), increment `col_num` by a conventional value (usually 4 or 8);
    #.  In all other cases, increment `col_num` and leave `line_num` untouched.

-   This approach would require additional measures for [Unicode characters](./tomasi-ray-tracing-03a.html#lo-standard-unicode), but our format only allows ASCII characters (fortunately!).

---

```python
class InputStream:
    …

    def _update_pos(self, ch):
        """Update `location` after having read `ch` from the stream"""
        if ch == "":
            # Nothing to do!
            return
        elif ch == "\n":
            self.location.line_num += 1
            self.location.col_num = 1
        elif ch == "\t":
            self.location.col_num += self.tabulations
        else:
            self.location.col_num += 1

    def read_char(self) -> str:
        """Read a new character from the stream"""
        if self.saved_char != "":
            # Recover the «unread» character and return it
            ch = self.saved_char
            self.saved_char = ""
        else:
            # Read a new character from the stream
            ch = self.stream.read(1)

        self.saved_location = copy(self.location)
        self._update_pos(ch)

        return ch

    def unread_char(self, ch):
        """Push a character back to the stream"""
        assert self.saved_char == ""
        self.saved_char = ch
        self.location = copy(self.saved_location)
```

# The `Token` Type

# The `Token` Type
-   Decide whether to use a class hierarchy or a *tagged union* (*sum type*); in Python I used hierarchies because *sum types* don't exist ([link to the code](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/scene_file.py#L35-L146)).

-   The token types to define are the following:

    #.  *Keyword*: use an enumerated type (`enum` in [Nim](https://nim-lang.org/docs/manual.html#types-enumeration-types), [D](https://dlang.org/spec/enum.html), [C\#](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/enum), [Rust](https://doc.rust-lang.org/book/ch06-01-defining-an-enum.html), [Java](https://www.w3schools.com/java/java_enums.asp), `enum class` in [Kotlin](https://kotlinlang.org/docs/enum-classes.html)), because it will make the *parser* more efficient;
    #.  *Identifier*: it's a string;
    #.  *Literal string*: it's again a string;
    #.  *Literal number*: a floating-point value;
    #.  *Symbol*: a character;
    #.  *Stop token* (see next slide).

# End of File

-   The *lexer* needs to be able to signal when a file has ended.

-   In the pytracer code I implemented a new «special» *token*: [`StopToken`](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/scene_file.py#L41-L45). It is emitted when the end of the file is reached.

-   The `StopToken` trick is not essential: you could simply check when the stream has reached the end…

-   …but it shows how flexible the concept of *token* can be. Tricks like this are very common in compilers (see for example how Python handles indentation changes [at the *lexer* level](https://riptutorial.com/python/example/8674/how-indentation-is-parsed)).

# Whitespace and Newlines

-   Our format ignores spaces, newlines between *tokens* and comments.

-   To implement the `read_token` function we need a function that skips these characters:

    ```python
    WHITESPACE = " \t\n\r"

    def skip_whitespaces_and_comments(self):
        """Keep reading characters until a non-whitespace/non-comment character is found"""
        ch = self.read_char()
        while ch in WHITESPACE or ch == "#":
            if ch == "#":
                # It's a comment! Keep reading until the end of the line
                # (include the case "", the end-of-file)
                while self.read_char() not in ["\r", "\n", ""]:
                    pass

            ch = self.read_char()
            if ch == "":
                return

        # Put the non-whitespace character back
        self.unread_char(ch)
    ```

# Reading a *token*

-   Divide the `read_token` method into simple functions [as I did in pytracer](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/scene_file.py#L231-L284), so that it is clearer to read.

-   After skipping any whitespace and comments, `read_token` must read the first character `c` and decide which token should be created:

    #.  If it is a symbol (comma, parenthesis, etc.), it returns a `SymbolToken`;
    #.  If it is a digit, it returns a `LiteralNumberToken`;
    #.  If it is `"`, it returns a `LiteralStringToken`;
    #.  If it is a sequence of characters `a`…`z`, it returns a `KeywordToken` if the sequence is a keyword, `IdentifierToken` otherwise;
    #.  If the file is finished, it returns `StopToken`.

---

```python
SYMBOLS = "()<>[],*"

def read_token(self) -> Token:
    self.skip_whitespaces_and_comments()

    # At this point we're sure that ch does *not* contain a whitespace character
    ch = self.read_char()
    if ch == "":
        # No more characters in the file, so return a StopToken
        return StopToken(location=self.location)

    # At this point we must check what kind of token begins with the "ch" character
    # (which has been put back in the stream with self.unread_char). First,
    # we save the position in the stream
    token_location = copy(self.location)

    if ch in SYMBOLS:
        # One-character symbol, like '(' or ','
        return SymbolToken(token_location, ch)
    elif ch == '"':
        # A literal string (used for file names)
        return self._parse_string_token(token_location=token_location)
    elif ch.isdecimal() or ch in ["+", "-", "."]:
        # A floating-point number
        return self._parse_float_token(first_char=ch, token_location=token_location)
    elif ch.isalpha() or ch == "_":
        # Since it begins with an alphabetic character, it must either be a keyword
        # or a identifier
        return self._parse_keyword_or_identifier_token(
            first_char=ch,
            token_location=token_location,
        )
    else:
        # We got some weird character, like '@` or `&`
        raise GrammarError(self.location, f"Invalid character {ch}")
```
# Test

- Implement two families of tests:
    1. A [test for `InputStream`](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/test_all.py#L1037-L1081), which verifies that the position in a file is tracked correctly even if there are newlines or `unread_char` is called;
    2. A [test for `read_token`](https://github.com/ziotom78/pytracer/blob/c1f0ed490f322bb9db9db185127aac69ac790fba/test_all.py#L1083-L1104), which verifies that spaces and comments are skipped and that the token sequence is produced correctly.

- Writing these tests will allow you to familiarize yourself with the types you have defined (especially if you use *sum types*!), in preparation for the next lesson.


# What to do today

1. Create a new *branch* called `scenefiles`;
2. Implement `SourceLocation`;
3. Implement `GrammarError`;
4. Implement `InputStream` and the associated functions/methods (especially `unread_char`!);
5. Implement the `Token` type, making sure that all *token* types present in pytracer are included (there are six in total);
6. Implement the function/method `read_token`.

---
title: "Laboratory 12"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...
