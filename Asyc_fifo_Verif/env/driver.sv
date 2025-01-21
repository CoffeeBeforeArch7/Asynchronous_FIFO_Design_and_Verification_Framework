class driver #(parameter DSIZE = 8);

virtual     fifoPorts itf;
rand logic [DSIZE-1:0] wdata;

mailbox     WMbx;
mailbox     GMbx;
packet      pkt;

function new (virtual fifoPorts itf, mailbox GMbx, mailbox WMbx);
    this.itf  = itf;
    this.GMbx = GMbx; //GMbx = Generator Mailbox
    this.WMbx = WMbx; //WMbx = Write Mailbox
endfunction

task Write(input int putInMbx , input int writeNumber);
    int i = 0;
    $display("%0t: INFO: Driver.Write task Start Writing... writeNumber = %0d",$time, writeNumber);
    do begin
        this.itf.wcb.winc <= 1'b1;
        //this.itf.wcb.wdata <= i;
        GMbx.get(pkt);//这里的mbx数据来自于generator，所以在driver模块中也没有对packet进行实例化
            this.itf.wcb.wdata <= pkt.data;
        
        pkt.opt = WR;
        if(putInMbx)begin
            this.WMbx.put(pkt);
        end
        @(posedge itf.wclk);
        i++;
    end while (i < writeNumber);
    this.itf.wcb.winc <= 1'b0;
    $display("%0t: INFO: Driver.Write task END Writing",$time);
endtask

endclass