package tests_pkg;

  import vr_agent_pkg::*;
  import uart_agent_pkg::*;
  import env_pkg::*;

  `include "0_base_test.sv" 
  `include "1_test_reg_hw_reset.sv"
  `include "2_test_reg_rw_access.sv"
   `include "3_test_config_read_backpressure.sv"
   `include "4_test_config_write_mid_transaction.sv"
   `include "5_test_tx_parity_mode_config.sv"
  `include "6_test_rx_parity_mode_configs.sv"
  `include "7_test_invalid_address_access.sv"
    `include "8_test_soft_reset_tx_rx_flush.sv"
  `include "9_test_config_update_during_soft_reset.sv"
    `include "10_test_reset_keeps_counters.sv"
  `include "11_test_tx_sanity.sv"
  `include "12_test_rx_sanity.sv"
  `include "13_test_baud_rate_sweep.sv"
  `include "14_test_tx_total_parity_sanity.sv"
  `include "15_test_tx_ppb_parity_sanity.sv"
  `include "16_test_rx_total_parity_sanity.sv"
  `include "18_test_tx_err_drop_mode.sv" 
  `include "19_test_tx_error_injection_persistence.sv"
  `include "20_test_tx_err_flip_total.sv"
  `include "21_test_tx_err_flip_byte.sv"
  `include "22_test_tx_err_flip_all.sv"
  `include "23_43_test_rx_error_injection.sv"
  `include "44_test_rx_start_bit_glitch.sv"
  `include "45_test_rx_overrun_error_on_backpressure.sv"
  `include "46_test_tx_back_to_back.sv"
  `include "47_test_tx_valid_delay.sv"
  `include "48_test_rx_backpressure_clean.sv"
  `include "49_test_tx_backpressure_ready_toggle.sv"
  `include "50_test_rx_backpressure_error.sv"
  `include "51_64_test_counters_basic_traffic.sv"
  `include "65_70_test_counters_read_collision.sv"
  `include "72_test_asymmetric_baud_rates.sv"
  `include "73_test_full_duplex_stress.sv"
  `include "74_test_full_duplex_random_stress.sv"

endpackage