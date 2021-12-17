PANDOC = /usr/bin/pandoc
SED = /bin/sed
JS_FILES = \
	./js/quantization.js

.phony: all

all: \
	tomasi-ray-tracing-14b-parsing.html \
	tomasi-ray-tracing-14a-parsing.html \
	tomasi-ray-tracing-13b-lexing.html \
	tomasi-ray-tracing-13a-lexing.html \
	tomasi-ray-tracing-12b-path-tracing2.html \
	tomasi-ray-tracing-12a-path-tracing2.html \
	tomasi-ray-tracing-11b-random-numbers-and-pigments.html \
	tomasi-ray-tracing-11a-path-tracing.html \
	tomasi-ray-tracing-10a-other-shapes.html \
	tomasi-ray-tracing-09b-issues.html \
	tomasi-ray-tracing-09a-shapes.html \
	tomasi-ray-tracing-08b-docstrings.html \
	tomasi-ray-tracing-08a-projections.html \
	tomasi-ray-tracing-07b-ci-builds.html \
	tomasi-ray-tracing-07a-clifford-algebras.html \
	tomasi-ray-tracing-06b-pull-requests.html \
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
	language-comparison.html \
	index.html

index.html: index.md ${JS_FILES}
	$(PANDOC) --standalone -o $@ $<

language-comparison.html: language-comparison.md
	$(PANDOC) --toc --standalone -o $@ $<

%.js: %.nim
	nim js -o:$@ $<

%.html: %.md
	$(PANDOC) \
	    	--standalone \
		--filter pandoc-imagine \
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
	# This is necessary to make Asymptote WebGL figures work
	$(SED) -i 's/embed data-src/embed width="640px" height="640px" src/g' $@
