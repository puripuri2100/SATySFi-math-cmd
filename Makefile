all:
	satysfi math-greece.saty -o math-greece.pdf
	gs -sDEVICE=pngalpha -o math-greece-%02d.png -r144 math-greece.pdf
