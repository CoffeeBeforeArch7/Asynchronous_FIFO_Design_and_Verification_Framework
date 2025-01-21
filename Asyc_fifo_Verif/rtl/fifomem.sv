module fifomem #(parameter DATASIZE = 8, parameter ADDRSIZE = 4)
  // Memory data word width, Number of mem address bits
  (input  [DATASIZE-1:0] wdata,
   input  [ADDRSIZE-1:0] waddr, raddr,
   input  wclken, wfull, wclk,
   output [DATASIZE-1:0] rdata
  );

  `ifdef VENDORRAM
    // Instantiation of a vendor's dual-port RAM
    vendor_ram mem (.dout(rdata),
                    .din(wdata),
                    .waddr(waddr),
                    .raddr(raddr),
                    .wclken(wclken),
                    .wclken_n(wfull),
                    .clk(wclk)
    );
  `else
    // RTL Verilog memory model
    localparam DEPTH = 1<<ADDRSIZE;
    reg [DATASIZE-1:0] mem [0:DEPTH-1];
    assign rdata = mem[raddr];

    always @(posedge wclk)
      if (wclken && !wfull)
        mem[waddr] <= wdata;
  `endif

endmodule
