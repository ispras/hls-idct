SRC = IDCT.scala

FIR = $(SRC:%.scala=%.fir)
V   = $(SRC:%.scala=%.v)

TEST = testbench_IDCT

all: $(V) $(TEST)

$(V): $(SRC)
	sbt "runMain ru.ispras.idct.IDCTDriver"

$(TEST): $(TEST).vl $(V)
	iverilog -g2005-sv $(TEST).vl -o $(TEST)

run: $(TEST)
	vvp $(TEST)

view: $(TEST).vcd
	gtkwave --save=$(TEST).gtkw $^ &

$(TEST).fst: $(TEST).vcd
	vcd2fst $^ $@

viewfst: $(TEST).fst
	gtkwave --save=$(TEST).gtkw $^ &

clean:
	rm -rf *.json *.v *.fir *.f $(TEST) $(TEST).vcd project target

help:
	@echo "make (<empty>|run|view|clean|help)"
