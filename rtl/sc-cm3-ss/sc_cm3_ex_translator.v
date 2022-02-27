//-----------------------------------------------
// Space Cubics Cortex-M3 SubSystem
//  Cortex-M3 Exclusive Access Translator
//  Module: sc_cm3_ex_translator
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_cm3_ex_translator (
  // System Interface
  input HCLK,
  input HRESETN,

  // AHB Interface
  input [1:0] HTRANS,
  input HWRITE,
  input HREADY,
  input EXREQ,
  output reg EXRESP,

  // AXI Interface
  input AWVALID,
  input [1:0] AWLOCK_I,
  output reg [1:0] AWLOCK_O,
  input ARVALID,
  input [1:0] ARLOCK_I,
  output reg [1:0] ARLOCK_O,
  input BVALID,
  input BREADY,
  input [1:0] BRESP,
  input RVALID,
  input RREADY,
  input [1:0] RRESP
);

reg detect_exreq;
reg read0write1;
reg latch_resp;
always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    detect_exreq <= 1'b0;
    read0write1 <= 1'b0;
  end
  else begin
    if ((HTRANS == 2'b10 | HTRANS == 2'b11) & HREADY & EXREQ) begin
      detect_exreq <= 1'b1;
      read0write1 <= HWRITE;
    end
    else if (detect_exreq & HREADY)
      detect_exreq <= 1'b0;
  end
end

always @ (*) begin
  EXRESP = 1'b0;
  if (HREADY) begin
    if (detect_exreq & read0write1) begin
      if (BVALID & BREADY)
        EXRESP = (BRESP != 2'b01);
      else
        EXRESP = latch_resp;
    end
    else if (detect_exreq & !read0write1) begin
      if (RVALID & RREADY)
        EXRESP = (RRESP != 2'b01);
      else
        EXRESP = latch_resp;
    end
  end
end

always @ (*) begin
  AWLOCK_O = AWLOCK_I;
  if (AWVALID) begin
    if (detect_exreq & read0write1)
      AWLOCK_O = 2'b01;
  end

  ARLOCK_O = ARLOCK_I;
  if (ARVALID) begin
    if (detect_exreq & !read0write1)
      ARLOCK_O = 2'b01;
  end
end

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN)
    latch_resp <= 1'b0;
  else if (detect_exreq & read0write1) begin
    if (BVALID & BREADY)
      latch_resp = (BRESP != 2'b01);
    else if (detect_exreq & !read0write1)
      if (RVALID & RREADY)
        latch_resp = (RRESP != 2'b01);
  end
end

endmodule
