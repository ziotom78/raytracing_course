# Writing LDR Images

# Program Interface

-   Today we will implement the code for our program (`main.py` in the Python version).

-   The program will function as follows:

    ```text
    $ ./main.py input_file.pfm 0.3 1.0 output_file.png
    File 'input_file.pfm' has been read from disk
    File 'output_file.png' has been written to disk
    $
    ```

-   The goal is to convert a PFM file into a PNG file (or your preferred LDR format). The values `0.3` and `1.0` refer to the [scale factor](tomasi-ray-tracing-05b.html#/normalization) $a$ and $\gamma$, respectively.

# Implementation

The tasks to be performed on the code are the following:

1.  Define a function that calculates the luminosity of a `Color` object;
2.  Define a function that calculates the average luminosity of an `HdrImage`;
3.  Define a function that normalizes the values of an `HdrImage` using a certain average luminosity, optionally passed as an argument;
4.  Define a function that applies the correction for light sources;
5.  Implement the `main` function in the application code.

# Luminosity (1/2)

-   Let's add a simple `luminosity` method to the `Color` class, which returns the luminosity value suggested by Shirley & Morley:

    ```python
    class Color:
        # ...

        def luminosity(self):
            return (max(self.r, self.g, self.b) + min(self.r, self.g, self.b)) / 2
    ```

-   If the equivalent of `max` and `min` in your language only accepts two parameters (e.g., `minOf` and `maxOf` in Kotlin), you can use the equivalence

    $$
    \max\left\{a, b, c\right\} \equiv \max\bigl\{\max\left\{a, b\right\}, c\bigr\}.
    $$

# Luminosity (2/2)

-   Some tests for `Color.luminosity` are also needed:

    ```python
    def test_luminosity():
        col1 = Color(1.0, 2.0, 3.0)
        col2 = Color(9.0, 5.0, 7.0)

        assert pytest.approx(2.0) == col1.luminosity()
        assert pytest.approx(7.0) == col2.luminosity()
    ```

-   The `pytest.approx()` method is part of the `pytest` library and corresponds to the `is_close` function you implemented some time ago.

# Average Luminosity (1/2)

```python
class HdrImage:
    # ...

    def average_luminosity(self, delta=1e-10):
        cumsum = 0.0
        for pix in self.pixels:
            cumsum += math.log10(delta + pix.luminosity())

        return math.pow(10, cumsum / len(self.pixels))
```

# Average Luminosity (2/2)

```python
def test_average_luminosity():
    img = HdrImage(2, 1)

    img.set_pixel(0, 0, Color(  5.0,   10.0,   15.0))  # Luminosity: 10.0
    img.set_pixel(1, 0, Color(500.0, 1000.0, 1500.0))  # Luminosity: 1000.0

    print(img.average_luminosity(delta=0.0))
    assert pytest.approx(100.0) == img.average_luminosity(delta=0.0)
```

# Normalization (1/3) {#normalization}

-   The `normalize_image` function calculates the average brightness of an image according to the [corresponding equation](tomasi-ray-tracing-05b.html#/normalization).

-   The function should accept the value of $a$ as an input parameter (in `factor`):

    ```python
    def normalize_image(self, factor, luminosity=None):
        if not luminosity:
            luminosity = self.average_luminosity()

        for i in range(len(self.pixels)):
            self.pixels[i] = self.pixels[i] * (factor / luminosity)
    ```

# Normalization (2/3)

-   It’s better to ask for the luminosity instead of calculating it:

    -   In tests, it can be convenient to pass different values for the brightness;
    -   The user might want to specify this value.

-   If your language supports optional types, you can call the function `average_luminosity` if the brightness parameter is null:

    ```csharp
    // This is C#; in Kotlin it's almost the same.
    public void NormalizeImage(float factor, float? luminosity = null)
    {
        // In Kotlin use "?:" instead of "??"
        var lum = luminosity ?? AverageLuminosity();
        for (int i = 0; i < pixels.Length; ++i) { /* ... */ }
    }
    ```

# Normalization (3/3)

```python
def test_normalize_image():
    img = HdrImage(2, 1)

    img.set_pixel(0, 0, Color(  5.0,   10.0,   15.0))
    img.set_pixel(1, 0, Color(500.0, 1000.0, 1500.0))

    img.normalize_image(factor=1000.0, luminosity=100.0)
    assert img.get_pixel(0, 0).is_close(Color(0.5e2, 1.0e2, 1.5e2))
    assert img.get_pixel(1, 0).is_close(Color(0.5e4, 1.0e4, 1.5e4))
```

# Bright Spots (1/2) {#bright-spots}

```python
def _clamp(x: float) -> float:
    return x / (1 + x)

class HdrImage:
    # ...

    def clamp_image(self):
        for i in range(len(self.pixels)):
            self.pixels[i].r = _clamp(self.pixels[i].r)
            self.pixels[i].g = _clamp(self.pixels[i].g)
            self.pixels[i].b = _clamp(self.pixels[i].b)
```

# Bright Spots (2/2)

```python
def test_clamp_image():
    img = HdrImage(2, 1)

    img.set_pixel(0, 0, Color(0.5e1, 1.0e1, 1.5e1))
    img.set_pixel(1, 0, Color(0.5e3, 1.0e3, 1.5e3))

    img.clamp_image()

    # Just check that the R/G/B values are within the expected boundaries
    for cur_pixel in img.pixels:
        assert (cur_pixel.r >= 0) and (cur_pixel.r <= 1)
        assert (cur_pixel.g >= 0) and (cur_pixel.g <= 1)
        assert (cur_pixel.b >= 0) and (cur_pixel.b <= 1)
```


# Dependency Management

# Dependency Management

-   Implementing code to save an image in one of the most common LDR formats (PNG, JPEG, TIFF, WebP) would be very interesting, but very complex!
-   We will implement this functionality by relying on an external library.
-   In this way, we will learn how the language we are using allows us to manage dependencies.

# System Libraries

<center>![](media/dependencies-simple.svg)</center>

-   This kind of library is usually installed using `sudo` in some way, such as `./configure && make && sudo make install`.

-   Example: installing ROOT on your system to work on TNDS exercises!

# System Libraries

However, it often happens that you have to use *incompatible* libraries in your code! Suppose we have numerous oscilloscopes in an electronics lab, and we use the `oscilloscope` library to analyze their measurements:

-   So far we have used version 2.4 to write a lot of analysis code that we use regularly.

-   However, version 3.0 of `oscilloscope` has been out for a while now, which has interesting new features, but I haven't upgraded yet because it's incompatible with version 2.4!

-   Version 4.0 is about to be released, even more powerful, but it will no longer support one of my old oscilloscopes, which I still need.


# Local Libraries

Local libraries solve these problems because they are not installed system-wide, but are linked to a single *repository*:

<center>![](media/dependencies-complex.svg)</center>

-   Example: copy of a *header-only* library into your C++ project.

-   Example: [*virtual environment*](https://docs.python.org/3/tutorial/venv.html) in Python.

# Dependency Management

-   Almost all languages support "local" library management.

-   These features are usually implemented in the programs you have used so far to create projects (`nimble`, `gradle`, `dotnet`, `dub`, `cargo`...).

-   So choose a library that supports *writing* LDR images and import it into your project as a **local** dependency (no `sudo`!).

-   The use of local libraries will help us a lot when we deal with *continuous integration*.

# LDR Image Production

# HDR→LDR Conversion (1/3)

-   Once `normalize_image` and `clamp_image` have been applied, all RGB components of the colors in the matrix will be in the range [0, 1].
-   At this point, the conversion to the sRGB space takes place via the [usual formula with γ](tomasi-ray-tracing-02a.html#/from-rgb-to-srgb).
-   The result of the conversion is a matrix that must be saved in an LDR graphic format: PNG, JPEG, WebP...
-   For saving, you need to choose an appropriate library.

# HDR→LDR Conversion (2/3)

| Language                                              | Libraries                                                                                              |
|-------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| C\#                                                   | [ImageSharp](https://docs.sixlabors.com/articles/imagesharp/?tabs=tabid-1)                             |
| D                                                     | [imageformats](https://code.dlang.org/packages/imageformats)                                           |
| Java/Kotlin                                           | [javax.imageio](https://docs.oracle.com/javase/8/docs/api/javax/imageio/ImageIO.html) (già installato) |
| Nim                                                   | [simplepng](https://github.com/jrenner/nim-simplepng)                                                  |
| Python                                                | [Pillow](https://pillow.readthedocs.io/en/stable/)                                                     |
| Rust                                                  | [image](https://crates.io/crates/image)                                                                |

You can search for other libraries, but be sure to pick a pixel-based one!

# What do we need?

Choose an LDR library that has these characteristics:

-   Creation of an image by specifying the number of columns (`width`) and the number of rows (`height`)
-   Setting the sRGB value of a pixel given its `x` and `y` coordinates
-   Saving the image in a common graphic format
-   Pay close attention to the coordinate system: is the pixel at `(0, 0)` at the top left? Bottom left? Or…?

# HDR→LDR Conversion (3/3)

```python
class HdrImage:
    # ...

    def write_ldr_image(self, stream, format, gamma=1.0):
        from PIL import Image
        img = Image.new("RGB", (self.width, self.height))

        for y in range(self.height):
            for x in range(self.width):
                cur_color = self.get_pixel(x, y)
                img.putpixel(xy=(x, y), value=(
                        int(255 * math.pow(cur_color.r, 1 / gamma)),
                        int(255 * math.pow(cur_color.g, 1 / gamma)),
                        int(255 * math.pow(cur_color.b, 1 / gamma)),
                ))

        img.save(stream, format=format)
```

# The `main` function (1/2)

```python
from dataclasses import dataclass

@dataclass
class Parameters:
    input_pfm_file_name: str = ""
    factor:float = 0.2
    gamma:float = 1.0
    output_png_file_name: str = ""

    def parse_command_line(self, argv):
        if len(sys.argv) != 5:
            raise RuntimeError("Usage: main.py INPUT_PFM_FILE FACTOR GAMMA OUTPUT_PNG_FILE")

        self.input_pfm_file_name = sys.argv[1]

        try:
            self.factor = float(sys.argv[2])
        except ValueError:
            raise RuntimeError(f"Invalid factor ('{sys.argv[2]}'), it must be a floating-point number.")

        try:
            self.gamma = float(sys.argv[3])
        except ValueError:
            raise RuntimeError(f"Invalid gamma ('{sys.argv[3]}'), it must be a floating-point number.")

        self.output_png_file_name = sys.argv[4]
```

(Instead of using global variables for the parameters read from `argv`, I use a `struct` and pass it to other functions: it’s easier to write tests!)

# The `main` function (2/2)

```python
def main(argv):
    parameters = Parameters()
    try:
        parameters.parse_command_line(argv)
    except RuntimeError as err:
        print("Error: ", err)
        return

    # You should put a try…except block here and produce a nice error
    # message is the image couldn't be saved
    with open(parameters.input_pfm_file_name, "rb") as inpf:
        img = hdrimages.read_pfm_image(inpf)

    print(f'File "{parameters.input_pfm_file_name}" has been read from disk.')

    img.normalize_image(factor=parameters.factor)
    img.clamp_image()

    # Same as above: use try…except to produce a human-readable message
    # if something goes wrong
    with open(parameters.output_png_file_name, "wb") as outf:
        img.write_ldr_image(stream=outf, format="PNG", gamma=parameters.gamma)

    print(f'File "{parameters.output_png_file_name}" has been written to disk.')
```


# What to do today

# What to do today

1. Define a function that calculates the luminosity of a `Color` object and the average luminosity of an `HdrImage` and add tests;
2. Define a function that normalizes the values of an `HdrImage` using a certain average luminosity, optionally passed as an argument and add tests;
3. Define a function that applies the correction for light sources and add tests;
4. Implement the `main` function in the application code, so that it accepts 4 arguments: the PFM file to read, the value of $a$, the value of γ, and the name of the PNG/JPEG/etc. file to create.
5. Add *docstrings* to those classes, methods, functions, types, etc. that you feel need them, but make sure that each comment **is not pedantic**.
6. Choose together a [usage license](./tomasi-ray-tracing-04a.html#/licenses).

# Reference Images

- If you need a realistic PFM image, you can use [memorial.pfm](http://www.pauldebevec.com/Research/HDR/memorial.pfm).

- There is also the site [Scenes for pbrt-v3](https://www.pbrt.org/scenes-v3.html).

# Hints for C++

# Hints for C++

-   Many code examples shown today were in C++, so you can start from them.

-   [Awesome C++](https://github.com/fffaraz/awesome-cpp) is a treasure trove of C++ libraries. Have a look at the section [Image processing](https://github.com/fffaraz/awesome-cpp?tab=readme-ov-file#image-processing) to find a viable image processing library to use in your project.

-   To document code, the most used tool is [Doxygen](https://github.com/doxygen/doxygen), but there are other choices available (See again the [section “Documentation” in the Awesome C++ website](https://github.com/fffaraz/awesome-cpp?tab=readme-ov-file#documentation).)


# Hints for D/Nim/Rust

# Hints for D/Nim/Rust

- You can install libraries in your project with your package manager:

    - In Nim, use `nimble install NAME`;
    - In Cargo, use `cargo` following [the guide](https://doc.rust-lang.org/cargo/guide/dependencies.html);
    - In D, use `dub add NAME`.

- These libraries will be installed as dependencies of your program, and not system-wide.

# Hints for Java/Kotlin

# Hints for Java/Kotlin

- Unlike Python, C++, C# and Julia, both Java and Kotlin provide support for PNG, JPEG, BMP and GIF images through the standard Java libraries.

- You need the classes `java.awt.image.BufferedImage` (LDR image) and `javax.imageio.ImageIO` (the class that implements the methods for reading/writing LDR images to files).

# Encoding Color

- The `BufferedImage` class allows you to encode color in many different ways. If you use `TYPE_INT_RGB`, the color is not an RGB triplet but a 32-bit integer with this format:

    ```
    00000000 rrrrrrrr gggggggg bbbbbbbb
    ```

    where `r` are the bits for red, `g` for green and `b` for blue. Usually colors are indicated using hexadecimal notation, because this way they are always six digits, e.g. `0x12FA51`.

- If `r`, `g` and `b` are bytes in the range [0, 255], you can use one of these two formulas:

    ```
    r * 65536 + g * 256 + b                    (r shl 16) + (g shl 8) + b
    ```

# Kotlin Code Example

```kotlin
fun main(args: Array<String>) {
    val width = 800
    val height = 600
    val ldrImage = BufferedImage(width, height, BufferedImage.TYPE_INT_RGB)
    for (y in 0 until height) {
        for (x in 0 until width) {
            // 0xFF0000 corresponds to sRGB(255, 0, 0): the image will be
            // painted uniformly with a bright red shade
            ldrImage.setRGB(x, y, 0xFF0000)
        }
    }
    // Save the image to the file specified on the command line
    ImageIO.write(args[0], "PNG", stream)
}
```

# Command Line

- Java and Kotlin have a somewhat «baroque» way of handling command line parameters.

- Your executable *cannot* be run like a normal Python/C++/C# executable:

    ```text
    $ ./main.py input_file.pfm 0.3 1.0 output_file.png
    ```

    because it is compiled for the JVM.

- If you are using Kotlin, you have to go through `gradlew`, which requires that parameters be passed through `--args`:

    ```text
    ./gradlew run --args="input_file.pfm 0.3 1.0 output_file.png"
    ```

# Guidelines for C#

# Importing Libraries

-   The ImageSharp library supports many formats: JPEG, PNG, BMP, GIF, and TGA (an older format that we didn't cover in the theory lesson).

-   In C#, you can automatically download and install libraries and specify that they should be used in your projects without the need to modify Makefiles or use `root-config`, `pkg-config`, or similar tools.

-   Add the [SixLabors.ImageSharp](https://docs.sixlabors.com/index.html) package to the class library (which you may have named `Tracer`):

    ```text
    $ dotnet add package SixLabors.ImageSharp
    ```

# Saving PNG Files

```csharp
// Create a sRGB bitmap
var bitmap = new Image<Rgb24>(Configuration.Default, width, height);

// The bitmap can be used as a matrix. To draw the pixels in the bitmap
// just use the syntax "bitmap[x, y]" like the following:
bitmap[SOMEX, SOMEY] = new Rgb24(255, 255, 128); // Three "Byte" values!

// Save the bitmap as a PNG file
using (Stream fileStream = File.OpenWrite("output.png")) {
    bitmap.Save(fileStream, new PngEncoder());
}
```

---
title: "Laboratory 4"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...
