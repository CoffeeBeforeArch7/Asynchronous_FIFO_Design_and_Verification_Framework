class monitor #(parameter DSIZE = 8);

virtual     fifoPorts itf;
rand logic [DSIZE-1:0] wdata;
mailbox                RMbx;
packet                 pkt;


function new (virtual fifoPorts itf, mailbox RMbx );
    this.itf = itf;
    this.RMbx = RMbx;
endfunction

task Read(input int putInMbx , input int readNumber);
    int i = 0;
    $display("%0t: INFO: Monitor.Read task Start Reading... readNumber = %0d",$time, readNumber);
    do begin
        pkt = new();
        this.itf.rinc <= 1'b1;
        @(posedge itf.rclk);
        if(putInMbx) begin
            this.pkt.data = itf.rdata; //from DUT
            this.pkt.opt  = RD;
            this.RMbx.put(this.pkt);
        end
        i++;
    end while (i < readNumber);
    this.itf.rinc <= 1'b0;
    $display("%0t: INFO: Monitor.Read task END Reading",$time);
endtask

endclass