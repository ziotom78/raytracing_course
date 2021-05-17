set terminal svg font "Helvetica,18"
set xlabel "x"
set ylabel "y"
set key left top
plot [0:3.14159] sqrt(x) * sin(x) lw 5 lt rgb "#000000" t "f(x)", \
                 sqrt(x) * 2 lw 5 lt rgb "#a01010" t "f(x) / p(x)", \
                 0.5 * sin(x) lw 5 lt rgb "#"10a010" t "p(x)"