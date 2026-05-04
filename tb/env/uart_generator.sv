class uart_Generator #(parameter DATA_WIDTH=32);
  
  mailbox #(uart_Transaction #(DATA_WIDTH)) gen2drv;

  function new(mailbox #(uart_Transaction #(DATA_WIDTH)) gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task send_rx_traffic(int num_transactions,
                     int parity_err_rate = 0,
                     int checksum_err_rate = 0,
                     int framing_err_rate = 0,
                     int min_tx_delay = 0,
                     int max_tx_delay = 0);

  uart_Transaction #(DATA_WIDTH) tr;
  int rand_p, rand_c, rand_f;

  for (int i = 0; i < num_transactions; i++) begin
    tr = new();
    tr.data = $urandom();

    rand_p = $urandom_range(0, 99);
    tr.inject_parity_err = (rand_p < parity_err_rate);

    rand_c = $urandom_range(0, 99);
    tr.inject_checksum_err = (rand_c < checksum_err_rate);

    rand_f = $urandom_range(0, 99);
    tr.inject_framing_err = (rand_f < framing_err_rate);

    tr.tx_delay = $urandom_range(min_tx_delay, max_tx_delay);

    gen2drv.put(tr);
  end

  $display("[%0t] [UART_GEN] Generated %0d RX Trans .", $time, num_transactions);
endtask

endclass