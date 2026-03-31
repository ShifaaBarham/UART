package tests_pkg;

  import vr_agent_pkg::*;
  import uart_agent_pkg::*;
  import env_pkg::*;

  `include "0_base_test.sv" 
  `include "1_test_reg_hw_reset.sv"
  `include "2_test_reg_rw_access.sv"
  `include "3_test_config_read_backpressure.sv"
  `include "4_test_config_write_mid_transaction.sv"
  `include "7_test_invalid_address_access.sv"
  `include "11_test_tx_sanity.sv"
  `include "12_test_rx_sanity.sv"
  `include "13_test_baud_rate_sweep.sv"
  `include "14_test_tx_total_parity_sanity.sv"
  `include "15_test_tx_ppb_parity_sanity.sv"
  `include "16_test_rx_total_parity_sanity.sv"
  `include "17_test_rx_ppb_parity_sanity.sv"
  

endpackage