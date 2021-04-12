set terminal svg
set xlabel "Normalized input"
set ylabel "Normalized output"
set key left top
plot [0:1] x with lines t "γ = 1.0" lt rgb "#ad3434", \
           x**1.6 with lines t "γ = 1.6" lt rgb "#34ad34", \
           x**2.2 with lines t "γ = 2.2" lt rgb "#3434ad"