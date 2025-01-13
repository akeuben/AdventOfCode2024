build:
	gcc turing_machine.c -g -o turing_machine

run: build
	@echo "Part 1"
	@./turing_machine part1 input | sed "s/.* //" | tail -n 1
	@echo "Part 2"
	@./turing_machine part2 input | sed "s/.* //" | tail -n 1
