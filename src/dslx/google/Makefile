# example:
# make sv stages=10

PWD              = $(shell pwd)

stages         ?= 1

SOURCE_FILE     = idct-chen.x
SOURCE          = $(PWD)/$(SOURCE_FILE)
TARGET_IR       = $(PWD)/$(SOURCE_FILE:.x=.ir)
TARGET_OPT_IR   = $(PWD)/$(SOURCE_FILE:.x=.opt.ir)
TARGET_V        = $(PWD)/$(SOURCE_FILE:.x=_s$(stages).v)
TARGET_SV       = $(PWD)/$(SOURCE_FILE:.x=_s$(stages).sv)

TESTV_VVP       = $(PWD)/$(SOURCE_FILE:.x=_s$(stages)_v.vvp)
TESTSV_VVP      = $(PWD)/$(SOURCE_FILE:.x=_s$(stages)_sv.vvp)
TEST_BENCH_FILE = testbench.v
TEST_BENCH      = $(PWD)/$(TEST_BENCH_FILE)
TEST_V          = test_v
TEST_SV         = test_sv

TEST_X          = test_x

.PHONY: verilog
verilog: $(TARGET_V)

.PHONY: ir
ir: $(TARGET_IR)

.PHONY: opt
opt: $(TARGET_OPT_IR)

.PHONY: sv
sv: $(TARGET_SV)

$(TARGET_SV): $(TARGET_OPT_IR)
	$(XLS_PATH)/bazel-bin/xls/tools/codegen_main $< --pipeline_stages=$(stages) --delay_model=unit > $@

$(TARGET_V): $(TARGET_OPT_IR)
	$(XLS_PATH)/bazel-bin/xls/tools/codegen_main $< --pipeline_stages=$(stages) --delay_model=unit --use_system_verilog=false > $@

$(TARGET_OPT_IR):$(TARGET_IR)
	$(XLS_PATH)/bazel-bin/xls/tools/opt_main $< > $@

$(TARGET_IR): $(SOURCE)
	cd $(XLS_PATH); bazel-bin/xls/dslx/ir_converter_main $< > $@

$(TESTV_VVP): $(TARGET_V)
	$(ICARUS_HOME)/bin/iverilog $< -o $@

$(TESTSV_VVP): $(TARGET_SV)
	$(ICARUS_HOME)/bin/iverilog $< -o $@ -g2012

# run interpreter
$(TEST_X): $(SOURCE)
	cd $(XLS_PATH); bazel-bin/xls/dslx/interpreter_main $<

$(TEST_V): $(TESTV_VVP)
	$(ICARUS_HOME)/bin/vvp $<

$(TEST_SV): $(TESTSV_VVP)
	$(ICARUS_HOME)/bin/vvp $<

clean:
	rm -rf $(TARGET_IR) $(TARGET_OPT_IR) $(PWD)/$(SOURCE_FILE:.x=)_s*.*
