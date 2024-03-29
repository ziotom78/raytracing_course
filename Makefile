PANDOC = /usr/bin/pandoc
SED = /bin/sed
JS_FILES = \
	./js/quantization.js

.phony: all http

all: \
	tomasi-ray-tracing-13b.html \
	tomasi-ray-tracing-13a.html \
	tomasi-ray-tracing-12b.html \
	tomasi-ray-tracing-12a.html \
	tomasi-ray-tracing-11b.html \
	tomasi-ray-tracing-11a.html \
	tomasi-ray-tracing-10b.html \
	tomasi-ray-tracing-10a.html \
	tomasi-ray-tracing-09a.html \
	tomasi-ray-tracing-08b.html \
	tomasi-ray-tracing-08a.html \
	tomasi-ray-tracing-07b.html \
	tomasi-ray-tracing-07a.html \
	tomasi-ray-tracing-06b.html \
	tomasi-ray-tracing-06a.html \
	tomasi-ray-tracing-05b.html \
	tomasi-ray-tracing-05a.html \
	tomasi-ray-tracing-04b.html \
	tomasi-ray-tracing-04a.html \
	tomasi-ray-tracing-03b.html \
	tomasi-ray-tracing-03a.html \
	tomasi-ray-tracing-02b.html \
	tomasi-ray-tracing-02a.html \
	tomasi-ray-tracing-01b.html \
	tomasi-ray-tracing-01a.html \
	giudizi-linguaggio.html \
	language-comparison.html \
	index.html

index.html: index.md ${JS_FILES}
	$(PANDOC) --standalone -o $@ $<

language-comparison.html: language-comparison.md
	$(PANDOC) --toc --standalone -o $@ $<

giudizi-linguaggio.html: giudizi-linguaggio.md
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
		--template template-revealjs.html \
		-V theme=white \
		-V progress=true \
		-V slideNumber=true \
		-V history=true \
		-V background-image=./media/background.png \
		-V width=1440 \
		-V height=810 \
		-f markdown+tex_math_single_backslash+subscript+superscript \
		-t revealjs \
		-o $@ $<
	# This is necessary to make Asymptote WebGL figures work
	$(SED) -z -i 's/embed.data-src/embed width="640px" height="640px" src/g' $@

http:
	python -m http.server
