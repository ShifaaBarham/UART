# ----------------------------------------------------
# ModelSim Run Script for UART Project
# ----------------------------------------------------

vlib work

vlog rtl/*.v

vlog +incdir+tb/interfaces \
     +incdir+tb/agents/vr_agent \
     +incdir+tb/agents/uart_agent \
     +incdir+tb/env \
     +incdir+tb/tests \
     tb/top/top_tb.sv


vsim -voptargs=+acc work.top_tb

run -all