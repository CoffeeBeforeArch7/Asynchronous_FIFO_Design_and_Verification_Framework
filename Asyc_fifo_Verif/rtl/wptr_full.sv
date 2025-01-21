module wptr_full #(parameter ADDRSIZE = 4)
  (input  [ADDRSIZE :0] wq2_rptr, //Write Queue 2-flop synchronized（经过两级触发器同步到写时钟域的读指针）
   input  winc, wclk, wrst_n,
   output reg wfull,
   output [ADDRSIZE-1:0] waddr,
   output reg [ADDRSIZE :0] wptr //宽度为 ADDRSIZE+1 的 Gray 编码写指针
  );

  reg [ADDRSIZE:0] wbin;
  wire [ADDRSIZE:0] wgraynext, wbinnext;

  // Memory write-address pointer (okay to use binary to address memory)
  assign waddr = wbin[ADDRSIZE-1:0];
  assign wbinnext = wbin + (winc & ~wfull);
  assign wgraynext = (wbinnext>>1) ^ wbinnext; // 二进制转格雷码：右移一位再异或

  //Simplified version of the three necessary full-tests:
  assign wfull_val=((wgraynext[ADDRSIZE] != wq2_rptr[ADDRSIZE] ) &&
                   (wgraynext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
                   (wgraynext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));

//more complex version
  // assign wfull_val = (wgraynext == {
  //                                    ~wq2_rptr[ADDRSIZE:ADDRSIZE-1],//// 最高两位取反
  //                                     wq2_rptr[ADDRSIZE-2:0] });  //低3位保持不变

  // GRAYSTYLE2 pointer
  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n) {wbin, wptr} <= 0;
    else         {wbin, wptr} <= {wbinnext, wgraynext};

  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n) wfull <= 1'b0;
    else         wfull <= wfull_val;

endmodule
