size(0,100);
import three;
currentlight=Viewport;

for(int i = 0; i < 1000; ++i) {
    real x1 = unitrand();
    real x2 = unitrand();
    
    real theta = acos(sqrt(1 - x1));
    real phi = 2 * 3.14159 * x2;
    
    triple point = (sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));
    
    draw(shift(point) * scale3(0.01) * unitsphere, black);
}

// Axes
draw((-1.5X)--1.5X, gray); //x-axis
draw((-1.5Y)--1.5Y, gray); //y-axis
draw((-1.5Z)--1.5Z, gray); //z-axis

label("$x$", 1.5X + 0.2Z);
label("$y$", 1.5Y + 0.2Z);
label("$z$", 1.5Z + 0.2X);