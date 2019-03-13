all:
	ocamlc str.cma main.ml -o main
	./main
	satysfi main.saty -o math-cmd.pdf
	pdfcrop math-cmd.pdf math-cmd-cropped.pdf
	gs -sDEVICE=pngalpha -o img/math-cmd-%01d.png -r144 math-cmd-cropped.pdf
