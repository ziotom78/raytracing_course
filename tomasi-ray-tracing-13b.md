# Syntactic and lexical analysis

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

This is an example of the grammar that we want to parse.

# Structure of the *Parser*

-   Our *parser* must read the description of a scene using an `InputStream` and allocate memory for several objects:

    -   An instance of the type `World`;
    -   The definition of the observer;
    -   A table containing all the instances of `Material` defined in the scene, together with their name. (E.g., `sky_material` in our canonical example);
    -   A table containing all the `float` variables.

-   The table with materials and `float` variables will not be needed to render the scene, but it might be useful for printing a table to the console or to debug the code.

# The `Scene` type

-   We will save the results of the parsing stage in a new type, `Scene`.

-   In [pytracer](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L329L336), the type has the following definition:

    ```python
    class Scene:
        """A scene read from a scene file"""
        materials: Dict[str, Material] = field(default_factory=dict)
        world: World = World()
        camera: Union[Camera, None] = None
        float_variables: Dict[str, float] = field(default_factory=dict)
        overridden_variables: Set[str] = field(default_factory=set)
    ```

# The `expect_*` functions

-   In our grammar, it is often the case that a symbol, identifier, or keyword is **mandatory** at some point in the language.

-   It is handy to implement functions like `expect_symbol`, `expect_number`, …, to handle the error condition where the token is of an unexpected type. Example:

    ```python
    def expect_symbol(s: InputStream, symbol: str):
        """Read a token from `input_file` and check that it matches `symbol`."""
        token = input_file.read_token()
        if not isinstance(token, SymbolToken) or token.symbol != symbol:
            raise GrammarError(token.location, f"got '{token}' instead of '{symbol}'")
    ```

# The `expect_keyword` function

-   It is usually the case that the grammar expect a precise symbol at some point, e.g., a comma. For keywords, our grammar often lets many different choices.

-   For instance, when defining a BRDF, the grammar either expects `diffuse` or `specular`.

-   The function [`expect_keywords`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L346-L358) should accept a **list** of permitted keywords, instead of just one. (Usually this is handy for symbols too, but in our grammar this is useless: every time a symbol is expected, its kind is uniquely determined.)

# List of functions `expect_*`

-   [Pytracer](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L339-L396) implements these functions:

    #.   `expect_symbol(s: InputStream, symbol: str)`
    #.   `expect_keywords(s: InputStream, keywords: List[KeywordEnum]) -> KeywordEnum`
    #.   `expect_number(s: InputStream, scene: Scene) -> float`
    #.   `expect_string(s: InputStream) -> str`
    #.   `expect_identifier(s: InputStream) -> str`

-   Obviously, you have complete freedom to adapt this approach according to your taste!

# `expect_number`

-   The function [`expect_number`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L361-L374) is slightly more complex, because it must accept both *literal numbers* and variables:

    ```python
    def expect_number(s: InputStream, scene: Scene) -> float:
        token = input_file.read_token()
        if isinstance(token, LiteralNumberToken):
            return token.value
        elif isinstance(token, IdentifierToken):
            variable_name = token.identifier
            if variable_name not in scene.float_variables:
                raise GrammarError(token.location, f"unknown variable '{token}'")
            return scene.float_variables[variable_name]

        raise GrammarError(token.location, f"got '{token}' instead of a number")
    ```

-   To handle variables, the function must accept an instance to `Scene`.

# The `parse_*` functions

-   The functions [`parse_*`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L399-L616) are built upon the `expect_*` functions and interpret *lists* of tokens. For instance, Pytracer implements [`parse_color`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L411-L420) in this way:

    ```python
    def parse_color(s: InputStream, scene: Scene) -> Color:
        expect_symbol(input_file, "<")
        red = expect_number(input_file, scene)
        expect_symbol(input_file, ",")
        green = expect_number(input_file, scene)
        expect_symbol(input_file, ",")
        blue = expect_number(input_file, scene)
        expect_symbol(input_file, ">")
        return Color(red, green, blue)
    ```

-   [`expect_number`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L361-L374) lets to use `float` variables for the RGB components.

# List of functions `parse_*`

#.  ```parse_vector(s: InputStream, scene: Scene) -> Vec```
#.  ```parse_color(s: InputStream, scene: Scene) -> Color```
#.  ```parse_pigment(s: InputStream, scene: Scene) -> Pigment```
#.  ```parse_brdf(s: InputStream, scene: Scene) -> BRDF```
#.  ```parse_material(s: InputStream, scene: Scene) -> Tuple[str, Material]```
#.  ```parse_transformation(input_file, scene: Scene)```
#.  ```parse_sphere(s: InputStream, scene: Scene) -> Sphere```
#.  ```parse_plane(s: InputStream, scene: Scene) -> Plane```
#.  ```parse_camera(s: InputStream, scene) -> Camera```

# The function `parse_scene`

-   The function [`parse_scene`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L571-L616) is at the highest level: it must interpret the scene and create an instance of `Scene`.

    ```python
    parse_scene(s: InputStream) -> Scene
    ```

-   In the EBNF grammar we saw last time, a scene is a list of zero or more definitions of `float`/materials/spheres/planes/observers (`scene ::= declaration*`). The best option is to implement a `while` loop.

-   The same applies to recursive EBNF functions like `transformation`. The latter must use *look-ahead*.


# *Look-ahead* of tokens

# LL(1) grammars

-   During the last class, we stressed that our grammar is of type LL(1): to correctly parse the tokens, sometimes we need to “peek” the next one before actually reading it.

-   This function can be implemented in `InputStream`. Pytracer uses the method [`unread_token`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L323-L326), which uses the data member [`saved_token`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L181).

---

```python
class InputStream:
    def __init__(self, stream, file_name="", tabulations=8):
        # …

        self.saved_token: Union[Token, None] = None

    def read_token(self) -> Token:
        if self.saved_token:
            result = self.saved_token
            self.saved_token = None
            return result

        # Continue as usual
        # …

    def unread_token(self, token: Token):
        """Pretend that `token` was never read from `input_file`"""
        assert not self.saved_token
        self.saved_token = token
```

# The `main` function

# From `demo` to `render`

-   So far, the `main` function in your program accepted two verbs:

    #.  `pfm2png`, to apply *tone mapping* to HDR images;
    #.  `demo`, to generate a sample image.

-   Today you will add a new verb, `render`, which must accept a file name from the command line.

-   It would be nice to add a `examples` folder in your repository, containing one or more sample scenes. In this case, the `demo` verb becomes redundant, and if you prefer you can remove it.

# Animations

-   The [`main`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/main.py#L72-L192) in Pytracer enables a new feature that is handy for animations: you can define variables from the command line. For instance:

    ```
    ./main --declare-float=clock:150.0 examples/demo.txt
    ```

    The switch [`--declare-float`](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/main.py#L118-L124) declares a variable `clock` with the value 150.0.

-   This feature alone cannot create animations, but you can use it in a iteration:

    ```
    for angle in $(seq 0 359); do
        ./main --declare-float=clock:$angle --pfm-output=image$angle.pfm examples/demo.txt
    done
    ```

# Overwriting variables

-   To make the program easier to use, Pytracer lets the user to **overwrite** the value of a variable like `clock`, if this is already defined in the input file (in this case, `examples/demo.txt`).

-   This means that the scene file can contain the following definition:

    ```python
    float clock(150.0)
    ```

    If the user calls the program with `--declare-float=clock:0.0`, the definition in the file is ignored and the value 0 is used instead of 150. The advantage is that the scene can be compiled without errors even if the user forgets to define `clock` on the command line.

# Overwriting variables

-   We have a chicken-egg problem. Command line parameters are interpreted *before* the scene file is interpreted, but variables are created during the parsing stage! If we define `clock` both on the command line and in the file, we will raise an error (duplicated declaration).

-   There are a few possible solutions:

    #.   Mark the variables defined on the command line with a Boolean switch. When variables are defined again during parsing, no error is raisen if this flag is `True`.
    #.   When defining a variable, the code can check if the value was defined from the command line. ([This is the approach used by Pytracer](https://github.com/ziotom78/pytracer/blob/03225baa510d97c004f8165609e590b4f5849de2/scene_file.py#L595-L601).)


# What to do today

# What to do today

#.  Keep working in the `scenefiles` *branch*;
#.  Modify `InputStream` to support *look-ahead* of tokens;
#.  Create the functions `expect_*` and `parse_*`;
#.  Change the verb `demo` with `render` and make it read the scene from a file;
#.  Create a folder `examples` and fill it with one or more scenes;
#.  Update the documentation and the `CHANGELOG`;
#.  Release version `1.0`: cheers!


---
title: "Laboratory 13"
subtitle: "Calcolo numerico per la generazione di immagini fotorealistiche"
author: "Maurizio Tomasi <maurizio.tomasi@unimi.it>"
...
