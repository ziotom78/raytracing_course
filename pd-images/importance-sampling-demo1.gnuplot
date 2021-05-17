set terminal svg font "Helvetica,18"
set xlabel "x"
set ylabel "y"
set key left top
plot [0:3.14159] sqrt(x) lw 2 lt rgb "#33c013" t "√x", \
                 sin(x) lw 2 lt rgb "#c03333" t "sin x", \
                 sqrt(x) * sin(x) lw 5 lt rgb "#000000" t "f(x)"