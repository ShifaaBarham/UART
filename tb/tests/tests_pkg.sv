package tests_pkg;

 import vr_agent_pkg::*;
  import uart_agent_pkg::*;
  import env_pkg::*;

  //`include "0_base_test.sv" 
  `include "1_test_reg_hw_reset.sv"
  `include "2_test_reg_rw_access.sv"
  `include "3_test_config_read_backpressure.sv"
  `include "4_test_config_write_mid_transaction.sv"
  

endpackage