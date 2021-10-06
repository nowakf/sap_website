.PHONY: html ##build html

src_dir = posts
dst_dir = build
style_sheet = style.css

proc_images = $(patsubst %,build/images/%.jpg,$(notdir $(basename $(raw_images))))
raw_images = $(shell find $(src_dir) -type f -print0 | xargs -0 file --mime-type | grep -F 'image/' | cut -d ':' -f 1)
md_files = $(wildcard posts/*.md)
html_files = $(md_files:posts/%.md=build/%.html)


build/$(style_sheet): $(style_sheet)
	cp $(style_sheet) build/$(style_sheet)

build/%.html: posts/%.md $(style_sheet)
	@echo $@ $<
	pandoc --css=$(style_sheet) \
	       --from=markdown      \
	       --to=html -o $@ $<   \

build/images/%.jpg: posts/**/%.*
	@echo $@ $<
	convert $< -resize 800\> $@

css: build/$(style_sheet)

images: $(proc_images)
	@echo building images

html: $(html_files)
	@echo building files

all: css html images

