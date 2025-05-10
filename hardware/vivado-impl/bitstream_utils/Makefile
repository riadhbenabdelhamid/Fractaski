RUN_DIR?=vivado-updated-runs
HEX_PROG_NAME?=../../../../software/runs/fractals

ENV_VARS = RUN_DIR=$(RUN_DIR) \
	   HEX_PROG_NAME=$(HEX_PROG_NAME)

all : clean reprog

reprog:
	mkdir -p $(RUN_DIR)
	HEX_PROG=$(HEX_PROG_NAME)
	cd $(RUN_DIR) && $(ENV_VARS) vivado -mode batch -source ../reprogram.tcl

clean:
	rm -rf $(RUN_DIR)
