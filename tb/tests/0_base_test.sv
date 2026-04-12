class base_test;
  uart_env env;

  // Configurations & Interfaces (نفس الترتيب السابق مع التأكد من العرض)
  vr_Agent_config #(8,8,1)   cfg_config;  // تحديد الحجم للكونفيج
  vr_Agent_config #(32,8,1)  cfg_vr_tx;   // تحديد الحجم للداتا
  vr_Agent_config #(32,8,1)  cfg_vr_rx;   // تحديد الحجم للداتا
  uart_Agent_config #(8)     cfg_uart_tx;
  uart_Agent_config #(8)     cfg_uart_rx;

  virtual valid_ready_if #(8,8,1)  vif_config; // Config: 8-bit addr/data, 1-bit op
  virtual valid_ready_if #(32,8,1) vif_vr_tx;  // TX: 32-bit data
  virtual valid_ready_if #(32,8,1) vif_vr_rx;  // RX: 32-bit data
  virtual UART_if        #(8)      vif_uart_tx;
  virtual UART_if        #(8)      vif_uart_rx;

  // --- Mailboxes & Generators ---
mailbox #(vr_Transaction #(8,8,1))  mbx_gen2drv_config;
  mailbox #(vr_Transaction #(32,8,1)) mbx_gen2drv_tx;
  mailbox #(vr_Transaction #(32,8,1)) mbx_gen2drv_rx;
  mailbox #(uart_Transaction #(8))    mbx_gen2drv_uart_rx;

  // --- GENERATORS ---
  vr_Generator #(8,8,1)   gen_config;
  vr_Generator #(32,8,1)  gen_vr_tx;
  vr_Generator #(32,8,1)  gen_vr_rx;
  uart_Generator #(8)     gen_uart_rx;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(8)      u_tx,
                virtual UART_if        #(8)      u_rx );
    
    this.vif_config = v_cfg; this.vif_vr_tx = v_tx; this.vif_vr_rx = v_rx;
    this.vif_uart_tx = u_tx; this.vif_uart_rx = u_rx;

    // إنشاء الميل بوكسات بحجم 1 لضمان التزامن كما طلب المدرب
    mbx_gen2drv_config  = new(1);
    mbx_gen2drv_tx      = new(1);
    mbx_gen2drv_rx      = new(1);
    mbx_gen2drv_uart_rx = new(1);

    // إنشاء الـ Generators
    gen_config  = new(mbx_gen2drv_config);
    gen_vr_tx   = new(mbx_gen2drv_tx);
    gen_vr_rx   = new(mbx_gen2drv_rx);
    gen_uart_rx = new(mbx_gen2drv_uart_rx);

    // إعداد الـ Configs للأيجنتس
  // 3. Create Agent Configurations
   cfg_config  = new(); cfg_config.vif  = vif_config;  cfg_config.agent_type = vr_agent_pkg::MASTER;
    cfg_vr_tx   = new(); cfg_vr_tx.vif   = vif_vr_tx;   cfg_vr_tx.agent_type  = vr_agent_pkg::MASTER;
    cfg_vr_rx   = new(); cfg_vr_rx.vif   = vif_vr_rx;   cfg_vr_rx.agent_type  = vr_agent_pkg::SLAVE;
     cfg_uart_tx = new(); cfg_uart_tx.vif = vif_uart_tx; cfg_uart_tx.is_active = 0;
    cfg_uart_rx = new(); cfg_uart_rx.vif = vif_uart_rx;  cfg_uart_rx.is_active=1;

    env = new(cfg_config, cfg_vr_tx, cfg_vr_rx, cfg_uart_tx, cfg_uart_rx,
              mbx_gen2drv_config, mbx_gen2drv_tx, mbx_gen2drv_rx, mbx_gen2drv_uart_rx);
  endfunction

  virtual task run();
    env.build();
    fork env.run(); join_none
    
    apply_hw_reset();    
    configure_dut();     
    lift_soft_reset();  
    main_test();        
    
    #5000;
    $display("[%0t] [TEST] Simulation Finished.", $time);
    $finish;
  endtask

  // --- التعديل هنا: دوال القراءة والكتابة تستخدم الـ Generator ---
  
  virtual task write_register(bit [7:0] addr, bit [7:0] data);
    // استدعاء الـ Generator المخصص للكونفيج
    gen_config.write_reg(addr, data);
  endtask

  virtual task read_register(bit [7:0] addr,int delay_ready = 0);
    // استدعاء الـ Generator المخصص للكونفيج
    gen_config.read_reg(addr, delay_ready);
  endtask

  virtual task apply_hw_reset();
    $display("[%0t] [TEST] Waiting for HW Reset...", $time);
    wait(vif_config.rst == 0); 
    wait(vif_config.rst == 1); 
    #50;
  endtask

  virtual task configure_dut();
    // سيتم عمل override لها في التستات اللي بتحتاج كونفيج خاص
  endtask

  virtual task lift_soft_reset();
    $display("[%0t] [TEST] Lifting Soft Reset.", $time);
    write_register(8'h04, 8'h01); // نستخدم الدالة الجديدة
    #50;
  endtask

  virtual task main_test();
    $display("[%0t] [TEST] Base Test: Empty Scenario.", $time);
  endtask
endclass