all:
	satysfi math-greece.saty -o math-greece.pdf
	gs -sDEVICE=pngalpha -o math-greece-%01d.png -r144 math-greece.pdf

	satysfi math-operator.saty -o math-operator.pdf
	gs -sDEVICE=pngalpha -o math-operator-%01d.png -r144 math-operator.pdf
