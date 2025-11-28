RUN_DIR?=vivado-runs
COMPILE_SCRIPTS_DIR?=../compile-scripts
HEX_NAME?=fractals
HEX_SRC_PATH?=../../software
HEX_PROG?=$(HEX_SRC_PATH)/runs/$(HEX_NAME).inst
TOP_RTL?=fpga

HEX_C_PATH := $(HEX_SRC_PATH)/C/$(HEX_NAME).c
HEX_ASM_PATH := $(HEX_SRC_PATH)/assembly/$(HEX_NAME).S

# Determine generator based on path
ifeq ($(wildcard $(HEX_C_PATH)), $(HEX_C_PATH))
  HEX_GEN_TARGET = c_hex_gen
else ifeq ($(wildcard $(HEX_ASM_PATH)), $(HEX_ASM_PATH))
  HEX_GEN_TARGET = hex_gen
else
  $(error HEX_NAME '$(HEX_NAME)' not found in either C/ or Assembly/ under '$(HEX_SRC_PATH)')
endif

# config params
# TBD
MMCM_OUT_FREQ_MHZ?=100
NUM_PIPE_STAGES?=4
NUM_THREADS?=4
ENABLE_BRAM_REGFILE?=false
# TBD
ENABLE_ALU_DSP?=false
ENABLE_UNIFIED_BARREL_SHIFTER?=true

#TBD
#SINGLE_PROGRAM=1 => same program go into all cores
#SINGLE_PROGRAM=0 => program should be suffixed with IDs of each core (e.g program_0_0_0_1)
SINGLE_PROGRAM?=1 

#TBD
#CORE_HARD_BARRIER=1 => Use extended core top that has extended MMIO with hard barrier registers
#CORE_HARD_BARRIER=0 => Use regular core top that has regular MMIO 
CORE_HARD_BARRIER?=1

ENV_VARS = RUN_DIR=$(RUN_DIR) \
	   COMPILE_SCRIPTS_DIR=$(COMPILE_SCRIPTS_DIR) \
	   TOP_RTL=$(TOP_RTL) \
	   MMCM_OUT_FREQ_MHZ=$(MMCM_OUT_FREQ_MHZ) \
	   NUM_PIPE_STAGES=$(NUM_PIPE_STAGES) \
	   NUM_THREADS=$(NUM_THREADS) \
	   ENABLE_BRAM_REGFILE=$(ENABLE_BRAM_REGFILE) \
	   ENABLE_ALU_DSP=$(ENABLE_ALU_DSP) \
	   ENABLE_UNIFIED_BARREL_SHIFTER=$(ENABLE_UNIFIED_BARREL_SHIFTER) \
	   SINGLE_PROGRAM=$(SINGLE_PROGRAM) \
	   CORE_HARD_BARRIER=$(CORE_HARD_BARRIER) \
	   HEX_PROG=../$(HEX_PROG)


all: compile_nexys-a7

compile_nexys-a7: 
	$(MAKE) compile FPGA_PART=nexys-a7

#TBD
compile_basys3: 
	$(MAKE) compile FPGA_PART=basys3

#TBD
compile_nexys-video: 
	$(MAKE) compile FPGA_PART=nexys-video

compile: hex_gen
	mkdir -p $(RUN_DIR)
	FPGA_PART=$(FPGA_PART)
	cd $(RUN_DIR) && FPGA_PART=$(FPGA_PART) $(ENV_VARS) vivado -mode batch -source $(COMPILE_SCRIPTS_DIR)/compile.tcl

# generate .inst file
hex_gen:
	cd $(HEX_SRC_PATH) && CPROG=$(HEX_NAME) PROG=$(HEX_NAME) NUM_THREADS=$(NUM_THREADS) $(MAKE) $(HEX_GEN_TARGET)

clean:
	rm -rf $(RUN_DIR)

help:
	@echo "(make all) will generate the fpga bitstream for the target board" 

all: clean compile 
