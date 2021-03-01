PANDOC = /usr/bin/pandoc

.phony: all

all: \
	tomasi-ray-tracing-03b.html \
	tomasi-ray-tracing-03a.html \
	tomasi-ray-tracing-02b.html \
	tomasi-ray-tracing-02a.html \
	tomasi-ray-tracing-01b.html \
	tomasi-ray-tracing-01a.html

%.html: %.md
	$(PANDOC) \
	    	--standalone \
		--filter pandoc-plot \
		--filter pandoc-graphviz \
		--css ./css/custom.css \
		--css ./css/asciinema-player.css \
		-A asciinema-include.html \
		--katex \
		-V theme=white \
		-V progress=true \
		-V slidenum=true \
		-V width=1440 \
		-V height=810 \
		-f markdown+tex_math_single_backslash \
		-t revealjs \
		-o $@ $<
