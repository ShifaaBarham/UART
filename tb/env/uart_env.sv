class uart_env;

  vr_Agent     agt_config;  
  vr_Agent     agt_vr_tx;   
  vr_Agent     agt_vr_rx; 
  uart_Agent   agt_uart_tx;  
  uart_Agent   agt_uart_rx;  

  vr_Agent_config     cfg_config;
  vr_Agent_config     cfg_vr_tx;
  vr_Agent_config     cfg_vr_rx;
  uart_Agent_config   cfg_uart_tx;
  uart_Agent_config   cfg_uart_rx;

  scoreboard  sb;

  function new( vr_Agent_config     c_cfg,
                vr_Agent_config     c_v_tx,
                vr_Agent_config     c_v_rx,
                uart_Agent_config   c_u_tx,
                uart_Agent_config   c_u_rx );
    this.cfg_config  = c_cfg;
    this.cfg_vr_tx   = c_v_tx;
    this.cfg_vr_rx   = c_v_rx;
    this.cfg_uart_tx = c_u_tx;
    this.cfg_uart_rx = c_u_rx;
  endfunction

  function void build();
    $display("[%0t] [ENV] Building Environment...", $time);
    
    agt_config  = new(cfg_config);
    agt_vr_tx   = new(cfg_vr_tx);
    agt_vr_rx   = new(cfg_vr_rx);
    agt_uart_tx = new(cfg_uart_tx);
    agt_uart_rx = new(cfg_uart_rx);

    sb = new();
    
  
    agt_config.mbx_monitor  = sb.mbx_config;
    agt_vr_tx.mbx_monitor   = sb.mbx_vr_tx;
    agt_vr_rx.mbx_monitor   = sb.mbx_vr_rx;
    agt_uart_tx.mbx_monitor = sb.mbx_uart_tx;
    agt_uart_rx.mbx_monitor = sb.mbx_uart_rx;

  endfunction

  task run();
    fork
      agt_config.run();
      agt_vr_tx.run();
      agt_vr_rx.run();
      agt_uart_tx.run();
      agt_uart_rx.run();
      sb.run(); 
    join_none
  endtask

endclass