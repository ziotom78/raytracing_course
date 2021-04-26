size(0,100);
import three;
currentlight=Viewport;

draw(O--1.5X, gray); //x-axis
draw(O--1.5Y, gray); //y-axis
draw(O--1.5Z, gray); //z-axis

label("$x$", 1.5X + 0.2Z);
label("$y$", 1.5Y + 0.2Z);
label("$z$", 1.5Z + 0.2X);

path3 xy = ((2, 2, -0.01) -- (-2, 2, -0.01) -- (-2, -2, -0.01) -- (2, -2, -0.01) -- cycle);

draw(surface(xy), green, nolight);
draw(shift(0, 1, 2) * scale3(0.1) * unitsphere, white);
draw((0, 0, 0) -- (0, 1, 2) * 0.75, black, Arrow3);
draw(unithemisphere, gray + opacity(0.7));