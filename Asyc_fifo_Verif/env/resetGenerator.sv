class resetGenerator;
    logic rrst , wrst;
    int period;
    virtual fifoPorts itf;
    event rrstkill, wrstkill;

    function new(virtual fifoPorts itf);
        this.itf = itf;
    endfunction

    task automatic rstActivate (input string rstName);
        if(rstName == "rrst") begin
            $display("%0t: INFO: Calling task rrstActivate",$time);
            this.itf.rrst_n = 1'b1;
            repeat(this.period) @(posedge this.itf.rclk);
            this.itf.rrst_n = 1'b0;
            repeat(this.period) @(posedge this.itf.rclk);
            this.itf.rrst_n = 1'b1;
        end
        else begin
            $display("%0t: INFO: Calling task wrstActivate",$time);
            this.itf.wrst_n = 1'b1;
            repeat(this.period) @(posedge this.itf.wclk);
            this.itf.wrst_n = 1'b0;
            repeat(this.period) @(posedge this.itf.wclk);
            this.itf.wrst_n = 1'b1;
        end
    endtask

    task automatic rstGenerator (input string rstName, input int rstPeriod);
        $display("%0t: INFO: Calling task clkGenerator for %s",$time, rstName);
        this.period = rstPeriod;
        init();
        rstActivate(rstName);
    endtask

    extern function automatic void init();
endclass


function automatic void resetGenerator::init();
    this.itf.winc = 0;
    this.itf.rinc = 0;
    this.itf.wdata = '0;
    
endfunction


