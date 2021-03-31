PANDOC = /usr/bin/pandoc
JS_FILES = \
	./js/quantization.js

.phony: all

all: \
	tomasi-ray-tracing-06a-geometry.html \
	tomasi-ray-tracing-05b-external-libraries.html \
	tomasi-ray-tracing-05a-compression.html \
	tomasi-ray-tracing-04b-reading-images.html \
	tomasi-ray-tracing-04a-documentation.html \
	tomasi-ray-tracing-03b-image-files.html \
	tomasi-ray-tracing-03a-images.html \
	tomasi-ray-tracing-02b-tests.html \
	tomasi-ray-tracing-02a-colors.html \
	tomasi-ray-tracing-01b-github.html \
	tomasi-ray-tracing-01a-rendering-equation.html \
	index.html

index.html: index.md ${JS_FILES}
	$(PANDOC) --standalone -o $@ $<

%.js: %.nim
	nim js -o:$@ $<

%.html: %.md
	$(PANDOC) \
	    	--standalone \
		--filter pandoc-plot \
		--css ./css/custom.css \
		--css ./css/asciinema-player.css \
		-A asciinema-include.html \
		-A nim-include.html \
		--katex \
		-V theme=white \
		-V progress=true \
		-V slideNumber=true \
		-V background-image=./media/background.png \
		-V width=1440 \
		-V height=810 \
		-f markdown+tex_math_single_backslash+subscript+superscript \
		-t revealjs \
		-o $@ $<
