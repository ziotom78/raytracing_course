size(0,100);
import three;
currentlight=Viewport;

draw(O--2X, gray); //x-axis
draw(O--Y, gray); //y-axis
draw(O--Z, gray); //z-axis

label("$x$", 2X + 0.2Z);
label("$y$", Y + 0.2Z);
label("$z$", Z + 0.2X);

path3 xy = ((1, -1, -0.5) -- (1, -1, 0.5) -- (1, 1, 0.5) -- (1, 1, -0.5) -- cycle);

draw(surface(xy), gray + opacity(0.7));
draw((0, 0, 0) -- (1, 0, 0), RGB(110, 110, 215), Arrow3);
draw((1, 0, 0) -- (1, -1, 0), RGB(215, 110, 110), Arrow3);
draw((1, 0, 0) -- (1, 0, 0.5), RGB(110, 215, 110), Arrow3);

draw(scale3(0.02) * unitsphere, black);

label("$P$", (0, 0.2, 0.2));
label("$\vec d$", (0.5, 0.2, 0.2));
label("$\vec r$", (1.0, -1.2, 0));
label("$\vec u$", (1.0, 0, 0.7));