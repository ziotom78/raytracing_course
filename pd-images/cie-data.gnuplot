set terminal svg
set xlabel "Wavelength [nm]"
set ylabel "Pure number"
plot "cie_data.txt" using 1:2 with lines lw 2 lt rgb "#3434ad" t 'X', \
     "" using 1:3 with lines lw 2 lt rgb "#34ad34" t 'Y', \
     "" using 1:4 with lines lw 2 lt rgb "#ad3434" t 'Z'