default: compile link
all: compile link simulate
vlog: rtl vlink vsim

# ----------------------------------------------------------------

TOPFILE   ?= ./IdctAxiWrapper.bsv
#TOPFILE   ?= ./IdctAxiWrapperTestbench.bsv
#TOPFILE   ?= ./IdctTestbench.bsv
#TOPFILE   ?= ./IdctTest0Wrapper.bsv

TOPMODULE ?= mkIdctAxiWrapper
#TOPMODULE ?= mkIdctAxiWrapperTestbench
#TOPMODULE ?= mkIdctTestbench
#TOPMODULE ?= mkIdctTest0Wrapper
EXEFILE_BSIM ?= exe_HW_bsim
EXEFILE_VSIM ?= exe_HW_vsim

BSCFLAGS = -show-schedule \
	-no-warn-action-shadowing \
	-show-range-conflict

BSC_C_FLAGS += \
	-Xc++  -D_GLIBCXX_USE_CXX11_ABI=0 \
	-Xl -v \
	-Xc -O3 -Xc++ -O3

# ----------------------------------------------------------------
# For RISCY-OOO

BSCPATH = +

# ----------------------------------------------------------------
# FOR BLUESIM

BSCDIRS_BSIM  = -simdir build_bsim -bdir build -info-dir build
BSCPATH_BSIM  = $(BSCPATH)

build_bsim:
	mkdir -p $@

build:
	mkdir -p $@

.PHONY: compile
compile: build_bsim build
	@echo Compiling...
	bsc -u -sim $(BSCDIRS_BSIM)  $(BSCFLAGS)  -p $(BSCPATH_BSIM)  $(TOPFILE)
	@echo Compilation finished

.PHONY: link
link:
	@echo Linking...
	bsc  -sim  -parallel-sim-link 8\
		$(BSCDIRS_BSIM)  -p $(BSCPATH_BSIM) \
		-e $(TOPMODULE) -o ./$(EXEFILE_BSIM) \
		$(BSCFLAGS) \
		$(BSC_C_FLAGS)
	@echo Linking finished

.PHONY: simulate
simulate:
	@echo Simulation...
	./$(EXEFILE_BSIM)
	@echo Simulation finished

# ----------------------------------------------------------------
# FOR VERILOG

BSCDIRS_V = -vdir verilog  -bdir build_v  -info-dir build_v
BSCPATH_V = .:+

VSIM ?= iverilog

build_v:
	mkdir -p $@

verilog:
	mkdir -p $@

.PHONY: rtl
rtl: build_v verilog
	@echo Verilog generation ...
	bsc -u -elab -verilog  $(BSCDIRS_V)  $(BSCFLAGS)  -p $(BSCPATH_V)  $(TOPFILE)
	@echo Verilog generation finished

.PHONY: vlink
vlink:
	bsc -verilog  -vsim $(VSIM)  $(BSCDIRS_V) \
		-e $(TOPMODULE) -o ./$(EXEFILE_VSIM) \
		$(BSCFLAGS)
	@echo Verilog linking finished

.PHONY: vsim
vsim:
	@echo Simulation...
	./$(EXEFILE_VSIM)
	@echo Simulation finished

# ----------------------------------------------------------------

.PHONY: clean
clean:
	rm -f  *~ *.vcd ./*~  build/*  build_bsim/*

.PHONY: full_clean
full_clean: clean
	rm -r -f  exe_*  build*  verilog  exe_HW_*

# ----------------------------------------------------------------
