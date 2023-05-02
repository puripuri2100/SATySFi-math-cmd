.PHONY: pdfstd pdfbase build

pdfstd:
	pdfcrop --margins "10 10" std-math.pdf std-math-crop.pdf
	gs -sDEVICE=pngalpha -o img/std-math-%01d.png -r144 std-math-crop.pdf

pdfbase:
	pdfcrop --margins "10 10" base-math-ext.pdf base-math-ext-crop.pdf
	gs -sDEVICE=pngalpha -o img/base-math-ext-%01d.png -r144 base-math-ext-crop.pdf


build:
	ocamlc str.cma main.ml -o main

