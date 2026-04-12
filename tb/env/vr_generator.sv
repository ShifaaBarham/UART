class vr_Generator #(parameter DATA_WIDTH=32, parameter ADDRESS_WIDTH=8, parameter CTRL_WIDTH=1);
  
  mailbox #(vr_Transaction #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) gen2drv;
  
  function new(mailbox #(vr_Transaction #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task write_reg(logic [ADDRESS_WIDTH-1:0] adr, logic [DATA_WIDTH-1:0] dat);
    vr_Transaction #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) tr = new();
    // تعيين مباشر بدون راندومايز
    tr.addr = adr;
    tr.wdata = dat;
    tr.ctrl = 1'b1;
    tr.tx_err = 1'b0;
    tr.valid_delay = 0;
    gen2drv.put(tr);
  endtask

  task read_reg(logic [ADDRESS_WIDTH-1:0] adr, int r_delay = 0); 
    vr_Transaction #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) tr = new();
    
    tr.addr = adr;
    tr.ctrl = 1'b0;
    tr.tx_err = 1'b0;
    tr.valid_delay = 0;
    
    // 2. أهم خطوة: مرر الـ delay للـ Transaction
    tr.ready_delay = r_delay; 
    
    gen2drv.put(tr);
endtask
  task send_tx_traffic(int num_transactions, int err_rate = 0, int min_delay = 0, int max_delay = 0);
    vr_Transaction #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) tr;
    int rand_val;
    for(int i=0; i<num_transactions; i++) begin
      tr = new();
      
      tr.addr = 8'h00; 
      tr.ctrl = 1'b1; 
      tr.wdata = $urandom(); // بيانات عشوائية
      
      rand_val = $urandom_range(0, 99);
      tr.tx_err = (rand_val < err_rate) ? 1'b1 : 1'b0;
      
      tr.valid_delay = $urandom_range(min_delay, max_delay);
      
      gen2drv.put(tr);
    end
    $display("[%0t] [VR_GEN] Generated %0d TX Trans (ErrRate:%0d%%, Delay:%0d-%0d)", 
             $time, num_transactions, err_rate, min_delay, max_delay);
  endtask

  task drive_rx_ready_responses(int num_responses, int min_delay = 0, int max_delay = 0);
    vr_Transaction #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) tr;
    for(int i=0; i<num_responses; i++) begin
      tr = new();
      tr.ready_delay = $urandom_range(min_delay, max_delay); 
      gen2drv.put(tr);
    end
    $display("[%0t] [VR_GEN] Generated %0d RX Ready Responses (Delay: %0d to %0d)", 
             $time, num_responses, min_delay, max_delay);
  endtask

endclass