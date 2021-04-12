size(0,100);
import three;
currentlight=Viewport;

draw(O--2X, gray); //x-axis
draw(O--2Y, gray); //y-axis
draw(O--2Z, gray); //z-axis

real[][] rot = rotate(15, X) * rotate(30, Y);
path3 pl = ((2, -2, 0) -- (-2, -2, 0) -- (-2, 2, 0) -- (2, 2, 0) -- cycle);
draw(surface(rot * pl), green + opacity(0.2));
draw(rot * pl, black);
draw(rot * ((0, 0, 0) -- X), blue, Arrow3);
draw(rot * ((0, 0, 0) -- (0.3 * (X + 2Y))), red, Arrow3);