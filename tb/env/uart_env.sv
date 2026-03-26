
class uart_env;

  VR_Agent   agt_config;
  VR_Agent   agt_vr_tx;
  VR_Agent   agt_vr_rx;
  UART_Agent agt_uart_tx;
  UART_Agent agt_uart_rx;

  
  vr_Agent_config   cfg_config;
  vr_Agent_config   cfg_vr_tx;
  vr_Agent_config   cfg_vr_rx;
  uart_Agent_config cfg_uart_tx;
  uart_Agent_config cfg_uart_rx;

  scoreboard sb;

  mailbox #(vr_Transaction)   mbx_config_drv, mbx_config_mon;
  mailbox #(vr_Transaction)   mbx_vr_tx_drv,  mbx_vr_tx_mon;
  mailbox #(vr_Transaction)   mbx_vr_rx_drv,  mbx_vr_rx_mon;
  mailbox #(uart_Transaction) mbx_uart_tx_drv, mbx_uart_tx_mon;
  mailbox #(uart_Transaction) mbx_uart_rx_drv, mbx_uart_rx_mon;

  function new( vr_Agent_config   c_cfg,
                vr_Agent_config   c_v_tx,
                vr_Agent_config   c_v_rx,
                uart_Agent_config c_u_tx,
                uart_Agent_config c_u_rx );

        this.cfg_config  = c_cfg;
        this.cfg_vr_tx   = c_v_tx;
        this.cfg_vr_rx   = c_v_rx;
        this.cfg_uart_tx = c_u_tx;
        this.cfg_uart_rx = c_u_rx;

  endfunction

  function void build();
    $display("[%0t] [ENV] Building Environment", $time);

            mbx_config_drv = new();
            mbx_config_mon = new();

            mbx_vr_tx_drv  = new();
            mbx_vr_tx_mon  = new();

            mbx_vr_rx_drv  = new();
            mbx_vr_rx_mon  = new();

            mbx_uart_tx_drv = new();
            mbx_uart_tx_mon = new();

            mbx_uart_rx_drv = new();
            mbx_uart_rx_mon = new();

    sb = new();

        sb.mbx_config   = mbx_config_mon;
        sb.mbx_vr_tx    = mbx_vr_tx_mon;
        sb.mbx_vr_rx    = mbx_vr_rx_mon;
        sb.mbx_uart_tx  = mbx_uart_tx_mon;
        sb.mbx_uart_rx  = mbx_uart_rx_mon;

        agt_config  = new(cfg_config,  mbx_config_drv,  mbx_config_mon);
        agt_vr_tx   = new(cfg_vr_tx,   mbx_vr_tx_drv,   mbx_vr_tx_mon);
        agt_vr_rx   = new(cfg_vr_rx,   mbx_vr_rx_drv,   mbx_vr_rx_mon);

    agt_uart_tx = new(cfg_uart_tx.vif, cfg_uart_tx, mbx_uart_tx_drv, mbx_uart_tx_mon);
    agt_uart_rx = new(cfg_uart_rx.vif, cfg_uart_rx, mbx_uart_rx_drv, mbx_uart_rx_mon);

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
