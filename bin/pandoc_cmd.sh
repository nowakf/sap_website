for i in posts/**/*.md; do pandoc -f markdown -o ${i%%.md}.html $i; mv -t artefacts ${i%%.md}.html; done
