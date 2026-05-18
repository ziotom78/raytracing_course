# A warning

- It will take some time before you can produce photorealistic images (You
  didn’t want to end this course in two weeks, did you?!?)

- The problem is that we need a lot of infrastructure before we can solve the
  rendering equation

- Our first image will be a so-called
  [black triangle](https://rampantgames.com/blog/?p=7745), to use a well-known
  meme.

# How to handle colors {#handling-colors}

# Encoding a color

- We saw that the colors perceived by the human eye can be encoded using three
  scalars R, G, B.

- Our task for today is to implement a `Color` data type that encodes a color
  using three 32-bit floating-point numbers.

- We’ll deal with the conversion from RGB to sRGB next week, when we will talk
  about graphics formats (PNG, Jpeg, etc.)

- As I did last week, I will show you a few examples in Python

# Colors in Python

- Let’s define a class named `Color` using `@dataclass` (it’s like `struct` in
  C++):

  ```python
  # Supported since Python 3.7
  from dataclasses import dataclass

  @dataclass
  class Color:
      r: float = 0.0
      g: float = 0.0
      b: float = 0.0
  ```

- We can create colors using these syntaxes:

  ```python
  color1 = Color(r=3.4, g=0.4, b=1.7)
  color2 = Color(3.4, 0.4, 1.7)  # Shorter version
  ```

# Operations on `Color`

- Sum two colors (like in $L_\lambda^{(1)} + L_\lambda^{(2)}$)
- Scalar-color product ($\alpha L_\lambda$)
- Product between two colors ($f_{r,\lambda} \otimes L_\lambda$ in the rendering
  equation)
- Similarity between two colors (useful for tests)

# Example in Python

```python
class Color:
    # ...

    def __add__(self, other):
        """Sum two colors"""
        return Color(
            self.r + other.r,
            self.g + other.g,
            self.b + other.b,
        )

    def __mul__(self, other):
        """Multiply two colors, or one color with one number"""
        try:
            # Try a color-times-color operation
            return Color(
                self.r * other.r,
                self.g * other.g,
                self.b * other.b,
            )
        except AttributeError:
            # Fall back to a color-times-scalar operation
            return Color(
                self.r * other,
                self.g * other,
                self.b * other,
            )

    # Etc.
```

# The type `HdrImage`

- We’ll implement the type `HdrImage` alongside `Color`. It will be used to
  represent a HDR image as a 2D matrix of `Color` instances.
- The task for today is to implement the following functionalities in
  `HdrImage`:
  - Create an empty image with a given number of columns (`width`) and rows
    (`height`);
  - Read/write pixels.

# The `Color` matrix

- The most natural type for a matrix is a 2D array with size `(width, height)`…

- …but it’s more efficient to use a **monodimensional** array with size
  `width × height`. (This is not the case if you use Julia: just rely on
  `Matrix`!)

- Not every programming language supports 2D arrays (e.g., Kotlin), and if you
  use them in the wrong way, they can be inefficient:

  ```java
  // This is valid Java, but it's sub-optimal!
  int[][] myNumbers = { {1, 2, 3, 4}, {5, 6, 7} };
  ```

# Structure of `HdrImage`

- In Python, we can implement `HdrImage` in this way:

  ```python
  class HdrImage:
      def __init__(self, width=0, height=0):
          # Initialize the fields `width` and `height`
          (self.width, self.height) = (width, height)
          # Create an empty image (Color() returns black, remember?)
          self.pixels = [Color() for i in range(self.width * self.height)]
  ```

- The array of values has $\mathtt{width} \times \mathtt{height}$ elements

- However, we want to identify an element in the matrix using a pair
  `(column, row)`, i.e., `(x, y)`.

# Accessing pixels

Given some position `(x, y)` for a pixel (with `x` the number of the column and
`y` the row), the index in the array `self.pixels` can be calculated in this
way:

<center>
![](./media/bitmap-linear-access.svg)
</center>

# `get_pixel` and `set_pixel`

```python
def get_pixel(self, x: int, y: int) -> Color:
    """Return the `Color` value for a pixel in the image

    The pixel at the top-left corner has coordinates (0, 0)."""

    assert (x >= 0) and (x < self.width)
    assert (y >= 0) and (y < self.height)
    return self.pixels[y * self.width + x]

def set_pixel(self, x: int, y: int, new_color: Color):
    """Set the new color for a pixel in the image

    The pixel at the top-left corner has coordinates (0, 0)."""

    assert (x >= 0) and (x < self.width)
    assert (y >= 0) and (y < self.height)
    self.pixels[y * self.width + x] = new_color
```

Can we avoid those repetitions?

# Verifying your code {#testing-principles}

# Why should we verify our code?

- Errors are lurking around every corner!

- This example was taken from a test in the TNDS course:

  ```c++
  VectorField operator+(const VectorField &v) const {
    VectorField sum(v); // I am calling the copy constructor for v
    sum.Addcomponent(getFx(), getFx(), getFz());

    return sum;
  }
  ```

- To verify the correctness of a function, we should call it with _non-trivial data_ and check the result.

# How can we verify our code?

- Once we have written some code, we must _verify_ its correctness by running it on inputs for which we can reasonably foresee the expected outputs.

- The simplest way is to print the output and visually check it’s ok:

  ```python
  color1 = Color(1.0, 2.0, 3.0)  # Avoid repeated values like Color(3.0, 3.0, 3.0)
  color2 = Color(5.0, 6.0, 7.0)  # in your tests! This is called *fingerprinting*
  print(color1 + color2)
  print(color1 * 2)
  # Output:
  #     Color(r=6.0, g=8.0, b=10.0)
  #     Color(r=2.0, g=4.0, b=6.0)
  ```

- Can we do better?

# Automatic tests

- Checking calculations is boring and error-prone.

- Computers have been invented to avoid doing repetitive and boring stuff!

- Every modern language offers some built-in system to run tests automatically. (C++ is a notable exception, but there are lots of libraries that fill this gap.)

# Automatic tests

Our starting point is this Python code:

```python
color1 = Color(1.0, 2.0, 3.0)
color2 = Color(5.0, 6.0, 7.0)
print(color1 + color2)
print(color1 * 2)
```

We can improve it using `assert`:

```python
color1 = Color(1.0, 2.0, 3.0)
color2 = Color(5.0, 6.0, 7.0)
assert (color1 + color2) == Color(6.0, 8.0, 10.0)
assert (2 * color1) == Color(2.0, 4.0, 6.0)
# If everything is ok, no output is expected
```

# Are we sure of our tests?

- The fact that the new version of our Python scripts does not produce any output is expected, as the implementation is bug-free. But if we get no output, are we _really_ sure that the tests were executed as expected?

- A common trick is to implement _wrong_ tests and make them fail:

  ```python
  color1 = Color(1.0, 2.0, 3.0)
  color2 = Color(5.0, 6.0, 7.0)
  assert (color1 + color2) == Color(6.0, 8.0, 11.0) # 11.0 instead of 10.0: wrong!
  assert (2 * color1) == Color(3.0, 4.0, 6.0)       # 3.0 instead of 2.0: wrong!
  ```

  Once we see that the tests failed, we can fix them and make them pass.

---

<asciinema-player src="cast/color-test-python.cast" rows="27" cols="94" font-size="medium"></asciinema-player>

# Testing floating-point values

- In the tests we are going to write, we will have to use logical operations and comparisons (for Python, these are typically `==`, `<`, `>`, `<=`, `>=`, etc.)

- We must handle floating-point numbers with special care!

  <asciinema-player src="cast/floating-point-python.cast" rows="15" cols="80" font-size="medium"></asciinema-player>

# Tricks for floating-point values

- Avoid numbers with a decimal part, like `2.1` or `5.09`, if possible

- Small integer numbers like `16.0` are encoded without rounding, so prefer them in tests, if possible (we did so for `Color` in our Python example)

- As it’s not always possible to use integer numbers, implement a function `are_close` (if your language doesn’t provide one already):

  ```python
  def are_close(x, y, epsilon = 1e-5):
      return abs(x - y) < epsilon

  x = sum([0.1] * 10)       # Sum of the values in [0.1, 0.1, ..., 0.1]
  print(x)                  # Output: 0.9999999999999999
  assert are_close(1.0, x)  # This test passes successfully
  ```

# Code granularity and tests

- Tests can provide a guidance for the implementation of types and functions.

- Implementing `get_pixel` and `set_pixel` leads to repetitions:

  ```python
  def get_pixel(self, x: int, y: int) -> Color:
      assert (x >= 0) and (x < self.width)
      assert (y >= 0) and (y < self.height)
      return self.pixels[y * self.width + x]

  def set_pixel(self, x: int, y: int, new_color: Color):
      assert (x >= 0) and (x < self.width)
      assert (y >= 0) and (y < self.height)
      self.pixels[y * self.width + x] = new_color
  ```

  We must verify the correctness of coordinates twice 🙁

---

# Repeating tests

- We must verify that wrong coordinates are rejected both by `set_pixel` and `get_pixel`:

  ```python
  img = HdrImage(7, 4)

  # Test that wrong positions be signaled
  with pytest.raises(AssertionError):
      img.get_pixel(-1, 0)

  # We must redo the same for "set_pixel"
  with pytest.raises(AssertionError):
      img.set_pixel(-1, 0, Color())
  ```

- We can improve our code and tests by _modularizing_ our implementation, i.e., we decompose it in simpler parts.

# New implementation

```python
def valid_coordinates(self, x: int, y: int) -> bool:
    return ((x >= 0) and (x < self.width) and
            (y >= 0) and (y < self.height))

def pixel_offset(self, x: int, y: int) -> int:
    return y * self.width + x

def get_pixel(self, x: int, y: int) -> Color:
    assert self.valid_coordinates(x, y)
    return self.pixels[self.pixel_offset(x, y)]

def set_pixel(self, x: int, y: int, new_color: Color):
    assert self.valid_coordinates(x, y)
    self.pixels[self.pixel_offset(x, y)] = new_color
```

# Tests

- Here are the tests for the new implementation:

  ```python
  img = HdrImage(7, 4)

  # Check that valid/invalid coordinates are properly flagged
  assert img.valid_coordinates(0, 0)
  assert img.valid_coordinates(6, 3)
  assert not img.valid_coordinates(-1, 0)
  assert not img.valid_coordinates(0, -1)
  assert not img.valid_coordinates(7, 0)
  assert not img.valid_coordinates(0, 4)

  # Check that indices in the array are calculated correctly:
  # this kind of test would have been harder to write
  # in the old implementation
  assert img.pixel_offset(3, 2) == 17    # See the plot a few slides before
  assert img.pixel_offset(6, 3) == 7 * 4 - 1
  ```

- This kind of test is called _unit test_

# Public/private methods

- OOP programming encourages the declaration of some methods/fields as “private”, so that they cannot be invoked outside a class.

- However, this practice makes the implementation of unit tests more difficult. Functions like `valid_coordinates` and `pixel_offset` should be declared “private”, but in this way we cannot invoke them directly in tests!

- The simplest solution is to define these functions as “public” so that we can write tests in the usual way, but to prepend their name with an underscore “`_`”. (In Computer Science, it is customary to consider names like `_valid_coordinates` and `_pixel_offset` as private.)

# Support functions for tests

- In our Python code, to check the correspondence between two colors, we used `==`, which works because we specified integer numbers:

```c++
assert (color1 + color2) == Color(6.0, 8.0, 10.0)
assert (2 * color1) == Color(2.0, 4.0, 6.0)
```

- We will soon need to use $\pi$ in our calculations with colors, so define a function that compares the “closeness” of two `Color` instances:

```python
def are_colors_close(a, b):
    return are_close(a.r, b.r) and are_close(a.g, b.g) and are_close(a.b, b.b)

assert are_colors_close(color1, color2)
```

# Importance of Tests

- Writing good tests is one of the skills that this course aims to develop.

- Therefore, **it is essential** that your repositories demonstrate a regular implementation of tests, lesson by lesson.

- Regularity in the implementation of tests and their quality is one of the criteria by which you will be assessed in the exam.

- (Moreover, it will be a good showcase of your code cleanliness in the future!)

# Importance of good commits!

- Your GitHub or LinkedIn profile may be reviewed during job interviews

- If you take good care of the repository for this course, it may serve as a "showcase" to include in your resume

- Therefore, avoid writing vague comments in your commits!

- Refer to the blog post [Writing good commit messages](https://kelvinromero.medium.com/writing-good-commit-messages-527679b1babb)

---

![](media/bad-commit-messages.png)

# Group Work {#team-work-in-git}

- From now on, you will work in groups: each of you will have to choose a part of the code to implement.

- We will start using the advanced features of Git to manage **conflicts**, that is, situations in which a part of the code is modified simultaneously by multiple people.

---

<asciinema-player src="cast/git-conflicts-96x27.cast" cols="96" rows="27" font-size="medium"></asciinema-player>

# _Merge commit_

<center> ![](./media/merge-commit.svg) </center>

# Types of conflicts

1. Two developers implement the same functionality:
   - Choose one of the implementations
   - Merge them together
2. Two developers implement separate functionalities in the same code location:
   - If they can coexist, keep them together (as in the previous video example)
   - If not, separate them into two different files
3. Two developers implement incompatible functionalities:
   - Decide which functionality to maintain and which to discard…
   - …or one of the developers quits!


# What to do today

# What to do today

1. Choose a project name (we will use `myraytracer` for this exercise).

2. Structure the project as follows:

   - A library implementing `Color` and `HdrImage` classes, and their operations
   - A console application that imports the library, but for now only prints "Hello, world!"
   - A series of automated tests for `Color` and `HdrImage` classes

3. Commit the project to GitHub, add team members, and send an email to the teacher ([maurizio.tomasi@unimi.it](mailto:maurizio.tomasi@unimi.it).)

4. Don't be afraid of creating conflicts and performing merge commits: the more you practice with them, the easier it will be in the future.

# Group work

- In each group, only **one** person should create the project skeleton, create the GitHub page, and save it.

- The other group members become project collaborators (see the following slide for more information).

- Think about how to divide the work among group members; for example, for `Color`:

  1. Sum of two colors
  2. Product of two colors, and color-scalar product
  3. `are_colors_close` function
  4. Tests

---

<center>
![](./media/github-add-collaborators.png)
</center>

# Working in a Team

- Each of you will need to run `git push` on your repository on GitHub to send your changes (“commit”) to the server

- Once this is done, your team members can download the changes using `git pull`

- A way to divide the work is for one of you to implement a method (e.g., `valid_coordinates`) while the other writes the test **simultaneously**:

  - `valid_coordinates` + test;
  - `pixel_offset` + test;
  - `get_pixel`/`set_pixel` + test.

# Properties of `Color`

- Three fields `r`, `g`, `b` of type 32-bit floating-point: they don't need 64 bits, and would actually waste memory and processing time

- For OOP languages, don’t lose time writing getters and setters like `GetR`, etc.: they are long to write, prone to errors, and make the code harder to read

- A method/function that checks if two colors are similar (useful for testing);

- Addition of colors;

- Multiplication of color and color or color and scalar;

- If appropriate, implement a function that converts an object into a string (e.g., `<r:1.0, g:3.0, b:4.0>`): it will be handy for debugging

# Memory usage

- Most programming languages differentiate between _value_ and _reference types_.

- _Value types_ are direct values that can be accessed directly, and are always allocated on the stack: they are very fast to use, but cannot take up much memory (usually only a few kilobytes).

- _Reference types_ are pointers to the actual data, and can be allocated on the stack or heap: they can consume all available memory, but are slower to access and manipulate.

- Exceptions include languages based on the Java Virtual Machine (Java, Kotlin, Scala, etc.), where there are only reference types (although the JVM may automatically convert values to references if it deems it beneficial).

---

<center>
![](./media/stack-vs-heap-memory.svg)
</center>

---

# An example using C++

```c++
#include <iostream>
#include <vector>

int main() {
    int a{};                     // Allocated on the stack
    int * b{new int};            // Allocated in the heap
    int c[] = {1, 2, 3};         // Allocated on the stack
    std::vector<int> v{1, 2, 3}; // "v" on the stack, but the three numbers in the heap

    a = 15;   // This is fast
    *b = 16;  // This is slower

    std::cout << a << ", " << *b << "\n";
    // Output:
    // 15, 16
}
```

In Python, any variable (even integer variables like `x = 1`) is allocated on
the heap (one of the reasons why it is much slower than C++)

# Stack size

- For programs written in C/C++/Fortran/Julia, the stack size is set by the operating system. On systems using Posix (such as Linux/macOS), you can find the value in KB using the command `ulimit -s`:

  ```
  $ ulimit -s
  8192
  ```

  The value of 8 MB is characteristic of Linux; for macOS, it is 0.5 MB.

- For the .NET platform (including Visual Basic and C#), a 1 MB stack is used.

- The JVM (Java, Kotlin) uses a 1 MB stack, which is only used for primitive types (integers, booleans, floating-point numbers).

# Value types

- The `Color` class is quite small: it requires 3 floating-point numbers in memory, making it a good candidate for a value type (this is not true for `HdrImage`).

- The way you ask for a value type depends on the programming language:

  - In C++, both `struct` and `class` can be used (they are equivalent), but when using them, avoid using `new` and `delete`.
  - In C# and D, `struct` is used for value types (but not `class`), while `class` is used for reference types.
  - In Pascal, `object` or `record` can be used, but not `class`.
  - In Nim, `object` can be used, but not `ref object`.
  - In Julia, the [`StaticArrays`](https://julialang.github.io/staticarrays.jl/) package can be used.

# Test (1)

- Creating `Color` objects and using the `is_close` function:

  ```python
  color = Color(1.0, 2.0, 3.0)
  assert color.is_close(Color(1.0, 2.0, 3.0))
  ```

- It is important to test that `is_close` returns `False` when necessary (note that this is a **negative** test):

  ```python
  assert not color.is_close(Color(3.0, 4.0, 5.0))  # First method
  ```

# Test (2)

- Sum/product between colors:

  ```python
  col1 = Color(1.0, 2.0, 3.0)  # Do not use the previous definition,
  col2 = Color(5.0, 7.0, 9.0)  # it's better to define it again here

  assert (col1 + col2).is_close(Color(6.0, 9.0, 12.0))
  assert (col1 * col2).is_close(Color(5.0, 14.0, 27.0))
  ```

- Color-scalar product (you can implement scalar-color too, if you want):

  ```python
  prod_col = Color(1.0, 2.0, 3.0) * 2.0

  assert prod_col.is_close(Color(2.0, 4.0, 6.0))
  ```

# Test (3)

```python
def test_image_creation():
    img = HdrImage(7, 4)
    assert img.width == 7
    assert img.height == 4

def test_coordinates():
    img = HdrImage(7, 4)

    assert img.valid_coordinates(0, 0)
    assert img.valid_coordinates(6, 3)
    assert not img.valid_coordinates(-1, 0)
    assert not img.valid_coordinates(0, -1)
    assert not img.valid_coordinates(7, 0)
    assert not img.valid_coordinates(0, 4)

def test_pixel_offset():
    img = HdrImage(7, 4)

    assert img.pixel_offset(0, 0) == 0
    assert img.pixel_offset(3, 2) == 17
    assert img.pixel_offset(6, 3) == 7 * 4 - 1

def test_get_set_pixel():
    img = HdrImage(7, 4)

    reference_color = Color(1.0, 2.0, 3.0)
    img.set_pixel(3, 2, reference_color)
    assert are_colors_close(reference_color, img.get_pixel(3, 2))
```

# Hints for C++

# Numeric types

-   Be aware that C++ uses weird rules to establish the size of the types. Depending on the CPU/operating system/compiler you use, `int` might be a 16-bit, 32-bit, or 64-bit integer. This can cause many portability issues!

-   The recommended way to overcome this problem is to always use the types defined in `<cstdint>`: `int8_t`, `uint8_t`, `int16_t`, `uint16_t`, etc.

-   (This approach makes C++ more similar to Rust, which has built-in types like `u8`, `i8`, `u16`, `i16`, …)

-   It’s ok to use `int` for the counter used in `for` loops (`for(int i{}; i < …; i++)`), if you expect its maximum not to be too large, as the size of `int` is usually chosen to be the fastest integer type supported on the machine.

# Running tests

-   With Xmake, it is trivial to run tests, as it implements the command `xmake test`. See [the manual](https://xmake.io/guide/basic-commands/run-tests.html)

-   If you use [CMake](https://cmake.org/), things are more complicated. You must rely on CTest, which is a companion program developed by KitWare.

# Using CMake/CTest

- Create this directory tree:

  ```text
  $ tree raytracer
  raytracer
  ├── CMakeLists.txt
  ├── include
  │   └── colors.h       <-- Definition of "Color"
  ├── src
  │   ├── colors.cpp     <-- Implementation of "Color" (if you *really* need it!)
  │   └── raytracer.cpp
  └── test
      └── colors.cpp     <-- Tests for the class "Color"
  ```

- If you implement all the methods for `Colors` in `include/colors.h` (highly recommended! this makes the code faster), there is no need of `src/colors.cpp`.

# `CMakeLists.txt`

- CMake will have to create three products:

  1. A library that implements `Color`; choose a name for it (we will use `trace`).
  2. An executable program that uses the library, which we will call `raytracer`. At the moment it is enough that it prints `Hello, world!`.
  3. A program that runs the tests, which we will call `colorTest`.

- To create programs we know that there is the `add_executable` command; for libraries there is the analogous `add_library`.

- The dependencies between the `trace` library and programs are specified with `target_link_libraries`.

# Libraries and Executables

- The sequence of libraries and executables to produce is specified as follows:

  ```cmake
  add_library(trace
    src/colors.cpp
    )
  # This is needed if we keep .h files in the "include" directory
  target_include_directories(trace PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
    )

  add_executable(raytracer
    src/raytracer.cpp
    )
  target_link_libraries(raytracer PUBLIC trace)

  add_executable(colorTest
    test/colors.cpp
    )
  target_link_libraries(colorTest PUBLIC trace)
  ```

- `target_include_directories` specifies where to look for `colors.h`.

# Running Tests

- To run automatic tests, you need to invoke two commands in `CMakeLists.txt`:

  1. `enable_testing` enables the ability to run tests, and should be written immediately after the `project` command.

  2. `add_test` specifies which of the executable files to produce actually runs tests. (You can use it multiple times).

- In our case, we will invoke `add_test` only once to run `colorTest`.

- To run the tests, in the `build` directory, simply invoke `ctest`.

# `CMakeLists.txt`

This is the complete content of `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.12)

# Define a "project", providing a description and a programming language
project(raytracer
  VERSION 1.0
  DESCRIPTION "Hello world in C++"
  LANGUAGES CXX
  )

# Force the compiler to use the C++23 standard (or whatever you want)
set(CMAKE_CXX_STANDARD 23)

# If the compiler does not support the standard, stop!
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Turn on the support for automatic tests
enable_testing()

# This is the library. Pick the name you like the most; we use "trace"
add_library(trace
  src/colors.cpp
  )
# Help the compiler when you write "#include <colors.h>"
# See "cmake-generator-expressions(7)" in the CMake manual
target_include_directories(trace PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>
  )

# This is the program that we will run from the command line
add_executable(raytracer
  src/raytracer.cpp
  )
# The command-line program needs to be linked to the "trace" library
target_link_libraries(raytracer PUBLIC trace)

# This program runs the automatic tests on the "Color" class
add_executable(colorTest
  test/colors.cpp
  )
# The test program too needs to be linked to "trace"
target_link_libraries(colorTest PUBLIC trace)

# Here we specify that "colorTest" is a special executable, because
# it is meant to be run automatically whenever we want to check our code
add_test(NAME colorTest
  COMMAND colorTest
  )
```

---

<asciinema-player src="cast/c++-tests.cast" cols="72" rows="22" font-size="medium"></asciinema-player>

# Test Operation

- The test result must be returned as a value to the operating system.

- The most elementary possibility is to use an appropriate `return` in `main`:

  ```c++
  #include "colors.h"
  #include <cstdlib>

  int main() {
      Color c1{1.0, 2.0, 3.0};
      Color c2{5.0, 7.0, 9.0};

      return are_colors_close(Color{6.0, 9.0, 11.0}, c1 + c2)
          ? EXIT_SUCCESS : EXIT_FAILURE;
  }
  ```

- You can use
  [`abort`](https://www.cplusplus.com/reference/cstdlib/abort/?kw=abort) (in
  case of failure) or
  [`assert`](https://www.cplusplus.com/reference/cassert/assert/?kw=assert)
  (watch out for `NDEBUG`!).

# Running Tests

- Try modifying one of the tests on the `Color` type so that it fails:

  - Change the `test/colors.cpp` file
  - Go to the `build` directory and run `ctest`
  - Commit the changes
  - Send the changes to GitHub with the `git push` command

- It would be good if each group member tried to do this.

# Suggestions

- If the build does **not** fail, it is probably because the `Release` build type is used instead of `Debug`, and you used `assert` in your code.
- Solutions:
  - Change the `.yml` file to use `Debug` instead of `Release`;
  - Use `#undef NDEBUG` before `#include <cassert>` (better!);
  - Define your own `my_assert` function (even better!);
  - Use a C++ testing library. There are many good options: [doctest](https://github.com/doctest/doctest),  [Catch2](https://github.com/catchorg/Catch2/tree/v2.x), [ut](https://github.com/qlibs/ut)…
- Lesson: **always** try to make one or more tests fail!


# Hints for C\#

# Solutions and Projects

```{.graphviz im_fmt="svg" im_out="img" im_fname="project-structure-csharp"}
graph "" {
    lib [label="library (project)" shape=ellipse];
    exec [label="executable (project)" shape=box];
    test [label="tests (project)" shape=box];
    lib -- exec;
    lib -- test;
}
```

- The `dotnet` command supports the creation of _solutions_ and _projects_.

- A _progetto_ is anything that can be produced from source C\# files (executables, libraries)…

- A _solution_ is a collection of projects. Each element of the diagram is a _project_, and the whole diagram is a _solution_.

# Creating solutions/projects

- To create a solution, run `dotnet new sln`

- Projects in `dotnet` can be of three types:
  - Executables (`dotnet new console`)
  - Libraries (`dotnet new classlib`)
  - Automatic tests (`dotnet new xunit`)
- To specify that project `A` depends on `B`, write `dotnet add A reference B`
- To add new projects to a solution, use `dotnet sln add`

# Our “solution”

```sh
# Create a new solution that will include:
# 1. The library
# 2. The executable (currently printing «Hello, world!»)
# 3. The tests
dotnet new sln -o "Myraytracer"

cd Myraytracer

# 1. Create the library, named "Trace", and add it to the solution
dotnet new classlib -o "Trace"
dotnet sln add Trace/Trace.csproj

# 2. Create the executable, named "Myraytracer", and add it to the solution
dotnet new console -o "Myraytracer"
dotnet sln add Myraytracer/Myraytracer.csproj

# 3. Create the tests, named "Trace.Tests", and add them to the solution
dotnet new xunit -o "Trace.Tests"
dotnet sln add Trace.Tests/Trace.Tests.csproj

# Both the executable and the tests depend on the «Trace» library
dotnet add Myraytracer/Myraytracer.csproj reference Trace/Trace.csproj
dotnet add Trace.Tests/Trace.Tests.csproj reference Trace/Trace.csproj

# Create a .gitignore file
dotnet new gitignore
```

Do everything from the command line and then open the project in Rider: it's more instructive!

# Directory tree

- This solution has generic names for each file, so it is wise to change them into something easier to recognize.

- Rename the files so that they have the following structure:

  ```text
  Myraytracer
  ├── Myraytracer.sln
  ├── Myraytracer
  │   ├── Myraytracer.cs      <-- This was Program.cs
  │   └── Myraytracer.csproj
  ├── Trace
  │   ├── Color.cs            <-- This was Class1.cs
  │   ├── HdrImage.cs         <-- New file
  │   └── Trace.csproj
  └── Trace.Tests
      ├── ColorTests.cs       <-- This was UnitTest1.cs
      ├── HdrImageTests.cs    <-- New file
      └── Trace.Tests.csproj
  ```

# Writing tests

```csharp
// This should be put in Trace.Tests/ColorTests.cs
using System;
using Xunit;
using Trace;

namespace Trace.Tests
{
    public class ColorTests
    {
        [Fact]
        public void TestAdd()
        {
            Color a = new Color(1.0f, 2.0f, 3.0f);
            Color b = new Color(5.0f, 6.0f, 7.0f);
            // C# convention: *first* the expected value, *then* the test value
            Assert.True(Color.are_close(new Color(6.0f, 8.0f, 10.0f), a + b));
            // ...
        }
    }
}
```

You can run tests with `dotnet test`, but you can also use Rider (this is **so handy**! Refer to the slides for Kotlin.)

# Hints for Java/Kotlin

# Handling projects

- IntelliJ IDEA is based on Gradle, which is the analogous of CMake for C++.C++.

- Gradle can be programmed using Groovy (a language derived from Java) or Kotlin.

- As Java and Kotlin are highly modular, for this course there is no need to differentiate between a library and an executable.

- Therefore, you can create a project exactly like you did last week.

# Creating classes

In IntelliJ IDEA, you can create new classes via the Project window (on the left):

<center> ![](./media/kotlin-new-class.png){height=480} </center>

# The `Color` class

- In Kotlin, use _data classes_ to define `Color`: they are so easy to use!

  ```kotlin
  /** A RGB color
   *
   * @param r The level of red
   * @param g The level of green
   * @param b The level of blue
   */
  public data class Color(val r: Double, val g: Double, val b: Double) {
      // ...
  }
  ```

- Define `is_close` and operators `plus` (sum of two colors) and `times` (product between a color and a number).

# The `HdrImage` class

- Kotlin lets you to define classes in a compact form (a dream for whoever has used Java!). Here is an example:

  ```kotlin
  class HdrImage(
      val width: Int,  // Using 'val' ensures that we cannot change the width
      val height: Int, // or the height of the image once it's been created
      var pixels: Array<Color> = Array(width * height) { Color(0.0F, 0.0F, 0.0F) }
  ) {
      // Here are the methods for the class…
  }
  ```

- Be sure to understand the difference between `val` and `var`!

# Writing tests

- IntelliJ IDEA generates and handles tests automatically.

- You should use [JUnit](https://junit.org/); if the IDE asks you which version to use, pick 5.

- Check the version you are using by opening menu «File | Project structure».

---

<center> ![](./media/kotlin-project-structure.png){height=560} </center>

In this screenshot, JUnit’s version is 4.

# Creating empty tests

- Right-click on a class name and pick _Generate_.

- In the window, pick the right version for JUnit and choose the methods that you want to test. (In our case, they are `is_close`, `plus`, and `times`).

- Once you have implemented the tests using `assertTrue` and `assertFalse`, run them using the icons on the left.

---

# Generating tests

<center> ![](./media/kotlin-generate-test.png) </center>

---

# Running tests

<center> ![](./media/kotlin-run-test.png) </center>

# Hints for Rust

# Code Structure

- For today, it is not necessary for you to structure the code into complex modules.

- Create a `basictypes.rs` file in which you will define both the `Color` type and the `HdrImage` type, along with all the tests associated with them.

- You can leave the `main.rs` file intact for the moment (with the `Hello, world!` message).

- To automatically format the code, use the `cargo fmt` command.

# Type Definition

- For `Color`, derive the `Copy`, `Clone` and `Debug` traits to simplify your life:

  ```rust
  #[derive(Copy, Clone, Debug)]
  pub struct Color {
      pub r: f32,
      pub g: f32,
      pub b: f32,
  }
  ```

- For `HdrImage`, define the `pixels` member of type `Vec<Color>`.

- Also define a function `create_hdr_image(width: i32, height: i32) -> HdrImage`, which initializes `pixels` correctly.

# Tests in Rust

- Rust natively supports tests using the `#[cfg(test)]` and `#[test]` annotations.

- Tests can be executed automatically with the command

  ```
  $ cargo test
  ```

- Consult the [Rust guide](https://doc.rust-lang.org/rust-by-example/testing/unit_testing.html); a more in-depth discussion can be found in [chapter 11](https://doc.rust-lang.org/book/ch11-00-testing.html) of _The Rust Programming Language_ (Klabnik & Nichols).


# Hints for Nim

# Type Definition

- Implementing the `Color` and `HdrImage` types should be elementary.

- Make sure to use `object` and not `ref object` for Color, while for `HdrImage` it is indifferent.

- Remember that in Nim you need to export both the types and their members, using `*`:

  ```nim
  type
      Color* = object
          r*, g*, b*: float32

      HdrImage* = object
          width*, height*: int
          pixels*: Seq[Color]
  ```

# Creating `HdrImage`

- In Nim, constructors like in C++ are not needed.

- The common practice is to define a `newMyType` function that creates the `MyType` type.

- Therefore, add a `newHdrImage` procedure that accepts two parameters `width` and `height`, initialize the `pixels` field using [`newSeq`](https://nim-lang.org/docs/system.html#newSeq), and set all colors to zero (black).

# Writing Tests

- In Nim, you can use the [`assert` template](https://nim-lang.org/docs/assertions.html#assert.t%2Cuntyped%2Cstring) to run tests.

- The practice is to create Nim files inside the `tests` directory; if these files start with `t`, they are [automatically executed](https://github.com/nim-lang/nimble#tests) by the command

  ```
  $ nimble test
  ```

- To write tests for the `Color` and `HdrImage` types, create a `tests/test_basictypes.nim` file like this:

  ```nim
  import ../src/basictypes

  when isMainModule:
      assert Color(1.0, 2.0, 3.0) + Color(3.0, 4.0, 5.0) == Color(4.0, 6.0, 8.0)
      # …
  ```


# Hints for Julia

# Package Structure

- Julia natively implements the required structure type (library, executable, executable with tests):

  - Each package can be used as a library;
  - Packages can include a set of tests if they have a directory called `test` inside;
  - The script that implements `main` [seen in the previous exercise](./tomasi-ray-tracing-01b.html#/julia-main) can be used as an executable.

- Creating a new package therefore configures everything already in the required way, except for the executable.

# Creating the Package

- Create a new package with the commands seen last time:

  ```julia
  using Pkg
  Pkg.generate("Raytracer") # Upper case is customary in Julia
  Pkg.activate("Raytracer")
  ```

- Julia supports color management through [ColorTypes](https://github.com/JuliaGraphics/ColorTypes.jl) and [Colors](https://juliagraphics.github.io/Colors.jl/stable/):

  ```julia
  Pkg.add("ColorTypes")
  Pkg.add("Colors")
  ```

  This will modify `Project.toml` and add `Manifest.toml`, which should be saved in Git (look at what they contain!).

# Color Operations

- For today, there is no need to understand the difference between _value_ and _reference types_, because you will be using Colors and ColorTypes.

- The Colors library implements a series of template types:

  ```julia
  using Colors

  a = RGB(0.1, 0.3, 0.7)
  b = XYZ(0.8, 0.4, 0.2)
  println(convert(XYZ, a)) # Convert a from RGB to XYZ space
  ```

- However, the library does not implement the color operations that interest us (sum, difference, product, comparison). Implement them yourself in the `src/Raytracer.jl` file (the file name depends on your project name).

# Complications

- The types in ColorTypes are [_parametric_](https://docs.julialang.org/en/v1/manual/types/#Parametric-Types) (like templates in C++): the `RGB` type is actually `RGB{T}`, with `T` as a parameter.

- You need to redefine the fundamental operations `+`, `-`, `*` and `≈` (`\approx`), which in Julia are present in the `Base` package.

  You will need to write something like this in `src/Raytracer.jl`:

  ```julia
  import ColorTypes
  import Base.:+, Base.:*, Base.:≈

  # To make this work, first define the product "scalar * color"
  Base.:*(c::ColorTypes.RGB{T}, scalar) where {T} = scalar * c
  ```

# Creating Tests

- To implement the tests, create a `test/runtests.jl` file, so that the directory structure is as follows:

  ```sh
  $ tree Raytracer
  Raytracer
  ├── Manifest.toml
  ├── Project.toml
  ├── src
  │   └── Raytracer.jl
  └── test
      └── runtests.jl
  ```

- To write tests, you need to add the [Test]() library:

  ```julia
  Pkg.add("Test")
  ```

# How to Write Tests

- In the `runtests.jl` file, you need to write the test procedures. The Test library implements the `@testset` (groups tests) and `@test` macros:

  ```julia
  using Raytracer # Put the name you chose
  using Test

  @testset "Colors" begin
      # Put here the tests required for color sum and product
      @test 1 + 1 == 2
  end
  ```

- To run them from the REPL, write

  ```julia
  Pkg.test()
  ```

# Running Tests

<asciinema-player src="cast/julia-tests.cast" cols="72" rows="22" font-size="medium"></asciinema-player>

# The `Manifest.toml` File

- Julia uses the `Project.toml` file to indicate general information about the package, and it can be edited.
- The `Manifest.toml` file is generated automatically, and it pins the version numbers of the dependencies used by your package.
- It is essential to add the `Project.toml` file to Git.
- For `Manifest.toml` there are two possibilities:
  1. If you believe it is **essential** that every user uses exactly your versions of the dependencies, add it;
  2. If you want to guarantee more versatility, exclude it from Git (thus adding a line to `.gitignore`).

# Hints for D

# Definition of the types

- Define `Color` as a `struct` and `HdrImage` as a `class`; for `Color`, include defaults:

  ```d
  struct Color {
    float r = 0, g = 0, b = 0;
  };
  ```

- Define `pixels` in `HdrImage` as a [dynamic array](https://dlang.org/spec/arrays.html#dynamic-arrays)

- Define a constructor for `HdrImage` that requires `width` ed `height` and initializes `pixels` [allocating the correct length](https://dlang.org/spec/arrays.html#length-initialization). Then set the color of every pixel to black.

# Tests in D

- D offers excellent support for tests via the keyword `unittest` (it’s awesome!)

- It’s not needed to define tests in separate files, as it is the case for C++ and C\#.

- To run the tests, execute the command

  ```
  $ dub test
  ```

- See the documentation for more information: [Unit tests](https://dlang.org/spec/unittest.html)

---
title: "Laboratory 2"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
---
