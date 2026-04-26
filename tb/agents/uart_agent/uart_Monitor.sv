class uart_Monitor #(parameter DATA_WIDTH=32);
  
    virtual interface UART_if #(DATA_WIDTH) vif;
    mailbox #(uart_Transaction #(DATA_WIDTH)) uart_mon_mbx;
    uart_Agent_config #(DATA_WIDTH) cfg;
      
    function new( virtual interface UART_if #(DATA_WIDTH) vif,
                  mailbox #(uart_Transaction #(DATA_WIDTH)) uart_mon_mbx,
                  uart_Agent_config #(DATA_WIDTH) cfg);
        this.vif = vif;
        this.uart_mon_mbx = uart_mon_mbx;
        this.cfg = cfg; 
    endfunction
      
  task run();
      uart_Transaction #(DATA_WIDTH) t;
      int unsigned clks_per_bit;
      int unsigned half_clks;
      int total_bytes = DATA_WIDTH / 8;
      logic [7:0] current_byte;
      logic expected_parity;
      string mon_name;
      string bit_stream; 

      wait(vif.rst == 1);

      forever begin
        mon_name = cfg.is_tx ? "TX_MON" : "RX_MON";

        if (cfg.is_tx) begin
          wait(vif.tx == 1'b1);
          wait(vif.tx == 1'b0);
        end
        else begin
          wait(vif.rx == 1'b1);
          wait(vif.rx == 1'b0);
        end

        clks_per_bit = cfg.get_clks_per_bit();
        if (clks_per_bit == 0) begin
          @(posedge vif.clk);
          continue;
        end

        half_clks = clks_per_bit / 2;

        t = new();
        t.detect_parity_err = 0;
        t.detect_checksum_err = 0;
        t.detect_framing_err = 0;
        
        bit_stream = "[Start:0] "; 

        repeat(half_clks) @(posedge vif.clk);

        if ((cfg.is_tx ? vif.tx : vif.rx) !== 1'b0)
          continue;

        repeat(clks_per_bit) @(posedge vif.clk);

        for (int byte_idx = 0; byte_idx < total_bytes; byte_idx++) begin
          current_byte = '0;
          
          bit_stream = {bit_stream, $sformatf("[B%0d:", byte_idx)}; 

          for (int bit_indx = 0; bit_indx < 8; bit_indx++) begin
            current_byte[bit_indx] = (cfg.is_tx ? vif.tx : vif.rx);
            
            bit_stream = {bit_stream, $sformatf("%b", current_byte[bit_indx])};
            
            repeat(clks_per_bit) @(posedge vif.clk);
          end
          
          bit_stream = {bit_stream, "] "}; 

          t.data[(byte_idx*8) +: 8] = current_byte;

          if (cfg.ppb_enable && cfg.parity_mode != NONE) begin
            if (cfg.parity_mode == EVEN)
              expected_parity = ^current_byte;
            else
              expected_parity = ~^current_byte;

            if ((cfg.is_tx ? vif.tx : vif.rx) !== expected_parity)
              t.detect_parity_err = 1;

            bit_stream = {bit_stream, $sformatf("[P%0d:%b] ", byte_idx, (cfg.is_tx ? vif.tx : vif.rx))};

            repeat(clks_per_bit) @(posedge vif.clk);
          end
        end

        t.calc_checksum(cfg.parity_mode);
        if ((cfg.is_tx ? vif.tx : vif.rx) !== t.checksum)
          t.detect_checksum_err = 1;

        t.checksum = (cfg.is_tx ? vif.tx : vif.rx);
        
        bit_stream = {bit_stream, $sformatf("[ChkSum:%b] ", t.checksum)};
        
        repeat(clks_per_bit) @(posedge vif.clk);

        bit_stream = {bit_stream, "[Stop:"};
        for (int s = 0; s < cfg.stop_bits; s++) begin
          if ((cfg.is_tx ? vif.tx : vif.rx) !== 1'b1)
            t.detect_framing_err = 1;

          bit_stream = {bit_stream, $sformatf("%b", (cfg.is_tx ? vif.tx : vif.rx))};

          if (s < cfg.stop_bits - 1)
            repeat(clks_per_bit) @(posedge vif.clk);
        end
        bit_stream = {bit_stream, "]"}; 

        $display("[%0t] [%s] BIT STREAM: %s", $time, mon_name, bit_stream);

        uart_mon_mbx.put(t);
      end
    endtask
endclass