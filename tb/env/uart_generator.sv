class uart_generator #(parameter DATA_WIDTH=8);
  
        mailbox #(uart_Transaction #(DATA_WIDTH)) mbx;
        int num_transactions;
        
    function new(mailbox #(uart_Transaction #(DATA_WIDTH)) mbx);
              this.mbx = mbx;
            this.num_transactions = 1;
        endfunction
        
    task run();
            uart_Transaction #(DATA_WIDTH) t;
             for (int i = 0; i < num_transactions; i++) begin
               t = new();
              if (!t.randomize()) begin
                $error("[%0t] [UART_GEN] Randomization failed!", $time);
             end
            mbx.put(t);
            $display("[%0t] [UART_GEN] Generated Transaction %0d/%0d", $time, i+1, num_transactions);
            end
        endtask
endclass