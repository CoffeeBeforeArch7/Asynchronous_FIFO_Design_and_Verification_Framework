class clockGenerator;

    logic wclk, rclk;
    int period;
    virtual fifoPorts itf;
    event wclkkill, rclkkill;

    function new(virtual fifoPorts itf);
        this.itf = itf;
    endfunction

    task automatic clkActivate(input string clkName);
        //write clk generate/kill
        if(clkName == "wclk") begin
            $display("%0t: INFO: Calling task wclkActivate",$time);
            this.itf.wclk = 1'b0;

            fork: clkGen
                wait(this.wclkkill.triggered) begin: Killclock
                    $display("%t INFO: Killing the clk",$time);
                end: Killclock

                forever begin: startclock
                    #this.period this.itf.wclk++;//每隔period单位循环生成时钟(前面是延时信号，后面是动作)
                end: startclock
            join_any: clkGen //join_any 检测到一个进程完成，执行 disable fork，disable fork 终止所有进程，包括时钟生成
            disable fork;
        end

        else begin
            $display("%0t: INFO: Calling task rclkActivate", $time);
            this.itf.rclk = 1'b0;
            fork: clkGen2
                wait(this.rclkkill.triggered) begin: Killclock
                    $display("%0t INFO: Killing the clk",$time);
                end: Killclock

                forever begin: startclock
                    #this.period this.itf.rclk++;//每隔period单位循环生成时钟
                end: startclock
            join_any: clkGen2
            disable fork;
        end
    endtask

    task automatic clkGenerator (input string clkName, input int wclkPeriod);
        $display("%0t: INFO: Calling task clockGenerator for %s",$time,clkName);
        this.period = wclkPeriod / 2;
        fork
            clkActivate(clkName);
        join_none //立即启动 clkActivate,不等待fork中的进程完成(时钟进程是不会自然结束的,所以不能等待时钟完成)
    endtask

    task clkStop(input string clkName);
        $display("%0t: INFO: Stopping clock %s", $time, clkName);
        if(clkName == "wclk")
            ->wclkkill;
        else 
            ->rclkkill;
    endtask
endclass
