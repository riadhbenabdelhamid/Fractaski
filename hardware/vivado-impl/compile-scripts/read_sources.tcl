read_verilog -sv [glob ${RISCV_CORE_SOURCE_DIR}/*.sv]
read_verilog -sv [glob ${RTL_SOURCE_DIR}/*.sv]
read_verilog -sv [glob ${INC_DIR}/*.svh]

read_xdc $USR_CONSTR_DIR/nexys-a7.xdc
#read_xdc $USR_CONSTR_DIR/floorplan_${selected_fpga_part}.xdc
#read_xdc $USR_CONSTR_DIR/general_constr_${selected_fpga_part}.xdc

