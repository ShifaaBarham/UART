
class base_test;

  uart_env env;

  vr_Agent_config    cfg_config;
  vr_Agent_config    cfg_vr_tx;
  vr_Agent_config    cfg_vr_rx;
  uart_Agent_config  cfg_uart_tx;
  uart_Agent_config  cfg_uart_rx;

  virtual valid_ready_if vif_config;
  virtual valid_ready_if vif_vr_tx;
  virtual valid_ready_if vif_vr_rx;
  virtual UART_if        vif_uart_tx;
  virtual UART_if        vif_uart_rx;

  function new( virtual valid_ready_if v_cfg,
                virtual valid_ready_if v_tx,
                virtual valid_ready_if v_rx,
                virtual UART_if        u_tx,
                virtual UART_if        u_rx );
    
    this.vif_config  = v_cfg;
    this.vif_vr_tx   = v_tx;
    this.vif_vr_rx   = v_rx;
    this.vif_uart_tx = u_tx;
    this.vif_uart_rx = u_rx;

    cfg_config  = new();
    cfg_config.vif  = vif_config;

    cfg_vr_tx   = new();
    cfg_vr_tx.vif   = vif_vr_tx;

    cfg_vr_rx   = new();
    cfg_vr_rx.vif   = vif_vr_rx;

    cfg_uart_tx = new();
    cfg_uart_tx.vif = vif_uart_tx;

    cfg_uart_rx = new();
    cfg_uart_rx.vif = vif_uart_rx;

    env = new(cfg_config, cfg_vr_tx, cfg_vr_rx, cfg_uart_tx, cfg_uart_rx);
  endfunction

    virtual task run();
        env.build();
        fork 
        env.run();
        join_none
    
        apply_hw_reset();    
        configure_dut();     
        lift_soft_reset();  
        main_test();        
        
        #2000;
        $display("[%0t] [TEST] Simulation Finished Successfully.", $time);
        $finish;
    endtask


        virtual task apply_hw_reset();
            $display("[%0t] [TEST] Applying Hardware Reset", $time);
        endtask

  virtual task configure_dut();
    $display("[%0t] [TEST] Configuring DUT (Default values)", $time);
  endtask

    virtual task lift_soft_reset();
        $display("[%0t] [TEST] Lifting Soft Reset (Writing 0x00 to 0x04).", $time);
        write_register(8'h04, 8'h00);
        #50;
    endtask

  virtual task main_test();
    $display("[%0t] [TEST] Base Test: No specific scenario running.", $time);
  endtask

  
        virtual task write_register(bit [7:0] addr, bit [7:0] data);
        vr_Transaction #(8,8,8) write_trans = new();
        write_trans.addr = addr;
        write_trans.data = data;
        write_trans.ctrl = 1; // write
        env.agt_config.vr_drv_mbx.put(write_trans);
        endtask

        virtual task read_register(bit [7:0] addr, int delay_ready = 0);
        vr_Transaction #(8,8,8) read_trans = new();
        read_trans.addr = addr;
        read_trans.ctrl = 0; // read
        read_trans.ready_delay = delay_ready;
        env.agt_config.vr_drv_mbx.put(read_trans);
        endtask


endclass