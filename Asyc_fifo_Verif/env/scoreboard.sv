`ifndef SCB_SV
`define SCB_SV
class scoreboard #(parameter DSIZE = 8);
    mailbox             WMbx, RMbx;
    bit [DSIZE-1:0]     wdata,rdata;
    packet              wpkt, rpkt;

    function new (mailbox WMbx , RMbx);
    this.WMbx = WMbx; //GMbx = Generator Mailbox
    this.RMbx = RMbx; //WMbx = Write Mailbox
    this.wrc  = new();
    endfunction

covergroup wrc ;
    winc_cp : coverpoint wpkt.opt{
                            bins wr = {WR};
                            ignore_bins nop = {RD};
    }
    rinc_cp : coverpoint rpkt.opt{
                            bins rd = {RD};
                            ignore_bins nop = {WR};
    }
endgroup



    task printMbxContent(input mailbox mbx, string message);
        int mbxElements;
        packet pkt;
        bit [DSIZE-1:0] mbxData;
        packet q[$];
        mbxElements = mbx.num();//获取邮箱中现有的数据包数量(>=number of cycles)
        for (int i = 0; i < mbxElements; i++) begin
            mbx.get(pkt);
            q.push_back(pkt);//store in queue, as data to be putback into the orig mbx
        end
        $write ("%s",message);
        foreach (q[i]) begin
            if(i == 0)
                $write("%d", q[i].data);  // 第一个数据前不加逗号
            else 
                $write(",%d",q[i].data); // 其他数据前加逗号
            mbx.put(q[i]); // putback in the mbx in its orig order
        end
        $display("   ");
    endtask


    task compareData;
        int loopw,loopr;

        printMbxContent(WMbx,"Golden Data:");
        printMbxContent(RMbx,"Actual Data:");
        $display("\n %0t: INFO: Scoreboard.Compare task, Start Comparing...",$time);

        loopw = WMbx.num();
        loopr = RMbx.num();

        if(loopw != loopr)begin
            $display("%0t: INFO: <><><><><> FIALED for size-mismatch <><><><><>",$time);
        end
        else begin
            for (int i = 0; i < loopw ; i++) begin
                WMbx.get(this.wpkt);
                RMbx.get(this.rpkt);
            wrc.sample();
                if(wpkt.data == rpkt.data)
                    $display("%0t: INFO: Scoreboard: P A S S: Write(%0d) and Read(%0d) data are the Same", $time, this.wpkt.data, this.rpkt.data);
                else
                    $display("%0t: INFO: Scoreboard: <><><>FAILED<><><>: Write(%0d) and Read(%0d) data are Different", $time, this.wpkt.data, this.rpkt.data);
            end
        end
    endtask

endclass



`endif