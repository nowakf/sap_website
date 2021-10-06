.PHONY: html ##build html

src_dir = posts
dst_dir = build
style_sheet = style.css
template = template.html
index_template = template.html
index_style_sheet = style.css

proc_images = $(patsubst %,build/images/%.jpg,$(notdir $(basename $(raw_images))))
raw_images = $(shell find $(src_dir) -type f -print0 | xargs -0 file --mime-type | grep -F 'image/' | cut -d ':' -f 1)
md_files = $(wildcard posts/*.md)
html_files = $(md_files:posts/%.md=build/%.html)


build/$(style_sheet): $(style_sheet)
	cp $(style_sheet) build/$(style_sheet)

build/%.html: posts/%.md $(style_sheet) $(template)
	@echo $@ $<
	pandoc  --standalone           \
		--css=$(style_sheet)   \
		--template=$(template) \
		--from=markdown        \
		--to=html -o $@ $<     \

build/images/%.jpg: posts/**/%.*
	@echo $@ $<
	convert $< -resize 800\> $@

index: index.html
	@echo buidling index

index.html: index.md
	pandoc  --standalone                 \
		--css=$(index_style_sheet)   \
		--template=$(index_template) \
		--from=markdown              \
		--to=html -o $(dst_dir)/index.html $<

index.md: bin/generate_index.lua $(md_files)
	bin/generate_index.lua $(md_files) > index.md

css: build/$(style_sheet)

images: $(proc_images)
	@echo building images

html: $(html_files)
	@echo building files

all: css html images index

