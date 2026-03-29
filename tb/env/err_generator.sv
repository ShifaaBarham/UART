class uart_parity_err_generator #(parameter DATA_WIDTH=32) extends uart_generator #(DATA_WIDTH);
  
  function new(mailbox #(uart_Transaction #(DATA_WIDTH)) mbx);
    super.new(mbx);
  endfunction
  
  task run();
    uart_Transaction #(DATA_WIDTH) t;
    for (int i = 0; i < num_transactions; i++) begin
      t = new();
      if (!t.randomize() with { inject_parity_err == 1; inject_framing_err == 0; }) begin
        $error("Randomization failed!");
      end
        mbx.put(t);
        $display("[%0t] [GEN] Injected Parity Error Trans %0d", $time, i);
    end
  endtask
endclass

class uart_framing_err_generator #(parameter DATA_WIDTH=32) extends uart_generator #(DATA_WIDTH);
            function new(mailbox #(uart_Transaction #(DATA_WIDTH)) mbx);
        super.new(mbx);
    endfunction
    
    task run();
            uart_Transaction #(DATA_WIDTH) t;
            for (int i = 0; i < num_transactions; i++) begin
            t = new();
        if (!t.randomize() with { inject_framing_err == 1; inject_parity_err == 0; }) begin
            $error("Randomization failed!");
        end
        mbx.put(t);
        end
    endtask
endclass