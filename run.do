# ----------------------------------------------------
# ModelSim Run Script for UART Project
# ----------------------------------------------------

# 1. Create work library
vlib work

# 2. Compile Everything in the correct order
vlog -sv +incdir+./tb/agents/vr_agent +incdir+./tb/agents/uart_agent +incdir+./tb/env +incdir+./tb/tests \
  ./tb/interfaces/valid_ready_if.sv \
  ./tb/interfaces/UART_if.sv \
  ./tb/agents/vr_agent/vr_agent_pkg.sv \
  ./tb/agents/uart_agent/uart_agent_pkg.sv \
  ./tb/env/env_pkg.sv \
  ./tb/tests/tests_pkg.sv \
  ./DUT/design.sv \
  ./tb/top_tb.sv

# 3. Run Simulation (with the testname passed as an argument)
# يمكنك تغيير اسم التست هنا بسهولة
vsim -gui -voptargs="+acc" work.tb_top +TESTNAME=test_config_read_backpressure

# 4. Add waves (Optional - if you want to see the signals)
# add wave -position insertpoint sim:/tb_top/*

# 5. Run
run -all