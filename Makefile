.PHONY: index css images html assets all videos push

style_sheet = style.css
template = template.html
index_template = template.html
index_style_sheet = style.css

#raw_images = $(shell find posts -type f -print0 | xargs -0 file --mime-type | grep -F 'image/' | cut -d ':' -f 1)
#proc_images = $(patsubst %,build/images/%.jpg,$(notdir $(basename $(raw_images))))
mov_src = $(wildcard posts/images/*.webm) # could be better:
#raw_video = $(shell find posts -type f -print0 | xargs -0 file --mime-type | grep -F 'video/' | cut -d ':' -f 1) --
mov_files = $(mov_src:posts/images/%.webm=build/images/%.webm)
img_src = $(wildcard posts/images/*.jpg)
img_files = $(img_src:posts/images/%.jpg=build/images/%.jpg)
md_files = $(wildcard posts/*.md)
html_files = $(md_files:posts/%.md=build/%.html)
asset_src = $(shell find posts/assets -type f)
asset_files = $(asset_src:posts/assets/%=build/assets/%)

build/$(style_sheet): $(style_sheet)
	cp $(style_sheet) build/$(style_sheet)

build/assets/%: posts/assets/%
	@echo $@ $<
	cp $< $@

build/%.html: posts/%.md $(template)
	@echo $@ $<
	pandoc  --standalone           \
		--css=$(style_sheet)   \
		--template=$(template) \
		--from=markdown        \
		--to=html -o $@ $<     \

build/images/%.webm: posts/images/%.*
	@echo $@ $<
	ffmpeg -i $< -filter:v scale=800:-1 -c:a copy $@

build/images/%.jpg: posts/images/%.*
	convert $< -resize 800\> $@

index: build/index.html
	@echo buidling index

about: build/about.html
	@echo buidling about

build/about.html: about.md
	pandoc  --standalone                 \
		--css=$(index_style_sheet)   \
		--template=$(index_template) \
		--from=markdown              \
		--to=html -o build/about.html $<

build/index.html: index.md
	pandoc  --standalone                 \
		--css=$(index_style_sheet)   \
		--template=$(index_template) \
		--from=markdown              \
		--to=html -o build/index.html $<

index.md: bin/generate_index.lua header.html $(md_files)
	cat header.html > index.md
	bin/generate_index.lua $(md_files) >> index.md

css: build/$(style_sheet)

images: $(img_files)
	@echo building images

videos: $(mov_files)
	@echo building videos

html: $(html_files)
	@echo building files

assets: $(asset_files)
	@echo $@ $<
	@echo copying assets

all: css html images videos index about assets

push: all
	cd build
	git add .
	git commit -m "$$(date)"
	git push -u origin master
