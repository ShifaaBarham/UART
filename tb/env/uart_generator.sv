class uart_Generator #(parameter DATA_WIDTH=8);
  
  mailbox #(uart_Transaction #(DATA_WIDTH)) gen2drv;

  function new(mailbox #(uart_Transaction #(DATA_WIDTH)) gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task send_rx_traffic(int num_transactions, 
                       int parity_err_rate = 0, 
                       int checksum_err_rate = 0,
                       int framing_err_rate = 0);
    
    uart_Transaction #(DATA_WIDTH) tr;
    int rand_p, rand_c, rand_f;
    
    for(int i=0; i<num_transactions; i++) begin
      tr = new();
      
      tr.data = $urandom(); 
      
      rand_p = $urandom_range(0, 99);
      tr.inject_parity_err = (rand_p < parity_err_rate) ? 1'b1 : 1'b0;
      
      rand_c = $urandom_range(0, 99);
      tr.inject_checksum_err = (rand_c < checksum_err_rate) ? 1'b1 : 1'b0;
      
      rand_f = $urandom_range(0, 99);
      tr.inject_framing_err = (rand_f < framing_err_rate) ? 1'b1 : 1'b0;
      
      gen2drv.put(tr);
    end
    $display("[%0t] [UART_GEN] Generated %0d RX Trans (ParityErr:%0d%%, ChkErr:%0d%%, FrameErr:%0d%%)", 
             $time, num_transactions, parity_err_rate, checksum_err_rate, framing_err_rate);
  endtask

endclass