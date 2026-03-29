 class vr_generator #(parameter DATA_WIDTH=8, parameter ADDRESS_WIDTH=8, parameter CTRL_WIDTH=8);
        
        mailbox #(vr_Transaction #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) mbx;
        int num_transactions;
        
     function new(mailbox #(vr_Transaction #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) mbx);
              this.mbx = mbx;
              this.num_transactions = 1; 
        endfunction
        
   task run();
                vr_Transaction #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) t;
                for (int i = 0; i < num_transactions; i++) begin
                 t = new();
                 if (!t.randomize()) begin
                    $error("[%0t] [VR_GEN] Randomization failed!", $time);
                 end
                 mbx.put(t);
                $display("[%0t] [VR_GEN] Generated Transaction %0d/%0d", $time, i+1, num_transactions);
                end
            endtask
endclass