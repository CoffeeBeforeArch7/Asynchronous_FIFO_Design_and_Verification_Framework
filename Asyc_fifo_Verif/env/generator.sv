`ifndef GENERATOR_SV
`define GENERATOR_SV
class generator #(parameter DSIZE = 8);
packet pkt;
mailbox SMbx; //SMbx = Scoreboard Mailbox

function new(mailbox SMbx);
    this.SMbx = SMbx;
endfunction
    
    task send(int sendNumber);  //Randomly generate pkt data and save it in the Mbx
        $display("%0t: INFO: GENERATOR.send task, Start Sending... sendNumber = %0d",$time,sendNumber);
        repeat(sendNumber) begin
            pkt = new();
            assert(pkt.randomize);
            $display(pkt);
            SMbx.put(pkt);
        end
        $display("%0t: INFO: GENERATOR.send task, END Sending...",$time);
    endtask

endclass

`endif