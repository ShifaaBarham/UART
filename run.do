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

# 3. Handle arguments safely (Anti-Crash logic)
set arg1 ""
set arg2 ""
set arg3 ""
if {[info exists 1]} { set arg1 $1 }
if {[info exists 2]} { set arg2 $2 }
if {[info exists 3]} { set arg3 $3 }

# 4. Run Simulation with arguments (if any)
vsim -gui -voptargs="+acc" work.tb_top $arg1 $arg2 $arg3

# 5. Run
run -all