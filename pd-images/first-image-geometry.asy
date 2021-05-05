size(0,100);
import three;
currentlight=Viewport;

// Spheres on the vertexes of the cube
draw(shift( 0.5,  0.5,  0.5) * scale3(0.1) * unitsphere, white);
draw(shift(-0.5,  0.5,  0.5) * scale3(0.1) * unitsphere, white);
draw(shift( 0.5, -0.5,  0.5) * scale3(0.1) * unitsphere, white);
draw(shift(-0.5, -0.5,  0.5) * scale3(0.1) * unitsphere, white);
draw(shift( 0.5,  0.5, -0.5) * scale3(0.1) * unitsphere, white);
draw(shift(-0.5,  0.5, -0.5) * scale3(0.1) * unitsphere, white);
draw(shift( 0.5, -0.5, -0.5) * scale3(0.1) * unitsphere, white);
draw(shift(-0.5, -0.5, -0.5) * scale3(0.1) * unitsphere, white);

// Two additional spheres
draw(shift( 0.0,  0.0, -0.5) * scale3(0.1) * unitsphere, white);
draw(shift( 0.0,  0.5,  0.0) * scale3(0.1) * unitsphere, white);

// A wireframe to suggest the structure of the cube
path3 square = (
    ( 0.5,  0.5,  0.0) --
    (-0.5,  0.5,  0.0) --
    (-0.5, -0.5,  0.0) --
    ( 0.5, -0.5,  0.0) -- cycle);

draw(shift(0.0, 0.0,  0.5) * square, black);
draw(shift(0.0, 0.0, -0.5) * square, black);
draw(rotate(90, X) * shift(0.0, 0.0,  0.5) * square, black);
draw(rotate(90, X) * shift(0.0, 0.0, -0.5) * square, black);
draw(rotate(90, Y) * shift(0.0, 0.0,  0.5) * square, black);
draw(rotate(90, Y) * shift(0.0, 0.0, -0.5) * square, black);

// The screen
path3 screen = ((-1, -1, -0.5) -- (-1, -1, 0.5) -- (-1, 1, 0.5) -- (-1, 1, -0.5) -- cycle);

draw(surface(screen), gray + opacity(0.7));

// The observer
triple observer_pos = (-2.0, 0.0, 0.0);
draw(shift(observer_pos) * scale3(0.05) * unitsphere, white);

draw(observer_pos -- (-1, -1, -0.5), gray);
draw(observer_pos -- (-1, -1,  0.5), gray);
draw(observer_pos -- (-1,  1,  0.5), gray);
draw(observer_pos -- (-1,  1, -0.5), gray);

// Axes
draw(O--1.5X, gray); //x-axis
draw(O--1.5Y, gray); //y-axis
draw(O--1.5Z, gray); //z-axis

label("$x$", 1.5X + 0.2Z);
label("$y$", 1.5Y + 0.2Z);
label("$z$", 1.5Z + 0.2X);