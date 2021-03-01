PANDOC = /usr/bin/pandoc

.phony: all

all: \
	tomasi-ray-tracing-04a-raytracing.html \
	tomasi-ray-tracing-03b.html \
	tomasi-ray-tracing-03a-images.html \
	tomasi-ray-tracing-02b-tests.html \
	tomasi-ray-tracing-02a-colors.html \
	tomasi-ray-tracing-01b-github.html \
	tomasi-ray-tracing-01a-rendering-equation.html \
	index.html

index.html: index.md
	$(PANDOC) --standalone -o $@ $<

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
		-V slideNumber=true \
		-V background-image=./media/background.png \
		-V width=1440 \
		-V height=810 \
		-f markdown+tex_math_single_backslash \
		-t revealjs \
		-o $@ $<
