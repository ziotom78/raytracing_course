# PFM Images

# PFM Images

-   The `HdrImage` class must be able to load and save images to disk.

-   Since `HdrImage` uses floating-point for the three color components (red, green, blue), an HDR format is required, so PNG, JPEG and the like are not suitable.

-   We will use the PFM format.


# The PFM Format

-   Writing PFM files is relatively trivial, because they have a very simple [format](http://www.pauldebevec.com/Research/HDR/PFM/)

-   A PFM file is a **binary** file, but it starts as if it were a text file (with ASCII characters, so we don't have to worry about Unicode):

    ```text
    PF
    width height
    ±1.0
    ```

    where `width` and `height` are the width (number of columns) and height (number of rows) of the image; then the RGB values follow in binary.

-   The newline characters in the first three lines must always and only be encoded as `0x0a` (`\n`). Thus, on Windows you must **not** write newlines using `0x0d 0x0a` (`\r\n`).


# The number `±1.0`

-   The third line of the file header must contain a positive (e.g., `1.0`) or negative number.

-   This number is used to signal how each of the RGB components of a color (32-bit floating-point) is encoded:

    1.  A positive value indicates that *big endian* encoding is used;
    2.  A negative value indicates that *little endian* encoding is used.

-   When writing, we could choose one of the two formats and not worry too much, but when reading, we must handle both!


# Floating-point in binary

-   You must be sure to floating-point numbers in binary! In C++,

    ```c++
    std::ofstream of{"file.pfm"};
    of << 1.3;
    ```

    prints the characters «`1`», «`.`» and «`3`» (text encoding!).

-   Each language has a different approach; in Python for example [`struct`](https://docs.python.org/3/library/struct.html) is used:

    ```python
    def _write_float(stream, value):
        # Meaning of "<f":
        # "<": little endian
        # "f": single-precision floating point value (32 bit)
        stream.write(struct.pack("<f", value))
    ```


# File Access in Python

<asciinema-player src="./cast/binary-text-files-75x25.cast" cols="75" rows="25" font-size="medium"></asciinema-player>


# `HdrImage` API {#hdrimage-api}

-   The way a data type or function should be used by the programmer is called *Application Program Interface* (API).

-   In our case, the API for writing a PFM file consists of how we would invoke a `write_pfm` function:

    ```python
    # Our API requires the name of the file
    img.write_pfm("output_file.pfm")
    ```

-   The API type should also be modeled based on the tests that need to be written on it.


# Tests and API

-   Let's consider the case of `write_pfm`. How should we write a test for this function?

    ```python
    img = HdrImage(7, 4)
    img.write_pfm("output_file.pfm")
    assert ...  # Now what?
    ```

-   If the function writes to a file, it means that we should then *load* the file and verify that it was written correctly.

-   Does this mean that until we have a parallel `read_pfm` routine we can't test `write_pfm`?


# File Management

-   You can think of a binary file as a vector (one-dimensional array) of bytes, one after the other. (A text file is the same, but in UTF encoding it is a sequence of *code points* rather than bytes, and it is a bit more complicated).

-   Modern languages introduce an abstraction: the *stream*. (Alas, D doesn't have it [in its standard libraries](https://github.com/dlang/phobos/pull/3631): if you program in D, use [stream.d](https://github.com/dlang/undeaD/blob/master/src/undead/stream.d))

-   This abstraction is very useful in tests.


# Files and Streams

-   Simply put, a *stream* is an object capable of performing these operations:

    1.  Return one byte at a time by reading it from a sequence;
    2.  Write one byte at a time, appending it to those already written.

-   These two operations are those typically performed on files, but a *stream* is also applicable to other contexts:

    1.  A network connection to a remote server works like a stream;
    2.  The RAM itself can be considered as a stream; consequently, a sequence of bytes in memory can be seen as a stream, if the language supports it.


# Example in Python

<asciinema-player src="./cast/files-streams-75x25.cast" cols="75" rows="25" font-size="medium"></asciinema-player>


# Streams, APIs and Testing

-   We could consider modifying our API so that it writes to a generic stream, like the `write_hello` example in the video:

    ```python
    stream = CreateSomeStream(...)
    img.write_pfm(stream)
    ```

-   When the program is running, we'll make `stream` a real file.

-   When we need to run a test, we can instead make `stream` an in-memory variable. The bytes will not be written to a file, but kept in a byte array, on which we will perform `assert`s.


# The `write_pfm` Method

```python
def write_pfm(self, stream, endianness=Endianness.LITTLE_ENDIAN):
    endianness_str = "-1.0" if endianness == Endianness.LITTLE_ENDIAN else "1.0"

    # The PFM header, as a Python string (UTF-8)
    header = f"PF\n{self.width} {self.height}\n{endianness_str}\n"

    # Convert the header into a sequence of bytes
    stream.write(header.encode("ascii"))

    # Write the image (bottom-to-up, left-to-right)
    for y in reversed(range(self.height)):
        for x in range(self.width):
            color = self.get_pixel(x, y)
            _write_float(stream, color.r, endianness)
            _write_float(stream, color.g, endianness)
            _write_float(stream, color.b, endianness)
```


# Test Images

-   I created two PFM files with these characteristics:

    -   One is encoded as *little endian* (`-1.0`), the other as *big endian* (`1.0`);
    -   Color matrix (RGB) of size 3×2 pixels:

        |    | #1              | #2              | #3              |
        |----|-----------------|-----------------|-----------------|
        | #A | (10, 20, 30)    | (40, 50, 60)    | (70, 80, 90)    |
        | #B | (100, 200, 300) | (400, 500, 600) | (700, 800, 900) |

-   It is useful to have the files on your disk. Download them with the names [`reference_le.pfm`](./media/reference_le.pfm) and [`reference_be.pfm`](./media/reference_be.pfm) and save them in your repository, possibly in the same directory as the tests.

# Writing the test (1/3)

The first approach is to read the `reference_le.pfm` file and compare it with the file that *would have been* written by `write_pfm`:

```python
img = HdrImage(3, 2)

img.set_pixel(0, 0, Color(1.0e1, 2.0e1, 3.0e1)) # Each component is
img.set_pixel(1, 0, Color(4.0e1, 5.0e1, 6.0e1)) # different from any
img.set_pixel(2, 0, Color(7.0e1, 8.0e1, 9.0e1)) # other: important in
img.set_pixel(0, 1, Color(1.0e2, 2.0e2, 3.0e2)) # tests!
img.set_pixel(1, 1, Color(4.0e2, 5.0e2, 6.0e2))
img.set_pixel(2, 1, Color(7.0e2, 8.0e2, 9.0e2))

buf = BytesIO()
img.write_pfm(buf, endianness=Endianness.LITTLE_ENDIAN)

with open("reference_le.pfm", "rb") as inpf:
    reference_bytes = inpf.readall()

assert buf.getvalue() == reference_bytes
```


# Test Writing (2/3)

Another approach is possible. If we run `xxd` on the file `reference_le.pfm`, we can get the sequence of byte values in C/C++ format:

```text
$ xxd -i reference_le.pfm
unsigned char reference_le_pfm[] = {
  0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
  0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
  0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
  0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
  0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
  0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
  0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
};
unsigned int reference_le_pfm_len = 84;
```


# Test Writing (3/3)

If we insert this byte sequence into our program, we can make a direct comparison in memory:

```python
# Create "img" as in the previous case, then…

# Little-endian format
reference_bytes = bytes([
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
    0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
    0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
    0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
    0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
    0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
    0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
])

# No file is being read/written here!
buf = BytesIO()
img.write_pfm(buf)
assert buf.getvalue() == reference_bytes
```


# Reading PFM Files

# File Reading

-   Let's now address the much more challenging problem of *reading* files.

-   Unlike writing, reading presents more difficulties:
    -   The file might be in an incorrect format (problems during copying, wrong extension, etc.);
    -   We must be able to read both *little endian* and *big endian*, while during writing we had freedom of choice.


# Constructor or Function?

-   Implementing PFM reading within a constructor is possible (C++):

    ```c++
    struct HdrImage {
        HdrImage image(std::istream & stream);
        // ...
    };

    std::ifstream myfile{"input.pfm"};
    HdrImage img{myfile};
    ```

-   It’s ok to define a `read_pfm_file` **function**:

    ```c++
    HdrImage read_pfm_file(std::istream & stream);

    std::ifstream myfile{"input.pfm"};
    HdrImage img{read_pfm_file(myfile)};
    ```


# Picking an API

-   The problem of picking which possibility is the best is related to the choice of an [API](./tomasi-ray-tracing-03b-image-files.html#/hdrimage-api).

-   The choice depends on personal taste and other factors:
    1.  In a OOP language, it’s more natural to provide a constructor;
    2.  In procedural languages like Nim or Rust, it’s ok to implement a function;
    3.  If your language limits the applicability of constructors (e.g., Python prevents overloading), just implement a function.


# Stream and files

-   In the previous slides, the C++ interface to read a file is through a *stream* (`std::istream`);
-   We saw that streams simplify the creation of tests, as they do not need to read data from disk;
-   Moreover, the code is more versatile: instead of reading data from disk, we could read it from an Internet connection or a compressed file:

    ```python
    import gzip

    with gzip.open("image_file.pfm.gz", "rb") as inpf:
        read_pfm_file(inpf)
    ```


# Reading Files Directly

-   Anyway, it would be really handy to open a file directly:

    ```python
    # How handy!
    image = read_pfm_file("image_file.pfm")
    ```

-   In C++, we could think of implementing an overloaded constructor:

    ```c++
    struct HdrImage {
        // Read a PFM file from a stream
        HdrImage(std::istream & stream);

        // Open a PFM file and read the stream of bytes from it
        HdrImage(const std::string & file_name)
        : this(std::ifstream{file_name}) { }
    };
    ```


# Stream e nomi di file

-   Unfortunately this is not valid C++: the code does not compile!

-   The `std::ifstream` instance in the second constructor is temporary and cannot be passed to the first constructor:

    ```text
    $ g++ -c hdrimages.cpp
    hdrimages.cpp: In constructor ‘HdrImage::HdrImage(const string&)’:
    hdrimages.cpp:33:58: error: cannot bind non-const lvalue reference of type ‘std::istream&’ {aka ‘std::basic_istream<char>&’} to an rvalue of type ‘std::basic_istream<char>’
    ```

-   There are similar problems in C♯ and Kotlin, as secondar constructors must first call primary constructors before anything else. This problem is known as *constructor chaining issue*.

-   The easiest solution is to implement the functionality in a function/method and call it in both constructors.


# The Solution of the Riddle

```c++
class HdrImage {
    // Put the code that reads the PFM file in a separate method
    void read_pfm_file(std::istream & stream);

public:
    // First constructor: invoke `read_pfm_file`
    HdrImage(std::istream & stream) { read_pfm_file(stream); }

    // Second constructor: again, invoke `read_pfm_file`
    HdrImage(const std::string & file_name) {
        std::ifstream stream{file_name};
        read_pfm_file(stream);
    }
};
```


# The PFM File Format

-   Let’s recall the shape of the PFM format:

    ```text
    PF
    width height
    ±1.0
    <binary data>
    ```

-   The reading code must verify the following things:

    1.  The file must start with `PF\n`, otherwise it is not in PFM format;
    2.  The second line must contain two positive integers;
    3.  The third line must contain `1.0` or `-1.0`;
    4.  The amount of binary data must be enough; we expect $\text{width} \times \text{height}$ pixels, each made of three components (R, G, B) of 4 bytes each, for a total of $12 \times \text{width} \times \text{height}$ bytes.


# Error Handling

-   The function that reads a file must be able to handle error conditions.
-   In the [previous class](tomasi-ray-tracing-03a.html#/error-handling), we saw that errors in a library function should do nothing **destructive** or **visible**, because it is not possible to know in advance whether the error was caused by the programmer or the user.
-   We can handle error conditions using exceptions if the language supports them, or any other form of error control, like [`std::expected`](https://en.cppreference.com/w/cpp/utility/expected) in C++ or [`Result`](https://doc.rust-lang.org/std/result/) in Rust.
-   If you use exceptions, define a new class to handle exceptions generated while reading a PFM file.


# `InvalidPfmFileFormat`

-   In Python, it is enough to create a class derived from `Exception`:

    ```python
    class InvalidPfmFileFormat(Exception):
        def __init__(self, error_message: str):
            super().__init__(error_message)
    ```

    Note that we accept an error message to better identify which problem occurred when reading the PFM file.

-   If possible, follow the same strategy for your language, perhaps being careful to derive the class from a pre-existing exception suitable for the context (e.g., `System.FormatException` in C#, `RuntimeException` in Kotlin).


# Error Conditions

-   If we handle error conditions using exceptions, we can decide how to handle errors depending on the context.

-   For example, in a `main` that wants to open a PFM file provided by the user:

    ```python
    filename = sys.argv[1]
    try:
        with open(filename, "rb") as inpf:
            image = read_pfm_file(inpf)
    except InvalidPfmFileFormat as err:
        printf(f"impossible to open file {filename}, reason: {err}")
    ```

-   In a *unit test* that needs to open a file containing reference data, we would **not** catch the exception in a `try ... except`.


# Other Exceptions

-   To interpret a PFM file, we will need to call standard library functions of our language:

    -   Reading from a *stream*;
    -   Interpreting a byte string as a number (e.g., `320`).

-   In case of errors, the language's core functions can raise exceptions (e.g., `ValueError` in Python when trying to convert a string like `hello, world!` to an integer).

-   We need to ensure that we "catch" these exceptions and convert them into `InvalidPfmFileFormat`, otherwise, the code from the previous slide would no longer work.


# Example

<asciinema-player src="./cast/catching-exceptions-78x25.cast" cols="78" rows="25" font-size="medium"></asciinema-player>


# Writing Tests

-   We saw in the last lesson that it is easier to write tests for smaller functions.

-   In our case, reading a PFM file could rely on the following functions:

    1.  A function that reads a 32-bit floating point;
    2.  A function that reads a sequence of bytes up to `\n` (if the language does not already provide one);
    3.  A function that interprets the line with the image dimensions;
    4.  A function that determines the file *endianness*.

    Each of these functions can be tested in a dedicated [*unit test*](./tomasi-ray-tracing-03b-image-files.html#/test).


# Support Functions (1/4)

```python
def _read_line(stream):
    result = b""
    while True:
        cur_byte = stream.read(1)
        if cur_byte in [b"", b"\n"]:
            return result.decode("ascii")

        result += cur_byte
```


# Test (1/4)

```python
def test_pfm_read_line():
    line = BytesIO(b"hello\nworld")
    assert _read_line(line) == "hello"
    assert _read_line(line) == "world"
    assert _read_line(line) == ""
```


# Support Functions (2/4)

```python
_FLOAT_STRUCT_FORMAT = {
    Endianness.LITTLE_ENDIAN: "<f",
    Endianness.BIG_ENDIAN: ">f",
}

# This function is meant to be used with PFM files only! It raises a
# InvalidPfmFileFormat exception if not enough bytes are available.
def _read_float(stream, endianness=Endianness.LITTLE_ENDIAN):
    format_str = _FLOAT_STRUCT_FORMAT[endianness]

    try:
        return struct.unpack(format_str, stream.read(4))[0]

    except struct.error:
        # Capture the exception and convert it in a more appropriate type
        raise InvalidPfmFileFormat("impossible to read binary data from the file")
```


# Test (2/4)

-   In Python, we can avoid implementing tests for `_read_float`: it is a function that simply acts as a *wrapper* for a standard function in the Python library.

-   However, if the standard library of your language does not provide a similar feature, you should test it…

-   …but actually we will verify its behavior when we test reading a PFM file from start to finish, so you can avoid creating an unit test for it.


# Support Functions (3/4)

```python
def _parse_endianness(line: str):
    try:
        value = float(line)
    except ValueError:
        raise InvalidPfmFileFormat("missing endianness specification")

    if value > 0:
        return Endianness.BIG_ENDIAN
    elif value < 0:
        return Endianness.LITTLE_ENDIAN
    else:
        raise InvalidPfmFileFormat("invalid endianness specification, it cannot be zero")
```


# Test (3/4)

```python
def test_pfm_parse_endianness():
    assert _parse_endianness("1.0") == Endianness.BIG_ENDIAN
    assert _parse_endianness("-1.0") == Endianness.LITTLE_ENDIAN

    # We must test that the function properly raises an exception when
    # wrong input is passed. Here we use the "pytest" framework to do this.
    with pytest.raises(InvalidPfmFileFormat):
        _ = _parse_endianness("0.0")

    with pytest.raises(InvalidPfmFileFormat):
        _ = _parse_endianness("abc")
```


# Support Functions (4/4)

```python
def _parse_img_size(line: str):
    elements = line.split(" ")
    if len(elements) != 2:
        raise InvalidPfmFileFormat("invalid image size specification")

    try:
        width, height = (int(elements[0]), int(elements[1]))
        if (width < 0) or (height < 0):
            raise ValueError()
    except ValueError:
        raise InvalidPfmFileFormat("invalid width/height")

    return width, height
```


# Test (4/4)

```python
def test_pfm_parse_img_size():
    assert _parse_img_size("3 2") == (3, 2)

    with pytest.raises(InvalidPfmFileFormat):
        _ = _parse_img_size("-1 3")

    with pytest.raises(InvalidPfmFileFormat):
        _ = _parse_img_size("3 2 1")
```

# `read_pfm_image`

```python
def read_pfm_image(stream):
    # The first bytes in a binary file are usually called «magic bytes»
    # See https://hackers.town/@zwol/114155595855705796
    magic = _read_line(stream)
    if magic != "PF":
        raise InvalidPfmFileFormat("invalid magic in PFM file")

    img_size = _read_line(stream)
    (width, height) = _parse_img_size(img_size)

    endianness_line = _read_line(stream)
    endianness = _parse_endianness(endianness_line)

    result = HdrImage(width=width, height=height)
    for y in range(height - 1, -1, -1):
        for x in range(width):
            (r, g, b) = [_read_float(stream, endianness) for i in range(3)]
            result.set_pixel(x, y, Color(r, g, b))

    return result
```

# Integration test

-   We have implemented tests for all the functions on which `read_pfm_image` is built: `_read_line`, `_parse_endianness`, etc.

-   But how can we be sure that we have correctly combined the functions?

-   It is necessary to go beyond *unit tests* and perform a test that runs the entire machinery from start to finish.

-   A test on a complex function that calls already tested simple functions is called an *integration test*.

-   Specifically, our test must verify functionality on *little-endian* files ([`reference_le.pfm`](./media/reference_le.pfm)), *big-endian* files ([`reference_be.pfm`](./media/reference_be.pfm)), and also on invalid files.


# Tests for `read_pfm_file`

```python
# This is the content of "reference_le.pfm" (little-endian file)
LE_REFERENCE_BYTES = bytes([
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
    0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
    0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
    0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
    0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
    0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
    0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
])

# This is the content of "reference_be.pfm" (big-endian file)
BE_REFERENCE_BYTES = bytes([
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x31, 0x2e, 0x30, 0x0a, 0x42,
    0xc8, 0x00, 0x00, 0x43, 0x48, 0x00, 0x00, 0x43, 0x96, 0x00, 0x00, 0x43,
    0xc8, 0x00, 0x00, 0x43, 0xfa, 0x00, 0x00, 0x44, 0x16, 0x00, 0x00, 0x44,
    0x2f, 0x00, 0x00, 0x44, 0x48, 0x00, 0x00, 0x44, 0x61, 0x00, 0x00, 0x41,
    0x20, 0x00, 0x00, 0x41, 0xa0, 0x00, 0x00, 0x41, 0xf0, 0x00, 0x00, 0x42,
    0x20, 0x00, 0x00, 0x42, 0x48, 0x00, 0x00, 0x42, 0x70, 0x00, 0x00, 0x42,
    0x8c, 0x00, 0x00, 0x42, 0xa0, 0x00, 0x00, 0x42, 0xb4, 0x00, 0x00
])

def test_pfm_read(self):
    for reference_bytes in [LE_REFERENCE_BYTES, BE_REFERENCE_BYTES]:
        img = read_pfm_image(BytesIO(reference_bytes))
        assert img.width == 3
        assert img.height == 2

        assert img.get_pixel(0, 0).is_close(Color(1.0e1, 2.0e1, 3.0e1))
        assert img.get_pixel(1, 0).is_close(Color(4.0e1, 5.0e1, 6.0e1))
        assert img.get_pixel(2, 0).is_close(Color(7.0e1, 8.0e1, 9.0e1))
        assert img.get_pixel(0, 1).is_close(Color(1.0e2, 2.0e2, 3.0e2))
        assert img.get_pixel(0, 0).is_close(Color(1.0e1, 2.0e1, 3.0e1))
        assert img.get_pixel(1, 1).is_close(Color(4.0e2, 5.0e2, 6.0e2))
        assert img.get_pixel(2, 1).is_close(Color(7.0e2, 8.0e2, 9.0e2))

def test_pfm_read_wrong(self):
    buf = BytesIO(b"PF\n3 2\n-1.0\nstop")
    with pytest.raises(InvalidPfmFileFormat):
        _ = read_pfm_image(buf)
```


# What to do today

# What to do today

1.  Implement the following functions:

    -   Reading a sequence of 4 bytes into a 32-bit floating point, considering the *endianness* (`_read_float` in the Python example);
    -   Reading a sequence of bytes up to `\n` or the end of the stream (`_read_line`);
    -   Reading the image dimensions from a string (`_parse_img_size`);
    -   Decoding the type of *endianness* from a string (`_parse_endianness`).

2.  Implement a function/method that reads a PFM file from a stream.

3.  Implement the same tests as in the Python example. Also, verify that your methods correctly handle errors.

# Hints for C++

# Determining the endianness

-   If you want, you can check the endianness of the system used to compile your program with the [`std::endian`](https://en.cppreference.com/w/cpp/types/endian.html) enum class (in `<bit>`, available since C++20)

-   However, `std::endian` does not perform any conversion: it simply *reports* what is the endianness

-   To actually perform the conversion, you can use [`std::byteswap`](https://en.cppreference.com/w/cpp/numeric/byteswap.html) (still in `<bit>`)

-   Prefer `std::byte` (in `<stddef>`) over `char`, so you clearly signal that you are actually referring to a “byte” instead of a “character”.

# Files and Streams

-   For file access, C++ is not very sophisticated: you open the file for writing using `std::ofstream`.

-   In-memory streams (like `ByteIO` in Python) are implemented by [`std::stringstream`](https://www.cplusplus.com/reference/sstream/stringstream/stringstream/) (in `<sstream>`):

    ```c++
    std::stringstream sstr;

    sstr << "PF\n" << width << " " << height << "\n" << endianness;
    std::string result{sstr.str()};  // "result" is an ASCII string
    ```


# Writing Binary Data

-   C++ does not offer many tools to decompose a `float` variable into its four bytes; use this implementation and study it carefully:

    ```c++
    #include <cstdint>  // It contains uint8_t

    enum class Endianness { little_endian, big_endian };

    void write_float(std::ostream &stream, float value, Endianness endianness) {
      // Convert "value" in a sequence of 32 bit
      uint32_t double_word{*((uint32_t *)&value)};

      // Extract the four bytes in "double_word" using bit-level operators
      uint8_t bytes[] = {
          static_cast<uint8_t>(double_word & 0xFF),         // Least significant byte
          static_cast<uint8_t>((double_word >> 8) & 0xFF),
          static_cast<uint8_t>((double_word >> 16) & 0xFF),
          static_cast<uint8_t>((double_word >> 24) & 0xFF), // Most significant byte
      };

      switch (endianness) {
      case Endianness::little_endian:
        for (int i{}; i < 4; ++i)    // Forward loop
          stream << bytes[i];
        break;

      case Endianness::big_endian:
        for (int i{3}; i >= 0; --i)  // Backward loop
          stream << bytes[i];
        break;
      }
    }

    // You can use "write_float" to write little/big endian-encoded floats:
    // write_float(stream, 10.0, Endianness::little_endian);
    // write_float(stream, 10.0, Endianness::big_endian);
    ```


# Big/little endian?

-   On the third line of the PFM file, you must write `1.0` or `-1.0` depending on the *endianness*.

-   The `write_float` function from the previous slide works in both cases, so you can choose one and use that.

-   Side note: the following function returns `true` when run on a *little endian* system, and `false` otherwise:


    ```c++
    bool is_little_endian() {
      uint16_t word{0x1234};
      uint8_t *ptr{(uint8_t *)&word};

      return ptr[0] == 0x34;
    }
    ```


# Hints for Java/Kotlin


# Files and Streams

-   Java and Kotlin have the classes [`InputStream`](https://docs.oracle.com/javase/7/docs/api/java/io/InputStream.html) and [`OutputStream`](https://docs.oracle.com/javase/7/docs/api/java/io/OutputStream.html) (in `java.io`) to represent a stream. These are suitable for the `writeFloat` and `writePfm` prototypes.

-   [`FileOutputStream`](https://docs.oracle.com/javase/7/docs/api/java/io/FileOutputStream.html) opens a file for writing and returns a stream.

-   In-memory streams are created with [`ByteArrayOutputStream`](https://docs.oracle.com/javase/7/docs/api/java/io/ByteArrayOutputStream.html).

-   To open a file, operate on it, and close it, Kotlin offers the very convenient [`use`](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.io/use.html), similar to `using` in C#:

    ```kotlin
    FileOutputStream("out.pfm").use {
        outStream -> outStream.write(...)
    }
    ```


# Writing Binary Files

-   Endianness is identified by the [`ByteOrder`](https://docs.oracle.com/javase/7/docs/api/java/nio/ByteOrder.html) type in `java.nio` (a Java class, but you can natively use Java libraries in Kotlin).

-   To write/read values in binary format, there is the [`ByteBuffer`](https://docs.oracle.com/javase/7/docs/api/java/nio/ByteBuffer.html) class, also in `java.nio`. Example in Kotlin:

    ```kotlin
    fun writeFloatToStream(stream: OutputStream, value: Float, order: ByteOrder) {
        val bytes = ByteBuffer.allocate(4).putFloat(value).array() // Big endian

        if (order == ByteOrder.LITTLE_ENDIAN) {
            bytes.reverse()
        }

        stream.write(bytes)
    }
    ```


# Initializing `ByteBuffer`

-   Bytes in Kotlin are signed (very strange!).

-   To initialize an array from hexadecimal values like those printed by `xxd -i reference_be.pfm`, you need a small helper function:

    ```kotlin
    fun byteArrayOfInts(vararg ints: Int) =
        ByteArray(ints.size) { pos -> ints[pos].toByte() }
    ```


# Content of `reference_be.pfm`

```kotlin
val reference_be = byteArrayOfInts(
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x31, 0x2e, 0x30, 0x0a, 0x42,
    0xc8, 0x00, 0x00, 0x43, 0x48, 0x00, 0x00, 0x43, 0x96, 0x00, 0x00, 0x43,
    0xc8, 0x00, 0x00, 0x43, 0xfa, 0x00, 0x00, 0x44, 0x16, 0x00, 0x00, 0x44,
    0x2f, 0x00, 0x00, 0x44, 0x48, 0x00, 0x00, 0x44, 0x61, 0x00, 0x00, 0x41,
    0x20, 0x00, 0x00, 0x41, 0xa0, 0x00, 0x00, 0x41, 0xf0, 0x00, 0x00, 0x42,
    0x20, 0x00, 0x00, 0x42, 0x48, 0x00, 0x00, 0x42, 0x70, 0x00, 0x00, 0x42,
    0x8c, 0x00, 0x00, 0x42, 0xa0, 0x00, 0x00, 0x42, 0xb4, 0x00, 0x00
)
```

Do the same with `reference_le.pfm`.


# Writing Text

-   Java and Kotlin internally represent strings using UTF-16 encoding.

-   To convert the encoding to ASCII so it can be saved in a binary file, Kotlin offers the very convenient `toByteArray()` method:

    ```kotlin
    val header = "PF\n$width $height\n$endianness\n"
    stream.write(header.toByteArray())
    ```


# Hints for Julia

# Files and Streams

- In Julia, streams are represented as subtypes of `IO`.

- Instead of defining a `savepfm` function, provide a new definition of [`write`](https://docs.julialang.org/en/v1/base/io-network/#Base.write) using *multiple dispatch*:

    ```julia
    function write(io::IO, image::HdrImage)
        # ...
    end
    ```

    This way you will extend the `write` function (implemented by Julia for basic types) to your `HdrImage` type as well.

# Writing Binary Files

- To determine if the machine is *little endian* or *big endian*, there is the constant [`ENDIAN_BOM`](https://docs.julialang.org/en/v1/base/io-network/#Base.ENDIAN_BOM):

    ```julia
    const little_endian = ENDIAN_BOM == 0x04030201
    ```

- To convert a floating-point number to an integer and vice-versa, there is [`reinterpret`](https://docs.julialang.org/en/v1/base/arrays/#Base.reinterpret):

    ```julia
    # On little-endian machines
    @assert reinterpret(UInt32, 1.0f0) == 0x3f800000
    # On big-endian machines
    @assert reinterpret(UInt32, 1.0f0) == 0x0000803f
    ```

# Conversions

- You can convert an integer value from *big endian* or *little endian* to the local machine format with the functions `ntoh`, `hton`, `ltoh` and `htol`.

- The letter `h` stands for «host», and indicates the machine on which the program is running.

- Obviously, on *little endian* machines the functions `ltoh` and `htol` correspond to the identity; on *big endian* machines this applies to `ntoh` and `hton`.

# Writing Text

- Strings in Julia are of type `String`, and are encoded as UTF-8.

- Characters are of type `Char`, but unlike C++ they are 32-bit values: in other words, they are Unicode *code points* stored using UTF-32.

- To convert a string to a sequence of bytes, use [`transcode`](https://docs.julialang.org/en/v1/base/strings/#Base.transcode):

    ```julia
    bytebuf = transcode(UInt8, "PF\n$width $height\n$endianness\n")
    open("out.pfm", "wb") do io
        write(io, bytebuf)
        # ...
    end
    ```

# Hints for C\#

# Files and Streams

-   In C#, a stream is of type `Stream`, which is a base class from which [`FileStream`](https://docs.microsoft.com/en-us/dotnet/api/system.io.filestream?view=net-5.0) and [`MemoryStream`](https://docs.microsoft.com/en-us/dotnet/api/system.io.memorystream?view=net-5.0) derive.

-   To open a file for writing, use the [`using`](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/using-statement) keyword:

    ```csharp
    var img = new HdrImage(7, 4);

    using (Stream fileStream = File.OpenWrite("file.pfm"))
    {
        img.SavePfm(fileStream);
    }
    ```

# Writing Binary Data

-   The [`BitConverter`](https://docs.microsoft.com/en-us/dotnet/api/system.bitconverter?view=net-5.0) class implements methods for reading and writing binary data from streams.

-   The following method writes a 32-bit floating-point number in binary:

    ```csharp
    private static void writeFloat(Stream outputStream, float value)
    {
        var seq = BitConverter.GetBytes(value);
        outputStream.Write(seq, 0, seq.Length);
    }
    ```

-   The variable `BitConverter.IsLittleEndian` exists to decide whether to write `1.0` or `-1.0` in the PFM file.

# Writing Text

-   C#, unlike C++, distinguishes between strings (encoded in Unicode with UTF-16) and byte sequences.

-   To correctly write the header, the simplest thing is to create a Unicode string and then convert it to ASCII:

    ```csharp
    var header = Encoding.ASCII.GetBytes($"PF\n{width} {height}\n{endianness_value}\n");
    ```

    where `endianness_value` is a `double` that is either `1.0` or `-1.0`.


# Hints for D

# Streams

-   Unfortunately, the most recent version of the D language [does not natively support streams](https://forum.dlang.org/post/mailman.797.1513034483.9493.digitalmars-d-learn@puremagic.com).

-   But it's not a big deal, because you can use dynamic byte sequences like `ubyte[]`; for writing, an [`Appender`](https://dlang.org/library/std/array/appender.html) is even better (more efficient), or alternatively [`outbuffer`](https://dlang.org/phobos/std_outbuffer.html).

-   The language provides the [Endian](https://dlang.org/library/std/system/endian.html) type and the [std.bitmanip](https://dlang.org/phobos/std_bitmanip.html) library, which provides the `append` template function:

    ```d
    auto stream = appender!(ubyte[])();
    float value = 123.456;
    // uint is a 4-byte integer
    append!(uint, Endian.bigEndian)(stream, *cast(uint*)(&value));
    ```

# Writing a File

-   To write a `float` number to an `Appender`, you can use this code:

    ```d
    void write_float(Appender!(ubyte[]) appender, float value, Endian endianness) {
      if (endianness == Endian.bigEndian) {
        append!(uint, Endian.bigEndian)(appender, *cast(uint*)(&value));
      } else {
        append!(uint, Endian.littleEndian)(appender, *cast(uint*)(&value));
      }
    }
    ```

-   Note that you cannot pass the `endianness` value to `append!` because, being a template, it requires the value to be known at compile time.

-   To write the header, you can send the ASCII file string with the `put` function: `appender.put(cast(ubyte[])(header_string))`.

# Reading a File (1/2)

-   It's simple to interpret a byte array as a *stream*:

    ```d
    class StringStream {
      uint curidx = 0;
      const ubyte[] stream;

      this(const ubyte[] _stream) { stream = _stream; }
      bool eof() { return curidx >= stream.length; }

      char read_char() {
        if (curidx < stream.length) {
          char result = stream[curidx];
          curidx++;
          return result;
        }

        return 0;  // If we are at the end of the string, return 0
      }
    }
    ```

-   Add a `read_line()` method for convenience.

# Reading a File (2/2)

-   To read a `float`, use this method:

    ```d
    float read_float(Endian endianness) {
      uint result = 0;
      for(int i = 0; i < 4; ++i) {
        result = (result << 8) + read_char(); // Assume big endian here
      }

      if(endianness != Endian.bigEndian) result = result.swapEndian;
      return *cast(float*)(&result);
    }
    ```

-   In addition to `decode_pfm(const ubyte[])`, you can also implement:

    ```d
    HdrImage decode_pfm_from_file(const string file_name) {
      return decode_pfm(cast(const(ubyte)[])read(file_name));
    }
    ```


# Hints for Nim

# Libraries to use

-   Today's code should be very simple to implement in Nim

-   The library [endians](https://nim-lang.org/docs/endians.html) provides functions to convert data in *little*/*big endian* format

-   The library [streams](https://nim-lang.org/docs/streams.html) implements the concept of *stream* both associated with a file and with a string in memory


# Hints for Rust

# Use of `enum` and `match`

-   To specify the *endianness* there is the type [`ByteOrder`](https://docs.rs/endianness/latest/endianness/enum.ByteOrder.html) in the crate [endianness](https://docs.rs/endianness/latest/endianness/)

-   With `enum`s get used to using `match` instead of `if`:

    ```rust
    fn endianness_number(endianness: &ByteOrder) -> f32 {
        match endianness {
            ByteOrder::LittleEndian => -1.0,
            ByteOrder::BigEndian => 1.0,
        }
    }
    ```

# Streams

-   Use the `Write` and `Read` *traits* to define functions that read and write to a stream. For example:

    ```rust
    fn write_float<T: Write>(
        dest: &mut T,
        value: f32,
        endianness: &Endianness,
    ) -> std::io::Result<usize> {
        match endianness {
            Endianness::LittleEndian => dest.write(&value.to_le_bytes()),
            Endianness::BigEndian => dest.write(&value.to_be_bytes()),
        }
    }
    ```

-   You can make the code faster using [`BufWriter` and `BufReader`](https://doc.rust-lang.org/nightly/std/io/index.html#bufreader-and-bufwriter), but it's not necessary (it certainly won't be the bottleneck!).

---
title: "Laboratory 3"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...
